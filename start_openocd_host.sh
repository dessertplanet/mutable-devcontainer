#!/usr/bin/env bash
# start_openocd_host.sh — Run OpenOCD on the macOS host for ST-Link V2.
#
# The devcontainer cannot access USB devices directly (Docker Desktop
# limitation on macOS).  Instead, run this script on the host to start
# OpenOCD; the container connects to it via host.docker.internal.
set -euo pipefail

usage() {
  cat <<'EOF'
Start host-side OpenOCD for ST-Link V2 + STM32F4 (Marbles), for use with
the devcontainer.

Usage:
  ./start_openocd_host.sh [options] [-- <extra-openocd-args...>]

Options:
  --interface <cfg>     OpenOCD interface cfg (default: interface/stlink-v2.cfg)
  --target <cfg>        OpenOCD target cfg    (default: target/stm32f4x.cfg)
  --speed <khz>         Adapter speed in kHz  (default: 4000)
  --gdb-port <port>     GDB port              (default: 3333)
  --telnet-port <port>  Telnet port           (default: 4444)
  --tcl-port <port>     TCL port              (default: 6666)

Environment (equivalent defaults):
  OPENOCD_INTERFACE_CFG, OPENOCD_TARGET_CFG, OPENOCD_ADAPTER_SPEED,
  OPENOCD_GDB_PORT, OPENOCD_TELNET_PORT, OPENOCD_TCL_PORT

Prerequisites:
  brew install open-ocd

Examples:
  ./start_openocd_host.sh
  ./start_openocd_host.sh --speed 2000
  ./start_openocd_host.sh --interface interface/stlink.cfg
  ./start_openocd_host.sh -- --log_output openocd.log

Then from inside the container:
  make -f marbles/makefile upload_combo_jtag
  # or manually:
  arm-none-eabi-gdb -ex "target remote host.docker.internal:3333" build/marbles/marbles.elf
EOF
}

if ! command -v openocd >/dev/null 2>&1; then
  echo "Error: openocd not found on PATH." >&2
  echo "Install it with:  brew install open-ocd" >&2
  exit 127
fi

interface_cfg="${OPENOCD_INTERFACE_CFG:-interface/stlink-v2.cfg}"
target_cfg="${OPENOCD_TARGET_CFG:-target/stm32f4x.cfg}"
adapter_speed="${OPENOCD_ADAPTER_SPEED:-4000}"
gdb_port="${OPENOCD_GDB_PORT:-3333}"
telnet_port="${OPENOCD_TELNET_PORT:-4444}"
tcl_port="${OPENOCD_TCL_PORT:-6666}"

extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --interface)
      interface_cfg="$2"; shift 2
      ;;
    --target)
      target_cfg="$2"; shift 2
      ;;
    --speed)
      adapter_speed="$2"; shift 2
      ;;
    --gdb-port)
      gdb_port="$2"; shift 2
      ;;
    --telnet-port)
      telnet_port="$2"; shift 2
      ;;
    --tcl-port)
      tcl_port="$2"; shift 2
      ;;
    --)
      shift
      extra_args+=("$@")
      break
      ;;
    *)
      extra_args+=("$1")
      shift
      ;;
  esac
done

echo "Starting OpenOCD (host) for ST-Link V2..."
echo "  interface:   $interface_cfg"
echo "  target:      $target_cfg"
echo "  speed (kHz): $adapter_speed"
echo "  gdb_port:    $gdb_port"
echo "  telnet_port: $telnet_port"
echo "  tcl_port:    $tcl_port"

if [[ ${#extra_args[@]} -gt 0 ]]; then
  exec openocd \
    -f "$interface_cfg" \
    -f "$target_cfg" \
    -c "adapter speed $adapter_speed" \
    -c "gdb_port $gdb_port" \
    -c "telnet_port $telnet_port" \
    -c "tcl_port $tcl_port" \
    "${extra_args[@]}"
else
  exec openocd \
    -f "$interface_cfg" \
    -f "$target_cfg" \
    -c "adapter speed $adapter_speed" \
    -c "gdb_port $gdb_port" \
    -c "telnet_port $telnet_port" \
    -c "tcl_port $tcl_port"
fi
