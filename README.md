# Apache Configuration Test Fixtures

This repository contains Apache HTTP Server configuration examples and a BATS-based testing framework for validating different scenarios.

<!-- TEST-RESULTS-START -->
## Test Results (Auto-generated)

| Fixture | Status | Description |
|---------|--------|-------------|
| 01 Cache Control | ⏳ Pending | React & Angular cache headers |
| 02 Security Headers | ⏳ Pending | CSP, HSTS, X-Frame-Options |
| 03 Cache Conflict | ⏳ Pending | Documents directive conflicts |

*Run tests to update this section*
<!-- TEST-RESULTS-END -->

## Fixtures

### 01-cache-control
Proper cache header configuration for modern JavaScript frameworks:

**React (Webpack)**
- `index.html` - `no-cache, no-store, must-revalidate`
- Hashed JS/CSS files (e.g., `main.a3f2b1c.js`) - `max-age=31536000, immutable`

**Angular (CLI)**
- `index.html` - `no-cache, no-store, must-revalidate`
- Bundles with hash (main, runtime, polyfills) - `max-age=31536000, immutable`
- Assets folder - `max-age=86400` (1 day)

### 02-security-headers
Comprehensive security header configuration:
- Content-Security-Policy (CSP)
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin
- Permissions-Policy: feature restrictions
- Strict-Transport-Security (HSTS)

### 03-cache-conflict
**Intentionally misconfigured** - demonstrates how directive ordering and `always` can corrupt location-specific headers. The global `Header always set Cache-Control` overrides all carefully configured cache headers.

## Project Structure

```
.
├── fixtures/
│   ├── 01-cache-control/       # Cache control for React & Angular
│   ├── 02-security-headers/    # Security headers
│   └── 03-cache-conflict/      # Intentionally wrong config (demo)
├── test/
│   ├── helper.bash             # Shared test utilities
│   ├── 01-cache-control.bats   # Tests for fixture 01
│   ├── 02-security-headers.bats
│   └── 03-cache-conflict.bats
├── .githooks/
│   └── pre-push                # Updates README before push
└── .github/workflows/
    └── test.yml                # GitHub Actions CI
```

## Setup

### Install Git Hooks

```bash
./scripts/install-hooks.sh
```

This installs a pre-push hook that automatically runs tests and updates the README with latest results before each push.

### Run Tests Locally

Requires: [BATS](https://bats-core.readthedocs.io/) and Podman

```bash
# Run all tests
cd test
bats *.bats

# Run specific fixture
bats 01-cache-control.bats

# With TAP output
bats --tap 01-cache-control.bats
```

### Run with GitHub Actions

Tests run automatically on push/PR. See `.github/workflows/test.yml`.

## License

MIT
