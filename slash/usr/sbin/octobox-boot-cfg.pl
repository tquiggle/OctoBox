#! /usr/bin/perl

# Script to look for a USB drive containing OctoBox initial configuration
#
# Executed at system startup, this script scans for USB disk drives and checks 
# for a file 'octobox-config.txt'
#
# If found, it applies the specified configuration.
#
# If a file 'syslog' is found on a device, it is replaced with the content
# of /var/log/syslog for debugging purposes.
#
# Written in Perl because the author finds regex processing and command
# execution easier in Perl than bash or python.

use strict;

my @usb_drives;
my $debug=0;

# Setup logger for output to syslog
use Sys::Syslog qw(:DEFAULT :standard :macros);
openlog("octobox-bootcfg[$$]", $debug ? 'ndelay,perror' : 'ndelay', 'local2');

# find USB block devices
syslog(LOG_INFO, "scanning for USB drives");
open USBDRIVES, "ls -l /dev/disk/by-id/usb* |";
while  (<USBDRIVES>) {
    chomp;
    my @cols = split /\s/;
    my $device = @cols[-1];
    $device =~ s/.*\///;
    syslog(LOG_INFO, "found device $device");
    push @usb_drives, $device
}

if (!@usb_drives) {
    syslog(LOG_INFO, "no USB drives found. Exiting.");
    exit 0;
}

# iterate over each USB disk device:
#   mount the partition on /media/usb (if not already mounted)
#   process any octobox-config.txt file in the root folder
#
# If multiple USB drives with octobox-config.txt files are present, 
# the script stops after the first one is processed.  

system("mkdir -p /media/usb");
foreach my $drive (sort @usb_drives) {
    my $done;
    print "checking partition $drive\n" if ($debug);
    if (`mount | grep $drive` eq "") {
        print "$drive not mounted. Mounting at /media/usb\n" if ($debug);
        my $cmd = "mount /dev/$drive /media/usb";
        print "$cmd\n" if ($debug);
        system($cmd);
        $done = process_drive("/media/usb");
        system("umount /media/usb");
    } else {
        my $mount_info = `mount | grep $drive`;
        if ($mount_info =~ /\s+on\s+(\S+)\s+/) {
            my $mount_point = $1;
            $done = process_drive($mount_point);
        }
    }
    last if ($done);
}

# Escape special characters in SSID or password before passing as 
# command line options to nmcli

sub escape($) {
    my $var = shift @_;

    $var =~ s/\\/\\\\/g;
    $var =~ s/\./\\\./g;
    $var =~ s/\*/\\\*/g;
    $var =~ s/\+/\\\+/g;
    $var =~ s/\'/\\\'/g;
    $var =~ s/\?/\\\?/g;
    $var =~ s/\^/\\\^/g;
    $var =~ s/\$/\\\$/g;
    $var =~ s/\//\\\//g;
    $var =~ s/\[/\\\[/g;
    $var =~ s/\]/\\\]/g;
    $var =~ s/ /\\ /g;
    $var =~ s/\{/\\{/g;
    $var =~ s/\}/\\}/g;
    $var =~ s/\(/\\(/g;
    $var =~ s/\)/\\)/g;
    $var =~ s/"/\\\\\"/g;

    return $var;
}

sub process_config ($) {
    my $config_file = shift @_;

    my $do_wifi = 1;
    my $ssid = "";
    my $password = "";
    my $desktop = "";
    my $config = `cat $config_file`;

    # Truly hackey parsing of the config file. The entire config file
    # is read into a variable and known config values are matched via
    # regular expressions. This protects against end-of-line variations.
    # It doesn't matter if the file was created on Windows, Linux or
    # MacOs.
    #
    # Note: if you have a '#' character followed by any amount of
    # whitespace (including line terminators) preceeding a config line,
    # the config will be treated as commented out.
    #
    # E.g.:
    #
    #    # This comment block ends in a trailing '#' line
    #    # so the SSID config will not be processed!
    #    #
    #
    #    SSDI=myssid
    #    password=mypassword
    #
    # verses:
    #
    #    # This comment block has a character after the last '#'
    #    # thus separating the comment from the next config line.
    #    # The SSID config will be processed.
    #    #-
    #
    #    SSDI=myssid
    #    password=mypassword

    # First check for " quoted SSIDs
    $ssid     = $1 if ($config =~ /[Ss][Ss][Ii][Dd]\s*[:=,]\s*"([^"]+)"/ && 
                       $config !~ /#\s*[Ss][Ss][Ii][Dd]\s*/);

    # Then check for ' quoted SSIDs
    if ($ssid eq "") {
        $ssid     = $1 if ($config =~ /[Ss][Ss][Ii][Dd]\s*[:=,]\s*'([^']+)'/ && 
                           $config !~ /#\s*[Ss][Ss][Ii][Dd]\s*/);
    }

    # Finally check for unquoted SSIDs
    if ($ssid eq "") {
        $ssid     = $1 if ($config =~ /[Ss][Ss][Ii][Dd]\s*[:=,]\s*(\S+)/ && 
                           $config !~ /#\s*[Ss][Ss][Ii][Dd]\s*/);
    }

    $password = $1 if ($config =~ /[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*"([^"]+)"/ &&
                       $config !~ /#\s*[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*(\S+)/);

    if ($password eq "") {
        $password = $1 if ($config =~ /[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*'([^']+)'/ &&
                           $config !~ /#\s*[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*(\S+)/);
    }

    if ($password eq "") {
        $password = $1 if ($config =~ /[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*(\S+)/ &&
                           $config !~ /#\s*[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=,]\s*(\S+)/);
    }

    $desktop  = $1 if ($config =~ /[Dd][Ee][Ss][Kk][Tt][Oo][Pp]\s*[:=,]\s*(\S+)/ &
                       $config !~ /#\s*[Dd][Ee][Ss][Kk][Tt][Oo][Pp]\s*[:=,]\s*(\S+)/);

    $ssid = escape($ssid);
    $password = escape($password);

    print "ssid=$ssid\n" if ($debug);
    print "password=$password\n" if ($debug);
    print "desktop=$desktop\n" if($debug);

    if ($ssid eq "" && $password eq "") {
        syslog(LOG_ERR, "$config_file contains no SSID or password");
        $do_wifi = 0;
    }

    if ($ssid ne "" && $password eq "") {
        syslog(LOG_ERR, "$config_file contains SSID but no password");
        $do_wifi = 0;
    }

    if ($password ne "" && $ssid eq "") {
        syslog(LOG_ERR, "$config_file contains password but no SSID");
        $do_wifi = 0;
    }

    if ($password eq "mypassword" || $ssid eq "mySSID") {
        syslog(LOG_ERR, "$config_file contains default password or SSID. Skipping...");
        $do_wifi = 0;
    }

    if ($do_wifi) {
        syslog(LOG_INFO, "Turning WiFi on");
        system ("nmcli radio wifi on");
        system ("nmcli device wifi rescan ifname wlp2s0 ssid $ssid");
        system ("nmcli device wifi list --rescan yes > /tmp/wifi-list.txt");
        my $cmd = "nmcli dev wifi connect $ssid password \"$password\"";
        syslog(LOG_INFO, "Configuring WiFi with SSID=$ssid");
        my $cmd = "nmcli dev wifi connect $ssid password \"$password\"";
        print "executing '$cmd'\n" if ($debug);
        my $rc = system ($cmd);
        print "nmcli returned $rc" if ($debug);
        syslog(LOG_INFO, "nmcli returned $rc");
        system ("dhclient wlp2s0");
    }

    if ($desktop ne "") {
        syslog(LOG_INFO, "desktop set to '$desktop'");
        my $current_target = `systemctl get-default`;
        chomp $current_target;
        # Check if desktop option is 'True' 'Enable*' or '1' (case insenstive)
        if ($desktop =~ /[Tt][Rr][Uu][Ee]/ ||
            $desktop =~ /[Ee][Nn][Aa][Bb][Ll][Ee]/ ||
            $desktop eq "1") {
            if ($current_target eq "graphical.target") {
                syslog(LOG_INFO, "$config_file set desktop to enabled. Already enabled.");
            } else {
                syslog(LOG_INFO, "$config_file Enabling desktop.");
                system("systemctl --quiet set-default graphical.target");
                system("reboot now");
            }
        # Check if desktop option is 'False' 'Disable*' or '0' (case insenstive)
        } elsif ($desktop =~ /[Ff][Aa][Ll][Ss][Ee]/ ||
                 $desktop =~ /[Dd][Ii][Ss][Aa][Bb][Ll][Ee]/ ||
                 $desktop eq "0") {
            if ($current_target eq "multi-user.target") {
                syslog(LOG_INFO, "$config_file set desktop to disabled. Already disabled.");
            } else {
                syslog(LOG_INFO, "$config_file Disabling desktop.");
                system("systemctl --quiet set-default multi-user.target");
                system("reboot now");
            }
        } else {
            syslog(LOG_ERR, "Unrecognized value for desktop option '$desktop'");
        }
    }
}

sub process_syslog($) {
    my $log_file = shift @_;

    # compute free space on thumb drive
    my $df_out = `df --block-size=1 /media/usb | tail -1`;
    my @cols = split /\s+/, $df_out;
    my $free = $cols[3];
    # use up to the last 4K
    my $log_bytes = $free - 4096;
    my $cmd = "tail --bytes=$free /var/log/syslog > $log_file";
    system($cmd);
}

sub process_drive($) {
    my $mount_point = shift @_;
    my $config_complete = 0;

    if (-e "$mount_point/octobox-config.txt") {
        $config_complete = process_config("$mount_point/octobox-config.txt");
    } else {
        syslog(LOG_INFO, "no file $mount_point/octobox-config.txt");
    }

    if (-e "$mount_point/syslog") {
        syslog(LOG_INFO, "found $mount_point/syslog. Saving /var/log/syslog");
        process_syslog("$mount_point/syslog");
    }
    return $config_complete;
}

closelog()

# vim: expandtab: sw=4
