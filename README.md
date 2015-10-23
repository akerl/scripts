scripts
=========

[![MIT Licensed](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://tldrlegal.com/license/mit-license)

Personal scripts and such. Mostly written by me, but a couple borrowed from the internet and lots of the other ideas inspired by various folks.

## Contents

### auth_mail

Used by PAM to send an email with information when an authentication occurs

### budget

Quick script to calculate budget based on a YAML file of income/expenses

### cask_upgrade

removes old cask versions and installs the latest version

### circleci_fails.rb

This lists any unsuccessful builds you have in CircleCI

### colors

Taken from http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html, it prints out a table of colors for easy comparison.

### connection_test 

Checks if I can currently SSH into a given user/hostname. I use this for confirming I have an open connection to servers I want to SCP from in cron (really launchd) scripts.

### dnsctl

Helper script for maintaining zonefile serials and reloading NSD.

### git-issue

Creates an issue in the current GitHub repo

### git-open

Taken from https://github.com/paulirish/git-open/ , this opens the current git repo on github

### github-repo-list.rb

Lists all repos you have access to on github. I used to use this to clone all my repos locally, but now use [spaarti](https://github.com/akerl/spaarti) for that

### hexip

Tiny script to take an IP in hex and spit it out as a dotted quad.

### key_sync

Takes all the \*.pub files in a directory and concatenates them into a file. I use it to load my keys repo into ~/.ssh/authorized\_keys.

### link_check

Scans $PATH for binaries and checks if they're linked against any libraries that aren't available. Output is formatted at "$ARCH_PACKAGE $BINARY $LIBRARY1 ... $LIBRARYN"

### maillog

A replacement "mail" for logrotate, so that log files get dropped into a directory for further processing rather than being shipped off immediately. Used in conjunction with https://github.com/akerl/archer/blob/master/common/files/logrotate.cron and https://github.com/akerl/logpull

### mount_encfs

Ruby script to mount my EncFS volumes using info from the OSX Keychain. Details on how I do this can be found here: http://blog.akerl.org/2013/12/07/encrypted-cloud-storage.html

### nftables

Super simple init script for nftables

### pacman-init

Loads pacman keyring

### purge_songs

Doesn't work, was intended to clean up local songs I'd synced to iTunes Match

### randquote

Pulls random quotes from [my quote lists](https://github.com/akerl/quotes)

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

### vundle_update

Hacky script for opening vim automatically and running vundle_update

### xsa_list.rb

Lists XSAs from http://xenbits.xen.org/xsa/

## License

All scripts except those noted internally are released under the MIT License. See the bundled LICENSE file for details.

