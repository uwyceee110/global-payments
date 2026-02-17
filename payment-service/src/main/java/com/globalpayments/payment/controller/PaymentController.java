package com.globalpayments.payment.controller;

import com.globalpayments.common.dto.ApiResponse;
import com.globalpayments.payment.dto.CreatePaymentRequest;
import com.globalpayments.payment.dto.CreatePaymentResponse;
import com.globalpayments.payment.service.PaymentService;
import com.globalpayments.payment.service.StripeWebhookService;
import com.stripe.model.Event;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final StripeWebhookService webhookService;

    public PaymentController(PaymentService paymentService, StripeWebhookService webhookService) {
        this.paymentService = paymentService;
        this.webhookService = webhookService;
    }

    @PostMapping("/create")
    public ApiResponse<CreatePaymentResponse> create(@RequestBody CreatePaymentRequest req) throws Exception {
        return ApiResponse.ok(paymentService.createPayment(req));
    }

    @PostMapping("/webhook")
    public String webhook(@RequestBody String payload,
                          @RequestHeader("Stripe-Signature") String sig) throws Exception {

        Event event = webhookService.parseEvent(payload, sig);
        webhookService.handleEvent(event);
        return "ok";
    }
}
