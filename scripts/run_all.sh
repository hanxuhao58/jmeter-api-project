#!/usr/bin/env bash
set -e
JMETER_DIR=apache-jmeter-5.6.3
REPORT_DIR=reports
JTL=${REPORT_DIR}/all_cases.jtl

mkdir -p ${REPORT_DIR}
> ${JTL}

# 根据第一个参数决定环境名，默认为 dev
ENV_NAME=${1:-dev}
CONFIG_FILE=config/${ENV_NAME}.env.properties

# 若配置文件不存在则报错退出
if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file $CONFIG_FILE not found."
  exit 1
fi

# 先跑登录获取 token
${JMETER_DIR}/bin/jmeter -n -t testcases/tg1_auth_login.jmx -q ${CONFIG_FILE} -l ${JTL}

# 确保 auth_tokens.csv 存在，若无则创建占位
if [ ! -f data/auth_tokens.csv ]; then
  echo "userId,userToken,userAuthorization" > data/auth_tokens.csv
  echo "test,test,test" >> data/auth_tokens.csv
fi

# 白名单用例
whitelist=(
  testcases/tg2_registration_register.jmx
  testcases/tg3_auth_logout.jmx
  testcases/tg4_account_activation.jmx
  testcases/tg5_password_reset.jmx
  testcases/tg7_ad_posted_analytics.jmx
  testcases/tg8_post_ad.jmx
  testcases/tg9_delete_ad.jmx
  testcases/tg10_promote_ad_screen.jmx
  testcases/tg11_user_block.jmx
  testcases/tg12_vip_screen.jmx
  testcases/tg13_mygumtree_screen.jmx
  testcases/tg14_favourites.jmx
  testcases/tg15_favourites_screen.jmx
  testcases/tg16_chat_screen.jmx
  testcases/tg17_conversation_screen.jmx
  testcases/tg18_conversation_unread_messages.jmx
  testcases/tg19_conversation.jmx
  testcases/tg20_reviews_conversation.jmx
)

for file in "${whitelist[@]}"; do
  echo "Running ${file}"
  ${JMETER_DIR}/bin/jmeter -n -t "${file}" -q ${CONFIG_FILE} -l ${JTL}
done

# 最后单独执行 forgot password
${JMETER_DIR}/bin/jmeter -n -t testcases/tg6_forgot_password.jmx -q ${CONFIG_FILE} -l ${JTL}

# 生成统一 HTML 报告
${JMETER_DIR}/bin/jmeter -g ${JTL} -e -o ${REPORT_DIR}/all_cases_report

echo "All JMeter tests executed and report generated at ${REPORT_DIR}/all_cases_report" 