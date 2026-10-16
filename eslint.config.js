const js = require("@eslint/js");
const globals = require("globals");

module.exports = [
  // Ignore downloaded libraries and test reports
  { ignores: ["node_modules/", "coverage/"] },

  // Start from ESLint's recommended rules
  js.configs.recommended,

  // Our code runs in Node.js, and tests use Jest
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: { ...globals.node, ...globals.jest },
    },
  },
];
