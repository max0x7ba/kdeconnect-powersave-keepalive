# kdeconnect-powersave-keepalive
Increase TCP keepalive timeout for longer battery life.

KDE Connect in Plasma desktop sends TCP keepalive messages every 5 seconds after connection has idled for 10 seconds, which drains paired phone battery at faster rate. https://bugs.kde.org/show_bug.cgi?id=441830

This workaround makes KDE Connect TCP keepalive timeout configurable. The default is set to 9 minutes.

Example of KDE Connect TCP keepalive messages:

```
05:09:30.783016 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544842155 ecr 2754153561], length 0
05:09:30.816512 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754153594 ecr 2544842156], length 0
05:09:41.018310 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544852390 ecr 2754153594], length 0
05:09:41.062820 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754163840 ecr 2544842156], length 0
05:09:51.258606 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544862631 ecr 2754163840], length 0
05:09:51.304018 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754174082 ecr 2544842156], length 0
05:10:01.498581 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544872871 ecr 2754174082], length 0
05:10:02.019323 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754182723 ecr 2544842156], length 0
05:10:12.250315 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544883622 ecr 2754182723], length 0
05:10:17.370580 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544888743 ecr 2754182723], length 0
05:10:17.383432 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754184063 ecr 2544842156], length 0
05:10:27.610478 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544898983 ecr 2754184063], length 0
05:10:32.730605 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544904103 ecr 2754184063], length 0
05:10:33.353527 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754185414 ecr 2544842156], length 0
05:10:43.482308 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544914854 ecr 2754185414], length 0
05:10:48.602579 IP workstation.32990 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2544919975 ecr 2754185414], length 0
05:10:48.650261 IP OnePlus-7T-Pro.1716 > workstation.32990: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2754190695 ecr 2544842156], length 0
```

Example of KDE Connect TCP keepalive messages with the workaround installed:
```
05:35:15.633953 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 1449, win 176, options [nop,nop,TS val 2755026524 ecr 2546387004], length 0
05:35:15.634148 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 2062, win 181, options [nop,nop,TS val 2755026524 ecr 2546387004], length 0
05:35:15.671758 IP workstation.33000 > OnePlus-7T-Pro.1716: Flags [.], ack 121, win 83, options [nop,nop,TS val 2546387044 ecr 2755026562], length 0
05:35:15.695753 IP workstation.33000 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2546387068 ecr 2755026586], length 0
05:35:15.731208 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2755026621 ecr 2546387068], length 0
05:44:34.586547 IP workstation.33000 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2546945959 ecr 2755026621], length 0
05:44:34.733266 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 3480, win 187, options [nop,nop,TS val 2755514995 ecr 2546387068], length 0
05:46:12.656676 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 4807, win 204, options [nop,nop,TS val 2755526826 ecr 2547043949], length 0
05:55:13.562665 IP workstation.33000 > OnePlus-7T-Pro.1716: Flags [.], ack 1285, win 83, options [nop,nop,TS val 2547584935 ecr 2755526826], length 0
05:55:13.648939 IP OnePlus-7T-Pro.1716 > workstation.33000: Flags [.], ack 4807, win 204, options [nop,nop,TS val 2755710185 ecr 2547043949], length 0

```

# Usage
The workaround patches `kdeconnectd` ELF object to make it load the shared library built from this code. Using `sudo` command may be necessary to install and uninstall.

## Clone, build and test
```
$ git clone git@github.com:max0x7ba/kdeconnect-powersave-keepalive.git
$ cd kdeconnect-powersave-keepalive
$ make
```

## Install
```
$ sudo make install
```

## Status
```
$ make status
```

## Uninstall
```
$ sudo make uninstall
```

---
Copyright (c) 2022 Maxim Egorushkin. MIT License. See the full licence in file LICENSE.
