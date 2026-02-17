#!/bin/bash
set -e

echo "🔧 开始修复批次 1 + 批次 2 缺失文件..."

###############################################
# 1. 确保 common/pom.xml 存在
###############################################
if [ ! -f "common/pom.xml" ]; then
  echo "📄 创建 common/pom.xml..."
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

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>

</project>
EOF
else
  echo "✔ common/pom.xml 已存在，跳过"
fi

###############################################
# 2. 补全 PaymentStatus.java
###############################################
if [ ! -f "common/src/main/java/com/globalpayments/common/dto/PaymentStatus.java" ]; then
  echo "📄 创建 PaymentStatus.java..."
  cat > common/src/main/java/com/globalpayments/common/dto/PaymentStatus.java << 'EOF'
package com.globalpayments.common.dto;

public enum PaymentStatus {
    PENDING,
    SUCCESS,
    FAILED
}
EOF
else
  echo "✔ PaymentStatus.java 已存在，跳过"
fi

###############################################
# 3. 检查父 pom.xml 是否包含 modules
###############################################
if ! grep -q "<module>common</module>" pom.xml; then
  echo "📄 修复根 pom.xml，添加 <module>common</module>..."
  sed -i '/<modules>/a\        <module>common</module>' pom.xml
else
  echo "✔ 根 pom.xml 已包含 common 模块"
fi

echo "🎉 批次 1 + 批次 2 修复完成！"
