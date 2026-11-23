#!/usr/bin/env bash
FLAG_FILE="$HOME/.config/.lnx_win11_applied"
[ -f "$FLAG_FILE" ] && exit 0

sleep 2

# Terapkan Tema GTK, Ikon, Font, dan Window Manager
xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent-Dark-compact" --create -t string
xfconf-query -c xsettings -p /Net/IconThemeName -s "Win11-dark" --create -t string
xfconf-query -c xsettings -p /Gtk/FontName -s "Inter 10" --create -t string
xfconf-query -c xfwm4 -p /general/theme -s "Fluent-Dark-compact" --create -t string
xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC" --create -t string

# Aktifkan tombol Windows (Super_L) untuk membuka Start Menu (Whisker Menu)
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -n -t string -s "xfce4-popup-whiskermenu"

# Konfigurasi Panel Bawah Bergaya Windows 11
xfconf-query -c xfce4-panel -p /panels -n -a -t int -s 1
xfconf-query -c xfce4-panel -p /panels/panel-1/position -n -t string -s "p=8;x=0;y=0"
xfconf-query -c xfce4-panel -p /panels/panel-1/length -n -t double -s 100
xfconf-query -c xfce4-panel -p /panels/panel-1/size -n -t int -s 44
xfconf-query -c xfce4-panel -p /panels/panel-1/position-locked -n -t bool -s true

xfconf-query -c xfce4-panel -p /plugins/plugin-1 -n -t string -s "separator"
xfconf-query -c xfce4-panel -p /plugins/plugin-1/expand -n -t bool -s true
xfconf-query -c xfce4-panel -p /plugins/plugin-1/style -n -t int -s 0

xfconf-query -c xfce4-panel -p /plugins/plugin-2 -n -t string -s "whiskermenu"

xfconf-query -c xfce4-panel -p /plugins/plugin-3 -n -t string -s "tasklist"
xfconf-query -c xfce4-panel -p /plugins/plugin-3/show-labels -n -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-3/grouping -n -t int -s 1

xfconf-query -c xfce4-panel -p /plugins/plugin-4 -n -t string -s "separator"
xfconf-query -c xfce4-panel -p /plugins/plugin-4/expand -n -t bool -s true
xfconf-query -c xfce4-panel -p /plugins/plugin-4/style -n -t int -s 0

xfconf-query -c xfce4-panel -p /plugins/plugin-5 -n -t string -s "systray"
xfconf-query -c xfce4-panel -p /plugins/plugin-6 -n -t string -s "pulseaudio"
xfconf-query -c xfce4-panel -p /plugins/plugin-7 -n -t string -s "clock"

xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -n -a \
  -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 6 -t int -s 7

xfce4-panel -r &
mkdir -p "$HOME/.config"
touch "$FLAG_FILE"
