package com.globalpayments.onchain.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.onchain.dto.TransferRequest;
import com.globalpayments.onchain.dto.TransferResponse;
import com.globalpayments.onchain.service.OnchainService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/onchain")
public class OnchainController {

    private final OnchainService onchainService;

    public OnchainController(OnchainService onchainService) {
        this.onchainService = onchainService;
    }

    @PostMapping("/transfer")
    public ApiResponse<TransferResponse> transfer(@RequestBody TransferRequest req) {
        return ApiResponse.ok(onchainService.transferUsdc(req));
    }
}
