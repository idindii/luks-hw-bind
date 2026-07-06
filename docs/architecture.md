# Architecture

## Overview

The LUKS Hardware Binding Framework is designed as a modular security framework for Embedded Linux systems.

The framework authenticates the target hardware during the early boot process before automatically unlocking an encrypted LUKS partition.

The architecture separates hardware identification, cryptographic verification, installation, and system integration into independent modules to simplify maintenance, testing, and future extensions.

## Design Goals

The framework is designed with the following goals:

- Security first
- Modular architecture
- Hardware independence
- Production readiness
- Maintainability
- Extensibility
- Minimal external dependencies
- Portability
- Least Privilege

## High-Level Architecture

             System Boot
                  │
                  ▼
         Load initramfs
                  │
                  ▼
     Hardware Identity Module
                  │
                  ▼
          Generate HMAC
                  │
                  ▼
          Compare HMAC
          ┌──────────────┐
          │              │
        Match        No Match
          │              │
          ▼              ▼
   Unlock LUKS     Ask Passphrase
          │
          ▼
      Continue Boot

## Components

### Hardware Identity

Collects unique hardware identifiers used for authentication.

### HMAC Engine

Generates and verifies HMAC values using the secret key.

### Key Management

Handles generation and secure storage of cryptographic keys.

### Initramfs Integration

Performs authentication during the early boot process.

### Systemd Integration

Updates authentication data after hardware changes.

### Installation

Installs and configures the framework.

### Configuration

Stores project configuration parameters.

## Design Principles

Each module follows the Single Responsibility Principle.

Modules communicate through clearly defined interfaces.

Security-sensitive operations are isolated.

Platform-specific logic is isolated from security-critical components.

Cryptographic operations are centralized.

## Assumptions

The framework assumes:

- The secret key remains confidential.
- Hardware identifiers are sufficiently stable.
- The boot environment has not been compromised.
- LUKS is correctly configured.

## Scope

This framework focuses on hardware-bound authentication for automatic LUKS unlocking.

It does not replace Secure Boot, TPM, or full disk encryption mechanisms.

Instead, it complements existing Linux security features.

