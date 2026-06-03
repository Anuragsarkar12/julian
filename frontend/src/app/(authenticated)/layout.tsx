// frontend/src/app/(authenticated)/layout.tsx
import { NavBar } from '@/components/NavBar'

export default function AuthenticatedLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50">
      <NavBar />
      {children}
    </div>
  )
}
