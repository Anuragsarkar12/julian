
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
