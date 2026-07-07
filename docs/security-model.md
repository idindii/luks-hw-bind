## Security Model

The framework is based on three security components:

- Hardware identity
- HMAC-SHA256 verification
- Secure storage of the master key

## Overview

The LUKS Hardware Binding Framework protects access to an encrypted LUKS device by binding the decryption process to the target hardware.

Instead of relying only on a passphrase, the framework verifies a hardware-derived HMAC before automatically providing the encryption key.

## Hardware Authentication

During boot, the framework:

1. Reads the hardware identifier.
2. Generates an HMAC-SHA256 value.
3. Compares it with the stored HMAC.
4. Unlocks the encrypted device only if the values match.

Otherwise, the user is prompted for the LUKS passphrase.

## Key Protection

The LUKS master key is stored with restricted file permissions and is only used after successful hardware authentication.

## Threat Model

The framework is designed to protect against:

- Storage device theft
- Hardware replacement
- Unauthorized automatic unlocking

It is not intended to protect against a fully compromised operating system or privileged attackers.

## Limitations

The framework assumes that:

- The secret used to generate the HMAC remains confidential.
- The hardware identifier is stable.
- The boot environment is trusted.

This project complements existing Linux security mechanisms and does not replace Secure Boot or TPM-based solutions.