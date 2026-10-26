const js = require('@eslint/js');
const { defineConfig } = require('eslint/config');
const globals = require('globals');
const tseslint = require('typescript-eslint');

module.exports = defineConfig([
  {
    ignores: ['jest/coverage/', 'docker/volumes/', 'supabase/'],
  },
  js.configs.recommended,
  tseslint.configs.recommended,
  {
    rules: {
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
  // Root setup scripts are CommonJS and run under Node
  {
    files: ['*.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: globals.node,
    },
    rules: {
      '@typescript-eslint/no-require-imports': 'off',
    },
  },
  {
    files: ['jest/**/*.ts'],
    languageOptions: {
      globals: { ...globals.node, ...globals.jest },
    },
  },
]);
