import React from "react";

export default function ResultPanel({ result }) {
  return (
    <div style={{ marginTop: 30 }}>
      <h2>支付结果</h2>
      <p>Stripe PaymentIntent ID: {result.paymentIntentId}</p>
      <p>Onchain Signature: {result.onchainSignature}</p>
    </div>
  );
}
