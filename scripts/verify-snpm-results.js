import fs from "fs";
import path from "path";

const fixtures = ["next", "astro", "vue", "svelte", "large", "run"];
const variations = [
  "cache",
  "cache+lockfile",
  "cache+lockfile+node_modules",
  "cache+node_modules",
  "clean",
  "lockfile",
  "lockfile+node_modules",
  "node_modules",
  "run",
];

const shouldSkip = (fixture, variation) =>
  (variation === "run" && fixture !== "run") ||
  (fixture === "run" && variation !== "run");

const missing = [];

for (const fixture of fixtures) {
  for (const variation of variations) {
    if (shouldSkip(fixture, variation)) continue;

    const resultFile = path.join(
      "results",
      `results-${fixture}-${variation}`,
      "benchmarks.json",
    );

    if (!fs.existsSync(resultFile)) {
      console.warn(
        `Skipping verification for ${fixture}/${variation}: results file missing`,
      );
      continue;
    }

    try {
      const data = JSON.parse(fs.readFileSync(resultFile, "utf8"));
      const hasSnpm =
        Array.isArray(data.results) &&
        data.results.some((entry) => entry?.command === "snpm");

      if (!hasSnpm) {
        missing.push(`${fixture}/${variation}`);
      }
    } catch (error) {
      console.warn(
        `Could not parse results for ${fixture}/${variation}: ${error.message}`,
      );
      missing.push(`${fixture}/${variation}`);
    }
  }
}

if (missing.length > 0) {
  console.error(
    `snpm results missing for ${missing.length} combinations: ${missing.join(", ")}`,
  );
  process.exit(1);
}

console.log("snpm results present for all combinations with data");
