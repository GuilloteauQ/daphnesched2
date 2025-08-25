#! /bin/sh

# Linux data-gathering commands; adjust as necessary for your platform.
#
# Be sure to remove any information from the output that would violate
# SC's double-blind review policies.
# Based on templete provided at: https://github.com/SC-Tech-Program/Author-Kit/blob/master/collect_environment.sh

lsb_release -a
uname -a
lscpu || cat /proc/cpuinfo
cat /proc/meminfo
lsblk -a
#lsscsi -s
