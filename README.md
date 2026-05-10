# mutable-devcontainer

A VS Code Dev Container for hacking on [Mutable Instruments](https://github.com/pichenettes/eurorack) Eurorack module firmware. Works on macOS (including Apple Silicon via Rosetta), Linux, and Windows + WSL2.

The container provides the full toolchain — ARM GCC 4.8 (the original Mutable Instruments version), AVR tools, OpenOCD, GDB, Python — and clones the [pichenettes/eurorack](https://github.com/pichenettes/eurorack) source on first start.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (on Apple Silicon, enable **Rosetta** in Settings → General).
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.
- [OpenOCD](https://openocd.org/) installed on the **host** (only required for flashing). On macOS: `brew install open-ocd`.
- An ST-Link V2 (or compatible) connected to the host, with the SWD/JTAG header wired to the module.

## Quick start

1. Clone this repo and open it in VS Code.
2. When prompted, **Reopen in Container** (or run `Dev Containers: Reopen in Container` from the command palette). First build takes a few minutes — it downloads the ARM toolchain and clones the eurorack source.
3. Inside the container, compile any module, e.g. Marbles:

   ```bash
   cd eurorack-modules
   make -f marbles/bootloader/makefile hex
   make -f marbles/makefile
   ```

## Flashing

Docker Desktop on macOS cannot pass USB devices into containers, so OpenOCD runs on the **host** and the container talks to it over TCP.

1. In a **host** terminal (not the container):

   ```bash
   ./start_openocd_host.sh
   ```

   Leave it running. It exposes the GDB server on `localhost:3333`, which the container reaches as `host.docker.internal:3333`.

2. In a **container** terminal:

   ```bash
   cd eurorack-modules
   make -f marbles/makefile upload
   ```

   The container is pre-configured with `PGM_INTERFACE=stlink-v2` and `PGM_INTERFACE_TYPE=hla`, and `OPENOCD_HOST=host.docker.internal`.

## Debugging (Cortex-Debug)

The container installs the Cortex-Debug extension. Create `.vscode/launch.json` in the eurorack-modules folder:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach (Marbles)",
      "type": "cortex-debug",
      "request": "attach",
      "cwd": "${workspaceFolder}/eurorack-modules",
      "executable": "build/marbles/marbles.elf",
      "servertype": "external",
      "gdbTarget": "host.docker.internal:3333",
      "gdbPath": "gdb-multiarch",
      "device": "STM32F405RG"
    }
  ]
}
```

Manual GDB also works:

```bash
arm-none-eabi-gdb build/marbles/marbles.elf \
  -ex "target remote host.docker.internal:3333"
```

## Customizing the eurorack source

By default the container clones [pichenettes/eurorack](https://github.com/pichenettes/eurorack) into `eurorack-modules/`. To use your own fork, set `USER_GITHUB_URL` before the first container build:

```jsonc
// .devcontainer/devcontainer.json
"remoteEnv": {
  "USER_GITHUB_URL": "https://github.com/<you>/eurorack.git"
}
```

The bootstrap script clones that URL on first start and leaves the upstream repo untouched.

## Programmer / target overrides

The Mutable Instruments makefiles read environment variables for programmer selection (see [stmlib/makefile.inc](https://github.com/pichenettes/stmlib/blob/master/makefile.inc)). To change the default:

```bash
export PGM_INTERFACE=ftdi/olimex-arm-usb-tiny-h
export PGM_INTERFACE_TYPE=ftdi
make -f braids/makefile upload
```

For AVR modules:

```bash
export PROGRAMMER=stk500
export PROGRAMMER_PORT=/dev/ttyUSB0
```

## Layout

- `.devcontainer/Dockerfile` — toolchain image (ARM GCC 4.8, AVR tools, OpenOCD, Python 2 + 3, etc.).
- `.devcontainer/devcontainer.json` — VS Code dev container config; preselects extensions and sets `OPENOCD_HOST`.
- `scripts/bootstrap.sh` — runs once at container create; clones the eurorack source.
- `start_openocd_host.sh` — convenience launcher for host-side OpenOCD against ST-Link V2.

## Credits

- [pichenettes/eurorack](https://github.com/pichenettes/eurorack) — the Mutable Instruments module firmware itself, by Émilie Gillet. This repo only packages tooling around it.
- [mqtthiqs/mutable-dev-environment](https://github.com/mqtthiqs/mutable-dev-environment) — the Vagrant-based dev environment this repo replaces.
- Adafruit's [ARM-toolchain-vagrant](https://github.com/adafruit/ARM-toolchain-vagrant) and Novation's [launchpad-pro](https://github.com/dvhdr/launchpad-pro) — earlier inspirations for the upstream Vagrant setup.

## License

MIT — see [LICENSE](LICENSE).
