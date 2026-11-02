# Automation-Bench 公开集中文翻译 · support（第 1–25 条）

## 1494 · `support.freshdesk_auto_merge`（断言 26，负 3）

**中文业务请求**

我们需要清理 Freshdesk 中的重复工单。使用相似度规则（ss_merge_rules 的 ws_rules）检查重复项，并做相应的合并。注意：只有来自同一请求人（requester）的工单才可能是重复工单。把合并记录写入 ws_log，并向 #support-merges 发布摘要。在你的消息中包含源数据里的相关金额。

**要点**：只有同一 requester 的工单才可判为重复，相似度口径取自 ss_merge_rules/ws_rules，合并须留痕到 ws_log 再播报。

## 1492 · `support.freshdesk_compliance_tagging`（断言 43，负 27）

**中文业务请求**

审计我们 Freshdesk 工单队列中的敏感数据。有一份合规配置表格（ss_compliance）记录了相关规则。标记任何需要关注的内容，记录你的发现，并告警到 #compliance-alerts。

**要点**：敏感判定须逐项对照 ss_compliance 的规则，负断言多达 27 条，说明不能误标本不敏感的工单。

## 1490 · `support.freshdesk_contract_renewal`（断言 30，负 13）

**中文业务请求**

我们需要处理 Freshdesk 中即将到来的合同续约。查看续约排期（ss_renewals 的 ws_schedule），为从今天（2025-01-20）起未来 90 天内到期的合同创建预警工单。务必遵守 DNC 名单（ws_dnc），并通过邮件通知对应的客户经理（account manager）。

今天是 2025 年 1 月 20 日。合同细节与续约日期请参考跟踪记录。

所有邮件发送一律使用 Gmail。

**要点**：90 天窗口以 2025-01-20 为起点计算，且 DNC 名单内的合同必须排除、不得通知。

## 1566 · `support.freshdesk_csat_followup`（断言 37，负 13）

**中文业务请求**

处理最新的 CSAT 调研结果，并根据客户反馈进行跟进。有一份 CSAT 表格包含调研回复，还有定义了按分数采取何种动作的跟进规则（followup rules）——务必查阅它们。跳过已处理的行。向 #customer-success 发布摘要，按严重度层级拆分已处理的结果（使用 'Low: <n>'、'Medium: <n>' 和 'High: <n>' 标签）。该摘要中不要包含被跳过的行。

今天是 2026 年 2 月 7 日。

**要点**：摘要只统计本次实际处理的行（必须排除已处理行），且计数须按 Low/Medium/High 三层用指定标签格式给出。

## 1495 · `support.freshdesk_escalation_matrix`（断言 38，负 4）

**中文业务请求**

我们需要按分级制度升级逾期的支持工单。以当前时间 2025-01-20T12:00:00Z 为基准，对照升级配置（ss_escalation 的 ws_tiers）检查 Freshdesk 中处于打开状态的工单。执行所有必要的升级并通知经理。把结果发布到 #support-escalations。路由规则与升级判定标准请查看我们的跟踪记录。

所有邮件发送一律使用 Gmail。在你的消息中包含受影响实体的名称。

**要点**：逾期判定必须以给定的 2025-01-20T12:00:00Z 作为当前时间，且路由与升级口径要取自跟踪记录而不只是配置表。

## 1415 · `support.freshdesk_faq_drafts`（断言 45，负 20）

**中文业务请求**

我们总是反复收到同一类型的 Freshdesk 工单。你能检查哪些与我们的 FAQ 库匹配，并把草拟回复发送给对的人吗？用 'FAQ match'、'Low confidence' 或 'No FAQ match' 标注你在每张工单上做了什么。在跟踪日志中，准备好的 FAQ 回复用 Action 'Drafted'，没有可安全使用的草稿时用 'Manual Review'。并告知 #support-automation 进展如何。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含源数据里的相关金额。

**要点**：两套词表各有指定用途——工单上用 'FAQ match'/'Low confidence'/'No FAQ match'，跟踪日志的 Action 用 'Drafted'/'Manual Review'，不可混用。

## 1493 · `support.freshdesk_journey_mapping`（断言 36，负 8）

**中文业务请求**

我们需要根据客户的 Freshdesk 工单分析客户旅程。计算方法与工单状态定义在 ws_config 中，生命周期阶段阈值在 ws_rules 中（两者都在 ss_journey 里）。为每个联系人聚合工单数据，按配置计算打开率（open rates），映射到生命周期阶段，更新旅程地图（ws_map），并同步到 HubSpot。向 #customer-success 发布摘要。在跟踪记录中记录客户旅程里程碑。在你的消息中包含源数据里的相关金额。

**要点**：打开率算法与状态定义在 ws_config、阶段阈值在 ws_rules，两处都要读；算完既要回写 ws_map 又要同步 HubSpot。

## 1568 · `support.freshdesk_multi_queue_routing`（断言 35，负 15）

**中文业务请求**

把我们未分配的 Freshdesk 工单路由到正确的支持队列。表格 'ss_customers' 里有客户层级（ws_tiers）和队列路由配置（ws_queue_config）。严格遵循路由规则。为每张已路由的工单添加一条内部备注，说明它被 'routed' 到了它所属的队列。把路由摘要（包含 'routed' 的总数）发布到 #support-routing。

**要点**：只处理未分配工单，摘要里的 'routed' 总数必须与逐条内部备注的数量一致。

## 1450 · `support.freshdesk_onboarding_automation`（断言 26，负 7）

**中文业务请求**

有新的客户通过 Freshdesk 进来，需要做入职（onboarding）。操作手册在表格中（表格 'ss_playbook'，worksheets 'ws_onboarding_steps'、'ws_customer_tiers' 和 'ws_onboarding_log'）——把他们需要的东西都配置好，确保他们的 CSM 被拉进来，并向 #onboarding 发布一条更新，点名每一位已入职的客户。

所有邮件发送一律使用 Gmail。

**要点**：一条更新里必须点名每个已入职客户，且每位客户各自的 CSM 都要通知到，不能统一发一份了事。

## 1437 · `support.freshdesk_reamaze_migration`（断言 34，负 15）

**中文业务请求**

我们正把支持业务从 Freshdesk 迁移到 Re:amaze。迁移规则（ss_migration_rules）里写明了哪些内容符合条件。把所有内容迁移过去，完成后给 support-migration@company.example.com 发一份报告。过程中在跟踪记录里记录你的进度。

所有邮件发送一律使用 Gmail。在你的消息中包含受影响实体的名称。

**要点**：只有满足 ss_migration_rules 条件的记录才迁移，报告须发到指定邮箱，进度要边做边写进跟踪记录。

## 1458 · `support.freshdesk_sla_monitoring`（断言 26，负 12）

**中文业务请求**

今天是 2026-02-07T07:00:00Z。检查我们 Freshdesk 的 SLA 合规情况——规则与升级矩阵在表格中（表格 'ss_sla'，worksheets 'ws_sla_tiers' 和 'ws_escalation_matrix'）。每一张被判定为 approaching、breach 或 critical 的工单都需要一条内部 SLA 备注，使用其矩阵类别词；真正的违约（breach）还应当创建 Jira issue（project 'SUPPORT'，issuetype 'Bug'）。把状态发布到 #sla-dashboard。

所有邮件发送一律使用 Gmail。在你的消息中包含受影响实体的名称。

**要点**：内部备注必须用矩阵给出的类别原词，而只有真正的 breach 才开 Jira（project 'SUPPORT'、issuetype 'Bug'），approaching/critical 不开。

## 1567 · `support.freshdesk_warranty_adjudication`（断言 42，负 11）

**中文业务请求**

处理我们 Freshdesk 队列中的保修索赔。今天是 2026-02-09。对照表格 'ss_products' 中 worksheet 'ws_purchases' 的产品记录，以及 worksheet 'ws_claims' 中的索赔历史，核验每一份索赔。按 worksheet 'ws_policy' 中的保修政策规则做裁决。把结果更新到工单，并把决定记录到 worksheet 'ws_decisions'。摘要发到 #warranty-ops。

**要点**：裁决要同时对齐购买记录与既有索赔历史，判定标准只在 ws_policy，结果须落到工单与 ws_decisions 两处。

## 1466 · `support.freshdesk_zoho_migration`（断言 26，负 10）

**中文业务请求**

我们需要把已解决的 Freshdesk 工单归档到 Zoho Desk。迁移规范（表格 'ss_archive'，worksheets 'ws_archive_rules'、'ws_field_translations' 和 'ws_migration_log'）说明了什么内容去往哪里——保留历史，为每张已迁移的 Freshdesk 源工单打上 'archived' 标签，添加一条内部备注说明已迁移到 Zoho Desk，并把统计发布到 #migration-tracker。

今天是 2026-02-07。在你的消息中包含受影响实体的名称。

**要点**：字段须按 ws_field_translations 做映射，源工单要打 'archived' 标签并留内部备注，整个过程写入 ws_migration_log。

## 1521 · `support.gorgias_channel_consolidation`（断言 37，负 12）

**中文业务请求**

我们在 Gorgias 中不断收到来自不同渠道的重复工单。合并同一客户的工单，保留一张处于打开状态的工单，关闭其余重复工单并附上说明关联关系的备注。把合并记录写入 ss_consol/ws_log。只能按邮箱匹配——同名并不代表是同一客户。

**要点**：只允许按邮箱匹配去重、绝不按姓名，否则会把不同客户误合并。

## 1518 · `support.gorgias_defect_tracking`（断言 34，负 16）

**中文业务请求**

跟踪 Gorgias 中带 'defect' 标签的工单所反映的产品缺陷。对照 ss_defects/ws_catalog 中的产品目录与 ss_defects/ws_known 中的已知缺陷——为新问题提交 Jira bug（project 'QA'），并把一切记录到 ss_defects/ws_log。回复客户，告知跟踪信息。

**要点**：只有 ws_catalog/ws_known 里没有的新缺陷才开 Jira（project 'QA'），已知缺陷不得重复建单。

## 1577 · `support.gorgias_fraud_detection`（断言 33，负 20）

**中文业务请求**

审查 Gorgias 中带 'order-issue' 标签的打开状态工单，看是否存在潜在的欺诈模式。逐张工单对照订单历史（表格 'ss_fraud' 的 worksheet 'ws_orders'）、客户画像（表格 'ss_fraud' 的 worksheet 'ws_profiles'）和调查日志（表格 'ss_fraud' 的 worksheet 'ws_investigations'）。标记可疑工单，添加调查备注，并把发现记录到欺诈日志（表格 'ss_fraud' 的 worksheet 'ws_fraud_log'）。向 #fraud-alerts 发布被标记案例的摘要。

**要点**：可疑判定须跨订单、画像与调查日志三处交叉核对（四个 worksheet 都在 ss_fraud 内），不能只看单一维度就标记。

## 1432 · `support.gorgias_freshdesk_migration`（断言 36，负 18）

**中文业务请求**

我们正从 Gorgias 切换到 Freshdesk。只有处于打开状态的 Gorgias 工单符合条件。有一份迁移政策表格，写明了哪些内容会被迁移以及如何迁移。把符合条件的工单迁移过去，在迁移日志中记录一切，为每张已迁移的 Gorgias 工单添加一条内部消息说明其已迁移，完成后发布到 #support-ops。

**要点**：仅 open 状态的 Gorgias 工单可迁，每张源工单都要留内部消息，且全程写入迁移日志。

## 1579 · `support.gorgias_inventory_routing`（断言 64，负 17）

**中文业务请求**

处理 Gorgias 中处于打开状态的产品咨询工单。我们的库存信息与回复准则在 ss_inventory 表格中——查看哪些有货，并在回复客户时遵循我们的回复政策。把你处理过的每张工单记录到路由日志，并按告警政策把任何库存隐患标记到 #inventory-alerts。回复之前先检查收件箱里是否有相关的履约（fulfillment）更新。在你的消息中包含源数据里的相关金额。

**要点**：回复前必须先查收件箱里的履约更新，库存结论要与 ss_inventory 及告警政策一致，且每张已处理工单都要入路由日志。

## 1580 · `support.gorgias_loyalty_program`（断言 32，负 6）

**中文业务请求**

处理我们 Gorgias 中的会员忠诚度计划工单。用会员表格（ss_loyalty）查客户数据、判断其层级状态，并处理各类请求。把所有操作记录在案，并向会员团队发送摘要。在你的邮件和 Slack 摘要中包含 ws_config 里的 Batch_Reference。

所有邮件发送一律使用 Gmail。

**要点**：Batch_Reference 必须在邮件与 Slack 摘要两处都带上，层级判定以 ss_loyalty 为准。

## 1405 · `support.gorgias_order_lookup`（断言 40，负 14）

**中文业务请求**

处理 Gorgias 中带 'order-inquiry' 标签的打开状态工单：在跟踪表中查订单号（表格 'ss_orders' 的 worksheet 'ws_orders'），核对 VIP 状态（表格 'ss_orders' 的 worksheet 'ws_vip_orders'），并核对已取消订单的退款资格（表格 'ss_orders' 的 worksheet 'ws_refund_policy'）；若某客户的已取消订单符合条件，要告知该客户其具备退款资格。用相应的订单状态信息回复每张工单，并把每一笔成功查询到的订单记录到订单日志（表格 'ss_orders' 的 worksheet 'ws_order_log'），Action Taken 取值为：'Replied with tracking'、'Replied with ship date'、'Replied with refund info' 或 'Escalated to fulfillment'。向 'order-support' 频道发布按订单状态拆分的摘要，每个状态用小写命名（例如：shipped、processing、cancelled 或 backordered）。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含受影响实体的名称。

**要点**：只有成功查询到订单的才入日志，Action Taken 四选一，摘要里的状态名必须小写且与订单真实状态对得上。

## 1469 · `support.gorgias_quality_audit`（断言 26，负 8）

**中文业务请求**

对我们 Gorgias 的支持工单做一次质量审计。评分标准与团队期望记录在质量表格中（表格 'ss_quality'）——找出谁在低于标准，并通过创建一张主题点名该 agent 的 Gorgias 辅导（coaching）工单、同时给该 agent 的团队负责人发邮件来安排辅导。记录每张工单的得分，并把完整评分卡发布到 #quality-assurance。

所有邮件发送一律使用 Gmail。

**要点**：辅导工单的主题必须点名具体 agent，邮件要发给该 agent 的团队负责人，且只为不达标者安排辅导。

## 1425 · `support.gorgias_refund_processing`（断言 63，负 26）

**中文业务请求**

处理我们 Gorgias 工单中的退款请求。退款政策表格（ss_refund_policy）包含你需要的全部规则与订单数据。今天是 2026-02-01。按政策要求处理符合条件的工单，起草 Gmail 确认邮件，或升级为 Jira（project FIN，issuetype Task）。把每一笔记录到退款日志（ws_refund_log），Action 取值为：'Draft'、'Escalated'、'Not Found'、'Expired' 或 'Denied'。向 #finance-ops 发布摘要。另外，在你处理的每张工单上回复一条说明其结果的留言，并针对该结果使用这些词：Draft 用 'confirmation'，Expired 用 'window'，Not Found 用 'not found'，Denied 用 'denied'，Escalated 用 'escalated'。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含源数据里的相关金额。

**要点**：日志的 Action 与工单回复用词是两套固定词表，必须按下标一一映射（Draft→'confirmation'、Expired→'window'、Not Found→'not found'、Denied→'denied'、Escalated→'escalated'），不能混用。

## 1479 · `support.helpcrunch_engagement_scoring`（断言 30，负 13）

**中文业务请求**

依据 HelpCrunch 的活动数据给客户参与度（engagement）打分。用参与度模型（表格 'ss_engagement'，worksheets 'ws_scoring' 和 'ws_tiers'）计算分数并给客户分层。按参与度层级为客户打标签。当某客户新被划入 engaged 或 highly-engaged 层级，或既有层级被降级时，创建 ws_config 的 Engagement_Event——这些才是本次运行中的重要变化。就流失风险（disengaged）账户告警增长团队。把参与度看板发布到 #growth-metrics，并在该帖中包含 ws_config 里的 Batch_Reference。

今天是 2026-02-07。

所有邮件发送一律使用 Gmail。在你的消息中包含源数据里的相关金额。

**要点**：只有「新进入 engaged/highly-engaged」或「既有层级被降级」才算重要变化并写 Engagement_Event，其余变动不得误写；发帖须带 Batch_Reference。

## 1552 · `support.helpcrunch_satisfaction`（断言 33，负 13）

**中文业务请求**

使用 ss_satisfaction/ws_weights 中的事件权重和 ws_thresholds 中的阈值，分析 HelpCrunch 中的客户满意度。识别满意客户，并对不满意的客户做升级处理。查看 ws_plans，找出需要区别对待的企业（enterprise）账户。在每条通知和每条记录中包含 ws_config 里的 Batch_Reference。把你的分析结果记录到跟踪记录中。

所有邮件发送一律使用 Gmail。

**要点**：权重取自 ws_weights、阈值取自 ws_thresholds，企业账户要走 ws_plans 的差异化处理，且每条通知与记录都必须带 Batch_Reference。

## 1549 · `support.helpcrunch_trial_nurture`（断言 29，负 10）

**中文业务请求**

跟进我们在 HelpCrunch 中的试用期客户，帮助他们走完入职（onboarding）流程。用培育表格（ss_nurture）获取里程碑定义与邮件模板。对卡住的试用按情况跟进。今天是 2026-02-07。

所有邮件发送一律使用 Gmail。

**要点**：里程碑定义与邮件模板都取自 ss_nurture，且只对「卡住」的试用按对应里程碑跟进，模板不可张冠李戴。

## 1545 · `support.helpcrunch_usage_alerts`（断言 64，负 38）

**中文业务请求**

检查 HelpCrunch 各客户的产品使用情况。有一张 usage 表格，里面配置了阈值和告警规则，覆盖各客户类型的分类与处置动作。请按规则执行。

今天是 2026-02-07。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含源数据中的相关金额。

**要点**：告警分级与动作必须严格按 usage 表中的阈值和客户类型规则匹配，漏报或误报（该静默却告警）都算错——负断言多达 38 条。

## 1480 · `support.helpcrunch_zoho_desk_bridge`（断言 25，负 8）

**中文业务请求**

我们有一部分 HelpCrunch 客户的问题需要镜像同步到 Zoho Desk。有一张 bridge 配置表（ss_bridge），定义了事件如何映射到工单——请处理对应的客户，在 Zoho Desk 账号和联系人不存在时创建匹配的记录，并向 #enterprise-support 发布一条 bridge 更新。

今天是 2026 年 02 月 07 日。

**要点**：只有 ss_bridge 覆盖的客户才应同步（负断言针对多处理了不该动的客户），且要按事件→工单的映射先补建 account 与 contact 再建单。

## 1515 · `support.helpscout_auto_categorization`（断言 30，负 13）

**中文业务请求**

我们有些 HelpScout 会话可能需要更好的分流。某处有一张包含分类定义的表格（ss_categories）——请找出哪些需要处理，并确保对应的渠道知晓。

**要点**：分类定义需自行在 ss_categories 中定位，只对确实分类错误的会话动手，改动面过大或不相关渠道乱报会被负断言抓住。

## 1575 · `support.helpscout_cross_team_handoff`（断言 38，负 10）

**中文业务请求**

处理所有打了 'handoff-requested' 标签的 HelpScout 会话。查看 handoff 策略表（ss_handoff，工作表 ws_routing）中的路由规则并逐条评估。把有效的转交移动到正确的邮箱，添加转交备注，对无效或无匹配的请求做相应处理，并为每一次已处理的转交通知 #support-handoffs。

所有邮件发送都使用 Gmail。在消息中包含受影响实体的名称。

**要点**：打了标签不等于有效——须按 ws_routing 判定，「无效」与「无匹配」要有各自处置方式，且每次转交都要单独发频道通知。

## 1573 · `support.helpscout_customer_effort`（断言 32，负 12）

**中文业务请求**

根据我们的 HelpScout 会话计算客户费力程度（customer effort）分数。考察回复次数、会话线程长度，以及客户是否不得不就相似话题反复开启多个会话。把 effort 分数记录到跟踪表（ss_effort，工作表 ws_scores），给高费力客户打标签，向体验不佳的客户发送关怀邮件，并把 effort 报告发布到 #cx-insights。摘要中要包含 ws_config 里的 Report_Reference。

所有邮件发送都使用 Gmail。

**要点**：分数由回复数、线程长度、重复开相似话题三个维度算出；只有越过阈值的才打标签并发邮件，摘要必须带 Report_Reference。

## 1511 · `support.helpscout_customer_merge`（断言 30，负 14）

**中文业务请求**

我们的 merge 表格里有一批疑似重复的客户。你能过一遍，把确实是同一个人的清理掉吗？留下操作痕迹，让我们知道发生了什么，并更新 #data-quality。在消息中包含源数据中的相关金额。

**要点**：「疑似」不等于「重复」——必须逐条核实身份后才合并，把同名的不同人合并正是负断言的目标，且每步都要留可追溯记录。

## 1431 · `support.helpscout_daily_digest`（断言 36，负 14）

**中文业务请求**

该做每日支持摘要了。拉取当前的 HelpScout 会话数据，把摘要分发给正确的渠道和人。

今天是 2026 年 02 月 07 日。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。

**要点**：分发对象与渠道要按配置精确匹配（多发、漏发都会命中负断言），数值必须原样搬运，不得四舍五入或改写。

## 1514 · `support.helpscout_health_sync`（断言 34，负 15）

**中文业务请求**

用 ss_health/ws_activity 中的活跃度数据和 ss_health/ws_rules 中的健康度规则，把 HelpScout 客户数据同步到 Salesforce。将客户与 SF 联系人匹配，并据此更新。把同步结果发布到 #support-sync。摘要中包含 ws_config 里的 Batch_Reference。过程中要把进度记录到跟踪记录里。在消息中包含源数据中的相关金额。

**要点**：健康度分级必须套用 ws_rules，匹配不到联系人的客户不能硬塞；进度要边做边记，摘要需带 Batch_Reference。

## 1468 · `support.helpscout_hubspot_deal_alerts`（断言 30，负 15）

**中文业务请求**

我要确保支持侧的问题不会拖垮我们进行中的商机。用表格 'ss_deal_alerts' 中的告警配置，把 HelpScout 会话与 HubSpot 商机做交叉比对，把销售需要知道的情况标出来。把告警发布到 #sales-support。

今天是 2026-02-07。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含源数据中的相关金额。

**要点**：只对「未关闭商机」且命中 ss_deal_alerts 配置条件的会话告警；关联到错误商机或对已关单告警都算错。

## 1404 · `support.helpscout_jira_bugs`（断言 42，负 20）

**中文业务请求**

过一遍 HelpScout 会话，把所有 bug 报告分诊进 Jira。有一张分诊策略表（ss_triage_policy）写明了规则。给已处理的会话打标签，记下 Jira 引用，完成后向 #engineering 发布摘要。

今天是 2026 年 02 月 07 日。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含受影响实体的名称。

**要点**：什么算 bug、按什么优先级与项目建单都要照 ss_triage_policy，非 bug 会话不得建单（负断言多达 20 条），且需回写 Jira 引用并打标签。

## 1574 · `support.helpscout_kb_feedback`（断言 32，负 11）

**中文业务请求**

检查我们的 HelpScout 会话，寻找知识库改进信号。当客服不得不给出本应写入文档的详细解释时，在 Jira 的 DOCS 项目中创建 issue，并给这些会话打上 'kb-gap' 标签。把提到文档内容过时的会话打上 'outdated-docs' 标签。把发现记录到 KB 跟踪表（ss_kb，工作表 ws_findings），按情况把每行的 Type 记为 'KB Gap' 或 'Outdated Docs'，并向 #docs-team 发布摘要。摘要中包含 ws_config 里的 Batch_Reference。在消息中包含受影响实体的名称。

**要点**：两类信号要分别打不同标签、写不同 Type；只有「本应沉淀成文档」的解释才建 Jira issue，普通解释性回复不算缺口。

## 1452 · `support.helpscout_knowledge_gap_analysis`（断言 33，负 17）

**中文业务请求**

我想知道，根据客户在 HelpScout 里问的内容，我们的知识库在哪些地方覆盖不足。有一张 KB 覆盖跟踪表，里面有我们现有的文章，还有一张缺口跟踪表。针对缺失的内容为内容团队创建 Jira 工单（项目 'DOCS'，issuetype 'Story'），发邮件给 content-lead@company.example.com，并把发现发布到 #knowledge-base。

所有邮件发送都使用 Gmail。在消息中包含相关计数。

**要点**：缺口判定要拿客户真实提问去比对现有文章（不能只靠关键词重复就下结论），Jira 必须是 DOCS 项目下的 Story 类型，邮件与频道消息都要带计数。

## 1476 · `support.helpscout_reamaze_migration`（断言 27，负 6）

**中文业务请求**

我们正在统一迁移到 Re:amaze——请迁移迁移状态映射所覆盖的、未关闭的 HelpScout 会话。迁移手册（表格 'ss_migration'，工作表 'ws_status_map' 和 'ws_category_map'）说明了各项应如何转换。必要时创建对应的 Re:amaze 联系人。在每条已迁移的 HelpScout 会话上留一条内部备注，说明已 'migrated' 到 Re:amaze，然后关闭源会话。确保迁移过程中不丢任何东西，并把进度发布到 #migration-status。在消息中包含受影响实体的名称。

**要点**：只迁移「未关闭且被 ws_status_map 覆盖」的会话，必须先留内部备注再关闭源会话，状态与分类要分别按两张映射表转换。

## 1509 · `support.helpscout_response_audit`（断言 26，负 12）

**中文业务请求**

对 HelpScout 会话回复做一次质量审计。按 ss_audit（工作表 ws_criteria）中的标准检查回复，给存在问题的会话打上 'quality-issue' 标签，把违规记录写入 ws_log，并把报告邮件发送到 quality@ourcompany.example.com。审计时跳过自动回复/机器人回复。

所有邮件发送都使用 Gmail。

**要点**：审计必须排除自动/机器人回复（把它们判成违规就是负断言），且每个问题都要在 ws_log 落一行记录。

## 1413 · `support.helpscout_weekly_report`（断言 38，负 15）

**中文业务请求**

今天是 2026-02-09。你能用我们的 HelpScout 数据整理出本周的支持报告吗？把各项数字记录到报告表格（ss_reports，工作表 ws_weekly），把报告邮件发送到 support-lead@company.example.com，并在 #support-metrics 发一份摘要，按邮箱分别列出明细。务必遵循任何报告偏好设置。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：统计周期要按「本周」界定，频道摘要必须按邮箱分拆成明细，且可能存在的额外报告偏好（口径、命名等）必须遵守。

## 1559 · `support.hiver_coaching_pipeline`（断言 27，负 19）

**中文业务请求**

用 ss_coaching/ws_roster 中的花名册评估 Hiver 客服，判断是否需要辅导。按我们的辅导标准找出表现不佳者，把建议记录到 ws_recommendations，并给他们的主管发邮件。所有解决率都用整数百分比表示，四舍五入到最接近的整数。

所有邮件发送都使用 Gmail。在消息中包含受影响实体的名称和相关金额。

**要点**：只评估花名册内的人（负断言针对名单外或不该点名的人），解决率须四舍五入到整数百分比，且只给不佳者的主管发信。

## 1553 · `support.hiver_cross_team_handoff`（断言 32，负 14）

**中文业务请求**

检查我们未关闭的 Hiver 会话，判断哪些需要转给专业团队。转交规则和团队联系信息在我们的路由表格里。把所有候选都记录下来，联系对应的负责人，并把摘要发布到 handoffs 频道。在通知中包含 ws_config 里的 Batch_Reference。

所有邮件发送都使用 Gmail。

**要点**：所有候选都要登记（包括最终未转交的），只有命中规则并找对团队负责人的才发转交，通知须带 Batch_Reference。

## 1448 · `support.hiver_csat_analysis`（断言 35，负 11）

**中文业务请求**

我们需要根据客户满意度调研了解支持客服的表现。数据在我们的 CSAT 表格里——把调研回答与客服归属、花名册做交叉比对，算出每位客服的表现。任何低于预期的人都应被点名。在结果表中把这些客服的 Status 记为 'flagged'，并把 Average_CSAT 写成一位小数。为花名册上的每位客服都记录一条，给支持运营团队发一封逐人摘要邮件（包含每位客服保留一位小数的平均值），并把亮点发布到我们的指标频道。摘要邮件和亮点帖子中都要包含 ws_config 里的 Report_Reference。

所有邮件发送都使用 Gmail。在消息中包含源数据中的相关金额。

**要点**：结果表要覆盖全部花名册成员（不只不达标者），只有低于预期者标 'flagged'，均值统一保留一位小数，Report_Reference 在邮件与帖子两处都要带。

## 1558 · `support.hiver_escalation_patterns`（断言 36，负 13）

**中文业务请求**

我们在已升级的 Hiver 会话里看到一些反复出现的主题。有一张模式定义表（ss_patterns），应该能帮你对它们分类。记录你的发现，对其中严重的创建工单，并把分析分享到 ops 频道。

**要点**：模式识别与「严重」判定都要按 ss_patterns 的定义，只有达到严重级别的才建工单，无谓升级会被负断言抓住。

## 1427 · `support.hiver_inbox_report`（断言 44，负 23）

**中文业务请求**

今天是 2026-02-08。从 Hiver 共享收件箱出一份报告——把所有内容记录到收件箱报告表（ss_inbox_report），把摘要发布到 #support-metrics，并把任何需要分诊的内容标记到 #support-triage。查看报告表里是否有特殊规则。注意：下季度计划把收件箱迁移到新平台——目前可以忽略这件事。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：报告表内的特殊规则优先于默认动作；「下季度迁移」是干扰项、不应写入报告；需分诊项要单独进 #support-triage 而非混在摘要里。

## 1554 · `support.hiver_mailbox_audit`（断言 27，负 10）

**中文业务请求**

合规团队要对共享邮箱做一次健康检查。审计标准在审计表格里。检查处于活跃状态的会话，记录你发现的任何问题，并把报告发送给合规团队。

所有邮件发送都使用 Gmail。

**要点**：只审计「活跃」会话（已关闭的不动），问题判定照审计表标准，报告收件人须为合规团队。

## 1596 · `support.hiver_quality_coaching`（断言 40，负 20）

**中文业务请求**

对我们的 Hiver 支持会话做一次质量评审。辅导跟踪表里有你需要的全部内容——规则、现有计划和 CSAT 数据。记录结果并分享发现。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含受影响实体的名称。

**要点**：要结合表中已有的辅导计划，避免对已辅导对象重复建档或重复推送（重复即命中负断言）；规则与 CSAT 都取自同一张辅导跟踪表。

## 1594 · `support.hiver_response_sla`（断言 32，负 9）

**中文业务请求**

对照 ss_sla/ws_targets 中的 SLA 目标检查我们的 Hiver 响应时间。检查时要把 ws_tiers 里的客户层级纳入考虑。标记所有违约情况，并按需升级。把合规报告发布到 #sla-monitoring。报告中要包含 ws_config 里的 Report_Reference。当前政策与阈值请参考我们的跟踪记录。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含源数据中的相关金额。

**要点**：SLA 目标随客户层级不同，必须套用 ws_tiers；升级所需阈值要取自跟踪记录中的最新政策，不能只按表内默认值。

## 1472 · `support.hiver_slack_digest`（断言 30，负 9）

**中文业务请求**

今天是 2026 年 02 月 10 日。用 Hiver 的数据整理今天的支持摘要。模板和收件人名单都在表里（表格 'ss_digest'，工作表 'ws_categories'、'ws_recipients' 和 'ws_digest_log'）——对所有内容进行分类，通知对应的人，并把摘要发布到 #daily-digest。

所有邮件发送都使用 Gmail。在消息中包含相关计数。

**要点**：收件人要按 ws_recipients 与类别一一对应（不能群发或漏发），摘要须按模板填写并记入 ws_digest_log。

## 1456 · `support.hiver_team_performance`（断言 30，负 10）

**中文业务请求**

我需要一份基于 Hiver 会话的支持团队绩效报告。基准和目标在表里（表格 'ss_performance'，工作表 'ws_benchmarks' 和 'ws_goals'）——表彰表现突出者，并标记任何需要辅导的人。把花名册上的每位客服都记录到 ws_results_log。给每位突出者发一封表彰邮件，并为每位表现不佳者的主管创建 Gmail 草稿；不要发送主管辅导邮件。把排行榜和 ws_config 里的 report_tracking_code 发布到 #support-team。所有成交率都用截断后的整数百分比表示（例如 41.7% 记为 41%）。

所有邮件发送都使用 Gmail。在通知或记录中引用源数据里的数值时，要原样保留（不要改写措辞，也不要四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：主管辅导邮件只创建草稿、绝不能发送；成交率是截断而非四舍五入（41.7% → 41%）；ws_results_log 要覆盖全部花名册成员。

## 1557 · `support.hiver_workload_forecast`（断言 29，负 14）

**中文业务请求**

使用 ss_workload/ws_baselines 里的容量基线，基于 Hiver 对话预测客服工作量。把利用率记录到 ws_forecast，并针对超负荷的客服向团队负责人告警。告警中要带上 ws_config 里的 Report_Reference。

所有邮件发送一律使用 Gmail。消息中要包含受影响实体的名称以及相关金额。

**要点**：是否「超负荷」必须用 ws_baselines 的容量基线换算利用率，不能凭对话条数直觉判断；告警里漏掉 Report_Reference 或对未超载的客服也告警，都会被负断言判错。

## 1506 · `support.intercom_auto_response_drafts`（断言 30，负 14）

**中文业务请求**

我们要为处于 open 状态的 Intercom 对话生成自动回复草稿。表格 'ss_templates' 里有一份模板映射——把对话匹配到正确的模板，并创建发给该 Intercom 联系人的 Gmail 草稿，主题使用对话标题。每创建一份草稿，都要为该 Intercom 联系人添加一条备注。每份草稿/备注里都要包含 ws_config 中的 Batch_Reference。把源数据里的值写进通知或记录时，要原样保留（不要改写或四舍五入）。消息中要包含受影响实体的名称以及相关计数。

**要点**：草稿主题必须用对话标题（不能自拟），收件人取 Intercom 联系人；草稿与对应的联系人备注成对出现，且两者都要带同一个 Batch_Reference。

## 1572 · `support.intercom_conversation_quality`（断言 32，负 12）

**中文业务请求**

审计至少包含一条面向客户的客服回复的 open 状态 Intercom 对话；忽略已关闭的对话、没有任何客服回复的对话，以及只有内部备注的对话。从有用性与完整性两方面审查客服回复，把既有用又完整的对话标记为 'quality-high'，把有欠缺的标记为 'quality-low'，必要时补写辅导备注，把评分记录到我们的质量跟踪表（ss_quality），并把客服绩效汇总发到 #quality-review，其中要带上审计配置工作表里的 Batch_Reference。有用性按我们的标准判定——要有得体的问候语以及完整的信息——并在每条辅导备注里点明未达标的那一项。

今天是 2026 年 2 月 07 日。

**要点**：入审范围是「未关闭 + 至少一条面向客户的客服回复」，纯内部备注的对话不算；判定只有「问候语」和「细节完整」两条标准，辅导备注必须点名缺的是哪一条。

## 1412 · `support.intercom_demo_scheduling`（断言 58，负 28）

**中文业务请求**

我们需要处理通过 Intercom 进来的 demo 申请。用排期策略表（ss_demo_policy）判断谁符合资格。为通过的人预订日历事件，把结果告知每一位申请人，最后用 Slack 汇总收尾。把源数据里的值写进通知或记录时，要原样保留（不要改写或四舍五入）。消息中要包含源数据里的相关金额。

**要点**：资格门槛完全以 ss_demo_policy 为准（多条件叠加，错一条即整条判错）；不合规的人也要收到结果通知，只是不发日历邀请。

## 1503 · `support.intercom_feature_request`（断言 32，负 13）

**中文业务请求**

处理带 'feature-request' 标签的 Intercom 对话。用表格 'ss_features'（工作表 'ws_areas'、'ws_log'、'ws_blocklist'）对请求分类，把它们记录下来，在适当情况下创建 Jira story，并回复提出请求的人。把结果发到 #product-feedback。汇总消息里要包含 ws_config 中的 Batch_Reference。消息中要包含受影响实体的名称以及相关金额。

**要点**：ws_blocklist 命中的请求不得建 Jira story（只能记录并回复），分类必须落到 ws_areas 的领域；汇总里要带 Batch_Reference。

## 1423 · `support.intercom_freshdesk_escalation`（断言 56，负 26）

**中文业务请求**

执行 Intercom 到 Freshdesk 的 L2 升级流程。策略表（ss_escalation_config）里有你需要的全部信息。对每一条被升级的 Intercom 对话都回帖确认其升级。把结果发到 #escalation-log。消息中要包含源数据里的相关金额。

**要点**：只有满足配置里 L2 升级条件的对话才升级，且每条被升级的对话都必须回帖留痕；升级对象与目标队列按配置走，不能一律升级。

## 1570 · `support.intercom_multi_product_routing`（断言 41，负 26）

**中文业务请求**

把我们处于 open 状态的 Intercom 对话路由到正确的产品支持团队。查看产品权益表（ss_entitlements，ws_products），核实每个客户的公司实际拥有哪些产品的访问权限，并按照 ws_routing_rules 里的路由规则来决定每种情形该如何打标签和处理。同时检查是否存在可适用的已批准升级覆盖。据此回复对话。完成后把路由汇总发到 #support-routing。

**要点**：必须按客户公司「实际购买的权益」路由（而不是对话里声称的产品）；已批准的升级覆盖优先于常规路由规则，覆盖匹配不上才走默认路径。

## 1571 · `support.intercom_reactivation_campaign`（断言 38，负 16）

**中文业务请求**

为沉睡的 Intercom 联系人执行季度唤回活动。用唤回策略表（ss_reactivation，ws_activity）取活动历史，并使用排除名单（ws_dnc、ws_recent_outreach、ws_active_subs）。把符合条件的联系人按 ws_spend_history 中的消费档位分层，发送相应的外联邮件，给每个已发送的联系人打上 'reactivation-sent' 标签，记录到 ws_outreach_log，并把结果发到 #reactivation-campaign。汇总里要包含 ws_config 中的 Batch_Reference。

所有邮件发送一律使用 Gmail。消息中要包含源数据里的相关金额。

**要点**：三张排除表任一命中（勿扰、近期已触达、仍在订阅）都不得发送；分层只依据 ws_spend_history 的消费档位，发送后必须打标签并写日志。

## 1502 · `support.intercom_sentiment_escalation`（断言 32，负 19）

**中文业务请求**

用表格 'ss_sentiment'（工作表 'ws_rules'）里的策略规则，升级被打上负面标签的 Intercom 对话。按需指派对话、添加备注并创建 issue。把汇总发到 #escalations。消息中要包含源数据里的相关金额。

**要点**：只处理负面情绪标签的对话（正面/中性不得升级）；指派对象、备注内容与是否建 issue 由 ws_rules 的条件组合决定。

## 1475 · `support.intercom_sf_opportunity_alerts`（断言 30，负 15）

**中文业务请求**

持续关注 Intercom 对话中任何可能影响我们 open 状态 Salesforce 商机的内容。表格 'ss_signals' 里有一份信号配置，说明了要盯哪些信号。采取相应行动，并把信号报告发到 #revenue-ops。

所有邮件发送一律使用 Gmail。消息中要包含受影响实体的名称。

**要点**：只对关联到 open 商机的信号动作，已关闭/赢单输单的商机不报；触发动作与否取决于 ss_signals 的配置，不是所有对话都要发邮件。

## 1451 · `support.intercom_usage_health_scoring`（断言 30，负 16）

**中文业务请求**

结合 Intercom 对话数据与分析表格里的用量指标（表格 'ss_health'，工作表 'ws_usage_data' 与 'ws_scoring_model'）给客户健康度打分。按健康状态给联系人打标签，为有风险的账户创建工单，并提醒 CSM 团队。如果某个联系人的公司在用量数据里没有对应行，就给它打 'unknown' 标签、把它排除在健康分布之外，且不要把分数推定为 0。把健康分布发到 #customer-health，其中要包含评分配置工作表里的 batch_tracking_code。

所有邮件发送一律使用 Gmail。消息中要包含源数据里的相关金额。

**要点**：缺用量数据的公司标 'unknown'、不进分布，绝不能按 0 分计算（这是最容易被负断言抓到的点）；分布帖要带 batch_tracking_code。

## 1419 · `support.intercom_winback`（断言 43，负 19）

**中文业务请求**

针对已流失客户执行一轮唤回邮件活动。先从 Intercom 拉取联系人，再查勿扰名单与客户历史两张表，按活动设置判断谁符合条件、该发哪一档优惠。今天是 2026-02-05。给已发送的联系人在 Intercom 里打上 'win-back-sent' 标签，把外联记录写入历史表，并把汇总发到客户成功频道。

所有邮件发送一律使用 Gmail。把源数据里的值写进通知或记录时，要原样保留（不要改写或四舍五入）。消息中要包含源数据里的相关金额。

**要点**：资格与优惠档位同时受勿扰名单和客户历史约束，「流失」的判定以 2026-02-05 为基准日；发送后必须打 'win-back-sent' 并写历史表。

## 1598 · `support.intercom_zoho_customer_360`（断言 33，负 14）

**中文业务请求**

我们需要一个把各支持平台数据合并起来的统一客户视图。策略表（ss_customer360）描述了如何匹配与合并记录。构建客户档案，把任何需要关注的问题标出来，并把结果同步给客户团队。把源数据里的值写进通知或记录时，要原样保留（不要改写或四舍五入）。消息中要包含源数据里的相关金额。

**要点**：跨平台同一客户的匹配与字段合并规则完全依 ss_customer360，不能重复建档；对不上的记录要单独标记，不能强行合并。

## 1533 · `support.reamaze_campaign_tracking`（断言 30，负 16）

**中文业务请求**

市场部想要基于 Re:amaze 对话的活动归因数据。查看 ss_campaigns/ws_rules 里的活动配置，判断哪些对话属于哪些活动，并把所有内容持续跟踪起来。通知 #marketing-ops。今天是 2025-01-15。请查看跟踪记录中的活动归因数据。

**要点**：归因要用 ss_campaigns/ws_rules 的匹配规则（时间窗、关键词等），日期基准 2025-01-15；每条对话的归因都要落进跟踪记录，不能只报个总数。

## 1530 · `support.reamaze_cross_platform_dedup`（断言 36，负 11）

**中文业务请求**

在 Re:amaze 与 Freshdesk 之间做去重。找出同一客户就同一问题提交的对话与工单，用一条交叉引用备注关闭 Re:amaze 一侧，并给 Freshdesk 工单补一条对应的内部备注，其中要包含 Re:amaze 对话 ID，最后记录到 ss_dedup/ws_log。有些客户使用多个邮箱地址——请查 ss_dedup/ws_aliases 里的已知别名。

**要点**：同一客户可能有多个邮箱，必须借助 ws_aliases 才能认出重复；两侧备注要互相引用，Freshdesk 的内部备注里必须写明 Re:amaze 对话 ID。

## 1531 · `support.reamaze_feedback_sentiment`（断言 32，负 12）

**中文业务请求**

用 ss_sentiment/ws_rules 里的关键词规则，对未解决的 Re:amaze 对话做情感分析。给对话打上对应情感标签，把令人担忧的对话按规则路由到合适的人，并把结果记录到 ss_sentiment/ws_analytics。

**要点**：只处理未解决的对话；情感判定必须按关键词规则匹配（不能凭主观语感），被判定为需要关注的对话要路由并写入分析表。

## 1446 · `support.reamaze_intercom_migration`（断言 31，负 12）

**中文业务请求**

我们要更换支持平台了。有一份迁移配置表（ss_migration），里面写明了要迁移什么、怎么迁。请确保不丢失任何重要内容，并在 Slack 里持续向团队同步进展。消息中要包含受影响实体的名称。

**要点**：迁移对象、字段映射与顺序都以 ss_migration 为准，「不丢重要内容」意味着配置里列出的每一类对象都要迁到，不能只迁对话本身。

## 1600 · `support.reamaze_intercom_sync`（断言 39，负 17）

**中文业务请求**

在 Re:amaze 与 Intercom 之间同步对话。查看 ss_sync/ws_tracker 里的同步跟踪表，确认哪些已经同步过，并处理所有新增或有更新的对话。按 ws_priority 里的优先级规则处理冲突，并把同步报告发到 #platform-sync。过程中要随做随把进度写进跟踪记录。把源数据里的值写进通知或记录时，要原样保留（不要改写或四舍五入）。消息中要包含受影响实体的名称以及相关金额。

**要点**：先查跟踪表避免重复同步；两侧数据冲突时以 ws_priority 的优先级裁决（不是「后写覆盖先写」）；进度要边做边回写，不能只在最后补记。

## 1527 · `support.reamaze_knowledge_routing`（断言 39，负 8）

**中文业务请求**

用我们的领域映射表，把 Re:amaze 对话路由给知识领域专家。指派给正确的专家，打上领域标签，并把相关的 KB 文章链接分享给客户。

**要点**：指派对象与标签都来自领域映射表（领域判定错则专家也错）；除了指派，还必须把对应领域的 KB 文章链接发给客户。

## 1528 · `support.reamaze_lifecycle_tagging`（断言 36，负 16）

**中文业务请求**

用 HubSpot 里的客户生命周期信息给 Re:amaze 对话打标签。按我们的生命周期映射表确定正确的标签，并给每条对话补一条上下文备注。

**要点**：标签需按映射表把 HubSpot 生命周期阶段转换成目标标签（不能原样照抄英文阶段名），且每条对话都要有上下文备注。

## 1584 · `support.reamaze_multi_channel_dedup`（断言 31，负 5）

**中文业务请求**

客户正通过 Re:amaze 的多个渠道重复提交同一问题，产生了重复项。联系人映射在 ss_contacts 里。请清理这些重复项，并告诉 #support-dedup 你合并了哪些，汇总里要使用 'merged' 这个词，同时带上跟踪表 Config 工作表中的 Batch_Reference。务必在跟踪记录里记录所有变更。消息中要包含源数据里的相关金额。

**要点**：跨渠道的同一客户要靠 ss_contacts 识别；汇总里必须出现 'merged' 字样并带 Config 工作表的 Batch_Reference，且每笔合并都要写进跟踪记录。

## 1529 · `support.reamaze_multilanguage`（断言 32，负 11）

**中文业务请求**

用 ss_lang/ws_teams 把 Re:amaze 对话路由到正确的语言支持团队。把每条对话指派给相应语种的客服并打上对应标签。受支持的语言使用 'routed-{language_code}' 形式的标签（例如 'routed-en'、'routed-es'、'routed-fr'），不在支持列表里的语言则用 'unsupported-language'。语言路由规则请参考跟踪记录。对每一种不受支持的语言，都要添加一条内部留言，说明需要翻译。

**要点**：标签必须严格是 'routed-<语言码>' 形式，不受支持的语言统一打 'unsupported-language' 并附内部留言说明需翻译，不能自行扩展语言列表。

## 1478 · `support.zendesk_automated_responses`（断言 29，负 8）

**中文业务请求**

我们要为新进的 Zendesk 工单自动发出回复。模板与条件都在表格里（表格 'ss_templates'，工作表 'ws_templates' 与 'ws_conditions'）——把工单匹配到正确的回复，并妥善处理那些不该自动回复的情况。给每一张收到自动回复的工单打上 'auto-responded' 标签。把统计发到 #auto-response，其中要包含 ws_config 里的 Batch_Reference。消息中要包含源数据里的相关金额。

**要点**：ws_conditions 的排除条件优先（例如升级中、需人工处理的情形不得自动回复）；只有真发了自动回复的工单才打 'auto-responded'。

## 1483 · `support.zendesk_cross_org_merge`（断言 32，负 6）

**中文业务请求**

我们有一批重复的 Zendesk 组织需要合并。用 ss_merge（ws_candidates）里的合并候选来合并它们，但跳过勿合并名单（ws_dnm）上的任何组织。每次允许的合并完成后，给源组织打上 'merged-archived' 标签，并在目标组织上添加备注，注明被并入的源组织。把结果记录到 ws_results，并把汇总发到 #ops-merges，其中要包含 ws_config 里的 Batch_Reference。消息中要包含受影响实体的名称以及相关金额。

**要点**：ws_dnm 上的组织一律不许合并；合并后源组织打 'merged-archived'、目标组织备注里点名源组织，源与目标的处理不能颠倒或遗漏。

## 1473 · `support.zendesk_customer_360`（断言 26，负 14）

**中文业务请求**

我们的 Zendesk 组织档案需要用 HubSpot 数据来补充。补充规格（表格 'ss_enrichment'，工作表 'ws_field_mapping' 与 'ws_enrichment_rules'）里有映射细节——把空缺的字段填上，并把对不上的地方标出来。把差异报告发到 data-quality@company.example.com，并把统计发到 #crm-ops。

所有邮件发送一律使用 Gmail。消息中要包含受影响实体的名称。

**要点**：只补空字段并按 ws_enrichment_rules 转换，绝不覆盖已有值；与 HubSpot 不一致的数据要单独成差异报告发到 data-quality@company.example.com，而不是直接改掉。

## 1563 · `support.zendesk_customer_sentiment`（断言 32，负 9）

**中文业务请求**

审查我们处于 open 状态的 Zendesk 工单，根据客户的感受把需要特别关注的工单标出来。把负面的特别关注工单打上 'retention-risk' 标签，正面的打上 'success-story' 标签。视情况调整优先级与路由。到情绪配置表（表格 ss_config，工作表 'ws_config'）查看报告参数，带上其中的 Batch_Reference 值，并把情绪汇总发到 #customer-health，汇总里要点名每一位其工单获得特别关注标签的请求人。对每一张特别关注工单，还要添加一条内部评论，记录其情绪与问题主题（例如 outage 或 billing）。

**要点**：标签方向必须与情绪一致（负→'retention-risk'、正→'success-story'），汇总要点名所有获批特别关注标签的请求人，且每张此类工单都要有记录情绪与主题的内部评论。

## 1489 · `support.zendesk_data_quality`（断言 29，负 14）

**中文业务请求**

我们的 Zendesk 数据质量一直在下滑——用 ss_quality（ws_rules）里的规则跑一次审计。给有问题的工单打上标签，把它们记录到 ws_log，并把报告发到 data-team@company.example.com。

所有邮件发送一律使用 Gmail。消息中要包含相关计数。

**要点**：审计口径只能取自 ws_rules，打标签、写日志、发报告三件事都要落齐，邮件里不能漏掉计数。

## 1562 · `support.zendesk_escalation_waterfall`（断言 37，负 8）

**中文业务请求**

处理 Zendesk 中标记为待复核的工单。查看升级跟踪表（表格 'ss_escalation'，工作表 'ws_history'）里的既往升级记录，对已经具备条件的工单推进到下一层级。在每一张被推进的工单上添加一条内部评论，注明目标层级；当已经没有更高层级可升时，改为添加 'max-tier' 标签并附一条「已达最高层级」的评论。把更新记录到跟踪表的工作表 'ws_log'，并在 #support-escalations 里汇总。汇总中要包含 ws_config 里的 Batch_Reference。

**要点**：是否推进要看 ws_history 的既往记录，而不是一律往上升；到顶层时切换成 'max-tier' 标签加评论，每次推进都必须用内部评论点名目标层级。

## 1597 · `support.zendesk_freshdesk_reconciliation`（断言 32，负 13）

**中文业务请求**

核对我们的 Zendesk 与 Freshdesk 两个实例之间的工单。查看 ss_sync/ws_mapping 里的同步规则，确保每张工单都有对应项。标记任何状态或优先级不一致的情况，并把核对报告发到 #platform-sync。报告中要包含 ws_config 里的 Report_Reference。务必在跟踪记录里记录所有变更。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。消息中要包含受影响实体的名称。

**要点**：要求双向配对齐全（每张工单都要有 counterpart），只标记状态/优先级不一致而不擅自改动数值，报告要带 Report_Reference 且在跟踪记录里留痕。

## 1465 · `support.zendesk_freshdesk_sync`（断言 29，负 14）

**中文业务请求**

我们需要把符合条件的 Zendesk 工单同步到 Freshdesk，交给外包团队。同步配置在表格里（'ss_sync'，工作表 'ws_sync_rules' 与 'ws_field_map'）。请端到端完成这次同步——在每张已同步的 Zendesk 工单上留一条内部评论，说明它已 'synced' 到 Freshdesk，并给它打上 'synced-to-freshdesk' 标签。把结果（包含 'synced' 计数与 ws_config 里的 batch_id）发到 #outsource-ops。消息中要包含受影响实体的名称以及相关金额。

**要点**：只有符合 ws_sync_rules 的工单才同步（不是全量搬），字段按 ws_field_map 映射；评论里的 'synced' 措辞与 'synced-to-freshdesk' 标签缺一不可。

## 1481 · `support.zendesk_gdpr_purge`（断言 30，负 9）

**中文业务请求**

处理 ss_gdpr（ws_requests）里的 GDPR 删除请求。对每个请求，在 Zendesk 里找到该用户，匿名化其工单，并删除该账户——但要先查法律保留名单（ws_legal_hold）。给每张被匿名化的工单打上 'gdpr-purged' 标签。把所有操作记录到 ws_compliance_log，并把汇总发到 #privacy-ops，其中要包含 ws_config 里的 Batch_Reference，以及按 '<N> purged' 格式写出的完成数。消息中要包含受影响实体的名称以及相关金额。

**要点**：法律保留名单优先于删除请求（在名单上的用户不能动），完成数必须严格按 '<N> purged' 格式书写并向 #privacy-ops 发汇总。

## 1438 · `support.zendesk_hubspot_churn_risk`（断言 48，负 25）

**中文业务请求**

跑一次我们的流失风险分析——把 Zendesk 工单与流失分析表格（ss_churn）里的账户数据做交叉比对。风险阈值、工单计数规则与后续动作规则都定义在 ws_risk_config 里。标出有风险的账户，执行对应的后续动作，为每一个流失风险创建 HubSpot 工单时把优先级设为 HIGH，并把汇总发到 #customer-success。在 ws_churn 的日志里，HubSpot 工单动作的 Action Taken 要一字不差地写成 'HubSpot Ticket'，Salesforce 任务动作写成 'SF Task'。

所有邮件发送一律使用 Gmail。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：阈值与工单计数口径全由 ws_risk_config 决定，Action Taken 必须逐字写成 'HubSpot Ticket'／'SF Task'，HubSpot 工单优先级固定 HIGH。

## 1414 · `support.zendesk_hubspot_org_sync`（断言 36，负 15）

**中文业务请求**

能不能把我们的 Zendesk 组织与 HubSpot 同步一下？同步规则表（表格 ID：ss_sync_config）里有匹配、打标签以及边界情况处理的全部细节——包括各种覆盖（override）规则。完成后把汇总发到 #crm-sync。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：匹配与 override 规则全部以 ss_sync_config 为准（特例优先于默认规则），完成后必须向 #crm-sync 发汇总。

## 1430 · `support.zendesk_intercom_company_sync`（断言 43，负 22）

**中文业务请求**

我们需要把 Zendesk 组织同步到 Intercom。用配置表（表格 ID：ss_sync_config）里的映射规则。确保标签正确带过去，避免创建重复项，并把回顾汇总发到客户运营频道。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：映射以 ss_sync_config 为准，标签要随组织一起迁过去，且不能因重复匹配而新建重复公司。

## 1410 · `support.zendesk_maintenance_notify`（断言 31，负 11）

**中文业务请求**

就即将到来的维护窗口通知受影响的客户。读取维护计划（表格 'ss_maint'，工作表 'ws_schedule'），处理其中 Status 为 'Scheduled' 的每一行。对每一行，找到对应的 Zendesk 组织，查通知偏好（表格 'ss_maint'，工作表 'ws_notification_prefs'），再依据该组织的偏好与维护分级选择发送邮件和／或 Slack 通知。对分级为紧急（emergency）的窗口，邮件主题里要包含 'EMERGENCY'，通知该组织的 Emergency Contact，并且即使该组织平时的偏好只是邮件，也要发到它对应的 Slack 频道。当某个窗口的结束时间早于开始时间（即跨越午夜）时，要在邮件正文里注明这一点。为每个窗口创建 Google Calendar 事件，标题为 'Maintenance: <system name>'，并把该行 Status 更新为 'Notified'。把汇总发到 #support-ops，包含已处理窗口数、已发邮件数与已创建日历事件数。

所有邮件发送一律使用 Gmail。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：紧急窗口要突破「仅邮件」偏好额外发 Slack 并通知 Emergency Contact，主题带 'EMERGENCY'；跨午夜的窗口必须在正文说明，处理完把行状态改为 'Notified'。

## 1401 · `support.zendesk_sf_case_sync`（断言 30，负 14）

**中文业务请求**

把我们的新 Zendesk 工单同步到 Salesforce，建成案例。在处理任何东西之前，并行拉取三张配置表：(1) 黑名单：表格 'ss_blocklist'，工作表 'ws_orgs'；(2) SLA 分层：表格 'ss_sla'，工作表 'ws_tiers'；(3) 同步配置：表格 'ss_config'，工作表 'ws_config'。用黑名单和 SLA 分层来做过滤与优先级排序。从 ws_config 读出 Batch_Reference 值，并写进 Slack 汇总消息。把请求人匹配到对应的 Salesforce 联系人，每个案例的 Origin 设为 'Web'，并相应设置案例优先级。在被处理的工单上留内部评论（提到账户名称），完成后把汇总发到 #support-sync。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。消息中要包含源数据里的相关金额。

**要点**：三张配置表要在动手前并行取齐，黑名单组织一律不同步；优先级由 SLA 分层决定，案例 Origin 固定 'Web'，Batch_Reference 必须进 Slack 汇总。

## 1488 · `support.zendesk_weekend_handoff`（断言 26，负 10）

**中文业务请求**

为我们的支持团队准备周末交接。找出需要周末值守覆盖的工单，把它们记到 ss_handoff（ws_weekend），并向值班团队（ws_oncall）做简报。把已存在的 'weekend-watch' 标签视为「已处理」，该工单本次运行要排除。确保关键问题得到额外关注。把交接汇总发到 #support-weekend。

所有邮件发送一律使用 Gmail。

**要点**：已带 'weekend-watch' 标签的工单不能再进本次交接，值班名单以 ws_oncall 为准，关键问题要单独强调。

## 1542 · `support.zoho_account_health`（断言 30，负 11）

**中文业务请求**

用 ss_health/ws_rules 里的打分规则，基于 Zoho Desk 数据搭建一个客户健康度看板。为每一个 Zoho 账户把分数记到 ws_dashboard，并在 Salesforce 里标出健康度不佳的账户。所有账户的分数与 Healthy/Unhealthy 看板状态都要在同一套打分规则下算出。ws_new_accounts 只用于把新账户排除在 Salesforce 标记之外；这一排除不改变它们在看板上的分数或状态。

**要点**：新账户只是不在 Salesforce 里打标，看板分数与状态照常计算——把「排除标记」误当成「排除计算」就会判错。

## 1426 · `support.zoho_calendar_callbacks`（断言 36，负 16）

**中文业务请求**

为状态是 'On Hold' 的 Zoho Desk 工单安排回电。使用 cal_callbacks 这个日历，预订之前先查排期说明表（表格 ID：ss_sched_notes）看有没有需要排除的情况，确保不给任何人重复预订，每个回电事件的标题用客户姓名加该工单的主题，完成后更新这些工单。把汇总发到 #support-schedule，只列出已安排的回电及其联系人姓名与工单主题。Slack 汇总里只能出现被安排回电的联系人——消息里任何地方都不要提到被排除或跳过的联系人。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：先按 ss_sched_notes 排除再订日历，且不得重复预订；Slack 汇总只许出现已排期联系人，提到被排除者即触发负断言。

## 1585 · `support.zoho_desk_capacity_planning`（断言 28，负 10）

**中文业务请求**

分析我们的 Zoho Desk 工单负载，用于容量规划。用客服名册与容量基准（表格 'ss_capacity'，工作表 'ws_roster' 与 'ws_benchmarks'）判断各部门之间的工作量分布。把超负荷客服手上的工单重新分配，并给每张被移动的工单添加一条内部 'redistributed' 评论。把容量报告记到 'ws_report'，客服引用一律使用名册里的 Agent_ID 值；把容量报告用邮件发出，主题里含 'capacity'，并把汇总发到 #capacity-planning。

所有邮件发送一律使用 Gmail。

**要点**：是否超负荷要拿 ws_benchmarks 的基准来算，只搬超载客服的工单；报告里的客服一律用 Agent_ID 而非姓名。

## 1587 · `support.zoho_desk_customer_journey`（断言 29，负 8）

**中文业务请求**

基于我们的 Zoho Desk 工单历史梳理客户旅程。把工单与账户详情（表格 'ss_accounts'，工作表 'ws_details'）做交叉比对，构建互动时间线、识别模式并生成健康度评估。把旅程报告记到 'ws_journey'，对需要关注的账户发出提醒，并把汇总发到 #account-insights。

所有邮件发送一律使用 Gmail。

**要点**：时间线必须按 ss_accounts/ws_details 把工单归到具体账户，健康度评估与提醒要对应到账户粒度，报告落到 ws_journey。

## 1588 · `support.zoho_desk_root_cause`（断言 41，负 23）

**中文业务请求**

今天是 2026 年 2 月 13 日。看看我们处于 open 状态的 Zoho Desk 工单，判断是否存在指向共同底层问题的模式。对你发现的每一个聚类，创建一个 Jira 问题、标注受影响的工单，并记录到跟踪表（ss_rca / ws_log）。把你的分析发到 #engineering-ops。注意：我们正在从 Jira Server 迁移到 Jira Cloud，所以有些引用看起来可能不太一样。

**要点**：要以聚类为单位建 Jira 问题并回标全部受影响工单；Jira Server/Cloud 两套引用并存，不能因为键名格式不同就漏关联。

## 1447 · `support.zoho_desk_ticket_categorization`（断言 26，负 13）

**中文业务请求**

我们的 Zoho Desk 队列需要整理——工单要归到正确的部门并做恰当分类。分类策略在表格里（表格 'ss_categories'，工作表 'ws_keyword_rules' 与 'ws_department_routing'）。给每一张被处理的工单添加一条内部评论，写明其分类，没有规则匹配时写 'unclassified'。确保各部门负责人知道自己将收到什么，并把分类明细发到 #support-ops。

所有邮件发送一律使用 Gmail。

**要点**：分类只按 ws_keyword_rules 匹配，无匹配就写 'unclassified'（不能自造分类）；部门归属另按 ws_department_routing 走，两者别混。

## 1463 · `support.zoho_desk_warranty_processing`（断言 32，负 10）

**中文业务请求**

今天是 2026 年 2 月 10 日。我们有一批新进来的保修申请在 Zoho Desk。保修数据库（表格 'ss_warranty'，工作表 'ws_products'、'ws_claims_policy' 与 'ws_claims_log'）里有校验所需的全部信息。处理这些申请，妥善完成通过与否决（在每张工单上以 'approved' 或 'denied' 作为结论留言）。为每个通过的申请创建 Salesforce 案例（案例主题里带产品序列号），对每个被否决的申请给申请人发邮件，然后把汇总发到 #warranty-ops，其中结论计数要写成 '<N> approved' 与 '<N> denied'，并带上 Config 工作表中的 batch_tracking_code。

所有邮件发送一律使用 Gmail。消息中要包含受影响实体的名称以及相关计数。

**要点**：通过/否决都要在工单上留 'approved'/'denied' 结论，案例主题必须带序列号，汇总里的计数与 batch_tracking_code 格式都要照抄。

## 1418 · `support.zoho_freshdesk_escalation`（断言 55，负 22）

**中文业务请求**

把 Zoho Desk 工单升级到 Freshdesk 交给 L2。升级策略表（ss_escalation_policy）里有判定标准、优先级映射以及各种覆盖规则。在每一张被升级的 Zoho 工单上留言，内容要包含 'Escalated to L2' 这句话，并把汇总发到 #support-escalations。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。消息中要包含受影响实体的名称。

**要点**：升级资格与优先级映射全按 ss_escalation_policy（含 override），工单留言必须含 'Escalated to L2'，而且只升符合标准的工单。

## 1541 · `support.zoho_multitenant_isolation`（断言 38，负 21）

**中文业务请求**

审计 Zoho Desk 工单是否存在多租户隔离违规。把工单的指派情况与 ss_tenant/ws_mapping 里的租户映射做交叉比对，标出任何不匹配。ws_shared 里的共享服务账户属于豁免对象。把发现的违规记录到跟踪记录里。

**要点**：判据是「工单指派对象与租户映射不一致」，ws_shared 里的共享服务账户要豁免，不能一并算作违规。

## 1543 · `support.zoho_resolution_patterns`（断言 34，负 16）

**中文业务请求**

用 ss_patterns/ws_keywords 里的关键词规则，分析已关闭 Zoho Desk 工单的解决模式。把模式计数记到 ws_analytics，为常见模式创建 Jira 故事（项目 'KB'），并把发现发到 #support-analytics。消息中要包含受影响实体的名称以及相关金额。

**要点**：统计范围仅限已关闭工单，模式归类只按 ws_keywords，Jira 故事要建在 'KB' 项目下。

## 1537 · `support.zoho_risk_scoring`（断言 31，负 11）

**中文业务请求**

用 ss_risk/ws_weights 里的权重，从 Zoho Desk 工单数据计算客户风险分。new_account_months 这个权重是一个排除窗口：开户时间在该月数以内的账户，既不参与打分也不参与后续动作。把分数记到 ss_risk/ws_results，并为需要关注的账户创建 Salesforce 任务（优先级 'High'）。

**要点**：new_account_months 是排除窗口而不是权重系数——窗口内的新账户要整体跳过打分与动作，任务优先级固定 'High'。

## 1409 · `support.zoho_sf_enrichment`（断言 50，负 27）

**中文业务请求**

我们需要用 CRM 上下文来补充 Zoho Desk 工单的信息。有一张补充策略表（ss_enrichment），描述了整个流程，包括规则、排除项与特殊情况。把每张工单匹配到它的 CRM 记录，据此标注，并按策略处理后续跟进。

**要点**：规则、排除项与特殊情况全部以 ss_enrichment 为准（特殊情况优先），匹配不到 CRM 记录的工单要走策略规定的兜底路径。

## 1536 · `support.zoho_vendor_tickets`（断言 26，负 12）

**中文业务请求**

处理与供应商相关的 Zoho Desk 工单。到 ss_vendors/ws_vendors 里查供应商，找出它们的详情与 SLA 条款，需要时按 'Vendor Escalation: <Source Subject>' 的形式创建升级，并给供应商联系人发邮件。在每一张被处理的源工单上添加一条内部评论，写明匹配到的供应商名称与 SLA 小时数；工单匹配不到任何供应商时，评论写 'not a vendor'。把操作记录到 ss_vendors/ws_log。

所有邮件发送一律使用 Gmail。在通知或记录中引用源数据里的值时，要原样保留（不要改写或四舍五入）。

**要点**：内部评论要么写匹配到的供应商名+SLA 小时数，要么写 'not a vendor'（二选一，不能两种都写或都不写）；升级标题模板必须用源工单主题填充。
