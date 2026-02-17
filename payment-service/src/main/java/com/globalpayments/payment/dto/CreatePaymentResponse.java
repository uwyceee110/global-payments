package com.globalpayments.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CreatePaymentResponse {
    private String paymentIntentId;
    private String clientSecret;
}
