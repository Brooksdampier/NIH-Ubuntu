#!/bin/bash
#
# 5.3.1 Ensure password creation requirements are configured
apt-get -y install libpam-pwquality

echo "password requisite pam_pwquality.so try_first_pass retry=3" >> /etc/pam.d/common-password

egrep -q "^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$/\minlen=14\2/" /etc/security/pwquality.conf || echo "minlen=14" >> /etc/security/pwquality.conf
egrep -q "^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$/\dcredit=-1\2/" /etc/security/pwquality.conf || echo "dcredit=-1" >> /etc/security/pwquality.conf
egrep -q "^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$/\ucredit=-1\2/" /etc/security/pwquality.conf || echo "ucredit=-1" >> /etc/security/pwquality.conf
egrep -q "^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$/\ocredit=-1\2/" /etc/security/pwquality.conf || echo "ocredit=-1" >> /etc/security/pwquality.conf
egrep -q "^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$/\lcredit=-1\2/" /etc/security/pwquality.conf || echo "lcredit=-1" >> /etc/security/pwquality.conf

# 5.3.3 Ensure password reuse is limited

echo "password sufficient pam_unix.so remember=5" >> /etc/pam.d/common-password

# 5.4.1.1 Ensure password expiration is 90 days or less

egrep -q "^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MAX_DAYS 90\2/" /etc/login.defs || echo "PASS_MAX_DAYS 90" >> /etc/login.defs 

# 5.4.1.2 Ensure minimum days between password changes is 7 or more

egrep -q "^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MIN_DAYS 7\2/" /etc/login.defs || echo "PASS_MIN_DAYS 7" >> /etc/login.defs

# 5.4.1.4 Ensure inactive password lock is 30 days or less

useradd -D -f 30

# 5.4.2 Ensure system accounts are non-login

for user in `awk -F: '($3 < 1000) {print $1 }' /etc/passwd`; do
  if [ $user != "root" ]; then
    usermod -L $user
    if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]; then
      usermod -s /usr/sbin/nologin $user
    fi
fi done

# 5.4.4 Ensure default user umask is 027 or more restictive

echo "umask 027" >> /etc/profile
echo "umask 027" >> /etc/bash.bashrc

# 5.6 Ensure access to the su command is restricted

echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su

df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | chmod a+t /etc/pam.d/su

echo 0 5 * * * /usr/bin/aide --check >> /etc/cron.monthly/0anacron
echo 0 5 * * * /usr/bin/aide --check >> /etc/cron

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

echo restrict -4 default kod nomodify notrap nopeer noquery >> /etc/ntp.conf
echo restrict -6 default kod nomodify notrap nopeer noquery >> /etc/ntp.conf

systemctl disable avahi-daemon

sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.route.flush=1

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j DROP
chmod -R g-wx,o-rwx /var/log/*

#chown root:root /etc/ssh/sshd_config
#chmod og-rwx /etc/ssh/sshd_config

cp /media/localadmin/UBUNTU-GNOM/UbuntuPost/rsyslog.conf /etc
wait
echo *.* @@ncias-p2017-v.nci.nih.gov >> /etc/rsyslog.conf
echo $FileCreateMode 0640 >> /etc/rsyslog.conf
pkill -HUP rsyslogd

echo server ncias-p2017-v.nci.nih.gov >> /etc/chrony/chrony.conf
invoke-rc.d chrony restart
