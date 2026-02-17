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
