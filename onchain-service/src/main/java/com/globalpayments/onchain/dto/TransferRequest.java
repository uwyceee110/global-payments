package com.globalpayments.onchain.dto;

import lombok.Data;

@Data
public class TransferRequest {
    private String paymentIntentId;
    private Long amountUsdc;
    private String toWallet;
}
