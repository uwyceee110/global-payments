package com.globalpayments.orchestration.dto;

import lombok.Data;

@Data
public class OrchestrationRequest {
    private Long amountUsd;
    private String description;
    private String toWallet;
}
