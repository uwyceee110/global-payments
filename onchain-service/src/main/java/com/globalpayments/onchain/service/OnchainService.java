package com.globalpayments.onchain.service;

import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import org.springframework.stereotype.Service;

@Service
public class OnchainService {

    public TransferResponse transferUsdc(TransferRequest req) {

        // TODO: 调用 Solana RPC 进行 USDC 转账
        // 这里先返回 mock 数据，后续批次会补全链上逻辑

        String mockSignature = "mock_signature_" + req.getPaymentIntentId();

        return new TransferResponse(mockSignature);
    }
}
