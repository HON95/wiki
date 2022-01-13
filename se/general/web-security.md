---
title: Web Security
breadcrumbs:
- title: Software Engineering
- title: General
---
{% include header.md %}

## Resources

- [OWASP](https://owasp.org/)

## Vulnerabilities

### General Vulnerabilities

- Injection:
    - Examples: XSS, SQL injection, command injection, etc.
    - Solution: Sanitize all user data, use prepared statements, etc.
- Broken authentication and access control:
    - Solution: Unbreak it.
- Sensitive data exposure:
    - Solution: Fix it and add multiple layers of access control to avoid accidentally exposing sensitive data.
- XML external entities (XXE):
    - Makes poorly configured XML processors read and expose sensitive files.
    - Solution: Configure the XML processor properly and restrict access to sensitive files.
- Security misconfiguration:
    - Solution: Configure it securely.
- Insecure deserialization:
    - Serialized data is not deserialized by the server in a secure fashion, allowing adversaries to use specially crafted serialized data as an attack vector.
    - Solution: Deserialize securely (look it up).
- Using components with known vulnerabilities:
    - Solution: Avoid using unnecessary components, don't use untrusted components, and keep track of known vulnerabilities using some framework like Snyk og GitHub security alerts.
- Insufficient logging and monitoring:
    - Allows adversaries to stay undetected.
    - Solution: Add more logging, monitor the logs (typically using some framework) and respond to incidents.
- System information exposure:
    - Regards HTTP headers, server signatures, error pages and other places which may leak information about the internal system such as component versions.
    - This information is useful to adversaries as it describes the system structure and may reveal insecure components.
    - Solution: Hide server signatures, raw error messages and other info if there isn't a very good reason for users to see it.
- Brute forcing certain endpoints:
    - Especially regarding endpoints where the adversary may brute force stuff like login pages.
    - Solution: Implement throttling or lock-out mechanisms for certain endpoints.
- Weak usernames and passwords:
    - Solution: Implement simple username and password policies. Don't make them so complicated and annoying that users will have to write down their passwords in insecure places.
- Man in the middle attack (MITM):
    - Allows adversaries to sniff and modify transported data if they manage to place themselves in front of the client.
    - Solution: Use encrypted and authenticated transport, like TLS with secure ciphers and valid certificate chains. Make sure everything uses the secure channel, e.g. using HTTP Strict Transport Security (HSTS) (which should be used regardless).
- Weak cryptography:
    - Solution: Use strong cryptography. E.g. don't use 3DES, MD5, TLS 1.1 and lower etc.
- Directory traversal and file inclusion:
    - Allows adversaries to specify and include files and directories that the endpoint isn't intended to give access to. The paths are often outside the web root.
    - Solution: Sanitize user input and chroot/jail the web server to not have access to files outside the web root.
- Sensitive data is cached:
    - Sensitive data that is intended for a specific user og group of users is accidentally cached and made available to all users.
    - Solution: Fix your cache policies.
- Uploading of malicious files:
    - Solution: Handle all files securely to avoid injection, XSS, remote execution, etc. Maybe use whitelists or blacklists for file types.

### Web-Specific Vulnerabilities

- Cross-site scripting (XSS):
    - A special case of injection which targets the users' browsers.
    - Types:
        - Stored XSS: The injected script is stored presistently on the server.
        - Reflected XSS: The injected script is stored non-persistently in e.g. a URL or special form provided by the adversary.
    - Solution: Sanitize, escape or whitelist user input.
- Cross-site request forgery (CSRF):
    - Exploits user sessions, where the browser sends all cookies (containing session data) on every request, to run some unsafe action on the targeted website.
    - Typically implemented as a link, an image or a JS form on the adversary's site or some infected site where the URL targets the unsafe action on the target website.
    - Solution:
        - Don't let safe HTTP methods (GET, HEAD, OPTIONS) trigger unsafe actions. This will prevent link- and image-based CSRF, but not JS-based.
        - Use CSRF tokens (look them up) provided by the target site which must be provided with all unsafe requests, which the adversarial site would not know.
        - Prevent XSS where the adversary may get access to the CSRF token.
- Insecure cookies:
    - Cookies are set with the wrong domain scope or are missing the secure or http-only flags.
    - Solution: Fix it.
- Session fixation:
    - A form of session hijacking where the adversary chooses an arbitrary session ID and injects it into the target user's page (e.g. in the URL) such that the user's browser uses it as its session ID. When the user logs in, the server sees the existing session ID and uses it for the logged in user. The adversary can now hijack the session as they know the session ID which they self set.
    - Solution: Always change the session ID when logging in users.
- Missing session expiration:
    - The session is not invalidated on the server when the user logs out, meaning the user can instantly log back in if he or an adversary knows his old session ID.
    - Solution: Invalidate/delete the session on the server when the user logs out.
- Click-jacking:
    - A technique where an invisible iframe of the target website is layered on top of another website (either the adversary's own website or through XSS in a trusted website) and positioned such that when the user tries to click on the visible webpage, they instead click on some unsafe part of the invisible target website.
    - Solution: Use the older "X-Frame-Options" or the newer "Content-Security-Polict" (CSP) HTTP headers to disallow embedding the webpage in certain or all iframes. Also, prevent XSS.

## Mechanisms

### Headers

- Note: These are response headers unless otherwise stated.
- `X-Frame-Options`: Determines if the current page can be framed. Can prevent e.g. clickjacking. Unless the page is intended to be framed on other sites, set it to `SAMEORIGIN` or `DENY`.
- `X-Content-Type-Options`: Can prevent e.g. MINE sniffing by denying browsers to ignore the sent `Content-Type` and try to determine the content type of a document by itself, which can lead to XSS. Always set to `nosniff`.
- `X-XSS-Protection`: Determines if built-in XSS features in the browser (e.g. for detecting reflected XSS) should be enabled or disabled. The default (`1`) is to detect and sanitize unsafe parts (which could potentially be exploited). Set to `1; mode=block` to stop loading the page when detected instead.
- `Strict-Transport-Security`: See the HSTS section below.
- `Access-Control-*`: See the CORS section below.
- `Content-Security-Policy`: See the CSP section below.

### HTTP Strict Transport Security (HSTS)

**TODO**

### Cross-origin resource sharing (CORS)

**TODO**

### Content Security Policy (CSP)

**TODO**

### Cookies

- Sent with every request.
- As many and large cookies may reduce request performance, local storage should be used for general client-side storage instead.
- The session ID should be stored as a cookie and never in local storage as that would remove certain access restrictions for client scripts.
- Expiration: Cookies may specify an expiration date (or max age). If it is not specified, the cookie is considered a session cookie and will expire when the browser is closed. However, session restoring in the browser may keep it alive even after browser restarts.
- Secure flag: Cookies set with the `Secure` flag are only accessible over HTTPS connections (not HTTP). In later browser versions, HTTP connections are not allowed to set cookies with this flag.
- HTTP-only flag: Cookies set with the `HttpOnly` flag are inaccessible to client scripts and only accessible to servers.
- Scope: `Domain` specifies which domains the cookie will be sent to. If omitted, it will only be sent to the current host, excluding subdomains. If it is specified, it will include subdomains. `Path` specifies which paths the cookie will be sent to, including subdirectories. If omitted, all paths are allowed.
- Same-site: `SameSite=None` allows the cookie to be sent for both same-site and cross-site requests. `SameSite=Strict` allows sending the cookie only when the origin is the same as for the cookie. `SameSite=Lax` allows sending the cookie when the browser navigates to the site as well (meaning the origin is different). Modern browsers are migrating to defaulting to `SameSite=Lax`.

### JSON Web Token (JWT)

- Useful as single-use authorization tokens.
- Does not rely on central state but are instead self-contained.
- May not fit in cookies, but shouldn't be put in local storage either (due to missing security features).
- Stateless JWT tokens can't be invalidated, meaning they may contain stale data. They should therefore be short-lived and single-use.
- Should never be used for sessions:
    - Sessions are long-lived and must be able to be invalidated by the server.
    - Session IDs requires the security features only cookies can provide (not local storage).

## Recommendations

### Recommended Server HTTP Security Headers

- `Strict-Transport-Security max-age=63072000; includeSubDomains; preload`: Example HSTS record for 2 years, subdomains included and eligibility for being added to preload lists.
- `X-Content-Type-Options nosniff`: Disallow MIME/content sniffing and force browsers to respect the content type provided by the server.
- `X-Frame-Options DENY`: Disallow rendering this page in any kind of frame (frame, iframe, ember, object). Should not be used when the page is explicitly allowed to be rendered in frames. For modern browsers, use `Content-Security-Policy` instead.
- `X-XSS-Protection 1; mode=block`: Block page loading if XSS is detected. For modern browsers, use `Content-Security-Policy` instead.

### Miscellanea

- Block HTTP TRACE as it may give malicious client scripts access to cookies with the HTTP-only flag set.
- Session IDs should never be JWTs and should be stored in cookies (never local storage) with the secure and HTTP-only flags set.

{% include footer.md %}
