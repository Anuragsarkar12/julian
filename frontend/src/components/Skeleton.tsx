// frontend/src/components/Skeleton.tsx

export function SkeletonCard({ className = '' }: { className?: string }) {
  return (
    <div className={`bg-slate-900 rounded-2xl border border-slate-800 p-6 animate-pulse ${className}`}>
      <div className="h-3 w-24 bg-slate-800 rounded mb-4" />
      <div className="h-8 w-32 bg-slate-800 rounded mb-3" />
      <div className="h-3 w-full bg-slate-800 rounded mb-2" />
      <div className="h-3 w-3/4 bg-slate-800 rounded" />
    </div>
  )
}

export function SkeletonTable({ rows = 5 }: { rows?: number }) {
  return (
    <div className="space-y-2 animate-pulse">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="flex items-center gap-4 p-3 bg-slate-900 rounded-xl border border-slate-800">
          <div className="w-8 h-8 bg-slate-800 rounded-full shrink-0" />
          <div className="flex-1">
            <div className="h-3 w-40 bg-slate-800 rounded mb-2" />
            <div className="h-2.5 w-24 bg-slate-800 rounded" />
          </div>
          <div className="h-4 w-12 bg-slate-800 rounded" />
        </div>
      ))}
    </div>
  )
}

export function SkeletonText({ lines = 3, className = '' }: { lines?: number; className?: string }) {
  return (
    <div className={`space-y-2 animate-pulse ${className}`}>
      {Array.from({ length: lines }).map((_, i) => (
        <div
          key={i}
          className="h-3 bg-slate-800 rounded"
          style={{ width: `${100 - i * 15}%` }}
        />
      ))}
    </div>
  )
}
