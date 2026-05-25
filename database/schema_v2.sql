-- Julian V2 — New Tables for LeetCode-Style Platform
-- Run these in Supabase SQL Editor AFTER schema.sql (v1) is already applied.

-- ══════════════════════════════════════════════════════════════════════════
-- Block 1: Questions Table (replaces daily_challenges as the primary bank)
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.questions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug              TEXT NOT NULL UNIQUE,
  title             TEXT NOT NULL,
  prompt_text       TEXT NOT NULL,
  category          TEXT NOT NULL CHECK (category IN (
                      'conflict','leadership','failure','achievement',
                      'teamwork','communication','problem-solving',
                      'adaptability','initiative','growth'
                    )),
  difficulty        TEXT NOT NULL CHECK (difficulty IN ('easy','medium','hard')),
  tips              TEXT[] NOT NULL,
  example_answer    TEXT,
  times_attempted   INTEGER DEFAULT 0,
  avg_score         NUMERIC(5,2) DEFAULT 0,
  added_date        DATE DEFAULT CURRENT_DATE,
  is_potd_eligible  BOOLEAN DEFAULT true,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_questions_category   ON public.questions(category);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty  ON public.questions(difficulty);
CREATE INDEX IF NOT EXISTS idx_questions_slug        ON public.questions(slug);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 2: User Question Attempts
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_question_attempts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  question_id       UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  session_id        UUID REFERENCES public.speech_sessions(id),
  best_score        INTEGER,
  attempts          INTEGER DEFAULT 1,
  last_attempted_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_uqa_user     ON public.user_question_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_uqa_question ON public.user_question_attempts(question_id);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 3: Problem of the Day
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.potd (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id  UUID NOT NULL REFERENCES public.questions(id),
  potd_date    DATE NOT NULL UNIQUE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_potd_date ON public.potd(potd_date DESC);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 4: Daily Leaderboard (per-POTD rankings)
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.daily_leaderboard (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  potd_date    DATE NOT NULL,
  question_id  UUID NOT NULL REFERENCES public.questions(id),
  session_id   UUID NOT NULL REFERENCES public.speech_sessions(id),
  score        INTEGER NOT NULL,
  rank         INTEGER,
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, potd_date)
);

CREATE INDEX IF NOT EXISTS idx_dl_date  ON public.daily_leaderboard(potd_date DESC);
CREATE INDEX IF NOT EXISTS idx_dl_score ON public.daily_leaderboard(potd_date, score DESC);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 5: Global Rankings (all-time)
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.global_rankings (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  questions_solved        INTEGER DEFAULT 0,
  total_potd_points       INTEGER DEFAULT 0,
  potd_days_participated  INTEGER DEFAULT 0,
  best_potd_score         INTEGER DEFAULT 0,
  avg_potd_score          NUMERIC(5,2) DEFAULT 0,
  global_rank             INTEGER,
  updated_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gr_rank ON public.global_rankings(global_rank);
CREATE INDEX IF NOT EXISTS idx_gr_solved ON public.global_rankings(questions_solved DESC);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 6: Add question_id to speech_sessions (backward compatible)
-- ══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'speech_sessions' AND column_name = 'question_id'
  ) THEN
    ALTER TABLE public.speech_sessions ADD COLUMN question_id UUID REFERENCES public.questions(id);
  END IF;
END $$;


-- ══════════════════════════════════════════════════════════════════════════
-- Block 7: Add username to users if missing
-- ══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'username'
  ) THEN
    ALTER TABLE public.users ADD COLUMN username TEXT UNIQUE;
  END IF;
END $$;


-- ══════════════════════════════════════════════════════════════════════════
-- Block 8: Row Level Security for new tables
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.questions               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_question_attempts  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potd                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_leaderboard       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.global_rankings         ENABLE ROW LEVEL SECURITY;

-- Questions: anyone authenticated can read
CREATE POLICY "questions_read_all" ON public.questions
  FOR SELECT TO authenticated USING (true);

-- POTD: anyone authenticated can read
CREATE POLICY "potd_read_all" ON public.potd
  FOR SELECT TO authenticated USING (true);

-- Daily leaderboard: anyone can read, users can insert their own
CREATE POLICY "daily_lb_read_all" ON public.daily_leaderboard
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "daily_lb_insert_own" ON public.daily_leaderboard
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Global rankings: anyone can read
CREATE POLICY "global_rank_read_all" ON public.global_rankings
  FOR SELECT TO authenticated USING (true);

-- User question attempts: users can do everything on their own rows
CREATE POLICY "attempts_own" ON public.user_question_attempts
  FOR ALL USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 9: Update handle_new_user to also create global_rankings row
-- ══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;

  -- Also create a global_rankings row for the new user
  INSERT INTO public.global_rankings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
