// frontend/src/app/dashboard/page.tsx
'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Flame, Trophy, Target, BarChart3, ChevronRight, Clock, Zap, TrendingUp } from 'lucide-react'
import { getPOTDToday, getHistory, getUserProfile, getPOTDLeaderboard } from '@/lib/api'
import { ProgressChart } from '@/components/ProgressChart'
import { CategoryBadge, DifficultyBadge } from '@/components/CategoryBadge'
import { CountdownTimer } from '@/components/CountdownTimer'
import { SkeletonCard } from '@/components/Skeleton'
import type { POTD, HistorySession, UserProfile, DailyLeaderboardEntry } from '@/types'

export default function DashboardPage() {
  const [potd, setPotd] = useState<POTD | null>(null)
  const [history, setHistory] = useState<HistorySession[]>([])
  const [profile, setProfile] = useState<UserProfile | null>(null)
  const [leaderboard, setLeaderboard] = useState<DailyLeaderboardEntry[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.allSettled([
      getPOTDToday().then(setPotd),
      getHistory(14).then(r => setHistory(r.sessions)),
      getUserProfile().then(setProfile),
      getPOTDLeaderboard().then(r => setLeaderboard(r.entries.slice(0, 5))),
    ]).finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            <SkeletonCard className="h-48" />
            <SkeletonCard className="h-40" />
          </div>
          <div className="space-y-6">
            <SkeletonCard className="h-36" />
            <SkeletonCard className="h-44" />
          </div>
        </div>
      </div>
    )
  }

  const greeting = getGreeting()

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      {/* Page header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-white">{greeting}, {profile?.full_name?.split(' ')[0] || 'there'}</h1>
        <p className="text-sm text-slate-400 mt-1">Ready for today&apos;s challenge?</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* ── Left Column (2/3) ──────────────────────────────────────────── */}
        <div className="lg:col-span-2 space-y-6">
          {/* POTD Hero Card */}
          {potd && (
            <div className="bg-gradient-to-br from-violet-950/50 to-slate-900 rounded-2xl border border-violet-900/50 p-6 card-hover">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <Zap className="w-5 h-5 text-violet-400" />
                  <span className="text-sm font-semibold text-violet-400">Problem of the Day</span>
                </div>
                <div className="flex items-center gap-2 text-xs text-slate-500">
                  <Clock className="w-3.5 h-3.5" />
                  <CountdownTimer />
                </div>
              </div>

              <h2 className="text-lg font-semibold text-white mb-2">{potd.question.title}</h2>
              <p className="text-sm text-slate-300 leading-relaxed mb-4 line-clamp-2">
                {potd.question.prompt_text}
              </p>

              <div className="flex items-center gap-2 mb-5">
                <CategoryBadge category={potd.question.category} />
                <DifficultyBadge difficulty={potd.question.difficulty} />
              </div>

              {potd.user_submitted ? (
                <div className="flex items-center gap-4">
                  <div className="flex items-center gap-2 text-emerald-400 text-sm font-medium">
                    <div className="status-dot-green" />
                    Completed — Score: {potd.user_score}
                  </div>
                  <Link
                    href={`/results/${potd.user_session_id}`}
                    className="text-sm text-violet-400 hover:text-violet-300 transition-colors"
                  >
                    View Results →
                  </Link>
                </div>
              ) : (
                <Link
                  href="/potd"
                  className="inline-flex items-center gap-2 px-5 py-2.5 bg-violet-600 hover:bg-violet-500 text-white rounded-full font-semibold text-sm transition-all hover:shadow-lg hover:shadow-violet-500/25 animate-pulse-glow"
                >
                  Start Challenge <ChevronRight className="w-4 h-4" />
                </Link>
              )}
            </div>
          )}

          {/* Progress Chart */}
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-violet-400" />
                <h3 className="text-sm font-semibold text-slate-300">Score Trend</h3>
              </div>
              <Link href="/history" className="text-xs text-slate-500 hover:text-slate-300 transition-colors">
                View all →
              </Link>
            </div>
            <ProgressChart sessions={history} />
          </div>

          {/* Recent Sessions */}
          {history.length > 0 && (
            <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6">
              <h3 className="text-sm font-semibold text-slate-300 mb-4">Recent Sessions</h3>
              <div className="space-y-2">
                {history.slice(-5).reverse().map((s, i) => (
                  <Link
                    key={s.session_id}
                    href={`/results/${s.session_id}`}
                    className="flex items-center justify-between p-3 rounded-xl hover:bg-slate-800/50 transition-colors group animate-fade-in"
                    style={{ animationDelay: `${i * 60}ms` }}
                  >
                    <div className="flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold ${
                        s.total_score >= 80 ? 'bg-emerald-950/60 text-emerald-400' :
                        s.total_score >= 60 ? 'bg-amber-950/60 text-amber-400' :
                        'bg-red-950/60 text-red-400'
                      }`}>
                        {s.total_score}
                      </div>
                      <div>
                        <p className="text-sm text-slate-300 group-hover:text-white transition-colors">
                          {s.question_title || 'Practice Session'}
                        </p>
                        <p className="text-xs text-slate-600">
                          {Math.round(s.wpm)} WPM · {s.filler_count} fillers
                        </p>
                      </div>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-700 group-hover:text-slate-400 transition-colors" />
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* ── Right Column (1/3) ─────────────────────────────────────────── */}
        <div className="space-y-6">
          {/* Stats Cards */}
          <div className="grid grid-cols-2 gap-3 stagger-children">
            <StatCard
              icon={<Target className="w-4 h-4 text-violet-400" />}
              label="Sessions"
              value={String(profile?.total_sessions || 0)}
            />
            <StatCard
              icon={<Flame className="w-4 h-4 text-orange-400" />}
              label="Streak"
              value={`${profile?.current_streak || 0}d`}
            />
            <StatCard
              icon={<BarChart3 className="w-4 h-4 text-cyan-400" />}
              label="Avg Score"
              value={profile?.avg_score ? String(Math.round(profile.avg_score)) : '—'}
            />
            <StatCard
              icon={<Trophy className="w-4 h-4 text-amber-400" />}
              label="Best Streak"
              value={`${profile?.longest_streak || 0}d`}
            />
          </div>

          {/* Quick Links */}
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-4 space-y-1">
            <h3 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-2 px-2">Quick Actions</h3>
            <QuickLink href="/questions" label="Browse Questions" description="100 curated behavioral questions" />
            <QuickLink href="/leaderboard" label="Leaderboard" description="See how you rank globally" />
            <QuickLink href="/profile" label="My Profile" description="Badges, stats & activity" />
          </div>

          {/* Mini Daily Leaderboard */}
          {leaderboard.length > 0 && (
            <div className="bg-slate-900 rounded-2xl border border-slate-800 p-4">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-xs font-semibold text-slate-500 uppercase tracking-widest">Today&apos;s Top</h3>
                <Link href="/leaderboard" className="text-xs text-violet-400 hover:text-violet-300">
                  View all →
                </Link>
              </div>
              <div className="space-y-2">
                {leaderboard.map(entry => (
                  <div
                    key={entry.user_id}
                    className={`flex items-center gap-3 p-2 rounded-lg ${entry.is_current_user ? 'bg-violet-950/30 border border-violet-900/50' : ''}`}
                  >
                    <span className={`w-5 text-xs font-bold text-center ${
                      entry.rank === 1 ? 'text-amber-400' :
                      entry.rank === 2 ? 'text-slate-300' :
                      entry.rank === 3 ? 'text-orange-400' :
                      'text-slate-600'
                    }`}>
                      {entry.rank <= 3 ? ['🥇','🥈','🥉'][entry.rank - 1] : `#${entry.rank}`}
                    </span>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs text-slate-300 truncate">
                        {entry.full_name || 'Anonymous'}
                        {entry.is_current_user && <span className="text-violet-400 ml-1">(you)</span>}
                      </p>
                    </div>
                    <span className="text-xs font-bold text-white">{entry.score}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

function StatCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="bg-slate-900 rounded-xl border border-slate-800 p-4 animate-fade-in">
      <div className="flex items-center gap-1.5 mb-2">
        {icon}
        <span className="text-xs text-slate-500">{label}</span>
      </div>
      <p className="text-xl font-bold text-white">{value}</p>
    </div>
  )
}

function QuickLink({ href, label, description }: { href: string; label: string; description: string }) {
  return (
    <Link
      href={href}
      className="flex items-center justify-between px-2 py-2.5 rounded-lg hover:bg-slate-800/50 transition-colors group"
    >
      <div>
        <p className="text-sm text-slate-300 group-hover:text-white transition-colors">{label}</p>
        <p className="text-xs text-slate-600">{description}</p>
      </div>
      <ChevronRight className="w-4 h-4 text-slate-700 group-hover:text-slate-400 transition-colors" />
    </Link>
  )
}

function getGreeting() {
  const h = new Date().getHours()
  if (h < 12) return 'Good morning'
  if (h < 17) return 'Good afternoon'
  return 'Good evening'
}
