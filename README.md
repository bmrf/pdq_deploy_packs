Vocatus' PDQ Deploy Packs
===

This repository contains all the scripts used in Vocatus' [PDQ Deploy packs](https://old.reddit.com/r/pdq/search?q=pdq+deploy+author%3Avocatus+self%3Ayes&restrict_sr=on&sort=new&t=all).

**Note! This repository contains ONLY the scripts** - you need to download the full package from the latest [Reddit thread](https://old.reddit.com/r/pdq/search?q=pdq+deploy+author%3Avocatus+self%3Ayes&restrict_sr=on&sort=new&t=all) if you want to use the packages. The Github is provided mostly to see the installation wrapper scripts in a hope they're beneficial to other sysadmins.

Please submit fixes and suggestions either in the reddit thread or here on Github.

# Instructions

0. You must be running at least version 12.2 (v12.2.0.0) of PDQ Deploy; perform a database upgrade if required.

1. Import the `.xml` file(s) from the `\job_files` directory into PDQ deploy.

2. Copy everything from the `\repository` directory to wherever your repository is. 

3. Your screen should look roughly like the [included screenshot](https://github.com/bmrf/pdq_deploy_packs/blob/master/Roughly%20what%20it%20should%20look%20like.png) of my console.


# Notes

Each release contains `checksums.txt`, which contains SHA256 hashes of every file included in the download. You can use my included PGP public key (Key ID: [0x07d1490f82a211a2](http://pool.sks-keyservers.net:11371/pks/lookup?op=get&search=0x07D1490F82A211A2)) to verify nothing has been tampered with.

v8.0 introduced an optional download, Microsoft Offline Update packages. It's not included with the main PDQ package because it's very large, and I presume most organizations use WSUS or SCCM to manage their Windows and Office updates. But if you're like me, with some non-Internet-connected computers to update, or don't have a WSUS/SCCM server, then the offline packages are very helpful.

If you download this package make sure to read the instructions that come with it, otherwise you'll run it, nothing will happen, and you'll feel silly.

# Read-only keys for Resilio Sync:

PDQ Deploy installer packages:               `BTRSRPF7Y3VWFRBG64VUDGP7WIIVNTR4Q`

Optional Microsoft Offline Update packages:  `BMHHALGV7WLNSAPIPYDP5DU3NDNSM5XNC`


# Donations

If you're feeling overly charitable, donations are accepted at these addresses:

Bitcoin: `1BqZP5i4Cor3GePNcEokjb84L3D2QEHYmY`

Monero: `4GG9KsJhwcW3zapDw62UaS71ZfFBjH9uwhc8FeyocPhUHHsuxj5zfvpZpZcZFHWpxoXD99MVt6PnR9QfftXDV8s6Hg1MJkCPytYA3r3KvR`
