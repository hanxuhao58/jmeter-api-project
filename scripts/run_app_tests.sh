#!/usr/bin/env bash
set -e

# ========================================
# Mobile Apps BFF API 测试脚本
# 专门用于执行 Mobile Apps BFF 相关的 API 测试
# 包含 app-bff 和 app-bff-new 两个目录
# ========================================

# JMeter 配置
# 优先使用系统安装的 JMeter，如果没有则使用本地目录
if command -v jmeter &> /dev/null; then
  JMETER_CMD="jmeter"
elif [ -f "apache-jmeter-5.6.3/bin/jmeter" ]; then
  JMETER_CMD="apache-jmeter-5.6.3/bin/jmeter"
else
  echo "ERROR: JMeter not found. Please install JMeter or place it in apache-jmeter-5.6.3/"
  exit 1
fi
REPORT_DIR=reports
JTL=${REPORT_DIR}/jmeter-report/all_cases.jtl

# 创建报告目录并清空 JTL 文件
mkdir -p ${REPORT_DIR}/jmeter-report
> ${JTL}

# App BFF 专用配置
ENV_NAME=appbff
CONFIG_FILE=config/${ENV_NAME}.env.properties

# 若配置文件不存在则报错退出
if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: App BFF config file $CONFIG_FILE not found."
  exit 1
fi

echo "=== 开始执行 Mobile Apps BFF API 测试 ==="
echo "环境: $ENV_NAME"
echo "配置文件: $CONFIG_FILE"
echo "当前工作目录: $(pwd)"

# 先跑登录获取 token
echo "=== 步骤1: 执行登录测试获取 token ==="
${JMETER_CMD} -n -t testcases/app-bff/tg1_auth_login.jmx -q ${CONFIG_FILE} -l ${JTL}

# 确保 auth_tokens.csv 存在，若无则创建占位
echo "=== 步骤2: 检查 auth_tokens.csv 文件 ==="
if [ ! -f data/auth_tokens.csv ]; then
  echo "创建 auth_tokens.csv 占位文件..."
  mkdir -p data
  echo "userId,userToken,userAuthorization" > data/auth_tokens.csv
  echo "test,test,test" >> data/auth_tokens.csv
else
  echo "auth_tokens.csv 已存在，内容："
  cat data/auth_tokens.csv
fi

# App BFF 专用黑名单：这些测试用例将被跳过
echo "=== 步骤3: 执行 App BFF 测试用例（黑名单模式）==="
# 黑名单：这些测试用例将被跳过
# 注意：tg1_auth_login.jmx 已经在前面单独运行过，所以加入黑名单避免重复运行
# tg6_forgot_password.jmx 会造成系统登出，放到最后单独运行
# tg21_vip_phone.jmx 和 tg22_vip_reply.jmx会造成线上信息污染，可在测试环境运行。
blacklist=(
  testcases/app-bff/tg1_auth_login.jmx
  testcases/app-bff/tg6_forgot_password.jmx
  testcases/app-bff/tg21_vip_phone.jmx
  testcases/app-bff/tg22_vip_reply.jmx
  testcases/app-bff-new/tg37_v2_vip_phone.jmx
  testcases/app-bff-new/tg38_v2_vip_reply.jmx
)

echo "当前工作目录: $(pwd)"
echo "App BFF 测试用例目录内容:"
ls -la testcases/app-bff/
echo "App BFF New 测试用例目录内容:"
ls -la testcases/app-bff-new/
echo "数据目录内容:"
ls -la data/
echo "CSV 文件内容:"
cat data/auth_tokens.csv

# 获取所有 App BFF 测试用例目录下的 jmx 文件（包括 app-bff 和 app-bff-new）
all_files=($(find testcases/app-bff/ testcases/app-bff-new/ -name "*.jmx" | sort))

echo "找到 ${#all_files[@]} 个 App BFF 测试文件（包含 app-bff 和 app-bff-new）"

# 运行所有非黑名单的 App BFF 测试用例
for file in "${all_files[@]}"; do
  # 检查文件是否在黑名单中
  skip=false
  for blacklisted in "${blacklist[@]}"; do
    if [[ "$file" == "$blacklisted" ]]; then
      echo "跳过黑名单测试: $file"
      skip=true
      break
    fi
  done
  
  if [[ "$skip" == false ]]; then
    echo "执行 App BFF 测试: $file"
    # 添加错误处理，单个测试用例失败不影响其他测试
    if ! ${JMETER_CMD} -n -t "$file" -q ${CONFIG_FILE} -l ${JTL}; then
      echo "警告: App BFF 测试 $file 失败，但继续执行其他测试..."
    fi
  fi
done

# 最后单独执行 forgot password
echo "=== 步骤4: 执行忘记密码测试（最后执行，会造成系统登出）==="
# tg6_forgot_password.jmx 会造成系统登出，所以放到最后单独运行
echo "执行 tg6_forgot_password.jmx (最后执行，会造成系统登出)"
# 添加错误处理，即使 tg6 失败也不影响整体测试结果
if ! ${JMETER_CMD} -n -t testcases/app-bff/tg6_forgot_password.jmx -q ${CONFIG_FILE} -l ${JTL}; then
  echo "警告: tg6_forgot_password.jmx 失败，但继续..."
fi

# 生成统一 HTML 报告
echo "=== 步骤5: 生成 App BFF HTML 报告 ==="
# 先清理旧的报告目录
rm -rf ${REPORT_DIR}/all_cases_report
${JMETER_CMD} -g ${JTL} -e -o ${REPORT_DIR}/all_cases_report

echo "=== App BFF 测试执行完成 ==="
echo "所有 Mobile Apps BFF 测试已执行，报告生成在 ${REPORT_DIR}/all_cases_report" 