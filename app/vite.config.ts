import path from "path";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

const base = (() => {
  const value = process.env.BENCHMARKS_BASE_URL || "/";
  return value.endsWith("/") ? value : `${value}/`;
})();

export default defineConfig({
  base,
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: "../results/",
    emptyOutDir: false,
  },
});
