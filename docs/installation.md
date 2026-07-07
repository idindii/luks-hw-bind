# Installation Guide

## Overview

This document explains how to install the LUKS Hardware Binding Framework on a Linux system.

## Requirements

Before installing the framework, ensure the target system provides:

- Linux
- initramfs-tools
- cryptsetup
- OpenSSL
- GCC
- GNU Make

## Build

Clone the repository:

```bash
git clone https://github.com/idindii/luks-hw-bind.git
cd luks-hw-bind
```

Build the project on the target Linux system:

```bash
make
```

## Installation

Run the installation script as root:

```bash
sudo ./scripts/install.sh
```

The installation script performs the following tasks:

- Creates the installation directory
- Builds the HMAC verification utility
- Installs the required project files
- Generates the master key
- Generates the expected hardware HMAC
- Configures the LUKS keyscript
- Rebuilds the initramfs image

## Verification

After the installation is complete, verify that the following files exist:

- `/root/luks/hmac_check`
- `/root/luks/hmac_getkey.sh`
- `/root/luks/master.key`
- `/root/luks/expected_hmac`

You can also verify that the initramfs image has been rebuilt successfully.

## Uninstallation

To remove the framework:

- Delete the `/root/luks` directory.
- Remove the initramfs hook.
- Restore the original `/etc/crypttab` configuration.
- Rebuild the initramfs image.