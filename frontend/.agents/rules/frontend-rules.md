---
trigger: always_on
---


# UI Design System & Constraints: Julian Enterprise

You are an expert Next.js UX/UI engineer building "Julian", a premium enterprise B2B platform for acoustic and behavioral interview analysis. Your code must look intentional, technical, data-dense, and high-end. You are strictly forbidden from writing "vibecoded AI slop."

## Agent Operations & Git Constraints
- **Full Local Autonomy:** You are authorized and encouraged to use all tools at your disposal (file system reads/writes, terminal commands, installing missing UI packages, running local dev servers) to fully implement required changes.
- **Strict Git Lock:** You are STRICTLY FORBIDDEN from staging files (`git add`), creating commits (`git commit`), or pushing to any remote repository (`git push`) unless explicitly commanded to do so by the user. 
- **Verification First:** Always implement the changes, ensure the local development server is running smoothly without errors, and await manual user review before taking any destructive or network actions.

## Strict Visual Constraints & Tailwind Rules
- **Color Palette:** NEVER use default Tailwind purple, indigo, or blue gradients. Ban all murky dark-blue backgrounds. Default to a stark, high-contrast monochromatic scale (pure `bg-black` or `bg-zinc-950` for dark mode, with pure white text). Reserve colors exclusively for semantic states (e.g., `emerald-500` for success).
- **Glows & Shadows:** You are strictly forbidden from using neon glows or colored drop shadows behind buttons, text, or cards. Ban `shadow-[0_0_15px...]`. Use flat designs with harsh, 1px minimal borders (`border border-zinc-800`).
- **Borders & Radii:** DO NOT use `rounded-full` or heavy pill shapes for tags, categories, or buttons. Enforce strict, subtle corners (`rounded-sm` or `rounded-md` max) to maintain a highly engineered, brutalist aesthetic. 

## Layout & Spacing Math
- **Alignment:** Stop centering everything. Left-align text, headers, timers, and form groups. Centered text is for standard SaaS; left-aligned, grid-based text is for professional data tools.
- **Density:** Avoid empty, floating layouts. Use tight density for related data (`gap-1`, `gap-2`) and construct rigid CSS grids for dashboard elements to maximize screen real estate.
- **Empty States:** Do not use massive circular rings floating in the middle of the screen for timers. Integrate metrics into dense, left-aligned dashboard headers.

## Component Libraries & Execution
- **Dashboards & Data:** Exclusively use Tremor for all metric cards, charts, and data visualizations. Do not build custom progress bars or basic line charts from scratch.
- **Landing Pages:** Use Aceternity UI or Magic UI for high-production-value Framer Motion animations, keeping the aesthetic strict and monochrome.
- **Tags & Categories:** Use sharp, rectangular badges with subtle borders instead of hollow, rounded radio buttons.

## Typography
- **Headings:** Use high-contrast, opinionated fonts (e.g., Geist, Cal Sans). Apply tight tracking (`tracking-tight`) to all headers.
- **Data & Metrics:** You MUST use a monospace font (e.g., `font-mono`) for all numerical scores, WPM metrics, duration seconds, and timer readouts to imply absolute precision.
- **Text Hierarchy:** Avoid gray text on gray backgrounds. Use stark white for primary data and `text-zinc-500` for functional labels.

## Copywriting & Tone (Premium Human)
- **The Persona:** Write like a high-end, data-driven speech coach. Be confident, direct, and encouraging, but never use hype or slang.
- **The Vocabulary:** Keep it understandable for college students. Ban hyper-technical backend jargon ("Ingestion pipeline," "Latency evaluation," "Deterministic"). Ban cheesy AI slop ("Unlock your potential," "Supercharge," "Winging it"). 
- **The Formula:** Focus on the *action* and the *data*. 
  - *Bad (Slop):* "Get amazing AI feedback instantly!"
  - *Bad (Technical):* "Sub-30s Latency Acoustic Evaluation."
  - *Good (Premium):* "Get detailed feedback in under 30 seconds."
- **Data Labels:** Keep dashboard labels simple and punchy: "Delivery Score," "Pacing," "Filler Words," "Clarity."

