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
