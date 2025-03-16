module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    // Disable rules causing problems
    "quotes": "off",
    "indent": "off",
    "linebreak-style": "off",
    "object-curly-spacing": "off",
    "max-len": "off",
    "comma-dangle": "off",
    "eol-last": "off",
    "brace-style": "off",
    "no-unused-vars": "warn",
    "require-jsdoc": "off",
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
};