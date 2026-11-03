# sway-config

Configurazione di [sway](https://swaywm.org) per MSI GS66 Stealth (Ubuntu 24.04).

- Monitor gestiti da [kanshi](https://sr.ht/~emersion/kanshi/) (`kanshi.conf`): profili riconosciuti dal modello del monitor
  - MSI GS66: 2560x1440 @ 240 Hz, scala 1.25; LG UltraWide sopra
  - su altri PC nessun profilo corrisponde e sway usa le impostazioni predefinite
- Tastiera italiana, touchpad con tap e scroll naturale
- Tasti Fn per volume, microfono, luminosità e media
- Screenshot con grim/slurp e Flameshot 14
- Waybar (`waybar/`) con icone Font Awesome 4.7 e colori Catppuccin

## Installazione

```bash
git clone https://github.com/antoniolch/sway-config ~/.config/sway
sudo apt install brightnessctl playerctl slurp mako-notifier wlsunset \
                 xdg-desktop-portal-wlr policykit-1-gnome cliphist kanshi blueman
sudo usermod -aG video $USER   # necessario per la luminosità
ln -sfn ~/.config/sway/waybar ~/.config/waybar   # config di Waybar
```

Flameshot deve essere >= 13 (la 12.1 di Ubuntu non supporta la scala frazionaria):
pacchetto `.deb` dalle release di <https://github.com/flameshot-org/flameshot>.

## Usarlo su un altro PC

Tutto il `config` è indipendente dall'hardware. Per i monitor aggiungi un profilo a `kanshi.conf`
usando i nomi restituiti da:

```bash
swaymsg -t get_outputs | jq -r '.[] | "\(.make) \(.model) \(.serial)"'
```
