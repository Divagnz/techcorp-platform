module.exports = {
  extends: ['@commitlint/config-conventional', '@commitlint/config-nx-scopes'],
  rules: {
    'scope-enum': [0], // Disabled - handled by @commitlint/config-nx-scopes
  },
};
