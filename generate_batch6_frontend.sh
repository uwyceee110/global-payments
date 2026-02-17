#!/bin/bash
set -e

echo "🚀 启动批次 6：frontend 生成脚本..."

###############################################
# 0. 检查是否在 global-payments 根目录
###############################################
CURRENT_DIR_NAME=$(basename "$PWD")

if [ "$CURRENT_DIR_NAME" != "global-payments" ]; then
  echo "❌ 错误：当前目录不是 global-payments，而是：$CURRENT_DIR_NAME"
  echo "👉 请先进入 global-payments 目录再运行脚本。"
  exit 1
fi

echo "📁 已确认：当前目录为 global-payments（根目录正确）"

###############################################
# 1. 创建 frontend 目录
###############################################
echo "📦 创建 frontend 目录..."

mkdir -p frontend/src/components

###############################################
# 2. 写入 package.json
###############################################
echo "📄 写入 package.json..."

cat > frontend/package.json << 'EOF'
{
  "name": "global-payments-frontend",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "axios": "^1.6.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0"
  }
}
EOF

###############################################
# 3. 写入 vite.config.js
###############################################
echo "📄 写入 vite.config.js..."

cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()]
})
EOF

###############################################
# 4. 写入 index.html
###############################################
echo "📄 写入 index.html..."

cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Global Payments</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/App.jsx"></script>
  </body>
</html>
EOF

###############################################
# 5. 写入 src/api.js
###############################################
echo "📄 写入 api.js..."

cat > frontend/src/api.js << 'EOF'
import axios from "axios";

const ORCHESTRATION_BASE = "http://localhost:8080/orchestration";

export const executePayment = async (payload) => {
  const res = await axios.post(`${ORCHESTRATION_BASE}/execute`, payload);
  return res.data.data;
};
EOF

###############################################
# 6. 写入 App.jsx
###############################################
echo "📄 写入 App.jsx..."

cat > frontend/src/App.jsx << 'EOF'
import React, { useState } from "react";
import PaymentForm from "./components/PaymentForm";
import ResultPanel from "./components/ResultPanel";

export default function App() {
  const [result, setResult] = useState(null);

  return (
    <div style={{ padding: 40 }}>
      <h1>Global Payments</h1>
      <PaymentForm onResult={setResult} />
      {result && <ResultPanel result={result} />}
    </div>
  );
}
EOF

###############################################
# 7. 写入 PaymentForm.jsx
###############################################
echo "📄 写入 PaymentForm.jsx..."

cat > frontend/src/components/PaymentForm.jsx << 'EOF'
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
EOF

###############################################
# 8. 写入 ResultPanel.jsx
###############################################
echo "📄 写入 ResultPanel.jsx..."

cat > frontend/src/components/ResultPanel.jsx << 'EOF'
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
EOF

###############################################
# 9. Git 提交
###############################################
echo "📦 Git add..."
git add .

echo "📝 Git commit..."
git commit -m "Add Batch 6: frontend module" || echo "ℹ️ 无需提交"

echo "🎉 批次 6：frontend 已生成完成！"
