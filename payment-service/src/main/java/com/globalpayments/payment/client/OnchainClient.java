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
