---
title: CUDA
breadcrumbs:
- title: Software Engineering
- title: Languages & Platforms
---
{% include header.md %}

## Useful Commands

- Update dependencies (all modules): `go get -d -u ./...`
    - `-u` to upgrade minor or patch versions of dependencies in `go.mod`.
    - `-d` to download only, not build or install anything.
    - Indirect dependencies are pinned.
- Cleanup dependencies: `go mod tidy`
    - Unused dependencies are removed from `go.mod`.
- Lint (using `golint`): `golint ./...`
- Build: `go build -o <binary> <main-file>`

{% include footer.md %}
