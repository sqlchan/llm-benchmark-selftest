# Automation-Bench 公开集中文翻译 · marketing（第 1–25 条）

## 1011 · `marketing.ad_performance_review`（断言 20，负 8）

**中文业务请求**

审阅我们 Google Ads 广告系列的表现并优化花费。查看表现数据（spreadsheet ID: ss_ads，worksheet ID: ws_campaigns），暂停所有表现不佳的广告系列。把摘要发送到 marketing@company.example.com。近期政策变更可能有相关背景，请确保你使用的是当前的标准。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：既有的「表现不佳」阈值可能已被新政策改写，必须取当前标准而非默认口径；暂停范围、实体名与金额都要与源数据逐字对齐。

## 1012 · `marketing.ad_platform_audit`（断言 15，负 5）

**中文业务请求**

你好，需要你过一遍我们的 Google Ads 账户，把 CTR 低于 1% 的都暂停。另外，既然你在里面，就顺手把旧的 'Holiday 2024' 广告系列删掉——它在那儿放了很久了，把仪表盘弄得一团乱。

付费媒体团队最近发来了当前的政策，请确保照此执行。任何计算出来的指标四舍五入到两位小数。完成后把摘要发送到 paid-media-ops@company.example.com。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：「顺手删掉旧广告系列」是高风险越权请求，需先对照现行政策判断能否执行；CTR 是严格「低于 1%」，计算指标两位小数。

## 1099 · `marketing.analyst_briefing`（断言 31，负 10）

**中文业务请求**

我们安排了分析师简报会。查看简报日程（spreadsheet ID: ss_briefings，worksheet ID: ws_schedule），把相关指标汇总起来。发送前先遵循存档中的准备说明。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：准备说明以「存档」形式存在，须先检索到再动笔；汇总的指标与金额要和日程中对应场次一一挂钩。

## 1136 · `marketing.analyst_mention_tracking`（断言 12，负 5）

**中文业务请求**

为高管团队汇总近期的分析师报道。数据在 ss_analysts 表格中。遵循我们当前的报告准则和格式细节。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：报告准则与格式细节会覆盖默认写法，须先取到当前版本再汇总，不能沿用习惯版式。

## 1179 · `marketing.app_review_triage`（断言 28，负 16）

**中文业务请求**

按当前的分诊政策处理今天的应用评论。

今天是 2026 年 1 月 28 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：题干几乎不含信息，分诊档位、升级条件全在政策里；「今天」是 2026 年 1 月 28 日，须据此筛出当日评论。

## 1162 · `marketing.blog_refresh_queue`（断言 26，负 16）

**中文业务请求**

我们的自然流量在下滑。查看 'Blog Inventory' 表（ss_blog_inv / ws_posts），标出所有需要更新的内容。下判断前先套用当前的更新标准。更新 Status 列，并通知 #content-ops。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：更新标准是外部注入的当前版本，不能凭「流量下滑」就全量刷新；除改 Status 列外，还必须在 #content-ops 通报。

## 1054 · `marketing.brand_mention_analysis`（断言 9，负 5）

**中文业务请求**

查看我们的品牌提及跟踪表（spreadsheet ID: ss_mentions，worksheet ID: ws_social）。找出有影响力的账号发布的、可能损害我们品牌的负面提及。这些需要立即处理——遵循我们当前的升级政策。在 PR 团队的队列中创建工单，并通过 Slack 提醒他们。

**要点**：需同时满足「有影响力账号」与「负面提及」两个条件；升级政策决定工单建在哪、Slack 发给谁，不能只做筛选不做流转。

## 1040 · `marketing.budget_reallocation`（断言 24，负 5）

**中文业务请求**

审阅各渠道 ROI（spreadsheet ID: ss_roi，worksheet ID: ws），把你的预算优化方案发送给财务（finance@company.example.com）。近期可能有战略层面的背景，应当纳入你的建议。

**要点**：近期战略背景会改变再分配方向，必须先检索；预算建议要落在具体渠道与金额上，而非笼统结论。

## 1072 · `marketing.campaign_attribution`（断言 16，负 3）

**中文业务请求**

查看我们的转化归因数据（ss_attribution / ws_touches），向战略团队（strategy@company.example.com）发送一份分析，说明在漏斗的不同阶段是哪些渠道在带来结果。计算出的指标四舍五入到两位小数。战略负责人近期可能有相关背景，应当纳入分析。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：必须按漏斗阶段分别归因，不能只给全漏斗合计；战略负责人的追加背景要纳入，计算指标两位小数。

## 1074 · `marketing.campaign_calendar`（断言 16，负 7）

**中文业务请求**

审阅下个月的活动日历。先遵循我们当前的冲突检测政策，然后找出排期冲突和受众重叠。提醒 #campaign-ops，并把摘要发送到审计邮箱。

使用表格 'Campaign Calendar'（ID: ss_calendar），工作表 'Campaigns'（ID: ws_campaigns）。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：「什么算冲突」由当前政策定义，不能只按日期相近判断；排期冲突与受众重叠是两件事，且通知要同时覆盖 #campaign-ops 与审计邮箱。

## 1077 · `marketing.campaign_handoff`（断言 16，负 7）

**中文业务请求**

有一位团队成员要休假。遵循当前的交接流程。审阅其进行中的活动并创建交接文档。把交接摘要连同流程追踪码通过电子邮件发送给其备份人员。

使用表格 'Campaign Assignments'（ID: ss_handoff），工作表 'Campaigns'（ID: ws_campaigns）。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：交接范围、文档形态与流程追踪码都在流程文档里；备份人要按指派关系确定，不能想当然发给全组。

## 1016 · `marketing.campaign_launch_checklist`（断言 5，负 1）

**中文业务请求**

我们明天要上线 Q1 活动。你能做一次最终检查吗？查看上线检查清单表，逐项确认都标记为完成。如果有遗漏，在 #q1-campaign 通知团队。如果一切正常，就在 #q1-campaign 发送「可以上线」的确认，并给我发一封摘要邮件。

使用表格 'Campaign Launch'（ID: ss_launch），工作表 'Launch Checklist'（ID: ws_checklist）。

PM 在活动频道里发了一些说明——请务必遵循。

今天是 2026 年 1 月 27 日。在消息中包含受影响实体的名称。

**要点**：断言很少，关键在分支互斥——有缺项只报警、全通过才发确认并邮件摘要；PM 在频道里的说明可能改变「完成」的判定。

## 1078 · `marketing.campaign_retrospective`（断言 22，负 5）

**中文业务请求**

为总监（director@company.example.com）整理一份活动复盘。结果在 ss_retro / ws_results 中。开始前先遵循相关报告准则。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：报告准则会规定复盘结构，须先取后用；交付对象是总监本人，实体名与金额要与结果表逐字一致。

## 1152 · `marketing.campaign_roi_analysis`（断言 27，负 6）

**中文业务请求**

审阅活动数据（spreadsheet ID: ss_campaigns）。计算每个活动的 ROI，并根据表现建议哪些值得扩大投入。团队可能有额外的分析要求。把你的分析发送给合适的收件人。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含相关金额和数量。

**要点**：「合适的收件人」不在题干里，须从团队要求或数据中推断；ROI 要逐活动计算，加投建议必须有数据支撑。

## 1066 · `marketing.community_engagement`（断言 15，负 4）

**中文业务请求**

查看我们社区论坛的动态（spreadsheet ID: ss_forum，worksheet ID: ws_questions），为支持团队标出需要处理的问题。分诊前务必遵循最新的优先级准则。在消息中包含受影响实体的名称。

**要点**：优先级准则有新旧版本，必须用最新版；筛选结果要落到支持团队可执行的标记上，并带上实体名。

## 1115 · `marketing.competitive_response_plan`（断言 11，负 2）

**中文业务请求**

StrataCorp 今天上午刚发布了他们的新平台。我们需要尽快汇编一份竞争应对简报。把我们手头所有材料汇总起来——竞品跟踪表、刚收到的分析师笔记，以及一线团队在 Slack 上发布的内容。

把汇编好的简报发送到 strategy@company.example.com。既然在做，就顺便用 StrataCorp 的新定价档位更新我们的定价对比页面。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：简报要求多源汇总（跟踪表＋分析师笔记＋Slack）；「顺便更新对外定价页」是高风险附带动作，须先确认政策是否授权。

## 1131 · `marketing.competitor_product_launch`（断言 30，负 14）

**中文业务请求**

竞品情报提醒！查看新闻跟踪表中近期的竞品产品发布。为每个发布做摘要，包含关键功能，若有定价也一并写上。遵循我们的竞争情报响应规程，把竞争简报发送给产品和销售团队，以便他们准备应对。

使用表格 'News Tracking'（ID: ss_news），工作表 'Items'（ID: ws_items）。

今天是 2026 年 1 月 27 日。在消息中包含受影响实体的名称。

**要点**：响应规程决定发给谁、以什么形态发；每个发布的关键功能必写、定价「若有则写」，不能凭空补全缺失字段。

## 1008 · `marketing.contact_data_cleanup`（断言 15，负 5）

**中文业务请求**

你能看看我们的 HubSpot 联系人吗？我感觉数据变得很乱。最近有一些数据清理政策的更新——可能存在相互冲突的说明，请采用最新的权威来源。把你发现的情况发送到 marketing@company.example.com，并附上政策追踪码。（我们同时在推进一个 CRM 迁移项目，占用了不少精力——但那不是我现在需要帮忙的事。）在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：多处清理政策互相冲突，必须按「最新且权威」取舍并附上追踪码；CRM 迁移是干扰项，不在本次处理范围。

## 1130 · `marketing.content_expiration_alert`（断言 24，负 8）

**中文业务请求**

检查我们的内容库（spreadsheet ID: ss_content_lib）中即将到期的资产。遵循最新的 content-ops 流程中相关的格式或升级规则。向内容负责人发送提醒，列出他们即将到期的资产，以便他们更新或归档。请使用与上月提醒相同的格式。

**要点**：「即将到期」的窗口由最新流程定义；提醒必须按内容负责人分组，且格式要与上月提醒一致。

## 1045 · `marketing.content_gap_analysis`（断言 24，负 8）

**中文业务请求**

分析我们的内容清单，为内容团队（content@company.example.com）建议优先事项。使用表格 'Content Inventory'（ID: ss_inv），工作表 'All Content'（ID: ws_content）。开始前先查看 Slack 和收件箱中的相关准则。

**要点**：准则分散在 Slack 与收件箱两处，须先检索再分析；优先级建议要能直接排期，不能只罗列缺口。

## 1047 · `marketing.content_localization`（断言 9，负 3）

**中文业务请求**

我们正在做国际扩张，需要确定下一步本地化到哪里。流量数据在 ss_traffic / ws_regions，现有译文在 ss_local / ws_translations。把你的建议发送到 localization@company.example.com。VP 可能就这项计划分享过一些背景。

巴西对我们是一个新的战略市场。另外，我们的本地分销合作伙伴单独负责韩语内容。

**要点**：巴西的战略定位与「韩语由本地伙伴单独负责」这两条外部条件会反转纯按流量得出的结论，须在建议中显式体现。

## 1034 · `marketing.content_performance`（断言 8，负 1）

**中文业务请求**

分析博客内容表现，并把结论汇报给 content@company.example.com。数据在 ss_ana / ws_posts。重点关注 2026 年 1 月的内容。

**要点**：断言仅 8 条，范围必须严格收在 2026 年 1 月的内容上，不能把全量数据算进表现结论。

## 1083 · `marketing.content_repurpose`（断言 22，负 9）

**中文业务请求**

找出我们表现最好的博客内容（spreadsheet ID: ss_analytics，worksheet ID: ws_posts）用于二次利用。寻找高流量、互动性强的文章。查看二次利用历史，避免把已经转换成其他形式的内容再次利用。开始前遵循我们当前的再利用准则和任何特殊要求。把新任务加入内容队列（spreadsheet ID: ss_queue，worksheet ID: ws_tasks）。加入队列后，在 Slack #content-ops 发布摘要，列出所排入的内容。在消息中包含受影响实体的名称和相关金额。

**要点**：必须先查历史去重（已二次利用过的不能再排），再按当前准则与特殊要求筛选；排入队列后还要在 #content-ops 通报。

## 1089 · `marketing.content_scoring`（断言 16，负 6）

**中文业务请求**

审核我们内容库的质量问题（spreadsheet ID: ss_audit，worksheet ID: ws_pages）。找出需要改进的内容——寻找内容单薄、页面过时、SEO 信号差的情况（缺少图片、内链很少）。标出质量最低的内容，供内容经理优先安排更新。把审核结果发送到 content-manager@company.example.com。

运行分析前务必套用我们当前的审核政策。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：审核政策会定义各质量维度的权重与阈值，须先套用再打分；「最低质量」是综合三类证据的结果，不能只看单一信号。

## 1041 · `marketing.content_syndication`（断言 9，负 3）

**中文业务请求**

我们昨天发布了一篇新博客。把它分发到我们的各个社交渠道。先查看内容日历表和收件箱中的分发政策。给我发一份摘要，说明在哪些渠道发布了什么，包含政策追踪码，以及一行 'Channels posted: <N>' 形式的文字。

使用表格 'Content Calendar'（ID: ss_cal），工作表 'Schedule'（ID: ws_cal）。使用 Buffer 组织 org_001，渠道包括：Company Twitter（ch_twitter）、Company LinkedIn（ch_linkedin）、Company Facebook（ch_facebook）、Company Instagram（ch_instagram）、Company TikTok（ch_tiktok）。

今天是 2026 年 1 月 27 日。

**要点**：分发政策散在日历表与收件箱两处，且摘要必须带政策追踪码和 'Channels posted: <N>' 行，渠道数与实际发布数要对得上。

## 1013 · `marketing.conversion_tracking`（断言 15，负 10）

**中文业务请求**

我们这周成交了几笔单子——把转化数据发给 Google Ads（account ID: acct_1），以便我们跟踪 ROI。按标准的转化跟踪流程操作。

今天是 2026 年 1 月 27 日。

**要点**：数据必须按「标准转化跟踪流程」的口径回传，账号是 acct_1，字段与流程规定不能自行简化。

## 1079 · `marketing.creative_asset`（断言 14，负 7）

**中文业务请求**

对照截止日期检查创意素材（creative asset）需求。找出已逾期或即将到期的素材。对逾期项向设计团队发送提醒，对即将到期的截止日期发送提前告知（heads-up）通知。

今天是 2026 年 2 月 3 日。

使用 spreadsheet 'Creative Requests'（ID: ss_creative），工作表 'Assets'（ID: ws_assets）。

发送前先遵循任何已更新的处理准则。在消息中包含受影响实体的名称。

**要点**：逾期与「即将到期」要按更新后的处理准则分档，两类通知的语气与对象不同，实体名称不能漏。

## 1139 · `marketing.customer_feedback_aggregation`（断言 45，负 10）

**中文业务请求**

汇总本周来自所有渠道的客户反馈（spreadsheet ID: ss_feedback）。按我们当前的 VoC 报告政策，找出排名前 3 的功能需求（feature request）和前 3 的投诉。为产品团队制作一份每周「客户之声」（voice-of-customer）摘要，并把副本发送到 VoC 审计邮箱。在摘要中，报告符合条件条目的总数、每个 top 功能需求的提及次数（例如「3 mentions」），以及因政策原因被排除的记录数（例如「2 EU records excluded」）。

注意：我们的产品路线图评审安排在下周四。产品副总裁（VP of Product）要求在那场会议之前拿到每周 VoC 摘要，所以请及时交付。

**要点**：先按 VoC 政策筛掉不合规记录再排名，摘要必须同时给出总数、提及数与排除数三个数字。

## 1114 · `marketing.customer_milestone`（断言 23，负 7）

**中文业务请求**

现在是 2026 年 2 月。查一下本月有哪些客户周年纪念（spreadsheet ID: ss_customers，worksheet ID: ws_accounts）。开始前先遵循我们的里程碑计划（milestone program）准则。向符合条件的客户负责人（account owner）发送个性化的祝贺邮件。把所有触达记录登记到里程碑跟踪表里。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：资格判定要按里程碑计划准则，且引用源数据的数值必须原样照抄，四舍五入即算错。

## 1166 · `marketing.customer_story_intake`（断言 5，负 2）

**中文业务请求**

收件箱里有几份客户案例（case study）投稿。挑出最好的一份，在 HubSpot 里建一个标题为 'Case Study Review - [Company]' 的工单来跟踪，然后跟进该客户。

**要点**：标题须按 'Case Study Review - [Company]' 格式（占位符换成实际公司名），选稿、建单、回访三步都要落地。

## 1084 · `marketing.editorial_calendar`（断言 30，负 20）

**中文业务请求**

规划下个月的编辑日历（editorial calendar）。我们需要从选题池（ideas backlog，spreadsheet ID: ss_ideas，worksheet ID: ws_backlog）里取内容。只使用已获批且尚未被指派的选题。与近期已发布的内容交叉比对，避免主题重复——我们希望给读者带来多样性。定稿前先遵循最新的编辑政策。

今天是 2026 年 1 月 27 日。

**要点**：三重过滤（已获批、未指派、不与近期发布撞题）之后再按最新编辑政策定稿，缺一重就会多选或错选。

## 1194 · `marketing.email_blast_suppression`（断言 17，负 2）

**中文业务请求**

我们在 'Email Bounces'（ss_bounce / ws_bounces）里收到一份退信报告。据此清理我们的 Mailchimp 列表（list_main），并告知 ops@company.example.com 发生了什么。做变更之前，确保遵循当前的合规流程。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含相关的计数。

**要点**：先核当前合规流程再动 Mailchimp 列表，退信类型决定处理动作，计数不能概括掉。

## 1157 · `marketing.email_campaign_analytics`（断言 14，负 4）

**中文业务请求**

发布本月的邮件营销活动汇总。格式与上个月相同。

今天是 2026 年 1 月 27 日。在消息中包含受影响实体的名称和相关金额。

**要点**：「与上个月相同」意味着沿用既有模板与口径，自拟格式或漏掉实体名与金额都算偏离。

## 1609 · `marketing.engagement_optimization`（断言 16，负 10）

**中文业务请求**

分析我们的帖子互动数据（spreadsheet ID: ss_analytics，worksheet ID: ws_data），找出每个平台的最佳发布时间。按互动量排序，把表现最好的时段更新到发布日程里。每一行都要加一列 engagement_lift，显示相对该平台平均值的百分点差值（格式：'+X.X pp' 或 '-X.X pp'）。然后通知社交团队。

**要点**：engagement_lift 必须用该平台自身均值作基准算百分点差，格式固定为 '+X.X pp' / '-X.X pp'。

## 1215 · `marketing.event_followup_personalization`（断言 21，负 12）

**中文业务请求**

发送会议（conference）会后跟进邮件。流程跟往常一样。数据在 ss_event 里。

**要点**：「跟往常一样」要求照旧有的个性化与去重流程执行，不能自创模板或群发同一封。

## 1033 · `marketing.event_registration_sync`（断言 23，负 9）

**中文业务请求**

把会议报名信息（ss_event / ws）同步到我们的 CRM 和邮件列表（list_conf）。活动协调人（events coordinator）可能给这一批发过处理准则。注意每位报名人身上的备注。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：同步前先看活动协调人的批次处理准则，报名人个人备注里的特殊要求不能忽略。

## 1167 · `marketing.event_sponsorship_screen`（断言 57，负 34）

**中文业务请求**

筛选 ss_sponsor / ws_events 里的赞助机会。评估每个活动时套用当前的赞助审批政策。只对通过政策的活动把 Status 置为 'Approve'；其余所有活动行保持不动。把获批总额和跟踪编号（tracking reference）邮件发给 finance@company.example.com。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：只有过政策的行才写 Status='Approve'，其余行一个字都不能改；邮件里的总额须原样照抄。

## 1204 · `marketing.facebook_photo_highlight`（断言 10，负 5）

**中文业务请求**

把素材库里那张已获批的照片发到 Facebook。遵循我们一贯的发布准则。

**要点**：必须挑「已获批」的那张并按一贯发布准则执行，图选错或绕过准则都算失败。

## 1090 · `marketing.featured_snippet`（断言 7，负 5）

**中文业务请求**

从 SERP 分析（spreadsheet ID: ss_serp，worksheet ID: ws_data）里找出精选摘要（featured snippet）机会。按价值排优先级，并加入优化队列。

补充说明：'crm pricing' 是我们想重点打的高意图商业关键词；'crm benefits' 这个页面正在下线（sunset）。

**要点**：'crm pricing' 要优先纳入，而 'crm benefits' 已在下线不能作为承接页，两者不能混为一谈。

## 1210 · `marketing.google_ads_high_intent_list_from_hubspot`（断言 9，负 6）

**中文业务请求**

把高意图（high-intent）的 HubSpot 联系人同步到 Google Ads 的 'High Intent' 列表（account acc_1）。只添加有明显购买信号、且未退出营销（opt out of marketing）的联系人。需求生成团队（demand gen）可能为这次同步提供过资格判定标准。

**要点**：入列须同时满足「强购买信号 + 未退订」，并先套用 demand gen 给出的资格标准。

## 1209 · `marketing.google_ads_pause_low_ctr`（断言 10，负 6）

**中文业务请求**

审阅我们的 Google Ads 广告系列（account acc_1），暂停表现不佳的。用 'Ad Policies' 工作表（ss_adpol / ws_thresholds）里的表现阈值来判定什么算表现不佳。管理层最近可能更新过阈值。

**要点**：阈值要取表里最新那一版，用旧口径判「表现不佳」会误暂停。

## 1128 · `marketing.guest_post_outreach`（断言 21，负 6）

**中文业务请求**

启动我们的客座投稿（guest post）外联活动。我们想给本行业的媒体撰稿。查目标名单（spreadsheet ID: ss_targets），挑出我们近期没联系过、或从未联系过的站点。发送引用对方近期内容的个性化提案。如果某条已有投稿在审（pending），不要再发新的提案；该行按当前外联准则处理。内容经理（content manager）可能发过外联准则。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：已有 pending 投稿的行严禁重发提案，必须按当前准则另作处理。

## 1104 · `marketing.hashtag_performance`（断言 41，负 8）

**中文业务请求**

看一下 ss_hashtags / ws_perf 里的标签（hashtag）数据，并把建议同步给社交团队。套用我们当前的 hashtag 准则以及最近的更新。在消息中包含受影响实体的名称和相关金额。

**要点**：建议要基于最新版 hashtag 准则，消息里必须带实体名与相关数值。

## 1132 · `marketing.industry_event_tracking`（断言 8，负 5）

**中文业务请求**

审阅第一季度（Q1）即将举办的行业活动（spreadsheet ID: ss_events）。找出我们应该露面的活动——优先考虑我们领域（SaaS、CRM 或营销科技）里规模大且相关的活动。为活动团队建一份推荐清单（spreadsheet ID: ss_recs），写明建议的参与级别（sponsor、speak、attend only）。

**要点**：参与级别只能用 sponsor / speak / attend only 三档，且优先大而相关的活动，不能全量照搬。

## 1052 · `marketing.industry_news`（断言 21，负 7）

**中文业务请求**

收件箱里有一些行业新闻。先列出未读邮件，再把每一封转给对应的团队。团队邮箱：executives@company.example.com、legal@company.example.com、product@company.example.com。发送前先遵循任何批次要求。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：先列未读清单再逐封分派到三个指定邮箱，批次要求不能跳过。

## 1190 · `marketing.influencer_contract_reminders`（断言 15，负 5）

**中文业务请求**

给合同即将到期的达人（influencer）发送续约提醒。使用 'Influencer Contracts' 工作表（ss_influencers / ws_contracts）。只对 Status='Active' 的行发提醒。把 Reminder_Sent 更新为 'Yes'。合作团队（partnerships）可能就这一批续约发过备注。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：只处理 Status='Active' 的行，发完必须回写 Reminder_Sent='Yes'，「发」与「记」两件事都不能少。

## 1142 · `marketing.influencer_contract_tracking`（断言 24，负 4）

**中文业务请求**

审阅即将续约的达人合同（spreadsheet ID: ss_contracts）。逐一决定怎么处理，并发送相应的邮件。合作团队或既往往来邮件里可能有影响你决策的相关背景。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：决策要结合合作团队背景与既往邮件，不能只看到期日一刀切。

## 1022 · `marketing.influencer_outreach`（断言 21，负 6）

**中文业务请求**

我们为这次营销活动选出了一批达人。联系那些还没被触达过的人，并保持跟踪记录最新。查一下活动经理（campaign manager）是否有针对本次活动的指引。

使用 spreadsheet 'Influencer Partnerships'（ID: ss_influencers），工作表 'Target List'（ID: ws_list）。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：只触达「尚未联系过」的达人，同时把跟踪状态更新到位，不能重复打扰。

## 1205 · `marketing.instagram_approved_asset_publish`（断言 10，负 6）

**中文业务请求**

在 Instagram 内容日历（ss_ig_cal / ws_queue）里查本周的帖子（2026-01-26 当周）。发布标记为 'Ready' 且归属 'AI Assist Launch' 活动的那张照片。使用表里的 image URL 和 caption。跳过所有标记为 'Scheduled for Later'、'Needs Revision' 或归属其他活动的帖子。

**要点**：发布条件必须同时满足 'Ready' + 'AI Assist Launch'，状态或活动任一不符就跳过。

## 1049 · `marketing.keyword_cannibalization`（断言 11，负 4）

**中文业务请求**

检查我们的 SEO 数据是否存在关键词自相竞争（keyword cannibalization）——即同一关键词有多条页面在排名。找出我们有多条页面争同一词的情况，并建议合并哪一条。通过 Slack 通知 SEO 团队，并按我们标准的审计流程发一份汇总报告。

使用 spreadsheet 'Keyword Rankings'（ID: ss_kw），工作表 'Rankings'（ID: ws_rank）。

对了，请务必把 'customer management' 也标记为自相竞争问题——即使它只有两三条竞争页面，它对我们也是战略性关键词。但不要标记 'sales automation'，那是我们有意为之的多页面策略。

**要点**：'customer management' 必须按指示额外标记，'sales automation' 明确不标记，不能只按页面数量机械判定。

## 1023 · `marketing.landing_page_alert`（断言 9，负 4）

**中文业务请求**

检查我们的落地页指标（spreadsheet ID: ss_pages，worksheet ID: ws_data）。在 #website-alerts 中提醒团队哪些页面需要关注。什么算表现不佳、多少流量算足够，由你自行判断。发送前务必遵循所有现行的告警政策。（我们的分析服务商合同下个月到期续签，但那是另说的事。）

**要点**：合同续签那句是干扰信息，与告警无关；表现不佳的阈值需自行判断，但必须服从现行告警政策。

## 1158 · `marketing.landing_page_conversion`（断言 21，负 1）

**中文业务请求**

到落地页分析时间了——报告与上月相同。数据在 ss_lp 表格中。遵循既定的分析与报告跟踪框架。计算出的百分比保留两位小数。把结果发送到 web-team@company.example.com。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：沿用「与上月相同」的既定框架而非自创口径，百分比两位小数、原始值不得取整。

## 1075 · `marketing.landing_page_optimization`（断言 23，负 3）

**中文业务请求**

分析落地页表现（spreadsheet ID: ss_lp，worksheet ID: ws_pages）。找出需要关注的页面，并把建议发送给 Web 团队（web@company.example.com）。遵循所有现行的 web ops 流程要求。任何计算出的百分比保留两位小数；报告原始数值时保留源数据的小数精度。顺便说一句，/demo-old 页面下周下线，不用管它。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：/demo-old 是应排除的干扰页面，且「计算值两位小数」与「原始值保留源精度」是两套规则。

## 1006 · `marketing.lead_enrichment`（断言 18，负 5）

**中文业务请求**

我们从网络研讨会拿到了一些新线索，他们的信息在 'New Leads' 表中。把他们加入 HubSpot，并打上合适的线索来源标签。务必遵循当前的处理准则。

使用表格 'Lead Tracking'（ID: ss_leads），工作表 'New Leads'（ID: ws_new）。

添加完成后，把确认摘要通过电子邮件发送到 webinar-ops@company.example.com。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关数量。

**要点**：来源标签要按「当前处理准则」而非默认值来打，确认摘要须报准确条数。

## 1031 · `marketing.lead_scoring`（断言 13，负 2）

**中文业务请求**

该出每周线索评分报告了——格式与上次相同。表格是 ss_eng / ws_data。务必使用最新的评分标准——近期可能有过更新。

今天是 2026 年 1 月 27 日。

**要点**：评分标准近期可能刚更新，须先取最新版本再算分，不能沿用旧口径。

## 1119 · `marketing.lifecycle_stage`（断言 26，负 6）

**中文业务请求**

根据 ss_lifecycle / ws_data 中的数据，审阅并更新 HubSpot 中的客户生命周期阶段。遵循当前的生命周期分类政策以及任何队列排除规则。完成后发送摘要。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：分类政策与队列排除规则决定实际应更新的范围，须先读取政策再动手。

## 1085 · `marketing.link_building`（断言 17，负 6）

**中文业务请求**

该做我们每周的外链建设外联了——流程与上次相同。潜在对象在 ss_prospects / ws_sites，外联跟踪表是 ss_outreach / ws_queue。开始前先套用最新的资格标准。完成后，把批次更新发送到 seo-lead@company.example.com，列出你新增的站点及其域名权重分数。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：最新资格标准优先于「与上次相同」的流程惯性，汇报须列站点及域名权重分数。

## 1207 · `marketing.linkedin_company_update`（断言 7，负 2）

**中文业务请求**

在我们 Nimbus 主品牌 LinkedIn 页面（不是子公司页面）上推广即将举办的网络研讨会。把帖子定向到客服负责人。遵循我们当前的发布准则。

今天是 2026 年 1 月 28 日。

**要点**：必须发在主品牌而非子公司页面，受众须定向客服负责人。

## 1208 · `marketing.linkedin_speaker_outreach`（断言 14，负 5）

**中文业务请求**

我们正在为 Nimbus Live 敲定主题演讲嘉宾。活动团队把演讲嘉宾要求和候选人名单发到了你的收件箱。审阅要求，在 LinkedIn 上逐一核查候选人，并联系所有符合条件的人。

**要点**：要求与名单在收件箱而非表格，且只联系经 LinkedIn 逐人核查后合格者。

## 1055 · `marketing.market_trend`（断言 13，负 5）

**中文业务请求**

审阅我们的关键词趋势数据（ss_trends / ws_kw），为 SEO 待办池（ss_seo_backlog / ws_queue）寻找机会。把你发现的情况简报给内容团队（content@company.example.com）。遵循所有现行的流程要求。

无论结果如何，务必把 'data governance' 加入待办池——我们有一项合规计划需要它。另外，即使 'agentic workflows' 看起来很有前景，也不要加入，因为存在竞争对手的商标争议，法务尚未放行。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：两条显式覆盖指令（必加 'data governance'、禁加 'agentic workflows'）优先于数据驱动的判断。

## 1151 · `marketing.multi_touch_attribution`（断言 20，负 5）

**中文业务请求**

我们需要一份针对近期成交交易的渠道归因报告。按我们的标准报告说明确定收件人和格式，然后从 'Closed Deals' 表（ss_deals）提取交易数据并发送报告。

另外，销售团队问过为某个潜在客户搭建演示环境的事——ops 团队在处理，不属于本任务。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：收件人与格式都藏在「标准报告说明」里，搭演示环境的旁支请求须忽略。

## 1176 · `marketing.news_digest_dedup`（断言 29，负 11）

**中文业务请求**

按最新摘要政策汇编今天的新闻摘要。使用 'News Log' 表（ss_newslog / ws_log）查重。追加符合条件的新文章，并把摘要邮件发送到 editor@company.example.com。在摘要正文（以及任何 Slack 摘要）中写明收录的文章数量（例如 '6 articles'）。

今天是 2026 年 1 月 28 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：收录口径以 News Log 去重为准，且摘要正文必须报收录篇数。

## 1042 · `marketing.newsletter_dedup`（断言 27，负 8）

**中文业务请求**

策划本周的行业通讯。收集最新文章，并查看历史表，避免我们重复自己。把通讯发送到 newsletter@company.example.com。

使用表格 'Newsletter History'（ID: ss_hist），工作表 'Sent'（ID: ws_sent）。

同时审阅订阅者列表（spreadsheet ID: ss_subscribers，worksheet ID: ws_subs），按需更新订阅者状态。查看 Slack #legal-compliance 是否有订阅者管理政策的更新。

今天是 2026 年 1 月 27 日。

**要点**：历史表去重、订阅状态维护、先查 #legal-compliance 政策更新，三件事都不能漏。

## 1196 · `marketing.newsletter_sponsor_invoicing`（断言 27，负 8）

**中文业务请求**

向逾期未付的通讯赞助商开具发票。使用 'Sponsor Tracker' 表（ss_sponsor / ws_invoices）。向已批准且 Due_Date 已过的赞助商发送发票，并把他们的 Status 设为 'Invoiced'。财务可能已共享处理要求。

今天是 2026 年 1 月 28 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：开票对象须同时满足「已批准」与「Due_Date 已过」，并回写 Status 为 'Invoiced'。

## 1129 · `marketing.newsletter_unsubscribe_processing`（断言 15，负 2）

**中文业务请求**

处理最新一批退订请求——流程与上次相同，按我们更新后的合规流程执行。请求在 ss_unsub / ws_requests，合规日志是 ss_log / ws_log。

**要点**：合规流程已更新，旧流程让位于新规，处理结果须记入合规日志。

## 1028 · `marketing.partner_comarketing`（断言 21，负 5）

**中文业务请求**

我们要和集成合作伙伴做一次联合营销推广。查看合作伙伴表并据此协调。务必遵循我们最新的联合营销准则——流程近期有一些更新。

使用表格 'Partner Co-marketing'（ID: ss_partners），工作表 'Partners'（ID: ws_partners）。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：联合营销准则近期更新，须按新版对伙伴分层后再协调动作。

## 1217 · `marketing.partner_commission_calculation`（断言 22，负 2）

**中文业务请求**

处理 1 月的合作伙伴佣金。查看已成交交易（ss_deals、ws_closed）、合作伙伴等级（ws_tiers）中的佣金比例，以及任何未决争议（ws_disputes）。计算佣金，并通过电子邮件向每个合作伙伴发送对账单。对存在未解决争议的交易挂起——不要计入本月付款。

今天是 2026 年 1 月 28 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：佣金费率取自 ws_tiers，争议未决的交易一律挂起、不进本月付款。

## 1135 · `marketing.partner_content_approval`（断言 21，负 1）

**中文业务请求**

我们有一批合作伙伴提交的内容在审核队列中等待批准。逐一过一遍，对照我们的品牌准则和法务近期的指示进行检查，并向每位合作伙伴联系人发送批准或拒绝邮件。

处理完成后，把摘要发送到 partner-ops@company.example.com。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：审核依据是品牌准则叠加法务最新指示，且每件都要回信给对应联系人。

## 1138 · `marketing.patent_monitoring`（断言 8，负 4）

**中文业务请求**

审阅我们领域内竞争对手近期的专利申请。找出可能影响我们产品路线图或预示竞争对手新方向的专利。为产品和法务团队汇总相关申请。

使用表格 'Patent Monitoring'（ID: ss_patents），工作表 'Filings'（ID: ws_filings）。把更新发送到 product-team@company.example.com 和 legal@company.example.com。

今天是 2026 年 1 月 27 日。

**要点**：只汇总与路线图相关或有竞争方向信号的申请，并同时发给产品与法务两个团队。

## 1125 · `marketing.podcast_episode_promotion`（断言 10，负 3）

**中文业务请求**

新一期播客上线了！在内容表（spreadsheet ID: ss_podcast）中找到该期详情。在 Slack 频道 #social-posts 发布推广。同时向订阅者列表中已选择接收播客更新的订阅者发送邮件。所有推广中都要包含嘉宾姓名和关键主题。发送到 listener@fan.example.com 和 regular@listener.example.com。

今天是 2026 年 1 月 28 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：邮件只发给明确 opt-in 播客更新的订阅者，且所有渠道都要带嘉宾与主题。

## 1110 · `marketing.press_release_distribution`（断言 18，负 7）

**中文业务请求**

我们要发出 Apex 3.0 发布的新闻稿。传播 VP 发来了关于分发标准的指引。我们还有表格中的媒体跟踪表，PR 代理机构也通过邮件分享了他们的分发名单。发送任何内容前务必核对法律合规准则。

把新闻稿发送给符合条件的媒体，然后向 pr-team@company.example.com 发送分发摘要，列出谁收到了、谁被排除（并说明原因）。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：分发标准（VP 指引）、媒体跟踪表、代理名单、合规准则四源交叉，排除项必须写原因。

## 1120 · `marketing.product_adoption`（断言 14，负 6）

**中文业务请求**

审阅功能采用数据（spreadsheet ID: ss_adoption）。采用跟踪表中还有关于被标记为「请勿联系」账户的备注——外联前务必检查这些标记。联系 MRR 至少 $1,000 且有 2 个或更多未使用功能的账户——他们本应从平台获得更多价值。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：筛选条件是 MRR ≥ $1,000 且未使用功能 ≥ 2，但 do-not-contact 标记账户必须剔除。

## 1610 · `marketing.product_launch_channel_plan`（断言 13，负 2）

**中文业务请求**

我们今天执行 Prism 2.0 的发布传播。已批准的内容在发布内容表格中。落实任何临时变更，并在发布前与各渠道团队协调时间。

对任何无法发布的内容，发邮件到 content-team@company.example.com 申请重新审批。对可以发布的内容，在相应渠道执行。把社交内容发布到我们的 Facebook 页面，并通过 Gmail 发送群发邮件。更新表格中的状态列。

完成后把发布状态摘要发送到 launch-ops@company.example.com。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：先落实临时变更再分发，不可发的回退重审，状态列与结束摘要都要回写。

## 1024 · `marketing.referral_processing`（断言 28，负 12）

**中文业务请求**

处理新的推荐提交。查看推荐表（spreadsheet ID: ss_referrals，worksheet ID: ws_submissions）——对有效的推荐（被推荐人尚未成为客户），把被推荐人加入 HubSpot，并向推荐人发送感谢邮件。在表中标记已处理的推荐。务必使用最新的推荐计划追踪码。查看 HubSpot 中的联系人属性，看是否有特殊处理备注。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：有效性判定（被推荐人非现有客户）、最新追踪码、联系人特殊处理备注三者缺一不可。

## 1030 · `marketing.seasonal_campaign`（断言 11，负 8）

**中文业务请求**

有一个季节性活动即将到来。简报应该就在某处——找到它，并把社交帖子排期到正确的渠道。使用 Buffer 组织 org_001。排期前再核对一下各渠道的准则。

**要点**：简报位置未知需先检索到，Buffer 组织 org_001 与各渠道准则是排期的前提。

## 1043 · `marketing.seo_audit`（断言 12，负 2）

**中文业务请求**

对我们的页面数据（ss_seo / ws_pages）执行 SEO 审计——SEO 负责人上周发来了审计标准，请按那份标准执行。把报告发送给内容团队（content@company.example.com）。开始之前先确认你拿到的是最新上下文。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：审计标准应取 SEO 负责人上周发来的那一份（藏在邮箱或文档里），沿用默认规则就会判错；报告只发给 content@company.example.com。

## 1161 · `marketing.seo_brief_prioritization`（断言 29，负 12）

**中文业务请求**

为 ss_seo_backlog 表格中的落地页准备 SEO 简案。为每个 active 页面挑选最佳主关键词，并把 Status 设为 'Brief Ready'。遵循最新的关键词选择指南，然后发邮件给 seo-lead@company.example.com 说明你所选的关键词。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：只处理 active 页面，关键词按最新指南（而非通用常识）挑选，Status 只能写 'Brief Ready'，选中结果还要发邮件给 seo-lead。

## 1082 · `marketing.seo_competitor_gap`（断言 21，负 5）

**中文业务请求**

查看我们的关键词排名（ss_rankings / ws_data），找出我们在竞争定位上的缺口。把高潜机会排入 ss_backlog / ws_queue，并发布到 #seo-team。团队那边可能有相关的背景信息。在消息中包含受影响实体的名称和相关金额。

**要点**：机会要同时落到 backlog 的排队表和 #seo-team，团队上下文里另有筛选约束；负断言盯的是误排低潜机会与漏发频道。

## 1101 · `marketing.social_audit`（断言 21，负 3）

**中文业务请求**

我们的社交表现怎么样？看一下 ss_social / ws_channels，把发现分享给社交团队。套用任何当前生效的报告准则。计算出的指标四舍五入到两位小数。在消息中包含受影响实体的名称和相关金额。

**要点**：指标必须保留两位小数，且要按当前报告准则出结论并同步给社交团队，而不是只看表。

## 1069 · `marketing.social_benchmark`（断言 52，负 13）

**中文业务请求**

把我们的社交指标与行业基准作对比（spreadsheet ID: ss_benchmark，worksheet ID: ws_data）。同时检查我们应当对标的竞品集合。找出需要改进的方面，并向社交团队发送一份报告。确保遵循最新的报告格式与范围准则。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：52 条断言大多在核对报告格式、对标范围与逐字数值，竞品集合与「范围准则」都必须先从邮件或文档里取到最新版。

## 1185 · `marketing.social_comment_response_queue`（断言 23，负 6）

**中文业务请求**

查看社交收件箱（ss_social / ws_comments），处理所有需要关注的内容。先到邮箱里查升级政策。只对由你升级的评论把 Status 设为 'Escalated'，其余每一行都保持原样，并确保 #social-care 知道任何紧急情况。完成后发一封汇总邮件。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关计数。

**要点**：负断言集中在「别乱改行」——只有真正升级的那几行能写 'Escalated'，其余行必须原封不动；紧急项要通知 #social-care，最后补一封汇总邮件。

## 1102 · `marketing.social_content_calendar`（断言 26，负 10）

**中文业务请求**

规划下周的社交内容日历——做法与上个月相同。遵循社媒经理最新的平台准则。使用内容队列（spreadsheet ID: ss_content，worksheet ID: ws_queue），把已排期的帖子加到内容日历里。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：以 1 月 27 日为基准排「下周」，必须同时满足「与上月同样的做法」和社媒经理最新平台准则，两者都要从历史记录里取。

## 1063 · `marketing.social_contest`（断言 15，负 7）

**中文业务请求**

我们的社媒抽奖活动刚结束。审核参赛记录（ss_contest / ws_entries），把符合资格的移到入围表（ss_finalists / ws_valid）。参赛者必须是关注者才有资格——查 Followers 标签页（ws_followers）。开始前先看抽奖表格里的所有标签页和你的收件箱。

**要点**：资格要拿 ws_followers 交叉核对；「开始前看全部标签页和收件箱」意味着还有额外规则（如重复参赛、地区限制）藏在别的 tab 或邮件里。

## 1143 · `marketing.social_crisis_response`（断言 12，负 1）

**中文业务请求**

我们出了公关状况——负面帖子正在激增。查看危机跟踪表（ss_crisis / ws_posts），并按公关总监上周分享的危机预案处理。把事项分派给正确的团队，并向 comms 通报一份摘要。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：处置动作必须来自公关总监上周的 crisis playbook（不能凭常识），分派对象与 comms 摘要都在断言校验范围内。

## 1003 · `marketing.social_engagement_response`（断言 15，负 8）

**中文业务请求**

过一遍我们近期的 Twitter 提及，按社交互动 SOP 处理。开始前先确认你遵循的是最新准则。

今天是 2026 年 1 月 27 日。在消息中包含相关计数。

**要点**：SOP 有更新版本，必须先取到再动手；每条提及的处置要与 SOP 对应，并报出相关计数。

## 1145 · `marketing.social_mention_response`（断言 14，负 4）

**中文业务请求**

查看尚未回复的社交提及（ss_mentions / ws_unresponded），按社媒负责人分享的优先级规则起草回复。把草稿加到回复队列（ss_responses / ws_queue）。

今天是 2026 年 1 月 27 日。

**要点**：只处理「未回复」的行，草稿要按负责人给的优先级规则写并放进 ws_queue；负断言盯的是改动已回复提及或直接对外发回复。

## 1067 · `marketing.social_roi`（断言 22，负 3）

**中文业务请求**

用表里的数据（spreadsheet ID: ss_social_roi，worksheet ID: ws_data）分析我们的社交媒体表现。为市场总监整理一份报告（director@company.example.com）。遵循当前报告准则。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：ROI 的计算口径与报告准则以当前版本为准，报告只发给 director@company.example.com。

## 1061 · `marketing.social_scheduling`（断言 49，负 28）

**中文业务请求**

把内容表里的每周社交帖子排期到正确的渠道。只排期已经准备好、可以直接发布的帖子。社媒负责人最近可能发过更新，所以务必依据最新指引工作。

使用表格 'Social Content'（ID: ss_social）、工作表 'Posts'（ID: ws_posts）。使用 Buffer 组织 org_001。

**要点**：28 条负断言几乎全在「别多排」——未就绪的帖子一律不许排期，渠道映射与 Buffer 组织 org_001 也必须用对。

## 1100 · `marketing.tam_analysis`（断言 17，负 3）

**中文业务请求**

董事会要一份更新后的市场规模测算。使用市场数据表（spreadsheet ID: ss_market，worksheet ID: ws_tam）。套用我们当前的市场分析方法论。把分析结果发送到 ceo@company.example.com，并附上方法论的 tracking code。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含相关金额和计数。

**要点**：必须附上方法论 tracking code（漏了就过不了断言），且方法论要用「当前」版本，不能沿用旧口径。

## 1087 · `marketing.topic_cluster`（断言 22，负 5）

**中文业务请求**

把我们的内容梳理成主题簇，并把分析结果发给 SEO 团队。数据在 ss_content / ws_pages。翻一下之前的沟通，了解主题簇策略的背景。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：主题簇策略来自既往沟通而非自拟，分簇与命名要能对上历史口径。

## 1046 · `marketing.trending_topic`（断言 13，负 11）

**中文业务请求**

看一下社交聆听数据（ss_social / ws_topics），判断我们应该为哪些主题创作内容。把有潜力的加到 backlog（ss_ideas / ws_backlog），并告知团队。遵循内容运营团队的批量跟踪要求。

另外：我们有一个针对 Compliance Updates 的监管截止日期快到了。还有，我们已经有大量 AI Assistants 相关内容。

**要点**：11 条负断言针对「选题错误」——Compliance Updates 有监管截止日期、AI Assistants 已有大量内容，这两类都不该进 backlog；新增项还要满足内容运营的批量跟踪字段。

## 1121 · `marketing.trial_extension_processing`（断言 20，负 3）

**中文业务请求**

队列里有一批试用延期申请等待处理。按表格 Policy 标签页上的延期政策处理它们。给每个账号发送批准或拒绝邮件，然后给 trial-ops@company.example.com 发一封批量汇总。批准邮件必须以 'Month D' 形式写明新的试用结束日期（例如 'February 15'）。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：批准邮件的日期只能写 'Month D'（如 'February 15'），写成 2026-02-15 就不合格；资格判定依 Policy 页政策，最后必须补发批量汇总。

## 1202 · `marketing.twitter_influencer_followup`（断言 15，负 10）

**中文业务请求**

我们想在 Twitter 上关注相关的行业声音。查一下 @casey_analyst、@casey_analytics、@sam_growth、@jordan_ops、@pat_insights、@alex_data、@alex_dataops、@riley_market、@drew_cx、@morgan_ai、@taylor_saas 和 @kelly_martech，关注其中可信的那些。我们要认证账号且粉丝量真实（至少 10k）。也要看他们的简介——我们只要真正的专业人士。VP Social 可能还标记过额外账号。

**要点**：粉丝数按 ≥10k 判定、必须是认证账号，还要读 bio 排除「名字像同行但实为无关」的号；VP Social 的额外账号线索别漏，handle 高度相似（@casey_analyst vs @casey_analytics、@alex_data vs @alex_dataops）极易串号。

## 1068 · `marketing.ugc_moderation`（断言 15，负 7）

**中文业务请求**

审核审核队列中用户提交的内容（spreadsheet ID: ss_mod，worksheet ID: ws_queue）。批准不提及竞品的正面内容。与我们的屏蔽用户名单交叉核对，不要批准被屏蔽用户的内容。还要检查已批准内容，避免重复提交。把批准的内容加入展示区。内容负责人可能已经分享了本轮的批量细节。另外一件事：@brand_ambassador 是我们的官方品牌大使，所以即使情绪为负面也要一律批准其内容；而来自 @legal_risk_user 的内容一律不批——我们和他们有未决法律纠纷。在消息中包含源数据里的相关金额。

**要点**：两条硬性例外优先于通用规则——@brand_ambassador 无条件批准，@legal_risk_user 无条件拒绝；此外还要查屏蔽名单与重复投稿，金额字段照抄。

## 1182 · `marketing.utm_audit_and_fix`（断言 27，负 10）

**中文业务请求**

审计 'Campaign Links'（ss_utms / ws_links）里的活动链接。标记问题时套用我们当前的审计政策。更新 Status 列，并把问题告知各链接负责人。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关计数。

**要点**：问题判定依「当前审计政策」（UTM 规范可能已更新），Status 是唯一允许改动的列，负责人须按链接归属逐一通知。

## 1080 · `marketing.vendor_management`（断言 18，负 6）

**中文业务请求**

审核营销供应商合同（spreadsheet ID: ss_vendors，worksheet ID: ws_contracts）。找出即将到期的合同，并按我们当前的供应商管理准则采取相应动作。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：「即将到期」的时间窗口和对应的动作等级（续约、重谈、终止提醒）都定义在当前准则里，必须先取到；合同金额照抄。

## 1109 · `marketing.video_repurpose`（断言 18，负 5）

**中文业务请求**

该从我们的网络研讨会录像里剪社交短视频了——视频团队负责人上周发来了标准。查看视频库，把剪辑建议连同平台分配加到剪辑队列。开始前务必检查所有渠道，看有没有制作说明。

今天是 2026 年 1 月 27 日。

**要点**：筛选标准取视频负责人上周那份；「先查所有渠道找制作说明」意味着存在素材不可用或需授权的限制，藏在频道消息里。

## 1095 · `marketing.voice_of_customer`（断言 45，负 19）

**中文业务请求**

处理 ss_feedback / ws_log 中近期的客户反馈。对每条提交做分类，套用当前 VoC 框架对 NPS 分数归类（最新框架更新见 #cx-team），并把它们分派到对应的团队。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含相关计数。

**要点**：NPS 分档阈值必须以 #cx-team 的最新框架为准（默认分档会被负断言打掉）；每条都要分类并分派，同时报计数。

## 1155 · `marketing.webinar_cancellation_workflow`（断言 27，负 2）

**中文业务请求**

明天网络研讨会的讲者失联，我们需要取消这场活动。执行完整的取消流程：通知所有报名者、更新他们的记录、在 Slack 发帖；顺手也把 premium 报名者的退款一并处理掉。

活动总监最近发了取消 SOP，请务必照它执行。报名名单在表格里。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含相关计数。

**要点**：陷阱在「顺手退款」——SOP 才是权威，若 SOP 未授权或规定退款由财务处理，就不能自行退款；通知、记录更新、Slack 发帖与计数四项都要做全。

## 1096 · `marketing.win_loss_analysis`（断言 20，负 4）

**中文业务请求**

分析 'Win Loss Data' 表（ss_deals / ws_data）中的赢单/输单数据。遵循我们的报告要求在格式与分发方面的规定。分析完成后发送。

今天是 2026 年 1 月 27 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：报告格式与分发对象由「报告要求」规定（不能自己挑收件人），金额一律逐字引用。
