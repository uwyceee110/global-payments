#!/bin/bash
set -e

echo "🚀 启动批次 4：onchain-service 生成脚本..."

###############################################
# 0. 检查是否在 global-payments 根目录
###############################################
CURRENT_DIR_NAME=$(basename "$PWD")

if [ "$CURRENT_DIR_NAME" != "global-payments" ]; then
  echo "❌ 错误：当前目录不是 global-payments，而是：$CURRENT_DIR_NAME"
  echo "👉 请先进入 global-payments 目录再运行脚本。"
  exit 1
fi

echo "📁 已确认：当前目录为 global-payments（根目录正确）"

###############################################
# 1. 创建 onchain-service 目录结构
###############################################
echo "📦 创建 onchain-service 模块目录..."

mkdir -p onchain-service/src/main/java/com/globalpayments/onchain/controller
mkdir -p onchain-service/src/main/java/com/globalpayments/onchain/service
mkdir -p onchain-service/src/main/java/com/globalpayments/onchain/dto
mkdir -p onchain-service/src/main/java/com/globalpayments/onchain/config
mkdir -p onchain-service/src/main/resources

###############################################
# 2. 生成 pom.xml
###############################################
echo "📄 写入 onchain-service/pom.xml..."

cat > onchain-service/pom.xml << 'EOF'
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
    <artifactId>onchain-service</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>com.globalpayments</groupId>
            <artifactId>common</artifactId>
        </dependency>
    </dependencies>

</project>
EOF

###############################################
# 3. application.yml
###############################################
echo "📄 写入 application.yml..."

cat > onchain-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8082

solana:
  rpc-url: https://api.mainnet-beta.solana.com
  usdc-mint: EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
EOF

###############################################
# 4. DTO 文件
###############################################
echo "📄 写入 DTO..."

cat > onchain-service/src/main/java/com/globalpayments/onchain/dto/TransferRequest.java << 'EOF'
package com.globalpayments.onchain.dto;

import lombok.Data;

@Data
public class TransferRequest {
    private String paymentIntentId;
    private Long amountUsdc;
    private String toWallet;
}
EOF

cat > onchain-service/src/main/java/com/globalpayments/onchain/dto/TransferResponse.java << 'EOF'
package com.globalpayments.onchain.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TransferResponse {
    private String signature;
}
EOF

###############################################
# 5. OnchainService.java
###############################################
echo "📄 写入 OnchainService.java..."

cat > onchain-service/src/main/java/com/globalpayments/onchain/service/OnchainService.java << 'EOF'
package com.globalpayments.onchain.service;

import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import org.springframework.stereotype.Service;

@Service
public class OnchainService {

    public TransferResponse transferUsdc(TransferRequest req) {

        // TODO: 调用 Solana RPC 进行 USDC 转账
        // 这里先返回 mock 数据，后续批次会补全链上逻辑

        String mockSignature = "mock_signature_" + req.getPaymentIntentId();

        return new TransferResponse(mockSignature);
    }
}
EOF

###############################################
# 6. OnchainController.java
###############################################
echo "📄 写入 OnchainController.java..."

cat > onchain-service/src/main/java/com/globalpayments/onchain/controller/OnchainController.java << 'EOF'
package com.globalpayments.onchain.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import com.globalpayments.onchain.service.OnchainService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/onchain")
public class OnchainController {

    private final OnchainService onchainService;

    public OnchainController(OnchainService onchainService) {
        this.onchainService = onchainService;
    }

    @PostMapping("/transfer")
    public ApiResponse<TransferResponse> transfer(@RequestBody TransferRequest req) {
        return ApiResponse.ok(onchainService.transferUsdc(req));
    }
}
EOF

###############################################
# 7. 将模块加入父 pom.xml
###############################################
echo "🧩 将 onchain-service 加入父 pom.xml..."

if ! grep -q "<module>onchain-service</module>" pom.xml; then
  sed -i '/<modules>/a\        <module>onchain-service</module>' pom.xml
  echo "✔ 已加入 onchain-service 模块"
else
  echo "✔ 父 pom.xml 已包含 onchain-service"
fi

###############################################
# 8. Git 提交（不强制 push）
###############################################
echo "📦 Git add..."
git add .

echo "📝 Git commit..."
git commit -m "Add Batch 4: onchain-service module" || echo "ℹ️ 无需提交"

echo "🎉 批次 4：onchain-service 已生成完成！"
