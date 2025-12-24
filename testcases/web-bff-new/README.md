# Gumtree Web BFF 新增接口测试用例

**创建日期**: 2024年12月9日  
**用例总数**: 44个新用例 (tg15-tg58)

---

## 📊 用例覆盖统计

结合原有 `web-bff` 目录的17个用例，共覆盖 **56+3 = 59个接口**。

| 分类 | 接口数量 | 原有用例 | 新增用例 |
|------|----------|----------|----------|
| 广告相关 (Ads) | 2 | 0 | tg15, tg16 |
| 消息中心 (Message Centre) | 9 | 5 | tg17, tg18, tg19, tg20 |
| 登录 (Login) | 2 | 1 | tg38 |
| 登出 (Logout) | 1 | 1 | - |
| 注册 (Register) | 3 | 2 | tg39 |
| 广告管理 (Manage Ads) | 6 | 1 | tg21, tg22, tg23, tg40, tg41 |
| Google 评论 | 7 | 0 | tg24, tg42-tg47 |
| 举报功能 (Report) | 2 | 1 | tg25 |
| 用户评价 (Review) | 6 | 1 | tg26, tg48-tg51 |
| 运输相关 (Ship) | 6 | 0 | tg27-tg30, tg52, tg53 |
| 密码重置 (Reset) | 3 | 0 | tg31, tg32, tg54 |
| TMX 安全 | 1 | 0 | tg33 |
| 诊断工具 | 2 | 0 | tg34, tg55 |
| 指标上报 | 2 | 0 | tg35, tg36 |
| 内部路由 | 1 | 1 | tg37 |
| 代理中间件 | 2 | 0 | tg56, tg57 |
| 开发环境 | 1 | 0 | tg58 |

---

## 📋 新增用例详细列表

### 广告接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg15 | tg15_ads_search.jmx | /bff-api/ads/advert/search | POST | 搜索广告 |
| tg16 | tg16_ads_get_by_id.jmx | /bff-api/ads/advert/:id | GET | 获取广告详情 |

### 消息中心接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg17 | tg17_conversations_extended.jmx | /bff-api/message-centre/conversations/extended | GET | 扩展会话信息 |
| tg18 | tg18_send_message.jmx | /bff-api/message-centre/message | POST | 发送消息 |
| tg19 | tg19_mark_as_read.jmx | /bff-api/message-centre/messages/:id/mark-as-read | PUT | 标记已读 |
| tg20 | tg20_delete_conversation.jmx | /bff-api/message-centre/delete-conversation | POST | 删除会话 |

### 广告管理接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg21 | tg21_manage_ads_buy_features.jmx | /bff-api/manage/ads/buy-features | POST | 购买广告功能 |
| tg22 | tg22_manage_ads_daily_stats.jmx | /bff-api/manage/ads/daily/ad-stats/:id | GET | 每日统计 |
| tg23 | tg23_manage_ads_cancel_auto_renew.jmx | /bff-api/manage/ads/cancel-auto-renew/:id | POST | 取消自动续费 |
| tg40 | tg40_phoneverify.jmx | /bff-api/manage/ads/phoneverify/:draftId | GET | 手机验证状态 |
| tg41 | tg41_identity_verification.jmx | /bff-api/manage/ads/identity-verification/verification | POST | 身份验证 |

### Google 评论接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg24 | tg24_google_review_summary.jmx | /bff-api/manage/ads/google/get-summary | GET | 评论摘要 |
| tg42 | tg42_google_do_auth.jmx | /bff-api/manage/ads/google/do-auth | GET | Google授权 |
| tg43 | tg43_google_set_display.jmx | /bff-api/manage/ads/google/set-display/:id/:display | GET | 设置显示 |
| tg44 | tg44_google_resync.jmx | /bff-api/manage/ads/google/re-sync/:authid | GET | 重新同步 |
| tg45 | tg45_google_unbind.jmx | /bff-api/manage/ads/google/unbind/:authid | GET | 解绑账号 |
| tg46 | tg46_google_relation_list.jmx | /bff-api/manage/ads/google/get-relation-list/:authid | GET | 关联列表 |
| tg47 | tg47_google_set_relation.jmx | /bff-api/manage/ads/google/set-relation/:id | GET | 设置关联 |

### 举报与评价接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg25 | tg25_report_user.jmx | /bff-api/report/report-user | POST | 举报用户 |
| tg26 | tg26_create_review.jmx | /bff-api/reviews/reviews | POST | 创建评价 |
| tg48 | tg48_reviewee_list.jmx | /bff-api/reviews/reviewee/list | POST | 可评价列表 |
| tg49 | tg49_braze_notification.jmx | /bff-api/reviews/braze/notification | POST | Braze通知 |
| tg50 | tg50_review_delay_judge.jmx | /bff-api/reviews/review/delay/judge | POST | 延迟判断 |
| tg51 | tg51_review_delay_record.jmx | /bff-api/reviews/review/delay/record | POST | 延迟记录 |

### 运输相关接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg27 | tg27_ship_check_price.jmx | /bff-api/ship/check-ad-price | POST | 检查价格 |
| tg28 | tg28_ship_create_label.jmx | /bff-api/ship/create-label | POST | 创建标签 |
| tg29 | tg29_ship_get_points.jmx | /bff-api/ship/get-points | POST | 获取服务点 |
| tg30 | tg30_ship_tracking_url.jmx | /bff-api/ship/get-tracking-url | GET | 物流追踪 |
| tg52 | tg52_ship_download.jmx | /bff-api/ship/download | POST | 下载文件 |
| tg53 | tg53_ship_download_qrcode.jmx | /bff-api/ship/download-qrcode | GET | 下载二维码 |

### 密码重置接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg31 | tg31_reset_via_form.jmx | /bff-api/reset/via-form | POST | 重置请求 |
| tg32 | tg32_forgot_password_form.jmx | /bff-api/reset/forgot-password-form | POST | 忘记密码表单 |
| tg54 | tg54_forgot_password_reset.jmx | /bff-api/reset/forgot-password-form/reset | POST | 密码重置确认 |

### 其他接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg33 | tg33_tmx_info.jmx | /bff-api/tmx/info | GET | TMX安全信息 |
| tg34 | tg34_diagnostics_services.jmx | /bff-api/diagnostics/dependent-services | GET | 依赖服务状态 |
| tg35 | tg35_metrics_counter.jmx | /bff-api/metrics/counter | POST | 计数器指标 |
| tg36 | tg36_metrics_histogram.jmx | /bff-api/metrics/histogram | POST | 直方图指标 |
| tg37 | tg37_internal_metrics.jmx | /internal/metrics | GET | Prometheus指标 |
| tg38 | tg38_login_via_social.jmx | /bff-api/login/via-social | POST | 社交登录 |
| tg39 | tg39_register_via_form.jmx | /bff-api/register/via-form | POST | 表单注册 |
| tg55 | tg55_diagnostics_profile_cpu.jmx | /bff-api/diagnostics/profile-cpu | GET | CPU性能分析 |

### 代理与开发接口
| 用例编号 | 文件名 | 接口路径 | 方法 | 说明 |
|----------|--------|----------|------|------|
| tg56 | tg56_phone_auth_proxy.jmx | /bff-api/phone-auth/* | ALL | 手机认证代理 |
| tg57 | tg57_bark_lead_proxy.jmx | /bff-api/bark-lead/* | ALL | Bark Lead代理 |
| tg58 | tg58_ajax_search_filters.jmx | /ajax/search-filters/:key/values | GET | 搜索过滤器(开发) |

---

## 🔧 使用说明

### 认证信息依赖

需要认证的用例依赖 `data/web_auth_tokens.csv` 文件，该文件由 `tg1_login_via_form.jmx` 生成。

运行顺序：
1. 先运行 `web-bff/tg1_login_via_form.jmx` 获取认证信息
2. 再运行需要认证的接口用例

### 环境变量

- `HOST_BFF`: BFF服务主机地址
- `PROTOCOL`: 协议 (http/https)

---

*文档自动生成于 2024年12月9日*
