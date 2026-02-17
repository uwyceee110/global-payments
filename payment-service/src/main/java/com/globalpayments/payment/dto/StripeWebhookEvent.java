package com.globalpayments.payment.dto;

import lombok.Data;

@Data
public class StripeWebhookEvent {
    private String type;
    private Object data;
}
