# Automation-Bench 公开集中文翻译 · operations（第 1–25 条）

## 1323 · `operations.access_request_validation`（断言 12，负 5）

**中文业务请求**

我们有一批系统访问权限申请需要处理。查看访问管理表格 ss_access_requests——待处理队列在 worksheet ws_queue 中，员工目录在 ws_directory 中。今天是 2026-02-09。

对每份待处理申请，检查申请人的经理是否有足够的职级（seniority）来批准所申请的访问级别。

按 ws_provisioning_routing 中的 IT 开通路由规则处理每份申请。已标记为已处理的申请应完全跳过。

今天是 2026-02-09。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：批准与否取决于经理职级是否足以覆盖所申请的访问级别，且必须按 ws_provisioning_routing 分流、完全跳过已处理项。

## 1232 · `operations.airtable_gmail_visitor_followup`（断言 5，负 2）

**中文业务请求**

前台送来了一份访客 NDA 已完成的通知——你能把它记录到 Airtable 并通知接待方（host）吗？

查看 frontdesk@company.example.com 发来的、关于某位访客 NDA 的最新邮件。更新 Airtable 的访客记录（base_ops / Visitors 表），加一条评论注明 NDA 已完成，并发送邮件至 host-ops@company.example.com 通知接待方。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：要从邮件里认出是哪位访客，更新到正确的 Visitors 记录而不是新建；评论须点明 NDA 已完成，通知对象是 host-ops 而非前台。

## 1217 · `operations.asana_basecamp_move_planning`（断言 8，负 4）

**中文业务请求**

我们需要为办公室搬迁 Phase 1 的地面平面图签字确认（floor plan signoff）安排日程。

在搬迁计划表（ss_move_plan）中查找下一个 Phase 1 的 floor plan signoff 任务。该表中还写有搬迁任务政策，所以在安排任何事项之前先审阅这些政策。

在 Move 项目（ws_ops/proj_move）的 Planning 分区下创建一个带 Move tag 的 Asana 任务，并添加对应的 Basecamp todo（acct_ops/proj_move，set_move/list_signoff）。把所选行的 Task 值逐字用作 Asana 任务名和 Basecamp todo 内容，并用它的 Due date 作为两者的截止日期。

**要点**：须先用表中的搬迁任务政策筛掉不该排的行；Asana 任务名与 Basecamp todo 内容必须逐字取所选行的 Task 值，两侧截止日期同源于该行 Due date。

## 1201 · `operations.asana_fire_drill`（断言 11，负 6）

**中文业务请求**

设施团队刚发来了消防演习的信息——你能把它添加到 Asana 的 Facilities 项目（workspace ws_ops，project proj_facilities）的 February 分区下吗？

查看设施团队发来的、关于消防演习的最新未读邮件，从中取得任务详情、截止日期以及该用哪个 tag。要确认它确实是关于消防演习的，而不是其他设施事务。

在创建任务之前，先检查表格 ss_ops_policy（worksheet ws_email_rules）中的邮件处理政策，看其中是否有关于哪些邮件应处理、哪些不应处理的规则。

创建完成后通知 #ops-updates。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：最新未读邮件必须是消防演习主题（不能误按其他设施事务处理），建任务前还须过一遍邮件处理政策，最后在 #ops-updates 通报。

## 1208 · `operations.asana_safety_walk_log`（断言 10，负 6）

**中文业务请求**

Q1 的安全巡检（safety walk）要到了——你能为 Main building 安排下一次吗？

查看安全巡检日程表（ss_ops_safety），找到 Main building 的下一次 Q1 检查——该日程表里也有排期指南，所以先审阅那些指南。

在 Facilities 项目（ws_ops/proj_facilities）的 March 分区下创建一个带 Safety tag 的 Asana 任务。任务名用 'Quarterly Safety Walk - [Area]'，其中 [Area] 是被检查的区域。把截止日期设为检查日之后 3 天，以便留出时间完成巡检报告。

同时把它记录到我们的跟踪表（ss_ops/ws_log）中，写明任务详情，owner 填 Facilities。

**要点**：任务名要把 [Area] 替换成实际受检区域，截止日期 = 检查日 + 3 天，且必须先看日程表里的排期指南再选行。

## 1235 · `operations.asana_slack_sheets_audit`（断言 10，负 5）

**中文业务请求**

该安排 Q1 运营审计了。你能创建 Asana 任务并做记录吗？

查看 Audit Calendar 表格，找到下一个 full-scope 的 Q1 审计——那里也有排期政策，所以在挑选任何一条之前先审阅这些政策。在 Asana 的 compliance 项目、Q1 分区下创建一个名为 'Q1 Ops Audit' 的任务，打上 Audit tag，并使用所选审计行的截止日期。把它记录到审计日志表格中，并发布到 #ops-updates。

**要点**：只能选 full-scope 的 Q1 审计，且须先按排期政策排除不合规的行，任务名/tag/分区/截止日期四个字段都要和所选行对上。

## 1320 · `operations.buffer_engagement_optimization`（断言 14，负 6）

**中文业务请求**

我想根据互动数据找出社交媒体最佳发布时间。你能分析一下我们的发帖模式吗？

从 Buffer（organization_id: org_001）拉取最近的帖子，并按 ss_social_analytics（ws_config）中的分析配置进行筛选。按小时和星期几拆分，看看我们在什么时候获得的互动最好。

按分析配置里的判定标准，找出表现最好和最差的时间段（若有并列，优先取更早的时间）。互动率用带百分号的整数百分比表示。创建一个名为 'Posting Schedule Optimization' 的 Notion 页面，写入发布时间安排建议；把分析结果记录到 ss_social_analytics（ws_timing）；并在 #social-strategy 中分享最佳时段、应避免的时段以及推荐的每周发布安排。

今天是 2026-01-28。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含源数据里的相关数值。

**要点**：时间槽按「小时 × 星期几」聚合，并列时取更早时段，互动率必须写成带 % 的整数；筛选口径来自 ws_config 而非默认假设。

## 1236 · `operations.calendar_airtable_gmail_maintenance_notice`（断言 11，负 6）

**中文业务请求**

我们有一个已批准的机房（data closet）断电计划需要安排。你能把它安排好么？

查看 Maintenance Plan（ss_maint_plan）中已批准的 Data Closet 断电详情——先审阅计划中的所有排期指南，然后把它添加到 cal_ops，记录到 Airtable 记录 rec_200（base_ops / Maintenance），并通知 it-ops@company.example.com。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：必须挑「已批准」的那条断电计划，且先读完所有排期指南再落日历/Airtable/邮件三处，三处的日期时间要一致。

## 1206 · `operations.calendar_airtable_maintenance`（断言 9，负 7）

**中文业务请求**

该安排仓库的 HVAC 维护了——你能找到下一个已批准的窗口并排进日历吗？

查看维护窗口表（ss_maint_windows/ws_windows），寻找仓库已批准的 HVAC 作业。我们这里只处理主 HVAC 系统——辅助系统走另一套流程。近期有一些政策变更和供应商确认，可能会影响哪些窗口实际可用，所以在确定之前要把完整情况拼起来看清楚。

把它添加到运营日历（cal_ops），并记录到 Airtable 维护日志（base_ops/Maintenance，记录 rec_14）。

**要点**：只有主 HVAC 在范围内（辅助系统另有流程），且近期政策变更与供应商确认会推翻表里看似可用的窗口，必须交叉核对后再落库。

## 1222 · `operations.calendar_slack_training`（断言 15，负 9）

**中文业务请求**

需要把下一次叉车安全培训排进日历。

查看培训日程表并安排下一个可用的场次。务必同时检查所有培训政策工作表，看是否有排期要求。把它作为一场叉车安全培训事件添加到运营日历（ops calendar），使用该场次的实际时间。

就排定的培训通知 #ops-updates——要包含日期和讲师姓名。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：不能只看第一个可用场次，须遍历所有培训政策工作表确认排期要求；日历事件用场次实际起止时间，Slack 通报必须带日期与讲师姓名。

## 1249 · `operations.calendly_equipment_inspection`（断言 8，负 2）

**中文业务请求**

我们需要安排最紧急的那项逾期设备检查。查看 ss_equipment（worksheet ws_inspections），并在 ss_inspectors（worksheet ws_certified）中找到有资质的检查员。

为 2026-02-03T09:00:00Z 预订一个 Calendly 会议，记录到 Airtable（base_equipment/'Inspection Schedule'）并把 Status 设为 'Scheduled'，在 Notion（pg_inspections）中存档，发邮件给 facilities@company.example.com，并发布到 #facilities。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含源数据里的相关数值。

**要点**：要挑「最紧急且已逾期」的那台设备，且检查员必须在 ws_certified 中对应该设备类型，不能随便指派人。

## 1296 · `operations.canva_asset_management`（断言 12，负 7）

**中文业务请求**

你能整理一下 Canva 里的新营销素材吗？找出同时带 'approved' 和 'q1-2026' 标记的设计，并把它们导出为 PNG。

把导出的文件移动到 Google Drive 中的 'Marketing Assets Q1 2026' 文件夹。

然后通知 #design-team 新素材已可用——列出设计名称并附上 Drive 文件夹链接。

处理之前请先检查是否有素材管理规范。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。在你的消息中包含相关数量。

**要点**：必须同时满足两个 tag 的设计才算，且需先读素材管理规范（可能限定可导出/可移动范围），Slack 消息要含设计名清单、文件夹链接和数量。

## 1283 · `operations.chatgpt_feedback_analysis`（断言 28，负 17）

**中文业务请求**

需要你过一遍客户反馈邮件，并按情绪（sentiment）分流。

查找最近 24 小时内（自 2026-01-29 起）主题中含 'Feedback' 的未读邮件。跳过已打上 'PROCESSED' 标签的，以及来自内部 @company.example.com 地址的邮件。

用 ChatGPT 分析每封邮件的情绪——positive、negative 或 neutral。

按情绪分析结果和反馈配置表格中的分流规则，对每封邮件进行分流——检查路由规则以及任何 override 工作表。处理完成后，把所有处理过的邮件标记为已读。

今天是 2026-01-29。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：三重筛选（未读 + 主题含 Feedback + 24 小时内）再叠加两类排除（PROCESSED 标签、内部域名），然后按路由规则与 override 工作表分流，最后统一标为已读。

## 1369 · `operations.chemical_inventory_safety_audit`（断言 25，负 8）

**中文业务请求**

对我们的化学品存储做一次安全审计。查看化学品库存表格，并在继续之前审阅审计政策规则。

同时检查收件箱，看是否有可能影响本次审计的供应商来函。

标记出存在以下问题的化学品：
1. SDS 已过期（SDS Expiry Date 早于 2026-02-09）——在每张 Jira 工单的 summary 中包含逾期天数
2. 存储不兼容——Compatibility Group 为 'A' 的化学品不得与 'B' 组化学品存放在同一 Storage Location

排除 Status = 'In Transit'（临时位置）或 Status = 'Pending Disposal'（正在清运）的化学品。

对每个被标记的化学品，在 Jira 项目 SAFETY 中创建一张安全工单，包含化学品名称、issue type、位置，以及逾期天数（针对 SDS 问题）。把完整审计结果通过邮件发送给 EHS 经理（ehs.manager@company.example.com）——邮件中只包含被标记的化学品；不得在邮件正文任何位置提及被排除的化学品（In Transit、Pending Disposal 或 de minimis）。把任何存储不兼容的发现发布到 Slack 的 #safety-critical——这些是最紧急的问题。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：SDS 过期与兼容组混放是两条独立判定，逾期天数须逐条算准；邮件正文只能出现被标记项，连 de minimis 这类被排除项都不得提及，混放问题还要单独发 #safety-critical。

## 1394 · `operations.compressed_gas_cylinder_tracking`（断言 13，负 10）

**中文业务请求**

审计压缩气瓶库存的水压试验（hydrostatic testing）合规情况。查看气瓶库存（ss_cylinders，ws_inventory）。气瓶须自其 Last Hydro Test 日期起每 5 年做一次水压试验。今天是 2026-02-09。

重要规则：
- Contents Status 为 'Empty' 的气瓶应退回供应商，而不是送检。不要为空瓶创建试验工单。
- Ownership 为 'Rental' 的气瓶由租赁公司负责试验——跳过这些。
- 只处理 Ownership 为 'Company-Owned' 且 Contents Status 为 'Full' 或 'Partial' 的气瓶。

对每个逾期的公司自有气瓶，在 Jira 项目 'SAFETY' 中创建工单，summary 为 'Hydro Test Required - [Cylinder ID]'，并包含气体类型、位置和上次试验日期。

就每个位置，给该位置的安全负责人（取自 ws_safety_officers）发邮件，列出其区域内所有逾期气瓶。

今天是 2026-02-09。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只有 Company-Owned 且 Full/Partial 的气瓶才建单，Empty 与 Rental 必须排除；逾期判定为上次水压试验日 + 5 年，且邮件要按位置归属发给对应安全负责人。

## 1356 · `operations.conference_room_booking_conflicts`（断言 19，负 10）

**中文业务请求**

检查 Google Calendar 中 2026 年 2 月 10 日的会议室预订。每个事件的 summary 以方括号中的房间名开头，例如 '[Room A] Meeting Title'。

找出同一房间中两个定时事件时间重叠的重复预订。全天事件与定时事件不构成冲突。名称相似但不同的房间（例如 'Room A' 与 'Room A1'）不是同一个房间。

对每个冲突，把详情发布到 Slack 的 #office-ops，包括两个事件的名称、房间以及重叠的时间段。同时给出发现的冲突总数，以及所有冲突的重叠分钟数总和。

给后创建（event ID 数值更大）的那个事件的组织者发邮件，请其改期。组织者邮箱在事件的 description 字段中。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只算同房间两个定时事件的重叠（全天事件不算、'Room A' 与 'Room A1' 不算同房间），并要汇总冲突总数与重叠总分钟数；催改期的邮件只发给 event ID 更大的那一方。

## 1212 · `operations.confluence_gmail_policy_notice`（断言 10，负 5）

**中文业务请求**

我们需要发布当前已批准的访客政策，并知会 Security。

查看政策更新表（ss_policy），找到处于生效状态且已批准的访客政策。该表也有处理规则，所以在挑选任何内容之前先审阅这些规则。

在 SP_OPS（cloud_ops）中创建一个 Confluence 页面，标题为 'Visitor Policy Update - 2026'，写明生效日期与变更内容。

发邮件给 security@company.example.com 告知此次更新（主题：'Visitor Policy Updated'）。

今天是 2026-01-31。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只能选「当前生效 + 已批准」的那条访客政策（处理规则可能把其他行排除掉），Confluence 标题与邮件主题须与要求一字不差。

## 1353 · `operations.contract_renewal_pipeline`（断言 20，负 11）

**中文业务请求**

嘿，我需要你提前把我们的供应商合同续约安排好。接下来几个月有一批要到期，我们不希望任何一份失效。

查看我们的合同跟踪表（ss_contracts，ws_active），找出近期需要处理的事项——其中还有一个续约政策工作表（ws_policy），定义了我们的续约窗口。自动续约的都没问题，只需关注需要人工处理的那些。显然，已经处理过的合同要忽略。

对符合条件的事项，把 DocuSign 续约协议发给供应商联系人。使用续约模板——DocuSign 里应该有一份。

把即将到期事项的汇总同步给采购团队（procurement@ourcompany.example.com）。今天是 2026 年 2 月 9 日。

**要点**：只处理「需人工续约 + 落在续约窗口内」的合同（自动续约的不管、已处理的跳过），模板必须取 DocuSign 里的续约模板，汇总发给采购团队。

## 1339 · `operations.contractor_badge_expiration`（断言 18，负 8）

**中文业务请求**

嘿，安全团队在问即将到期需要续期的承包商徽章。你能查看表格 ss_badges，标出徽章在未来两周内到期的所有人吗？今天是 2026-02-09。

对每个需要处理的承包商，给他们发短信、给其公司联系人发邮件，并把这件事发布到安全频道。务必包含徽章编号，好让他们知道说的是哪一张徽章。

不用管已终止合作的承包商，也不用管已经续过期的徽章。显然，早就过期很久的属于另一类问题。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只标「未来两周内到期」的徽章，已终止、已续期、早已过期三类都要排除；每条通知都必须带徽章编号，且三种渠道都要发。

## 1331 · `operations.contractor_onboarding_workflow`（断言 13，负 7）

**中文业务请求**

处理新承包商入职队列。在承包商管理表格中查找 Status 为 'Pending Onboarding' 的条目。

对每个待入职承包商，在入职项目的 'New Contractors' 分区下创建一个 Asana 入职任务，任务标题只用承包商姓名，截止日期用其开始日期。

给每位待入职承包商的个人邮箱发一封欢迎邮件，写明其开始日期和表格中的汇报经理姓名。

承包商表格中还有其他包含入职政策的工作表——处理前请先审阅。

不要为已标记为 'Onboarding Complete' 或 'Active' 的承包商创建任务或发送邮件。

今天是 2026-02-09。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只处理 Status 为 'Pending Onboarding' 的人，任务标题只用姓名（不加前缀），且必须读过额外的入职政策工作表再动手。

## 1360 · `operations.cross_department_budget_reconciliation`（断言 20，负 8）

**中文业务请求**

财务部要求对 Q1 各部门支出做一次快速核对。你能打开预算跟踪表，看看我们现在处在什么位置吗？我知道本季度内有一些预算调整获批，在把实际数与计划对比之前需要先把它们计入。检查所有工作表——里面应当有支出数据、调整、政策规则和部门联系人。

标出任何显著超出其调整后预算的部门——CFO 想了解超出政策页中差异阈值（variance threshold）的超支情况。就各部门辖区内的任何问题知会相关部门的负责人，并在 Slack 的财务告警频道发布一条提醒。

不要把未获批准的调整计入。今天是 2026 年 2 月 9 日。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只有已批准的调整才能计入 adjusted budget，超支判定用政策页的 variance threshold，且只通知确有问题的部门负责人。

## 1380 · `operations.cross_training_assignment`（断言 19，负 13）

**中文业务请求**

本季度我们在推进一项跨岗培训计划。你能查看技能矩阵（skills matrix），找出哪些人在其岗位所需技能上存在缺口吗？有一个培训表格（ss_training）。

对任何缺少必备能力的人（不必考虑 optional/nice-to-have 技能），在培训项目中创建一个 Asana 任务，并给他们发邮件，附上一份培训计划，列出他们需要学习的内容。跳过已经安排了培训的人。

只标记 required 技能的缺口——optional 技能是加分项，不是强制要求。

给每个人的邮件中，要包含他们所缺 required 技能的总数，以便他们了解培训计划的范围。

今天是 2026-02-09。

**要点**：只看 required 技能缺口（optional 不算），已排培训的人要跳过，每人邮件都要写明缺口数量。

## 1280 · `operations.docusign_annual_review`（断言 20，负 14）

**中文业务请求**

该启动 2026 年度评估周期了。你能从准备就绪的最大部门开始吗？

在发起任何事项之前，先审阅当前的评估政策——Q1 对资格标准有过一些更新。查看部门表格，找出有待完成的 2026 年评估且预算已获批的部门。跳过任何未获预算批准的部门。选 headcount 最高的那个——若有并列，取评估开始日期最早的。确定部门后：
- 通过 DocuSign 把年度评估确认模板发送给该部门负责人
- 安排一个 2 小时的 Zoom 校准会议，名称为 '<Department> Review Calibration'
- 创建一个名为 '<Department> 2026 Review Cycle' 的 Monday 事项，用于跟踪评估周期
- 在 HR 空间中创建一个标题为 '2026 Review Cycle: <Department>' 的 Confluence 页面
- 在该部门的 Slack 频道中公布评估周期——要包含该部门的 headcount 以及有多少个部门被评估为符合条件

在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：资格须同时满足「2026 年评估待办 + 预算已获批」并按 Q1 最新标准判定；排序用 headcount、并列比开始日期；五个下游动作加上公告里的两个数字都不能错。

## 1262 · `operations.docusign_contractor_offboard`（断言 8，负 3）

**中文业务请求**

我们有一些承包商合同本周到期（2026-01-27 至 2026-02-02），需要启动离职（offboarding）流程。查看 Contractor Contracts 表（ss_contractors/ws_active），找出最需要先处理的一份——只处理已具备离职条件的承包商（active 且已签署 NDA），按 End Date 最早优先，并用 Security Clearance 等级（High > Standard > None）作为并列时的排序依据。

通过 DocuSign 把 'Contractor Exit Agreement' 发送给他们（CC hr@company.example.com 和 legal@company.example.com），在 Trello 看板 brd_hr 上建立跟踪：在 'Offboarding' 列表中创建 'Offboard: <Contractor Name>'，在 Notion（pg_offboarding）中存档，并通知 #hr-ops 及其经理。

今天是 2026-01-29。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：只处理 active 且已签 NDA 的承包方，排序先按最早 End Date、再按 Security Clearance 高低破平，且五个动作（DocuSign、Trello、Notion、#hr-ops、经理）一个不能少。

## 1253 · `operations.docusign_lease_renewal`（断言 8，负 4）

**中文业务请求**

该处理我们最大的一笔租约续签了。查看办公室租赁表（ss_leases，ws_active），找出最重大且已可续签的商业租约。

通过 DocuSign 把续约文件（使用 'Commercial Lease Renewal' 模板）发送给房东，CC facilities@company.example.com 和 finance@company.example.com。在 'Facilities Management' 项目中创建一个标题为 'Lease Renewal: [Office Name]' 的 Jira 任务，在 Notion（pg_leases）中以 'Lease Renewal - [Office Name]' 为题存档，并给房东发一封主题为 'Lease Renewal Notice: [Office Name]' 的邮件，确认 DocuSign 文件已发送。在你的通知或记录中引用源数据里的数值时，请原样保留（不要改写或四舍五入）。

**要点**：要挑「最重要且已可续签」的商业租约，DocuSign 模板、Jira/Notion 标题中的 [Office Name]、以及房东邮件主题必须对应同一份租约。

## 1276 · `operations.docusign_prospect_nda`（断言 9，负 4）

**中文业务请求**

我们有几位潜在客户在等待技术演示，但他们需要先签 NDA。你能发一份给价值最高的那位潜在客户吗？

查看 Demo Requests 表（ss_demos/ws_pending）中需要 NDA 的技术演示申请。该表格还有若干包含 NDA 政策的工作表——在选择之前先看这些。挑出预估价值最高的那一个。

确定潜在客户之后：

- 通过 DocuSign 把 'Mutual NDA' 模板发给他们，抄送 legal@company.example.com
- 在 Airtable（base_sales/NDA Log）中登记，把公司填进 Company，预估价值填进 Value
- 给联系人发邮件，确认 NDA 已发出

**要点**：附加的 NDA 政策工作表可能把部分客户排除在外，「最高价值」必须在排除之后重新排序，不能只看主表。

## 1205 · `operations.drive_notion_archive`（断言 10，负 7）

**中文业务请求**

Ops 有人发邮件说要归档一份供应商清单——你能处理一下吗？

查看 ops@company.example.com 关于供应商清单的最新邮件。他们想让我们归档 Q1 供应商清单的最终版。

在 Drive 里找到正确的文件，把它移到 archived vendors 文件夹。然后在 Notion 的 pg_ops 下记录文件名和归档详情。

**要点**：邮件说的是「最终版」，Drive 里往往同时躺着草稿与旧版本，必须按邮件指认的那一版归档，而不是按修改时间取最新。

## 1221 · `operations.drive_notion_lease_archive`（断言 16，负 12）

**中文业务请求**

法务标出了几份要归档的租约——你能处理吗？

查看 legal@company.example.com 关于租约归档的邮件。他们标出了几份要归档的租约。

先和租约状态表交叉核对，并在归档任何东西之前查看归档政策工作表。我知道最近有一些政策更新和澄清在流转，所以要确保掌握完整情况。可能还有别的与这些租约相关的邮件，行动前把所有内容都仔细读完。

对每一份已到期的租约：把文件移到 Drive 里的 legal 文件夹，并在 legal 父页面下创建一个 Notion 页面，标题为 '<File Title> (Archived)'，内容为：'Archived file <file_id> to Legal folder <folder_id> on 2026-02-03. (<N> leases reviewed, <M> archived.)'，其中 N 是状态表中的租约总数，M 是你实际归档的数量。

**要点**：只有「已到期」且政策允许的租约才归档；正文里 N/M 的口径（状态表总数 vs 实际归档数）与日期写法必须逐字照抄。

## 1213 · `operations.drive_slack_dock_schedule`（断言 21，负 16）

**中文业务请求**

物流那边需要我们共享 2 月最新的 dock schedule 版本。

查看 logistics@company.example.com 关于 dock schedules 的邮件，判断哪个版本是最新的。把最新的 dock schedule 版本移到 ops 共享文件夹，同时把上一个版本移到 archive 文件夹。

注意只处理 dock schedules，不要碰 warehouse schedules。我记得物流最近还发过一些 distribution rules，所以在移动任何东西之前先看 distribution policy 表。可能还有一张覆盖 QA clearance 的 release tracking 表——ops 最近对这块更严格了，确保没有未经正式签核的东西流出去。

最新版本共享后通知 #ops-updates，并附上你移动的文件总数和 QA 参考编号，好让物流核对。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：dock 与 warehouse 日程极易混，且必须先过 distribution policy 与 QA release tracking 两道闸；通知要带文件总数与 QA 编号。

## 1336 · `operations.energy_consumption_anomaly`（断言 12，负 8）

**中文业务请求**

设施团队想让我们看一下能耗数据，把异常的地方标出来。能耗表里有最近几个月的读数。

把每栋楼最近一个月的数据与它自身的历史趋势比较。如果某栋楼当前用量明显高于正常水平——我们对「异常」的阈值定义在同一表格的 config 工作表里——就标出来。

把异常发到设施运营 Slack 频道，并给设施总监发邮件。要包含实际用量、预期基线，以及偏离幅度。跳过数据不完整的楼。

今天是 2026-02-09。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：阈值不是常识值而是 config 工作表里写死的，判定是「显著高于」而非任何波动；数据不完整的楼要跳过，不能按缺失值硬算。

## 1348 · `operations.equipment_calibration_scheduling`（断言 15，负 7）

**中文业务请求**

实验室主任想确保我们对即将到来的校准心里有数。你能查一下哪些仪器快到期了，并为每一台建好跟踪任务吗？

看校准跟踪表（spreadsheet ss_calibration），并确保遵循当前的校准政策——最近可能有暂停（hold）或覆盖（override）通知。未来两周内到期的都要建 Asana 任务。另外给实验室经理准备一封汇总邮件。

不用管已停用（out of service）的仪器，以及已经安排好校准的仪器。今天是 2026-02-09。

**要点**：政策里的 hold/override 会改写「两周内到期」这份名单，已停用与已安排校准的两类都要排除。

## 1330 · `operations.equipment_lease_processing`（断言 17，负 9）

**中文业务请求**

该处理设备租赁队列了。我们有几份已批准的申请需要发出 DocuSign 协议，但发出前要确认每一份都落在部门剩余租赁预算之内。

租赁表（ss_leases）里有申请、部门预算和采购政策。也检查一下各条申请上的备注或标记。只处理「已批准」且「预算可负担」的申请。如果某个部门有多份已批准申请，按顺序处理——按 request ID 先到先得。一旦某部门预算用完，该部门剩下的申请就不能再处理。

每处理一份，就把 DocuSign 租赁协议发给供应商、给申请人发确认邮件，并把详情发到 #procurement。

在 Slack 汇总里包含所有已处理租约的月度承诺总金额。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：按 request ID 顺序贪心扣减部门预算，预算耗尽后同部门申请必须放弃；Slack 汇总要给月度承诺总额。

## 1313 · `operations.facebook_roas_monitoring`（断言 12，负 4）

**中文业务请求**

嘿，能帮我看一下我们 Facebook 广告的 ROAS，把需要注意的标出来吗？

从 ss_fb_ads（ws_daily 工作表）拉取昨天的表现数据，计算每个广告系列的 ROAS（收入除以花费）。

如果某广告系列 ROAS 低于 1.0，那是严重问题——我们在亏钱。通知 #paid-social 并邮件告知 paid-social-lead@company.example.com。如果 ROAS 高于 4.0，那是放量机会——告诉 #paid-social 我们可以考虑加预算。

把所有异常记录到 ss_ad_anomalies 的 ws_roas 工作表。

今天是 2026-01-29。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：1.0 与 4.0 对应两档不同处置（告警+邮件 vs 仅频道提示），且异常必须写回指定的 ws_roas 工作表。

## 1329 · `operations.facility_incident_triage`（断言 17，负 12）

**中文业务请求**

刚收到一些设施事件的通报。你能看一下设施事件日志表，并处理最紧急的那一条吗？应该有未结事件和值班联系人两个工作表。今天是 2026 年 2 月 9 日，星期一。

我们需要把最严重的未解决问题录入 Jira（Facilities Ops 项目），给今天值班的人发短信，并把它发到 Slack 的 incidents 频道。只处理唯一最严重的那条未结事件——其余的留到常规分诊会上处理。

已经解决的一律不用管，并确保你找到的是今天这一班正确的值班人。

今天是 2026-02-09。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：只处理一条最严重事件；值班人必须按「周一 2026-02-09」对应的班次查，不能取排在第一位的默认联系人。

## 1347 · `operations.fire_extinguisher_inspection_schedule`（断言 15，负 9）

**中文业务请求**

楼宇管理方要我们查一下哪些灭火器检验逾期了。你能看消防安全表（ss_fire，工作表 ws_units 和 ws_config），判断哪些单元需要检验吗？

每个单元因所在位置不同而有不同的检验周期。表里应该有细节。当距上次检验的天数严格超过检验周期（仅等于不算）时，该单元即为逾期。为每个逾期单元在 2 月 12 日 9am UTC 排一个 30 分钟的日历事件，并把完整清单邮件发给安全官。

只考虑实际已部署的单元——存放在库房或正在更换的可以等等。今天是 2026-02-09。

**要点**：逾期判定是「严格大于」周期，等于不算；只排已部署单元，且事件时间固定在 UTC。

## 1392 · `operations.fire_suppression_testing`（断言 24，负 12）

**中文业务请求**

嘿，我们该做季度消防抑爆合规巡检了。消防系统表（ss_fire）里有完整清单、检验政策细节、技术员与协调人联系方式。今天是 2026-02-09。

逐一过每个系统，按 config 里的周期规则判断哪些逾期，并为每一个在 FIRE 项目里建 Jira 工单。摘要要遵循 config 表上的格式。

给每个逾期系统对应的消防技术员发短信，并把该楼宇的逾期情况汇总邮件发给楼宇安全协调人，其中要包含该楼宇逾期系统的总数。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：周期规则与工单摘要格式都取自 config；短信按系统分配到对应技术员，邮件按楼宇聚合计数。

## 1335 · `operations.fleet_vehicle_maintenance`（断言 18，负 10）

**中文业务请求**

你能过一遍我们的车队跟踪表，判断哪些车辆该保养了吗？把所有工作表都看一遍——应该有车辆数据、联系人和保养政策。另外检查收件箱里可能影响排期的车队相关邮件。我们有些卡车用公里计里程，有些用英里——保养间隔始终以英里计，所以需要的地方你要做换算。

对任何已逾期的，在 14 日 8-10 AM UTC 建一个日历事件，标题为 'Service: [vehicle ID]'，并把完整清单邮件发给车队经理。还没真正到期的不要排——「快到了」不算。

另外，标记为停用（out of service）的车辆应完全跳过——它们已经在修理厂了。

**要点**：公里/英里必须先换算再与英里间隔比较；「快到期」不等于到期；停用车辆一律跳过。

## 1398 · `operations.generator_load_testing_schedule`（断言 13，负 6）

**中文业务请求**

查看备用发电机清单（ss_generators，ws_units），为从今天（2026-02-09）起 14 天内到期的发电机安排负载测试。

测试周期规则：

- 'Monthly' 发电机：若上次负载测试距今超过 30 天，或将在 14 天内达到 30 天，则视为到期。
- 'Quarterly' 发电机：若上次负载测试距今超过 90 天，或将在 14 天内达到 90 天，则视为到期。

重要规则：

- Status 为 'Under Repair' 的发电机无法测试——跳过。
- Assignment 为 'Event' 的移动式发电机适用不同排期——跳过。
- Notes 中含 'Emergency run' 且发生在最近 30 天内的发电机，视为已完成负载测试——用该应急运行日期作为上次测试日期。

对每台到期需测试的发电机，在下一个可用工作日创建一个 Google Calendar 事件，标题为 'Generator Load Test - [Unit ID]'，从 06:00 开始，时长 2 小时。

按 ws_engineers 给每栋楼对应的设施工程师发邮件，说明为其楼宇安排的测试发电机总台数。

今天是 2026-02-09。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：近期「Emergency run」可顶替上次测试日期；「下一个可用工作日」要跳过周末；三类跳过条件缺一不可。

## 1289 · `operations.google_ads_budget_alert`（断言 12，负 4）

**中文业务请求**

需要你检查我们 Google Ads 广告系列的预算问题。取所有在投广告系列，按当前投放速度计算预计花费。

如果某广告系列预计超过月度预算的 110%，那是 CRITICAL——立即暂停它并邮件告知 marketing-director@company.example.com。超过 100% 是 WARNING——只需就预计超支发一封邮件。

邮件中把每个被标记广告系列的预计花费表示为其月度预算的百分比，保留一位小数（例如 118.4%）。

把所有告警记录到预算日志表的 alerts 工作表。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：110% 暂停、100% 仅告警是两档处置，不要一刀切；百分比保留一位小数，实体名不能省。

## 1386 · `operations.hazmat_shipping_compliance`（断言 24，负 13）

**中文业务请求**

处理危险品出库运输的合规事务。查看运输日志（ss_shipments，ws_outbound）中所有分类为 'Hazardous' 的运输。

重要规则：

- 只处理 Destination Type 为 'International' 的运输——国内危险品运输走另一套流程，应跳过。
- Notes 列含 'Reclassified' 的条目即使 Classification 仍写着 'Hazardous' 也已不再是危险品——跳过这些。
- 检查 Declaration Status 列——只对状态为 'Missing' 的运输发送 DocuSign。

对每笔符合条件的运输，用 'International Hazmat Declaration' 模板（不是 'Domestic Hazmat Declaration'）把危险品申报单发到发货联系人邮箱，然后发送信封。

给合规官（compliance@company.example.com）发邮件，列出所有需要申报的运输。

把摘要发到 #logistics，包含运输 ID、目的地和需要申报的运输总数。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：国际 / 未重分类 / 申报缺失三个过滤条件叠加，模板必须选国际版而非国内版，发完还要执行发送（send envelope）。

## 1352 · `operations.holiday_coverage_planning`（断言 18，负 10）

**中文业务请求**

下周一（2026 年 2 月 16 日）就是总统日了，我们需要确认关键部门有人手覆盖。你能看一下节假日排班表，判断哪些部门已经妥当、哪些需要支援吗？检查员工可用性、部门需求和节假日覆盖政策。

对已确认覆盖充足的部门，按排班政策里的标准节假日班次时长，把已确认的员工排到日历上的节假日班次。对缺人的部门，通知部门负责人，让他们去找补充人手。

完成后把整体状态发到运营 Slack 频道。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：覆盖是否充足要拿「已确认」人数比部门需求，班次时长取自政策；缺人部门只通知负责人，不要自行补排。

## 1327 · `operations.housekeeping_schedule`（断言 11，负 4）

**中文业务请求**

需要把下周的清洁排期排好。查清洁管理表（ss_cleaning，工作表 ws_properties、ws_staff 和 ws_contacts），找出 2026 年 2 月 9 日至 2 月 15 日之间到期需清洁的物业，并把它们与具备相应资质的可用员工匹配。

我们有些套房需要专项深度清洁——这类只能派有认证的员工。按排期政策页（ss_cleaning / ws_schedule_policy）里的标准班次时长，为每次清洁创建日历事件，把指派的清洁工加为参与人，并把完整排期告知运营协调人。

还有一点——上次出过问题，有人把请假的清洁工排了进去。指派任何人之前先再核一遍可用性。另外，任何被挂起（hold）的物业都不应排期。

今天是 2026-02-07。

**要点**：深度清洁限认证员工、请假者不得排、hold 物业跳过，三重过滤缺一不可。

## 1302 · `operations.hubspot_churn_prediction`（断言 17，负 9）

**中文业务请求**

需要标出可能有流失风险的客户并主动联系。在标记客户之前，务必按我们的流失分析配置套用任何账户级排除或保护规则。

在 HubSpot 里查找出现预警信号的客户（lifecycle_stage = 'Customer'）——即 30 天以上未登录、NPS 低于 7，或近期提交了 3 张以上支持工单。

如果某人命中 2 个或更多信号，属高风险——通知 #churn-watch，并为 CSM 创建一张主题含客户名的 HubSpot 工单。中等风险（仅 1 个信号）则发一封带资源的关怀邮件。同时更新每个联系人的 churn_risk 字段。

今天是 2026-01-29。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：账户级排除/保护规则优先于信号打分；「NPS 低于 7」是严格小于；风险等级还要写回 churn_risk 字段。

## 1284 · `operations.hubspot_lead_qualification`（断言 20，负 9）

**中文业务请求**

嘿，我们需要对展会来的新线索做资格判定。查 ss_tradeshow_leads 表（ws_leads 工作表）里尚未判定的线索。另外看看销售团队近期有没有可能影响线索资格的邮件。

为每条合格线索创建 HubSpot 联系人，把高价值潜在客户优先放进商机管道，并把资格判定分布与可进入商机的线索管道总价值汇总邮件发给 sales@company.example.com。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：销售团队的邮件可能改写资格口径；汇总必须同时给出分层计数与可入管道的总价值。

## 1315 · `operations.hubspot_mailchimp_sync`（断言 12，负 6）

**中文业务请求**

需要把 HubSpot 的线索评分同步到 Mailchimp，这样我们才能正确地对邮件营销活动做分群。

从 HubSpot 拉取所有带 lead_score 的联系人，按线索同步规则表里定义的评分档位，在我们主要的 Mailchimp audience 中给他们打标签。确保每个联系人只有一个温度标签（把不正确的删掉）。

完成后把同步结果记录到 sync log 工作表。

**要点**：一人只能留一个温度标签，需先删旧标签；档位阈值来自同步规则表，不能用想当然的分档。

## 1307 · `operations.hubspot_payment_failure`（断言 9，负 5）

**中文业务请求**

我们有几笔失败付款要处理。你能跑一下留存流程吗？务必遵循当前的账单政策。

在 HubSpot 里找 payment_status = 'failed' 且尚未达到 3 次重试的联系人。对我们的 VIP（lifetime_value 超过 $10000），通知 #vip-support 并邮件告知 success@company.example.com。普通客户只发自动的付款更新邮件。

对你处理的每个人把 payment_retry_count 加一，并全部记录到 ss_billing（ws_failures）。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。

**要点**：重试未满 3 次才处理，VIP 阈值是 lifetime_value 严格大于 $10000，且重试计数必须自增并留痕。

## 1297 · `operations.hubspot_personalized_outreach`（断言 11，负 5）

**中文业务请求**

我们需要联系一些已经沉寂的冷线索。找出 HubSpot 里长期无互动的联系人，用 ChatGPT 撰写文案给他们发个性化外联邮件。把互动记录到 HubSpot。

发送前请先阅读任何外联准则。

**要点**：外联准则会约束语气、频率与可触达范围，且文案生成后仍要把互动结果写回 HubSpot。

## 1281 · `operations.hubspot_ticket_escalation`（断言 23，负 14）

**中文业务请求**

嘿，能查一下支持收件箱里有没有紧急客户投诉吗？找主题里带 'urgent' 或 'critical' 的邮件——取最近一封我们还没回复的。务必读完整封邮件正文，确认它确实需要升级——有时客户会在邮件后段补充说明。处理前请先阅读可用的升级准则。另外查一下有没有关于该客户账户的进行中事件内部邮件。

为它创建一张 HubSpot 工单，优先级 HIGH，主题与邮件主题一致。在描述里包含客户邮箱。

然后发到 #support-escalations 让团队知晓——类似 'Urgent ticket created: <Subject> from <Customer Email>'。

再给客户发一封确认，说明我们已收到其紧急请求并已升级，附上工单 ID。

今天是 2026-01-29。在通知或记录中引用源数据里的数值时，要逐字保留（不要改写或四舍五入）。在消息中包含源数据中的相关金额。

**要点**：主题带关键字不等于该升级，需读完整正文（客户可能在邮件后段撤回或降级）；还要排查内部事件邮件以免重复升级。

## 1321 · `operations.insurance_cert_validation`（断言 17，负 10）

**中文业务请求**

嘿，能看一下我们供应商保险的情况吗？季度审查快到了，我想提前把可能有问题的都摸清。我们的供应商保险表（ss_vendor_ins，工作表 ws_certs）里应该有你需要的一切——查一下谁不合规，给他们发 DocuSign 证书申请。

今天是 2026-02-09。我们的最低 GL 保额要求写在跟踪表底部那行政策备注里。任何低于该要求、或证书已过期的，都需要发起新的证书申请。务必用对 DocuSign 模板——我们那里有好几个与保险相关的模板。

发出 DocuSign 之后，给供应商联系人发一封简短的邮件，说明问题是什么、具体差在哪些数字上。已经合规的供应商不要去打扰——我们不想惹烦合规的合作伙伴。另外忽略任何标记为 inactive 的供应商行，那些合同已经终止了。

**要点**：最低 GL 保额藏在表底备注行、保险类模板有多个极易选错；已合规与 inactive 两类都要排除。

## 1325 · `operations.inventory_enrichment`（断言 10，负 3）

**中文业务请求**

产品团队反馈我们库存系统里有些商品缺重量数据，导致运费估算出问题。你能对照我们的参考目录把缺的补上吗？

全部更新完成后，在 Notion 的 ops reports 数据库里记录这些变更，并给库存经理发一份汇总。注意只动真正需要更新的记录——已经有数据的一律不要覆盖，即使它与参考目录不一致。

**要点**：只补空缺、不覆盖已有值（哪怕与参考目录不同），变更要落到 Notion 并通知库存经理。

## 1324 · `operations.invoice_shipping_trigger`（断言 9，负 3）

**中文业务请求**

发票 INV-2026-0452 刚刚完成付款。从发票表（ss_invoices，工作表 ws_line_items）中调出发票明细，查看哪些行项目需要加急发货——也就是零件号以 '-EXP' 结尾的那些。

只计算加急项目的总金额（数量 x 单价），并在发货看板（brd_shipping）上创建一个 Monday 事项，写入发票号、加急项目数量和加急总金额。把状态设为 'Pending'，截止日期设为 2026-02-11。

另外给仓库团队（warehouse@company.example.com）发邮件说明加急发货详情——包含每个加急零件号、数量以及加急总金额。

**要点**：只有零件号以 '-EXP' 结尾的行才计入加急，金额按「数量 × 单价」逐行汇总；负断言盯的是把普通行算进加急总额或漏发仓库邮件。

## 1204 · `operations.jira_confluence_incident`（断言 10，负 7）

**中文业务请求**

我们需要把最严重的、尚未关闭的设施事故升级到 Jira 并留下记录。

查看设施事故表（ss_incidents/ws_facilities），找出最紧急的未关闭问题。处理之前还要先看一遍升级规则。

在 'Operations Support' Jira 项目中创建一个 Incident，注明 ops 团队已收到通知，并在 SP_OPS 空间（cloud_ops）中建一个 Confluence 页面写事故详情。页面标题用 'Incident - <Location>'，正文用所选事故的 Summary。

**要点**：必须先按升级规则界定「最紧急」，凭直觉挑会选错；Confluence 标题里的 <Location> 要替换为实际地点，正文直接照抄所选事故的 Summary。

## 1317 · `operations.linkedin_abm_outreach`（断言 13，负 8）

**中文业务请求**

该对久无互动的 Tier 1 客户做一轮 ABM 外联了。

从 Salesforce 拉出 Tier 1 客户，并查看 ABM 外联配置表，取出我们的无互动阈值和联系人职级要求。对每家符合条件客户，在 Salesforce 中查出该客户的联系人，按职级标准筛选，再查看他们的 LinkedIn 主页和近期发帖，以便做个性化外联。

在 LinkedIn 上发送带个性化说明的连接请求，为每个客户的 AE 创建一个 Salesforce 任务，主题为 'ABM Touch - <Account Name>'，并把所有内容记录到 ABM 追踪表。告知 #abm-team 你联系了哪些客户和联系人。

今天是 2026-01-28。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：阈值和职级门槛都得从配置表里取，不能凭经验设；负断言盯的是联系了不达职级要求的联系人或漏建 AE 任务。

## 1299 · `operations.linkedin_job_change`（断言 15，负 9）

**中文业务请求**

我们该查一下重点联系人有没有换工作。取出 Salesforce 中标记为 'Champion' 或 'Decision Maker' 的联系人。

在 LinkedIn 上核对他们当前所在公司——如果与 Salesforce 不一致，他们很可能已经跳槽。但在标记之前，也要查一下近期邮件里有没有关于这些联系人的背景信息。

动手之前务必对照当前生效的政策，并交叉核实所有可用的记录。

对于确实换了工作的人：用新公司和职位更新其 Salesforce 记录，为该客户的负责人创建一个跟进任务，并在 #sales-alerts 通报其姓名、新公司，以及已确认的换工作总数。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：公司不一致只是线索，邮件上下文可能解释差异（改名、子公司、并购）；通报里的「已确认换工作总数」是最容易漏的聚合值。

## 1391 · `operations.loading_dock_scheduling`（断言 21，负 10）

**中文业务请求**

处理装卸货月台的预约申请。查看月台管理表（ss_docks，工作表 ws_requests、ws_docks、ws_bookings），并在排期前先阅读我们的月台政策。

对每个成功排期的申请，在 Google Calendar 中创建一个事件，标题为 'Dock [N] - [Company Name]'，时间用申请中的日期/时间，时长 2 小时。

给提出申请的公司联系人发邮件，确认其预约或说明申请为何被拒。

每封确认或拒绝邮件中都要包含成功排期、被拒绝和暂缓（on-hold）预约的总数。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：月台容量、时段冲突、维护中的月台都要按政策判定；「暂缓」这一档最易被漏，且三类计数在每封邮件里都要出现。

## 1287 · `operations.mailchimp_campaign_tracking`（断言 7，负 3）

**中文业务请求**

嘿，上一次营销活动有一些退信。你能在 Mailchimp 里查一下 aud_main 受众中的退信订阅者吗？

按 Mailchimp 规则工作表（ss_sync_policy / ws_mailchimp_rules）里的同步政策更新他们的 Airtable 记录（base_contacts 的 Contacts 表）。

然后把报告发送到同一工作表中列为 Report Recipient 的地址。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：改哪个字段、改成什么由同步政策规定，报告收件人也从表里读，不能默认回给发件人。

## 1308 · `operations.mailchimp_ecommerce_sync`（断言 13，负 6）

**中文业务请求**

需要把近期买家同步到 Mailchimp，用于邮件分群。

从订单表拉出近期订单，把符合条件的买家加入 Mailchimp 主受众，并打上正确的标签。务必遵循当前生效的标签政策。

完成后在 #ecommerce-ops 发一份同步汇总。

今天是 2026-01-29。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：「符合条件」和标签映射都由标签政策决定（例如已退款、重复买家要排除），汇总里还必须带金额。

## 1282 · `operations.mailchimp_subscriber_sync`（断言 17，负 11）

**中文业务请求**

能把我们的活动报名同步到新闻邮件吗？检查 ss_event_registrations 表格（ws_registrations 工作表）中需要同步的报名记录。把符合条件的订阅者加入 Mailchimp 的 aud_newsletter 受众并打上标签。

务必遵循最新的同步资格规则——我知道法务和隐私团队最近标出了一些问题，会影响到哪些报名可以处理。

完成后在 #marketing-ops 发一条消息，写明已同步订阅者的姓名、公司以及总数。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：资格规则被法务/隐私更新过，必须取最新版本（同意状态、地区限制等），沿用旧规则就会同步错人。

## 1374 · `operations.mailroom_package_routing`（断言 19，负 11）

**中文业务请求**

处理 ss_mailroom 表格（ws_packages 工作表）里包裹登记中的到件。每行包含 Tracking Number、Recipient Name、Department、Package Type 和 Received Date。

在员工名录（同一表格的 ws_employees 工作表）中逐个查找收件人，找出其 Floor 和 Phone number。

规则：
- 对 Refrigerated 或 Hazardous 包裹，向收件人手机号发送短信，内容含运单号和取件说明
- Standard 包裹只需路由（不发短信）
- 如果在员工名录中查不到收件人（已离职员工），跳过该包裹

重要：有些员工同名——必须同时匹配 Name 和 Department 两项。

在 Slack 的 #mailroom 发布路由汇总，列出所有成功路由的包裹及其楼层分配。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：同名员工必须用 Name + Department 联合匹配，只按姓名会路由到错误楼层；查不到的离职员工包裹要跳过，而非强行分配。

## 1219 · `operations.monday_calendar_emergency_drill`（断言 8，负 4）

**中文业务请求**

安全团队发来了应急演练安排——你能把总部演练加到日历并更新 Monday 吗？

查看 safety@company.example.com 发来的关于总部应急演练的邮件。更新 ops 看板（brd_ops）上的演练事项，并把它加到 ops 日历（cal_ops）。如果时间在下班后，给 #emergency-team 提个醒。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：安全团队可能发过多封（改期、取消），要取最新有效的那封；只有确实在下班后才额外通知频道，多此一举会被负断言抓到。

## 1203 · `operations.monday_email_update`（断言 22，负 15）

**中文业务请求**

IT Ops 发来了关于办公室搬迁切换的更新——你能把它同步到 Monday 并向他们确认吗？

查看 it-ops@company.example.com 最近一封关于 IT Cutover 的邮件（不是服务器迁移那封），然后在 ops 看板（brd_ops）上找到 IT Cutover 事项，用当前状态和截止日期更新它（列：status、due）。

我觉得其他团队那边还流传着一些更正，Slack 里也有人提过什么，所以请把一切都仔细核实。做任何改动前务必遵循当前生效的更新政策。

回复 IT Ops 确认已更新。确认信要遵循我们的标准格式，带上正确的参考编号和计数，以便他们核对记录。

如果状态是 Done，还要在 #ops-updates 发布切换已完成。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：干扰源很多——服务器迁移邮件、其他团队的更正、Slack 传言都可能带错日期；只认 IT Cutover 的最新邮件，且确认信必须按标准格式带参考编号与计数。

## 1210 · `operations.monday_slack_inventory`（断言 9，负 5）

**中文业务请求**

我们需要处理最紧急的待办门禁卡申请。今天是 2026-02-19。

查看门禁卡库存表（ss_inventory/ws_badges）中的待处理项，挑出最紧急的那一条。

更新 brd_ops 看板上对应的事项：把 status 设为 'In Progress'，并把所选行的 Needed By 日期抄到 Monday 的 due 列。并告知 #ops-updates。如果该申请需要立即处理，还要提醒 #ops-alerts。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：紧急度按 Needed By 距 2026-02-19 的远近判定，日期要原样抄进 due 列；只有真正紧迫才升级到 #ops-alerts。

## 1214 · `operations.notion_gmail_checklist_update`（断言 9，负 5）

**中文业务请求**

Ops 负责人发来了供应商入驻清单的更新——你能把它放进 Notion 并向他们确认吗？

查看 ops-leads@company.example.com 发来的关于供应商入驻清单的邮件，找出最新的一条更新。确认它确实是关于供应商入驻的，而不是其他清单。

在 pg_ops 下创建一个 Notion 页面放入该更新，并回复确认已完成。

如果更新中新增了任何与安全相关的步骤（例如门禁卡申请、访问控制或安全审查），还要在 #security-team 发布消息让他们知晓。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：邮箱里混有其他清单（例如客户入驻）的更新，必须挑对主题；只有新增了安全类步骤才额外通知 #security-team。

## 1234 · `operations.notion_slack_playbook`（断言 12，负 9）

**中文业务请求**

我们需要把当前的非工作时间呼叫树发布到 Notion 并通知团队。

在 playbook 版本表中查出当前版本，并在 ops 父页面（页面 id 'pg_ops'）下创建一个 Notion 页面，写入相关细节。

Notion 页面正文必须包含所选版本号和生效日期。发布前还要查看发布政策工作表里的各项要求。发布完成后告知 #ops-updates。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：「当前版本」要按版本表判定（不要选到已排期、尚未生效的未来版本），正文必须同时写出版本号与生效日期，还要满足发布政策。

## 1395 · `operations.office_supply_budget_monitoring`（断言 14，负 7）

**中文业务请求**

我们来做一次办公用品支出的预算检查。今天是 2026-02-09，我想知道哪些部门的用品预算烧得太快。

办公用品跟踪表里有月度支出数据和预算分配。还有一个财政策略页，写明了如何计算有效预算以及告警阈值是多少。

找出超线的部门，并为每个部门在 Slack 的 admin-ops 频道发布预算告警。同时给部门管理员发一封提醒邮件，让他们在情况恶化前收紧支出。

今天是 2026-02-09。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：「有效预算」不是表里的名义预算，要按财政策略重算（扣除已承诺金额等），阈值同样取自策略页；要按部门逐个告警，而不是发一条汇总。

## 1326 · `operations.overdue_inspection_summary`（断言 15，负 9）

**中文业务请求**

你能整理出逾期检查报告吗？今天是 2026-02-09。我们需要检查现场检查记录，看哪些站点已经落后于计划。

把 monthly 视为自上次走访起固定 30 天间隔，quarterly 视为固定 90 天间隔。如果某站点的下次检查日期已过，即为逾期。明显逾期的站点需要在 Asana 的 Facilities 项目（workspace ws_facilities、project proj_inspections、section sec_overdue）中创建任务——我们对「明显」的阈值是逾期超过两周。

把全部逾期站点清单发邮件给检查协调员。邮件中要包含上次走访日期和每个站点落后的程度，格式为 '<N> days overdue'。只标记检查仍处于 active 状态的站点——任何标记为 suspended 的都应排除。

**要点**：周期要按固定 30/90 天换算而非自然月；只有逾期超过两周才建 Asana 任务，但邮件清单要覆盖全部逾期站点；suspended 站点一律排除。

## 1351 · `operations.overtime_threshold_monitoring`（断言 15，负 8）

**中文业务请求**

嘿，这周快结束了，我需要有人在周五前核对一下考勤表。我们以前出过加班问题，我不想在发薪时遇到意外。

调出每周考勤跟踪表（ss_timesheets），与公司加班政策表交叉核对。根据截至目前（周一至周四）的工时，标出任何正在接近加班上限的人。政策表里给出了每个雇佣类别的阈值。

对任何接近加班的人，给其经理发短信，写明员工姓名和当前总工时。你需要从组织架构图里查出经理信息。

另外给 HR（hr@ourcompany.example.com）发一封邮件，汇总谁有风险。今天是 2026 年 2 月 9 日。

**要点**：工时只统计周一到周四，阈值按雇佣类别分别取，经理信息要经组织架构图中转查；给 HR 的是风险汇总而非原始明细。

## 1367 · `operations.parking_allocation_management`（断言 24，负 11）

**中文业务请求**

我们需要处理待定的停车位申请。查看停车登记表（表格 ss_parking，工作表 ws_spots）里的可用车位，以及员工资历表（同一表格，工作表 ws_seniority）里的排序。

规则：
- 按资历把可用车位分配给提出申请的员工（Rank 数字越小 = 资历越高）
- 'Handicap' 车位只能分给 Accessibility = 'Yes' 的员工
- 'Reserved' 车位仅限 Director 及以上级别
- 'Standard' 车位任何人都可以分
- 跳过 Status = 'Maintenance' 的车位
- 跳过登记表中已分配车位的员工

分配完成后，更新停车登记表中相应行，把 Assignee 列设为员工姓名。给每位新分配的员工按其邮箱发邮件，写明车位号和类型。在 Slack 的 #office-ops 发布所有新分配的汇总，包括新分配总数和整体车位使用率（已分配车位 / 总可用车位，四舍五入到整数）。使用率中的「总可用车位」指登记表中所有 Status='Active' 的车位。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：本质是「资历优先 × 车位类型资格」的匹配问题；使用率的分母是 Status='Active' 的车位（不含 Maintenance），且要四舍五入成整数。

## 1346 · `operations.perishable_inventory_expiry`（断言 21，负 8）

**中文业务请求**

嘿，现在是周一早上，我需要你检查一下我们的易腐货物里本周会到期的东西。我们得赶在变质之前处理。

查看到期跟踪表中未来 7 天内到期的项目。对任何有风险的项目，给仓库联系人发短信、发布到库存告警频道，并给联系人发邮件。要包含批号和位置，方便他们找到。

不要包含已经处置或处于隔离（quarantine）状态的东西——那些另行处理。今天是 2026-02-09。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：7 天窗口自 2026-02-09 起算，已处置/隔离的批次必须排除；每个风险品要三路通知（短信 + 频道 + 邮件）并带上批号与位置。

## 1216 · `operations.pipefy_gmail_vendor_approval`（断言 13，负 3）

**中文业务请求**

采购发来了好几份供应商审核决定——你能全部处理掉吗？

查看 procurement@company.example.com 发来的、关于供应商审核的未读邮件，并更新每家供应商的 Pipefy 卡片（tbl_ops）以反映该决定。把已批准的供应商移到 phase_approved、状态设为 Approved（字段 field_status），被拒绝的移到 phase_rejected、状态设为 Rejected，有条件通过的移到 phase_pending_docs、状态设为 Pending Docs。

给采购回邮件，逐份确认。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：只有「未读」且属于供应商审核的邮件才算数，三类决定对应三组阶段 + 状态，一家都不能漏；回信要逐份确认。

## 1231 · `operations.pipefy_slack_purchase_request`（断言 9，负 5）

**中文业务请求**

嘿，Pipefy 里有一份采购申请已经可以批准了。

查看 Purchase Requests 表格，找出金额最高、且落在我们 $5,000 自动批准额度之内的已批准采购申请。
在 Pipefy 里找到 ops 表中对应的记录，把它移到已批准阶段，并把 status 字段设为 'Approved'。

然后在 #ops-updates 发布审批详情。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：要找的是「≤ $5,000 的已批准申请中金额最高的一条」，不是整体金额最高的一条；超过阈值的必须排除，否则就绕过了人工审批。

## 1207 · `operations.pipefy_vendor_onboarding`（断言 10，负 5）

**中文业务请求**

采购刚刚批准了一家新供应商——你能更新 Pipefy 并告知 Ops 吗？

查看刚收到的、关于新供应商入驻的邮件，并查阅供应商审批政策表。找出已完全批准、可以启动的那家供应商，然后在 Pipefy 中把其卡片移到 Ready 阶段、状态设为 Approved。

在 #ops-updates 发布消息，让团队知道可以启动了。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。

**要点**：「完全批准」要按审批政策逐项核对（可能还有一家在等补材料）；阶段和状态两个字段都必须改。

## 1385 · `operations.procurement_card_reconciliation`（断言 21，负 10）

**中文业务请求**

财务要求我们在月末前清理 P-card 对账。从 P-card 交易表中拉出交易记录，标出任何缺少凭证的交易。查看其他工作表里的收据政策，了解阈值以及哪些情况需要升级。

为每笔被标记的交易在 Monday 中创建一个跟踪事项，并给持卡人发邮件，告知其需要提交收据。务必写明具体是哪笔交易，让他们知道指哪一笔。在通知或记录中引用源数据里的数值时，要原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：只有超过收据政策阈值的缺凭证交易才建事项、发邮件，低于阈值的不能滥标；邮件必须点名具体交易并带上金额。

## 1341 · `operations.purchase_order_three_way_match`（断言 9，负 5）

**中文业务请求**

对我们的采购数据做一次三单匹配。ss_procurement 中有三个工作表：

1. ws_po - Purchase Orders：PO Number、Vendor、Item、Qty Ordered、Unit Price、PO Date
2. ws_inv - Invoices：Invoice Number、PO Number、Invoice Amount、Invoice Date
3. ws_recv - Receiving：Receipt ID、PO Number、Qty Received、Receipt Date、Notes

按 PO Number 匹配记录。标出以下差异：
- Qty Received != Qty Ordered（除非 Notes 列写的是 'Partial - Expected'）
- Invoice Amount != (Qty Ordered * Unit Price)

为每处差异在 'Procurement Issues' 看板上创建带详情的 Monday 事项。给 procurement@supplychainco.com 发邮件，汇总所有不匹配项。

只匹配 2026 年 1 月及以后的 PO（PO Date >= 2026-01-01）。更早的 PO 已经核对过了。

**要点**：金额比对的分母是「订购数量 × 单价」而不是收货数量；Notes 为 'Partial - Expected' 的部分收货属正常，不能误报；2026-01-01 之前的 PO 全部排除。

## 1338 · `operations.role_based_access_audit`（断言 13，负 3）

**中文业务请求**

我们正在做季度访问权限审查。你能把员工实际拥有的系统访问权限与其角色允许的权限做一次交叉比对吗？IT 团队维护着表格 ss_access——先从工作表 ws_matrix 的员工权限矩阵入手，并查看其他工作表里的角色定义和审查设置。

任何拥有其角色本不该有的系统访问权限的人，都需要创建一个审查任务。不过有些人是走了特殊批准的，所以要查看备注。完成后给 IT 安全团队发送一份完整报告。

务必为每个需要审查的人列出具体的未授权系统。

**要点**：备注里的「特殊批准」可以豁免部分越权，不能一刀切；每人必须列出具体的未授权系统清单，只报姓名会被判错。

## 1332 · `operations.safety_certification_gap_analysis`（断言 10，负 4）

**中文业务请求**

我们需要审计员工的安全认证（safety certifications）。电子表格（ss_safety，ws_certs）列出了每位员工的姓名、部门、角色、认证类型和到期日期。必需认证表（ss_safety，ws_requirements）则把每个角色映射到其必须持有的认证。

把两张表交叉比对：对每位员工，检查其是否持有本角色要求的全部认证，并且这些认证在今天（2026-02-09）都未过期。只要缺少任一必需认证，或某个必需认证已过期，该员工即为不合规。

为每位不合规员工创建一个 Jira issue（项目 key 为 SAFE，issue 类型为 Task）。summary 中应包含员工姓名以及缺失或已过期的具体内容。然后给安全协调员 sarah.oconnor@industrialco.com 发邮件，汇总所有发现的问题。

注意：不要标记即将到期但尚未过期的认证，只标记真正过期或缺失的认证。

今天是 2026-02-09。

**要点**：不合规只有「缺失」和「已过期」两种口径，快到期未过期的认证不能误报；角色的必需认证清单必须取自 ws_requirements。

## 1361 · `operations.safety_incident_investigation_routing`（断言 18，负 10）

**中文业务请求**

查看安全事故日志（ss_safety，ws_incidents）。每条事故都有类型、严重程度（Critical/Major/Minor）、地点、证人和调查状态。

只处理 Investigation Status 为 'New' 的事故。跳过 'Under Investigation' 以及类型为 'Near Miss' 的事故（这两类走另一套流程）。

按严重程度分流每条新事故：
- Critical：创建 Jira issue（proj_safety）+ 给安全总监发短信至 +15558001001 + 在 Slack 的 #safety-critical 频道发帖
- Major：创建 Jira issue（proj_safety）+ 仅在 Slack 的 #safety-incidents 频道发帖
- Minor：仅创建 Jira issue（proj_safety）

所有 Jira issue 中都要包含事故类型、地点和严重程度。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：先做两道筛选（状态为 New、排除 Near Miss 与 Under Investigation），再按严重程度分流；只有 Critical 才三通道齐发，Major 不发短信。

## 1244 · `operations.salesforce_escalated_customer`（断言 22，负 9）

**中文业务请求**

有几起客户升级（escalations）需要处理。查看 ss_escalations（工作表 ws_pending），处理其中最严重的那起企业客户问题。

通过 Salesforce 和 Jira（Customer Escalations 项目）做升级，在 Confluence（cloud_ops/SP_ESCALATIONS）留档，并发布到 #escalations 和 #account-management，内容需包含该客户当前的 ARR。务必遵守所有升级策略，包括 reference ID 的格式要求和 CSM 归属（attribution）要求。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：先按策略筛出「最严重的企业客户」，升级动作要覆盖 Salesforce、Jira、Confluence 与两个频道，reference ID 格式和 CSM 归属这两条策略细节都不能漏。

## 1322 · `operations.sensor_monitoring_alert`（断言 14，负 9）

**中文业务请求**

执行每日传感器检查。拉取传感器监控仪表盘表格，标记出在线但读数低于其最低阈值的传感器。

离线传感器由基础设施团队处理——不要把它们算进来。只标记正在上报但读数偏低的传感器。我们的传感器告警策略最近刚更新过，标记前先查最新规则。

给设施运维负责人（facilities-ops@company.example.com）发邮件，列出被标记的传感器 ID、当前读数和位置。邮件主题需包含 'Daily Sensor Alert'。

另外在 #facilities-alerts 发一条摘要，包含传感器数量以及最严重的一个（相对其阈值读数最低者）。

今天是 2026-02-09。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：必须排除离线传感器，且阈值要按最近更新的告警策略取；摘要里的「最严重」按读数相对阈值的比例判断，而非绝对读数。

## 1334 · `operations.server_capacity_threshold_alerts`（断言 17，负 8）

**中文业务请求**

监控团队要我们复核今天的服务器指标，把运行过热（running hot）的项标出来。查看服务器监控表格中的当前读数，并翻阅其他工作表以获取告警阈值、联系方式和任何策略约束。

今天是 2026-02-09。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：阈值、收件人和策略约束都藏在该工作簿的其他工作表里，不先读全就会漏掉判断条件和通知对象。

## 1223 · `operations.sheets_asana_approved_request`（断言 18，负 13）

**中文业务请求**

我们有一个已批准的高优先级设施请求，需要建一个 Asana 任务。

在 Operations Requests 表格中找出最紧急的、已批准的设施请求。选定之前，再核对一下备注（notes）列，看是否有会影响资格的内容。该表格还有若干附加工作表，写有请求处理策略与指引。

动手前先确认该请求满足所有成本与流程阈值。

在 Asana 的 facilities 项目中、Backlog 分区创建一个任务，截止日期 2026-02-10。在任务描述中写明预估成本、原始申请日期，并注明该请求是否曾通过邮件重新审批（reapproved），以便财务和审计追溯。

**要点**：备注列里可能有让请求失去资格的信息，动手前必须同时过成本阈值与流程阈值；「邮件重新审批」这一事实要在任务描述里留痕。

## 1224 · `operations.sheets_monday_maintenance_queue`（断言 8，负 5）

**中文业务请求**

能看一下我们的维护队列表格，把最紧急的未结项排期吗？

排期前，先看队列表格里的排期策略，确认是否存在挂起（hold）或授权要求。

在 ops 看板上更新对应的 Monday 条目，写入排期细节，并通知 #ops-updates。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：先读排期策略排除被挂起或需授权的项，再挑最紧急的；Monday 条目与 #ops-updates 通知都要写清受影响实体的名称。

## 1337 · `operations.sla_breach_early_warning`（断言 18，负 11）

**中文业务请求**

现在是周一下午，需要有人盯一下我们未结的支持工单。有几张可能快接近 SLA 截止时间了，得确认客服已经在跟进，别真等到违约。

当前时间是 2026-02-09T14:00:00Z。看一下工单跟踪表——电子表格 ss_tickets，工作表 ws_open。SLA 配置也看看其他工作表。找出所有正在逼近截止时间的事项。查阅 SLA 配置工作表，弄清我们的升级阈值以及针对有风险工单的必需动作。另外给支持经理发个提醒（heads up）。

显然，已经解决（resolved）或关闭（closed）的工单不用管。已经超过截止时间的则走另一套流程——我们有单独的工作流处理，别动它们。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：只处理「未结、尚未超时但已逼近阈值」的工单，已解决/已关闭与已超时的一律排除；升级动作要按 SLA 配置里的阈值执行。

## 1368 · `operations.space_utilization_analysis`（断言 12，负 7）

**中文业务请求**

查看办公空间使用率数据，位于电子表格 ss_space（工作表 ws_rooms）。每行包含 Room、Type、Capacity、Avg Daily Occupancy %、Floor 和 Notes。

找出所有 Type 为 'Office' 且使用率持续低于 40% 的房间。排除会议室（Type = 'Conference'），它们的使用模式不同。同时排除 Notes 列中含 'Renovation' 的房间——它们反正要重新改造。

在 Facilities 工作区（space_id: sp_facilities）创建一个 Notion 页面，标题为 'Space Consolidation Report - Q1 2026'，列出使用不足的办公室、其当前容量、使用率，以及合并（consolidate）的建议。

同时给设施总监 Rachel Torres（rachel.torres@company.example.com）发邮件说明发现，并包含总浪费容量（各使用不足办公室的空置座位数之和，其中空置 = capacity * (1 - occupancy%)）。

**要点**：三重排除（非 Office、Conference、Notes 含 Renovation）缺一不可，浪费容量按 capacity × (1 − 使用率) 逐间累加，不能直接取平均值。

## 1378 · `operations.temporary_worker_placement`（断言 21，负 9）

**中文业务请求**

这个月我们有若干临时岗位要补。查看临时用工表格里的空缺岗位，另有一张工作表列出可用的临时人员池。能把人和岗位匹配起来吗？

要确保工人确实具备岗位所需的技能，并且在岗位开始时可到岗。部分岗位要求认证——这类岗位的工人档案中至少要有一个有效认证。若有多名工人可胜任同一岗位，取你找到的第一个匹配即可。每位临时工只能接一个岗位。

给每位已安置的工人发邮件说明其岗位安排，并把所有安置情况的摘要发到 HR ops 的 Slack 频道。

今天是 2026-02-09。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：技能、到岗时间、有效认证三条同时成立才算匹配，先到先得且每人只能占一个岗位；匹配顺序会直接影响最终安置结果。

## 1340 · `operations.training_compliance_check`（断言 8，负 5）

**中文业务请求**

审计强制性培训的合规情况。

培训跟踪表（ss_training，ws_records）包含这些列：Employee、Role、Course Name、Course Type、Completion Date 和 Equivalent Course。

要求表（ss_training，ws_required）列出每个角色及其必修课程（Course Type = 'Mandatory'）。

若员工在截止日期 2026-02-15 之前未完成其角色的某门必修课，即为不合规。不过，如果员工完成了「Equivalent Course」（即 Equivalent Course 列填写的内容与某门必修课名称一致），可视为已完成。

不要标记 Course Type 为 'Optional' 的课程——那些不是必修。

为每位不合规员工创建一个 Asana 任务，列出其缺失的课程。把完整的不合规报告邮件发给 hr-training@acmecorp.com。

**要点**：等价课程可抵扣必修课，Optional 课程不能算作缺失项；是否完成以 2026-02-15 这条截止线来判断。

## 1202 · `operations.trello_basecamp_compliance`（断言 10，负 7）

**中文业务请求**

喂，我们该推进下一份高优先级供应商合规文档了。查看 Compliance Queue 表格（ss_compliance_queue，工作表 ws_queue），找出最紧急的外部供应商文档。另外看一下合规规则工作表，了解文档处理的相关政策。

更新 ops 看板（brd_ops）上的 card_778，写入截止日期，加上合规标签（lbl_compliance），并在我们的 Facilities Basecamp 项目（acct_ops/proj_facilities，set_compliance/list_vendor_docs）中新增一个 todo。todo 按 '<Vendor> - <Document>' 格式命名，用选中的队列行原样填写。

**要点**：选中的队列行要原样套进 '<Vendor> - <Document>' 模板，且动手前要先读合规规则工作表确认处理政策。

## 1237 · `operations.trello_basecamp_slack_compliance_followup`（断言 7，负 3）

**中文业务请求**

合规团队发来一个跟进请求，需要同时写入 Trello 和 Basecamp。查看 compliance@company.example.com 最新一封主题含 'Follow-up' 的邮件，取其中的任务文本和截止日期。

更新看板 brd_ops 上的 Trello 卡片 card_812，以反映该合规跟进状态，按邮件设置截止日期，并加上标签 lbl_compliance。同时在 Basecamp 创建一个 todo（acct_ops / proj_facilities / set_compliance / list_fire），写入任务文本和截止日期。

然后在 #ops-updates 通知团队这次更新。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：任务文本与截止日期必须取自那封 'Follow-up' 邮件，Trello 卡片与 Basecamp todo 两处信息要保持一致。

## 1209 · `operations.trello_vendor_hold_email`（断言 9，负 2）

**中文业务请求**

合规团队标记了一些供应商问题——需要处理所有供应商挂起（vendor holds）。

查看 compliance@company.example.com 关于供应商合规动作的邮件。在 ops 看板（brd_ops）上，用供应商挂起标签（lbl_vendor_hold）分别妥善处理每个供应商的合规动作。

对于动作为 Warning（而非 Hold）的供应商，只在其卡片上加一条评论说明警告详情——不要移到挂起列表，也不要发挂起通知邮件。

对每个 Hold 动作，把卡片移到 'On Hold' 列表，并将截止日期设为合规通知中的 deadline。

每封挂起邮件发往 ops-vendors@company.example.com，主题格式为 'Vendor Hold: [Vendor Name]'（替换为实际供应商名，例如 'Vendor Hold: Apex'），正文包含供应商名称、原因和截止日期。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：Warning 与 Hold 必须分开处理，Warning 只加评论、既不挪卡片也不发邮件；Hold 才移列、设截止日期并按主题模板发信。

## 1248 · `operations.twilio_afterhours_incident`（断言 10，负 5）

**中文业务请求**

处理这起非工作时间的 P1 事故。查看 ss_incident_queue（工作表 ws_queue）和 ss_oncall_schedule（工作表 ws_schedule），获取事故详情与值班信息。

用 +15550001111 给值班工程师发短信呼叫（page），在 Incident Management 项目创建一个带 after-hours 标签的 Jira issue，在 cloud_ops/SP_INCIDENTS 建一个 Confluence 页面，并把告警详情邮件发给 incident-stakeholders@company.example.com。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：值班人须按 ws_schedule 中非工作时间段的排班查找，不能拿白班联系人顶替；发出的短信、Jira、Confluence 与邮件四处信息要一致。

## 1271 · `operations.twilio_facilities_emergency`（断言 28，负 18）

**中文业务请求**

处理最严重的那起设施紧急事件。查看 Emergency Queue（ss_emergencies/ws_active）里新的设施问题。我记得安全团队发过一些更新，可能影响优先级分类，所以先把最新信息拼起来再动手。

确定紧急事件后：
- 给值班人 +15551119999 发短信，内容含优先级、描述和地点。还要写明（按所有排除条件筛完后）还剩多少起新的 Facilities 紧急事件待处理。
- 在 Monday 看板 brd_emergencies 上创建一个条目，状态为 'Active'
- 在 Notion 的 pg_emergencies 下留档，包含全部细节
- 给 building-occupants@company.example.com 发邮件通知所有人

在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：优先级要以安全团队的最新更新为准；短信里的「剩余待处理数量」必须按排除条件筛完之后的口径统计。

## 1275 · `operations.twilio_production_incident`（断言 10，负 4）

**中文业务请求**

我们刚触发了一起 SEV1 生产事故，需要立刻启动响应。

查看 Incidents 表（ss_prod_incidents），找到那条已触发的 SEV1 生产事故。把响应跑起来：
- 给值班工程师发短信并打电话，内容为 'SEV1 INCIDENT: [title]. Immediate response required.'
- 在 Jira 的 Incidents 项目创建 SEV1 事故工单
- 在 Notion 的 pg_incidents 下建一个事故页面，含时间线
- 同时告警 #incidents 和 #engineering-all

在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。在消息中包含受影响实体的名称。

**要点**：短信与电话两条通道都算数、都不能省，Jira、Notion 和两个频道也一个不能少；消息标题要按给定模板原样拼接。

## 1354 · `operations.utility_cost_allocation`（断言 12，负 5）

**中文业务请求**

复核公用事业费用表格（ss_utilities）中一月的账单和楼层平面数据，弄清各部门的平方英尺面积与所在楼宇。

把每栋楼的公用事业费用按比例分摊到各部门。共享空间的费用应在其所在楼宇的活跃部门之间平均分摊。空置楼层的费用不分摊给任何人。

把各部门的公用事业费用总额（保留两位小数）更新到分摊表（allocation sheet）。

给财务 finance@ourcompany.example.com 发邮件，附各部门的费用明细。

在 Slack 的 #facilities 发一条摘要。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：专用面积按比例分摊、共享面积只在活跃部门间均摊、空置面积不分摊，三类要分开处理，结果按两位小数落表。

## 1328 · `operations.vendor_compliance_audit`（断言 18，负 12）

**中文业务请求**

我们需要交叉核对供应商合规数据。定稿审计前，先确保拿到每个供应商最新的合规信息。查看 Salesforce 账户以获取活跃供应商名单，再看合规跟踪表（ss_compliance，ws_tracker），找出哪些供应商的文档已失效。

若某供应商在表中的 'Doc Expiry' 日期早于今天（2026-02-09），且其 Salesforce 账户状态为 'Active'，即为不合规。

把不合规供应商的名称、Salesforce 账户 ID 和过期文档类型发到 #vendor-compliance。只发真正不合规的供应商——账户在 Salesforce 中已标为 Inactive 的不要发。

在 Slack 帖子里包含不合规供应商的总数。

今天是 2026-02-09。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：两个条件同时成立才算不合规（Doc Expiry 已过 + Salesforce 状态为 Active），且账户状态要以 Salesforce 的实时数据为准。

## 1270 · `operations.zoom_board_meeting`（断言 10，负 3）

**中文业务请求**

要把 2026 年 Q1 的董事会会议安排起来，能负责这块的后勤吗？

查看 Board Meetings 表（ss_board_meetings/ws_upcoming），找到已排定的 Q1 2026 例会。跳过取消的或特别会议。若有多条匹配，取日期最早的一条。

从 ss_board_members/ws_active 取需要出席的现职董事名单，排除任何已回避（recused）的人。然后把一切就绪：
- 创建一场 3 小时、设密码的 Zoom 会议 'Q1 2026 Board Meeting'，开始时间为会议日当天 09:00 UTC
- 通过 DocuSign 向每位董事发送 'Board Meeting Consent'
- 加入 Monday 看板 brd_exec：日期（meeting_date）、状态 'In Progress'（prep_status）、出席人数（attendees）
- 在 Notion 的 pg_board 下创建议程页面，含会议详情、出席人和标准议程项
- 发布到 #executive，含日期、出席人数和议程链接

在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：会议要筛掉取消/特别场次并取最早日期，出席名单须剔除 recused 成员，Monday 的 meeting_date、prep_status、attendees 三个字段名要逐一对应。

## 1251 · `operations.zoom_change_advisory`（断言 7，负 3）

**中文业务请求**

喂，我们得为最紧急的高风险变更请求安排一次 CAB 会议。查看变更请求表（ss_change_requests，工作表 ws_pending），挑出该评审的那一条。只有 Approval Status 为 'Approved' 的变更才推进——被阻塞（blocked）的跳过。

安排一场 45 分钟的 Zoom 会议，时间为 2026-02-05T16:00:00Z，主题 'CAB Review: {Change Title}'；在 ws_it/proj_changes 创建一个 Asana 准备任务，截止日期为会议前一天，名称为 'Prepare CAB documentation: {Change Title}'；给 cab-members@company.example.com 发邮件，主题 'CAB Meeting: {Change Title}'；并发布到 #it-changes。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：只能选 Approved 且未被阻塞的变更，Zoom 主题、Asana 任务名和邮件主题三处占位符都要替换成实际的 Change Title。

## 1273 · `operations.zoom_deal_review`（断言 10，负 6）

**中文业务请求**

为价值最高的那笔停滞企业交易（stalled enterprise deal）安排一次评审。查看 Stalled Deals 表（ss_stalled/ws_deals）中的企业交易。选定前，先看表里的交易处理政策。

确定交易后：
- 安排一场 60 分钟的 Zoom 会议，时间为 2026-02-05 15:00 UTC，主题 'Deal Review: <Account Name>'
- 更新该 Salesforce 商机的 next step
- 在 Monday 看板 brd_sales 添加一条以 Account Name 命名的跟踪项
- 把交易详情发布到 #sales-leadership

在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。在消息中包含源数据里的相关金额。

**要点**：「价值最高」要按交易处理政策的口径筛选，不能只按金额取最大；消息里要带上源数据中的相关金额。

## 1255 · `operations.zoom_dr_drill`（断言 11，负 4）

**中文业务请求**

我们要为最久未测的关键生产系统安排一次 DR 演练。查看 DR systems 表（ss_dr_systems，ws_schedule）并挑出正确的那一个。选定前，先看表里的 DR 排期政策。这些系统的恢复时间目标（RTO）很紧，不能让演练拖延——在已就绪且尚未在进行中的系统里，选上次测试日期最早的那个。

安排一场 3 小时的 Zoom 会议，时间为 2026-02-08T06:00:00Z；在 Confluence（cloud_ops/SP_DR）记录演练计划；在 Asana（ws_it/proj_dr）创建准备/执行/报告三项任务，落在演练前后的几天；给 dr-team@company.example.com 发邮件；并发布到 #disaster-recovery。Zoom 会议命名为 'DR Drill: <System>'。Confluence 标题用 'DR Drill Plan: <System> - 2026-02-08'。三个 Asana 任务分别命名为 'Pre-drill checklist: <System>'、'Execute DR drill: <System>'、'Post-drill report: <System>'，截止日期依次为 2026-02-07、2026-02-08、2026-02-09。邮件主题用 'DR Drill Scheduled: <System>'，正文中要包含选中的 System Owner。在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：选取口径是「已就绪、未在进行中、上次测试日期最早」，多处命名模板与三个截止日期必须逐一落地，邮件正文还要带上 System Owner。

## 1277 · `operations.zoom_project_kickoff`（断言 8，负 3）

**中文业务请求**

为需要最先启动的那个已批准项目安排启动会。查看 Projects 表（ss_projects）中已批准的高优先级项目。

确定项目后：
- 安排一场 90 分钟的 Zoom 启动会，主题 'Project Kickoff: <Project Name>'
- 在 Trello 看板 brd_projects 的 'Active' 列表中为它创建一张卡片
- 在 Notion 的 pg_projects 下建一个项目 wiki 页面
- 为该项目创建一个 Slack 频道，并发布启动公告

**要点**：「最先启动」的排序依据要从表内日期与优先级判断，Zoom、Trello、Notion 与新建 Slack 频道四类产出缺一不可。

## 1263 · `operations.zoom_training_setup`（断言 8，负 4）

**中文业务请求**

安排待参训人数最多的那场强制性培训。查看 Training Schedule（ss_training）中已排定的强制性培训——注意遵循当前培训政策，并从 Trainers 表（ss_trainers/ws_certified）中找一位可用的讲师。

拿到细节后：
- 创建一场 Zoom 会议，主题与排期表中所写的培训主题完全一致，时间为排定日期当天 10:00 UTC，讲师为主持人
- 在 Monday 看板 brd_training 添加条目，命名为 '<Topic> - <Date>'，状态（training_status）设为 'Room Booked'，并写入参训人数
- 给 training-attendees@company.example.com 发邮件，主题 'Mandatory Training: <Topic>'，正文含日期、时长和讲师信息
- 在 Airtable（base_hr/Training Log）登记，字段用 Topic、Date、Trainer、Expected 和 Status

在通知或记录中引用源数据的值时，请原样保留（不要改写或四舍五入）。

**要点**：选「待参训人数最多」的培训，讲师须出自 ws_certified 且符合当前培训政策，Zoom 主题要与排期原文完全一致。
