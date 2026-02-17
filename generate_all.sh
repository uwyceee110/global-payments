#!/bin/bash
set -e

echo "🚀 启动批次 1 + 批次 2 生成脚本（最终稳定版）..."

###############################################
# 0. 使用目录名判断是否在 global-payments 根目录
###############################################
CURRENT_DIR_NAME=$(basename "$PWD")

if [ "$CURRENT_DIR_NAME" != "global-payments" ]; then
  echo "❌ 错误：当前目录不是 global-payments，而是：$CURRENT_DIR_NAME"
  echo "👉 请先进入 global-payments 目录再运行脚本。"
  exit 1
fi

echo "📁 已确认：当前目录为 global-payments（根目录正确）"

###############################################
# 1. 批次 1：根目录文件
###############################################
echo "📦 生成批次 1 文件..."

cat > pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>com.globalpayments</groupId>
    <artifactId>global-payments</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>

    <modules>
        <module>common</module>
    </modules>

</project>
EOF

mkdir -p docs
echo "# Documentation" > docs/README.md

###############################################
# 2. 批次 2：common 模块
###############################################
echo "📦 生成批次 2：common 模块..."

mkdir -p common/src/main/java/com/globalpayments/common/dto
mkdir -p common/src/main/java/com/globalpayments/common/util
mkdir -p common/src/main/resources

cat > common/pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <parent>
        <groupId>com.globalpayments</groupId>
        <artifactId>global-payments</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>

    <modelVersion>4.0.0</modelVersion>
    <artifactId>common</artifactId>

</project>
EOF

cat > common/src/main/java/com/globalpayments/common/dto/ApiResponse.java << 'EOF'
package com.globalpayments.common.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private T data;
    private String errorCode;
    private String message;
}
EOF

cat > common/src/main/java/com/globalpayments/common/dto/ErrorCode.java << 'EOF'
package com.globalpayments.common.dto;

public enum ErrorCode {
    INVALID_REQUEST,
    PAYMENT_FAILED,
    INTERNAL_ERROR
}
EOF

cat > common/src/main/java/com/globalpayments/common/util/BigDecimalUtil.java << 'EOF'
package com.globalpayments.common.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class BigDecimalUtil {
    public static BigDecimal usdToUsdc(BigDecimal usd) {
        return usd.setScale(6, RoundingMode.DOWN);
    }
}
EOF

echo "# Common module placeholder" > common/src/main/resources/application.yml

###############################################
# 3. Git 推送流程
###############################################
echo "🧩 检查 Git 仓库..."

if [ ! -d ".git" ]; then
  echo "⚙️ 初始化 Git 仓库..."
  git init
fi

REMOTE_URL_EXPECTED="https://github.com/uwyceee110/global-payments.git"
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ "$REMOTE_URL" != "$REMOTE_URL_EXPECTED" ]; then
  echo "🔗 修复远程仓库 URL..."
  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE_URL_EXPECTED"
fi

git branch -M main

git add .
git commit -m "Batch 1 + Batch 2 generated (stable script)" || echo "ℹ️ 无需提交"

echo "⬆️ 推送到 GitHub..."
git push -u origin main

echo "🎉 批次 1 + 批次 2 已成功生成并推送！"
