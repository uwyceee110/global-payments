package com.globalpayments.payment.service;

import com.stripe.model.Event;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class StripeWebhookService {

    @Value("${stripe.webhook-secret}")
    private String webhookSecret;

    public Event parseEvent(String payload, String signatureHeader) throws Exception {
        return Webhook.constructEvent(payload, signatureHeader, webhookSecret);
    }

    public void handleEvent(Event event) {
        switch (event.getType()) {
            case "payment_intent.succeeded":
                System.out.println("Payment succeeded");
                break;
            case "payment_intent.payment_failed":
                System.out.println("Payment failed");
                break;
            default:
                System.out.println("Unhandled event: " + event.getType());
        }
    }
}
