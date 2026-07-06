# LUKS Hardware Binding Framework

> Secure hardware-bound automatic LUKS unlocking for Embedded Linux systems using HMAC-based device authentication.

---

**Project Status**

Under Active Development

Current Version: **v0.1.0**

License: **MIT**

Target Platform:
- Embedded Linux
- Raspberry Pi
- Debian-based Systems

## Overview

LUKS Hardware Binding Framework is an open-source security framework designed for Embedded Linux systems.

The framework allows encrypted Linux systems to unlock automatically **only when running on authorized hardware**.

Instead of exposing encryption keys or storing hardware identifiers in plain text, the framework validates the device identity using an HMAC-based authentication mechanism during the early boot process.

This approach improves production usability while preserving disk encryption security.

## Why this project?

Traditional LUKS deployments require entering a passphrase on every boot.

While secure, this approach introduces several challenges in production environments:

- Operators must know the encryption password.
- Password sharing increases security risks.
- Automated manufacturing becomes difficult.
- Devices cannot boot unattended.

This framework removes those limitations by binding encrypted storage to a specific hardware device while preserving the security guarantees provided by LUKS.

## Features

- Automatic LUKS unlocking on authorized hardware
- Hardware-bound authentication
- HMAC-based hardware verification
- Automatic initramfs integration
- systemd-based HMAC update service
- Protection against SD card cloning
- Embedded Linux focused architecture
- Raspberry Pi compatible
- Production-ready deployment model
- Modular design

## Supported Platforms

| Platform | Status |
|----------|--------|
| Raspberry Pi 4 | ✅ Tested |
| Raspberry Pi 5 | Planned |
| Debian | ✅ |
| Ubuntu | Planned |
| Generic Embedded Linux | Planned |

## Roadmap

- [x] Hardware binding using CPU Serial
- [x] HMAC authentication
- [x] initramfs integration
- [x] systemd integration
- [ ] TPM support
- [ ] Secure Boot integration
- [ ] Hardware abstraction layer
- [ ] Multi-platform support

## Contributing

Contributions are welcome.

Please open an issue before submitting major changes.

## License

This project is licensed under the MIT License.