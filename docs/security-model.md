## Overview

The LUKS Hardware Binding Framework protects access to an encrypted LUKS device by binding the decryption process to the target hardware.

Instead of relying only on a passphrase, the framework verifies a hardware-derived HMAC before automatically providing the encryption key.

## Security Model

The framework is based on three security components:

- Hardware identity
- HMAC-SHA256 verification
- Secure storage of the master key

## Hardware Authentication

During boot, the framework:

1. Reads the hardware identifier.
2. Generates an HMAC-SHA256 value.
3. Compares it with the stored HMAC.
4. Unlocks the encrypted device only if the values match.

Otherwise, the user is prompted for the LUKS passphrase.

## Key Protection

## Threat Model

## Limitations