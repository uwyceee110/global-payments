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
