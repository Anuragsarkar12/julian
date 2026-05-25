-- CATEGORY 7: PROBLEM-SOLVING (10 questions)

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('ps-incomplete-information',
 'Decision With 40% Information',
 'Tell me about a time you had to make a significant technical decision with only 40% of the information you wanted. How did you decide, and were you right?',
 'problem-solving', 'hard',
 ARRAY['Frame what information you had vs. what was missing','Show you had a structured reasoning process, not just intuition','Include the risk you accepted and how you mitigated it','Reflect on whether you were right and what you learned'],
 'Situation — Had to choose between two cloud providers for a new service with incomplete pricing data and no benchmark results. Task — Make a decision that wouldn''t be expensive to reverse. Action — Identified the 3 most critical factors, made a reversible choice with containerization to ease migration, set a 30-day evaluation checkpoint. Result — Choice was correct; the evaluation checkpoint caught a billing issue early that saved $8K/month.'),

('ps-debugging-impossible',
 'The Impossible Bug',
 'Describe the hardest bug you have ever debugged. What made it so difficult and how did you eventually find it?',
 'problem-solving', 'hard',
 ARRAY['Walk through your debugging methodology step by step','Explain why conventional debugging approaches failed','Show creative thinking — what unconventional approach cracked it','Include time invested and the root cause'],
 'Situation — Intermittent 502 errors affecting 0.1% of requests, only during peak hours, impossible to reproduce locally. Task — Find and fix a bug with no stack trace and no consistent pattern. Action — Added distributed tracing, correlated with load balancer logs, discovered a race condition in connection pooling that only triggered when exactly 3 requests hit the same instance within 2ms. Result — Fixed with a mutex lock, zero 502s since, total debugging time was 4 days.'),

('ps-ambiguous-requirements',
 'Ambiguous Requirements',
 'Tell me about a time you received vague or contradictory requirements. How did you clarify them and move forward?',
 'problem-solving', 'medium',
 ARRAY['Show you didn''t just build what you assumed — you actively clarified','Explain your process for disambiguating requirements','Demonstrate how you balanced speed with thoroughness','Include the outcome and whether your clarification was valuable'],
 'Situation — PM said "make the dashboard faster" with no specific metrics, pages, or user complaints to reference. Task — Turn a vague request into actionable engineering work. Action — Ran a user session analysis to identify the 3 slowest interactions, set measurable targets (p95 under 2s), proposed a phased approach. Result — PM approved the specific plan, we hit all targets in 3 weeks, and the PM adopted our metrics-first approach for future requests.'),

('ps-system-design-tradeoff',
 'System Design Tradeoff',
 'Describe a time you had to make a difficult tradeoff between two valid system design approaches. How did you evaluate and decide?',
 'problem-solving', 'medium',
 ARRAY['Name the specific tradeoff and why both options had merit','Explain your evaluation framework and criteria','Show how you involved the team in the decision','Include whether the tradeoff played out as expected'],
 'Situation — Choosing between event-driven architecture (eventual consistency, high scalability) and synchronous API calls (strong consistency, simpler debugging) for an order processing system. Task — Make a decision the team could live with for 3+ years. Action — Built a decision matrix weighted by our specific needs, prototyped the trickiest flow in both approaches, presented data to the team. Result — Chose event-driven with a synchronous fallback for critical paths, handled 10x growth without redesign.'),

('ps-root-cause-analysis',
 'Finding the Real Root Cause',
 'Tell me about a time the obvious cause of a problem turned out to be wrong. How did you find the actual root cause?',
 'problem-solving', 'medium',
 ARRAY['Explain why the obvious cause seemed right initially','Show your systematic approach to digging deeper','Demonstrate intellectual humility when your first hypothesis was wrong','Include the real root cause and how it changed your debugging approach'],
 'Situation — Users reported slow page loads; everyone assumed it was the database. Task — Fix performance, which had degraded 3x over 2 months. Action — Profiled the full request path instead of just the DB, discovered a third-party analytics script had silently increased its payload by 400%. Result — Removed the bloated script, page load returned to baseline, established a performance budget that alerts on third-party script changes.'),

('ps-scaling-challenge',
 'Unexpected Scaling Challenge',
 'Describe a time your system hit an unexpected scaling limit. How did you diagnose and solve it?',
 'problem-solving', 'hard',
 ARRAY['Explain what scaled beyond expectations and why you didn''t anticipate it','Walk through your diagnostic process','Show the short-term fix vs. the long-term solution','Include metrics: what was the limit, what did you achieve after fixing'],
 'Situation — Our notification service crashed when a viral post triggered 50K notifications in 10 seconds, 100x normal load. Task — Restore service immediately and prevent recurrence. Action — Immediate: increased instance count and added a queue. Long-term: implemented rate limiting, batched notifications, and added circuit breakers. Result — System now handles 500K notifications/minute, auto-scales, and gracefully degrades under extreme load.'),

('ps-first-principles',
 'First Principles Thinking',
 'Give me an example of a time you solved a problem by going back to first principles rather than following the conventional approach.',
 'problem-solving', 'medium',
 ARRAY['Explain what the conventional approach was and why you questioned it','Show your first-principles reasoning process','Demonstrate the solution was genuinely better, not just different','Include adoption and impact'],
 'Situation — Team was building a complex caching layer to speed up a slow API. Task — Question whether caching was the right solution. Action — Went back to basics: analyzed why the API was slow. Discovered we were fetching and transforming data on every request that only changed daily. Replaced the cache with a pre-computed materialized view that updated via cron. Result — Simpler architecture, faster responses (5ms vs. 50ms cached), eliminated cache invalidation bugs entirely.'),

('ps-data-inconsistency',
 'Resolving Data Inconsistency',
 'Tell me about a time you discovered a data inconsistency in production. How did you investigate, fix, and prevent it?',
 'problem-solving', 'easy',
 ARRAY['Explain how you discovered the inconsistency','Walk through your investigation methodology','Show how you fixed existing bad data without causing more problems','Include the preventive measures you implemented'],
 'Situation — Customer support reported 50 users with negative account balances, which should be impossible. Task — Find the source, fix affected accounts, and prevent recurrence. Action — Traced transactions chronologically, found a race condition in concurrent withdrawal processing, wrote a migration to correct balances, added database-level constraints. Result — All 50 accounts corrected within 24 hours, constraint prevented 12 more potential occurrences in the following month.'),

('ps-constraint-innovation',
 'Innovation Under Constraints',
 'Describe a time a significant constraint (budget, time, technology) forced you to find a creative solution you wouldn''t have otherwise considered.',
 'problem-solving', 'easy',
 ARRAY['Name the specific constraint and why it seemed limiting','Show how the constraint actually drove better thinking','Explain the creative solution and why it worked','Include whether you''d choose this approach even without the constraint'],
 'Situation — Needed real-time analytics but had zero budget for a streaming platform like Kafka. Task — Build near-real-time dashboards with only our existing PostgreSQL database. Action — Used PostgreSQL LISTEN/NOTIFY for change events, a lightweight Node.js service to aggregate, and Server-Sent Events to push to the browser. Result — Dashboards updated within 2 seconds, total infrastructure cost was $0 extra, solution ran reliably for 2 years.'),

('ps-legacy-modernization',
 'Modernizing Legacy Systems',
 'Tell me about a time you had to modernize a legacy system without breaking existing functionality. What was your approach?',
 'problem-solving', 'hard',
 ARRAY['Show you understood why the legacy system existed and its constraints','Explain your strangler fig or incremental migration strategy','Demonstrate how you maintained backward compatibility','Include the timeline and any setbacks'],
 'Situation — A 7-year-old monolithic PHP app handling $2M/month in transactions needed to be migrated to microservices. Task — Migrate without any downtime or transaction failures. Action — Used the strangler fig pattern: built new services behind the old API, routed traffic gradually using feature flags, ran both systems in parallel with reconciliation checks. Result — Migration took 8 months, zero transaction failures, old system fully decommissioned, deployment frequency went from monthly to daily.');


-- CATEGORY 8: ADAPTABILITY (10 questions)

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('adapt-priorities-shifted',
 'Dramatic Priority Shift',
 'Give me an example of a time your team''s priorities shifted dramatically mid-project. How did you handle the transition while keeping quality high?',
 'adaptability', 'medium',
 ARRAY['Explain the original plan and what caused the shift','Show how you triaged existing work vs. new priorities','Demonstrate you maintained team morale during the change','Include the outcome for both the original and new priorities'],
 'Situation — Two months into a 4-month platform redesign, company pivoted to focus on a new enterprise client requiring a completely different feature set. Task — Preserve the 60% of redesign work that overlapped while delivering enterprise features. Action — Mapped overlap between projects, paused non-overlapping redesign work, created a combined roadmap that served both goals. Result — Enterprise client onboarded on time, resumed redesign with 40% already done, team avoided the "wasted work" morale hit.'),

('adapt-new-technology',
 'Rapid Technology Adoption',
 'Describe a time you had to learn and ship production code in a technology you had no experience with, under time pressure.',
 'adaptability', 'medium',
 ARRAY['Quantify the timeline and the technology gap','Explain your learning strategy, not just that you learned it','Show how you managed risk while learning','Include the quality of what you shipped and any follow-up'],
 'Situation — Our Go backend engineer quit 2 weeks before a major release, and I was a Python/TypeScript developer with zero Go experience. Task — Learn enough Go to fix critical bugs and ship the release. Action — Spent day 1 on Go fundamentals via the official tour, day 2-3 reading our codebase with a Go-experienced reviewer on standby, days 4-10 fixing bugs with thorough code reviews. Result — Release shipped on time, 3 bugs fixed, code review feedback was "looks like it was written by someone who knows Go."'),

('adapt-role-change',
 'Unexpected Role Change',
 'Tell me about a time your role changed significantly — either by choice or circumstance. How did you adapt?',
 'adaptability', 'easy',
 ARRAY['Explain the role change and why it happened','Show what skills transferred and what you had to develop','Demonstrate a growth mindset rather than resistance','Include what you learned about yourself'],
 'Situation — Tech lead left suddenly, and I was promoted from mid-level IC to acting tech lead for a team of 6. Task — Lead the team while still ramping up on their projects. Action — Spent the first week in 1:1s understanding each person''s context, delegated technical decisions I wasn''t qualified to make, focused on unblocking and process improvement. Result — Team didn''t miss any deliverables during the transition, two engineers said it was the smoothest leadership transition they''d experienced.'),

('adapt-failure-pivot',
 'Pivoting After a Failed Approach',
 'Describe a time you invested significant effort in an approach that wasn''t working. How did you recognize it and pivot?',
 'adaptability', 'medium',
 ARRAY['Show how much effort was invested before you pivoted','Explain the signals that told you the approach was failing','Demonstrate you didn''t fall prey to sunk cost fallacy','Include the pivot and its outcome'],
 'Situation — Spent 3 weeks building a custom ML model for spam detection when a simple rules-based approach would have caught 95% of spam. Task — Admit the ML approach was over-engineered for our current scale. Action — Benchmarked the simple approach against my model, found marginal improvement for 10x complexity, proposed shipping rules-based now with ML as a future enhancement. Result — Shipped in 2 days, caught 94% of spam, saved the ML work for when our volume justified the complexity.'),

('adapt-remote-transition',
 'Adapting to Remote Work',
 'Tell me about how you adapted your working style when transitioning to remote or hybrid work. What specific changes did you make?',
 'adaptability', 'easy',
 ARRAY['Be specific about what changed in your workflow','Show proactive adaptation, not just passive adjustment','Include both personal productivity and team collaboration changes','Demonstrate ongoing iteration on your remote work practices'],
 'Situation — Team went fully remote during 2020 with no remote work culture or tools in place. Task — Maintain productivity and team cohesion without in-person interaction. Action — Set up daily 15-min video standups, created virtual coworking sessions for focus time, established "camera on" norms for collaborative meetings and "camera optional" for status updates. Result — Team velocity actually increased 15% after the first month, and 3 of my practices were adopted org-wide.'),

('adapt-customer-feedback-pivot',
 'Pivoting Based on User Feedback',
 'Describe a time real user feedback fundamentally changed the direction of something you were building. How did you handle the pivot?',
 'adaptability', 'medium',
 ARRAY['Show you were genuinely open to the feedback, not defensive','Explain how you validated the feedback beyond a single data point','Demonstrate how you managed the pivot with your team and stakeholders','Include the before/after product direction and outcome'],
 'Situation — Built an advanced analytics dashboard with 15 chart types; user testing revealed people only used 3 and couldn''t find them among the noise. Task — Simplify without losing the work invested in advanced features. Action — Redesigned around the 3 core charts as the default view, moved advanced charts to an "Expert Mode" toggle, ran another round of user testing. Result — User satisfaction jumped from 3.2/5 to 4.6/5, and Expert Mode was used by the 8% of power users who needed it.'),

('adapt-org-restructure',
 'Navigating an Org Restructure',
 'Tell me about a time your team or organization went through a significant restructure. How did you navigate the uncertainty?',
 'adaptability', 'hard',
 ARRAY['Show how you managed your own uncertainty while supporting others','Explain what specifically changed and how it affected your work','Demonstrate you focused on what you could control','Include how you emerged from the restructure'],
 'Situation — Company reorganized engineering from product-aligned teams to platform teams, splitting my team across 3 new groups. Task — Maintain project continuity and team morale during the transition. Action — Created a transition doc mapping every in-flight project to its new owner, set up cross-team syncs for the first month, had honest conversations with teammates about their concerns. Result — Zero projects were dropped, all teammates landed in roles they were excited about, and I was asked to help design the next reorg process.'),

('adapt-scope-reduction',
 'Graceful Scope Reduction',
 'Describe a time you had to dramatically reduce the scope of a project to meet a deadline. How did you decide what to cut?',
 'adaptability', 'easy',
 ARRAY['Explain your prioritization framework for what to keep vs. cut','Show how you communicated the scope change to stakeholders','Demonstrate you cut scope without cutting quality on what remained','Include the outcome and any follow-up on cut features'],
 'Situation — A 12-feature release needed to ship in 3 weeks instead of 6 due to a competitive threat. Task — Identify the minimum viable feature set that would still be compelling. Action — Ranked features by customer impact using support ticket data, identified 5 must-haves, negotiated with PM to defer 7 features to a fast-follow release. Result — 5-feature release shipped on time, captured 80% of expected value, remaining 7 features shipped over the following 4 weeks.'),

('adapt-changing-requirements',
 'Requirements Changed Three Times',
 'Tell me about a project where the requirements changed multiple times during development. How did you manage the constant shifts?',
 'adaptability', 'hard',
 ARRAY['Show you didn''t just react — you built a process to handle change','Explain how you protected your team from whiplash','Demonstrate how you balanced flexibility with engineering discipline','Include the final outcome and whether the changes improved the product'],
 'Situation — E-commerce checkout flow requirements changed 3 times in 5 weeks as the business model pivoted from B2C to B2B. Task — Deliver a working checkout without rebuilding from scratch each time. Action — Architected the checkout as modular components with configuration-driven behavior, so requirement changes became config changes, not code rewrites. Result — Each pivot required only 2-3 days of work instead of weeks, final B2B checkout shipped on time with all 3 pivots incorporated.'),

('adapt-tech-stack-migration',
 'Adapting to a New Tech Stack',
 'Describe joining a company or team that used a completely different tech stack than what you knew. How did you get productive quickly?',
 'adaptability', 'easy',
 ARRAY['Be specific about the stack gap and what was most challenging','Show your learning strategy was systematic, not just trial and error','Demonstrate you contributed meaningfully during the learning curve','Include your time-to-productivity and what accelerated it'],
 'Situation — Moved from a React/Node shop to a company using Elixir/Phoenix with LiveView, which I''d never touched. Task — Become productive within my first month. Action — Spent week 1 building a personal project in Elixir, week 2 reading the team''s most critical service line by line, weeks 3-4 taking progressively larger tickets with pairing support. Result — Shipped my first production feature in week 3, was doing independent code reviews by week 6, and brought useful React patterns to the team''s LiveView architecture.');
