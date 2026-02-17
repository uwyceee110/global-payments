package com.globalpayments.orchestration.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OrchestrationResponse {
    private String paymentIntentId;
    private String onchainSignature;
}
