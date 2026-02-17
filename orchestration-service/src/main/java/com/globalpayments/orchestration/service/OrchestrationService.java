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
