---
title: Vagrant VMのディスクサイズを後から拡張する方法
date: 2014-04-24
tags: Vagrant
---

## 前提条件
Vagrant BoxがファイルシステムにLVM + ext3/4を使っていること。今回はVagrantbox.esで配布されているDebian Wheezyを利用した。

## 仮想ディスクを拡張する
VMDK形式だとサイズを変更することが出来ないのでVDI形式に変換する必要がある。リサイズが完了したらVirtualBoxのVMの設定画面でHDDをVDIのほうに差し替えておく。

```
$ cd ~/VirtualBox\ VMs/vagrant_default_xxxxx_xxxxx
$ VBoxManage clonehd box-disk1.vmdk box-disk1.vdi --format VDI
$ VBoxManage modifyhd box-disk1.vdi --resize 20480
```

## パーティションテーブルを変更する
ここからはゲスト側での操作。

fdiskで/dev/sdaの容量が増えている事を確認する。

```
$ sudo fdisk -l

Disk /dev/sda: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders, total 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000e1fac

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048      499711      248832   83  Linux
/dev/sda2          501758    20764671    10131457    5  Extended
/dev/sda5          501760    20764671    10131456   8e  Linux LVM
```

/dev/sda2と/dev/sda5の情報を一度削除して再定義する。

```
$ sudo fdisk /dev/sda

Command (m for help): d
Partition number (1-5): 5

Command (m for help): d
Partition number (1-5): 2

Command (m for help): n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): e
Partition number (1-4, default 2):
First sector (499712-41943039, default 499712):
Using default value 499712
Last sector, +sectors or +size{K,M,G} (499712-41943039, default 41943039):
Using default value 41943039

Command (m for help): n
Partition type:
   p   primary (1 primary, 1 extended, 2 free)
   l   logical (numbered from 5)
Select (default p): l
Adding logical partition 5
First sector (501760-41943039, default 501760):
Using default value 501760
Last sector, +sectors or +size{K,M,G} (501760-41943039, default 41943039):
Using default value 41943039
```

再定義できているか確認する。

```
Command (m for help): p

Disk /dev/sda: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders, total 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000e1fac

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048      499711      248832   83  Linux
/dev/sda2          499712    41943039    20721664    5  Extended
/dev/sda5          501760    41943039    20720640   83  Linux
```

/dev/sda5をLinux LVMに変更する。

```
Command (m for help): t
Partition number (1-5): 5
Hex code (type L to list codes): 8e
Changed system type of partition 5 to 8e (Linux LVM)

Command (m for help): p

Disk /dev/sda: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders, total 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000e1fac

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048      499711      248832   83  Linux
/dev/sda2          499712    41943039    20721664    5  Extended
/dev/sda5          501760    41943039    20720640   8e  Linux LVM
```

変更を保存するして再起動する。

```
Command (m for help): wq
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.

$ sudo shutdown -r now
```

## LVMの設定をする

pvresizeで物理ボリューム /dev/sda5 をリサイズする。pvscanでちゃんと容量が増えていることを確認する。

```
$ sudo pvresize /dev/sda5
  Physical volume "/dev/sda5" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized

$ sudo pvscan
  PV /dev/sda5   VG debian-7   lvm2 [19.76 GiB / 10.10 GiB free]
  Total: 1 [19.76 GiB] / in use: 1 [19.76 GiB] / in no VG: 0 [0   ]
```

次に論理ボリュームをリサイズする。論理ボリューム名はlvscanで確認できる。

```
$ sudo lvscan
  ACTIVE            '/dev/debian-7/root' [9.21 GiB] inherit
  ACTIVE            '/dev/debian-7/swap_1' [456.00 MiB] inherit

$ sudo lvresize -l +100%FREE /dev/debian-7/root
  Extending logical volume root to 19.31 GiB
  Logical volume root successfully resized
```

再度lvscanで容量が増えているか確認する。

```
$ sudo lvscan
  ACTIVE            '/dev/debian-7/root' [19.31 GiB] inherit
  ACTIVE            '/dev/debian-7/swap_1' [456.00 MiB] inherit
```

## ファイルシステムをリサイズする

resize2fsを使ってファイルシステムをリサイズする。

```
$ sudo resize2fs /dev/debian-7/root
resize2fs 1.42.5 (29-Jul-2012)
Filesystem at /dev/debian-7/root is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
Performing an on-line resize of /dev/debian-7/root to 5062656 (4k) blocks.
The filesystem on /dev/debian-7/root is now 5062656 blocks long.
```

dfで容量が増えていれば完了！

```
$ df
Filesystem                 1K-blocks    Used Available Use% Mounted on
rootfs                      19932432 7272316  11649560  39% /
```

## 参考

- [How to resize a VirtualBox vmdk file - Stack Overflow](http://stackoverflow.com/questions/11659005/how-to-resize-a-virtualbox-vmdk-file)
- [virtualbox - How can I increase disk size on a Vagrant VM? - Ask Ubuntu](http://askubuntu.com/questions/317338/how-can-i-increase-disk-size-on-a-vagrant-vm)
- [論理ボリュームの管理](https://access.redhat.com/site/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/LV.html)
