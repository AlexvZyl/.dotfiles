# Bluetooth Quick Connect

This extension allows paired Bluetooth devices to be connected and
disconnected via the GNOME system menu, without need to enter the
Settings app every time.

## Installation

### Requirements

 * bluez (on ubuntu: `sudo apt install bluez`)

### Installation from extensions.gnome.org

https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/

### Installation from source code

```
git clone https://github.com/bjarosze/gnome-bluetooth-quick-connect
cd gnome-bluetooth-quick-connect
make
rm -rf ~/.local/share/gnome-shell/extensions/bluetooth-quick-connect@bjarosze.gmail.com
mkdir -p ~/.local/share/gnome-shell/extensions/bluetooth-quick-connect@bjarosze.gmail.com
cp -r * ~/.local/share/gnome-shell/extensions/bluetooth-quick-connect@bjarosze.gmail.com
```

## Battery level

Headset battery (currently) requires enabling experimental features in bluez.
See https://github.com/bjarosze/gnome-bluetooth-quick-connect/pull/42 for more details.

## Troubleshooting

### Connecting and disconnecting does not work

This extensions calls `bluetoothctl` under the hood. If something does not work 
you can try to execute `bluetoothctl` command in terminal and see what is wrong.

#### Paired devices
```bash
bluetoothctl -- paired-devices
```

#### Connecting
```bash
bluetoothctl -- connect <mac address>
```

#### Disconnecting
```bash
bluetoothctl -- disconnect <mac address>
```

#### Reconnecting
```bash
bluetoothctl -- disconnect <mac> && sleep 7 && bluetoothctl -- connect <mac>
```

### Reconnecting does not work

Not sure why, but sometimes bluetoothctl does not want to connect 
device after it was disconnected. Reinstalling bluez and rebooting system helped on my ubuntu.
```
$ sudo apt purge bluez gnome-bluetooth pulseaudio-module-bluetooth
$ sudo apt install bluez gnome-bluetooth pulseaudio-module-bluetooth
```