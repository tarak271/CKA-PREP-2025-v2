#!/bin/bash
# Idempotent helpers — skip safely when resources are already removed.

if [[ -z "${CKA_SAFE_OPS_LOADED:-}" ]]; then
  CKA_SAFE_OPS_LOADED=1

  safe_note() {
    echo "  ℹ $*"
  }

  safe_run() {
    local hint="$1"
    shift
    if "$@" &>/dev/null; then
      return 0
    fi
    safe_note "skipped ($hint)"
    return 0
  }

  safe_systemctl() {
    local action="$1"
    shift
    local unit
    for unit in "$@"; do
      if sudo systemctl cat "$unit" &>/dev/null; then
        if ! sudo systemctl "$action" "$unit" &>/dev/null; then
          safe_note "systemctl $action $unit — no effect"
        fi
      else
        safe_note "$unit not loaded, skipping $action"
      fi
    done
  }

  safe_apt_purge() {
    local pkg="$1"
    if dpkg -l "$pkg" 2>/dev/null | awk '{print $1}' | grep -qE '^(ii|rc)$'; then
      sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "$pkg" &>/dev/null || \
        safe_note "$pkg purge had no effect"
    else
      safe_note "$pkg not installed, skipping purge"
    fi
  }

  safe_dpkg_remove() {
    local pkg="$1"
    if dpkg -l "$pkg" 2>/dev/null | awk '{print $1}' | grep -q '^ii'; then
      sudo dpkg -r "$pkg" &>/dev/null || safe_note "$pkg remove had no effect"
    else
      safe_note "$pkg not installed, skipping remove"
    fi
  }

  safe_rm() {
    local path
    for path in "$@"; do
      if [[ -e "$path" ]]; then
        sudo rm -rf "$path" 2>/dev/null || rm -rf "$path" 2>/dev/null || \
          safe_note "could not remove $path"
      fi
    done
  }

  cleanup_cri_docker() {
    echo "=== Cleaning cri-dockerd (if present) ==="
    safe_systemctl stop cri-docker.socket cri-docker.service cri-docker
    safe_systemctl disable cri-docker.socket cri-docker.service cri-docker
    safe_apt_purge cri-dockerd
    safe_dpkg_remove cri-dockerd
    safe_rm /var/run/cri-dockerd.sock \
      /etc/systemd/system/cri-docker.service \
      /etc/systemd/system/cri-docker.socket
    safe_run "daemon-reload" sudo systemctl daemon-reload
    safe_run "reset-failed" sudo systemctl reset-failed
    safe_rm /etc/sysctl.d/kube.conf
    safe_run "sysctl reload" sudo sysctl --system
    safe_rm "${HOME}/cri-dockerd.deb" /root/cri-dockerd.deb
  }

  safe_ip_link_delete() {
    local iface="$1"
    if ip link show "$iface" &>/dev/null; then
      sudo ip link set "$iface" down 2>/dev/null || true
      sudo ip link delete "$iface" 2>/dev/null || safe_note "$iface delete had no effect"
    else
      safe_note "$iface not present, skipping"
    fi
  }

  safe_iptables_flush() {
    safe_run "iptables flush" sudo iptables -F
    safe_run "iptables nat flush" sudo iptables -t nat -F
    safe_run "iptables mangle flush" sudo iptables -t mangle -F
    safe_run "iptables delete chains" sudo iptables -X
  }

fi
