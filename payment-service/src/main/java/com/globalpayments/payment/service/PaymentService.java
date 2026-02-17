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
