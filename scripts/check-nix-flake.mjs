import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..");
const flakePath = path.join(repoRoot, "flake.nix");

console.log("=== Validating CoreBlow Nix Flake Derivation ===");

assert.ok(fs.existsSync(flakePath), "flake.nix must exist");
const flakeContent = fs.readFileSync(flakePath, "utf8");

// 1. Version checks
console.log("1. Checking version alignment...");
assert.match(flakeContent, /version\s*=\s*"2\.1\.5"/, "flake.nix must pin canonical version 2.1.5");
assert.doesNotMatch(flakeContent, /"2\.0\.0"/, "Old 2.0.0 version must be removed");

// 2. Deterministic source URL and hash
console.log("2. Checking deterministic pinned tarball source and SHA-256...");
const expectedUrl = "https://registry.npmjs.org/coreblow/-/coreblow-${version}.tgz";
const expectedSha256 = "2c42a123582aa86e2b2282d4f0453d8422389a77cd65e81afdcc08ace893eea5";

assert.ok(flakeContent.includes(expectedUrl), `flake.nix must reference pinned URL: ${expectedUrl}`);
assert.ok(flakeContent.includes(expectedSha256), `flake.nix must pin SHA-256: ${expectedSha256}`);
assert.doesNotMatch(flakeContent, /coreblow@latest/, "Unpinned @latest wrapper must be removed");
assert.doesNotMatch(flakeContent, /npx\s+-y/, "npx dynamic execution wrapper must be removed");

// 3. Platform guards and app packaging
console.log("3. Checking Darwin platform guards and fallback messaging...");
assert.ok(flakeContent.includes("isDarwin"), "Darwin platform check must be present");
assert.ok(flakeContent.includes("platforms.darwin"), "coreblow-studio must target darwin platform");

// 4. Balanced brackets/braces syntax sanity
console.log("4. Checking Nix syntax structural balance...");
let braces = 0;
let parens = 0;
let brackets = 0;
for (const char of flakeContent) {
  if (char === "{") braces++;
  if (char === "}") braces--;
  if (char === "(") parens++;
  if (char === ")") parens--;
  if (char === "[") brackets++;
  if (char === "]") brackets--;
}
assert.equal(braces, 0, "Mismatched curly braces in flake.nix");
assert.equal(parens, 0, "Mismatched parentheses in flake.nix");
assert.equal(brackets, 0, "Mismatched square brackets in flake.nix");

// 5. Brand sovereignty & zero home directory paths
console.log("5. Checking brand sovereignty and path hygiene...");
assert.doesNotMatch(flakeContent, /\/Users\/|\/home\/(?!node)/, "No hardcoded local home paths allowed");
assert.doesNotMatch(flakeContent, /openclaw|clawhub|claw/i, "No competitor or legacy names allowed");

console.log("✅ CoreBlow Nix flake derivation verified successfully.");
