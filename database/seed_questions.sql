-- Julian V2 — 100 Behavioral Interview Questions Seed
-- Run AFTER schema_v2.sql

-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 1: CONFLICT (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('conflict-peer-technical-disagreement',
 'Peer Technical Pushback',
 'Tell me about a time a peer openly disagreed with your technical approach in front of the team. How did you handle it without damaging the relationship?',
 'conflict', 'hard',
 ARRAY['Describe the specific technical disagreement, not a vague difference of opinion','Show you listened to their perspective before defending yours','Explain how you separated the technical debate from the personal relationship','End with what happened to both the project and the relationship'],
 'Situation — A senior engineer challenged my database migration strategy during a design review with 8 people present. Task — I needed to address valid concerns without escalating tension. Action — I acknowledged their points publicly, proposed we timebox a spike to test both approaches with benchmarks. Result — Their approach was faster for reads but mine handled writes better; we combined both, and they became my strongest advocate.'),

('conflict-cross-team-priority',
 'Cross-Team Priority Clash',
 'Describe a situation where your team''s priorities directly conflicted with another team''s. How did you navigate the tension?',
 'conflict', 'medium',
 ARRAY['Name the specific competing priorities and why they clashed','Show you understood the other team''s perspective and constraints','Explain how you found common ground or escalated appropriately','Quantify the outcome for both teams'],
 'Situation — Our payments team needed a breaking API change that would block the checkout team''s launch. Task — Find a path that didn''t delay either team''s quarterly goals. Action — Proposed a versioned API with backward compatibility, facilitated a joint planning session. Result — Both teams hit their deadlines, and the versioned API pattern became our standard.'),

('conflict-manager-disagreement',
 'Disagreeing With Your Manager',
 'Tell me about a time you strongly disagreed with your manager''s decision. What did you do?',
 'conflict', 'hard',
 ARRAY['Show you can push back respectfully with data, not just opinions','Include how you presented your case privately first','Demonstrate you can commit to a decision even if you disagreed','Reflect on whether you were right or what you learned'],
 'Situation — Manager wanted to skip load testing to hit a launch date. Task — Convince them the risk was too high without undermining their authority. Action — Built a 30-minute proof showing our API would fail at 2x expected traffic, presented privately with a compressed testing plan. Result — We delayed by 3 days, caught a critical connection pool bug, launched without incident.'),

('conflict-stakeholder-pushback',
 'Stakeholder Pushback on Requirements',
 'Give me an example of a time a stakeholder insisted on a feature you believed was technically wrong or harmful to users. How did you handle it?',
 'conflict', 'medium',
 ARRAY['Clarify the stakeholder''s underlying goal vs. their requested solution','Show you proposed alternatives rather than just saying no','Demonstrate empathy for business pressure while advocating for users','Include the resolution and what you would do differently'],
 'Situation — Product manager insisted on auto-playing video ads that would increase page load by 4 seconds. Task — Protect user experience while respecting revenue goals. Action — Built a prototype showing lazy-loaded ads that preserved performance, presented A/B data from similar implementations. Result — Revenue increased 12% with the lazy approach vs. projected 8% with auto-play.'),

('conflict-code-review-tension',
 'Heated Code Review',
 'Tell me about a code review that became contentious. How did you de-escalate while still maintaining code quality?',
 'conflict', 'easy',
 ARRAY['Describe the specific code quality concern, not a style preference','Show you separated objective issues from subjective preferences','Explain how you moved from async comments to synchronous conversation','End with the team norm or process improvement that resulted'],
 'Situation — A PR review devolved into 40+ comments arguing about error handling patterns. Task — Resolve the review without burning the relationship or merging bad code. Action — Jumped on a 15-min call, agreed on which comments were blocking vs. nits, created a shared error handling guide. Result — PR merged same day, team adopted the guide, review times dropped 30%.'),

('conflict-remote-miscommunication',
 'Remote Team Miscommunication',
 'Describe a conflict that arose specifically because your team was remote or distributed across time zones. How did you resolve it?',
 'conflict', 'medium',
 ARRAY['Name the specific miscommunication and why remote work caused it','Show awareness of how async communication amplifies misunderstandings','Explain the process change you implemented to prevent recurrence','Include how you rebuilt trust after the miscommunication'],
 'Situation — A teammate in a different timezone interpreted my Slack message as critical of their work, leading to a week of tense interactions. Task — Repair the relationship and prevent future tone misreadings. Action — Scheduled a video call to clarify intent, established a team norm of using emoji reactions and explicit framing for feedback. Result — Relationship recovered, team adopted a "assume positive intent" async communication guide.'),

('conflict-deadline-quality',
 'Deadline vs Quality Standoff',
 'Tell me about a time you had to choose between shipping on time and shipping with quality. What was the conflict and how did you resolve it?',
 'conflict', 'easy',
 ARRAY['Be specific about what quality meant in this context','Show your decision-making framework for the tradeoff','Include who you involved in the decision and how you communicated it','Explain what you shipped, what you deferred, and the actual impact'],
 'Situation — Two days before launch, QA found 15 bugs, 3 of which were edge cases affecting 2% of users. Task — Decide what to fix vs. defer without missing the launch window. Action — Categorized bugs by user impact, fixed the 3 data-loss risks, documented the cosmetic issues with a 1-week follow-up plan. Result — Launched on time, zero customer complaints, fixed remaining bugs within 5 days.'),

('conflict-inherited-codebase',
 'Inherited Codebase Conflict',
 'Describe a time you joined a team and disagreed with fundamental architecture decisions made before you arrived. How did you approach it?',
 'conflict', 'hard',
 ARRAY['Show respect for the original context and constraints','Explain how you gathered evidence before proposing changes','Demonstrate patience — you can''t rewrite everything on day one','Include what you changed, what you accepted, and why'],
 'Situation — Joined a team using a hand-rolled ORM that caused weekly production issues. Task — Advocate for migration without alienating the original author who was still on the team. Action — Tracked incident hours for 2 months, presented data showing 40% of on-call pages traced to the ORM, proposed incremental migration starting with the most painful module. Result — Team agreed, migrated over 6 months, on-call pages dropped 60%.'),

('conflict-customer-escalation',
 'Customer Escalation Conflict',
 'Tell me about a time an angry customer or client created tension between you and another team. How did you handle the internal conflict while resolving the customer''s issue?',
 'conflict', 'medium',
 ARRAY['Show you focused on the customer outcome first, blame later','Explain how you coordinated across teams under pressure','Demonstrate you didn''t throw colleagues under the bus externally','Include the systemic fix, not just the immediate resolution'],
 'Situation — Enterprise client threatened to churn after a data export bug; sales blamed engineering, engineering blamed unclear requirements. Task — Fix the bug, save the client, and stop the blame cycle. Action — Owned the customer call personally, shipped a fix in 48 hours, then facilitated a blameless post-mortem with both teams. Result — Client renewed, we created a shared requirements checklist for enterprise features.'),

('conflict-promotion-disagreement',
 'Promotion Decision Pushback',
 'Describe a time you disagreed with a promotion or performance decision affecting you or someone on your team. How did you handle it constructively?',
 'conflict', 'hard',
 ARRAY['Show emotional maturity — this tests how you handle professional disappointment','Be specific about why you disagreed and what evidence you had','Demonstrate you used proper channels rather than politicking','Include what changed as a result, even if the decision stood'],
 'Situation — A direct report was denied promotion despite exceeding every stated criterion. Task — Advocate for them without undermining the review committee. Action — Requested a 1:1 with my skip-level, presented a detailed evidence doc mapping their work to the promotion criteria, asked for specific gaps. Result — Committee identified unclear criteria as the issue, revised the rubric, report was promoted next cycle.');


-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 2: LEADERSHIP (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('leadership-influence-without-authority',
 'Influence Without Authority',
 'Describe a situation where you had to get engineers on another team to prioritize your project when you had no leverage over them.',
 'leadership', 'hard',
 ARRAY['Show how you understood their team''s priorities and constraints first','Explain the specific mechanism you used: data, demos, relationships, or framing','Demonstrate persistence without being pushy','Include the outcome and timeline'],
 'Situation — Needed the platform team to build an API endpoint for our feature, but we weren''t on their roadmap. Task — Get their buy-in without management escalation. Action — Built a prototype showing how the endpoint would reduce their support tickets by 30%, presented it at their team standup. Result — They prioritized it within 2 weeks, and the endpoint became one of their most-used APIs.'),

('leadership-rallying-demoralized-team',
 'Rallying a Demoralized Team',
 'Tell me about a time your team was demoralized or burnt out. What did you do to turn things around?',
 'leadership', 'medium',
 ARRAY['Be specific about what caused the low morale','Show you listened before acting — don''t assume you know the problem','Explain concrete actions, not just motivational speeches','Include measurable indicators that morale improved'],
 'Situation — After 3 failed launches in a row, team velocity dropped 40% and two engineers started interviewing elsewhere. Task — Restore confidence and retain talent. Action — Ran anonymous retro, identified scope creep as root cause, negotiated 2-week cooldown sprint focused on tech debt wins, celebrated small shipped items daily. Result — Velocity recovered within a month, both engineers stayed, next launch succeeded.'),

('leadership-technical-direction',
 'Setting Technical Direction',
 'Tell me about a time you drove a significant technical decision that affected multiple teams. How did you build consensus?',
 'leadership', 'hard',
 ARRAY['Show you did thorough research before proposing your direction','Explain how you incorporated feedback from skeptics','Demonstrate you created a written proposal, not just hallway conversations','Include the long-term impact of the decision'],
 'Situation — Three teams were building separate caching layers, causing inconsistency bugs and wasted effort. Task — Propose and drive adoption of a shared caching service. Action — Wrote an RFC with benchmarks, held office hours for concerns, built a migration guide, offered to pair with each team on their first integration. Result — All three teams migrated within a quarter, cache-related bugs dropped 85%.'),

('leadership-mentoring-struggling',
 'Mentoring a Struggling Engineer',
 'Describe a time you helped a struggling team member improve their performance without formal authority over them.',
 'leadership', 'easy',
 ARRAY['Show empathy — explain why they were struggling, not just that they were','Describe your specific mentoring approach and how you adapted it','Demonstrate patience and the timeline of improvement','Include their growth and how it affected the team'],
 'Situation — A mid-level engineer was consistently missing sprint commitments and getting defensive in code reviews. Task — Help them improve without being their manager. Action — Offered weekly 1:1 pairing sessions, focused on breaking large tasks into smaller PRs, gave positive feedback publicly on improvements. Result — Within 2 months, they were completing sprints consistently and volunteering to review others'' code.'),

('leadership-driving-decisions',
 'Breaking a Decision Deadlock',
 'Tell me about a time your team was stuck in analysis paralysis. How did you drive the group to a decision?',
 'leadership', 'medium',
 ARRAY['Describe why the team was stuck — what made the decision hard','Show how you structured the decision-making process','Explain the framework you used to evaluate options','Include how you got buy-in from dissenters'],
 'Situation — Team spent 3 weeks debating between 4 different state management solutions with no resolution. Task — Break the deadlock without being authoritarian. Action — Created a weighted decision matrix with the team, defined evaluation criteria together, timeboxed a 2-day spike on the top 2 options. Result — Clear winner emerged from the data, team committed unanimously, shipped the feature on schedule.'),

('leadership-onboarding-ownership',
 'Owning Onboarding',
 'Describe a time you took ownership of improving the onboarding experience for new team members without being asked.',
 'leadership', 'easy',
 ARRAY['Show you identified the gap through observation or personal experience','Explain what specific improvements you made and why','Demonstrate follow-through, not just a one-time effort','Include feedback from new hires and time-to-productivity metrics'],
 'Situation — New engineers took 4-6 weeks to ship their first PR, and 3 recent hires mentioned feeling lost in their first month. Task — Reduce ramp-up time without being officially responsible for onboarding. Action — Created a week-by-week onboarding checklist, set up a buddy system, wrote "first PR" tutorials for our top 5 services. Result — Next 4 hires shipped within 2 weeks, satisfaction scores went from 3/5 to 4.5/5.'),

('leadership-cross-functional',
 'Leading Cross-Functional Initiative',
 'Tell me about a time you led a project that required coordination between engineering, design, and product. How did you align everyone?',
 'leadership', 'medium',
 ARRAY['Show how you created shared understanding across disciplines','Explain how you handled conflicting priorities between functions','Demonstrate your communication cadence and tools','Include the project outcome and what you''d do differently'],
 'Situation — Redesigning the checkout flow required syncing 3 engineers, 2 designers, and a PM with different definitions of done. Task — Ship a cohesive experience on a 6-week timeline. Action — Set up a shared Figma board with eng annotations, weekly 30-min syncs with rotating demo leads, created a single source of truth doc. Result — Shipped in 5 weeks, conversion rate improved 18%.'),

('leadership-saying-no',
 'Saying No to Leadership',
 'Describe a time you had to push back on a request from senior leadership because you believed it was the wrong approach.',
 'leadership', 'hard',
 ARRAY['Show you understood the business objective behind the request','Explain how you presented data, not just opinions','Demonstrate courage — this tests if you''ll speak up when it matters','Include the outcome regardless of whether you won or lost'],
 'Situation — VP wanted to ship a major feature behind a feature flag to 100% of users simultaneously to meet a board deadline. Task — Advocate for a gradual rollout without appearing to block business goals. Action — Presented incident data from our last big-bang rollout, proposed a 1%→10%→50%→100% schedule that still met the board date. Result — VP agreed, we caught a critical bug at 10% that would have affected all users.'),

('leadership-culture-change',
 'Driving Culture Change',
 'Tell me about a time you identified a toxic or unproductive team norm and worked to change it.',
 'leadership', 'hard',
 ARRAY['Be specific about the norm and its negative effects','Show you addressed it systematically, not by calling people out','Demonstrate how you modeled the new behavior yourself','Include evidence that the culture actually shifted'],
 'Situation — Team had a culture of "hero engineering" where people worked weekends to fix preventable issues, and this was celebrated. Task — Shift toward sustainable practices without demoralizing the heroes. Action — Started tracking preventable incidents, celebrated prevention in retros instead of firefighting, introduced on-call rotation with explicit rest policies. Result — Weekend work dropped 70%, preventable incidents dropped 50%, team satisfaction improved in the next engagement survey.'),

('leadership-delegation',
 'Learning to Delegate',
 'Describe a situation where you had to delegate a critical task to someone less experienced than you. How did you ensure success without micromanaging?',
 'leadership', 'easy',
 ARRAY['Show why delegation was necessary, not just a nice-to-have','Explain how you set them up for success: context, guardrails, checkpoints','Demonstrate trust while maintaining accountability','Include what they delivered and what you learned about delegation'],
 'Situation — I was the only one who knew our deployment pipeline, and I was going on vacation during a critical release window. Task — Prepare a junior engineer to handle the release independently. Action — Wrote a runbook, did two practice deployments together, established a Slack escalation path, and gave them explicit decision-making authority. Result — They executed the release flawlessly, found and fixed an issue I hadn''t documented, and became our second deployment expert.');


-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 3: FAILURE (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('failure-production-incident',
 'Production Incident You Caused',
 'Tell me about a production incident you caused. Walk me through exactly what happened, your role in it, and what you changed afterward.',
 'failure', 'hard',
 ARRAY['Own it completely — interviewers respect accountability over deflection','Walk through the timeline: what happened, when you knew, what you did','Explain the root cause, not just the symptoms','Show the systemic change you made to prevent recurrence'],
 'Situation — Deployed a migration that locked a critical database table for 12 minutes during peak traffic, causing 500 errors for 8,000 users. Task — Resolve immediately and ensure it never happened again. Action — Rolled back within 3 minutes of detection, wrote a detailed post-mortem, implemented mandatory migration dry-runs on staging with production-like data volumes. Result — Zero migration incidents in the 18 months since, process adopted company-wide.'),

('failure-missed-deadline',
 'Missed a Critical Deadline',
 'Tell me about a time you missed an important deadline. What went wrong and what did you learn?',
 'failure', 'medium',
 ARRAY['Be honest about your role in the miss — don''t blame external factors only','Explain the early warning signs you missed or ignored','Show how you communicated the delay to stakeholders','Include what you changed about your estimation or planning process'],
 'Situation — Committed to delivering a payment integration in 4 weeks but it took 7 due to undocumented API edge cases. Task — Manage the delay while maintaining stakeholder trust. Action — Flagged the slip at week 3 with a revised timeline and weekly progress updates, added buffer to all future estimates involving third-party APIs. Result — Stakeholders appreciated the transparency, and my subsequent estimates were within 10% accuracy.'),

('failure-wrong-technology',
 'Chose the Wrong Technology',
 'Describe a time you championed a technology choice that turned out to be wrong. How did you course-correct?',
 'failure', 'hard',
 ARRAY['Show you had a reasonable rationale for the original choice','Explain how you recognized the mistake — what signals did you see','Demonstrate willingness to reverse your own decision publicly','Include the cost of the mistake and what you''d evaluate differently'],
 'Situation — Advocated for GraphQL for our internal admin tool; 3 months in, the team was spending 40% of time on resolver complexity for simple CRUD operations. Task — Admit the mistake and propose a path forward. Action — Presented a cost analysis showing REST would have been 3x faster to develop, proposed migrating the worst endpoints first, offered to do the migration work myself. Result — Migrated critical paths in 2 weeks, team velocity doubled, I now use a decision framework that weighs team familiarity alongside technical merit.'),

('failure-hiring-mistake',
 'Hiring Mistake',
 'Tell me about a time you were involved in hiring someone who turned out to be a poor fit. What did you learn about your evaluation process?',
 'failure', 'hard',
 ARRAY['Be thoughtful about privacy — focus on what you missed, not the person''s failures','Show what signals you ignored or didn''t test for','Explain what you changed in your interview process afterward','Demonstrate empathy for the person while being honest about the impact'],
 'Situation — Hired a senior engineer who aced system design interviews but struggled with collaboration and code review etiquette. Task — Address the fit issue and improve our hiring process. Action — Worked with the engineer on a performance plan, added a collaborative coding exercise and team-fit panel to our interview loop. Result — The engineer chose to leave for a role better suited to solo work, and our subsequent hires had much better team integration.'),

('failure-scope-creep',
 'Let Scope Creep Kill a Project',
 'Describe a project that failed or was significantly delayed because of scope creep you didn''t control. What was your role in letting it happen?',
 'failure', 'medium',
 ARRAY['Own your part — even if others added scope, you could have pushed back','Show the specific moments where scope expanded and why you didn''t stop it','Explain the impact: delayed timeline, team burnout, or failed launch','Include the process change you implemented to manage scope going forward'],
 'Situation — A "2-week feature" turned into a 3-month project because we kept saying yes to stakeholder requests without evaluating impact. Task — Recognize my role as tech lead in not setting boundaries. Action — After the project finally shipped, I introduced a change request process requiring effort estimates and explicit trade-off decisions for any scope addition. Result — Next project shipped on time, and the team had a clear vocabulary for "that''s a scope change, let''s evaluate it."'),

('failure-communication-breakdown',
 'Failed to Communicate a Risk',
 'Tell me about a time you knew something was going wrong on a project but didn''t raise the alarm early enough. What happened?',
 'failure', 'medium',
 ARRAY['Explain why you hesitated — was it optimism bias, fear, or unclear escalation paths','Be specific about when you knew vs. when you spoke up','Show the consequences of the delay','Include what you changed about how you communicate risks now'],
 'Situation — Noticed our API response times degrading for 2 weeks but assumed it was temporary and didn''t escalate. Task — Should have flagged it when I first noticed the trend. Action — When it finally caused a customer-facing outage, I owned the delay in my post-mortem, implemented automated performance regression alerts with Slack notifications. Result — Never missed another gradual degradation, and I now follow a "if you notice it twice, escalate it" personal rule.'),

('failure-over-engineering',
 'Over-Engineered a Solution',
 'Give me an example of a time you over-engineered something. How did you realize it, and what did you do?',
 'failure', 'easy',
 ARRAY['Show self-awareness about your tendency to over-engineer','Explain what triggered the realization — feedback, metrics, or time pressure','Demonstrate you can simplify without ego','Include how you balance quality with pragmatism now'],
 'Situation — Built a microservice architecture for an internal tool that had 5 users and would never scale beyond 50. Task — Deliver a simple CRUD app; instead I delivered a distributed system. Action — After a teammate pointed out the 3-week delay, I consolidated into a single service in 2 days, deleted 4,000 lines of unnecessary infrastructure code. Result — Tool shipped that week, and I now ask "what''s the simplest thing that could work?" before designing.'),

('failure-ignored-feedback',
 'Ignored Important Feedback',
 'Tell me about a time you dismissed feedback that turned out to be correct. What happened and how did it change your approach?',
 'failure', 'medium',
 ARRAY['Show humility — this tests whether you can admit you were wrong','Be specific about the feedback and who gave it','Explain why you dismissed it at the time','Include how you actively seek feedback differently now'],
 'Situation — A junior engineer suggested we add rate limiting before launching a public API; I dismissed it as premature optimization. Task — Two weeks after launch, a bot scraped our API and caused a $2,000 cloud bill spike. Action — Implemented rate limiting immediately, apologized to the engineer publicly in retro, established a "security review" checklist for any public-facing endpoint. Result — No recurrence, and I now actively solicit input from junior team members during design reviews.'),

('failure-burned-out',
 'Burned Out and It Affected Work',
 'Describe a time when burnout or stress significantly affected your work quality. How did you recognize it and what did you do?',
 'failure', 'easy',
 ARRAY['Be honest but professional — show self-awareness, not a therapy session','Explain the specific impact on your work: missed details, short temper, errors','Show you took concrete action rather than just pushing through','Include what sustainable practices you''ve adopted since'],
 'Situation — After 3 months of on-call every other week plus a major migration, I started making careless code review mistakes and snapping at teammates. Task — Recognize I was the problem, not the workload. Action — Talked to my manager, took a week of PTO, proposed splitting on-call across more engineers, started blocking focus time on my calendar. Result — Work quality recovered, on-call rotation expanded to 5 people, I now track my energy levels and proactively flag when I''m approaching burnout.'),

('failure-lost-trust',
 'Lost a Stakeholder''s Trust',
 'Tell me about a time you lost the trust of a key stakeholder or customer. How did you rebuild it?',
 'failure', 'hard',
 ARRAY['Be specific about what you did or failed to do that broke trust','Show the immediate impact of the trust loss','Explain your systematic approach to rebuilding — not just an apology','Include how long it took and what the relationship looks like now'],
 'Situation — Promised a VP that a data pipeline would be ready for board reporting; it wasn''t, and they presented incomplete data to the board. Task — Rebuild trust after a very public failure. Action — Delivered a written plan with weekly checkpoints, over-communicated progress for the next quarter, delivered the next 3 commitments early. Result — Trust was fully restored within 2 months, VP later cited our team as the most reliable in their org.');
