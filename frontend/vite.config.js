import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev server proxies /api to the backend so the browser hits one origin —
// mirrors how the ALB routes /api to the app tier in AWS.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api": { target: "http://127.0.0.1:4000", changeOrigin: true },
    },
  },
});
