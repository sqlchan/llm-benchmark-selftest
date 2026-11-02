# Automation-Bench 公开集中文翻译 · simple（第 1–25 条）

## 3176 · `simple.airtable_create_contact`（断言 1，负 0）

**中文业务请求**

在 Airtable CRM 中新增一个联系人。在 base_crm 的 'Contacts' 表中创建一条记录：Name='Jordan Lee'、Email='jordan.lee@nexgen.example.com'、Company='NexGen Solutions'、Role='Product Manager'。

**要点**：须在 base_crm 的 'Contacts' 表新建记录，四个字段名与取值一字不差（邮箱拼写、公司名大小写都不能改）。

## 3179 · `simple.airtable_event_attendee`（断言 1，负 0）

**中文业务请求**

在 base_events 的 Event Attendees 表中新增一位参会者。创建一条记录：Name='Aisha Patel'、Email='aisha.patel@summit.example.com'、Event='Tech Summit 2026'、RSVP='Confirmed'。

**要点**：base 是 base_events、表是 Event Attendees，RSVP 取值必须为 'Confirmed'。

## 3181 · `simple.airtable_find_update`（断言 1，负 0）

**中文业务请求**

在 Airtable 的 base_crm 'Contacts' 表中查找邮箱为 'jordan@example.com' 的联系人（使用 airtable_findRecord 查询），然后在同一张表中创建一条新记录，将其标记为 VIP：Name='Jordan Lee'、Email='jordan@example.com'、Status='VIP'。

**要点**：先用 airtable_findRecord 查到人、再在同一张表里新建 VIP 记录——查找与写入是两步，不能省掉查找或写错表。

## 3182 · `simple.airtable_followup_task`（断言 1，负 0）

**中文业务请求**

在 base_pm 的 'Tasks' 表中创建一条记录：Name='Follow up with Meridian Group'、Due Date='2026-03-01'、Priority='High'、Assignee='Sales Team'。

**要点**：Due Date 须写成 '2026-03-01' 这种日期格式，四个字段都不能漏。

## 3185 · `simple.airtable_new_vendor`（断言 1，负 0）

**中文业务请求**

在 Airtable 中新增一个供应商。在 base_ops 的 'Vendors' 表中创建一条记录：Name='CloudForge Inc.'、Contact='Wei Zhang'、Email='wei.zhang@cloudforge.example.com'、Service='Cloud Infrastructure'。

**要点**：base 是 base_ops、表是 'Vendors'，Contact 填的是联系人姓名 'Wei Zhang' 而不是公司名。

## 3178 · `simple.airtable_update_deal`（断言 1，负 0）

**中文业务请求**

在 Airtable 的 base_crm 'Deals' 表中创建一条记录，把 deal rec_001 标记为已赢单。将 Name 设为 'Acme Corp Deal'，Status 设为 'Won'。

**要点**：要求是新建一条记录来标记 rec_001 赢单，不是去改已有记录；Status 必须是 'Won'。

## 3184 · `simple.airtable_update_slack_notify`（断言 2，负 0）

**中文业务请求**

更新 Airtable 中 base_pm 'Projects' 表的记录 rec_005：把 Status 设为 'Completed'。然后向 Slack 的 #operations 频道发送通知，说明该项目已完成。

**要点**：两个断言对应两个动作——先更新 rec_005 的状态，再向 #operations 发完成通知，只做其中一件就会丢分。

## 3174 · `simple.api_key_jira_slack`（断言 2，负 0）

**中文业务请求**

我们支付网关的生产 API key 将于 2026 年 3 月 1 日过期。在 INFRA 项目中创建一个 Jira 工单，标题为 'Rotate payment gateway API key'，优先级为高，并向 Slack 的 #security 频道发送告警。

**要点**：Jira 工单必须落在 INFRA 项目且为高优先级，同时还要发 #security 告警——工单与告警两件事都要做。

## 3101 · `simple.asana_api_docs_task`（断言 1，负 0）

**中文业务请求**

请创建一个名为 'Update API documentation' 的 Asana 任务。把它加入 workspace ws_prod 下的 Engineering 项目（proj_eng），并将截止日期设为 2026 年 3 月 7 日。

**要点**：workspace ws_prod 与项目 proj_eng 的组合不能配错，截止日期为 2026 年 3 月 7 日。

## 3103 · `simple.asana_board_presentation`（断言 1，负 0）

**中文业务请求**

在 workspace ws_exec 的 Executive 项目（proj_exec）中创建一个名为 'Prepare Q1 board presentation' 的 Asana 任务。将截止日期设为 2026 年 2 月 28 日。

**要点**：这题的 workspace 是 ws_exec 而非 ws_prod，项目为 proj_exec，容易沿用上一题的默认 workspace。

## 3108 · `simple.asana_checkout_bug_from_email`（断言 1，负 0）

**中文业务请求**

在我的收件箱中查找最近一封 bug 报告邮件。然后在 workspace ws_prod 的 Engineering 项目（proj_eng）中创建一个名为 'Fix checkout bug' 的 Asana 任务。

**要点**：要先去收件箱核实那封 bug 报告邮件，再在 proj_eng 里建任务，跳过查邮件这步就只算做了一半。

## 3102 · `simple.asana_dark_mode_from_email`（断言 1，负 0）

**中文业务请求**

在我的收件箱中查找最近一封客户提出新功能需求的邮件。然后在 workspace ws_prod 的 Product Backlog 项目（proj_backlog）中创建一个名为 'Add dark mode feature' 的 Asana 任务。

**要点**：任务要落在 Product Backlog（proj_backlog）而不是 Engineering，且需先从收件箱找到那封需求邮件。

## 3106 · `simple.asana_monitoring_alerts`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 Infrastructure 项目（proj_infra）中创建一个名为 'Set up monitoring alerts' 的 Asana 任务。在描述中注明我们需要为 CPU 使用率、内存、磁盘空间和 API 响应时间设置告警。

**要点**：描述里必须列出全部四项监控对象（CPU 使用率、内存、磁盘空间、API 响应时间），少一项就不完整。

## 3107 · `simple.asana_performance_reviews`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 People Ops 项目（proj_people）中创建一个名为 'Schedule performance reviews' 的 Asana 任务。将截止日期设为 2026 年 3 月 15 日。

**要点**：项目是 People Ops（proj_people），截止日期为 2026 年 3 月 15 日。

## 3109 · `simple.asana_rfp_response`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 Sales 项目（proj_sales）中创建一个名为 'Prepare RFP response for GlobalCorp' 的 Asana 任务。将截止日期设为 2026 年 2 月 28 日。

**要点**：客户名 GlobalCorp 必须原样出现在任务标题里，截止日期为 2026 年 2 月 28 日。

## 3105 · `simple.asana_sprint_section_task`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 Engineering 项目（proj_eng）中创建一个名为 'Refactor payment module' 的 Asana 任务，截止日期为 2026 年 3 月 14 日。然后找到 proj_eng 中的 'Sprint 8' section，把该任务加入这个 section。

**要点**：建完任务还要定位 'Sprint 8' section 并归入其中，两步缺一不可。

## 3110 · `simple.asana_team_offsite`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 People Ops 项目（proj_people）中创建一个名为 'Organize team offsite logistics' 的 Asana 任务。

**要点**：这题只要求建任务，不要自行加截止日期或归入 section 而引入多余改动。

## 3104 · `simple.asana_vendor_contracts_urgent`（断言 1，负 0）

**中文业务请求**

在 workspace ws_prod 的 Legal 项目（proj_legal）中创建一个名为 'Review vendor contracts' 的 Asana 任务。创建之后，给该任务加上 'urgent' 标签（tag_urgent）。

**要点**：任务建好后还要追加 tag_urgent 标签，只建任务不加标签是最常见的漏做。

## 3058 · `simple.buffer_company_award`（断言 1，负 0）

**中文业务请求**

安排一条 Facebook 帖子，庆祝 BrightPath 入选 2025 年 Forbes Cloud 100 榜单。向促成此事的团队和客户表达感谢。把它安排在周五下午发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：必须先用 buffer_list_channels 定位到 Facebook 频道，发布时间为本周五下午，且不能漏掉对团队与客户的致谢。

## 3056 · `simple.buffer_customer_success_story`（断言 1，负 0）

**中文业务请求**

安排一条 Twitter 帖子，分享一个客户成功案例。使用 Meridian Health 的 CTO Priya Sharma 的这句话：'BrightPath 的自动化平台把我们的入职流程时间缩短了 60%，我们的团队对此再满意不过。' 把它安排在周三上午发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：帖子要发到 Twitter 频道，引语须保留 60% 这个数字和发言人身份，时间为本周三上午。

## 3053 · `simple.buffer_facebook_blog_post`（断言 1，负 0）

**中文业务请求**

安排一条 Facebook 帖子，推广我们最新的一篇博客文章，标题为 '5 Remote Work Tips for Staying Productive in 2026'。文章链接：blog.brightpath.example.com/remote-work-tips。让内容更有吸引力，并安排在周一上午发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：文章标题与链接必须原样带上，时间是周一上午、频道为 Facebook。

## 3057 · `simple.buffer_job_opening`（断言 1，负 0）

**中文业务请求**

安排一条 LinkedIn 帖子，介绍我们正在招聘的 Senior Backend Engineer 岗位。说明我们是 remote-first 公司、提供有竞争力的福利，该岗位涉及构建可扩展的微服务。申请地址 careers.brightpath.example.com。把它安排在明天发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：remote-first、有竞争力福利、构建可扩展微服务这三个卖点与申请链接都要写到，发布时间为明天。

## 3052 · `simple.buffer_linkedin_partnership`（断言 1，负 0）

**中文业务请求**

安排一条 LinkedIn 帖子，宣布我们与 TechVision Inc. 达成新的战略合作。说明该合作将扩展我们的 AI 能力，我们对在下一代解决方案上的协作感到兴奋。把它安排在本周五发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：频道选 LinkedIn，合作方名称 TechVision Inc. 原样保留，发布时间为本周五。

## 3059 · `simple.buffer_product_tip`（断言 1，负 0）

**中文业务请求**

安排一条 Twitter 帖子，分享一个产品小技巧。技巧内容：'你知道在 BrightPath 里用键盘快捷键 Ctrl+Shift+A 就能从任意工作流步骤即时创建自动化吗？今天就来试试！' 把它安排在下周二发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：快捷键必须写成 Ctrl+Shift+A，时间为下周二、频道为 Twitter。

## 3060 · `simple.buffer_trade_show`（断言 2，负 0）

**中文业务请求**

在 Twitter 和 LinkedIn 上各安排一条帖子，宣布 BrightPath 将参加 2026 年 3 月 18–20 日在旧金山举办的 SaaStr Annual 2026。我们会在 412 号展位。说明参会者可在 brightpath.example.com/saastr 预约演示。两条都安排在下周一发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：两个断言对应两个平台各一条帖子，日期（3 月 18–20 日、下周一）、412 号展位和预约链接都不能漏。

## 3051 · `simple.buffer_twitter_product_launch`（断言 1，负 0）

**中文业务请求**

请安排一条帖子到我们的 Twitter 频道，宣布我们的产品发布活动。活动名为 'NexGen 2.0 Launch'，将于 2 月 28 日下午 2 点（EST）举行。注册链接：nexgen.example.com/launch。把它安排在明天上午发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：活动名、日期时间（2 月 28 日下午 2 点 EST）与注册链接要原样写进帖子，且必须先用 buffer_list_channels 定位 Twitter 频道。

## 3054 · `simple.buffer_twitter_quarterly_results`（断言 1，负 0）

**中文业务请求**

安排一条 Twitter 帖子，为我们的 2025 年第四季度业绩预热。提到营收同比增长 32%，并说明完整报告将于下周一发布。语气要专业又令人振奋。把它安排在明天中午发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：32% 的同比增长率和「下周一发布完整报告」两个信息都不能少，频道为 Twitter。

## 3055 · `simple.buffer_webinar_dual_post`（断言 2，负 0）

**中文业务请求**

在我们的 Twitter 和 LinkedIn 两个频道上都安排帖子，推广即将举办、题为 'Scaling Your Business with AI Automation' 的网络研讨会，时间是 3 月 12 日下午 1 点（EST）。注册链接：brightpath.example.com/webinar-ai。两条帖子都安排在本周四发布。使用 organization ID org_001，并用 buffer_list_channels 找到正确的频道。

**要点**：两个断言对应两个平台各一条帖子，研讨会名称、3 月 12 日下午 1 点（EST）与注册链接都要一致，只发一个平台就会丢分。

## 3195 · `simple.campaign_launch_asana`（断言 2，负 0）

**中文业务请求**

我们即将启动 'Spring Promo 2026' 营销活动。请在 Slack 的 #marketing 频道发布一条关于活动启动的公告，并在 ws_marketing workspace 中创建一个名为 'Monitor Spring Promo 2026 metrics' 的 Asana 任务。

**要点**：公告要发到 #marketing，任务要建在 ws_marketing workspace 且标题一字不差，两个动作缺一不可。

## 3166 · `simple.close_deal_sf_slack`（断言 2，负 0）

**中文业务请求**

NovaTech 的单子已经成交！请把 Salesforce 中名为 'NovaTech Enterprise Deal' 的商机（ID: opp_401）的阶段更新为 'Closed Won'，并向 Slack 的 #sales 频道发送一条庆祝消息。

**要点**：要更新的是 opp_401 这个指定商机、阶段名必须为 'Closed Won'，同时还要在 #sales 发庆祝消息。

## 3190 · `simple.csat_sheets_slack_alert`（断言 2，负 0）

**中文业务请求**

我们通过邮件收到了一份客户满意度调查回复。客户给出的评分是 10 分中的 4 分。请读取该邮件，把这条回复记录到 Google 表格 'ss_csat'（worksheet ID: sheet1）中，包含客户姓名和评分；由于评分低于 7 分，还要向 Slack 的 #support 频道发出提醒。

**要点**：评分 4 分要原样写入 ss_csat 的 sheet1，并因低于 7 分的阈值而额外触发 #support 告警——低分判定与告警是两个断言。

## 3198 · `simple.customer_question_zendesk_reply`（断言 2，负 0）

**中文业务请求**

一位客户发邮件询问我们的定价档位。请读取该邮件，回复一封有帮助的说明，提到我们的 Basic（$29/月）、Pro（$79/月）和 Enterprise（定制）套餐，并创建一个 Zendesk 工单来跟踪这次咨询。

**要点**：回复中三档价格必须写全（Basic $29/月、Pro $79/月、Enterprise 定制），且要另建 Zendesk 工单留痕。

## 3196 · `simple.demo_request_zoom_email`（断言 2，负 0）

**中文业务请求**

一位客户发邮件申请产品演示。请读取该邮件，创建一个名为 'Product Demo - Cascade Solutions' 的 Zoom 会议，时间为 2026 年 2 月 28 日下午 3:00（时长 30 分钟），并把会议详情发送给申请人。

**要点**：会议名、日期时间（2026-02-28 15:00）与 30 分钟时长要一致，且建完会议还要把详情回给申请人。

## 3183 · `simple.email_airtable_customer_welcome`（断言 2，负 0）

**中文业务请求**

收到一封新客户 onboarding 邮件。请读取该邮件，在 base_crm 的 'Customers' 表中创建一条 Airtable 记录，填入邮件中的客户姓名和公司，并向这位新客户发送一封欢迎邮件。

**要点**：Airtable 记录要落在 base_crm 的 'Customers' 表且姓名、公司取自邮件内容，同时还要发出欢迎邮件。

## 3177 · `simple.email_airtable_lead`（断言 1，负 0）

**中文业务请求**

收到一封来自潜在客户的咨询邮件。请读取该邮件，并在 base_crm 的 'Leads' 表中创建一条 Airtable 记录，填入发件人姓名、邮箱以及其咨询主题。

**要点**：记录要建在 base_crm 的 'Leads' 表，姓名、邮箱、咨询主题三个字段都要从邮件里取到。

## 3180 · `simple.email_airtable_project`（断言 1，负 0）

**中文业务请求**

收到一封包含新项目详情的邮件。请读取该邮件，把该项目作为一条 Airtable 记录登记到 base_pm 的 'Projects' 表中。记录中要包含邮件里的项目名称和状态。

**要点**：base 是 base_pm、表是 'Projects'，项目名称与状态都要照邮件填写。

## 3157 · `simple.email_asana_task_reply`（断言 2，负 0）

**中文业务请求**

一位客户发邮件提出了功能需求。请读取该邮件，为产品团队创建一个 Asana 任务以便评审，并回复发件人确认我们已收到。

**要点**：既要在 Asana 为产品团队建任务，又要回信确认收到——只建任务不回复就会丢掉一个断言。

## 3163 · `simple.email_calendar_meeting_reply`（断言 2，负 0）

**中文业务请求**

一位客户发邮件请求安排会议。请读取该邮件，在 Google Calendar 中创建一个名为 'Client Call with Apex Systems' 的日程，时间为 2026 年 2 月 26 日下午 2:00、时长 1 小时，并回复确认会议时间。

**要点**：日程名称、日期时间（2026-02-26 14:00，1 小时）要准确，且需回信确认时间。

## 3042 · `simple.email_hs_create_contact`（断言 1，负 0）

**中文业务请求**

我们收到了 Nathan Brooks 发来的一封介绍邮件。请找到该邮件，并根据其中的信息创建一个 HubSpot 联系人。

**要点**：要先去收件箱找到 Nathan Brooks 的那封邮件，再按邮件内容建 HubSpot 联系人，不能凭标题臆填信息。

## 3047 · `simple.email_hs_create_contact_inbound`（断言 1，负 0）

**中文业务请求**

我们收到一封来自潜在客户的主动咨询邮件。请找到 Liam Foster 发来的那封邮件，并根据其中的详细信息创建一个 HubSpot 联系人。

**要点**：收件人是 Liam Foster，须先定位该邮件，再据邮件里的细节建 HubSpot 联系人。

## 3159 · `simple.email_hubspot_contact_reply`（断言 2，负 0）

**中文业务请求**

收到一封销售咨询邮件。请读取该邮件，为发件人创建一个新的 HubSpot 联系人，并回复一封邮件感谢对方的关注。

**要点**：创建 HubSpot 联系人和回信致谢是两个断言，发件人信息须取自邮件正文。

## 3164 · `simple.email_hubspot_deal_slack`（断言 2，负 0）

**中文业务请求**

收到一封合作伙伴拓展邮件。请读取该邮件，在 HubSpot 中创建一个名为 'Vertex Labs Partnership'、金额为 75000 的商机，并通知 Slack 的 #partnerships 频道。

**要点**：商机名 'Vertex Labs Partnership' 与金额 75000 都要准确，且需同步通知 #partnerships 频道。

## 3158 · `simple.email_jira_bug_slack`（断言 2，负 0）

**中文业务请求**

一位客户通过邮件报告了一个 bug。请读取该邮件，在 PLAT 项目中创建一个 Jira bug 工单，并就该问题通知 Slack 的 #engineering 频道。

**要点**：工单类型必须是 bug、项目必须是 PLAT，并同时向 #engineering 发出通知。

## 3194 · `simple.email_jira_story_reply`（断言 2，负 0）

**中文业务请求**

一位客户通过邮件发来了功能反馈。请读取该邮件，在 PROD 项目中创建一个记录该反馈的 Jira story，并回复客户感谢其意见。

**要点**：Jira 侧要建 story 而非 bug、项目为 PROD，同时还要回信致谢客户。

## 3005 · `simple.email_sf_contact_account_update`（断言 1，负 0）

**中文业务请求**

David Kim 发来邮件说他已跳槽到一家新公司。请找到该邮件，并在 Salesforce 中更新他的账户名称（account name）。

**要点**：要改的是 David Kim 的 account name 字段，新公司名须取自邮件正文，不能改错联系人。

## 3010 · `simple.email_sf_contact_assistant_update`（断言 2，负 0）

**中文业务请求**

Rachel Nguyen 发来邮件介绍了她的新助理。请找到该邮件，并在 Salesforce 中更新 Rachel 的助理姓名（assistant name）和助理邮箱（assistant email）。

**要点**：assistant name 与 assistant email 两个字段都要更新，两个断言各自校验一个字段。

## 3004 · `simple.email_sf_contact_city_update`（断言 1，负 0）

**中文业务请求**

Lisa Park 发邮件告知她公司办公室搬迁。请找到该邮件，并在 Salesforce 中更新她的邮寄城市（mailing city）。

**要点**：要改的是 mailing city 字段、对象是 Lisa Park，新城市须取自邮件而不是随口补。

## 3009 · `simple.email_sf_contact_department_update`（断言 1，负 0）

**中文业务请求**

Amir Hassan 发邮件说他调换了部门。请找到该邮件，并在 Salesforce 中更新他的部门（department）。

**要点**：只更新 department 字段且对象是 Amir Hassan，新部门名称须与邮件一致。

## 3002 · `simple.email_sf_contact_email_update`（断言 1，负 0）

**中文业务请求**

Maria Santos 发邮件说她换了新的邮箱地址。请找到她的邮件，并在 Salesforce 中用这个新地址更新她的联系人记录。

**要点**：要改的是 Maria Santos 联系人的邮箱字段，新地址必须原样取自邮件。

## 3008 · `simple.email_sf_contact_fax_update`（断言 1，负 0）

**中文业务请求**

Priya Patel 的助理发来一封邮件，附上了更新后的传真号码。请找到该邮件，并在 Salesforce 中更新 Priya 的传真号码（fax number）。

**要点**：邮件是助理发的、但要改的是 Priya Patel 的 fax number，别把联系人搞成发件人。

## 3007 · `simple.email_sf_contact_mobile_update`（断言 1，负 0）

**中文业务请求**

Marcus Rivera 发来邮件，告知了他的新直线手机号。找到这封邮件，并在 Salesforce 中更新他的 mobile phone。

**要点**：从邮件里取出新号码后只改 Marcus Rivera 的 mobile phone 字段，别改错联系人、也别动其它电话字段。

## 3160 · `simple.email_sf_contact_onboard`（断言 1，负 0）

**中文业务请求**

一位新团队成员的欢迎邮件到了。读这封邮件，用邮件里的信息为这个人创建一个 Salesforce 联系人。公司（company）统一填 'Acme Corp'。

**要点**：姓名、邮箱、电话等取自媒体邮件，company 固定填 'Acme Corp'，不能拿邮件里出现的其它公司名顶上。

## 3001 · `simple.email_sf_contact_phone_update`（断言 1，负 0）

**中文业务请求**

Jordan Lee 刚发邮件告诉我们她的新电话号码。你能找到那封邮件，并在 Salesforce 中更新她的电话号码吗？

**要点**：只更新电话字段，且必须用邮件里的新号码，抄错一位或改到别人的记录上都算错。

## 3003 · `simple.email_sf_contact_title_update`（断言 1，负 0）

**中文业务请求**

Tyler Chen 发邮件告诉我们他升职了。找到这封邮件，并更新他在 Salesforce 中的 title。

**要点**：必须先从邮件里读出晋升后的新职位名称再写进 title，不能凭猜测填一个职位。

## 3040 · `simple.email_sf_create_contact_from_lead`（断言 1，负 0）

**中文业务请求**

我们收到一位新线索客户 Sophie Laurent 发来的邮件，里面有她的联系方式。找到这封邮件，并用邮件中的信息创建一个新的 Salesforce 联系人。

**要点**：要新建联系人记录（而不是更新已有记录），姓名、邮箱、电话等字段全部取自该邮件。

## 3006 · `simple.email_sf_lead_description_update`（断言 1，负 0）

**中文业务请求**

Sarah Johnson 发来一封邮件，签名里带了她的 LinkedIn 主页。找到这封邮件，并更新她在 Salesforce 中的 lead 描述（description），把该 LinkedIn URL 包含进去。

**要点**：改的是 lead 记录的 description 而非联系人字段，LinkedIn URL 要从邮件签名里原样取出。

## 3037 · `simple.email_sf_lead_rating_hot`（断言 1，负 0）

**中文业务请求**

我们收到线索客户 Ben Archer 发来的一封非常热情的邮件。找到这封邮件，再在 Salesforce 中找到他的 lead 记录，把他的 rating 更新为 'Hot'。

**要点**：先看邮件再改 lead 的 rating，取值必须是 'Hot'（大小写也要一致）。

## 3023 · `simple.email_sf_log_task`（断言 1，负 0）

**中文业务请求**

我们刚收到 Natalie Wong 关于项目时间线的邮件。找到这封邮件，并在她的联系人记录（003002）上把它登记为一条 Salesforce 任务，主题为 'Email received from client'。

**要点**：任务必须挂到指定的联系人记录 003002 上，主题一字不差，别另建一条不属于她的任务。

## 3156 · `simple.email_sf_update_slack_notify`（断言 2，负 0）

**中文业务请求**

Riley Thompson 刚发邮件确认了新的头衔。把 Riley 在 Salesforce 中的 job title 更新为 'VP of Operations'，并在 Slack 的 #sales 频道通报这次更新。

**要点**：两个断言对应两件事——Salesforce 里把 title 改成 'VP of Operations'，同时在 #sales 频道发通知，只做一件就丢分。

## 3162 · `simple.email_sheets_log_reply`（断言 2，负 0）

**中文业务请求**

一封客户反馈邮件到了。读这封邮件，把反馈记录到 Google Sheet 'ss_feedback'（worksheet ID：sheet1），包含客户名称和反馈摘要，然后发一封感谢回复。

**要点**：表格必须是 ss_feedback 的 sheet1，记录里要同时有客户名与反馈摘要，且必须真的发出感谢回复。

## 3165 · `simple.email_sheets_update_reply`（断言 2，负 0）

**中文业务请求**

开发团队发来一封项目进展邮件。读这封邮件，向 Google Sheet 'ss_projects'（worksheet ID：sheet1）追加一行，项目名写 'Mobile App v2'、状态写 'Phase 2 Complete'，然后回信确认并说明后续步骤。

**要点**：表是 ss_projects 的 sheet1，项目名与状态字符串原样写入；回信要同时给出确认和下一步安排。

## 3161 · `simple.email_zendesk_ack_reply`（断言 2，负 0）

**中文业务请求**

一位客户就合同问题发来邮件。读这封邮件，为法务团队创建一张 Zendesk 工单，并发送回复确认已收到其咨询。

**要点**：工单要归到法务团队（legal），同时还要回一封确认邮件，建单与回信两件事都不能省。

## 3187 · `simple.escalation_zendesk_slack`（断言 2，负 0）

**中文业务请求**

一位企业客户发来一封升级投诉邮件。读这封邮件，创建一张高优先级 Zendesk 工单，并向 Slack 的 #escalations 频道发送告警，在告警中 @ 客服经理（support manager）。

**要点**：工单优先级必须是高优先级，Slack 告警要发到 #escalations 并点名客服经理，两者缺一不可。

## 3173 · `simple.event_asana_calendar`（断言 2，负 0）

**中文业务请求**

我们要启动年度公司团建的筹备工作。在 workspace ws_ops 中创建一个 Asana 任务 'Plan Annual Company Retreat'；再为 2026 年 3 月 5 日上午 11:00 创建一个名为 'Company Retreat Planning Kickoff'、时长 1 小时的 Google Calendar 事件。

**要点**：Asana 任务必须落在 ws_ops，日历事件的时间为 2026-03-05 11:00、时长 1 小时，两个系统各建一条。

## 3169 · `simple.feature_launch_slack`（断言 2，负 0）

**中文业务请求**

新的 analytics dashboard 功能已就绪、可以上线了。在 Slack 的 #product 频道发布公告，说明新的 analytics dashboard 已上线；并在 workspace ws_prod 中创建一个 Asana 任务 'Monitor analytics dashboard launch'。

**要点**：公告要发到 #product 且明确说明功能已上线，Asana 任务要落在 ws_prod。

## 3132 · `simple.gcal_client_discovery_call`（断言 1，负 0）

**中文业务请求**

在 work 日历（ID：cal_primary）上创建一个与 Acme Corp 的客户需求沟通电话（client discovery call）事件。时间定在 2026 年 2 月 26 日下午 2:00 EST（19:00 UTC）。添加参会人：sarah.jones@acmecorp.example.com 和 agent@company.example.com。

**要点**：事件要建在 cal_primary 上，时间按 2:00 PM EST / 19:00 UTC 换算，两个参会人邮箱都要加上。

## 3134 · `simple.gcal_company_holiday`（断言 1，负 0）

**中文业务请求**

在 work 日历（ID：cal_primary）上为 2026 年 2 月 17 日创建一个名为 'Company Holiday - Presidents Day' 的全天事件。

**要点**：必须是全天（all-day）事件，标题里的连字符与 'Presidents Day' 写法原样保留，日期为 2026-02-17。

## 3137 · `simple.gcal_customer_success_checkin`（断言 1，负 0）

**中文业务请求**

创建一个名为 'Customer Success Check-in - TechVentures' 的日历事件，时间为 2026 年 3 月 4 日下午 1:00 EST（18:00 UTC），时长 45 分钟。添加参会人：csm@company.example.com 和 contact@techventures.example.com。

**要点**：时长是 45 分钟（不是默认 1 小时），客户名 TechVentures 与两个参会邮箱都要原样写入。

## 3140 · `simple.gcal_new_hire_orientation`（断言 1，负 0）

**中文业务请求**

创建一个名为 'New Hire Orientation' 的日历事件，时间为 2026 年 3 月 3 日上午 9:00 EST（14:00 UTC），时长 3 小时。添加参会人：hr@company.example.com、new.hire1@company.example.com 和 new.hire2@company.example.com。

**要点**：时长 3 小时，三名参会人一个都不能漏，时间要按 EST/UTC 双写换算。

## 3136 · `simple.gcal_one_on_one`（断言 1，负 0）

**中文业务请求**

在 work 日历（ID：cal_primary）上创建一个名为 '1:1 with Jordan' 的日历事件，时间为 2026 年 2 月 26 日（周四）上午 11:00 EST（16:00 UTC），时长 30 分钟。把 jordan.lee@company.example.com 加为参会人。

**要点**：标题里的 '1:1' 写法要保留，事件须建在 cal_primary 上、时长 30 分钟。

## 3139 · `simple.gcal_partnership_call_from_email`（断言 1，负 0）

**中文业务请求**

在我的收件箱里查找一封关于安排合作通话（partnership call）的邮件。然后按邮件中要求的时间与细节创建一个日历事件。

**要点**：不能凭印象直接建事件，必须先从收件箱找到那封邮件，再按邮件里的时间、标题与参会人建事件。

## 3133 · `simple.gcal_product_review_from_email`（断言 1，负 0）

**中文业务请求**

在我的收件箱里查找一封关于产品评审（product review）的会议邀约邮件。然后按邮件中的细节，在 work 日历（ID：cal_primary）上创建一个名为 'Product Review Meeting' 的日历事件。

**要点**：标题固定为 'Product Review Meeting'，事件须建在 cal_primary 上，其余时间等细节取自邮件。

## 3135 · `simple.gcal_quarterly_business_review`（断言 1，负 0）

**中文业务请求**

创建一个名为 'Quarterly Business Review' 的日历事件，时间为 2026 年 3 月 31 日上午 10:00 EST（15:00 UTC），时长 2 小时。地点设为 'Conference Room A'。添加参会人：cfo@company.example.com 和 vp-sales@company.example.com。

**要点**：除时间与时长外，location 必须填 'Conference Room A'，两个参会邮箱都不能漏。

## 3138 · `simple.gcal_team_offsite`（断言 1，负 0）

**中文业务请求**

创建一个名为 'Engineering Team Offsite' 的全天日历事件，跨 2026 年 3 月 14–15 日（共两天）。地点设为 'Lakeview Resort'。添加参会人：eng-team@company.example.com。

**要点**：全天事件且要跨两天（3 月 14 日至 15 日），结束日期不能写成单日或误写成 16 日。

## 3131 · `simple.gcal_weekly_standup`（断言 1，负 0）

**中文业务请求**

在 work 日历（ID：cal_primary）上创建一个名为 'Weekly Team Standup' 的重复日历事件，每周一上午 9:00 EST（14:00 UTC），时长 30 分钟。添加参会人：alice@company.example.com、bob@company.example.com 和 carol@company.example.com。

**要点**：考点在「重复」——必须设成每周一的 recurrence，只建一次性的单场事件会判错；时长 30 分钟、三名参会人要齐全。

## 3070 · `simple.gmail_contract_renewal_reminder`（断言 1，负 0）

**中文业务请求**

给 Ben Torres（ben.torres@summitretail.example.com）发送一封合同续约提醒邮件。主题：Your BrightPath Contract Renewal - Action Required。告知他的年度合同将于 2026 年 3 月 31 日到期。如果他于 3 月 15 日前完成签约，可享受 10% 的提前续约折扣。附上续约门户链接：renewals.brightpath.example.com。

**要点**：主题行须原样保留英文，到期日 3 月 31 日、折扣截止日 3 月 15 日、10% 折扣与续约门户链接四项缺一不可。

## 3062 · `simple.gmail_demo_followup`（断言 1，负 0）

**中文业务请求**

在今天的产品演示通话之后，给 Derek Hanson（derek.hanson@novacorp.example.com）发一封跟进邮件。感谢他抽出时间，回顾我们展示了工作流自动化与报表看板，并说明我们会在本周末前发送方案。主题：Great connecting today - BrightPath Demo Follow-up。

**要点**：主题行与收件人邮箱须原样保留，正文要覆盖「感谢 + 演示内容回顾 + 本周末前发方案」三要素。

## 3067 · `simple.gmail_invoice_email`（断言 1，负 0）

**中文业务请求**

给 Rachel Kim（rachel.kim@globexfin.example.com）发送邮件，主题为 'Invoice #INV-2026-0342 - February Services'。告知她 2 月咨询服务、金额 $12,500 的发票已作为附件附上。付款条件为 Net 30。引用附件文件 invoice_INV-2026-0342.pdf。

**要点**：发票号 INV-2026-0342、金额 $12,500、Net 30 与附件文件名必须与题面完全一致。

## 3061 · `simple.gmail_meeting_confirm`（断言 1，负 0）

**中文业务请求**

给 Maya Rodriguez（maya.rodriguez@clientco.example.com）发一封确认邮件，确认她的会议请求。会议已定于 2026 年 2 月 25 日（周二）上午 10 点（EST）。主题：Meeting Confirmed - Tuesday Feb 25th。

**要点**：主题行固定为 'Meeting Confirmed - Tuesday Feb 25th'，会议日期与时间（周二、2 月 25 日、上午 10 点 EST）须写准。

## 3069 · `simple.gmail_onboarding_welcome`（断言 1，负 0）

**中文业务请求**

给我们的新客户 Fatima Al-Hassan（fatima.alhassan@crescentlogistics.example.com）发送一封入驻欢迎邮件。主题：Welcome to BrightPath! Let's Get Started。内容包括：她的账户已激活；她可以登录 app.brightpath.example.com；她的入驻培训安排在 3 月 3 日上午 11 点（EST）；她的专属客户成功经理是 Olivia Park。

**要点**：账户状态、登录地址、培训时间、客户成功经理姓名四个信息点都要写全，邮箱与主题原样保留。

## 3068 · `simple.gmail_reply_complaint`（断言 1，负 0）

**中文业务请求**

我们收到了 James Whitfield 关于仪表盘加载缓慢的投诉邮件。找到他的邮件并回复致歉。承认该问题，说明我们的工程团队已定位到原因、修复将在 48 小时内上线，并提出在下次续约时给予 15% 折扣作为善意补偿。

**要点**：必须先在收件箱里找到 James Whitfield 的原邮件并「回复」该线程，而不是新发一封；48 小时与 15% 两个数字不能改。

## 3064 · `simple.gmail_reply_customer_inquiry`（断言 1，负 0）

**中文业务请求**

我收到一位客户询问我们 API 速率限制的邮件。找到 Tomoko Ishida 发来的邮件并回复，告知她标准版套餐允许每分钟 1,000 次 API 调用，企业版则提供每分钟 10,000 次。附上我们的文档链接：docs.brightpath.example.com/rate-limits。

**要点**：须找到 Tomoko Ishida 的邮件后回复该线程，标准版 1,000 次/分钟与企业版 10,000 次/分钟两个数字及文档链接都不能错。

## 3066 · `simple.gmail_reply_meeting_request`（断言 1，负 0）

**中文业务请求**

我有一封 Anika Patel 发来的会议请求邮件。找到这封邮件并回复，确认我可以参加 2026 年 2 月 27 日（周四）下午 3 点（EST）的会议。告知她我会提前准备好季度复盘幻灯片。

**要点**：要在原会议请求线程上回复，会议时间（周四、2 月 27 日、下午 3 点 EST）与「提前准备季度复盘幻灯片」都要写到。

## 3065 · `simple.gmail_reply_pricing_inquiry`（断言 1，负 0）

**中文业务请求**

一位客户发邮件询问定价。找到 Luis Moreno 的邮件并回复我们的报价：Starter 套餐为每用户每月 $49，Professional 为每用户每月 $99，Enterprise 为定制报价。引导他前往 brightpath.example.com/pricing-call 预约通话，以咨询企业版相关事宜。

**要点**：须回复 Luis Moreno 的原有线程，三档价格（$49、$99、定制）与预约链接不得遗漏或改数。

## 3063 · `simple.gmail_weekly_status`（断言 1，负 0）

**中文业务请求**

给团队 team@brightpath.example.com 发送每周状态更新邮件。主题：Weekly Status Update - Feb 24。包含以下进展：1) 已完成与 Salesforce 的 API 集成，2) 客户入驻看板已完成 80%，3) 下周将专注于 QA 测试与缺陷修复。

**要点**：主题、团队邮箱与三条编号进展都要完整，第 2 条的 80% 与 Salesforce 集成是易漏细节。

## 3041 · `simple.hs_create_contact`（断言 1，负 0）

**中文业务请求**

在 HubSpot 中新建一个联系人：姓名 Olivia Harper，邮箱 olivia.harper@nexwave.example.com，电话 +1-555-4141，公司 NexWave Solutions。

**要点**：四个字段都要填，邮箱拼写与公司名大小写须与题面一致。

## 3044 · `simple.hs_create_deal`（断言 1，负 0）

**中文业务请求**

在 HubSpot 中新建一个交易：'Acme Corp - Enterprise License'，金额 $25,000，阶段为 'Appointment Scheduled'。

**要点**：交易名称原样保留，金额 $25,000 与阶段 'Appointment Scheduled' 必须精确写对。

## 3049 · `simple.hs_create_deal_with_contact`（断言 1，负 0）

**中文业务请求**

在 HubSpot 中新建交易 'BluePeak - Platform Migration'，金额 $50,000，阶段 'Qualified to Buy'，并将其关联到联系人 hs_005（Andre Williams）。

**要点**：除了建交易，还必须把它关联到联系人 hs_005，只建交易不关联会丢分。

## 3050 · `simple.hs_update_contact_phone`（断言 1，负 0）

**中文业务请求**

把 HubSpot 联系人 hs_006（Emma Chen）的电话号码更新为 +1-555-5050。

**要点**：是「更新已有联系人」而非新建，联系人 ID hs_006 与电话号码不能混。

## 3048 · `simple.hs_update_contact_tag`（断言 1，负 0）

**中文业务请求**

更新 HubSpot 联系人 hs_004（Grace Kim），把 hs_tag 属性设置为 'enterprise'。

**要点**：改的是自定义属性 hs_tag（不是标签名或别的字段），取值必须是小写 'enterprise'。

## 3043 · `simple.hs_update_contact_title`（断言 1，负 0）

**中文业务请求**

把 HubSpot 联系人 hs_003（Diana Walsh）的职位更新为 'Chief Revenue Officer'。

**要点**：更新对象是 hs_003（Diana Walsh）的职位字段，头衔须原样写 'Chief Revenue Officer'。

## 3046 · `simple.hs_update_deal_amount`（断言 1，负 0）

**中文业务请求**

把 HubSpot 交易 deal_002（CloudBridge Expansion）的金额更新为 $38,000。

**要点**：改的是已有交易 deal_002 的金额字段，$38,000 不能写成别的数字。

## 3045 · `simple.hs_update_deal_stage`（断言 1，负 0）

**中文业务请求**

把 HubSpot 交易 deal_001（Pinnacle Tech Renewal）的阶段更新为 'Contract Sent'。

**要点**：更新的是 deal_001 的阶段，取值必须精确为 'Contract Sent'。

## 3192 · `simple.invoice_airtable_slack`（断言 2，负 0）

**中文业务请求**

收到一封发票邮件。读取该邮件，在 base_finance 的 'Invoices' 表中创建一条记录，写入供应商名称和发票金额，并通知 Slack 的 #finance 频道。

**要点**：两个断言对应三步——先读邮件取信息、再在 base_finance 的 'Invoices' 表建记录（供应商名 + 金额）、最后发 #finance 通知，漏掉通知就没拿到第二个断言。

## 3120 · `simple.jira_accessibility_audit`（断言 1，负 0）

**中文业务请求**

在 Jira 的 QA 项目中创建一个任务，摘要为 'Conduct accessibility audit for main dashboard'，问题类型为 Task。

**要点**：项目必须是 QA、摘要原样英文、问题类型为 Task，三者错一个就失败。

## 3111 · `simple.jira_auth_improvements`（断言 1，负 0）

**中文业务请求**

在 Jira 的 PROD 项目中创建一个任务，用于实现用户认证方面的改进。问题类型为 Task。

**要点**：项目是 PROD、问题类型是 Task，且不要自作主张补一个题面没有的摘要字段取值之外的改动。

## 3119 · `simple.jira_cicd_pipeline`（断言 1，负 0）

**中文业务请求**

在 Jira 的 DEVOPS 项目中创建一个任务，摘要为 'Update CI/CD pipeline for new deployment'，问题类型为 Task。

**要点**：项目是 DEVOPS（不是 PROD/QA），摘要里的 'CI/CD' 写法与问题类型 Task 都要对。

## 3114 · `simple.jira_dashboard_perf_bug`（断言 1，负 0）

**中文业务请求**

在 Jira 的 PROD 项目中创建一个高优先级的缺陷。摘要：'Dashboard loading time exceeds 5 seconds'。问题类型为 Bug。

**要点**：问题类型是 Bug 而非 Task，且要带上 High 优先级，摘要中的「5 seconds」不能改。

## 3118 · `simple.jira_data_sync_bug_from_email`（断言 1，负 0）

**中文业务请求**

在我的收件箱中查看一封客户关于数据同步问题的报告。然后在 Jira 的 PROD 项目中创建一个缺陷，摘要为 'Data sync fails for accounts with more than 1000 records'。问题类型为 Bug。

**要点**：这是两步题——先从收件箱找到客户的同步问题报告，再到 PROD 建 Bug；摘要里的 1000 条阈值必须原样保留。

## 3115 · `simple.jira_legacy_data_migration`（断言 1，负 0）

**中文业务请求**

在 Jira 的 INFRA 项目中创建一个任务，摘要为 'Migrate legacy data to new schema'，问题类型为 Task。

**要点**：项目是 INFRA、摘要原样英文、问题类型 Task，三项都要精确匹配。

## 3112 · `simple.jira_login_bug_from_email`（断言 1，负 0）

**中文业务请求**

到我的收件箱里找一封用户报告的、关于登录问题的 bug 邮件。然后在 PROD 项目中创建一个 Jira bug，summary 为 'Login fails with special characters in password'。Issue type 应为 Bug。

**要点**：须先从收件箱定位那封报障邮件，再在 PROD 项目建 Bug；项目键与 issue type 都不能换。

## 3117 · `simple.jira_mobile_redesign_epic`（断言 1，负 0）

**中文业务请求**

在 MOBILE 项目中创建一个 Jira Epic，summary 为 'Q2 Mobile App Redesign'。Issue type 应为 Epic。

**要点**：必须建 Epic 而非普通任务，summary 一字不改。

## 3116 · `simple.jira_rotate_api_keys`（断言 1，负 0）

**中文业务请求**

在 INFRA 项目中为安全团队创建一个 Jira 任务。Summary：'Rotate API keys for third-party integrations'。Issue type 应为 Task。

**要点**：项目是 INFRA、类型是 Task，summary 里的 'third-party integrations' 不能改写。

## 3113 · `simple.jira_search_filter_story`（断言 1，负 0）

**中文业务请求**

在 PROD 项目中创建一个 Jira Story，summary 为 'As a user, I want to filter search results by date'。Issue type 应为 Story。

**要点**：用户故事句式与 `As a user, I want to …` 原文必须保留，类型为 Story。

## 3175 · `simple.launch_announcement_email`（断言 2，负 0）

**中文业务请求**

我们的新产品 'CloudSync Pro' 今天发布。请在 #general Slack 频道发布一条发布公告，并给 team@company.example.com 的团队发一封邮件，主题为 'CloudSync Pro Launch'，内容包含发布的详细信息。

**要点**：两件事都要做——Slack #general 公告 + 邮件（收件地址和主题固定），只做一件会漏断言。

## 3081 · `simple.mailchimp_add_subscriber`（断言 1，负 0）

**中文业务请求**

把 alex.rivera@pixelworks.example.com 添加到 Mailchimp 的 Newsletter 邮件列表。Newsletter 列表 ID 是 list_001。

**要点**：必须加进 list_001 这个 Newsletter 列表，不能落到默认列表。

## 3084 · `simple.mailchimp_conference_lead`（断言 1，负 0）

**中文业务请求**

把一位会议线索添加到我们的 Newsletter Mailchimp 列表。详情：Name：Raj Kapoor，Email：raj.kapoor@quantumanalytics.example.com，Company：Quantum Analytics。给他们打上 'conference-2026' 标签。Newsletter 列表 ID 是 list_001。

**要点**：除姓名/邮箱/公司三字段外，还必须带上 'conference-2026' 标签。

## 3085 · `simple.mailchimp_dual_list`（断言 2，负 0）

**中文业务请求**

把订阅者 Emily Nakamura（emily.nakamura@solvex.example.com）同时添加到 Newsletter 和 Product Updates 两个 Mailchimp 列表。Newsletter 列表 ID 是 list_001，Product Updates 列表 ID 是 list_002。

**要点**：两个列表都要加（list_001 与 list_002），只加一个就丢一条断言。

## 3082 · `simple.mailchimp_email_request`（断言 1，负 0）

**中文业务请求**

有位客户发邮件要求加入我们的 newsletter。找到 Dana Okafor 发来的那封邮件，用她发信时使用的邮箱地址把她添加到 Mailchimp 的 Newsletter 列表。Newsletter 列表 ID 是 list_001。

**要点**：邮箱要用邮件里她本人发信地址，而不是自己造一个；列表固定 list_001。

## 3083 · `simple.mailchimp_full_contact`（断言 1，负 0）

**中文业务请求**

向 Product Updates 这个 Mailchimp 列表添加一位新订阅者，详情如下：First name：Jordan，Last name：Lee，Email：jordan.lee@canvasdesign.example.com。Product Updates 列表 ID 是 list_002。

**要点**：名和姓要分别写进 First name / Last name 字段，不能合并成一个名字。

## 3189 · `simple.milestone_sheets_slack`（断言 2，负 0）

**中文业务请求**

项目 'Atlas Redesign' 刚刚达成 Q1 里程碑。在 Google Sheet 'ss_milestones'（worksheet ID：sheet1）中新增一行，写入项目名 'Atlas Redesign'、里程碑 'Q1 Complete'、日期 '2026-02-23'。然后在 #project-updates Slack 频道发布一条更新。

**要点**：先写表（表名、worksheet ID、三列取值都要对）再发 Slack，两步缺一不可。

## 3199 · `simple.new_customer_sf_onboard_email`（断言 2，负 0）

**中文业务请求**

Horizon Media 刚刚签下合同！把 Salesforce 商机 'Horizon Media Deal'（ID：opp_601）的阶段更新为 'Closed Won'，并给他们主要联系人 kelly.brooks@horizonmedia.example.com 发一封入职欢迎邮件，欢迎他们成为客户。

**要点**：商机阶段必须精确设为 'Closed Won'，同时要发出欢迎邮件到指定联系人邮箱。

## 3167 · `simple.new_hire_asana_email`（断言 2，负 0）

**中文业务请求**

新团队成员 Priya Sharma 将于 2026 年 3 月 3 日入职。在 ws_hr 工作区创建一个 Asana 入职任务 'Onboard Priya Sharma'，并给 priya.sharma@company.example.com 发一封欢迎邮件。

**要点**：任务要建在 ws_hr 工作区且名称固定，邮件也要真的发出。

## 3172 · `simple.new_lead_sf_jira`（断言 2，负 0）

**中文业务请求**

一位名叫 Derek Huang、来自 BrightPath Solutions 的新线索刚刚进来。为 Derek 创建一条 Salesforce lead 记录（email：derek.huang@brightpath.example.com，company：BrightPath Solutions），并在 SALES 项目中创建一个 Jira 任务来跟进他们。

**要点**：Salesforce lead 与 Jira 任务都要建，Jira 项目键为 SALES。

## 3193 · `simple.partner_hubspot_asana`（断言 2，负 0）

**中文业务请求**

我们正在引入一家新合作伙伴：Zenith Analytics（联系人：Ravi Kapoor，ravi.kapoor@zenithanalytics.example.com）。为 Ravi 创建一条 HubSpot 联系人，并在 ws_partnerships 工作区创建一个 Asana 任务 'Onboard Zenith Analytics'。

**要点**：HubSpot 联系人 + Asana 任务两手都要做，工作区是 ws_partnerships。

## 3200 · `simple.partnership_hubspot_zoom`（断言 2，负 0）

**中文业务请求**

收到一封来自 QuantumLeap AI 的合作提案邮件。阅读这封邮件，创建一个名为 'QuantumLeap AI Partnership'、金额为 50000 的 HubSpot 商机，并为 2026 年 3 月 4 日下午 1:00 创建一场 30 分钟的 Zoom 会议 'Intro Call - QuantumLeap AI'。

**要点**：金额 50000、会议时间 2026-03-04 13:00 与时长 30 分钟都要准确，商机名与会议名固定。

## 3029 · `simple.sf_case_closed`（断言 1，负 0）

**中文业务请求**

把 Salesforce 工单 500003 的状态设置为 'Closed' 以关闭它。

**要点**：工单号是 500003，状态值必须正好是 'Closed'。

## 3027 · `simple.sf_case_in_progress`（断言 1，负 0）

**中文业务请求**

把 Salesforce 工单 500001 的状态更新为 'In Progress'。

**要点**：更新的是 500001，状态字符串 'In Progress' 不能写成 'InProgress'。

## 3028 · `simple.sf_case_priority_high`（断言 1，负 0）

**中文业务请求**

把 Salesforce 工单 500002 的优先级更新为 'High'。

**要点**：只改优先级字段，值为 'High'，别顺手改了状态。

## 3024 · `simple.sf_create_account_note`（断言 1，负 0）

**中文业务请求**

在账户 001001（Acme Corp）上创建一条 Salesforce note，标题为 'Q1 Meeting Summary'，正文为：'Discussed Q1 targets and expansion plans. Client interested in upgrading to enterprise tier.'。

**要点**：note 要挂在账户 001001 上，标题与正文原文照抄（含句末标点）。

## 3026 · `simple.sf_create_case`（断言 1，负 0）

**中文业务请求**

为账户 001002（BrightWave Inc）创建一个 Salesforce 工单。Subject：'Billing discrepancy on February invoice'。Priority：Medium。Status：New。

**要点**：三个字段都要设：Subject 原文、Priority=Medium、Status=New，并且关联到 001002。

## 3025 · `simple.sf_create_contact_note`（断言 1，负 0）

**中文业务请求**

在联系人 003003（Tyler Chen）上创建一条 Salesforce note，标题为 'Discovery Call Notes'，正文为：'Discussed pain points around data integration. Needs unified dashboard for team reporting.'。

**要点**：这条 note 挂在联系人（contact）而非账户上，正文须完整照抄。

## 3030 · `simple.sf_create_event`（断言 1，负 0）

**中文业务请求**

为联系人 003004（Lisa Park）创建一条 Salesforce 活动，表示一场已完成的会议。Subject：'Quarterly business review'。Start：2026-02-20T14:00:00Z，End：2026-02-20T15:00:00Z。

**要点**：起止时间用 Z（UTC）格式原样写入，关联联系人是 003004。

## 3021 · `simple.sf_create_followup_task`（断言 1，负 0）

**中文业务请求**

为与 Jordan Lee（联系人 003001）的后续电话创建一个 Salesforce 任务。Due date 设为 2026-02-28，subject 设为 'Follow-up call with Jordan Lee'。

**要点**：到期日是 2026-02-28，subject 必须与联系人姓名完全对应。

## 3036 · `simple.sf_create_lead_from_card`（断言 1，负 0）

**中文业务请求**

根据一张名片创建一条新的 Salesforce lead：Name：Yuki Tanaka，Company：Sakura Tech，Email：yuki.tanaka@sakuratech.example.com，Phone：+1-555-3636。

**要点**：四个字段全都要写入，电话带 '+1-555-' 前缀不能省。

## 3022 · `simple.sf_create_proposal_task`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中为 lead 00Q001 创建一条任务，主题为 'Send proposal to Elena Vasquez'。到期日应为 2026-03-05。

**要点**：任务必须挂在 lead 00Q001 上（不是 contact 或 opportunity），主题文字与到期日 2026-03-05 都要一字不差。

## 3034 · `simple.sf_lead_company_update`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q005（Mei Lin Zhang）上的公司名更新为 'Horizon Dynamics'（他们改名了）。

**要点**：只改公司名这一个字段、且要改到 lead 00Q005 上，'Horizon Dynamics' 的拼写与大小写不能动。

## 3038 · `simple.sf_lead_description_update`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q007（Ben Archer）上的 description 更新为：'Qualified via demo review. High urgency, looking to sign within 2 weeks.'

**要点**：description 是整段长文本，需原样写入（含句点、逗号与大小写），不能压缩成摘要或漏掉后半句。

## 3039 · `simple.sf_lead_employees_update`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q008（Fatima Al-Rashid）上的 number_of_employees 字段更新为 250。

**要点**：number_of_employees 是数字字段，要填整数 250，不要写成字符串 '250' 或 '250 employees'。

## 3035 · `simple.sf_lead_revenue_update`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q006（Carlos Mendez）上的 annual_revenue 字段更新为 5000000。

**要点**：annual_revenue 是数值字段，要写纯数字 5000000，不能写成带货币符号或千分位的字符串。

## 3033 · `simple.sf_lead_source_web`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q004（Rajesh Gupta）的 lead source 更新为 'Web'。

**要点**：来源取值要精确写成 'Web'，不能写成 'Website' 或 'Web Form'；改的对象是 00Q004。

## 3032 · `simple.sf_lead_status_qualified`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q003（Isabelle Moreau）的 status 更新为 'Qualified'。

**要点**：Status 要用标准阶段值 'Qualified'，不要写成 'qualified' 或 'Qualified Lead'；改的对象是 00Q003。

## 3031 · `simple.sf_lead_status_working`（断言 1，负 0）

**中文业务请求**

把 Salesforce lead 00Q002（James Okafor）的 status 更新为 'Working'。

**要点**：Status 必须取标准阶段值 'Working'（首字母大写），不要写成 'working' 或 'In Progress'。

## 3013 · `simple.sf_opp_amount_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006003（DataStream Analytics License）的 amount 更新为 $45,000。

**要点**：金额按数值写入（45000），别丢了千位或把带 $ 与逗号的展示串直接塞进数值字段。

## 3018 · `simple.sf_opp_campaign_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006008（Quantum Pay Gateway）的 campaign_id 设为 'camp_2026_spring'。

**要点**：campaign_id 要按原样写 'camp_2026_spring'（全小写、下划线分隔），不要改格式或加空格。

## 3014 · `simple.sf_opp_close_date_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006004（Apex Security Suite）的预计关单日推迟到 2026-03-31。

**要点**：CloseDate 要写成 2026-03-31 这一日期格式，且改的是 006004 而不是相邻机会。

## 3011 · `simple.sf_opp_closed_won`（断言 1，负 0）

**中文业务请求**

好消息——NexGen Platform Deal（opportunity 006001）刚刚成交！请在 Salesforce 中把它标记为 Closed Won。

**要点**：要落到 opportunity 006001 并把 StageName 置为 'Closed Won'；只写「已关单」或改错机会都不算。

## 3016 · `simple.sf_opp_description_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中给 opportunity 006006（Vantage AI Integration）加上如下 description：'Client requested custom ML model integration with existing data pipeline. Timeline: Q2 2026.'

**要点**：description 需整段原样写入，两句话与其中的「Q2 2026」都不能丢，改的是 006006。

## 3019 · `simple.sf_opp_next_step_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006009（Orion Fleet Management）的 next_step 字段更新为 'Schedule technical demo with engineering team'。

**要点**：next_step 是自由文本，整句 'Schedule technical demo with engineering team' 要一字不差，且落在 006009 上。

## 3015 · `simple.sf_opp_probability_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006005（Meridian ERP Rollout）的 probability 更新为 75%。

**要点**：probability 是百分比字段，取值 75%（按字段口径写数值 75），不要写成 0.75；改的对象是 006005。

## 3012 · `simple.sf_opp_stage_proposal`（断言 1，负 0）

**中文业务请求**

把 Salesforce 中 opportunity 006002（CloudBridge Migration）的阶段更新为 'Proposal/Price Quote'。

**要点**：阶段名必须精确写成 'Proposal/Price Quote'，斜杠两侧不要加空格，也不能简写成 'Proposal'。

## 3017 · `simple.sf_opp_stage_value_prop`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006007（TerraForm Cloud Hosting）从 'Needs Analysis' 推进到 'Value Proposition'。

**要点**：阶段只能从 'Needs Analysis' 走到 'Value Proposition'，起点与终点都是断言对象，别一步跳到 Proposal。

## 3020 · `simple.sf_opp_type_update`（断言 1，负 0）

**中文业务请求**

在 Salesforce 中把 opportunity 006010（Helios Solar Dashboard）的 type 字段更新为 'New Business'。

**要点**：Type 取标准值 'New Business'（两个单词、首字母大写），不要写成 'New' 或 'NewBusiness'。

## 3086 · `simple.sheets_add_lead`（断言 1，负 0）

**中文业务请求**

往我们的 Sales Leads Google Sheet 里新增一条潜在客户记录。姓名：Carla Mendes，公司：Horizon Biotech，邮箱：carla.mendes@horizonbiotech.example.com，电话：555-0142，来源：LinkedIn，状态：New。请把这一行加到 spreadsheet ss_leads、worksheet ws_leads 中。

**要点**：六个字段要一次写全，邮箱拼写和电话 555-0142 都不能改；目标是 ss_leads 的 ws_leads 表。

## 3099 · `simple.sheets_add_vendor`（断言 1，负 0）

**中文业务请求**

往 Vendor List Google Sheet 里新增一个供应商。供应商：CloudForge Solutions，联系人：Dmitri Volkov，邮箱：dmitri.volkov@cloudforge.example.com，服务：Cloud Infrastructure，合同起始日：March 1, 2026，年费：$48,000。请把这一行加到 spreadsheet ss_vendors、worksheet ws_vendors 中。

**要点**：年费 $48,000 与合同起始日 March 1, 2026 要按原文填，联系人邮箱拼写不能错，目标是 ss_vendors 的 ws_vendors。

## 3093 · `simple.sheets_budget_expense`（断言 1，负 0）

**中文业务请求**

往 Budget Tracker Google Sheet 里新增一笔支出。类别：Software，说明：Annual Figma license renewal，金额：$1,200，日期：February 23, 2026，审批人：Lisa Tran。请把这一行加到 spreadsheet ss_budget、worksheet ws_expenses 中。

**要点**：金额 $1,200 与审批人 Lisa Tran 要原样保留，说明文字不能改写；目标是 ss_budget 的 ws_expenses。

## 3090 · `simple.sheets_closed_deal`（断言 1，负 0）

**中文业务请求**

把一笔已成交的生意登记到 Closed Deals Google Sheet。客户：Pinnacle Healthcare，成交金额：$185,000，关单日期：February 23, 2026，销售代表：Sarah Jones，合同期限：2 years，套餐：Enterprise。请把这一行加到 spreadsheet ss_deals、worksheet ws_deals 中。

**要点**：金额 $185,000、关单日期与「2 years」的合同期限要按原文填入，六个字段一个都不能省。

## 3100 · `simple.sheets_content_calendar`（断言 1，负 0）

**中文业务请求**

往 Content Calendar Google Sheet 里为下周的博客文章新增一条记录。标题：10 Ways AI Is Transforming Customer Onboarding，作者：Olivia Park，发布日期：March 2, 2026，状态：Draft，类别：AI & Automation。请把这一行加到 spreadsheet ss_content、worksheet ws_calendar 中。

**要点**：标题是完整英文长句，不能改写或截断；类别 'AI & Automation' 中的 & 要保留，状态是 Draft。

## 3087 · `simple.sheets_log_email_inquiry`（断言 1，负 0）

**中文业务请求**

我们收到了一封客户咨询邮件。请找到 Kwame Asante 发来的那封邮件，并把详情作为新的一行记录到 Contact Log Google Sheet 中。要包含发件人姓名、邮箱地址、主题和日期。请把这一行加到 spreadsheet ss_contacts、worksheet ws_log 中。

**要点**：先在 Gmail 里定位 Kwame Asante 的那封咨询邮件，再把发件人姓名、邮箱、主题、日期四项全部写进 ss_contacts 的 ws_log——先查后写，四项缺一不可。

## 3097 · `simple.sheets_log_sales_call`（断言 1，负 0）

**中文业务请求**

把一通已完成的销售电话记录到 Activity Log Google Sheet。日期：February 23, 2026，类型：Discovery Call，联系人：Redwood Analytics 的 Vanessa Brooks，备注：Discussed data pipeline needs; interested in Enterprise plan; follow-up demo scheduled for March 1st.，结果：Positive。请把这一行加到 spreadsheet ss_activity、worksheet ws_log 中。

**要点**：备注是三段分号分隔的长文本（含 March 1st 的跟进安排），要整段写入，别只留第一句。

## 3095 · `simple.sheets_log_support_email`（断言 2，负 0）

**中文业务请求**

我们收到了一封支持请求邮件。找到 Ingrid Svensson 发来的那封邮件，并把它记录到 Support Log 这个 Google Sheet 中。要包含客户姓名、邮箱、主题、日期，并把 Priority 设为 'Medium'。把这一行加到 spreadsheet ss_support 的 worksheet ws_tickets 中。

**要点**：五个字段（姓名/邮箱/主题/日期）都要从邮件正文里取全，且 Priority 必须正好是 'Medium'，写入位置只能是 ss_support 的 ws_tickets。

## 3089 · `simple.sheets_project_tracker`（断言 1，负 0）

**中文业务请求**

向 Project Tracker 这个 Google Sheet 添加一行新记录，内容如下：Task：Implement SSO integration，Owner：Mike Chen，Due Date：March 14, 2026，Status：In Progress。把这一行加到 spreadsheet ss_projects 的 worksheet ws_tasks 中。

**要点**：四个字段值要原样写入，日期写成 March 14, 2026，Status 是 'In Progress' 而不是 'Completed'。

## 3091 · `simple.sheets_read_then_email`（断言 1，负 0）

**中文业务请求**

在 Outreach Tracker 这个 Google Sheet 中查找第一条 Status 为 'Pending' 的联系人。给他们发一封介绍 BrightPath 自动化平台的邮件。使用表格里的 Name 和 Email。主题：'Introducing BrightPath - Workflow Automation'。使用 spreadsheet ss_outreach、worksheet ws_pending。

**要点**：要先读表找到第一条 Pending 的联系人，再按表里的姓名/邮箱发信，主题一字不差，不能自己编收件人。

## 3092 · `simple.sheets_read_then_slack_dm`（断言 1，负 0）

**中文业务请求**

在 Client Assignments 这个 Google Sheet 中查找客户 'Orion Enterprises'。在表里找到分配给该客户的客户经理，然后在 Slack 中查到这个人的账号，给他发一条 DM，告知 Orion Enterprises 本周要求开一次合同评审会议。使用 spreadsheet ss_assignments、worksheet ws_clients。

**要点**：先查表定人、再按人名去 Slack 找人，DM 必须发给这位客户经理本人，且内容要点是「Orion Enterprises 本周要求合同评审会议」。

## 3098 · `simple.sheets_update_from_email`（断言 1，负 0）

**中文业务请求**

我收到了一封项目状态更新邮件。找到 Mike Chen 发来的那封邮件，用其中的信息去更新 Project Status 这个 Google Sheet 里对应的项目行。根据邮件内容更新 Status 以及其它相关字段。使用 spreadsheet ss_project_status、worksheet ws_projects。

**要点**：要先把邮件里的状态与字段读出来，再更新到匹配的项目行，不能新增行、也不能只改 Status 而漏掉邮件里提到的其它字段。

## 3088 · `simple.sheets_update_status`（断言 1，负 0）

**中文业务请求**

在 Sales Leads 这个 Google Sheet 中，找到 Marcus Webb 对应的那一行，把他的 Status 从 'Contacted' 改为 'Qualified'。使用 spreadsheet ss_leads、worksheet ws_leads。

**要点**：只改 Marcus Webb 这一行的 Status，且要改成 'Qualified' 而不是 'Contacted' 或 'Qualified Lead' 之类的变体。

## 3094 · `simple.sheets_update_status_report`（断言 2，负 0）

**中文业务请求**

在 Status Report 这个 Google Sheet 中，做以下更新：1）找到 'API Gateway Upgrade' 那一行，把 Status 改为 'Completed'。2）找到 'Mobile App Redesign' 那一行，把 Status 改为 'In Progress'。使用 spreadsheet ss_status、worksheet ws_report。

**要点**：两行两处状态要分别改成 Completed 与 In Progress，不能把两行的状态写反或只改其中一行。

## 3096 · `simple.sheets_webinar_registration`（断言 1，负 0）

**中文业务请求**

向 Attendees 这个 Google Sheet 添加一条新的网络研讨会报名记录。Name：Tariq Hassan，Email：tariq.hassan@vanguardsystems.example.com，Company：Vanguard Systems，Webinar：Scaling with AI，Date：March 12, 2026。把这一行加到 spreadsheet ss_webinar 的 worksheet ws_attendees 中。

**要点**：五个字段值（含邮箱与公司名）要逐字写入，Webinar 名称是 'Scaling with AI'，日期写成 March 12, 2026。

## 3073 · `simple.slack_ceo_announcement`（断言 1，负 0）

**中文业务请求**

我收到了 CEO 发来的一封公司公告邮件。找到 Nathan Drake 发来的那封邮件，把公告的摘要发到 #all-hands 这个 Slack 频道。

**要点**：要找对 CEO 那封邮件、把摘要发到 #all-hands 频道；漏掉频道或发到别的频道都不算完成。

## 3077 · `simple.slack_customer_escalation`（断言 1，负 0）

**中文业务请求**

我们收到了一封客户紧急升级（escalation）邮件。找到 Veronica Steele 发来的那封邮件，把问题概述作为一条告警发到 #support 这个 Slack 频道。

**要点**：核心是把邮件里的问题整理成告警发到 #support，不能只贴一句「有问题」而丢掉邮件中的关键信息。

## 3078 · `simple.slack_deployment_notice`（断言 1，负 0）

**中文业务请求**

在 #engineering 这个 Slack 频道发消息：我们今晚 10 PM EST 有一次已排期的部署。本次部署包含新的 webhook 系统（v2.4.0）以及 dashboard 性能修复。预计停机时间约 15 分钟。

**要点**：时间（今晚 10 PM EST）、版本号 v2.4.0、停机约 15 分钟这三个关键信息都要保留，且只能发到 #engineering。

## 3074 · `simple.slack_dm_meeting_reminder`（断言 1，负 0）

**中文业务请求**

给 Sarah Jones 发一条 Slack DM，提醒她明天下午 2 点与 Globex Financial 的客户会议。告诉她需要带上更新后的提案 deck 和 Q4 metrics report。

**要点**：DM 发给 Sarah Jones 本人，会议时间（明天 2 PM）、客户名 Globex Financial、要带的两份材料都不能漏。

## 3079 · `simple.slack_dm_project_status`（断言 1，负 0）

**中文业务请求**

给我的经理 Lisa Tran 发一条 Slack DM，汇报项目状态。告诉她：CRM 迁移已完成 90%，我们能赶上 3 月 5 日的截止日期，目前唯一剩下的风险是数据校验这一步，我们本周正在测试。

**要点**：三个数字/状态要点（90%、March 5th 截止、唯一风险是数据校验且本周在测）要齐全，收件人是经理 Lisa Tran。

## 3075 · `simple.slack_dm_task_assignment`（断言 1，负 0）

**中文业务请求**

给 Mike Chen 发一条 Slack DM，把「审阅新 webhook 端点的 API 文档」这项任务分配给他。截止时间是本周五，文档在共享 Google Drive 的 'API Docs v3' 文件夹里。

**要点**：任务是审阅新 webhook 端点的 API 文档，截止本周五，并要点明文件夹 'API Docs v3'，三者缺一不可。

## 3071 · `simple.slack_marketing_campaign`（断言 1，负 0）

**中文业务请求**

在 #marketing 这个 Slack 频道发一条消息，宣布我们的新活动 'Spring Forward' 上线。说明该活动时间为 3 月 1 日至 31 日，目标客群是 mid-market SaaS 公司，渠道包括 email、social 和 paid ads。

**要点**：活动名 'Spring Forward'、时间 3 月 1-31 日、目标客群 mid-market SaaS、三个渠道（email/social/paid ads）都要提到。

## 3072 · `simple.slack_office_closure`（断言 1，负 0）

**中文业务请求**

在 #general 这个 Slack 频道发消息：办公室本周五（2 月 27 日）因设施维护日关闭。所有员工应居家办公。大楼周一恢复正常开放。

**要点**：关闭日期是本周五 2 月 27 日、原因是设施维护、全员居家办公、周一恢复，四个要素都要写全。

## 3076 · `simple.slack_sales_closed_deal`（断言 1，负 0）

**中文业务请求**

在 #sales 这个 Slack 频道发消息庆祝我们刚刚签下 Pinnacle Healthcare 的单子，金额为 $185,000 ARR。这单由 Sarah Jones 主导，是 Enterprise 套餐的 2 年合同。

**要点**：金额 $185,000 ARR、客户 Pinnacle Healthcare、主导人 Sarah Jones、Enterprise 套餐 2 年合同，数字与专有名词不能含糊。

## 3080 · `simple.slack_weekly_metrics`（断言 1，负 0）

**中文业务请求**

把每周指标摘要发到 #metrics 这个 Slack 频道。本周数字：New signups：342，Trial conversions：28，MRR：$1.24M（上涨 3.2%），Churn rate：1.8%，Support tickets resolved：156。

**要点**：六个指标及其数值（342、28、$1.24M/3.2%、1.8%、156）要逐项对应，不能漏项或错配。

## 3197 · `simple.sprint_retro_jira_slack`（断言 2，负 0）

**中文业务请求**

Sprint 14 刚刚结束。在 ENG 项目中创建一个 Jira issue，标题为 'Sprint 14 Retrospective'，类型为 task，并在 #engineering 这个 Slack 频道发消息请团队成员补充各自的回顾笔记。

**要点**：Jira issue 的标题、类型（task）与项目（ENG）三项都要对，同时在 #engineering 频道发出邀请，两件事缺一不可。

## 3188 · `simple.subscriber_welcome_email`（断言 2，负 0）

**中文业务请求**

收到了一封新订阅者通知邮件。读取这封邮件，为该订阅者在 HubSpot 中创建一个 contact，并给他发一封欢迎邮件。

**要点**：订阅者信息要从通知邮件里取，先建 HubSpot contact 再发欢迎邮件，两步都要落到同一个人身上。

## 3127 · `simple.trello_case_study_draft`（断言 1，负 0）

**中文业务请求**

在 Marketing 看板（brd_mktg）的 To Do 列表中创建一张名为 'Draft customer case study - Acme Corp' 的 Trello 卡片。先列出该看板的 lists，找到 To Do 列表的 ID。

**要点**：必须先查 lists 拿到 To Do 列表 ID 再建卡，卡片名与看板（brd_mktg）都要对，不能建到别的列表。

## 3123 · `simple.trello_catering_contract`（断言 1，负 0）

**中文业务请求**

在 Events 看板（brd_events）的 To Do 列表中创建一张名为 'Finalize event catering contract' 的 Trello 卡片，到期日为 2026 年 3 月 5 日。先列出该看板的 lists，找到 To Do 列表的 ID。

**要点**：卡片名、到期日 2026-03-05、以及先查 lists 拿到 To Do 列表 ID 这三项都要满足。

## 3124 · `simple.trello_competitor_pricing`（断言 1，负 0）

**中文业务请求**

在 Sales 看板（brd_sales）的 Backlog 列表中创建一张名为 'Research competitor pricing' 的 Trello 卡片。先列出该看板的 lists，找到 Backlog 列表的 ID。

**要点**：目标是 Backlog 列而不是 To Do，需先查 lists 定位 Backlog 的 ID，卡片名不能改。

## 3129 · `simple.trello_employee_handbook`（断言 1，负 0）

**中文业务请求**

在 HR 看板（brd_hr）的 To Do 列表中创建一张名为 'Update employee handbook Q1 section' 的 Trello 卡片。先列出该看板的 lists，找到 To Do 列表的 ID。

**要点**：卡片名里的 Q1 不能丢，看板是 HR（brd_hr），且要先查 lists 再按 To Do 列表 ID 建卡。

## 3130 · `simple.trello_event_planning_checklist`（断言 1，负 0）

**中文业务请求**

在 Events 看板（brd_events）的 To Do 列表中创建一张名为 'Plan annual company picnic' 的 Trello 卡片。在描述里加入一份清单：book venue、arrange catering、send invitations、organize activities。先列出该看板的 lists，找到 To Do 列表的 ID。

**要点**：清单四项（book venue / arrange catering / send invitations / organize activities）要完整写进卡片描述，且先查 lists 拿到 To Do 列表 ID。

## 3128 · `simple.trello_manager_feedback_from_email`（断言 1，负 0）

**中文业务请求**

到我的收件箱里找一封来自我经理的反馈邮件。然后在 Marketing 看板（brd_mktg）的 To Do 列表中创建一张 Trello 卡片，概括该邮件里的行动项。卡片命名为 'Action items from manager feedback'。

**要点**：必须先从邮件里读出行动项再建卡，卡片要落在 brd_mktg 的 To Do 列表上，名称一字不差。

## 3125 · `simple.trello_move_card_to_inprog`（断言 1，负 0）

**中文业务请求**

把 Trello 卡片 card_101 从它当前所在的列表移动到 Product 看板（brd_prod）的 In Progress 列表。先列出该看板的各个列表，找到 In Progress 列表的 ID。

**要点**：要先查列表拿到 In Progress 列表 ID 再做移动，移动的目标看板必须是 brd_prod。

## 3122 · `simple.trello_onboard_agency_from_email`（断言 1，负 0）

**中文业务请求**

到我的收件箱里找一封关于接入新代理合作伙伴的邮件。然后在 Marketing 看板（brd_mktg）的 To Do 列表中创建一张名为 'Onboard new agency partner' 的 Trello 卡片。

**要点**：卡片要先读那封邮件确认主题，落点是 brd_mktg 的 To Do 列表，标题固定不变。

## 3121 · `simple.trello_q1_marketing_budget`（断言 1，负 0）

**中文业务请求**

在 Marketing 看板（brd_mktg）的 To Do 列表中创建一张名为 'Review Q1 marketing budget' 的 Trello 卡片。先列出该看板的各个列表，找到 To Do 列表的 ID。

**要点**：To Do 列表 ID 必须靠先查询获得而不是猜，卡片名与所在看板都要精确。

## 3126 · `simple.trello_urgent_support_card`（断言 1，负 0）

**中文业务请求**

在 Support 看板（brd_support）的 To Do 列表中创建一张名为 'Investigate payment gateway timeout' 的 Trello 卡片。然后给该卡片加上 'urgent' 标签（label_urgent）。先列出该看板的各个列表，找到 To Do 列表的 ID。

**要点**：建卡与打标签是两步，标签值要用 label_urgent，且先查出 To Do 列表 ID 再建卡。

## 3191 · `simple.weekly_digest_sheets_email`（断言 2，负 0）

**中文业务请求**

读取 Google Sheet 'ss_digest'（worksheet ID：sheet1）中的联系人列表，并给每位联系人发送一封每周摘要邮件。该表格包含联系人姓名和邮箱。给每个人发一封主题为 'Weekly Digest - Feb 23' 的邮件，正文是本周亮点的简要总结。

**要点**：收件人要从 sheet1 逐行取姓名与邮箱配对，每位联系人都要单独发到，主题固定为 'Weekly Digest - Feb 23'。

## 3170 · `simple.weekly_report_sheets_email`（断言 2，负 0）

**中文业务请求**

向 Google Sheet 'ss_reports'（worksheet ID：sheet1）添加一行，内容为本周摘要：'Week of Feb 23 - 12 deals closed, $340K revenue'。然后把这份周报通过邮件发送给 manager@company.example.com。

**要点**：追加的是含日期、成交数与金额的整段摘要文本（$340K 原样保留），发信对象是 manager@company.example.com。

## 3151 · `simple.zendesk_billing_ticket`（断言 1，负 0）

**中文业务请求**

收到一封关于发票问题的客户邮件。请阅读该邮件，并据此创建一张 Zendesk 支持工单。

**要点**：工单内容要从那封邮件里提取，不能凭空编造，且只建一张工单。

## 3154 · `simple.zendesk_feature_request`（断言 1，负 0）

**中文业务请求**

为一条功能请求创建 Zendesk 工单：'Add dark mode to dashboard'。把优先级设为 low，状态设为 open。

**要点**：主题是要一字不差的原话，priority=low 与 status=open 两个字段都要显式设置。

## 3152 · `simple.zendesk_login_ticket`（断言 1，负 0）

**中文业务请求**

创建一张主题为 'Login page not loading' 的 Zendesk 支持工单，并将其设为高优先级。把工单分配给 Support Team 组（ID：grp_support）。

**要点**：高优先级和分组 grp_support 都要设到，主题文字不能改动。

## 3171 · `simple.zendesk_resolve_email`（断言 2，负 0）

**中文业务请求**

关于密码重置问题的支持工单 ZD-501 已经解决。把该 Zendesk 工单的状态更新为 'solved'，并向客户 elena.voss@retail.example.com 发送一封解决通知邮件。

**要点**：状态要改成 'solved'（不是 closed 或 pending），同时必须真的给该客户邮箱发一封解决通知。

## 3155 · `simple.zendesk_urgent_reply`（断言 2，负 0）

**中文业务请求**

刚收到一封关于服务中断的紧急支持邮件。阅读该邮件，创建一张高优先级 Zendesk 工单，并回复客户确认我们已收到该问题。

**要点**：三步缺一不可：读邮件 → 建高优先级工单 → 回信向客户确认；只建工单不回复会挂。

## 3153 · `simple.zendesk_wrong_order_ticket`（断言 1，负 0）

**中文业务请求**

一位客户发邮件说收到了错误的订单。阅读该邮件，并创建一张带 'billing' 标签的 Zendesk 工单。

**要点**：工单必须打上 billing 标签（不能换成别的标签），内容取自客户邮件。

## 3143 · `simple.zoom_ai_webinar`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Intro to AI Tools' 的 Zoom 会议（webinar 形式），时间为 2026 年 3 月 15 日下午 1:00 EST，时长 90 分钟。主持人邮箱用 agent@company.example.com。

**要点**：webinar 类型、90 分钟时长、3 月 15 日 1:00 PM EST 三个属性都要落到会议设置里。

## 3146 · `simple.zoom_board_meeting_password`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Board of Directors Meeting' 的 Zoom 会议，时间为 2026 年 3 月 20 日上午 10:00 EST，时长 2 小时。务必为这场会议设置密码。主持人邮箱用 agent@company.example.com。

**要点**：会议密码必须真的设置上，日期时间与 2 小时时长同样要准。

## 3186 · `simple.zoom_calendar_sync`（断言 2，负 0）

**中文业务请求**

创建一场名为 'Onboarding Call with Helix Corp' 的 Zoom 会议，时间为 2026 年 3 月 2 日上午 9:00（时长 45 分钟），同时创建一个对应的 Google Calendar 日程。主持人邮箱用 agent@company.example.com。

**要点**：Zoom 会议与日历事件两边都要建，且标题、开始时间、45 分钟时长要一一对应。

## 3144 · `simple.zoom_client_call_from_email`（断言 1，负 0）

**中文业务请求**

到我的收件箱里找一封客户希望预约通话的邮件。然后按客户要求的时间和主题创建一场 Zoom 会议。主持人邮箱用 agent@company.example.com。

**要点**：会议时间和主题必须取自客户邮件，不能自行假设，主持人邮箱固定为 agent@company.example.com。

## 3142 · `simple.zoom_client_demo`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Client Demo - NexGen Platform' 的 Zoom 会议，时间为 2026 年 2 月 27 日下午 2:00 EST，时长 1 小时。主持人邮箱用 agent@company.example.com。

**要点**：标题里的连字符与平台名要原样保留，2 月 27 日 2:00 PM EST 与 1 小时时长都要对。

## 3150 · `simple.zoom_customer_training`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Customer Training Session' 的 Zoom 会议，时间为 2026 年 3 月 12 日上午 10:00 EST，时长 2 小时。为这场会议开启报名（registration）。主持人邮箱用 agent@company.example.com。

**要点**：除时间与时长外，还必须显式开启 registration，漏了这个开关就不算完成。

## 3145 · `simple.zoom_daily_standup`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Daily Standup' 的周期性 Zoom 会议，安排在工作日（周一至周五）上午 9:30 EST，从 2026 年 3 月 2 日开始。主持人邮箱用 agent@company.example.com。

**要点**：要设成按周一到周五重复的周期会议而不是单次会议，开始日期为 2026-03-02、时间 9:30 AM EST。

## 3141 · `simple.zoom_engineering_sync`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Weekly Engineering Sync' 的 Zoom 会议，时间为 2026 年 3 月 2 日（周一）上午 10:00 EST。主持人邮箱用 agent@company.example.com。

**要点**：题目没给时长，考点是日期、10:00 AM EST 与标题 'Weekly Engineering Sync' 的精确匹配。

## 3168 · `simple.zoom_meeting_email_invite`（断言 2，负 0）

**中文业务请求**

安排一场名为 'Quarterly Review with Orion Corp' 的 Zoom 会议，时间为 2026 年 2 月 27 日上午 10:00（时长 60 分钟），并把会议详情通过邮件发送给 marco.reeves@orioncorp.example.com。主持人邮箱用 agent@company.example.com。

**要点**：除了建会，还要单独给 marco.reeves@orioncorp.example.com 发一封含会议详情的邀请邮件，两件事都要做。

## 3149 · `simple.zoom_sales_pipeline_review`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Sales Pipeline Review' 的 Zoom 会议，时间为 2026 年 2 月 26 日（周四）下午 3:00 EST，时长 45 分钟。主持人邮箱用 agent@company.example.com。

**要点**：45 分钟时长与 2 月 26 日 3:00 PM EST 要精确，别被默认的 60 分钟覆盖。

## 3148 · `simple.zoom_team_retro`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Team Retrospective' 的 Zoom 会议，时间为 2026 年 2 月 27 日（周五）下午 4:00 EST，时长 1 小时。主持人邮箱用 agent@company.example.com。

**要点**：时间是周五 2 月 27 日 4:00 PM EST，标题 'Team Retrospective' 拼写不能简写或改动。

## 3147 · `simple.zoom_vendor_onboarding_with_slack`（断言 1，负 0）

**中文业务请求**

创建一场名为 'Vendor Onboarding Call' 的 Zoom 会议，时间为 2026 年 3 月 10 日上午 11:00 EST，时长 1 小时。然后向 #vendor-mgmt Slack 频道发送一条含会议详情的消息。主持人邮箱用 agent@company.example.com。

**要点**：除了建会，还要把会议详情（时间、链接等）发到 #vendor-mgmt 频道，两件事都要落地。
