import React, { useState } from "react";
import { executePayment } from "../api";

export default function PaymentForm({ onResult }) {
  const [amount, setAmount] = useState(10);
  const [desc, setDesc] = useState("Test Payment");
  const [wallet, setWallet] = useState("YourWalletAddress");

  const submit = async () => {
    const payload = {
      amountUsd: Number(amount),
      description: desc,
      toWallet: wallet
    };
    const res = await executePayment(payload);
    onResult(res);
  };

  return (
    <div style={{ marginTop: 20 }}>
      <h2>发起支付</h2>

      <div>
        <label>金额（USD）</label>
        <input value={amount} onChange={(e) => setAmount(e.target.value)} />
      </div>

      <div>
        <label>描述</label>
        <input value={desc} onChange={(e) => setDesc(e.target.value)} />
      </div>

      <div>
        <label>收款钱包地址</label>
        <input value={wallet} onChange={(e) => setWallet(e.target.value)} />
      </div>

      <button onClick={submit} style={{ marginTop: 20 }}>
        发起支付
      </button>
    </div>
  );
}
