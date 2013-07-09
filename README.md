scripts
=========

Personal scripts and such. Mostly written by me, but a couple borrowed from the internet and lots of the other ideas inspired by various folks.

## Contents

### colortest

Taken from http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html, it prints out a table of colors for easy comparison.

### dnsctl

Helper script for maintaining zonefile serials and reloading NSD.

### genca / gencert / signcert

Hacky scripts for simplifying management of a CA certificate and its children. May or may not get a revamp, depending on whether or not I find a less crappy way to manage certificates.

### hexip

Tiny script to take an IP in hex and spit it out as a dotted quad.

### keysRefresh

Takes all the \*.pub files in a directory and concatenates them into a file. I use it to load my keys repo into ~/.ssh/authorized\_keys.

### maillog

A replacement "mail" for logrotate, so that log files get dropped into a directory for further processing rather than being shipped off immediately. Used in conjunction with https://github.com/akerl/archer/blob/master/common/files/logrotate.cron and https://github.com/akerl/logpull

### pwgen

Yet another random password generator. Probably not really cryptographically secure.

### repoRefresh

Pulls updates from origin/master for any git repos inside a directory. If no directory is given, uses the current directory.

### scriptRefresh

Prunes dead symlinks in /usr/local/bin and puts in symlinks for any scripts in the current or specified directory.

### ssh-reagent

Currently broken, but the idea is to take over the ssh-agent socket from another user. This is useful if you SSH to a server as a non-root user, su to root, and then need to use the agent.

### tunnelkill

Kills any lingering `ssh -fND` processes.

## License

All scripts except those noted internally are released under the MIT License. See the bundled LICENSE file for
details.

