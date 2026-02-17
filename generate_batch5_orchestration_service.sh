#!/bin/bash
set -e

echo "🚀 启动批次 5：orchestration-service 生成脚本..."

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
# 1. 创建 orchestration-service 目录结构
###############################################
echo "📦 创建 orchestration-service 模块目录..."

mkdir -p orchestration-service/src/main/java/com/globalpayments/orchestration/controller
mkdir -p orchestration-service/src/main/java/com/globalpayments/orchestration/service
mkdir -p orchestration-service/src/main/java/com/globalpayments/orchestration/client
mkdir -p orchestration-service/src/main/java/com/globalpayments/orchestration/dto
mkdir -p orchestration-service/src/main/resources

###############################################
# 2. 生成 pom.xml
###############################################
echo "📄 写入 orchestration-service/pom.xml..."

cat > orchestration-service/pom.xml << 'EOF'
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
    <artifactId>orchestration-service</artifactId>

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

cat > orchestration-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8080

payment:
  base-url: http://localhost:8081

onchain:
  base-url: http://localhost:8082
EOF

###############################################
# 4. DTO 文件
###############################################
echo "📄 写入 DTO..."

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/dto/OrchestrationRequest.java << 'EOF'
package com.globalpayments.orchestration.dto;

import lombok.Data;

@Data
public class OrchestrationRequest {
    private Long amountUsd;
    private String description;
    private String toWallet;
}
EOF

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/dto/OrchestrationResponse.java << 'EOF'
package com.globalpayments.orchestration.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OrchestrationResponse {
    private String paymentIntentId;
    private String onchainSignature;
}
EOF

###############################################
# 5. PaymentClient.java
###############################################
echo "📄 写入 PaymentClient.java..."

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/client/PaymentClient.java << 'EOF'
package com.globalpayments.orchestration.client;

import com.globalpayments.orchestration.dto.OrchestrationRequest;
import com.globalpayments.payment.dto.CreatePaymentResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class PaymentClient {

    private final RestTemplate rest = new RestTemplate();

    public CreatePaymentResponse createPayment(OrchestrationRequest req, String baseUrl) {
        return rest.postForObject(
                baseUrl + "/payment/create",
                req,
                CreatePaymentResponse.class
        );
    }
}
EOF

###############################################
# 6. OnchainClient.java
###############################################
echo "📄 写入 OnchainClient.java..."

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/client/OnchainClient.java << 'EOF'
package com.globalpayments.orchestration.client;

import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class OnchainClient {

    private final RestTemplate rest = new RestTemplate();

    public TransferResponse transfer(TransferRequest req, String baseUrl) {
        return rest.postForObject(
                baseUrl + "/onchain/transfer",
                req,
                TransferResponse.class
        );
    }
}
EOF

###############################################
# 7. OrchestrationService.java
###############################################
echo "📄 写入 OrchestrationService.java..."

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/service/OrchestrationService.java << 'EOF'
package com.globalpayments.orchestration.service;

import com.globalpayments.orchestration.client.PaymentClient;
import com.globalpayments.orchestration.client.OnchainClient;
import com.globalpayments.orchestration.dto.OrchestrationRequest;
import com.globalpayments.orchestration.dto.OrchestrationResponse;
import com.globalpayments.payment.dto.CreatePaymentResponse;
import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class OrchestrationService {

    @Value("${payment.base-url}")
    private String paymentBaseUrl;

    @Value("${onchain.base-url}")
    private String onchainBaseUrl;

    private final PaymentClient paymentClient;
    private final OnchainClient onchainClient;

    public OrchestrationService(PaymentClient paymentClient, OnchainClient onchainClient) {
        this.paymentClient = paymentClient;
        this.onchainClient = onchainClient;
    }

    public OrchestrationResponse orchestrate(OrchestrationRequest req) {

        // 1. 创建 Stripe 支付
        CreatePaymentResponse payment = paymentClient.createPayment(req, paymentBaseUrl);

        // 2. 调用链上转账
        TransferRequest transferReq = new TransferRequest();
        transferReq.setPaymentIntentId(payment.getPaymentIntentId());
        transferReq.setAmountUsdc(req.getAmountUsd());
        transferReq.setToWallet(req.getToWallet());

        TransferResponse transfer = onchainClient.transfer(transferReq, onchainBaseUrl);

        return new OrchestrationResponse(
                payment.getPaymentIntentId(),
                transfer.getSignature()
        );
    }
}
EOF

###############################################
# 8. OrchestrationController.java
###############################################
echo "📄 写入 OrchestrationController.java..."

cat > orchestration-service/src/main/java/com/globalpayments/orchestration/controller/OrchestrationController.java << 'EOF'
package com.globalpayments.orchestration.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.orchestration.dto.OrchestrationRequest;
import com.globalpayments.orchestration.dto.OrchestrationResponse;
import com.globalpayments.orchestration.service.OrchestrationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orchestration")
public class OrchestrationController {

    private final OrchestrationService orchestrationService;

    public OrchestrationController(OrchestrationService orchestrationService) {
        this.orchestrationService = orchestrationService;
    }

    @PostMapping("/execute")
    public ApiResponse<OrchestrationResponse> execute(@RequestBody OrchestrationRequest req) {
        return ApiResponse.ok(orchestrationService.orchestrate(req));
    }
}
EOF

###############################################
# 9. 将模块加入父 pom.xml
###############################################
echo "🧩 将 orchestration-service 加入父 pom.xml..."

if ! grep -q "<module>orchestration-service</module>" pom.xml; then
  sed -i '/<modules>/a\        <module>orchestration-service</module>' pom.xml
  echo "✔ 已加入 orchestration-service 模块"
else
  echo "✔ 父 pom.xml 已包含 orchestration-service"
fi

###############################################
# 10. Git 提交（不强制 push）
###############################################
echo "📦 Git add..."
git add .

echo "📝 Git commit..."
git commit -m "Add Batch 5: orchestration-service module" || echo "ℹ️ 无需提交"

echo "🎉 批次 5：orchestration-service 已生成完成！"
