// frontend/src/app/profile/page.tsx
'use client'
import { useState, useEffect } from 'react'
import { Flame, Trophy, Target, BarChart3, Calendar, Award } from 'lucide-react'
import { getFullProfile, getActivityHeatmap } from '@/lib/api'
import { ActivityHeatmap } from '@/components/ActivityHeatmap'
import { SkeletonCard } from '@/components/Skeleton'
import type { FullProfile, ActivityDay } from '@/types'

const CATEGORY_EMOJIS: Record<string, string> = {
  conflict: '⚔️', leadership: '👑', failure: '💔', achievement: '🏆',
  teamwork: '🤝', communication: '💬', 'problem-solving': '🧩',
  adaptability: '🔄', initiative: '🚀', growth: '🌱',
}

export default function ProfilePage() {
  const [profile, setProfile] = useState<FullProfile | null>(null)
  const [heatmapDays, setHeatmapDays] = useState<ActivityDay[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.allSettled([
      getFullProfile().then(setProfile),
      getActivityHeatmap().then(r => setHeatmapDays(r.days)),
    ]).finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8 space-y-6">
        <SkeletonCard className="h-40" />
        <SkeletonCard className="h-32" />
        <SkeletonCard className="h-48" />
      </div>
    )
  }

  if (!profile) return null

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      {/* Profile Header */}
      <div className="bg-neutral-900 rounded-md border border-neutral-800 p-6 mb-6">
        <div className="flex items-center gap-5">
          {profile.avatar_url ? (
            <img src={profile.avatar_url} alt="" className="w-16 h-16 rounded-md border border-neutral-700" />
          ) : (
            <div className="w-16 h-16 rounded-md bg-neutral-800 flex items-center justify-center text-2xl font-bold text-neutral-50">
              {(profile.full_name || 'U').charAt(0).toUpperCase()}
            </div>
          )}
          <div className="flex-1">
            <h1 className="text-xl font-bold text-white">{profile.full_name || 'Anonymous'}</h1>
            <p className="text-sm text-neutral-400">{profile.email}</p>
            {profile.global_rank && (
              <p className="text-xs text-white mt-1">Global Rank #{profile.global_rank}</p>
            )}
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6 stagger-children">
        <StatCard
          icon={<Target className="w-4 h-4 text-white" />}
          label="Sessions"
          value={String(profile.total_sessions)}
        />
        <StatCard
          icon={<Flame className="w-4 h-4 text-orange-400" />}
          label="Current Streak"
          value={`${profile.current_streak}d`}
        />
        <StatCard
          icon={<BarChart3 className="w-4 h-4 text-cyan-400" />}
          label="Avg Score"
          value={profile.avg_score ? String(Math.round(profile.avg_score)) : '—'}
        />
        <StatCard
          icon={<Trophy className="w-4 h-4 text-amber-400" />}
          label="Questions Solved"
          value={String(profile.questions_solved)}
        />
      </div>

      {/* Activity Heatmap */}
      <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <Calendar className="w-4 h-4 text-neutral-500" />
          <h2 className="text-sm font-semibold text-neutral-300">Activity</h2>
        </div>
        <ActivityHeatmap days={heatmapDays} />
      </div>

      {/* Badges */}
      <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <Award className="w-4 h-4 text-amber-400" />
          <h2 className="text-sm font-semibold text-neutral-300">Badges</h2>
          <span className="text-xs text-slate-600 ml-auto">
            {profile.badges.filter(b => b.earned).length} / {profile.badges.length} earned
          </span>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
          {profile.badges.map(badge => (
            <div
              key={badge.id}
              className={`flex flex-col items-center p-3 rounded-md border transition-all ${
                badge.earned
                  ? 'border-emerald-800 bg-emerald-950/30'
                  : 'border-neutral-800 bg-neutral-900 opacity-50'
              }`}
            >
              <span className="text-2xl mb-1">{badge.emoji}</span>
              <p className={`text-xs font-medium text-center ${badge.earned ? 'text-emerald-300' : 'text-neutral-600'}`}>{badge.name}</p>
              <p className={`text-[10px] text-center mt-0.5 ${badge.earned ? 'text-emerald-500' : 'text-neutral-600'}`}>
                {badge.earned ? '✓ Earned' : badge.progress || badge.description}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Category Breakdown */}
      {profile.categories.length > 0 && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
          <h2 className="text-sm font-semibold text-neutral-300 mb-4">Category Breakdown</h2>
          <div className="space-y-3">
            {profile.categories.map(cat => (
              <div key={cat.category} className="flex items-center gap-4">
                <span className="text-lg w-8 text-center">{CATEGORY_EMOJIS[cat.category] || '📝'}</span>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm text-neutral-300 capitalize">{cat.category}</span>
                    <span className="text-xs text-neutral-500">
                      {cat.solved} solved · avg {Math.round(cat.avg_score)}
                    </span>
                  </div>
                  <div className="h-1.5 bg-neutral-900 rounded-sm overflow-hidden">
                    <div
                      className="h-full bg-emerald-600 rounded-sm transition-all duration-700"
                      style={{ width: `${cat.avg_score}%` }}
                    />
                  </div>
                </div>
                <span className="text-sm font-bold text-white w-8 text-right">{cat.best_score}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

function StatCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="bg-neutral-950 rounded-md border border-neutral-800 p-4 animate-fade-in">
      <div className="flex items-center gap-1.5 mb-2">
        {icon}
        <span className="text-xs text-neutral-500">{label}</span>
      </div>
      <p className="text-xl font-bold text-white">{value}</p>
    </div>
  )
}
