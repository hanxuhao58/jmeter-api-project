#!/usr/bin/env bash
set -e
JMETER_VER=5.6.3
JMETER_DIR=apache-jmeter-${JMETER_VER}

# 下载并解压 JMeter（若已存在则跳过）
if [ ! -d "$JMETER_DIR" ]; then
  echo "Downloading JMeter $JMETER_VER ..."
  wget -q https://mirrors.tuna.tsinghua.edu.cn/apache/jmeter/binaries/${JMETER_DIR}.tgz
  tar -xzf ${JMETER_DIR}.tgz
fi

# 安装 cmdrunner
wget -q https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.3/cmdrunner-2.3.jar -O ${JMETER_DIR}/lib/cmdrunner-2.3.jar

# 安装 Plugins Manager
PLUGIN_VERSION=1.8
wget -q https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/${PLUGIN_VERSION}/jmeter-plugins-manager-${PLUGIN_VERSION}.jar -O ${JMETER_DIR}/lib/ext/jmeter-plugins-manager.jar

# 安装 JSON Path Assertion 插件
JSON_PLUGIN_VERSION=2.7
wget -q https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-json/${JSON_PLUGIN_VERSION}/jmeter-plugins-json-${JSON_PLUGIN_VERSION}.jar -O ${JMETER_DIR}/lib/ext/jmeter-plugins-json.jar

mkdir -p reports

echo "JMeter and plugins installed successfully." 