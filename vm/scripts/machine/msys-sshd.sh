#!/bin/sh
#
#  msys2-sshd-setup.sh — configure sshd on MSYS2 and run it as a Windows service
#  https://www.msys2.org/wiki/Setting-up-SSHd/
#
#  Prerequisites:
#    — a 64-bit installation of MSYS2 itself: https://msys2.org
#    — some packages: pacman -S openssh cygrunsrv mingw-w64-x86_64-editrights
#
#  Gotchas:
#    — the log file will be /var/log/msys2_sshd.log
#    — if you get error “sshd: fatal: seteuid XXX : No such device or address”
#      in the logs, try “passwd -R” (with admin privileges)
#    — if you get error “chown(/dev/pty1, XXX, YYY) failed: Invalid argument”
#      in the logs, make sure your account and group names are detectable (see
#      `id`); issues are often caused by having /etc/{passwd,group} or having
#      a modified /etc/nsswitch.conf
#
#  Changelog:
#   09 May 2020 — completely remove additional privileged user
#   16 Apr 2020 — remove additional privileged user
#               — only touch /etc/{passwd,group} if they exist
#   27 Jun 2019 — rename service to msys2_sshd to avoid conflicts with Windows OpenSSH
#               — use mkgroup.exe as suggested in the comments
#               — fix a problem with CRLF and grep
#   24 Aug 2015 — run server with -e to redirect logs to /var/log/sshd.log
#

set -e

#
# Configuration
#

UNPRIV_USER=sshd # DO NOT CHANGE; this username is hardcoded in the openssh code
UNPRIV_NAME="Privilege separation user for sshd"

EMPTY_DIR=/var/empty


#
# Check installation sanity
#

if ! /mingw64/bin/editrights -h >/dev/null; then
    echo "ERROR: Missing 'editrights'. Try: pacman -S mingw-w64-x86_64-editrights."
    exit 1
fi

if ! cygrunsrv -v >/dev/null; then
    echo "ERROR: Missing 'cygrunsrv'. Try: pacman -S cygrunsrv."
    exit 1
fi

if ! ssh-keygen -A; then
    echo "ERROR: Missing 'ssh-keygen'. Try: pacman -S openssh."
    exit 1
fi


#
# The unprivileged sshd user (for privilege separation)
#

add="$(if ! net user "${UNPRIV_USER}" >/dev/null; then echo "//add"; fi)"
if ! net user "${UNPRIV_USER}" ${add} //fullname:"${UNPRIV_NAME}" \
              //homedir:"$(cygpath -w ${EMPTY_DIR})" //active:no; then
    echo "ERROR: Unable to create Windows user ${UNPRIV_USER}"
    exit 1
fi


#
# Add or update /etc/passwd entries
#

if test -f /etc/passwd; then
    sed -i -e '/^'"${UNPRIV_USER}"':/d' /etc/passwd
    SED='/^'"${UNPRIV_USER}"':/s?^\(\([^:]*:\)\{5\}\).*?\1'"${EMPTY_DIR}"':/bin/false?p'
    mkpasswd -l -u "${UNPRIV_USER}" | sed -e 's/^[^:]*+//' | sed -ne "${SED}" \
             >> /etc/passwd
    mkgroup.exe -l > /etc/group
fi


#
# Finally, register service with cygrunsrv and start it
#

cygrunsrv -R msys2_sshd || true
cygrunsrv -I msys2_sshd -d "MSYS2 sshd" -p /usr/bin/sshd.exe -a "-D -e" -y tcpip

# The SSH service should start automatically when Windows is rebooted. You can
# manually restart the service by running `net stop msys2_sshd` + `net start msys2_sshd`
if ! net start msys2_sshd; then
    echo "ERROR: Unable to start msys2_sshd service"
    exit 1
fi

# Infinite passwd expiry
# passwd -e "${PRIV_USER}"

# set required privileges
# for flag in SeAssignPrimaryTokenPrivilege SeCreateTokenPrivilege \
#   SeTcbPrivilege SeDenyRemoteInteractiveLogonRight SeServiceLogonRight; do
#     if ! /mingw64/bin/editrights -a "${flag}" -u "${PRIV_USER}"; then
#         echo "ERROR: Unable to give ${flag} rights to user ${PRIV_USER}"
#         exit 1
#     fi
# done


#
# Chown the home dir for key-based authentication to work
# chown vagrant /home/vagrant/.ssh -R
# chmod 0700 /home/vagrant/.ssh -R
# chown vagrant /home/vagrant
# chmod 0700 /home/vagrant


