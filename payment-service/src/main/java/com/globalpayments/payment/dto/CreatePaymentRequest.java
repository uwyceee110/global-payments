package com.globalpayments.payment.dto;

import lombok.Data;

@Data
public class CreatePaymentRequest {
    private Long amountUsd;
    private String description;
}
