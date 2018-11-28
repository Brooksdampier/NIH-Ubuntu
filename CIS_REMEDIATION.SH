#!/bin/bash
#
# CIS Ubuntu 16.04 1.0.0 Benchmark Remediation Script

# 1.1.1.1 - 1.1.1.7
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf

# 1.1.16 noexec set on /dev/shm partition
echo "shmfs  /dev/shm  tmpfs nodev,nosuid,noexec 0 0" >> /etc/fstab

# 1.4 Ensure permissions on bootloader config are configured
chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

# 1.5.1 Ensure core dumps are restricted
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf

# 1.7.1.2 Ensure local login banner is configured properly
rm /etc/issue
ln -s /etc/issue.net /etc/issue

# 2.2.1.1 Ensure time synchronization is in use
apt-get -y install ntp
apt-get -y install chrony

# 2.2.1.2 Ensure ntp is configure
cat <<EOF> /etc/ntp.conf
# Enable next tinker options:
# panic - keep ntpd from panicking in the event of a large clock skew
# when a VM guest is suspended and resumed;
# stepout - allow ntpd change offset faster
tinker panic 0
disable monitor

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1

# Set up servers for ntpd with next options:
# server - IP address or DNS name of upstream NTP server
# iburst - allow send sync packages faster if upstream unavailable
# prefer - select preferrable server
# minpoll - set minimal update frequency
# maxpoll - set maximal update frequency
# noselect - do not sync with this server
server ntp1.nih.gov
server ntp2.nih.gov
server ntp3.nih.gov
server 127.127.1.0

# Driftfile.
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys
requestkey
controlkey
fudge 127.127.1.0 stratum 10
EOF

# 2.2.3 Ensure Avahi Server is not enabled
systemctl disable avahi-daemon
systemctl disable avahi-daemon.socket
systemctl disable avahi-daemon.service

# 2.3.4 Ensure telnet client is not installed
apt -y purge telnet

# 3.1.2 Ensure packet redirect sending is disabled
echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects=0" >> /etc/sysctl.conf

# 3.2.1 Ensure source routed packates are not accepted
echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route=0" >> /etc/sysctl.conf

# 3.2.2 Ensure ICMP redirects are not accepted
echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.conf

# 3.2.3 Ensure secure ICMP redirects are not accepted
echo "net.ipv4.conf.all.secure_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects=0" >> /etc/sysctl.conf

# 3.2.4 Ensure suspicious packets are logged
echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf

# 3.3.1 Ensire IPv6 router advertisements are not accepted
echo "net.ipv6.conf.all.accept_ra=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra=0" >> /etc/sysctl.conf

# 3.3.2 Ensure IPv6 redirects are not accepted
echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_redirects=0" >> /etc/sysctl.conf

# 3.4.3 Ensure /etc/hosts.deny is configured
echo "ALL: ALL" >> /etc/hosts.deny

# 3.5.1 - 3.5.4 Uncommon Network Protocols
echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf

# 3.6.2 - 3.6.5 IPTables

# 4.2.4 Ensure permissions on all logfiles are configured
chmod -R g-wx,o-rwx /var/log/*

# 5.1.2 Ensure permissions on /etc/crontab are configured
chown root:root /etc/crontab
chmod og-rwx /etc/crontab

# 5.1.3 Ensure permissions on /etc/cron.hourly are configured
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

# 5.1.4 Ensure permissions on /etc/cron.daily are configured
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

# 5.1.5 Ensure permissions on /etc/cron.weekly are configured
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

# 5.1.6 Ensure permissions on /etc/cron.monthly are configured
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly

# 5.1.7 Ensure permissions on /etc/cron.d are configured
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

# 5.1.8 Ensure at/cron is restricted to authorized users
rm -rf /etc/cron.deny
rm -rf /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod g-r-w-x,o-r-w-x /etc/cron.allow
chmod g-r-w-x,o-r-w-x /etc/at.allow
chown 0:0 /etc/cron.allow
chown 0:0 /etc/at.allow


# 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured
chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

# 5.2.2 Ensure SSH Protocol is set to 2
# 5.2.3 Ensure SSH LogLevel is set to INFO
# 5.2.4 Ensure SSH X11 forwarding is disabled
# 5.2.5 Ensure SSH MaxAuthTries is set to 4 or less
# 5.2.6 Ensure SSH IgnoreRhosts is enabled
# 5.2.7 Ensure SSH HostbasedAuthentication is disabled
# 5.2.8 Ensure SSH root login is disabled
# 5.2.9 Ensure SSH PermitEmptyPasswords is disabled
# 5.2.10 Ensure SSH PermitUserEnvironment is disabled
# 5.2.11 Ensure only approved MAC algorithms are used
# 5.2.12 Ensure SSH Idle Timeout Interval is configured
# 5.2.13 Ensure SSH LoginGraceTime is set to one minute or less
# 5.2.14 Ensure SSH access limited
# 5.2.15 Ensure SSH warning banner is configured

cat <<EOF>/etc/ssh/sshd_config
Port 22
Protocol 2
LogLevel INFO
MaxAuthTries 4
X11Forwarding no
IgnoreRhosts yes
HostbasedAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
PermitUserEnvironment no
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
ClientAliveInterval 300
ClientAliveCountMax 0
Banner /etc/issue.net
UsePAM yes
AddressFamily any
ListenAddress 0.0.0.0
SyslogFacility AUTHPRIV
PasswordAuthentication yes
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
Subsystem sftp /usr/libexec/openssh/sftp-server
DenyUsers root
LoginGraceTime 60
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
EOF

cat <<EOF>/etc/issue.net
********************************************************************************

            ***WARNING***

This warning banner provides privacy and security notices consistent with
applicable federal laws, directives, and other federal guidance for accessing
this Government system, which includes (1) this computer network, (2) all
computers connected to this network, and (3) all devices and storage media
attached to this network or to a computer on this network.

This system is provided for Government-authorized use only.

Unauthorized or improper use of this system is prohibited and may result in
disciplinary action and/or civil and criminal penalties.

Personal use of social media and networking sites on this system is limited as
to not interfere with official work duties and is subject to monitoring.

By using this system, you understand and consent to the following:

The Government may monitor, record, and audit your system usage, including
usage of personal devices and email systems for official duties or to conduct
HHS business.  Therefore, you have no reasonable expectation of privacy
regarding any communication or data transiting or stored on this system. At any
time, and for any lawful Government purpose, the government may monitor,
intercept, and search and seize any communications or data transiting or stored
on this system.

Any communication or data transiting or stored on this system may be disclosed
or used for any lawful Government purpose.

********************************************************************************
EOF

