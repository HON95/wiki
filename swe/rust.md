---
title: Rust (Language)
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## Setup

Use Rustup, which manages your Rust installation(s), makes upgrades easy, and lets you easily install different toolchains and stuff.

## Commands

- Build and run: `cargo run`
- Build: `cargo build`
    - Builds to `target/<profile>/<name>`
- Test: `cargo test`
- Clean: `cargo clean`
    - Removes generated artefacts (the whole `target` directory by default).
- Lint (Clippy): `cargo clippy`
    - Note: Certain options (like `-D warnings`) must be placed after `--` in the command.
    - Add `[--] -D warnings` to fail on any warnings.
    - Add `[--] -A clippy::branches-sharing-code` (example) to ignore (allow) certain lints.
    - Add `--all-targets --all-features` to test all targets and all features too.

### Dependencies

- Update dependencies: `cargo update`
    - Make sure to manually update the your pinned versions in `Cargo.toml` before this.
- Show dependency graph: `cargo tree`
    - Show enabled features: `cargo tree -e features`
    - Show packages being built multiple times (duplicates): `cargo tree -d`
    - Show inverted tree for some package: `cargo tree -i <package>` (useful with e.g. `-e features`)

### Miscellanea

- Upgrade edition (e.g. from 2018 to 2021):
    1. Run `cargo fix --edition` to automatically fix your code.
    1. Change the `edition` in `config.toml` (e.g. from 2018 to 2021).
    1. Run `cargo build` or `cargo test` to verify it worked.

{% include footer.md %}
