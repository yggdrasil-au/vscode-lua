import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
    eslint.configs.recommended,
    ...tseslint.configs.recommended,
    {
        ignores: ["out/", "dist/", "**/*.d.ts"],
    },
    {
        files: ["**/*.ts", "**/*.tsx"],
        rules: {
            // --- CRITICAL: Keep as Errors ---
            "eqeqeq": "error",
            "default-case": "error",
            "default-case-last": "error",
            "@typescript-eslint/no-unused-expressions": "error",

            // --- NON-CRITICAL: Downgraded to Warnings ---
            "semi": ["warn", "always"],
            "prefer-const": "warn",
            "no-duplicate-imports": "warn",
            "no-prototype-builtins": "warn",

            // These can be noisy during development, so warning is usually better
            "@typescript-eslint/no-explicit-any": "warn",

            // --- DISABLED ---
            "@typescript-eslint/no-namespace": "off",
            "linebreak-style": "off",
        },
    }
);