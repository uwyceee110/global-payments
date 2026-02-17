package com.globalpayments.orchestration.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.orchestration.dto.OrchestrationRequest;
import com.globalpayments.orchestration.dto.OrchestrationResponse;
import com.globalpayments.orchestration.service.OrchestrationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orchestration")
public class OrchestrationController {

    private final OrchestrationService orchestrationService;

    public OrchestrationController(OrchestrationService orchestrationService) {
        this.orchestrationService = orchestrationService;
    }

    @PostMapping("/execute")
    public ApiResponse<OrchestrationResponse> execute(@RequestBody OrchestrationRequest req) {
        return ApiResponse.ok(orchestrationService.orchestrate(req));
    }
}
