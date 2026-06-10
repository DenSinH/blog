---
title: "Homelab - Installing Proxmox, settings and troubleshooting"
date: 2025-10-26
categories: 
  - "homelabbing"
---

My homelab runs on Proxmox, which was easy to set up, is very easy to work with, but gave me some trouble sometimes nontheless. I wanted to just leave this here for future reference, or it may be useful to others.

## Installing from USB

Since my hardware didn't like booting from a bootable USB with the Proxmox ISO created with Rufus, I had to take another route. I followed [this advice from a Reddit comment](https://www.reddit.com/r/intelnuc/comments/1bx2yf3/comment/l2p13zk/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button). I had never heard of Ventoy before this, but I am really loving it, it has come in useful multiple times. Basically, it is easier to create a bootable USB with Ventoy, and drop ISOs on there. On Windows, just download Ventoy, run Ventoy2Disk and install it on a USB.

**Note:** I had to install it with GPT format instead of MBR to get it to work, but it has never failed me ever since.

### Leftover signatures on disk

If there are leftover signatures on the disk you are trying to install proxmox on, the installer will stop. You will have to boot into a Linux shell (e.g. through your Ventoy USB!) and then find your disk device name with `lsblk` or `blkid`, and then run

```
sudo wipefs -fa /dev/sdX
```

replacing `sdX` with the disk you are trying to install Proxmox on.

## Post-install

There are various settings you might want to configure for power saving or performance, but here is what I did.

### Reducing SSD wear

I read a lot online that Proxmox can really wear out your SSD quickly if you do not alter some settings and use ramdisks for certain tasks / logging. I mainly followed instructions from [this Reddit comment](https://www.reddit.com/r/Proxmox/comments/1j4ehgq/comment/mg9y8ze/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button). Run the following to disable some write-heavy services (though it seemed `pvesr.timer` did not exist):

```bash
  systemctl stop pve-ha-crm
  systemctl stop pvesr.timer
  systemctl stop corosync.service
  
  systemctl disable pve-ha-lrm
  systemctl disable pve-ha-crm
  systemctl disable pvesr.timer
  systemctl disable corosync.service
```

- Enable `WRITE_TIMEOUT=3600` in `/etc/defaults/rrdcached` config file to reduce disk IOPS.

- Disable `JOURNAL_PATH=/var/lib/rrdcached/journal/` in `/etc/defaults/rrdcached` config file to reduce disk IOPS. (comment the line)

- Added `"${FLUSH_TIMEOUT:+-f ${FLUSH_TIMEOUT}} "` to `/etc/init.d/rrdcached`

- Install `[log2ram](https://github.com/azlux/log2ram)` and make sure `rsync` is installed (reboot after installing!)

- Mount `/tmp` to a ramdisk by adding the following to `/etc/fstab` and run `mount -a` to create a 1GB ramdisk for `/tmp` which only uses up RAM as it is being filled. You can check if it worked by running `df -h /tmp`

```
tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,mode=1777,size=1G 0 0
```

### Helper scripts

I ran the `install-post.sh` script from [this repo](https://github.com/extremeshok/xshok-proxmox) ([mirror on my own GitHub](https://github.com/DenSinH/xshok-proxmox)). There may be more post-install helper scripts (for example in Tteck's helper scripts), but I didn't run any others.

### Power saving stuff

You can do some stuff outside of Proxmox by changing some power saving settings in your BIOS (F2 on boot for Intel NUCs), but I also followed advice from [this forum thread](https://forum.proxmox.com/threads/turn-off-proxmox-primary-monitor.120769/):

#### Terminal sleep after timeout

Create and edit the script file: `nano /root/down_monitor.sh` and add the following lines:

```bash
    #!/bin/bash
    setterm -term linux -blank 1 -powersave powerdown -powerdown 1 </dev/tty1 >/dev/tty1
```

Then we need to enable the script with:

- `chmod +x /root/down_monitor.sh`

- run `crontab -e`, select your favorite editor and add a line `@reboot /root/down_monitor.sh`

- Run `bash /root/down_monitor.sh` to enable it for this session.

I also followed another tip from that thread:

- `nano /etc/default/grub`

- Replace `GRUB_CMDLINE_LINUX_DEFAULT="quiet"` with `GRUB_CMDLINE_LINUX_DEFAULT="quiet consoleblank=60"`

- Run `update-grub`

- Reboot

#### PowerTOP on boot

Run the following command to create a systemd service that runs `powertop --auto-tune` on boot:

```bash
cat << EOF | tee /etc/systemd/system/powertop.service
[Unit]
Description=powertop auto-tune

[Service]
Type=oneshot
Environment="TERM=dumb"
RemainAfterExit=true
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable powertop.service
```

#### Setting CPU governer to 'powersave'

Check what cpu governors are available with

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

You will likely get results like `performance`, `powersave` and maybe even `dynamic` or `ondemand`. You can set all core's CPU governer to `powersave` with

```bash
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Installing services

In general, I can really recommend the [Proxmox VE Helper Scripts](https://community-scripts.github.io/ProxmoxVE/). They automatically set up (most) of the LXCs you might want. Some caveats:

#### IP DHCP Configuration

Most helper scripts set the IP to DHCP by default. You may want to reconfigure the IP to a static one in the LXC / VM settings, and/or set the IP in your router's configuration (or whatever DHCP server you use).

#### Home Assistant ZigBee dongle passthrough

I followed [this tutorial](https://smarthomescene.com/guides/how-to-passthrough-usb-devices-to-home-assistant-in-proxmox/) for it. If you do it properly, it should detect the USB device even if it is connected to another port. Basically, in Proxmox, in your VM settings in Hardware, click "Add", then "USB Device" and select "Use Vendor/Device ID". Select your device and click add.

#### Tailscale in Proxmox LXC

Installing Tailscale on a proxmox LXC is fairly easy. Edit `/etc/pve/lxc/<id>.conf` and add the following 2 lines:

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

The install tailscale as usual for a Linux host (by running the following)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Then run `tailscale up` as it suggests (or add additional options to this command) and follow the link to add it to your tailnet.

## Troubleshooting

#### Network issues with Intel NUCs

At some point, I started having issues with my network. Since my pihole runs as an LXC, DNS would become unavailable and our entire home internet would break. The pihole was also configured as DNS server in my VPN (Tailscale), so internet would break even when away from home! It is therefore important to make sure your Proxmox host _always_ has a stable internet connection. This is the reason why I also decided to disable tailscale on my Proxmox host. The strange thing was, I wasn't even able to ping (even local!) IP addresses directly from my Proxmox host or any LXCs. It turns out there was something going on with the NIC of my Intel NUC. When shutting down, it started printing error messages:

```
e1000e 0000:00:19.0 enp0s25: Detected Hardware Unit Hang:
  THD                  <88>
  TDT                  <a7>
  next_to_use          <a7>
  next_to_clean        <88>
buffer_into[next_to_clean]:
  time_stamp           <102252f3c>
  next_to_watch        <89>
  jiffies              <104ca3900>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3800>
PHY Extended Status    <3000>
PCI Status             <10>
```

It turns out, [this is a known issue with a published workaround](https://www.reddit.com/r/Proxmox/comments/1drs89s/intel_nic_e1000e_hardware_unit_hang/). The solution was quite simple in the end (even though I tried a _lot_ of things, including chaning power settings for the network card, messing around with tailscale a _lot_). Simply include this in your `/etc/network/interfaces` config (replace `enp0s25` for the name of your NIC, which you can just deduce from the existing file contents):

```
iface enp0s25 inet manual
    post-up ethtool -K enp0s25 tso off gso off
```

and for your current session, you may want to just run `post-up ethtool -K enp0s25 tso off gso off`

#### Permission denied when adding TrueNAS NFS share

A simple fix is to simply go to the share, click "Advanced Options" and set "Mapall User" to "root".

#### CTs / VMs / Storage showing up as "unknown"

In this case, most likely the `pvestatd` service failed. Check the logs. Mine looked like this:

```
Dec 02 11:48:28 proxmox1 pvestatd[1056]: storage status update error: Can't use an undefined value as a subroutine reference at /usr/share/perl5/PVE/Status/InfluxDB.pm line 153.
Dec 02 11:48:38 proxmox1 pvestatd[1056]: storage status update error: Can't use an undefined value as a subroutine reference at /usr/share/perl5/PVE/Status/InfluxDB.pm line 153.
< many times >
Dec 02 11:51:19 proxmox1 pvestatd[1056]: storage status update error: Can't use an undefined value as a subroutine reference at /usr/share/perl5/PVE/Status/InfluxDB.pm line 153.
Dec 02 11:51:28 proxmox1 pvestatd[1056]: storage status update error: Can't use an undefined value as a subroutine reference at /usr/share/perl5/PVE/Status/InfluxDB.pm line 153.
Dec 02 11:51:29 proxmox1 pvestatd[1056]: auth key pair too old, rotating..
Dec 02 11:51:29 proxmox1 systemd[1]: pvestatd.service: Main process exited, code=killed, status=11/SEGV
Dec 02 11:51:29 proxmox1 systemd[1]: pvestatd.service: Failed with result 'signal'.
```

You can restart the service, though it may crash again later. It seems there is a forum thread about it [here](https://forum.proxmox.com/threads/pvestatd-crashes-every-few-days.165597/). A temporary hack is the following:

```bash
systemctl edit pvestatd.service
```

Then in the part of the file you can edit, enter

```toml
[Service]
Restart=on-failure
```

Save and exit and run

```bash
systemctl daemon-reload
```

This will make sure the pvestatd service will restart if it ever crashes.

#### Setting VMID range

To get the next VM ID, run

```bash
pvesh get /cluster/nextid
```

To set the range, run

```bash
pvesh set /cluster/options -next-id lower=300,upper=399
```

You can get the next VM ID to check that the range is properly configured now.
