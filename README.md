scripts
=========

Personal scripts and such. Mostly written by me, but a couple borrowed from the internet and lots of the other ideas inspired by various folks.

## Contents

### auth_mail

Used by PAM to send an email with information when an authentication occurs

### colors

Taken from http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html, it prints out a table of colors for easy comparison.

### connection_test 

Checks if I can currently SSH into a given user/hostname. I use this for confirming I have an open connection to servers I want to SCP from in cron (really launchd) scripts.

### dnsctl

Helper script for maintaining zonefile serials and reloading NSD.

### hexip

Tiny script to take an IP in hex and spit it out as a dotted quad.

### key_sync

Takes all the \*.pub files in a directory and concatenates them into a file. I use it to load my keys repo into ~/.ssh/authorized\_keys.

### maillog

A replacement "mail" for logrotate, so that log files get dropped into a directory for further processing rather than being shipped off immediately. Used in conjunction with https://github.com/akerl/archer/blob/master/common/files/logrotate.cron and https://github.com/akerl/logpull

### mount_encfs

Ruby script to mount my EncFS volumes using info from the OSX Keychain. Details on how I do this can be found here: http://blog.akerl.org/2013/12/07/encrypted-cloud-storage.html

### repo_pull

Quick bash script to git pull on a repo. I use it for having launchd pull repo updates.

### repo_sync

Pulls updates from origin/master for any git repos inside a directory. If no directory is given, uses the current directory.

### rock_out

Quick script to pull get_hyped downloads from my server to my local iTunes.

### script_sync

Prunes dead symlinks in /usr/local/bin and puts in symlinks for any scripts in the current or specified directory.

### tunnelkill

Kills any lingering `ssh -fND` processes.

## License

All scripts except those noted internally are released under the MIT License. See the bundled LICENSE file for details.

