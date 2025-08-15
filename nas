#!/bin/sh

# ====== Fungsi install pakej jika belum terpasang ======
install_pkg() {
    PKG="$1"
    if opkg list-installed | grep -q "^${PKG} "; then
        echo "[SKIP] ${PKG} sudah terpasang."
        return 1  # kod 1 = skip
    else
        echo "[INSTALL] ${PKG}..."
        opkg install "$PKG"
        return 0  # kod 0 = berjaya pasang
    fi
}

# ====== Fungsi install NAS ======
install_nas() {
    MIN_SPACE=200
    echo "[INFO] Semak ruang storage sebelum pemasangan pakej NAS..."
    FREE_SPACE=$(df /overlay | awk 'NR==2 {print int($4/1024)}')  # dalam MB
    echo "[INFO] Ruang kosong: ${FREE_SPACE}MB"

    if [ "$FREE_SPACE" -lt "$MIN_SPACE" ]; then
        echo "[ERROR] Ruang tidak mencukupi untuk pemasangan pakej NAS."
        echo "[INFO] Perlukan sekurang-kurangnya ${MIN_SPACE}MB."
        echo "[SKIP] Pakej NAS tidak dipasang."
    else
        echo "[OK] Ruang mencukupi. Mula pasang pakej NAS..."
        install_pkg python3-light
        install_pkg python3-pip
        install_pkg aria2
        install_pkg ariang
        install_pkg minidlna
        # install_pkg samba4
        # install_pkg autosamba
        echo "[DONE] Pakej NAS selesai dipasang."
    fi
}

# ====== Fungsi install Network ======
install_https_dns_proxy() {
    install_pkg https-dns-proxy
}

install_adblock_fast() {
    install_pkg coreutils-sort
    install_pkg gawk
    install_pkg grep
    install_pkg sed
    install_pkg adblock-fast
}

# ====== Fungsi install Clash Converter ======
install_clash_converter() {
    if [ -f "/usr/lib/lua/luci/controller/clash_converter.lua" ]; then
        echo "[SKIP] Clash Converter sudah wujud."
    else
        echo "[INSTALL] Memasang Clash Converter..."
        wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/ClashConverter/main/Install.sh \
            && chmod +x /tmp/Install.sh \
            && sh /tmp/Install.sh
    fi
}

# ====== Fungsi install ModNssVpn ======
install_modnssvpn() {
    if [ -f "/usr/bin/modipv4.sh" ]; then
        echo "[SKIP] ModNssVpn sudah wujud."
    else
        echo "[INSTALL] Memasang ModNssVpn..."
        wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/main/Install.sh \
            && chmod +x /tmp/Install.sh \
            && sh /tmp/Install.sh
    fi
}

# ====== Mula skrip ======
# Update opkg sekali sahaja
opkg update

# Auto install NAS
install_nas

# Menu network selepas NAS
echo
echo "==============================="
echo " Pilih Pakej Network & Tambahan"
echo "==============================="

# ====== https-dns-proxy ======
if opkg list-installed | grep -q "^https-dns-proxy "; then
    echo "[SKIP] https-dns-proxy sudah terpasang."
else
    read -p "Pasang https-dns-proxy? (y/n): " ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ] && install_https_dns_proxy || echo "[SKIP] https-dns-proxy tidak dipasang."
fi

# ====== adblock-fast ======
if opkg list-installed | grep -q "^adblock-fast "; then
    echo "[SKIP] adblock-fast sudah terpasang."
else
    read -p "Pasang adblock-fast? (y/n): " ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ] && install_adblock_fast || echo "[SKIP] adblock-fast tidak dipasang."
fi

# ====== Clash Converter ======
if [ -f "/usr/lib/lua/luci/controller/clash_converter.lua" ]; then
    echo "[SKIP] Clash Converter sudah wujud."
else
    read -p "Pasang Clash Converter? (y/n): " ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ] && install_clash_converter || echo "[SKIP] Clash Converter tidak dipasang."
fi

# ====== ModNssVpn ======
if [ -f "/usr/bin/modipv4.sh" ]; then
    echo "[SKIP] ModNssVpn sudah wujud."
else
    read -p "Pasang ModNssVpn? (y/n): " ans
    [ "$ans" = "y" ] || [ "$ans" = "Y" ] && install_modnssvpn || echo "[SKIP] ModNssVpn tidak dipasang."
fi

echo "[DONE] Semua proses pemasangan selesai."
