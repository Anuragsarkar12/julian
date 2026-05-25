-- Julian MVP — Complete Database Schema
-- Run these in Supabase SQL Editor → New Query, one block at a time.

-- ══════════════════════════════════════════════════════════════════════════
-- Block 1: Extensions and Users
-- ══════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE public.users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT NOT NULL,
  full_name   TEXT,
  avatar_url  TEXT,
  username    TEXT UNIQUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create user row on first Google login
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
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ══════════════════════════════════════════════════════════════════════════
-- Block 2: Daily Challenges
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE public.daily_challenges (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_date DATE NOT NULL UNIQUE,
  prompt_text    TEXT NOT NULL,
  category       TEXT NOT NULL CHECK (category IN ('behavioral','impromptu','storytelling','persuasion','technical')),
  difficulty     TEXT NOT NULL DEFAULT 'medium' CHECK (difficulty IN ('easy','medium','hard')),
  tips           TEXT[],
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_daily_challenges_date ON public.daily_challenges(challenge_date);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 3: Speech Sessions
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE public.speech_sessions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  challenge_id     UUID REFERENCES public.daily_challenges(id),
  status           TEXT NOT NULL DEFAULT 'uploading'
                     CHECK (status IN ('uploading','processing','completed','failed')),
  storage_path     TEXT,
  duration_seconds NUMERIC(6,2),
  error_message    TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  completed_at     TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user_id      ON public.speech_sessions(user_id);
CREATE INDEX idx_sessions_created_at   ON public.speech_sessions(created_at DESC);
CREATE INDEX idx_sessions_status       ON public.speech_sessions(status);
CREATE INDEX idx_sessions_user_date    ON public.speech_sessions(user_id, created_at DESC);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 4: Speech Metrics
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE public.speech_metrics (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id              UUID NOT NULL REFERENCES public.speech_sessions(id) ON DELETE CASCADE,
  user_id                 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Transcription
  transcript_text         TEXT,
  word_count              INTEGER DEFAULT 0,

  -- Delivery metrics
  wpm                     NUMERIC(6,2) DEFAULT 0,
  filler_count            INTEGER DEFAULT 0,
  filler_rate             NUMERIC(6,4) DEFAULT 0,
  filler_words_found      JSONB DEFAULT '{}',
  pause_count             INTEGER DEFAULT 0,
  pause_total_seconds     NUMERIC(6,2) DEFAULT 0,
  longest_pause_seconds   NUMERIC(5,2) DEFAULT 0,
  pitch_variance          NUMERIC(8,4) DEFAULT 0,
  energy_variance         NUMERIC(10,8) DEFAULT 0,

  -- Scores (0-100)
  delivery_score          INTEGER CHECK (delivery_score BETWEEN 0 AND 100),
  content_score           INTEGER CHECK (content_score BETWEEN 0 AND 100),
  improvement_score       INTEGER CHECK (improvement_score BETWEEN 0 AND 100),
  consistency_score       INTEGER CHECK (consistency_score BETWEEN 0 AND 100),
  total_score             INTEGER CHECK (total_score BETWEEN 0 AND 100),

  -- AI coaching (raw Gemini JSON)
  gemini_feedback         JSONB DEFAULT '{}',

  created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_metrics_session_id ON public.speech_metrics(session_id);
CREATE INDEX idx_metrics_user_id           ON public.speech_metrics(user_id);
CREATE INDEX idx_metrics_user_date         ON public.speech_metrics(user_id, created_at DESC);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 5: Streaks, Leaderboard, Feedback
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE public.streaks (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  current_streak      INTEGER DEFAULT 0,
  longest_streak      INTEGER DEFAULT 0,
  last_activity_date  DATE,
  total_sessions      INTEGER DEFAULT 0,
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.leaderboard (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  week_start      DATE NOT NULL,
  total_score     INTEGER DEFAULT 0,
  sessions_count  INTEGER DEFAULT 0,
  avg_score       NUMERIC(5,2) DEFAULT 0,
  rank            INTEGER,
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

CREATE INDEX idx_leaderboard_week  ON public.leaderboard(week_start DESC);
CREATE INDEX idx_leaderboard_score ON public.leaderboard(week_start, total_score DESC);

CREATE TABLE public.feedback (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id       UUID NOT NULL REFERENCES public.speech_sessions(id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  overall_summary  TEXT,
  strengths        TEXT[],
  improvements     TEXT[],
  structure_score  INTEGER CHECK (structure_score BETWEEN 0 AND 10),
  clarity_score    INTEGER CHECK (clarity_score BETWEEN 0 AND 10),
  engagement_score INTEGER CHECK (engagement_score BETWEEN 0 AND 10),
  coaching_tip     TEXT,
  next_focus       TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_feedback_session_id ON public.feedback(session_id);
CREATE INDEX idx_feedback_user_id           ON public.feedback(user_id);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 6: Row Level Security
-- ══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.users           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speech_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speech_metrics  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "sessions_select_own" ON public.speech_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "metrics_select_own" ON public.speech_metrics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "feedback_select_own" ON public.feedback
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "streaks_select_own" ON public.streaks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "leaderboard_select_all" ON public.leaderboard
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "challenges_select_all" ON public.daily_challenges
  FOR SELECT TO authenticated USING (true);


-- ══════════════════════════════════════════════════════════════════════════
-- Block 7: 15-Day Seed Challenges (Interview-Focused)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.daily_challenges (challenge_date, prompt_text, category, difficulty, tips) VALUES

(CURRENT_DATE,
 'Tell me about a time you had a conflict with a teammate. How did you handle it?',
 'behavioral', 'medium',
 ARRAY['Use the STAR format: Situation → Task → Action → Result',
       'Be specific — name the actual disagreement, not a vague "misunderstanding"',
       'Focus 70% of your time on YOUR actions, not the other person',
       'End with what you learned and how you would do it differently']),

(CURRENT_DATE + 1,
 'Describe a project where you had to learn something completely new under time pressure.',
 'behavioral', 'medium',
 ARRAY['Pick a real example — interviewers probe for specifics',
       'Quantify the timeline: "I had 3 days to learn X"',
       'Explain your learning strategy, not just that you learned it',
       'State the outcome with a concrete result: shipped, promoted, etc.']),

(CURRENT_DATE + 2,
 'Walk me through your greatest professional failure and what you took from it.',
 'behavioral', 'hard',
 ARRAY['Choose a failure that is genuinely yours to own',
       'Avoid: "my failure was working too hard" — interviewers see through this',
       'Be specific about what went wrong and why',
       'Make the lesson concrete: "Since then, I always..."']),

(CURRENT_DATE + 3,
 'Tell me about a time you disagreed with your manager. What happened?',
 'behavioral', 'hard',
 ARRAY['Show you can push back respectfully, not just comply',
       'Include how you presented your argument with data or reasoning',
       'Show the outcome regardless of whose view prevailed',
       'Demonstrate you can commit to a decision you disagreed with']),

(CURRENT_DATE + 4,
 'Describe a situation where you had to prioritize between multiple urgent tasks.',
 'behavioral', 'medium',
 ARRAY['Name the specific competing priorities — do not stay abstract',
       'Explain your prioritization framework (impact, deadline, dependencies)',
       'Mention what you communicated to stakeholders',
       'Result: what got done, what tradeoffs were made']),

(CURRENT_DATE + 5,
 'You have 90 seconds. Explain what a REST API is to a non-technical hiring manager.',
 'technical', 'easy',
 ARRAY['Analogy first: "Think of it like a waiter in a restaurant"',
       'Avoid acronyms — HTTP, JSON, endpoint all need plain-English explanations',
       'One real example they would recognize (ordering food, getting weather)',
       'Land a clear conclusion: why does this matter in software?']),

(CURRENT_DATE + 6,
 'Pitch yourself to a skeptical engineer interviewer in 60 seconds.',
 'impromptu', 'hard',
 ARRAY['Lead with one concrete thing you have built, not your resume title',
       'Make a claim: "I am particularly strong at X because Y"',
       'Include one number: users, performance improvement, time saved',
       'End with why this specific role interests you — not generic']),

(CURRENT_DATE + 7,
 'Tell me about a time you had to influence someone without direct authority.',
 'behavioral', 'hard',
 ARRAY['This tests leadership without a title — be clear this was influence, not management',
       'Explain how you understood their perspective first',
       'Show the specific mechanism: data, demos, relationships, framing',
       'Result: did they change their position? What happened to the project?']),

(CURRENT_DATE + 8,
 'Describe a time you received difficult feedback. How did you respond?',
 'behavioral', 'medium',
 ARRAY['Avoid defensive language — this is a test of self-awareness',
       'Be specific about the feedback: what exactly was said',
       'What did you do within the next 30 days?',
       'Show observable change: how did this affect your next performance review or project?']),

(CURRENT_DATE + 9,
 'Walk me through a decision you made with incomplete information.',
 'behavioral', 'hard',
 ARRAY['Frame your reasoning: what information did you have vs. what was missing',
       'Show you had a process — not just a gut feeling',
       'Include the risk you accepted and how you mitigated it',
       'Outcome + reflection: was the decision right? Would you do it the same way?']),

(CURRENT_DATE + 10,
 'You just joined a new team. Your first week, you notice a process that wastes 2 hours per week. What do you do?',
 'impromptu', 'medium',
 ARRAY['This tests judgment: when to speak up vs. listen and learn first',
       'Acknowledge you are new — humility matters in your first 30 days',
       'Show your process: observe, validate, propose — do not assume you are right',
       'How would you raise it? To whom? With what framing?']),

(CURRENT_DATE + 11,
 'Convince me that the product you are interviewing to build genuinely matters.',
 'persuasion', 'medium',
 ARRAY['Do your research — mention something specific about this product',
       'Lead with user pain, not company financials',
       'Use a personal connection or analogy to make it real',
       'Do not just say "I believe in the mission" — give a concrete reason']),

(CURRENT_DATE + 12,
 'Tell me about a time you had to deliver bad news to a stakeholder.',
 'behavioral', 'medium',
 ARRAY['Structure: What was the bad news, who needed to hear it, how did you deliver it',
       'Show you prepared — did you come with a plan, not just a problem',
       'Include how you managed their reaction',
       'What did this project teach you about managing expectations earlier?']),

(CURRENT_DATE + 13,
 'Describe your ideal working environment and how you perform your best.',
 'impromptu', 'easy',
 ARRAY['Be honest but strategic — match their culture if you know it',
       'Be specific: "I do my best thinking in long uninterrupted blocks" vs. vague answers',
       'Include both solo work and collaboration — show range',
       'Land it: "Which is why I was excited about this role because..."']),

(CURRENT_DATE + 14,
 'You have to explain a technical architecture decision to both engineers and the CEO in the same meeting. How do you do it?',
 'technical', 'hard',
 ARRAY['Acknowledge the audience split upfront',
       'Layer your explanation: high-level first (CEO), then depth (engineers)',
       'Use visuals in your description — even if you are just speaking, reference a diagram',
       'Ask a bridging question to calibrate: "Does that make sense before I go deeper?"'])

ON CONFLICT (challenge_date) DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- Block 8: Create Supabase Storage Bucket
-- Run this separately or create via Supabase Dashboard → Storage → New Bucket
-- ══════════════════════════════════════════════════════════════════════════
-- INSERT INTO storage.buckets (id, name, public) VALUES ('recordings', 'recordings', false);
