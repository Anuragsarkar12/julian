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

-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 4: ACHIEVEMENT (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('achievement-complex-ship',
 'Most Complex Ship',
 'What is the most technically complex thing you have shipped? What made it hard, and what was the measurable outcome?',
 'achievement', 'hard',
 ARRAY['Lead with what made it genuinely hard — not just that it was a lot of work','Explain technical decisions you made and tradeoffs you navigated','Quantify the outcome: users, revenue, performance improvement, time saved','Show your specific contribution if it was a team effort'],
 'Situation — Built a real-time collaborative editing system handling 50 concurrent users per document. Task — Deliver conflict-free editing with sub-100ms latency. Action — Implemented CRDTs for conflict resolution, WebSocket connection pooling, and an operational transform fallback. Result — Shipped to 10,000 users, 99.9% uptime, featured in the company''s annual report as a key product differentiator.'),

('achievement-performance-optimization',
 'Performance Breakthrough',
 'Tell me about a time you dramatically improved the performance of a system. What was the bottleneck and how did you find it?',
 'achievement', 'medium',
 ARRAY['Walk through your debugging methodology — how did you identify the bottleneck','Be specific about the metrics: before vs. after','Explain why the obvious solutions didn''t work','Show the business impact of the performance gain'],
 'Situation — Our search API had p99 latency of 4.2 seconds, causing 15% of users to abandon searches. Task — Reduce latency to under 500ms. Action — Profiled the query path, discovered N+1 queries in the ranking layer, implemented batch fetching and added a Redis cache for frequent queries. Result — p99 dropped to 280ms, search abandonment fell to 3%, drove an estimated $400K annual revenue increase.'),

('achievement-zero-to-one',
 'Built Something From Zero',
 'Describe a product or system you built from scratch. How did you make architectural decisions with no existing codebase to guide you?',
 'achievement', 'hard',
 ARRAY['Explain your decision-making framework for technology choices','Show how you balanced speed with long-term maintainability','Include what you got right and what you''d change in hindsight','Quantify adoption or impact'],
 'Situation — Company needed an internal feature flagging system; existing solutions were too expensive for our scale. Task — Design and build a system that could handle 10M flag evaluations per day. Action — Chose a simple architecture: PostgreSQL for flag config, edge-cached evaluation via CDN, SDK for 3 languages. Result — Shipped in 6 weeks, adopted by all 12 teams, saved $180K/year vs. vendor solutions.'),

('achievement-exceeded-expectations',
 'Exceeded Expectations',
 'Tell me about a project where you delivered significantly more than what was asked for. What drove you to go beyond the requirements?',
 'achievement', 'easy',
 ARRAY['Show genuine passion, not just working extra hours','Explain what you added and why it mattered to users','Be honest about whether the extra work was valued by your team and manager','Include metrics or feedback that validated the extra effort'],
 'Situation — Asked to build a CSV export feature for analytics data. Task — Ship a simple download button. Action — Noticed users were exporting to manipulate data in spreadsheets, so I built interactive filters, saved views, and scheduled email reports in addition to CSV export. Result — Feature adoption was 3x the projected usage, PM featured it in the quarterly product review.'),

('achievement-automation-impact',
 'Automation That Changed Everything',
 'Describe something you automated that had a significant impact on your team''s productivity. How did you identify the opportunity?',
 'achievement', 'easy',
 ARRAY['Explain how you noticed the repetitive work — observation, complaints, or data','Show the before/after in concrete time savings','Include any resistance to the automation and how you handled it','Quantify the ROI: hours saved × number of people × frequency'],
 'Situation — Engineers spent 2 hours every release manually updating 15 config files across 3 environments. Task — Automate the release configuration process. Action — Built a CLI tool that generated configs from a single source of truth, added validation and dry-run mode, integrated with CI/CD. Result — Release config time dropped from 2 hours to 3 minutes, eliminated 100% of config-related deployment bugs.'),

('achievement-under-pressure',
 'Delivered Under Extreme Pressure',
 'Tell me about a time you had to deliver a critical project under extreme time pressure. How did you manage quality while moving fast?',
 'achievement', 'medium',
 ARRAY['Explain what created the pressure — business context matters','Show how you triaged what to build vs. what to skip','Demonstrate you maintained engineering standards despite the rush','Include the outcome and any follow-up work needed'],
 'Situation — A competitor launched a feature our biggest client demanded we match within 2 weeks or they''d switch. Task — Build a functional equivalent in 10 business days. Action — Identified the 3 core use cases covering 90% of the client''s needs, built those with full test coverage, deferred the remaining 7 use cases to phase 2. Result — Client stayed, feature launched in 9 days, phase 2 shipped 3 weeks later.'),

('achievement-data-driven-decision',
 'Data-Driven Impact',
 'Give me an example of a time you used data to drive a product or engineering decision that had significant impact.',
 'achievement', 'medium',
 ARRAY['Explain what data you gathered and how you gathered it','Show how the data contradicted assumptions or conventional wisdom','Include the decision you made based on the data','Quantify the outcome'],
 'Situation — Team assumed mobile users wanted a simplified dashboard; engagement data showed mobile users used the same features as desktop. Task — Challenge the assumption before building a stripped-down mobile experience. Action — Analyzed 3 months of feature usage by device, ran a survey of 200 mobile users, presented findings showing mobile users wanted parity, not simplification. Result — Built responsive parity instead, mobile engagement increased 45%.'),

('achievement-mentorship-impact',
 'Impact Through Mentorship',
 'Tell me about someone you mentored whose growth you''re most proud of. What was your approach?',
 'achievement', 'easy',
 ARRAY['Focus on their growth, not your teaching ability','Be specific about what they struggled with and how you helped','Show your mentoring method: pairing, feedback cadence, goal-setting','Include where they are now and how mentoring changed your own approach'],
 'Situation — An intern with strong CS fundamentals but zero industry experience needed to ship a production feature in 12 weeks. Task — Guide them from academic code to production-quality engineering. Action — Set weekly milestones, paired on code reviews with explanations of "why not just what," introduced them to debugging production systems with real incidents. Result — They shipped the feature in week 10, received a return offer, and are now a mid-level engineer at the company.'),

('achievement-cost-reduction',
 'Significant Cost Reduction',
 'Describe a time you significantly reduced infrastructure or operational costs. How did you identify the opportunity and what was the impact?',
 'achievement', 'medium',
 ARRAY['Show your process for finding cost inefficiencies','Explain the technical changes you made and why they worked','Include the before/after cost numbers','Demonstrate you maintained performance while reducing costs'],
 'Situation — Our AWS bill had grown to $45K/month, up 200% in 6 months with only 50% user growth. Task — Identify and eliminate waste without degrading performance. Action — Audited every service: right-sized EC2 instances, added auto-scaling, moved cold data to S3 Glacier, optimized Lambda concurrency. Result — Monthly bill dropped to $22K, a 51% reduction, while handling 30% more traffic than before.'),

('achievement-customer-impact',
 'Direct Customer Impact',
 'Tell me about a feature or fix you shipped that had the most direct positive impact on end users. How do you know it mattered?',
 'achievement', 'easy',
 ARRAY['Ground this in real user feedback, not just metrics','Explain how you understood the user pain point','Show the before/after user experience','Include unsolicited feedback or support ticket reduction as evidence'],
 'Situation — Users were abandoning our onboarding flow at a 68% rate, with support tickets saying "I don''t know what to do next." Task — Reduce abandonment and confusion. Action — Added a step-by-step progress indicator, contextual tooltips, and a 30-second video for each step based on the most common support questions. Result — Abandonment dropped to 23%, support tickets for onboarding decreased 80%, NPS for new users jumped from 32 to 67.');


-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 5: TEAMWORK (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('teamwork-opposite-working-style',
 'Opposite Working Style',
 'Tell me about a time you had to work closely with someone whose working style was completely opposite to yours. How did you make it work?',
 'teamwork', 'medium',
 ARRAY['Be specific about the style difference — don''t just say "they were difficult"','Show you adapted your approach rather than expecting them to change','Explain the specific compromises or accommodations you made','Include what you learned about your own working style'],
 'Situation — Paired with an engineer who needed to discuss every decision verbally while I preferred async communication and written docs. Task — Deliver a feature together without friction. Action — Proposed a hybrid approach: 30-min daily sync for decisions, followed by written summaries I could reference, async Slack for non-blocking questions. Result — Feature shipped on time, we both rated the collaboration highly, and I realized I was missing context by being too async-heavy.'),

('teamwork-new-team-integration',
 'Integrating Into a New Team',
 'Describe how you integrated into a new team. What did you do in your first 30 days to build trust and contribute meaningfully?',
 'teamwork', 'easy',
 ARRAY['Show a deliberate first-30-days strategy, not just "I jumped in"','Explain how you balanced learning with contributing','Include how you built relationships, not just shipped code','Mention what surprised you and how you adapted'],
 'Situation — Joined a team with 4 engineers who had worked together for 2 years and had strong established norms. Task — Become a trusted contributor without disrupting existing dynamics. Action — Spent week 1 reading every doc and sitting in on all meetings quietly, week 2 took on small bugs to learn the codebase, week 3 proposed one small process improvement, week 4 shipped a medium feature. Result — Tech lead told me in my 1-month check-in that I''d integrated faster than any previous hire.'),

('teamwork-cross-functional-conflict',
 'Design vs Engineering Tradeoff',
 'Tell me about a time you disagreed with a designer about implementation feasibility. How did you find a solution that satisfied both engineering constraints and design vision?',
 'teamwork', 'medium',
 ARRAY['Show respect for the design perspective — don''t frame it as "design was wrong"','Explain the specific technical constraint and why it mattered','Demonstrate creative problem-solving to find a middle ground','Include the final solution and user feedback'],
 'Situation — Designer wanted a complex animated transition that would require 2 weeks to build and cause performance issues on low-end devices. Task — Deliver the user experience without the performance cost. Action — Prototyped a simplified animation that captured 80% of the visual effect with CSS-only transitions, showed it to the designer with performance data from real devices. Result — Designer loved the prototype, shipped in 2 days, users couldn''t tell the difference in A/B testing.'),

('teamwork-carried-more-load',
 'Carrying Extra Load',
 'Describe a time you had to pick up significantly more work because a teammate was struggling or unavailable. How did you handle it without resentment?',
 'teamwork', 'easy',
 ARRAY['Show you stepped up willingly, not grudgingly','Explain how you balanced the extra load with your own commitments','Demonstrate you communicated the situation to your manager','Include whether this revealed a systemic issue and how you addressed it'],
 'Situation — A teammate went on unexpected medical leave mid-sprint, leaving their 3 critical path tickets unassigned. Task — Absorb the work without missing the sprint goal. Action — Triaged their tickets, identified the one true blocker, negotiated with PM to move the other 2 to next sprint, worked focused overtime for 3 days on the blocker. Result — Sprint goal met, teammate returned to a clean backlog, I proposed a "bus factor" audit to reduce single-point-of-failure risks.'),

('teamwork-remote-collaboration',
 'Effective Remote Collaboration',
 'Give me an example of a complex project you delivered with a fully remote or distributed team. What practices made it successful?',
 'teamwork', 'medium',
 ARRAY['Be specific about the collaboration challenges unique to remote work','Show the rituals and tools you established','Explain how you maintained team cohesion and trust','Include what you''d do differently next time'],
 'Situation — Led a 4-person project across 3 timezones (PST, EST, IST) with only 2 hours of daily overlap. Task — Ship a payment integration in 6 weeks without synchronous collaboration. Action — Implemented "relay-style" development with detailed handoff docs, recorded daily Loom updates, used pair programming during overlap hours for complex decisions. Result — Shipped in 5.5 weeks, zero rework due to miscommunication, team rated collaboration 4.7/5.'),

('teamwork-gave-credit',
 'Giving Credit Where Due',
 'Tell me about a time you ensured a teammate received recognition for work that you could have easily taken credit for.',
 'teamwork', 'easy',
 ARRAY['Be genuine — don''t use this as a humble-brag about your own generosity','Explain what the teammate did and why it deserved recognition','Show how you actively ensured they got credit, not just didn''t take it','Include the impact on the teammate and your relationship'],
 'Situation — A junior engineer solved a critical production issue over the weekend using a debugging technique I''d shown them. Task — Ensure the team knew it was their win, not mine. Action — In Monday''s standup, I explicitly named them as the hero, asked them to present the fix in our tech talk series, and included their contribution in my report to leadership. Result — They gained visibility with engineering leadership, were asked to join the incident response team, and their confidence visibly grew.'),

('teamwork-difficult-teammate',
 'Working With a Difficult Personality',
 'Describe a time you had to work productively with someone the rest of the team found difficult to collaborate with.',
 'teamwork', 'hard',
 ARRAY['Don''t badmouth the person — describe specific behaviors, not character','Show empathy for why they might be difficult','Explain your specific strategy for working with them effectively','Include whether the dynamic improved and what you learned'],
 'Situation — An architect on our project was brilliant but dismissive in meetings, interrupting others and rejecting ideas without explanation. Task — Deliver with them as a key collaborator without the team shutting down. Action — Started sending proposals in writing before meetings so they could process async, asked targeted questions that channeled their expertise constructively, gave private feedback about the interrupting pattern. Result — Meeting participation from others increased, architect started acknowledging others'' contributions, project shipped successfully.'),

('teamwork-knowledge-sharing',
 'Building Knowledge Sharing Culture',
 'Tell me about a time you improved how your team shared knowledge. What problem did you solve and how?',
 'teamwork', 'easy',
 ARRAY['Identify the specific knowledge gap or silo you addressed','Show the system you built, not just a one-time presentation','Include adoption metrics and team feedback','Explain how you sustained it beyond the initial enthusiasm'],
 'Situation — Only 2 of 8 engineers could deploy our main service; when both were out, deployments stopped. Task — Eliminate knowledge silos for critical processes. Action — Instituted weekly "knowledge transfer" sessions where silo owners taught their specialty, created runbooks for all critical processes, added a rotation where everyone did each critical task at least once per quarter. Result — All 8 engineers could deploy within 2 months, unplanned downtime from "nobody knows how" incidents dropped to zero.'),

('teamwork-pair-programming',
 'Pair Programming Breakthrough',
 'Describe a time when pair programming or close collaboration with a colleague led to a significantly better solution than either of you would have built alone.',
 'teamwork', 'medium',
 ARRAY['Explain what each person brought to the pairing','Show how the collaboration process worked in practice','Demonstrate the solution was genuinely better, not just faster','Include what you learned about effective pairing'],
 'Situation — Tasked with designing an event sourcing system; I had domain expertise but limited distributed systems experience, my pair partner had the opposite. Task — Design a system that was both domain-correct and technically sound. Action — Spent 3 days in a conference room whiteboarding, alternating between domain modeling and technical architecture, challenging each other''s assumptions. Result — The design avoided 2 critical pitfalls each of us would have hit alone, shipped with zero domain logic bugs and handled 10x expected load.'),

('teamwork-conflict-mediation',
 'Mediating Team Conflict',
 'Tell me about a time two teammates were in conflict and it was affecting the team''s output. What did you do?',
 'teamwork', 'hard',
 ARRAY['Show you intervened because it was affecting the team, not just to be a hero','Explain how you understood both perspectives before acting','Demonstrate you facilitated resolution without taking sides','Include the outcome for the team dynamic, not just the individuals'],
 'Situation — Two senior engineers stopped reviewing each other''s PRs after a heated architecture disagreement, creating a review bottleneck. Task — Resolve the interpersonal issue that was blocking the team. Action — Had 1:1 conversations with each to understand their perspective, identified the root issue was a values conflict (performance vs. readability), facilitated a team discussion to create explicit code quality guidelines. Result — Both engineers agreed on the guidelines, resumed reviewing each other''s code, PR cycle time returned to normal within a week.');


-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORY 6: COMMUNICATION (10 questions)
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('communication-miscommunication-problem',
 'Miscommunication Caused a Problem',
 'Describe a time when a miscommunication between you and a stakeholder caused a real problem. What was your role in the breakdown and how did you fix it?',
 'communication', 'medium',
 ARRAY['Own your part in the miscommunication — don''t just blame the other person','Be specific about what was misunderstood and why','Show how you resolved the immediate problem','Include the process change you made to prevent recurrence'],
 'Situation — I told a PM "the API will be ready by Friday" meaning the backend endpoint; they told the client the full feature including UI would be live. Task — Manage the client expectation gap while shipping as fast as possible. Action — Called the PM immediately, we jointly called the client to set correct expectations, I proposed adding explicit "definition of done" fields to all commitments. Result — Client appreciated the transparency, feature shipped following Tuesday, and we never had another scope-of-ready confusion.'),

('communication-technical-nontechnical',
 'Translating Technical to Non-Technical',
 'Tell me about a time you had to explain a complex technical concept to a non-technical audience. How did you ensure they truly understood?',
 'communication', 'easy',
 ARRAY['Use an analogy they can relate to from their domain','Avoid jargon — if you must use a technical term, define it immediately','Check understanding by asking them to restate in their words','Include feedback you received about your explanation'],
 'Situation — CFO needed to understand why we were requesting $200K for database migration and couldn''t just "copy the data." Task — Explain schema migration complexity in business terms. Action — Used a moving-house analogy: "Imagine moving to a house where every room is a different shape — you can''t just carry furniture over, you need to reshape it to fit." Showed a 3-slide visual of data transformation steps. Result — CFO approved the budget in the same meeting and later used my analogy when explaining it to the board.'),

('communication-written-doc-impact',
 'Written Communication That Drove Action',
 'Give me an example of a technical document you wrote that drove a significant decision or action. What made it effective?',
 'communication', 'medium',
 ARRAY['Explain the audience and what decision they needed to make','Show the structure of the document and why you chose that format','Include how you handled objections or feedback','Demonstrate the outcome: what decision was made and what happened'],
 'Situation — Needed to convince engineering leadership to invest 2 sprints in observability tooling that had no direct product impact. Task — Write a compelling case that would survive scrutiny from 5 engineering directors. Action — Wrote a 3-page RFC structured as: problem (with incident data), proposed solution, alternatives considered, cost/benefit analysis, and rollout plan. Result — Approved unanimously, one director said it was the clearest engineering proposal they''d reviewed.'),

('communication-bad-news-delivery',
 'Delivering Bad News',
 'Tell me about a time you had to deliver bad news to a stakeholder or executive. How did you structure the conversation?',
 'communication', 'hard',
 ARRAY['Show you prepared — come with a plan, not just a problem','Explain your delivery structure: context, news, impact, next steps','Demonstrate empathy for how the news would be received','Include how you managed their reaction'],
 'Situation — Discovered 3 weeks before launch that a key integration partner''s API couldn''t handle our volume, making the launch date impossible. Task — Tell the VP of Product we needed to delay by a month. Action — Prepared a 1-pager with: what we found, why we didn''t catch it sooner, 3 options with tradeoffs, and my recommendation. Delivered it in a 1:1, not a group meeting. Result — VP appreciated the options-based framing, chose the modified timeline, and asked me to present the mitigation plan to the executive team.'),

('communication-presentation-impact',
 'High-Stakes Presentation',
 'Describe the most high-stakes presentation you have given. How did you prepare and what was the outcome?',
 'communication', 'hard',
 ARRAY['Explain the stakes: what depended on this presentation going well','Show your preparation process: content, practice, anticipating questions','Describe how you handled a tough question or unexpected moment','Include the concrete outcome and feedback'],
 'Situation — Presented our team''s architecture proposal to the CTO and 4 VPs, competing against 2 other team proposals for a $500K investment. Task — Win the investment by demonstrating technical rigor and business alignment. Action — Rehearsed 5 times, anticipated 15 likely objections with prepared responses, opened with the business impact rather than technical details, used a live demo instead of slides for the core system. Result — Our proposal was selected, CTO specifically cited the demo and our clear articulation of tradeoffs as differentiators.'),

('communication-feedback-giving',
 'Giving Difficult Feedback',
 'Tell me about a time you had to give someone feedback that was hard to deliver. How did you approach it?',
 'communication', 'medium',
 ARRAY['Show you prepared the feedback with specific examples, not generalizations','Explain your delivery approach: timing, setting, framing','Demonstrate you focused on behavior and impact, not character','Include how the person responded and what changed'],
 'Situation — A peer was consistently taking credit for team ideas in leadership meetings, and others were starting to disengage. Task — Address the behavior directly without damaging our relationship. Action — Asked for a private coffee chat, used specific examples from the last 3 meetings, framed it as "I noticed X, the impact is Y, I think you''d be even more effective if Z." Result — They were genuinely unaware, thanked me, and started explicitly crediting team members in subsequent meetings.'),

('communication-aligning-teams',
 'Aligning Misaligned Teams',
 'Describe a time you discovered two teams were building toward different goals because of unclear communication. How did you fix the alignment?',
 'communication', 'medium',
 ARRAY['Explain how you discovered the misalignment','Show the specific communication gap that caused it','Describe the alignment mechanism you created','Include the outcome and how you prevented future misalignment'],
 'Situation — Frontend and backend teams had different understandings of the API contract, discovered during integration 1 week before launch. Task — Align both teams and prevent a delay. Action — Organized a 2-hour war room, mapped out every API discrepancy, created a shared contract document, assigned owners to each mismatch with a 48-hour deadline. Result — Resolved all 12 discrepancies in 3 days, launched on time, and established API contract reviews as a mandatory milestone.'),

('communication-saying-i-dont-know',
 'Admitting You Don''t Know',
 'Tell me about a time you had to say "I don''t know" in a high-stakes situation. How did you handle it?',
 'communication', 'easy',
 ARRAY['Show that admitting uncertainty was the right call, not a weakness','Explain what you did to find the answer quickly','Demonstrate you followed up with the answer promptly','Include how this affected your credibility (hint: it should have helped)'],
 'Situation — In a client demo, the CTO asked about our system''s disaster recovery time, a metric I hadn''t measured. Task — Respond honestly without losing the client''s confidence. Action — Said "I don''t have that number right now, but I''ll get you the exact RTO and RPO by end of day tomorrow with our test results." Delivered the metrics in 18 hours with a test report. Result — Client said our honesty and follow-through was more impressive than competitors who gave vague reassurances.'),

('communication-async-leadership',
 'Leading Through Writing',
 'Describe how you''ve used written communication to lead a project or initiative where most collaboration was asynchronous.',
 'communication', 'hard',
 ARRAY['Show the specific writing artifacts you created and why','Explain how you ensured people actually read and engaged with your writing','Demonstrate how you handled disagreements in writing vs. calls','Include what makes your written communication effective'],
 'Situation — Led a 6-month platform migration with contributors across 4 timezones and only 1 hour of daily overlap. Task — Keep 12 engineers aligned using primarily written communication. Action — Published weekly progress updates with clear "action needed" callouts, created a decision log where every choice was documented with rationale, used structured RFC templates for major decisions. Result — Migration completed on schedule with zero misalignment incidents, team members cited the decision log as the most useful artifact.'),

('communication-listening-saved-project',
 'Listening That Saved a Project',
 'Tell me about a time when actively listening to someone — rather than speaking — prevented a significant problem or led to a breakthrough.',
 'communication', 'easy',
 ARRAY['Show you were genuinely listening, not just waiting to talk','Explain what you heard that others missed','Describe the specific impact of the insight you gained','Include how this changed your communication approach'],
 'Situation — In a sprint retrospective, a quiet QA engineer mentioned "it feels like we test different things than what users actually do." Task — Dig into this observation that everyone else glossed over. Action — Asked follow-up questions, learned they had data showing 60% of our test cases covered features used by only 5% of users. Spent a day reorganizing test priorities based on actual usage data. Result — Bug escape rate dropped 40% in the next quarter, and I now specifically ask quiet team members for their observations in every retro.');
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
-- CATEGORY 9: INITIATIVE (10 questions)

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('init-nobody-asked',
 'Built Something Nobody Asked For',
 'Tell me about something you built or fixed that nobody asked you to. How did you identify the opportunity, and what was the result?',
 'initiative', 'medium',
 ARRAY['Explain how you spotted the gap — observation, data, or personal frustration','Show you validated the idea before investing heavily','Demonstrate you balanced initiative work with your core responsibilities','Include adoption metrics and stakeholder reaction'],
 'Situation — Noticed engineers spent 20 minutes every morning checking 5 different dashboards for service health. Task — Nobody had asked for a unified view, but the waste was obvious. Action — Built a single-page health dashboard over a weekend hack session, aggregating all 5 sources via their APIs. Result — Adopted by all 15 engineers within a week, saved an estimated 25 engineer-hours per week, became an official team tool.'),

('init-process-improvement',
 'Proactive Process Improvement',
 'Describe a time you identified and fixed a broken process before it caused a major problem.',
 'initiative', 'easy',
 ARRAY['Show how you noticed the process was broken before others did','Explain why you acted instead of waiting for someone else to fix it','Demonstrate you proposed a solution, not just complained','Include the measurable impact of the improvement'],
 'Situation — Our deployment process required 7 manual steps with no checklist, and I noticed near-misses happening weekly. Task — Fix the process before a real incident occurred. Action — Documented the current process, automated 5 of the 7 steps with a CI/CD pipeline, added automated rollback for the remaining 2. Result — Deployment errors dropped from 2-3 per month to zero, deployment time from 45 minutes to 8 minutes.'),

('init-documentation',
 'Documentation Initiative',
 'Tell me about a time you created documentation that significantly improved your team''s effectiveness.',
 'initiative', 'easy',
 ARRAY['Explain what was undocumented and the impact of that gap','Show you structured the documentation for the audience, not yourself','Include how you ensured the docs stayed maintained','Demonstrate measurable impact on onboarding or productivity'],
 'Situation — Our main service had zero documentation; every question required interrupting the original author. Task — Create docs that would eliminate tribal knowledge dependencies. Action — Spent 2 hours daily for 2 weeks writing architecture docs, API references, and a troubleshooting playbook, then set up a quarterly doc review rotation. Result — New hire onboarding time dropped from 4 weeks to 2 weeks, interrupt-driven questions decreased 70%.'),

('init-tech-debt-champion',
 'Championing Tech Debt Reduction',
 'Describe a time you successfully advocated for dedicating time to tech debt when the business was focused on features.',
 'initiative', 'hard',
 ARRAY['Show you quantified the tech debt in business terms, not just engineering frustration','Explain how you made the case to non-technical stakeholders','Demonstrate the plan was incremental, not a full stop on features','Include the outcome: did velocity improve, did incidents decrease'],
 'Situation — Team velocity had dropped 40% over 6 months, but leadership only wanted new features. Task — Convince the VP to allocate 20% of sprint capacity to tech debt. Action — Tracked time spent working around tech debt for 4 weeks, calculated it was consuming 35% of capacity anyway, presented a proposal showing that 3 sprints of focused debt work would recover 25% of lost velocity. Result — VP approved, velocity recovered to 90% of peak within 2 months, incident rate dropped 50%.'),

('init-security-vulnerability',
 'Proactively Found a Security Issue',
 'Tell me about a time you proactively identified a security vulnerability before it was exploited.',
 'initiative', 'hard',
 ARRAY['Explain what made you look for the vulnerability','Show your investigation process','Demonstrate responsible disclosure and remediation','Include the potential impact if it had been exploited'],
 'Situation — While reviewing a colleague''s PR, I noticed they were logging request bodies that could contain API keys from our customers. Task — Determine the scope of the issue and fix it before any data was exposed. Action — Audited all logging across 8 services, found 3 more instances, implemented a log sanitizer that strips sensitive fields, added a CI check to prevent sensitive data in logs. Result — No customer data was exposed, but audit showed 200 API keys had been logged over 6 months; all were rotated within 48 hours.'),

('init-cross-team-tool',
 'Built a Cross-Team Tool',
 'Describe a tool or system you built that was adopted beyond your own team. What drove you to build it?',
 'initiative', 'medium',
 ARRAY['Show the original pain point that motivated you','Explain how you designed it to be useful beyond your team','Demonstrate how you promoted adoption without forcing it','Include adoption numbers and impact across teams'],
 'Situation — Every team wrote their own Slack bot for deployment notifications; there were 6 different bots with different formats and reliability. Task — Build a unified notification system that all teams would want to use. Action — Built a configurable notification service with templates, tested with 2 teams first, incorporated their feedback, then presented at the engineering all-hands. Result — 10 of 12 teams adopted it within a month, 6 bespoke bots were retired, deployment visibility improved across the organization.'),

('init-mentoring-program',
 'Started a Mentoring Program',
 'Tell me about a time you started a mentoring, learning, or growth initiative for your team or organization.',
 'initiative', 'medium',
 ARRAY['Explain the gap you identified in team development','Show how you designed the program to be sustainable','Include participation rates and feedback','Demonstrate impact on individual growth or retention'],
 'Situation — Junior engineers on the team had no structured growth path and were leaving after 12-18 months. Task — Create a development program that would accelerate growth and improve retention. Action — Launched a bi-weekly tech talk series where seniors presented deep dives, paired each junior with a senior mentor, created a skills matrix with quarterly check-ins. Result — Junior engineer retention improved from 60% to 90% over the next year, two juniors were promoted to mid-level within 8 months.'),

('init-testing-culture',
 'Improving Testing Culture',
 'Describe how you improved your team''s testing practices. What was the situation before, and what did you change?',
 'initiative', 'easy',
 ARRAY['Be honest about the starting point — no judgment about the existing culture','Show you led by example, not by mandate','Explain how you made testing easier, not just mandatory','Include metrics: coverage, bug rates, or confidence in deployments'],
 'Situation — Team had 12% test coverage and averaged 3 production bugs per sprint. Task — Improve quality without slowing down feature delivery. Action — Added tests to every PR I submitted as an example, created a testing workshop, set up a coverage dashboard (not a gate), celebrated when coverage milestones were hit. Result — Coverage reached 65% in 4 months, production bugs dropped to 0.5 per sprint, team started writing tests proactively.'),

('init-open-source-contribution',
 'Open Source or Community Contribution',
 'Tell me about a contribution you made to open source, a developer community, or a company-wide initiative that was outside your job description.',
 'initiative', 'medium',
 ARRAY['Explain your motivation — was it learning, giving back, or solving your own problem','Show the work you did and its impact','Demonstrate how you balanced this with your main responsibilities','Include community feedback or adoption'],
 'Situation — Discovered a bug in an open-source library our entire company depended on that caused intermittent test failures. Task — Fix the issue upstream rather than patching it locally. Action — Reproduced the bug, wrote a failing test, submitted a fix PR with detailed explanation, worked through 3 rounds of review with the maintainer. Result — PR merged and released within 2 weeks, fixed the issue for 50K+ users of the library, earned me recognition from our CTO.'),

('init-incident-response',
 'Built an Incident Response Process',
 'Describe a time you established or significantly improved your team''s incident response process.',
 'initiative', 'hard',
 ARRAY['Explain what incident response looked like before your intervention','Show the specific improvements you made and why','Demonstrate buy-in from the team — not just top-down mandates','Include metrics on incident response time and recovery'],
 'Situation — Team had no formal incident response; when things broke, whoever noticed it scrambled. Average resolution time was 90 minutes. Task — Build a process that reduced resolution time and prevented panic. Action — Created an incident commander rotation, wrote runbooks for top 10 failure modes, set up PagerDuty with proper escalation, ran monthly game-day exercises. Result — Average resolution time dropped to 25 minutes, team members reported feeling significantly less stressed during incidents.');


-- CATEGORY 10: GROWTH (10 questions)

INSERT INTO public.questions (slug, title, prompt_text, category, difficulty, tips, example_answer) VALUES

('growth-uncomfortable-feedback',
 'Uncomfortable Feedback',
 'What is the most uncomfortable piece of feedback you have received from a manager? How did you respond, and did it change your behavior?',
 'growth', 'hard',
 ARRAY['Choose feedback that was genuinely hard to hear, not a humble-brag','Show your emotional reaction and how you processed it','Demonstrate specific behavioral changes you made','Include evidence that the change stuck'],
 'Situation — Manager told me I was "technically strong but dismissive of ideas from people with less experience," citing 3 specific examples. Task — Process the feedback honestly and change a blind spot. Action — Took 24 hours to sit with it, asked 2 trusted peers if they agreed (they did), implemented a personal rule: in every meeting, ask at least one question before sharing my opinion. Result — In my next review, same manager called out my improved collaboration as my biggest growth area.'),

('growth-skill-gap',
 'Closing a Critical Skill Gap',
 'Describe a time you realized you had a significant skill gap that was holding you back. What did you do about it?',
 'growth', 'medium',
 ARRAY['Be specific about the skill gap and how you identified it','Show your learning plan was structured, not random','Include the timeline and milestones of your improvement','Demonstrate how closing the gap changed your effectiveness'],
 'Situation — Got promoted to senior engineer but realized I couldn''t effectively design distributed systems, which was expected at my level. Task — Close the gap before it became a performance issue. Action — Read "Designing Data-Intensive Applications" cover to cover, did system design practice 3x/week, asked a staff engineer to review my designs monthly. Result — Within 6 months, I was leading system design for my team''s major projects and mentoring others on distributed patterns.'),

('growth-learned-from-failure',
 'Growth Through Failure',
 'Tell me about a professional failure that fundamentally changed how you approach your work.',
 'growth', 'medium',
 ARRAY['Choose a failure that genuinely changed you, not just taught a lesson','Show the before and after in your approach','Demonstrate ongoing impact, not just a one-time change','Be vulnerable but professional'],
 'Situation — Shipped a feature without proper load testing that crashed under real traffic on launch day, affecting 50K users. Task — Not just fix the immediate issue, but change my entire approach to quality. Action — Implemented a personal "launch readiness" checklist I use for every feature: load test, rollback plan, monitoring alerts, communication plan. Shared it with the team. Result — Haven''t had a single launch-day incident in 3 years, checklist was adopted team-wide.'),

('growth-blind-spot',
 'Discovering a Blind Spot',
 'What is a professional blind spot you have discovered about yourself? How did you discover it and what have you done about it?',
 'growth', 'hard',
 ARRAY['Show genuine self-awareness, not a rehearsed weakness','Explain the discovery moment — what made you realize it','Demonstrate ongoing work to address it, not a one-time fix','Include how it has affected your relationships and work'],
 'Situation — Realized through 360 feedback that I was consistently underestimating task complexity, leading to missed deadlines. Task — Understand why my estimates were always optimistic. Action — Started tracking actual vs. estimated time for every task, discovered I consistently forgot integration testing and edge case handling. Applied a 1.5x multiplier to all estimates and broke tasks into smaller pieces. Result — Estimate accuracy improved from 50% to 85% within a quarter.'),

('growth-career-pivot',
 'Intentional Career Pivot',
 'Describe a significant career decision you made to grow, even though it was risky or uncomfortable.',
 'growth', 'medium',
 ARRAY['Explain the comfort zone you left and why','Show the growth mindset behind the decision','Include the challenges you faced during the transition','Demonstrate it was worth it with specific evidence'],
 'Situation — Was a comfortable mid-level frontend engineer but realized I wanted to become a full-stack engineer to have more impact. Task — Transition from purely frontend to full-stack without taking a step backward in seniority. Action — Volunteered for backend projects, took an online distributed systems course, asked to pair with backend engineers for 3 months, eventually led a backend service redesign. Result — Promoted to senior full-stack engineer within a year, doubled the scope of problems I could own.'),

('growth-feedback-seeker',
 'Actively Seeking Feedback',
 'Tell me about a time you proactively sought critical feedback, not during a performance review. What did you learn?',
 'growth', 'easy',
 ARRAY['Show you initiated the feedback request, not just received it','Explain why you sought feedback at that particular time','Include what surprised you about the feedback','Demonstrate concrete changes you made as a result'],
 'Situation — After leading my first major project, I felt it went well but wanted honest input. Task — Get candid feedback from people who might be hesitant to offer it unsolicited. Action — Sent a brief survey to 6 collaborators with specific questions: "What should I keep doing, stop doing, and start doing?" and followed up 1:1 with anyone who gave critical feedback. Result — Learned I was over-communicating status updates (10 people said this), reduced my update frequency by 50%, and started a more targeted communication style.'),

('growth-teaching-to-learn',
 'Teaching to Deepen Understanding',
 'Describe how teaching or explaining a concept to others deepened your own understanding of it.',
 'growth', 'easy',
 ARRAY['Show the concept you thought you understood but didn''t fully','Explain what teaching forced you to clarify','Include how your deeper understanding improved your work','Demonstrate ongoing commitment to teaching as a learning tool'],
 'Situation — Volunteered to give a tech talk on database indexing, a topic I used daily but had never explained formally. Task — Create a 30-minute presentation that was accurate and useful. Action — While preparing, realized I couldn''t explain composite index ordering or covering indexes clearly, spent 8 hours researching and testing hypotheses with EXPLAIN ANALYZE. Result — The talk was rated highest in our series, and my own query optimization skills improved significantly — I found and fixed 3 slow queries in our codebase during prep.'),

('growth-manager-relationship',
 'Building a Better Manager Relationship',
 'Tell me about a time you actively worked to improve your relationship with your manager. What was the situation and what changed?',
 'growth', 'medium',
 ARRAY['Be honest about the initial state of the relationship','Show you took responsibility for your part','Explain the specific actions you took to improve things','Include how the improved relationship affected your work'],
 'Situation — My manager and I had frequent miscommunications about priorities; I''d work on what I thought was important, they''d be frustrated it wasn''t what they expected. Task — Fix the alignment problem before it affected my performance review. Action — Proposed a weekly 30-minute 1:1 with a standing agenda: my top 3 priorities for the week, any blockers, and one growth topic. Sent a pre-read 24 hours before each meeting. Result — Miscommunications dropped to near-zero, manager cited our 1:1 format as a model for other ICs.'),

('growth-comfort-zone',
 'Stepping Outside Your Comfort Zone',
 'Describe a professional situation where you deliberately chose the uncomfortable path over the easy one. Why, and what happened?',
 'growth', 'easy',
 ARRAY['Explain why the comfortable option was tempting','Show the deliberate choice and your reasoning','Include the discomfort you felt and how you managed it','Demonstrate growth that wouldn''t have happened otherwise'],
 'Situation — Had the option to stay on a team where I was the expert or transfer to a new team working with unfamiliar technology. Task — Choose between comfort and growth. Action — Transferred to the new team, accepted being the least experienced person in the room, asked basic questions without embarrassment, documented my learning for future transfers. Result — Became proficient in 3 months, brought cross-team perspectives that improved the new team''s architecture, and grew more in 6 months than I had in the previous 2 years.'),

('growth-peer-feedback-loop',
 'Building a Peer Feedback Loop',
 'Tell me about a system or habit you created for getting regular feedback from peers, not just managers.',
 'growth', 'hard',
 ARRAY['Show this was proactive, not mandated by your company','Explain the specific mechanism you created','Include examples of feedback that surprised you or changed your behavior','Demonstrate this is an ongoing practice, not a one-time experiment'],
 'Situation — Realized I was only getting feedback from my manager twice a year, missing perspectives from the 8 engineers I worked with daily. Task — Create a lightweight peer feedback system. Action — Set up monthly "feedback exchanges" with 2-3 peers, using a simple format: one thing I did well, one thing I could improve. Kept a feedback journal to track patterns. Result — Discovered I was unknowingly blocking PRs by not reviewing promptly, fixed it within a week. Over a year, peers said I was the most coachable person on the team.');
