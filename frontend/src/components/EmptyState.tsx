// frontend/src/components/EmptyState.tsx
import Link from 'next/link'

interface Props {
  icon?: string
  title: string
  description: string
  actionLabel?: string
  actionHref?: string
}

export function EmptyState({ icon = '📭', title, description, actionLabel, actionHref }: Props) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
      <h3 className="text-lg font-semibold text-white mb-2">{title}</h3>
      <p className="text-sm text-neutral-400 max-w-sm mb-6">{description}</p>
      {actionLabel && actionHref && (
        <Link
          href={actionHref}
          className="px-5 py-2 bg-white text-black hover:bg-neutral-200 rounded-sm text-sm font-semibold transition-colors"
        >
          {actionLabel}
        </Link>
      )}
    </div>
  )
}
