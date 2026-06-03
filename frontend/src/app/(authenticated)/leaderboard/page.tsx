// frontend/src/app/leaderboard/page.tsx
'use client'
import { useState, useEffect } from 'react'
import { Trophy, Flame, Target, Users, Calendar, Globe } from 'lucide-react'
import { getDailyLeaderboard, getGlobalLeaderboard } from '@/lib/api'
import { SkeletonTable } from '@/components/Skeleton'
import { EmptyState } from '@/components/EmptyState'
import type { DailyLeaderboardEntry, GlobalRankingEntry, DailyLeaderboard, GlobalRankings } from '@/types'

type Tab = 'daily' | 'global'

export default function LeaderboardPage() {
  const [tab, setTab] = useState<Tab>('daily')
  const [daily, setDaily] = useState<DailyLeaderboard | null>(null)
  const [global, setGlobal] = useState<GlobalRankings | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    if (tab === 'daily') {
      getDailyLeaderboard().then(setDaily).catch(() => {}).finally(() => setLoading(false))
    } else {
      getGlobalLeaderboard().then(setGlobal).catch(() => {}).finally(() => setLoading(false))
    }
  }, [tab])

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <Trophy className="w-6 h-6 text-amber-400" />
          Leaderboard
        </h1>
        <p className="text-sm text-neutral-400 mt-1">See how you rank against other candidates</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-neutral-950 rounded-sm p-1 border border-neutral-800 mb-6 w-fit">
        <button
          onClick={() => setTab('daily')}
          className={`flex items-center gap-2 px-4 py-2 rounded-sm text-sm font-medium transition-all ${
            tab === 'daily'
              ? 'bg-neutral-800 text-white'
              : 'text-neutral-500 hover:text-white hover:bg-neutral-900'
          }`}
        >
          <Calendar className="w-4 h-4" /> Daily POTD
        </button>
        <button
          onClick={() => setTab('global')}
          className={`flex items-center gap-2 px-4 py-2 rounded-sm text-sm font-medium transition-all ${
            tab === 'global'
              ? 'bg-neutral-800 text-white'
              : 'text-neutral-500 hover:text-white hover:bg-neutral-900'
          }`}
        >
          <Globe className="w-4 h-4" /> Global Rankings
        </button>
      </div>

      {loading ? (
        <SkeletonTable rows={10} />
      ) : tab === 'daily' ? (
        <DailyTab data={daily} />
      ) : (
        <GlobalTab data={global} />
      )}
    </div>
  )
}



function DailyTab({ data }: { data: DailyLeaderboard | null }) {
  if (!data || data.entries.length === 0) {
    return (
      <EmptyState
        icon="📊"
        title="No submissions yet today"
        description="Be the first to submit today's Problem of the Day!"
        actionLabel="Go to POTD"
        actionHref="/potd"
      />
    )
  }

  return (
    <div>
      {/* Header info */}
      <div className="bg-neutral-950 rounded-md border border-neutral-800 p-4 mb-4 flex items-center justify-between">
        <div>
          <p className="text-xs text-neutral-500 uppercase tracking-widest">Today&apos;s Question</p>
          <p className="text-sm text-white font-medium mt-0.5">{data.question_title || 'Problem of the Day'}</p>
        </div>
        <div className="flex items-center gap-1 text-sm text-neutral-400">
          <Users className="w-4 h-4" />
          <span>{data.total_submissions} submissions</span>
        </div>
      </div>

      {/* Top 3 podium */}
      {data.entries.length >= 3 && (
        <div className="grid grid-cols-3 gap-3 mb-6">
          {[data.entries[1], data.entries[0], data.entries[2]].map((entry, i) => {
            const medals = ['🥈', '🥇', '🥉']
            const sizes = ['h-28', 'h-36', 'h-24']
            return (
              <div
                key={entry.user_id}
                className={`bg-neutral-950 rounded-md border border-neutral-800 flex flex-col items-center justify-end p-4 ${sizes[i]} ${
                  entry.is_current_user ? 'ring-1 ring-white' : ''
                } animate-slide-up`}
                style={{ animationDelay: `${i * 100}ms` }}
              >
                <span className="text-2xl mb-1">{medals[i]}</span>
                <p className="text-xs text-neutral-300 truncate max-w-full">{entry.full_name || 'Anonymous'}</p>
                <p className="text-lg font-bold text-white font-mono">{entry.score}</p>
              </div>
            )
          })}
        </div>
      )}

      {/* Full list */}
      <div className="space-y-1.5">
        {data.entries.map((entry, i) => (
          <div
            key={entry.user_id}
            className={`flex items-center gap-4 p-3 rounded-md border transition-all animate-fade-in ${
              entry.is_current_user
                ? 'bg-neutral-900 border-neutral-800'
                : 'border-neutral-800 bg-neutral-950'
            }`}
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <span className={`w-8 text-center text-sm font-bold ${
              entry.rank === 1 ? 'text-amber-400' :
              entry.rank === 2 ? 'text-neutral-300' :
              entry.rank === 3 ? 'text-orange-400' :
              'text-neutral-500'
            }`}>
              {entry.rank <= 3 ? ['🥇','🥈','🥉'][entry.rank - 1] : `#${entry.rank}`}
            </span>

            <Avatar src={entry.avatar_url} name={entry.full_name || 'Anonymous'} />

            <div className="flex-1 min-w-0">
              <p className="text-sm text-neutral-300 truncate">
                {entry.full_name || 'Anonymous'}
                {entry.is_current_user && <span className="text-white ml-2 text-xs">(you)</span>}
              </p>
            </div>

            <span className="text-sm font-bold text-white font-mono">{entry.score}</span>
          </div>
        ))}
      </div>
    </div>
  )
}



function GlobalTab({ data }: { data: GlobalRankings | null }) {
  if (!data || data.entries.length === 0) {
    return (
      <EmptyState
        icon="🌍"
        title="No rankings yet"
        description="Start practicing to earn your global ranking!"
        actionLabel="Browse Questions"
        actionHref="/questions"
      />
    )
  }

  return (
    <div>
      {/* User rank banner */}
      {data.user_rank && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-4 mb-6 flex items-center justify-between">
          <div>
            <p className="text-xs text-neutral-500 uppercase tracking-widest">Your Global Rank</p>
            <p className="text-2xl font-bold text-white mt-0.5 font-mono">#{data.user_rank}</p>
          </div>
          <p className="text-sm text-neutral-400 font-mono">out of {data.total_users} participants</p>
        </div>
      )}

      {/* Table header */}
      <div className="flex items-center gap-4 px-4 py-2 text-xs text-neutral-500 uppercase tracking-widest">
        <span className="w-8">Rank</span>
        <span className="flex-1">User</span>
        <span className="w-20 text-center hidden sm:block">Solved</span>
        <span className="w-20 text-center hidden sm:block">Avg POTD</span>
        <span className="w-16 text-center hidden sm:block">Streak</span>
      </div>

      <div className="space-y-1.5">
        {data.entries.map((entry, i) => (
          <div
            key={entry.user_id}
            className={`flex items-center gap-4 p-3 rounded-md border transition-all animate-fade-in ${
              entry.is_current_user
                ? 'bg-neutral-900 border-neutral-800'
                : 'border-neutral-800 bg-neutral-950'
            }`}
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <span className={`w-8 text-center text-sm font-bold font-mono ${
              entry.rank <= 3 ? 'text-amber-400' : 'text-neutral-500'
            }`}>
              #{entry.rank}
            </span>

            <Avatar src={entry.avatar_url} name={entry.full_name || 'Anonymous'} />

            <div className="flex-1 min-w-0">
              <p className="text-sm text-neutral-300 truncate">
                {entry.full_name || 'Anonymous'}
                {entry.is_current_user && <span className="text-white ml-2 text-xs">(you)</span>}
              </p>
            </div>

            <div className="w-20 text-center hidden sm:block">
              <div className="flex items-center justify-center gap-1">
                <Target className="w-3 h-3 text-emerald-500" />
                <span className="text-sm text-white font-medium font-mono">{entry.questions_solved}</span>
              </div>
            </div>

            <div className="w-20 text-center hidden sm:block">
              <span className="text-sm text-neutral-300 font-mono">{entry.avg_potd_score > 0 ? Math.round(entry.avg_potd_score) : '—'}</span>
            </div>

            <div className="w-16 text-center hidden sm:block">
              <div className="flex items-center justify-center gap-1">
                <Flame className="w-3 h-3 text-orange-400" />
                <span className="text-sm text-neutral-300 font-mono">{entry.current_streak}d</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function Avatar({ src, name }: { src?: string | null; name: string }) {
  const [error, setError] = useState(false)
  const initial = (name || 'A').charAt(0).toUpperCase()
  
  if (!src || error) {
    return (
      <div className="w-8 h-8 rounded-sm bg-neutral-900 flex items-center justify-center text-xs font-bold text-white font-mono shrink-0">
        {initial}
      </div>
    )
  }
  
  return (
    <img 
      src={src} 
      alt="" 
      className="w-8 h-8 rounded-sm border border-neutral-800 shrink-0" 
      onError={() => setError(true)} 
    />
  )
}
