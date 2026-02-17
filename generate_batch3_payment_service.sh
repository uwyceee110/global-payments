#!/bin/bash
set -e

echo "🚀 启动批次 3：payment-service 生成脚本..."

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
# 1. 创建 payment-service 目录结构
###############################################
echo "📦 创建 payment-service 模块目录..."

mkdir -p payment-service/src/main/java/com/globalpayments/payment/controller
mkdir -p payment-service/src/main/java/com/globalpayments/payment/service
mkdir -p payment-service/src/main/java/com/globalpayments/payment/client
mkdir -p payment-service/src/main/java/com/globalpayments/payment/dto
mkdir -p payment-service/src/main/java/com/globalpayments/payment/config
mkdir -p payment-service/src/main/resources

###############################################
# 2. 生成 pom.xml
###############################################
echo "📄 写入 payment-service/pom.xml..."

cat > payment-service/pom.xml << 'EOF'
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
    <artifactId>payment-service</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>com.stripe</groupId>
            <artifactId>stripe-java</artifactId>
            <version>24.0.0</version>
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

cat > payment-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8081

stripe:
  secret-key: sk_test_xxx
  webhook-secret: whsec_xxx

onchain:
  base-url: http://localhost:8082
EOF

###############################################
# 4. StripeConfig.java
###############################################
echo "📄 写入 StripeConfig.java..."

cat > payment-service/src/main/java/com/globalpayments/payment/config/StripeConfig.java << 'EOF'
package com.globalpayments.payment.config;

import com.stripe.Stripe;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StripeConfig {

    public StripeConfig(@Value("${stripe.secret-key}") String secretKey) {
        Stripe.apiKey = secretKey;
    }
}
EOF

###############################################
# 5. DTO 文件
###############################################
echo "📄 写入 DTO..."

cat > payment-service/src/main/java/com/globalpayments/payment/dto/CreatePaymentRequest.java << 'EOF'
package com.globalpayments.payment.dto;

import lombok.Data;

@Data
public class CreatePaymentRequest {
    private Long amountUsd;
    private String description;
}
EOF

cat > payment-service/src/main/java/com/globalpayments/payment/dto/CreatePaymentResponse.java << 'EOF'
package com.globalpayments.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CreatePaymentResponse {
    private String paymentIntentId;
    private String clientSecret;
}
EOF

cat > payment-service/src/main/java/com/globalpayments/payment/dto/StripeWebhookEvent.java << 'EOF'
package com.globalpayments.payment.dto;

import lombok.Data;

@Data
public class StripeWebhookEvent {
    private String type;
    private Object data;
}
EOF

###############################################
# 6. PaymentService.java
###############################################
echo "📄 写入 PaymentService.java..."

cat > payment-service/src/main/java/com/globalpayments/payment/service/PaymentService.java << 'EOF'
package com.globalpayments.payment.service;

import com.globalpayments.payment.dto.CreatePaymentRequest;
import com.globalpayments.payment.dto.CreatePaymentResponse;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

    public CreatePaymentResponse createPayment(CreatePaymentRequest req) throws Exception {

        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(req.getAmountUsd() * 100L)
                .setCurrency("usd")
                .setDescription(req.getDescription())
                .build();

        PaymentIntent intent = PaymentIntent.create(params);

        return new CreatePaymentResponse(
                intent.getId(),
                intent.getClientSecret()
        );
    }
}
EOF

###############################################
# 7. StripeWebhookService.java
###############################################
echo "📄 写入 StripeWebhookService.java..."

cat > payment-service/src/main/java/com/globalpayments/payment/service/StripeWebhookService.java << 'EOF'
package com.globalpayments.payment.service;

import com.stripe.model.Event;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class StripeWebhookService {

    @Value("${stripe.webhook-secret}")
    private String webhookSecret;

    public Event parseEvent(String payload, String signatureHeader) throws Exception {
        return Webhook.constructEvent(payload, signatureHeader, webhookSecret);
    }

    public void handleEvent(Event event) {
        switch (event.getType()) {
            case "payment_intent.succeeded":
                System.out.println("Payment succeeded");
                break;
            case "payment_intent.payment_failed":
                System.out.println("Payment failed");
                break;
            default:
                System.out.println("Unhandled event: " + event.getType());
        }
    }
}
EOF

###############################################
# 8. OnchainClient.java
###############################################
echo "📄 写入 OnchainClient.java..."

cat > payment-service/src/main/java/com/globalpayments/payment/client/OnchainClient.java << 'EOF'
package com.globalpayments.payment.client;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class OnchainClient {

    private final RestTemplate rest = new RestTemplate();

    public void sendUsdcTransfer(String paymentIntentId, Long amount) {
        // TODO: 调用 onchain-service
    }
}
EOF

###############################################
# 9. PaymentController.java
###############################################
echo "📄 写入 PaymentController.java..."

cat > payment-service/src/main/java/com/globalpayments/payment/controller/PaymentController.java << 'EOF'
package com.globalpayments.payment.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.payment.dto.CreatePaymentRequest;
import com.globalpayments.payment.dto.CreatePaymentResponse;
import com.globalpayments.payment.service.PaymentService;
import com.globalpayments.payment.service.StripeWebhookService;
import com.stripe.model.Event;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final StripeWebhookService webhookService;

    public PaymentController(PaymentService paymentService, StripeWebhookService webhookService) {
        this.paymentService = paymentService;
        this.webhookService = webhookService;
    }

    @PostMapping("/create")
    public ApiResponse<CreatePaymentResponse> create(@RequestBody CreatePaymentRequest req) throws Exception {
        return ApiResponse.ok(paymentService.createPayment(req));
    }

    @PostMapping("/webhook")
    public String webhook(@RequestBody String payload,
                          @RequestHeader("Stripe-Signature") String sig) throws Exception {

        Event event = webhookService.parseEvent(payload, sig);
        webhookService.handleEvent(event);
        return "ok";
    }
}
EOF

###############################################
# 10. 将模块加入父 pom.xml
###############################################
echo "🧩 将 payment-service 加入父 pom.xml..."

if ! grep -q "<module>payment-service</module>" pom.xml; then
  sed -i '/<modules>/a\        <module>payment-service</module>' pom.xml
  echo "✔ 已加入 payment-service 模块"
else
  echo "✔ 父 pom.xml 已包含 payment-service"
fi

###############################################
# 11. Git 提交（不强制 push）
###############################################
echo "📦 Git add..."
git add .

echo "📝 Git commit..."
git commit -m "Add Batch 3: payment-service module" || echo "ℹ️ 无需提交"

echo "🎉 批次 3：payment-service 已生成完成！"
