module.exports = {
  env: {
    node: true,
    browser: true,
    es6: true
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 12,
    sourceType: 'module'
  },
  rules: {
    'react/prop-types': ['off'],
    'no-prototype-builtins': ['off'],
    'no-unused-vars': ['error', {
      argsIgnorePattern: '^_'
    }],
    'import/no-anonymous-default-export': ['off'],
  },
  overrides: [{
    files: ['**/*.ts', '**/*.tsx'],
    parser: '@typescript-eslint/parser',
    extends: ['eslint:recommended'],
    parserOptions: {
      project: './tsconfig.json'
    },
    plugins: ['@typescript-eslint'],
    rules: {
      'no-unused-vars': ['error', {
        argsIgnorePattern: '^_'
      }],
    }
  }]
};
