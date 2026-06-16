#!/bin/bash

LOGFILE="Alathry-Optimize-Network.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===== $(date '+%Y-%m-%d %H:%M:%S') - Automated Network Optimization Script for Arch Linux ====="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

install_pkg_arch() {
  local pkg_name=$1
  local is_critical=${2:-false}

  if ! pacman -Q "$pkg_name" &>/dev/null; then
    echo -e "${BLUE}INFO:${NC} Package '$pkg_name' is not installed. Attempting installation..."
    if sudo pacman -S --noconfirm "$pkg_name"; then
      echo -e "${GREEN}SUCCESS:${NC} Installed package '$pkg_name'."
      return 0
    else
      echo -e "${RED}ERROR:${NC} Failed to install package '$pkg_name'. Please check your connection and repositories."
      if [[ "$is_critical" == "true" ]]; then
        echo -e "${RED}FATAL:${NC} Essential package missing. Exiting."
        exit 1
      else
        echo -e "${YELLOW}WARNING:${NC} Optional package. Proceeding without it..."
        return 1
      fi
    fi
  fi
  return 0
}

get_hardware_specs() {
    echo -e "${BLUE}INFO:${NC} Checking hardware specifications..."
    CPU_CORES=$(nproc 2>/dev/null)
    if [[ -z "$CPU_CORES" || ! "$CPU_CORES" =~ ^[0-9]+$ || "$CPU_CORES" -eq 0 ]]; then
        echo -e "${YELLOW}WARNING:${NC} Could not determine CPU core count. Defaulting optimizations to 1 core."
        CPU_CORES=1
    else
        echo -e "${GREEN}SUCCESS:${NC} Detected CPU cores: ${YELLOW}$CPU_CORES${NC}"
    fi
}

get_network_info() {
  echo -e "${BLUE}INFO:${NC} Finding the default network interface..."
  IFACE=$(ip -o -4 route show to default | awk '{print $5}')
  if [[ -z "$IFACE" ]]; then
    echo -e "${RED}FATAL:${NC} No active network interface found. Please connect to the internet."
    exit 1
  fi
  echo -e "${GREEN}SUCCESS:${NC} Active interface: ${YELLOW}$IFACE${NC}"

  echo -e "${BLUE}INFO:${NC} Detecting network driver..."
  DRIVER_PATH=$(readlink -f /sys/class/net/$IFACE/device/driver)
  if [[ -n "$DRIVER_PATH" ]]; then
      DRIVER=$(basename "$DRIVER_PATH")
  else
      install_pkg_arch "pciutils" false
      DRIVER=$(lspci -k -s $(ethtool -i $IFACE | grep bus-info | awk '{print $2}') 2>/dev/null | grep 'Kernel driver in use:' | awk '{print $NF}')
  fi

  if [[ -n "$DRIVER" ]]; then
    echo -e "${GREEN}SUCCESS:${NC} Driver detected: ${YELLOW}$DRIVER${NC}"
  else
    echo -e "${YELLOW}WARNING:${NC} Could not auto-detect network driver. Some driver-specific tweaks will be skipped."
    DRIVER=""
 fi
}

apply_optimizations() {
  echo -e "${BLUE}--- Applying Network Optimizations ---${NC}"

  echo -e "${BLUE}[1/12] INFO:${NC} Disabling Wi-Fi Power Saving in NetworkManager..."
  sudo mkdir -p /etc/NetworkManager/conf.d
  if ! sudo tee /etc/NetworkManager/conf.d/99-wifi-powersave-off.conf >/dev/null <<EOF
[connection]
wifi.powersave = 2
EOF
  then
    echo -e "${YELLOW}WARNING:${NC} Failed to create NetworkManager configuration file."
  else
    echo -e "${BLUE}INFO:${NC} Restarting NetworkManager..."
    if ! sudo systemctl restart NetworkManager; then
      echo -e "${YELLOW}WARNING:${NC} Failed to restart NetworkManager. Changes will apply after a manual reboot."
    else
       echo -e "${GREEN}SUCCESS:${NC} Wi-Fi Power Saving disabled and NetworkManager restarted."
    fi
  fi

  echo -e "${BLUE}[2/12] INFO:${NC} Optimizing Maximum Transmission Unit (MTU)..."
  if ! sudo ip link set "$IFACE" mtu 1400; then
     current_mtu=$(ip link show "$IFACE" | grep -o 'mtu [0-9]*' | awk '{print $2}')
     if [[ "$current_mtu" == "1400" ]]; then
        echo -e "${GREEN}SUCCESS:${NC} MTU is already set to 1400."
     else
        echo -e "${YELLOW}WARNING:${NC} Failed to modify MTU. Current value: $current_mtu."
     fi
  else
    echo -e "${GREEN}SUCCESS:${NC} MTU optimized to 1400."
  fi

  echo -e "${BLUE}[3/12] INFO:${NC} Adjusting RX/TX Ring Buffer limits..."
  local max_rx max_tx current_rx current_tx
  if ethtool_output=$(ethtool -g "$IFACE" 2>/dev/null); then
      max_rx=$(echo "$ethtool_output" | grep -i 'RX:' -A 2 | grep 'Pre-set maximums:' | awk '{print $NF}')
      max_tx=$(echo "$ethtool_output" | grep -i 'TX:' -A 2 | grep 'Pre-set maximums:' | awk '{print $NF}')
      current_rx=$(echo "$ethtool_output" | grep -i 'RX:' -A 1 | grep 'Current hardware settings:' | awk '{print $NF}')
      current_tx=$(echo "$ethtool_output" | grep -i 'TX:' -A 1 | grep 'Current hardware settings:' | awk '{print $NF}')

      if [[ -n "$max_rx" && -n "$max_tx" && "$max_rx" -gt 0 && "$max_tx" -gt 0 ]]; then
        echo -e "${BLUE}INFO:${NC} Hardware Max RX: $max_rx, TX: $max_tx. Current RX: $current_rx, TX: $current_tx."
        if [[ "$current_rx" == "$max_rx" && "$current_tx" == "$max_tx" ]]; then
            echo -e "${GREEN}SUCCESS:${NC} Ring buffers are already at maximum hardware capacity."
        else
            echo -e "${BLUE}INFO:${NC} Setting RX/TX buffers to maximum..."
            if ! sudo ethtool -G "$IFACE" rx "$max_rx" tx "$max_tx"; then
              exit_code=$?
              if [[ $exit_code -eq 75 ]]; then
                 echo -e "${YELLOW}WARNING:${NC} Values exceed device limits. Buffers left unchanged."
              elif [[ $exit_code -eq 22 ]]; then
                 echo -e "${YELLOW}WARNING:${NC} Invalid arguments or unsupported by interface. Buffers left unchanged."
              else
                 echo -e "${YELLOW}WARNING:${NC} Failed to maximize buffers (Error code: $exit_code)."
              fi
            else
              echo -e "${GREEN}SUCCESS:${NC} Ring buffers maximized to $max_rx/$max_tx."
            fi
        fi
      else
        echo -e "${YELLOW}WARNING:${NC} Could not determine hardware ring buffer limits. Skipping."
      fi
  else
      echo -e "${YELLOW}WARNING:${NC} Ethtool failed to fetch ring buffer data. Skipping."
  fi

  echo -e "${BLUE}[4/12] INFO:${NC} Enabling Network Offloading features (TSO, GSO, GRO)..."
  if ! sudo ethtool -K "$IFACE" tso on gso on gro on; then
    echo -e "${YELLOW}WARNING:${NC} Some offloading features might not be supported by your hardware."
  else
    echo -e "${GREEN}SUCCESS:${NC} TSO, GSO, and GRO offloading enabled."
  fi

  echo -e "${BLUE}[5/12] INFO:${NC} Adjusting Transmit Queue Length (txqueuelen)..."
  if ! sudo ip link set dev "$IFACE" txqueuelen 2000; then
    echo -e "${YELLOW}WARNING:${NC} Failed to adjust txqueuelen."
  else
    echo -e "${GREEN}SUCCESS:${NC} Transmit Queue Length increased to 2000."
  fi

  echo -e "${BLUE}[6/12] INFO:${NC} Configuring Receive Packet Steering (RPS) for $CPU_CORES cores..."
  rps_path="/sys/class/net/$IFACE/queues/rx-0/rps_cpus"
  if [ -f "$rps_path" ]; then
      local cores_to_use=$(( CPU_CORES < 64 ? CPU_CORES : 64 ))
      local rps_mask_dec=$(( (1 << cores_to_use) - 1 ))
      local rps_mask_hex=$(printf '%x' "$rps_mask_dec")

      if [[ -n "$rps_mask_hex" && "$rps_mask_hex" != "0" ]]; then
         echo -e "${BLUE}INFO:${NC} Using CPU mask $rps_mask_hex for RPS optimization."
         if ! echo "$rps_mask_hex" | sudo tee "$rps_path" >/dev/null; then
           echo -e "${YELLOW}WARNING:${NC} Failed to write CPU mask to rps_cpus."
         else
           echo -e "${GREEN}SUCCESS:${NC} RPS successfully configured."
         fi
      else
         echo -e "${YELLOW}WARNING:${NC} CPU mask calculation failed."
      fi
  else
      echo -e "${BLUE}INFO:${NC} RPS is not available for $IFACE. Skipping."
  fi

  echo -e "${BLUE}[7/12] INFO:${NC} Adjusting Interrupt Coalescing..."
  if sudo ethtool -c "$IFACE" 2>/dev/null | grep -qi 'Coalesce'; then
    if ! sudo ethtool -C "$IFACE" rx-usecs 5 tx-usecs 5; then
      exit_code=$?
       if [[ $exit_code -eq 22 ]]; then
          echo -e "${YELLOW}WARNING:${NC} Coalesce values are invalid or unsupported. Skipping."
       elif [[ $exit_code -eq 95 ]]; then
          echo -e "${YELLOW}WARNING:${NC} Coalesce configuration not supported by this interface."
       else
          echo -e "${YELLOW}WARNING:${NC} Failed to set Coalesce values (Error code: $exit_code)."
       fi
    else
       echo -e "${GREEN}SUCCESS:${NC} Interrupt Coalescing latency reduced."
    fi
  else
    echo -e "${BLUE}INFO:${NC} Interface does not support Interrupt Coalescing. Skipping."
  fi

  if [[ -n "$DRIVER" ]]; then
      echo -e "${BLUE}[8/12] INFO:${NC} Disabling power saving on kernel driver ($DRIVER)..."
      if ! sudo modprobe -r "$DRIVER" && sudo modprobe "$DRIVER" power_save=0; then
          sudo modprobe -r "$DRIVER" 2>/dev/null
          if ! sudo modprobe "$DRIVER" power_save=0 2>/dev/null; then
              echo -e "${YELLOW}WARNING:${NC} Driver does not support power_save=0 option. Reloading with default parameters..."
              if ! sudo modprobe "$DRIVER" 2>/dev/null; then
                 echo -e "${RED}ERROR:${NC} Failed to reload driver safely."
              fi
          else
              echo -e "${GREEN}SUCCESS:${NC} Driver reloaded with power saving disabled."
          fi
      else
           echo -e "${GREEN}SUCCESS:${NC} Driver reloaded with power saving disabled."
      fi
  else
      echo -e "${BLUE}[8/12] INFO:${NC} Driver undetected. Skipping driver power options."
  fi

  echo -e "${BLUE}[9/12] INFO:${NC} Applying optimized sysctl network parameters..."
  sudo mkdir -p /etc/sysctl.d
  if ! sudo tee /etc/sysctl.d/99-net-optimize.conf >/dev/null <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_fastopen=3
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 65536 33554432
net.core.netdev_max_backlog=5000
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_ecn=1
net.core.rps_sock_flow_entries=32768
EOF
  then
      echo -e "${RED}ERROR:${NC} Failed to create sysctl configuration file."
  else
      if ! sudo sysctl --system; then
        echo -e "${RED}ERROR:${NC} Failed to apply sysctl parameters."
      else
        echo -e "${GREEN}SUCCESS:${NC} Sysctl parameters successfully applied."
      fi
  fi

  echo -e "${BLUE}[10/12] INFO:${NC} Configuring systemd-resolved DNS settings..."
  sudo mkdir -p /etc/systemd/resolved.conf.d
  if ! sudo tee /etc/systemd/resolved.conf.d/99-dns-optimize.conf >/dev/null <<EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=1.0.0.1 8.8.4.4
DNSSEC=no
Cache=yes
EOF
  then
    echo -e "${RED}ERROR:${NC} Failed to write systemd-resolved configuration."
  else
    if ! sudo systemctl restart systemd-resolved; then
      echo -e "${RED}ERROR:${NC} Failed to restart systemd-resolved. Service might be inactive or missing."
    else
      sudo systemd-resolve --flush-caches 2>/dev/null || true
      echo -e "${GREEN}SUCCESS:${NC} DNS servers configured and cache flushed."
    fi
  fi

  echo -e "${BLUE}[11/12] INFO:${NC} Managing irqbalance service..."
  if [[ "$CPU_CORES" -gt 1 ]]; then
      if install_pkg_arch "irqbalance" false; then
          if systemctl list-unit-files | grep -q irqbalance.service; then
              if ! sudo systemctl enable --now irqbalance; then
                  if systemctl is-active --quiet irqbalance; then
                     echo -e "${GREEN}SUCCESS:${NC} irqbalance service is already active."
                  else
                     echo -e "${YELLOW}WARNING:${NC} Failed to start irqbalance service."
                  fi
              else
                  echo -e "${GREEN}SUCCESS:${NC} irqbalance service enabled and started."
              fi
          else
              echo -e "${YELLOW}WARNING:${NC} Service file missing after installation. Skipping."
          fi
      fi
  else
      echo -e "${BLUE}INFO:${NC} Single-core CPU detected. irqbalance is unnecessary. Skipping."
  fi

  echo -e "${BLUE}[12/12] INFO:${NC} Running optional network speed test..."
  if install_pkg_arch "speedtest-cli" false; then
       if ! command -v speedtest-cli >/dev/null; then
           echo -e "${YELLOW}WARNING:${NC} speedtest-cli execution failed. Skipping test."
       else
           if ! speedtest-cli --secure; then
             echo -e "${YELLOW}WARNING:${NC} Speed test interrupted."
           else
             echo -e "${GREEN}SUCCESS:${NC} Speed test completed successfully."
           fi
       fi
  fi

  echo -e "${GREEN}--- ✅ Network Optimizations Complete ---${NC}"
}

revert_optimizations() {
  echo -e "${BLUE}--- Reverting Network Settings to Default ---${NC}"

  echo -e "${BLUE}[1/10] INFO:${NC} Resetting MTU to default (1500)..."
  sudo ip link set "$IFACE" mtu 1500 || echo -e "${YELLOW}WARNING:${NC} Failed to reset MTU."

  echo -e "${BLUE}[2/10] INFO:${NC} Resetting RX/TX ring buffers to default (256)..."
  sudo ethtool -G "$IFACE" rx 256 tx 256 || echo -e "${YELLOW}WARNING:${NC} Failed to reset ring buffers."

  echo -e "${BLUE}[3/10] INFO:${NC} Disabling network offloading..."
  sudo ethtool -K "$IFACE" tso off gso off gro off || echo -e "${YELLOW}WARNING:${NC} Failed to disable offloading."

  echo -e "${BLUE}[4/10] INFO:${NC} Resetting Transmit Queue Length to default (1000)..."
  sudo ip link set dev "$IFACE" txqueuelen 1000 || echo -e "${YELLOW}WARNING:${NC} Failed to reset txqueuelen."

  echo -e "${BLUE}[5/10] INFO:${NC} Disabling RPS..."
  rps_path="/sys/class/net/$IFACE/queues/rx-0/rps_cpus"
  if [ -f "$rps_path" ]; then
      echo 0 | sudo tee "$rps_path" >/dev/null || echo -e "${YELLOW}WARNING:${NC} Failed to disable RPS."
  fi

  echo -e "${BLUE}[6/10] INFO:${NC} Resetting Coalesce configuration..."
  if sudo ethtool -c "$IFACE" 2>/dev/null | grep -qi 'Coalesce'; then
      sudo ethtool -C "$IFACE" rx-usecs 0 tx-usecs 0 || echo -e "${YELLOW}WARNING:${NC} Failed to reset Coalesce values."
  fi

  echo -e "${BLUE}[7/10] INFO:${NC} Removing custom sysctl rules..."
  sudo rm -f /etc/sysctl.d/99-net-optimize.conf
  sudo sysctl --system || echo -e "${YELLOW}WARNING:${NC} Failed to reload default sysctl rules."

  echo -e "${BLUE}[8/10] INFO:${NC} Removing custom DNS configurations..."
  sudo rm -f /etc/systemd/resolved.conf.d/99-dns-optimize.conf
  sudo systemctl restart systemd-resolved || echo -e "${YELLOW}WARNING:${NC} Failed to restart systemd-resolved."
  sudo systemd-resolve --flush-caches 2>/dev/null || true

  echo -e "${BLUE}[9/10] INFO:${NC} Stopping and disabling irqbalance..."
   if pacman -Q irqbalance &>/dev/null; then
       if systemctl list-unit-files | grep -q irqbalance.service; then
           sudo systemctl disable --now irqbalance 2>/dev/null || echo -e "${YELLOW}WARNING:${NC} Failed to stop irqbalance."
       fi
   fi

  if [[ -n "$DRIVER" ]]; then
      echo -e "${BLUE}[10/10] INFO:${NC} Reloading interface driver ($DRIVER) with defaults..."
      sudo modprobe -r "$DRIVER" 2>/dev/null
      sudo modprobe "$DRIVER" 2>/dev/null || echo -e "${YELLOW}WARNING:${NC} Failed to reload driver."
  fi

  echo -e "${BLUE}INFO:${NC} Removing Wi-Fi power saving configs..."
  sudo rm -f /etc/NetworkManager/conf.d/99-wifi-powersave-off.conf
  sudo systemctl restart NetworkManager || echo -e "${YELLOW}WARNING:${NC} Failed to restart NetworkManager."

  echo -e "${GREEN}--- ✅ Reversion to Defaults Complete ---${NC}"
}


if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR:${NC} This script must be run with root privileges (sudo)."
   exit 1
fi

echo -e "${BLUE}INFO:${NC} Verifying required tools..."
install_pkg_arch "iproute2" true
install_pkg_arch "ethtool" true
install_pkg_arch "procps-ng" false

get_hardware_specs
get_network_info

action="apply"
if [[ "$1" == "--reverse" ]]; then
  action="revert"
fi
echo -e "${BLUE}INFO:${NC} Operation mode: ${YELLOW}$action${NC}"

if [[ "$action" == "apply" ]]; then
  apply_optimizations
elif [[ "$action" == "revert" ]]; then
  revert_optimizations
else
  echo -e "${RED}ERROR:${NC} Unknown mode '$action'. Use '--reverse' to revert or run without arguments to apply."
  exit 1
fi

echo "===== Finished: $(date '+%Y-%m-%d %H:%M:%S') ====="
exit 0
