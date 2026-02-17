import axios from "axios";

const ORCHESTRATION_BASE = "http://localhost:8080/orchestration";

export const executePayment = async (payload) => {
  const res = await axios.post(`${ORCHESTRATION_BASE}/execute`, payload);
  return res.data.data;
};
