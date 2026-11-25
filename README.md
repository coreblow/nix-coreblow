# Nix CoreBlow

Deterministic Nix packaging and flake derivation for CoreBlow Sovereign Agent-OS & Desktop Studio.

## Overview

Nix CoreBlow is part of the CoreBlow public repository family. It provides fully reproducible, hermetic Nix derivations for CoreBlow CLI and CoreBlow Studio on Linux (`x86_64`, `aarch64`) and macOS (`x86_64-darwin`, `aarch64-darwin`).

This repository follows the same ecosystem split that CoreBlow uses to keep release surfaces small, auditable, and independently governed.

## Repository Role

- Status: Active
- Phase: 5
- Priority: distribution
- Kind: nix
- Family: CoreBlow public repository family
- Branding: CoreBlow

## Features

- **Deterministic Derivation**: Pinned directly to the official CoreBlow v2.2.0 release tarball with verified SHA-256 checksum (`109b18526aa8fb50ff34a046f8023c08cfa236fa9a64a577924d9be4e3bb0a07`).
- **Zero Dynamic Wrappers**: Replaces unpinned runtime wrappers with a native Node 22 wrapped binary entrypoint.
- **Darwin Platform Guarding**: Guards macOS CoreBlow Studio packaging with graceful fallback notifications for head builds.
- **Multi-Architecture Flake**: Supports `aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, and `x86_64-linux`.

## Usage

### Run with Nix

```sh
# Run CoreBlow CLI directly via flake
nix run github:coreblow/nix-coreblow -- --help

# Enter reproducible development shell
nix develop github:coreblow/nix-coreblow
```

### Install into Profile

```sh
nix profile install github:coreblow/nix-coreblow
```

## Development & Verification

### Test / Check

```sh
# Verify flake derivation structure, version, and checksums
npm test

# If Nix is installed locally:
nix flake check
```

## Release Policy

Do not publish packages, tags, installers, or release artifacts from this repository without explicit CoreBlow release approval.

Version changes must follow the coordinated CoreBlow release plan.

## Links

- [CoreBlow](https://github.com/coreblow/coreblow)
- [Documentation](https://docs.coreblow.com)
- [Website](https://coreblow.com)
- [Security Policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
