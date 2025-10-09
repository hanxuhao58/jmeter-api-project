#!/usr/bin/env bash
# 注意：不使用 set -e，以便测试失败时可以继续执行后续测试
# set -e

# ========================================
# Web BFF API 测试脚本
# 专门用于执行 Web BFF 相关的 API 测试
# ========================================

# JMeter 配置
JMETER_DIR=apache-jmeter-5.6.3
REPORT_DIR=reports
JTL=${REPORT_DIR}/jmeter-report/all_cases.jtl

# 创建报告目录并清空 JTL 文件
mkdir -p ${REPORT_DIR}/jmeter-report
> ${JTL}

# Web BFF 专用配置
ENV_NAME=webbff
CONFIG_FILE=config/${ENV_NAME}.env.properties

# 若配置文件不存在则报错退出
if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Web BFF config file $CONFIG_FILE not found."
  exit 1
fi

echo "=== 开始执行 Web BFF API 测试 ==="
echo "环境: $ENV_NAME"
echo "配置文件: $CONFIG_FILE"
echo "当前工作目录: $(pwd)"

# 先跑登录获取 token
echo "=== 步骤1: 执行登录测试获取 token ==="
${JMETER_DIR}/bin/jmeter -n -t testcases/web-bff/tg1_login_via_form.jmx -q ${CONFIG_FILE} -l ${JTL} || {
  echo "警告: 登录测试失败，但继续执行..."
}

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

# Web BFF 专用黑名单：这些测试用例将被跳过
echo "=== 步骤3: 执行 Web BFF 测试用例（黑名单模式）==="
# 黑名单：这些测试用例将被跳过
# 注意：tg1_login_via_form.jmx 已经在前面单独运行过，所以加入黑名单避免重复运行
# tg99_logout_via-form.jmx 会造成系统登出，放到最后单独运行
# tg98_delete.jmx 会删除数据，放到最后单独运行
blacklist=(
  testcases/web-bff/tg1_login_via_form.jmx
  testcases/web-bff/tg99_logout_via-form.jmx
  testcases/web-bff/tg98_delete.jmx
)

echo "当前工作目录: $(pwd)"
echo "Web BFF 测试用例目录内容:"
ls -la testcases/web-bff/
echo "数据目录内容:"
ls -la data/
echo "CSV 文件内容:"
cat data/auth_tokens.csv

# 获取所有 Web BFF 测试用例目录下的 jmx 文件
all_files=($(find testcases/web-bff/ -name "*.jmx" | sort))

echo "找到 ${#all_files[@]} 个 Web BFF 测试文件"

# 运行所有非黑名单的 Web BFF 测试用例
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
    echo "执行 Web BFF 测试: $file"
    # 添加错误处理，单个测试用例失败不影响其他测试
    # 使用 || true 确保即使测试失败也继续执行
    ${JMETER_DIR}/bin/jmeter -n -t "$file" -q ${CONFIG_FILE} -l ${JTL} || {
      echo "警告: Web BFF 测试 $file 失败，但继续执行其他测试..."
    }
  fi
done

# 最后单独执行删除和登出测试
echo "=== 步骤4: 执行删除和登出测试（最后执行，会造成数据删除和系统登出）==="
# tg98_delete.jmx 会删除数据，所以放到最后单独运行
echo "执行 tg98_delete.jmx (最后执行，会删除数据)"
${JMETER_DIR}/bin/jmeter -n -t testcases/web-bff/tg98_delete.jmx -q ${CONFIG_FILE} -l ${JTL} || {
  echo "警告: tg98_delete.jmx 失败，但继续..."
}

# tg99_logout_via-form.jmx 会造成系统登出，所以放到最后单独运行
echo "执行 tg99_logout_via-form.jmx (最后执行，会造成系统登出)"
${JMETER_DIR}/bin/jmeter -n -t testcases/web-bff/tg99_logout_via-form.jmx -q ${CONFIG_FILE} -l ${JTL} || {
  echo "警告: tg99_logout_via-form.jmx 失败，但继续..."
}

# 生成统一 HTML 报告
echo "=== 步骤5: 生成 Web BFF HTML 报告 ==="
${JMETER_DIR}/bin/jmeter -g ${JTL} -e -o ${REPORT_DIR}/all_cases_report

echo "=== Web BFF 测试执行完成 ==="
echo "所有 Web BFF 测试已执行，报告生成在 ${REPORT_DIR}/all_cases_report"
