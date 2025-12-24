#!/usr/bin/env bash
# 注意：不使用 set -e，以便测试失败时可以继续执行后续测试
# set -e

# ========================================
# Web BFF API 测试脚本
# 专门用于执行 Web BFF 相关的 API 测试
# 包含 web-bff 和 web-bff-new 两个目录
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
${JMETER_CMD} -n -t testcases/web-bff/tg1_login_via_form.jmx -q ${CONFIG_FILE} -l ${JTL} || true
echo "登录测试完成，继续..."

# 确保 web_auth_tokens.csv 存在（Web BFF 测试使用这个文件名）
echo "=== 步骤2: 检查 web_auth_tokens.csv 文件 ==="
mkdir -p data
if [ ! -f data/web_auth_tokens.csv ]; then
  echo "⚠️  警告: web_auth_tokens.csv 不存在，创建占位文件..."
  echo "timestamp,username,statusCode,responseTime,sessionId,rememberMe,gtMc,location,upstreamServiceTime,userToken,userAuthorization,conversationsToken,cookieString,testResult" > data/web_auth_tokens.csv
  echo "0,test@test.com,200,0,test_session,test_remember,test_gtmc,test_location,0,test_token,test_auth,test_conv_token,test_cookie,PLACEHOLDER" >> data/web_auth_tokens.csv
else
  echo "✓ web_auth_tokens.csv 已存在"
  echo "文件大小: $(wc -l < data/web_auth_tokens.csv) 行"
  echo "最新一行数据（不含header）："
  tail -1 data/web_auth_tokens.csv || echo "无法读取"
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
  testcases/web-bff/tg6_repost.jmx
)

echo "当前工作目录: $(pwd)"
echo "Web BFF 测试用例目录内容:"
ls -la testcases/web-bff/
echo "Web BFF New 测试用例目录内容:"
ls -la testcases/web-bff-new/
echo "数据目录内容:"
ls -la data/
echo "CSV 文件内容:"
cat data/auth_tokens.csv

# 执行顺序：1.登录(已完成) -> 2.旧case(web-bff) -> 3.新case(web-bff-new) -> 4.删除和登出

# 定义执行测试的函数
run_test_file() {
  local file=$1
  local count=$2
  local total=$3
  
  # 检查文件是否在黑名单中
  for blacklisted in "${blacklist[@]}"; do
    if [[ "$file" == "$blacklisted" ]]; then
      echo "跳过黑名单测试: $file"
      return 0
    fi
  done
  
  echo "=== [$count/$total] 开始执行: $file ==="
  echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
  
  # 执行测试，单个测试用例失败不影响其他测试
  if ! ${JMETER_CMD} -n -t "$file" -q ${CONFIG_FILE} -l ${JTL}; then
    echo "⚠️  警告: 测试 $file 执行失败，但继续执行其他测试..."
  fi
  
  echo "=== [$count/$total] 完成: $file ==="
  echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "JTL 当前行数: $(wc -l < ${JTL} 2>/dev/null || echo '0')"
  echo ""
}

# 步骤3a: 先执行旧的 web-bff 目录测试
echo "=== 步骤3a: 执行旧的 Web BFF 测试用例 (web-bff) ==="
old_files=($(find testcases/web-bff/ -name "*.jmx" | sort))
echo "找到 ${#old_files[@]} 个旧 Web BFF 测试文件"

executed_count=0
for file in "${old_files[@]}"; do
  executed_count=$((executed_count + 1))
  run_test_file "$file" "$executed_count" "${#old_files[@]}"
done

echo "=== 旧 Web BFF 测试完成，已执行 $executed_count 个文件 ==="

# 步骤3b: 再执行新的 web-bff-new 目录测试
echo "=== 步骤3b: 执行新的 Web BFF 测试用例 (web-bff-new) ==="
new_files=($(find testcases/web-bff-new/ -name "*.jmx" | sort))
echo "找到 ${#new_files[@]} 个新 Web BFF 测试文件"

executed_count=0
for file in "${new_files[@]}"; do
  executed_count=$((executed_count + 1))
  run_test_file "$file" "$executed_count" "${#new_files[@]}"
done

echo "=== 新 Web BFF 测试完成，已执行 $executed_count 个文件 ==="

# 最后单独执行删除和登出测试
echo "=== 步骤4: 执行删除和登出测试（最后执行，会造成数据删除和系统登出）==="
# tg98_delete.jmx 会删除数据，所以放到最后单独运行
echo "执行 tg98_delete.jmx (最后执行，会删除数据)"
${JMETER_CMD} -n -t testcases/web-bff/tg98_delete.jmx -q ${CONFIG_FILE} -l ${JTL} || true
echo "tg98_delete.jmx 完成"

# tg99_logout_via-form.jmx 会造成系统登出，所以放到最后单独运行
echo "执行 tg99_logout_via-form.jmx (最后执行，会造成系统登出)"
${JMETER_CMD} -n -t testcases/web-bff/tg99_logout_via-form.jmx -q ${CONFIG_FILE} -l ${JTL} || true
echo "tg99_logout_via-form.jmx 完成"

# 生成统一 HTML 报告
echo "=== 步骤5: 生成 Web BFF HTML 报告 ==="
echo "检查 JTL 文件内容："
if [ -f ${JTL} ]; then
  echo "JTL 文件大小: $(wc -l < ${JTL}) 行"
  echo "JTL 文件前3行:"
  head -3 ${JTL} || echo "无法读取 JTL 文件内容"
else
  echo "错误: JTL 文件不存在！"
fi

# 尝试生成 HTML 报告，即使失败也不影响整个流程
# 先清理旧的报告目录
rm -rf ${REPORT_DIR}/all_cases_report
if ${JMETER_CMD} -g ${JTL} -e -o ${REPORT_DIR}/all_cases_report 2>&1; then
  echo "✓ HTML 报告生成成功"
else
  echo "⚠ HTML 报告生成失败，但测试结果已保存在 JTL 文件中"
fi

echo "=== Web BFF 测试执行完成 ==="
echo "所有 Web BFF 测试已执行，报告生成在 ${REPORT_DIR}/all_cases_report"
echo "JTL 结果文件: ${JTL}"
