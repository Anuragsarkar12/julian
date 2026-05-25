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
