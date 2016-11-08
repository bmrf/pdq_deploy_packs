Vocatus' PDQ Deploy Packs
===

This repository contains all the scripts used in Vocatus' [PDQ Deploy packs](https://www.reddit.com/r/sysadmin/comments/4jl2yb/pdq_deploy_packs_v410_20160515_aq_edition/).

Note that this repository contains ONLY the scripts - you will need to download the full package from the latest [Reddit thread](https://www.reddit.com/r/sysadmin/search?q=pdq+deploy+author%3Avocatus+self%3Ayes&restrict_sr=on&sort=new&t=all) if you want to import them and start using them. The Github is provided mostly for people to see the installation wrapper scripts in a hope they're beneficial to those who don't need the full package.

Please submit fixes and suggestions either in the reddit thread or here on Github.

# Instructions

0. You must be running at least version 3.2 release 1 (v3.2.1.0) of PDQ Deploy; perform a database upgrade if required.

1. Import the `.xml` file(s) from the `\job_files` directory into PDQ deploy.

2. Copy everything from the `\repository` directory to wherever your repository is. 

3. Your screen should look roughly like the included `.PNG` screenshot of my console.


# Notes

For each release I generate and sign `checksums.txt`, a text file containing SHA256 hashes of every file included in the download. You can use my included PGP public key (Key ID: [0x07d1490f82a211a2](http://pool.sks-keyservers.net:11371/pks/lookup?op=get&search=0x07D1490F82A211A2)) to verify nothing has been tampered with.

v8.0 introduced an optional download, Microsoft Offline Update packages. It's not included with the main PDQ package because it's very large, and I presume most organizations use WSUS or SCCM to manage their Windows and Office updates anyway. But if you're like me, with some non-Internet-connected computers to update, or don't have a WSUS/SCCM server, then the offline packages are very helpful.

If you download this package make sure to read the instructions that come with it, otherwise you'll run it, nothing will happen, and you'll feel silly.

# Read-only keys for BitTorrent Sync:

PDQ Deploy installer packages:               `BTRSRPF7Y3VWFRBG64VUDGP7WIIVNTR4Q`

Optional Microsoft Offline Update packages:  `BMHHALGV7WLNSAPIPYDP5DU3NDNSM5XNC`



If you're feeling overly charitable, bitcoin donations are accepted at this addres:

    `1BqZP5i4Cor3GePNcEokjb84L3D2QEHYmY`
