# Security Checklist

Domain reference for verify extension reviewers. Load when reviewing code that handles auth, user input, data storage, or external APIs.

## Injection

- SQL: parameterized queries, no string concatenation for queries
- XSS: output encoding, CSP headers, no raw HTML rendering with user data
- Command injection: no shell exec with user input, use argument arrays
- Path traversal: validate and normalize file paths, no user-controlled path joins

## Authentication & Authorization

- Passwords hashed with bcrypt/scrypt/argon2 (never MD5/SHA1)
- JWT: verify signature, check expiry, validate issuer and audience
- Session tokens: cryptographically random, rotated on privilege change
- Authorization checked on every request (not just UI-hidden)
- Rate limiting on auth endpoints (login, password reset, OTP)

## Data Protection

- Secrets in environment variables, never in code or config files
- PII encrypted at rest, access logged
- API responses: no over-fetching (return only requested fields)
- Error messages: no stack traces, internal paths, or DB details in production
- CORS: explicit origin allowlist, no wildcard with credentials

## Dependencies

- No known vulnerabilities (check npm audit / pip audit / cargo audit)
- Lock files committed and reviewed
- No unnecessary permissions in third-party integrations

## Transport

- HTTPS enforced (HSTS headers)
- Secure cookie flags: HttpOnly, Secure, SameSite
- API keys transmitted in headers, never in URL query params
