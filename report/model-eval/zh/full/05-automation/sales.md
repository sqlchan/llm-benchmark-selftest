# Automation-Bench 公开集中文翻译 · sales（第 1–25 条）

## 4 · `sales.add_contact_to_campaign`（断言 9，负 5）

**中文业务请求**

把资深联系人添加到 Q1 Product Launch Webinar 活动（ID：701xx000001STU1）。重点关注 director 级别及以上。确保每个人都符合我们的活动资格与合规要求。

**要点**：只加 director 及以上、且必须同时满足活动资格与合规要求的联系人才可加入，负断言多说明误加不符合条件者即为错。

## 2 · `sales.advance_opportunity_stage`（断言 12，负 2）

**中文业务请求**

与 Hendricks Manufacturing 的 demo 进展顺利。推进流程。遵循可能适用的任何近期政策更新。

**要点**：阶段推进必须采用最新政策（可能有变更后的阶段门槛或前置条件），不能凭「进展顺利」直接跳到最终阶段。

## 105 · `sales.apply_project_label`（断言 14，负 0）

**中文业务请求**

照惯例给 PM 打上 Project Alpha 邮件的标签。

**要点**：需按既有惯例（既定标签名与归档规则）批量打标签，且只处理 Project Alpha 相关邮件，不能波及其他邮件。

## 519 · `sales.calendar_crm_meeting`（断言 7，负 4）

**中文业务请求**

我收到一封请求会面的邮件（ID：'msg_meeting_request_001'）。阅读该邮件，在 Salesforce 中查出该联系人，按对方给出的候选日期在我的日历里找第一个可用时段，并针对他们想要的讨论类型创建时长合适的会议。查看 'Meeting Duration Policy' 表格以确认时长准则。创建事件前还要查看 CRM Meeting Record Policy 邮件。

**要点**：时长要按讨论类型查政策表，且创建事件前必须先读 CRM 记录政策（可能要求补写记录或字段），时段取候选日期中最早的可用。

## 1148 · `sales.calendly_availability_based_routing`（断言 10，负 5）

**中文业务请求**

今天是 2026 年 1 月 21 日。'prospect@newco.example.com' 发来一个新的 demo 请求，希望明天会面。查看路由政策邮件和我们的 Demo Routing Rules 表格，确定应由哪位 rep 负责。与正确的 rep 安排一场 'Sales Demo'，并在 Salesforce 中更新 lead 归属。

**要点**：路由要同时依据政策邮件与 Demo Routing Rules 表（可能有更新覆盖），并同步改掉 Salesforce 中的 lead owner。

## 815 · `sales.calendly_capacity_management`（断言 7，负 3）

**中文业务请求**

今天是 2026 年 2 月 20 日。检查下周的团队容量并处理任何超限情况。rep 的上限在 Rep Skills 表格的 'Capacity Limits' 工作表中。务必通知所有受影响的人，并把摘要发到 #capacity-alerts。在消息中包含相关计数，取消数量使用 'Cancelled: <N> meeting(s)' 这一行。

**要点**：超限要按各 rep 的独立上限削减会议、通知到每一个受影响方，摘要里取消数必须写成指定的 'Cancelled: <N> meeting(s)'。

## 703 · `sales.calendly_discovery_call`（断言 9，负 1）

**中文业务请求**

为我们在 DataFlow Inc. 的合格 lead 'Marcus Williams' 预约一次 discovery call。查看 lead 预约政策表格（spreadsheet_id='ss_booking_policy_001'），确认该 lead 的角色适用哪种 event type。确保遵循当前有效的预约流程准则。把结果更新到该 lead 的 CRM 记录中。

**要点**：event type 必须按政策表中的角色映射选取，还要遵守最新的预约流程（可能含附加步骤），回写 CRM 记录。

## 839 · `sales.calendly_lead_scoring`（断言 8，负 3）

**中文业务请求**

按 lead scoring playbook 对当前 leads 打分并路由。把任何适用的政策更新应用到评分流程中。在消息中包含受影响实体的名称和相关金额。

**要点**：评分规则可能已被政策更新改写，必须用最新口径先打分再路由，消息里要带名称与金额。

## 811 · `sales.calendly_meeting_prep`（断言 14，负 4）

**中文业务请求**

为明天的 Calendly 会议准备简报。调研每位受邀者并创建准备笔记。按我们的升级流程处理高价值交易，完成后发送摘要。

今天是 2026-02-20。在消息中包含受影响实体的名称和相关金额。

**要点**：高价值交易必须走升级流程（升级对象与标记方式），且每位受邀者都要有准备笔记，摘要含名称与金额。

## 1144 · `sales.calendly_multi_stakeholder_scheduling`（断言 6，负 1）

**中文业务请求**

我们需要与 ClientCo 的 3 位 stakeholder 安排一场 deal review 会议。

在 account 'ClientCo' 下找出 title 包含 'VP' 或 'Director' 的联系人。
这样的联系人应恰好有 3 位。

创建一个 Calendly group event：
- Event type：'Deal Review'
- 把全部 3 位 stakeholder 加为受邀者
- 时长：60 分钟

预约完成后，创建一条与商机关联的 Salesforce 任务，用于会前准备。

**要点**：必须先筛出恰好 3 位 title 含 VP/Director 的联系人再建 group event，并在排期后补建与商机关联的 prep 任务。

## 704 · `sales.calendly_no_show_followup`（断言 9，负 3）

**中文业务请求**

Slack 中报告了一次 no-show。按流程处理。在跟进记录中，预约时间使用 24 小时制 HH:MM，总 pipeline 价值使用带逗号的整数美元。

今天是 2026-02-15。

**要点**：跟进记录里的时间必须是 24 小时制 HH:MM、金额为带千分位逗号的整数美元，并按最新 no-show 流程执行。

## 1151 · `sales.calendly_no_show_reengagement`（断言 13，负 4）

**中文业务请求**

今天是 2026 年 1 月 21 日。处理昨天的 no-show 事件并发起重激活（re-engagement）。在 Salesforce 中查出每位 no-show 受邀者，并应用我们当前的 escalating no-show 重激活政策。把每次已处理的 no-show 作为 note 记录在该联系人上。

**要点**：重激活要按「分级」（escalating）政策——不同次数对应不同动作与间隔；每条处理过的都要在联系人上留 note。

## 801 · `sales.calendly_reschedule_chain`（断言 11，负 3）

**中文业务请求**

处理刚刚收到的改期请求。按我们的改期政策取消并重新预约，确保没有冲突。相应更新 CRM；把对方请求的新时间按 12 小时制记录。

**要点**：改期须先取消再重订、且新时段不得与日程冲突，CRM 中记录的新时间要用 12 小时制。

## 1147 · `sales.calendly_reschedule_with_apology`（断言 13，负 5）

**中文业务请求**

嗨，我需要把和 ClientA 团队的 demo 往后推——他们那边出了点状况。按我们的排期惯例把它推后 3 天（并遵守公司日历），同时给他们发一封致歉说明，格式与上次我们不得不改期时一样。也别忘了更新 Salesforce——在联系人上记一条 note，写明改期情况以及原会议日期（YYYY-MM-DD）。在消息中包含受影响实体的名称。

**要点**：推后 3 天还要避开公司日历冲突，致歉信必须沿用上次的格式模板，并在联系人 note 中留原会议日期（YYYY-MM-DD）。

## 1146 · `sales.calendly_sequential_meetings`（断言 15，负 6）

**中文业务请求**

为商机 'TechStart - Platform Deal' 安排标准销售流程会议。查阅 'Sales Process Playbook' 表格（spreadsheet_id='ss_sales_playbook'，worksheet_id='ws_meeting_sequence'）以获取会议序列，包括每一步应安排哪种 meeting type、邀请哪个 contact role，以及排期后应把阶段设为哪个。相应更新商机阶段。

**要点**：必须按 playbook 的序列逐步建会、每步邀请对应角色，并在排期后按表中规定改阶段，不能一步到位。

## 831 · `sales.calendly_sla_monitoring`（断言 8，负 2）

**中文业务请求**

对照 'Account Tiers' 表格中的 SLA 目标监控响应时长，并按该工作簿中当前有效的 SLA 响应流程处理所有违约（breach）情况。今天的日期：2026-02-21。

**要点**：SLA 目标随 account tier 不同，违约处理要用工作簿里的现行流程（可能含升级动作），不能套用单一阈值。

## 1145 · `sales.calendly_timezone_aware_scheduling`（断言 10，负 4）

**中文业务请求**

与我们就 EMEA 扩张一直在沟通的那位 GlobalTech 团队成员安排一次通话。查看邮件 thread，确认此人是谁。确保时间落在对方的工作时间内，并使用 International Sales Call 这一 event type。给对方发送确认。在消息中包含受影响实体的名称。

**要点**：必须从邮件 thread 定位到正确的人，再按其所在时区的工作时间排期并使用指定 event type，最后发确认。

## 1119 · `sales.champion_change_alert`（断言 5，负 1）

**中文业务请求**

监控进行中交易里 champion 的职位变动。把 Salesforce 商机联系人与他们当前的 LinkedIn 资料交叉核对，以发现是否有 champion 已离开其公司。向团队告警，并对发现的任何变动更新相应记录。

**要点**：要拿 LinkedIn 现状与 Salesforce 记录比对来判断 champion 是否已离职，告警与更新记录两件事都要做。

## 1142 · `sales.chatgpt_contract_summary`（断言 9，负 1）

**中文业务请求**

DocuSign 里刚完成了一份合同。找到正确的那一份，用 ChatGPT 总结关键条款，用正确的调整后金额关闭对应的 Salesforce 商机，并按我们的赢单公告流程庆祝一下。在消息中包含受影响实体的名称。

**要点**：关单金额必须用合同中的「调整后」金额，且赢单公告要按既定流程（渠道与格式）发布。

## 1141 · `sales.chatgpt_email_sentiment_routing`（断言 13，负 1）

**中文业务请求**

对已收到的邮件做常规分诊（triage）。用 ChatGPT 做情绪分类，按政策把每封邮件路由到对应处，把成功处理过的源邮件标记为已读，并把摘要发到 #email-routing。在消息中包含源数据里的相关金额。

**要点**：按情绪分类后分别路由、只有「处理成功」的源邮件才标为已读，摘要发到 #email-routing 且金额原样引用。

## 1131 · `sales.chatgpt_lead_classification_pipeline`（断言 14，负 1）

**中文业务请求**

处理入站询价邮件，用 ChatGPT 按我们的 lead 分类路由规则对其进行分类与打分。按分类结果以相应优先级在 Salesforce 中创建 leads，对高优先级 leads 通知正确的渠道，并把处理摘要发到 #lead-processing（包含有多少 leads 被 'processed'）。把每封成功处理的源邮件标记为已读。在消息中包含源数据里的相关金额。

**要点**：分类→打分→建 lead 的优先级映射要按规则，只有高优先级才通知渠道，摘要里要写明被 'processed' 的 lead 数量。

## 1134 · `sales.chatgpt_lead_summary_generator`（断言 5，负 1）

**中文业务请求**

今天是 2026 年 2 月 20 日。我们需要一份关于 TechVentures 的 Marcus Chen 的研究简报，并套用我们的 engagement 评分标准。用 ChatGPT 把已掌握的情况综合成该简报，并分享给团队。在消息中包含受影响实体的名称。

**要点**：简报必须按 engagement 评分标准评估，并共享给团队（渠道与形式要符合要求），不能只自己保存。

## 1139 · `sales.chatgpt_proposal_customization`（断言 22，负 2）

**中文业务请求**

为 RetailGiant 制定一套提案思路。调研关键 stakeholder，并弄清他们各自在意什么。查看 Proposal SOP（ss_proposal_sop / ws_proposal_rules）确认必需包含哪些章节，然后用 ChatGPT 协助拟定策略，并保存到 Salesforce 中对应的商机上。

今天是 2026-01-20。

**要点**：提案必须涵盖 SOP 规定的全部必需章节，且策略要真正落到商机记录上，不能只发消息了事。

## 1107 · `sales.cold_email_personalization`（断言 6，负 1）

**中文业务请求**

今天是 2026 年 1 月 20 日。给 Quantum Dynamics 的 VP of Sales 发一封个性化 cold email。在 LinkedIn 上调研此人，从其近期动态中找出可用的个性化切入点，然后撰写并发送一封外联邮件，主题中需包含该潜在客户的名字（first name）。把 CRM 的 Status 更新为 'Contacted'。

**要点**：主题必须含对方的 first name、个性化切入点要来自其 LinkedIn 近期动态，并把 CRM Status 改为 'Contacted'。

## 1114 · `sales.competitive_displacement_outreach`（断言 24，负 7）

**中文业务请求**

执行 Q1 的竞争替换（competitive displacement）活动。务必纳入任何近期的目标客户筛选（targeting）准则。

**要点**：断言多、负断言也多，需严格按最新 targeting 准则筛选目标，不能沿用旧名单或误触不符合条件的客户。

## 1181 · `sales.contract_renewal_coordinator`（断言 10，负 3）

**中文业务请求**

为未来 60 天内到期的合同协调续约。找出即将到期的 DocuSign envelope，通过检查 champion 状态和未关闭的支持问题来评估每个 account 的健康度，然后根据关系进展情况采取相应的续约动作。健康账户会得到一次 Calendly 续约讨论和一份起草好的 Renewal Agreement；有风险的账户会得到一次 CSM 内部日历复盘和一条高优先级的 Salesforce 任务，且不发续约 envelope。自动续约（auto-renew）的账户无需任何动作。起草谈话要点（talking points），并把状态发到 #renewals。在消息中包含受影响实体的名称和相关金额。

**要点**：三类账户的动作严格互斥——健康＝Calendly 讨论＋草稿协议、有风险＝内部日历复盘＋高优任务且明确不发 envelope、auto-renew 什么都不做；健康度须同时看 champion 状态与未关闭工单。

## 3 · `sales.create_contact_for_account`（断言 6，负 3）

**中文业务请求**

收件箱里有新的 stakeholder 通知。请按我们的联系人入职（contact onboarding）流程处理它们。

**要点**：只能处理这三类新 stakeholder 通知并按 onboarding 流程建档，挂错 account、漏建或多建无关联系人都算错。

## 109 · `sales.create_draft_reply`（断言 11，负 8）

**中文业务请求**

收件箱里有一些与续约相关的邮件。请用标准的续约回复口径，给其中合适的那一封起草一封回复。在消息中包含受影响实体的名称和相关计数。

**要点**：只应给真正属于续约的那一封起草回复，其余干扰邮件一律不碰；负断言多达 8 条，说明误选、多发、漏发都会被判错，且消息要带名称与计数。

## 103 · `sales.create_important_draft`（断言 12，负 10）

**中文业务请求**

我需要就我们的 Q4 业绩向董事会汇报。起草一封发往 board@example.com、主题为 'Q4 2025 Results Summary' 的邮件。从我们的内部邮件中提取最新的财务亮点，标出任何看起来有风险的交易，并注明来源。遵循我们的董事会汇报格式规范。保存为草稿。在把源数据中的数值写入通知或记录时，请原样保留（不要改述，也不要四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：收件人与主题固定、只存草稿不发送，数字必须逐字照抄不得四舍五入或改述，并须按董事会格式标注来源；负断言多，混入无关邮件内容或自行估算即错。

## 9 · `sales.create_new_opportunity`（断言 7，负 6）

**中文业务请求**

Summit Industries 想加购我们的 Analytics Module。为他们创建一个商机，并根据其账户规模与层级定合适的价格。确保使用的是最新的定价更新与账户健康政策。

**要点**：价格要按账户规模与层级去查最新定价，并受账户健康政策约束（可能触发审批或不允许建单），照抄旧价或不看健康政策即失败。

## 10 · `sales.create_note_on_contact`（断言 13，负 3）

**中文业务请求**

按我们的标准 discovery 模板记录 Amanda Foster 的 discovery call 发现。找到正确的联系人，并查看 Discovery Call Template 表格（ID：'ss_disc_template_001'）以了解必需的章节与评分公式。

**要点**：note 必须包含模板规定的全部章节、按公式算出分数，并挂到正确的 Amanda Foster 联系人上（存在同名/相似联系人干扰）。

## 1202 · `sales.cross_modal_renewal_processing`（断言 11，负 7）

**中文业务请求**

嘿，能处理一下那些即将到期账户的 Q1 续约通知吗？续约跟踪表（renewal tracker）里有名单。CS 应该已经把 green-light 批准发过来了。从 Salesforce 拉取联系人信息，给每个人发一封续约提醒（heads-up）邮件。做完后还在 #renewals 里留一份摘要。在消息中包含源数据里的相关金额。

**要点**：名单以 tracker 为准，且必须先拿到 CS 的 green-light 批准才发——只对已批准账户发提醒，未获批的不能发，发完还要把摘要落到 #renewals。

## 1132 · `sales.cross_platform_account_health_score`（断言 13，负 3）

**中文业务请求**

对我们的 Enterprise 账户跑一遍季度健康检查。从各个常用平台拉取信号，给它们打分，并据此更新 Salesforce。标出任何需要关注的事项，并把摘要发到 #account-health。

**要点**：要把跨平台信号汇总后按统一口径打分再回写 Salesforce，范围仅限 Enterprise 账户，摘要里必须点明需关注项。

## 514 · `sales.cross_reference_validation`（断言 11，负 6）

**中文业务请求**

Quantum Labs 的 Maya Rodriguez 就来推进一笔交易联系了我们。按我们处理新交易请求的常规方式处理——如条件符合，先做校验，再建立商机（'Quantum Labs - Enterprise Deal'，阶段 Qualification，金额 $150,000）。在选定的联系人上留一条 'Validation Checklist' note 记录核验过程（其中包含 'chosen contact id: <contact_id>' 与 'chosen account id: <account_id>'）。

**要点**：必须先交叉核验（联系人与 account 是否对得上、是否已有重复商机）再决定建不建单，并在 note 中按指定写法写明选定的 contact id 与 account id。

## 1009 · `sales.feedback_routing`（断言 19，负 7）

**中文业务请求**

今天是 2026 年 2 月 20 日。按现行升级政策（查看近期政策邮件与参考资料）处理最新的客户反馈。在适当处标出有风险的交易，并把摘要发到 #sales-alerts。摘要必须包含：反馈总数、情绪分布（positive/negative/neutral 各自的数量），以及升级政策表格中的政策编号（policy reference number）。再加一个已标记交易章节，列出每一个被升级的账户/交易及其金额。每条升级任务的 Description 也必须包含该账户/交易与金额。在把源数据中的数值写入通知或记录时，请原样保留（不要改述，也不要四舍五入）。

**要点**：摘要三项硬指标（总数、情绪分布、政策编号）缺一不可，且每个升级任务的 Description 里都要重复写出账户/交易名与金额，数字原样不得改述或取整。

## 1004 · `sales.deal_escalation`（断言 7，负 3）

**中文业务请求**

#deal-alerts 里有一个风险交易的 thread。用我们的风险评分框架评估情况，并据此路由升级。无论你发什么内容，都要带上分数。在把源数据中的数值写入通知或记录时，请原样保留（不要改述，也不要四舍五入）。在消息中包含源数据里的相关金额。

**要点**：升级去向必须由框架算出的分数决定（不能凭感觉定级），并且发布内容与记录中都要出现该分数和原样金额。

## 517 · `sales.dependency_chain`（断言 6，负 4）

**中文业务请求**

收到一封交易请求邮件 'msg_deal_request_001'。处理它，并在合适的母公司下创建商机（我们只与顶层实体打交道，不与子公司）。按现行政策使用我们的标准定价。

创建商机，名称为 '[Account Name] - Q1 Enterprise Deal'，阶段为 Qualification，并向该账户最高级别的联系人发送一封确认邮件。主题：'Deal Request Received'。包含账户名称、商机名称和计算出的金额。

**要点**：必须沿股权链上溯到顶层母公司再建单（挂到子公司即错），商机命名与阶段固定，确认邮件只发给该账户职级最高的联系人。

## 1162 · `sales.docusign_amendment_processing`（断言 23，负 7）

**中文业务请求**

处理最新邮件中请求的合同修订（amendments）。对每一份：找到原始的已完成合同，用 'Contract Amendment' 模板创建一个 amendment envelope，在现行价格表中查出适用的每席位费率以计算价格调整（新增席位数 × 在新席位数档位所适用的每席位费率 × 剩余合同月数——原有席位仍按原定价），然后发送给原始签署人。在 envelope 自定义字段中，用字段名 'new_seat_count' 表示更新后的席位数，用 'price_adjustment' 表示计算出的价格变动。用修订详情更新商机。

**要点**：价格调整公式为「新增席位 × 新席位档费率 × 剩余月数」，老席位不重新计价；两个自定义字段名必须精确为 'new_seat_count' 与 'price_adjustment'，并回写商机。

## 1161 · `sales.docusign_bulk_nda_sender`（断言 19，负 5）

**中文业务请求**

今天是 2026 年 1 月 21 日。嘿，这周我们入职了一批新联系人，需要确保按我们的 NDA 合规准则把 NDA 都发出去。能查一下还有谁需要签，并通过 DocuSign 把 Mutual NDA 发给他们吗？更新他们的记录以反映 NDA 已发送，并给 #legal-ops 提个醒，简要汇总发出多少份、多少人本来就有。在消息中包含源数据里的相关金额。

**要点**：只发给确实缺 NDA 的联系人（已有 NDA 的不得重发），联系人记录要标记已发送，摘要需分别给出「本次发出」与「本来已有」的数量。

## 1158 · `sales.docusign_completion_processor`（断言 20，负 8）

**中文业务请求**

执行今天（2026 年 1 月 21 日）的每日关单流程。按常规方式处理已完成的合同。在消息中包含受影响实体的名称和相关金额。

**要点**：必须覆盖当天所有已完成合同（漏一份或重复处理都错），并按常规流程回写对应商机的阶段与金额。

## 813 · `sales.docusign_compliance_template`（断言 15，负 2）

**中文业务请求**

今天是 2026 年 1 月 22 日。本周已成交的交易需要按我们的标准合规流程把合同发出去。

**要点**：合同模板要按合规流程与交易类型逐单匹配，且范围严格限定「本周已成交」，不能发给未成交或模板不对应的交易。

## 1156 · `sales.docusign_conditional_template_selection`（断言 15，负 4）

**中文业务请求**

为所有已就绪的交易发送合同，按我们的标准流程。为每一份选用正确的协议类型。发送给主联系人（primary contact），并在商机描述中记录模板使用情况。

**要点**：协议类型要按每笔交易的条件分别选择，收件人只能是 primary contact，模板使用情况必须写入商机的 description。

## 705 · `sales.docusign_contract_send`（断言 19，负 5）

**中文业务请求**

处理 'Deal Closed' 通知邮件——找到相关商机，按我们的合同路由准则通过 DocuSign 把合适的合同模板发给正确的签署人，把已发送的内容更新到商机，并对大额交易提醒团队。在消息中包含受影响实体的名称和相关金额。

**要点**：签署人要按路由准则判定（不是默认联系人），大额交易需额外通知团队，发送内容要回写商机。

## 706 · `sales.docusign_deal_workspace`（断言 11，负 1）

**中文业务请求**

用该账户的联系人搭建一个 deal room workspace。到 #deal-ops 查看请求，并在那里确认完成。在消息中包含源数据里的相关金额。

**要点**：workspace 成员只能是该账户的联系人（不能拉入外部或无关人员），且完成后必须回到 #deal-ops 原处确认。

## 1153 · `sales.docusign_renewal_automation`（断言 7，负 3）

**中文业务请求**

处理未来 30 天内到期的合同。查看销售 VP 发来的续约政策邮件，确认定价与账户状况（account standing）标准。向符合条件的账户发送续约协议，其余标记为待复核。更新所有已处理的商机。

**要点**：定价与资格以 VP 的政策邮件为准，只有达标账户直接发协议、其余仅标记复核，且所有处理过的商机都要更新。

## 837 · `sales.docusign_sequential_signing`（断言 7，负 2）

**中文业务请求**

PartnerCorp 的合作协议需要签署。按我们的标准流程设置签署流程并发出去。

**要点**：必须按顺序签署（sequential）配置签署人及先后次序，配成并行或顺序颠倒即失败。

## 1157 · `sales.docusign_void_and_resend`（断言 9，负 4）

**中文业务请求**

我们给 CorrectionCo 发了一份金额错误的合同。正确金额应为 $85,000。修正这个问题，给他们发一封致歉信并附上更正后的合同，同时确保我们所有系统都已更新。

**要点**：要先作废原 envelope，再按 $85,000 重发并把致歉信与更件一并送出，CRM 等各系统里的金额也要同步改正。

## 821 · `sales.docusign_void_resend`（断言 15，负 3）

**中文业务请求**

收件箱里有一条未读的合同更新请求。按标准流程处理——作废、用正确的模板重发、更新 CRM，并向提出请求的 rep 确认。在消息中包含受影响实体的名称和相关金额。

**要点**：重发必须换用正确模板（不是原模板），CRM 更新完毕后还要回复提出请求的 rep 做确认。

## 604 · `sales.email_zoom_fuzzy`（断言 15，负 9）

**中文业务请求**

收件箱里某处有一个会议请求。把它设置为由 scheduler@ourcompany.example.com 主持的 Zoom 会议，并登记参会人。用 CRM 找出正确的人。务必遵循我们的排期流程。应用任何适用的授权政策更新。

**要点**：要从杂乱的收件箱里定位到那个会议请求、按 CRM 确定参会人，主持人固定为 scheduler@ourcompany.example.com，并叠加最新的授权政策。

## 1112 · `sales.event_followup_outreach`（断言 14，负 6）

**中文业务请求**

向 'Product Launch 2024' 网络研讨会的深度参与参会者发送个性化跟进。聚焦那些停留时间足够长、表现出真实兴趣的参会者。对新潜客，在 CRM 中创建一个 lead；对已有联系人，更新其 CRM 记录以标注参会情况。给每位深度参与的参会者发送一封个性化感谢邮件，并准确写明其参会了多少分钟。不要给早早离席的人发邮件。

**要点**：参会时长既是唯一的筛选口径、又要在邮件里写出确切分钟数；新潜客建 lead、老联系人只更新记录，早退者一律不发。

## 1180 · `sales.event_to_opportunity_pipeline`（断言 14，负 5）

**中文业务请求**

处理 'AI Innovation Summit' 网络研讨会上有互动的参会者，把其中有潜力的转为 pipeline。在 LinkedIn 上调研这些参会者，依据职级与公司规模判断资格——公司规模至少 50 名员工才算合格——然后建立正确的 CRM 记录、安排 discovery call、发送个性化跟进，并把摘要发到 #marketing-qualified。

**要点**：资格门槛是「公司至少 50 人 + 职级达标」，且必须走完整链路（CRM 记录、discovery call、个性化跟进、频道摘要），漏环节或把不合格者转进 pipeline 即失分。

## 528 · `sales.five_level_conditional`（断言 11，负 6）

**中文业务请求**

把 lead 'Marcus Johnson' 走一遍我们的标准 lead 资格判定流程（见 'Lead Qualification Workflow' 表格），并依据判定结果创建相应的跟进任务。检查其 lead source、company profile、account status 与 pipeline activity，据此确定正确的下一步动作。

创建任务时，要把它关联到该 lead 记录（把任务的 contact_id 设为该 lead 的 ID）。在任务描述里写入相关细节——opportunity 名称与阶段、以逗号分隔的整数美元金额表示的 deal value、以及 account 名称——好让接手的人有上下文。

**要点**：五级条件分支要严格按表格逐项（来源／公司画像／账户状态／管道活动）判定；任务必须挂到 lead 的 contact_id 上，描述里的金额要写成带千分位逗号的整数美元。

## 1121 · `sales.form_to_crm_qualification`（断言 13，负 3）

**中文业务请求**

处理最新一批网站表单提交。按 ICP 对它们做资格判定，并以正确的状态录入 Salesforce。更新表格，并把任何特别突出的 prospects 在 #high-value-leads 里标出来。在消息中包含受影响实体的名称。

**要点**：合格口径必须取自 ICP，录入状态要与判定结果一致，且消息里要点名受影响实体（负断言意味着不能漏报、也不能把不合格者写成合格）。

## 511 · `sales.format_ambiguity`（断言 7，负 1）

**中文业务请求**

收件箱里应该有一封 title 更新请求。你能处理一下吗？务必遵循我们的联系人识别流程。

**要点**：请求没说是谁、也没给记录 ID，必须先按「联系人识别流程」把人认准再改 title，认错人、改错记录都会踩负断言。

## 1179 · `sales.full_sales_cycle_orchestrator`（断言 9，负 1）

**中文业务请求**

TechVentures - Enterprise Deal 刚完成 Demo。把这个 deal 推进到后续步骤——到 #deal-room-techventures 查看 post-demo playbook。把合同材料准备为草稿，预留准备时间，生成 proposal 的 talking points，并保持 deal room 更新。

**要点**：后续动作以 deal room 里的 post-demo playbook 为准（不是凭销售常识）；合同材料只能做成草稿，不能当作可直接发出或签署的文件。

## 1178 · `sales.gcal_deal_milestone_tracker`（断言 7，负 2）

**中文业务请求**

检查仍处于 pipeline 早期阶段的 deal 的日历会议历史，并按其实际发生的情况更新这些 deal 的 opportunity 阶段。使用我们的阶段映射：Discovery/Intro 会议 = 'Discovery'，Demo/Technical 会议 = 'Demo'，Proposal/Pricing 会议 = 'Proposal'，Executive/Contract 会议 = 'Negotiation'。为每次阶段变更记录一条 note，并把里程碑摘要发到 #pipeline-updates。

**要点**：阶段只能按「会议类型→阶段」的映射表推进，处理范围仅限仍处早期阶段的 deal，且每次变更都必须留 note。

## 1177 · `sales.gcal_travel_time_buffer`（断言 7，负 2）

**中文业务请求**

今天是 2026 年 1 月 21 日。查看明天（1 月 22 日）的日历，确保任何线下会议之前都有 30 分钟的 travel-time 块。用任务 subject 'On-site visit' 在 Salesforce 中记录上门拜访。把出差安排发到 #field-sales，其中包含一行 'In-person visits: <N>'。如果某处缓冲块怎么排都会撞上冲突、放不下，就把它标记出来。

**要点**：缓冲只加在 in-person 会议之前，且不得与其他会议重叠；遇到放不下的情况只能上报，不能硬塞或挪动既有会议。

## 1201 · `sales.historical_context_pipeline_report`（断言 6，负 1）

**中文业务请求**

你好，能把本周的 pipeline 更新发给团队吗？今天是 2026 年 2 月 26 日。格式和上次一样。谢谢！在消息中包含受影响实体的名称和相关金额。

**要点**：「和上次一样」要求先翻历史邮件找出上次的模板与收件范围，照其结构与口径复刻，不能自创格式。

## 1204 · `sales.historical_win_loss_recap`（断言 9，负 4）

**中文业务请求**

你好，该给团队发月度 win/loss 复盘了。今天是 2026 年 2 月 26 日。照老规矩。谢谢！在通知或记录里引用源数据的数值时，要原样保留（不要改写、不要四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：数值必须逐字照搬（禁止四舍五入或改写），格式沿用历史惯例，且消息里要点名受影响实体与对应金额。

## 513 · `sales.implicit_rules`（断言 13，负 1）

**中文业务请求**

Aurora Tech 需要往前推进。按我们当前的流程处理阶段推进。

**要点**：「当前流程」是隐含规则，得先查出最新流程版本再晋级，按常识或旧流程跳阶段会出错。

## 1126 · `sales.invalid_email_cleanup`（断言 11，负 2）

**中文业务请求**

该对 Salesforce 做一轮邮件数据体检了。查看数据质量政策里什么算 invalid email，然后清理掉所有坏记录。记录全过程，做完后把摘要发到 #data-quality。

**要点**：「无效邮箱」的判定标准必须取自数据质量政策（口径可能比直觉更严），清理只针对真正符合定义的记录，并且全程留痕。

## 1104 · `sales.job_posting_contact`（断言 9，负 2）

**中文业务请求**

到 LinkedIn 上查看目标账户的新招聘信号，并为决策人创建 lead。按邮箱匹配 lead，命中已有记录就更新，而不是新建重复项；把招聘广告上的职位名记到 Lead Description。把所有内容记进 Hiring Signals 表格，并把摘要发到 Slack 的 #new-signals。在消息中包含受影响实体的名称。

**要点**：判重靠邮箱（有则更新、无则新建），职位名必须写进 Lead Description，重复建 lead 会直接踩负断言。

## 702 · `sales.linkedin_connection_outreach`（断言 16，负 4）

**中文业务请求**

检查收件箱里近期的产品咨询。对任何在 Salesforce 中属于「尚未联系过的 lead」的发件人，在 LinkedIn 上向其发送个性化连接请求，内容要提到他们的咨询、所在行业和人脉网络规模。遵循我们的标准 outreach 政策。在 Salesforce 中更新这些 lead 以反映本次触达。

**要点**：目标只限 Salesforce 里未联系过的 lead，连接请求须个性化并覆盖「咨询内容／行业／人脉规模」三点，同时回写 Salesforce 状态。

## 828 · `sales.linkedin_content_engagement`（断言 8，负 2）

**中文业务请求**

今天是 2026 年 2 月 18 日。处理 LinkedIn 帖子互动，并跟进有互动的 prospects。查看公司近期帖子，识别出决策人层级的互动者。对新 prospects 创建 CRM lead；对已有联系人且名下有 open opportunity 的，通知该 opportunity 的 owner。向尚未建立连接的互动者发送连接请求，并在 #social-selling 汇总活动情况。在消息中包含相关计数。

**要点**：要按「新 prospect／已有联系人且带 open opp／尚未连接」三类身份分流处理：只有非连接者发连接请求，已有 open opp 的则通知 owner。

## 816 · `sales.linkedin_event_promotion`（断言 9，负 1）

**中文业务请求**

把我们即将举办的那场网络研讨会推广给相关的 LinkedIn 连接。从 webinar 推广邮件里取研讨会详情。目标是 Salesforce 中行业与职级都与研讨会主题匹配的联系人——对已建立连接的发送消息，对其余人发送连接请求。在每个联系人的 Description 里写上精确的触达标记 'Webinar invite sent'，并在 #marketing-outreach 汇总结果。

**要点**：筛选要同时匹配行业与职级，已连接／未连接走不同动作，Description 里的标记必须一字不差。

## 808 · `sales.linkedin_job_change`（断言 10，负 1）

**中文业务请求**

把 Champions（description 中含 'Champion' 的联系人）的 LinkedIn 资料与 Salesforce 中的记录交叉比对，检查他们是否换了工作。对任何已经跳槽的人，按我们的 champion 变更流程处理：把其 contact status 设为 'Former Employee'，加一条说明他们去了哪里的 note，在 LinkedIn 上联系他们，并针对其新公司创建相应的跟进——如果该 account 我们已有，就建 re-engagement 任务；如果没有，就建新 lead。把摘要发到 #sales-alerts。在消息中包含源数据里的相关金额。

**要点**：对象仅限 description 含 'Champion' 的联系人；跟进形态取决于其新公司是否已是既有 account（有则 re-engagement 任务，无则新建 lead）。

## 1109 · `sales.linkedin_outreach_sequence`（断言 16，负 3）

**中文业务请求**

该把我们那份目标账户清单（spreadsheet_id: ss_targets_001，worksheet: ws_targets_001）过一遍了。为每家需要触达的公司找到合适的技术负责人，按我们当前的 outreach 政策发送个性化连接请求，并让 tracker 保持最新。在联系任何人之前，务必遵守我们当前的 do-not-contact 限制。为成功的触达创建跟进任务。

**要点**：do-not-contact 名单优先于目标清单（名单里的人一律不能联系），触达成功后要建跟进任务并回写 tracker。

## 1101 · `sales.linkedin_profile_enrichment`（断言 16，负 7）

**中文业务请求**

用 LinkedIn 数据补全 DataFlow Systems 这条 lead，做法和我们最近做过的其他 enrichment 一样。

**要点**：补哪些字段、怎么落笔要照搬近期 enrichment 的同一套口径（不能自行挑选字段），且不得覆盖或破坏原有正确值。

## 701 · `sales.linkedin_prospect_research`（断言 14，负 6）

**中文业务请求**

你能在 LinkedIn 上调出我们 Q1 Enterprise Deal 背后的那家公司，并按我们的频道路由政策把一份公司简介摘要发到合适的 Slack 频道吗？我们要用它准备 pipeline review。在消息中包含受影响实体的名称和相关金额。

**要点**：需先由 deal 反查出对应公司，再依频道路由政策选定频道；摘要里要点名受影响实体并给出金额。

## 1001 · `sales.linkedin_sales_prospecting`（断言 15，负 4）

**中文业务请求**

调研并联系 TechVentures Inc 在 San Francisco Bay Area 的 VP of Engineering。向其发送个性化的 LinkedIn 连接请求，内容要提到其工程领导角色、其资料上的行业与公司规模，以及我们 deployment optimization 的价值主张。然后把你查到的决策人细节更新到对应的 Salesforce lead 上，包括把其 LinkedIn 连接数写进 Lead Description，并将其标记为正在跟进。

**要点**：要先在公司里精确锁定「湾区 + VP of Engineering」这一个对象，连接请求须覆盖三个指定要点，回写时连接数要落进 Lead Description 且状态改为正在跟进。

## 840 · `sales.linkedin_signal_monitoring`（断言 9，负 2）

**中文业务请求**

在 LinkedIn 上监控目标账户的购买信号，例如高管入职、公司增长、融资公告或技术栈变更。对每一个检测到的信号，创建一条记录其细节的 Salesforce 任务，按信号强度更新对应 account 的优先级，并把预警发到 #buying-signals。在消息中包含受影响实体的名称。

**要点**：每个信号都要「建任务 + 按强度调整 account 优先级 + 发预警」三件事齐全，且只处理目标账户的信号。

## 104 · `sales.mark_vip_emails_read`（断言 14，负 0）

**中文业务请求**

今天是 2026 年 1 月 15 日。按我们的邮件处理政策处理 VIP 收件箱。

**要点**：处理范围与动作全部由邮件处理政策定义（哪些算 VIP、如何标记已读与归档）；该题没有负断言，说明任何一步漏做或错做都会直接扣分。

## 1116 · `sales.meeting_action_items`（断言 22，负 7）

**中文业务请求**

处理 'Quarterly Review - Apex Corp' 日历事件中的会议纪要。提取 action items，在 Salesforce 中把它们指派给正确的人，并更新 opportunity 记录。

**要点**：22 条断言意味着颗粒度很细：每个 action item 都要落到正确的负责人，opportunity 记录也须同步更新。

## 501 · `sales.multi_hop_lookup`（断言 6，负 3）

**中文业务请求**

我们刚拿下 Meridian Corp Platform Deal！把它标记为赢单，并按我们的路由政策把赢单通知发给正确的团队。务必遵循最新的路由指引。从 'Account Hierarchy' 表格确认 account tier，必要时做币种换算（见 'FX Rates' 表格），并检查是否存在尚未关闭的 support escalation。所有邮件都从我们的 Gmail 发出。

团队邮箱：support-escalation@example.com、executive-team@example.com、sales-team@example.com、smb-team@example.com、vp-sales@example.com

所有邮件一律用 Gmail 发送。在消息中包含受影响实体的名称和相关金额。

**要点**：收件团队要由「最新路由指引 + Account Hierarchy 里的 tier + 是否存在未关闭 escalation」多跳推出，金额还要按 FX Rates 换算。

## 1108 · `sales.multi_step_drip_campaign`（断言 13，负 3）

**中文业务请求**

执行今天的 drip campaign 轮次。今天是 2026 年 1 月 20 日。按我们的 cadence 政策处理这些 lead，并推进所有已到期的人。

**要点**：推进对象只能由 cadence 政策算出的到期日决定，未到期或已退出序列的 lead 一律不能动。

## 503 · `sales.negative_selection`（断言 17，负 10）

**中文业务请求**

把 Director 级别的联系人添加到 Q2 Executive Outreach 活动（ID：701xx000001EXE1）。务必遵循我们的活动纳入（enrollment）准则。

**要点**：负断言多达 10 条，只有同时满足 enrollment 准则的 Director 级联系人才可加入；误加级别不符或不符合准则的联系人即判错。

## 1206 · `sales.overdue_followup_flag`（断言 10，负 5）

**中文业务请求**

你能检查一下未关闭的跟进任务，把已逾期的都标记出来吗？CRM 里的状态可能不准确，别只信这些状态。对照我们的跟进政策判断什么算逾期。为每个逾期项创建一条已标记的任务，并把摘要发给 ops-team@crestline.example.com，只列逾期项——他们只想看需要处理的事，不要完整清单。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：CRM 状态不可信，逾期判定必须按跟进政策重算，邮件只含逾期项，数值原样引用。

## 1008 · `sales.partnership_contract`（断言 8，负 1）

**中文业务请求**

完成 Acme 的合作交易合同流程。按我们的标准政策处理合同，并在 Salesforce 中更新所有相关内容。

**要点**：必须走完标准政策规定的合同全流程，并把结果同步回 Salesforce 的各相关记录，不能只处理合同本身。

## 506 · `sales.priority_selection`（断言 8，负 7）

**中文业务请求**

Apex Manufacturing Corp 那边有一份安全公告需要发给正确的人。请处理这次路由。务必纳入关于该流程的任何近期指引。

**要点**：安全公告只能路由到 Apex Manufacturing Corp 中对口的唯一正确收件人，并遵循该流程的最新指引；负断言 7 条，说明发给任何其他人都算错。

## 5 · `sales.qualify_lead`（断言 10，负 4）

**中文业务请求**

让所有未关闭的 lead 走一遍我们的资格认定（qualification）流程。务必使用最新的资格认定政策及任何近期更新。

**要点**：必须采用最新资格政策（可能已覆盖旧版）逐条判定 lead，不能沿用旧标准，也不能漏掉任何 open lead。

## 504 · `sales.recency_selection`（断言 10，负 3）

**中文业务请求**

GlobalTech 的 Marcus Wong 的电话号码需要在 Salesforce 中更新。把你使用的来源记录在他记录的 note 中，并附上邮件 message ID，供我们审计追溯。

**要点**：多条渠道信息中必须选最新且正确的那条号码，note 里要写明来源并附上邮件 message ID。

## 1007 · `sales.call_transcription`（断言 7，负 2）

**中文业务请求**

查看 'Discovery Call - Acme Corp' 的销售通话录音并提取行动项。把后续事项分派给正确的人，更新商机，并把摘要发到该交易的频道。在消息中包含源数据里的相关金额。

**要点**：行动项要从录音内容里逐条落实给对的人，商机更新与频道摘要都不能漏，金额原样引用。

## 1002 · `sales.demo_scheduling`（断言 10，负 4）

**中文业务请求**

为 Enterprise Platform 商机安排一场 60 分钟的产品演示。创建 Zoom 会议，并按交易金额通知相应的频道。在通知中包含交易金额与会议详情。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：通知频道取决于 deal size 的分档，会议须为 60 分钟 Zoom，通知里金额原样不改并写明会议详情。

## 1006 · `sales.milestone_celebration`（断言 9，负 2）

**中文业务请求**

制作一份里程碑公告，庆祝我们的 ARR 成绩。从 Salesforce 中 Closed Won 的商机计算 ARR 总额（只计 Closed Won 的交易），然后通过 Canva 设计、带 #ARRMilestone 的 LinkedIn 帖子和发往 #sales-wins 的 Slack 消息来宣传。在 LinkedIn 帖子和 Slack 消息中都写出精确的 ARR 总额，格式为以 $ 开头、带千分位逗号的整数美元金额。仅在 Canva 设计中，使用保留一位小数的紧凑 $X.XM 形式；这一仅限设计的写法是获批的四舍五入例外。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。

**要点**：ARR 只能汇总 Closed Won 商机，LinkedIn 与 Slack 必须用带 $ 前缀和千分位逗号的整数美元，唯一允许的四舍五入是 Canva 里的 $X.XM 一位小数写法。

## 101 · `sales.send_customer_email`（断言 7，负 5）

**中文业务请求**

下周季度 pipeline 评审之前，有几件事需要理一理。伙伴集成文档需要更新——这事归 Dave，只是知会你一声。财务还在做 Q2 预测，市场部想就 webinar 系列对个 sync，但他们可以等。哦，还有 Priya 需要竞争格局的幻灯片——她会自己处理。

我唯一需要你（YOU）做的一件事：把最新的已批准定价发给 sarah.johnson@example.com，主题为 'Product Pricing Information'。今天是 2026-01-25。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称和相关金额。

**要点**：其余事项全是干扰，唯一要执行的是把最新获批定价发给 sarah.johnson@example.com 且主题固定，不能顺手替别人做事。

## 1130 · `sales.sheets_multi_channel_campaign_router`（断言 20，负 6）

**中文业务请求**

处理 Q1 活动目标表格（ss_campaign_001），按我们的路由政策通过相应渠道联系每个潜在客户。

在每一行更新所用的渠道和今天的日期（2026-01-21），然后把带渠道分布的摘要发到 #campaign-ops。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：渠道必须按路由政策逐人判定而非统一渠道，表格每行回写渠道与 2026-01-21，摘要含各渠道的数量分布。

## 520 · `sales.sheets_reconciliation`（断言 10，负 2）

**中文业务请求**

我们的销售跟踪表格（ID：'spreadsheet_sales_001'，工作表：'ws_deals_001'）需要与 Salesforce 对账。把每一行匹配到对应商机，在 Salesforce 数据更新时同步金额和阶段。用 'FX Rates' 表格处理账户之间的币种差异，并且不要动已关闭或已回退（regressed）的交易。

**要点**：只有 Salesforce 数据更新的字段才反向同步，跨币种要按 'FX Rates' 折算，已关闭/已回退的商机一律不能碰。

## 609 · `sales.slack_channel_for_new_account`（断言 11，负 2）

**中文业务请求**

我们刚签下 Pinnacle Financial Group 作为新的 Enterprise 客户。按我们的标准命名规范为其建立专属 Slack 频道（到 #general 查看置顶的频道规范），邀请客户团队加入，并更新 Salesforce 以反映该频道已创建。

**要点**：频道名必须严格按 #general 置顶规范生成，要邀请正确的 account team，并在 Salesforce 留下「频道已创建」的更新。

## 607 · `sales.slack_deal_notification`（断言 13，负 5）

**中文业务请求**

今天是 2026 年 2 月 20 日。我们刚拿下 Quantum Industries 的 Enterprise Platform 交易！按我们的标准流程把赢单通知发到 #deal-wins。务必遵循交易公告的最新流程指引。把该商机更新为 Closed Won，并注明你发布的位置。在消息中包含受影响实体的名称和相关金额。

**要点**：公告要按最新流程指引发布（渠道、格式、内容项可能已变），同时把商机改为 Closed Won 并在记录中写明发布位置。

## 515 · `sales.soft_matching`（断言 12，负 2）

**中文业务请求**

今天是 2026 年 2 月 20 日。NexGen 的 HR 发来一份联系人更新请求。在收件箱里找到它，并按我们的联系人匹配准则在 Salesforce 中更新正确那个人的电话号码。

**要点**：请求里的姓名/公司与 Salesforce 记录只是近似匹配，必须按匹配准则锁定唯一正确联系人，不能改错同名或相近的记录。

## 1203 · `sales.unreliable_label_account_review`（断言 7，负 4）

**中文业务请求**

嘿，能帮我把 QBR 要用的风险客户整理出来，并把摘要发给客户团队 account-team@company.example.com 吗？我想确保我们依据的是健康度标准表格，而不只是 Salesforce 里的内容——那些标签有段时间没更新了。也查一下活动日志，判断出到底谁才真正有风险。邮件里只放风险客户——团队只想看需要担心的那些，不要完整名单。在消息中包含源数据里的相关金额。

**要点**：不能信 Salesforce 里过期的 health 标签，必须按健康度标准表加活动日志重算，邮件只列真正 at-risk 的客户。

## 1 · `sales.update_contact_phone`（断言 8，负 1）

**中文业务请求**

处理 HR 发来的电话更新请求。

在收件箱中找到 HR 更新团队发来的最新一批邮件，把电话变更应用到匹配的 Salesforce 联系人上。妥善处理任何冲突或重复项。为你实际应用的每次更新创建一条 note。

**要点**：要取「最新一批」而非更早的邮件，冲突/重复联系人须按规则处置，且每应用一条更新都要留 note。

## 1205 · `sales.vendor_review_prep`（断言 7，负 4）

**中文业务请求**

嘿，能帮采购团队整理一份供应商评审摘要吗？从 Salesforce 拉取当前供应商账户，把摘要发到 procurement@ironforge.example.com。务必遵循我们的供应商评审准则。只列符合评审条件的供应商及其年度合同金额——采购团队不需要完整名单，只要那些要评审的。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：必须按评审准则筛出「符合条件」的子集而非全发，并附上各自的年度合同金额且原样不改。

## 516 · `sales.weighted_priority`（断言 4，负 3）

**中文业务请求**

今天是 2026 年 2 月 20 日。我们需要按当前 lead 评分框架联系优先级最高的 hot lead。评估所有 hot lead，找出最佳潜在客户。

给胜出者发一封个性化外联邮件。主题应为 'Priority Outreach'，正文包含其姓名、公司，以及一句我们希望聊聊如何帮助其业务的话。

**要点**：必须在全部 hot lead 上按评分框架算出唯一最高分者，邮件主题固定为 'Priority Outreach'，正文要含姓名、公司与那句意向说明。

## 819 · `sales.zoom_attendance_pipeline`（断言 11，负 1）

**中文业务请求**

今天是 2026 年 2 月 20 日。查看上周的 Zoom 会议，判断每场会议的出席情况如何，并据此更新 pipeline 以反映参与度水平。查看 Engagement Scoring Policy（spreadsheet='ss_engagement_policy'，worksheet='ws_tiers'）以确认各档阈值与对应动作。把参会人匹配到他们的 Salesforce 商机并执行正确更新。只更新仍处于活跃 pipeline 阶段的商机。把结果发到 #pipeline-updates。在消息中包含受影响实体的名称和相关金额。

**要点**：出席率要按政策表分档并执行对应动作，只改仍在活跃阶段的商机，已关闭或停滞的不能动。

## 603 · `sales.zoom_calendar_conflict`（断言 11，负 2）

**中文业务请求**

2026 年 2 月 20 日下午 2:00 我们有一个日程冲突——一场 Zoom 会议和一个 Google Calendar 事件撞在同一时间。查看表格中的会议优先级政策，确定哪一个胜出，然后把优先级较低的那个改期：在其 topic/title 前加上 '[RESCHEDULED] '，并把摘要发到 #ops-updates Slack 频道，说明哪场会议胜出、哪个被改期（消息中要同时包含 Zoom meeting ID 和 Calendar event ID）。在通知或记录中引用源数据里的值时，请原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：胜出方要按表格里的优先级政策判定，只能改低优先级那个且前缀必须是 '[RESCHEDULED] '，摘要里两个 ID 都要给出。

## 601 · `sales.zoom_crm_meeting`（断言 4，负 2）

**中文业务请求**

Innovate 那边有人发来 demo 请求——请安排一下。查看邮件获取细节，在 Salesforce 中确定正确的 account，并安排一场 60 分钟的 Zoom demo：2026-02-20 14:00 UTC，主持人为 demos@ourcompany.example.com。Topic 应为 'Product Demo - [Account Name]'。把最合适的对象登记为参会人。请考虑可能已传达的任何现行指引。

**要点**：account 要从邮件线索里正确辨认（不能随便挑 Innovate 相关记录），topic 模板要替换成真实 account 名，参会人须是最合理的那个。

## 838 · `sales.zoom_customer_health`（断言 6，负 2）

**中文业务请求**

又到了季度客户健康度检查。调出评分政策，用 Zoom 的参与度数据对我们的账户跑一遍数字。为每个账户分类，更新 Salesforce，把任何值得警惕的情况报到 #cs-alerts，并在需要的地方创建任务。

今天是 2026-02-20。

**要点**：分类必须按评分政策用 Zoom 参与度数据重算，告警只发有问题的，该建任务的地方不能漏。

## 807 · `sales.zoom_meeting_followup`（断言 11，负 3）

**中文业务请求**

Horizon Dynamics 的 discovery call 刚结束。能按我们一贯的做法处理后续跟进吗？同时确保商机阶段反映我们当前的进展。在消息中包含受影响实体的名称。

**要点**：后续跟进要按既有惯例（邮件、任务、记录等固定动作）全套执行，商机阶段也要同步推进到与现状相符的位置。

## 1200 · `sales.zoom_meeting_roi_analysis`（断言 10，负 4）

**中文业务请求**

分析 Q1 账户的会议 ROI。查看发布在 #sales-ops 的 ROI 政策，把表现不佳的交易标记出来待评审，并把摘要发给 sales ops 团队。

**要点**：ROI 口径要按 #sales-ops 里的政策（可能有更新版），只标记 underperforming 的交易并附摘要给 sales ops。

## 1165 · `sales.zoom_recording_distribution_basic`（断言 10，负 2）

**中文业务请求**

今天是 2026 年 1 月 21 日。昨天那场 TechClient demo 需要做惯例的录制后续处理。按我们上周处理 Acme demo 的同一方式来办。

**要点**：必须复刻上周 Acme demo 的既有处理方式（同样的分享对象、邮件模板与记录动作），自创流程或漏掉惯例步骤即为错。

## 814 · `sales.zoom_recording_distribution`（断言 16，负 3）

**中文业务请求**

今天是 2026 年 2 月 20 日。按我们的分发政策分发昨天已完成的 Zoom 会议录制。把每份录制路由到正确的受众，并把分发记录到 #recording-log。在消息中包含受影响实体的名称。

**要点**：受众路由要按分发政策逐场判定（含限制与排除条件），每份分发都要在 #recording-log 留痕并点名受影响实体。

## 1170 · `sales.zoom_recurring_meeting_optimizer`（断言 6，负 2）

**中文业务请求**

今天是 2026 年 1 月 21 日。MajorClient 的 account review 会议需要处理。查看目前的运行情况并采取适当行动。在消息中包含受影响实体的名称。

**要点**：要先查这类周期性会议的现状（出席率、空转等实际数据）再决定优化动作，不能凭印象直接取消或改期。

## 1172 · `sales.zoom_regional_webinar_coordinator`（断言 9，负 4）

**中文业务请求**

按我们的区域会议政策，按地区处理 Global Product Update 网络研讨会的报名者。处理后续会议、参会者登记、邮件，并把摘要发到 #regional-sales。在消息中包含受影响实体的名称和相关金额。

**要点**：报名者要按所属区域分别套用区域会议政策（各区域规则不同），后续会议、登记、邮件、摘要四类动作都要做，消息须带名称与金额。

## 803 · `sales.zoom_webinar_lead_capture`（断言 15，负 4）

**中文业务请求**

为 Q1 Product Roadmap 场次（meeting_id：'mtg_webinar_q1'）处理网络研讨会后续。按 webinar config 中的 engagement tiers 处理结果。在消息中包含源数据里的相关金额。

**要点**：与会者须按 webinar config 里的 engagement tiers 分层处理（层级不同动作不同），消息中的金额必须取自源数据。

## 1163 · `sales.zoom_webinar_lead_scoring`（断言 8，负 1）

**中文业务请求**

今天是 2026 年 1 月 22 日。为最近的 Product Launch 2026 网络研讨会的 leads 打分。使用评分量规（scoring rubric），在 Salesforce 中创建 leads，并带上相应的 ratings，把分数明细写进 description。

**要点**：rating 必须由评分量规算出，description 中要拆出各项得分明细，只给总分或凭感觉定级即为错。
