# Gumtree API 自动化测试项目说明

_版本：1.0 更新日期：2024-06-25_

## 1 项目背景

Gumtree 移动端大量依赖后端 REST/GraphQL 接口。为了在发布流程中及早发现回归缺陷、保障核心业务（登录、发帖、聊天、VIP 服务等）稳定性，团队基于 **Apache JMeter** 建立了一套接口自动化测试工程，并接入 CI/CD 流水线。

## 2 目标与范围

1. 覆盖所有关键业务接口的正向、逆向与边界路径。
2. 保证每日构建的接口通过率 ≥ 98 %。
3. 在 30 分钟内完成完整回归并生成可读报表。
4. 支持一键本地执行，支撑开发/测试自助验证。

> 当前仓库仅聚焦 **接口层**；UI 自动化另建专用项目。

## 3 技术栈与工具

| 类别          | 选型                                          | 说明                                 |
| ------------- | --------------------------------------------- | ------------------------------------ |
| 测试框架      | Apache JMeter 5.6.3                           | 使用 `.jmx` 场景文件编排线程组     |
| 依赖管理      | `lib/` 目录 + `scripts/install_jmeter.sh` | 拉取第三方插件（JSON Path、JDBC 等） |
| 执行脚本      | Bash (`scripts/run_all.sh`)                 | 支持本地/CI 一键执行                 |
| 报告          | JMeter HTML Report                            | 本地生成 `reports/all_cases_report`；CI 作为 Artifact 下载 |
| 解析/二次处理 | Python (可选)                                 | 统计指标或同步至测试平台             |
| 持续集成      | GitHub Actions (Fork Workflow)                | Fork 后自动在个人仓库执行 CI |

## 4 目录结构

```text
jmeter-api-project/
├─ config/                 # 环境变量; appbff.env.properties, webbff.env.properties 等
├─ data/                   # 测试数据，如 auth_tokens.csv
├─ lib/                    # JMeter 依赖 Jar/插件
├─ scripts/                # 安装&执行脚本
│  ├─ install_jmeter.sh
│  └─ run_all.sh
├─ testcases/              # *.jmx 场景文件 (见 5.1)
├─ reports/                # 最近一次执行生成的 HTML 报告
├─ README.md               # 快速上手文档
└─ CHANGELOG.md            # 版本历史
```

## 5 测试用例设计

### 5.1 用例总览

| Thread Group ID                       | 功能模块 | 覆盖接口/场景     | 备注             |
| ------------------------------------- | -------- | ----------------- | ---------------- |
| tg1_auth_login.jmx                    | 认证     | 登录（成功/失败） | 调 token 池      |
| tg2_registration_register.jmx         | 账户     | 新用户注册        | 邮箱/手机两种    |
| tg3_auth_logout.jmx                   | 认证     | 用户退出登录      | —               |
| tg4_account_activation.jmx            | 账户     | 激活邮件链接      | —               |
| tg5_password_reset.jmx                | 账户     | 重置密码流程      | 包括验证码校验   |
| tg6_forgot_password.jmx               | 账户     | 忘记密码          | —               |
| tg7_ad_posted_analytics.jmx           | 广告     | 发帖后埋点        | —               |
| tg8_post_ad.jmx                       | 广告     | 发布广告          | 图片上传、多分类 |
| tg9_delete_ad.jmx                     | 广告     | 删除广告          | 权限校验         |
| tg10_promote_ad_screen.jmx            | 广告     | 置顶/加急         | —               |
| tg11_user_block.jmx                   | 用户     | 拉黑/取消拉黑     | —               |
| tg12_vip_screen.jmx                   | VIP      | VIP 广告展示      | —               |
| tg13_mygumtree_screen.jmx             | 个人中心 | 数据加载          | —               |
| tg14_favourites.jmx                   | 收藏     | 添加/取消收藏     | —               |
| tg15_favourites_screen.jmx            | 收藏     | 列表展示          | —               |
| tg16_chat_screen.jmx                  | 聊天     | 聊天窗口加载      | —               |
| tg17_conversation_screen.jmx          | 聊天     | 会话列表          | —               |
| tg18_conversation_unread_messages.jmx | 聊天     | 未读数量          | —               |
| tg19_conversation.jmx                 | 聊天     | 发送/接收消息     | —               |
| tg20_reviews_conversation.jmx         | 聊天     | 会话评价          | —               |
| tg21_vip_phone.jmx                    | VIP      | 查看卖家电话      | 计费验证         |
| tg22_vip_reply.jmx                    | VIP      | VIP 回复          | SLA 校验         |

### 5.2 参数化与数据驱动

• **账号/Token**：`data/auth_tokens.csv` 按环境隔离。
• **动态变量**：UUID、时间戳等在 JMeter 里使用函数助手生成。
• **随机内容**：广告标题、描述等通过 JS 脚本生成，减轻后端缓存影响。

## 6 执行方式

### 6.1 本地快速执行

```bash
# 安装依赖（首次）
./scripts/install_jmeter.sh

# 运行全部用例（默认 dev 环境）
./scripts/run_all.sh dev
```

参数说明：
*第 1 个参数* = 环境名（dev / test / staging / prod），脚本内部会 `source config/${env}.env.properties`。

### 6.2 CI/CD 流水线

1. Checkout → 安装依赖。
2. `run_all.sh $ENV` —— 生成 `reports/all_cases_report/`。
3. 失败用例 > 0 则 Workflow 标红；报告目录被打包为 **Actions Artifact** 供下载。

### 6.2 CI/CD 流水线（GitHub Actions）

1. 在公司 GitHub 组织找到 `gumtree/jmeter-api-project` 仓库，点击 **Fork** 到自己的账号（如 `yourname/jmeter-api-project`）。  
2. 在个人仓库的 **Settings → Secrets and variables → Actions** 中配置必要密钥（如 `JMETER_PLUGINS_MIRROR`、内部 Token 等）。  
3. 每次向 `1.0`/`main` 分支 push 或创建 Pull Request 时，`.github/workflows/ci.yml` 会自动触发并执行：  
   1. Checkout 代码  
   2. 缓存并安装 JMeter 及插件  
   3. 运行 `scripts/run_all.sh test`  
   4. 将 `reports/all_cases_report` 上传为 Actions Artifact  
   5. 统计失败用例并把结果注释到 PR，若存在失败则 Workflow 标红  
4. 也可在 **Actions → Run workflow** 手动触发，选择目标环境后执行。

## 7 测试指标与报告

• **吞吐量 (TPS)**、**90/95 延迟**、错误率等核心指标可在 `reports/` HTML 里查看。
• 每个 Thread Group 都配置了 `Backend Listener` 输出 InfluxDB，可在 Grafana Dashboard 对比历史趋势。

## 8 维护与贡献

1. **新增接口**：复制现有 .jmx，保留取样器结构，补充请求 URL/断言即可。
2. **PR 规范**：请关联 JIRA 或 Issue，附带本地运行截图。
3. **版本升级**：重大变更记录在 CHANGELOG.md；tag 发布后触发 Release 流水线。

## 9 附录

### 9.1 常用命令

```bash
# 只跑登录相关用例
jmeter -n -t testcases/tg1_auth_login.jmx -l reports/login.jtl \
       -q config/appbff.env.properties -j jmeter.log

# 把 HTML 报告打包上传
tar -czf reports_$(date +%Y%m%d%H%M).tgz reports/html
```

### 9.2 参考链接

• Apache JMeter 官方文档
• Gumtree Open API 指南
• Grafana Dashboard 模板 #12345
