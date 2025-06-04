module.exports = {
  root: true, // Add this to prevent ESLint from looking for config files in parent directories
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2022, // Or "latest"
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    // "quotes": ["error", "single", {"allowTemplateLiterals": true}], // If you want to enforce single quotes (Google style)
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
    },
  ],
};