# sway-config

Configurazione di [sway](https://swaywm.org) per MSI GS66 Stealth (Ubuntu 24.04).

- Pannello interno 2560x1440 @ 240 Hz, scala 1.25, VRR; LG UltraWide sopra
- Tastiera italiana, touchpad con tap e scroll naturale
- Tasti Fn per volume, microfono, luminosità e media
- Screenshot con grim/slurp e Flameshot 14

## Installazione

```bash
git clone https://github.com/antoniolch/sway-config ~/.config/sway
sudo apt install brightnessctl playerctl slurp mako-notifier wlsunset \
                 xdg-desktop-portal-wlr policykit-1-gnome cliphist
sudo usermod -aG video $USER   # necessario per la luminosità
```

Flameshot deve essere >= 13 (la 12.1 di Ubuntu non supporta la scala frazionaria):
pacchetto `.deb` dalle release di <https://github.com/flameshot-org/flameshot>.
