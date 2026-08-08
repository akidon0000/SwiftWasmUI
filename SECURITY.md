# Security Policy

SwiftWasmUI is a client-side UI framework — it runs entirely in the browser and does
not talk to any server by itself. A security bug here is most likely an XSS-style
issue in how user data reaches the DOM.

## Supported versions

| Version | Supported |
|---|---|
| Latest `main` | ✅ |
| Anything older | ❌ — upgrade first |

## Reporting a vulnerability

**Please don't open a public issue.** Use GitHub's private reporting instead:

**[→ Report a vulnerability](https://github.com/akidon0000/SwiftWasmUI/security/advisories/new)**
(also reachable from the repo's **Security** tab)

Include what you have: a minimal view tree that triggers the issue, what an attacker
gains, and any patch or mitigation you already found.

This is a small side project, so expect an acknowledgement within about a week rather
than within hours. You'll be credited in the advisory unless you'd rather not be.
