
# OctoBox <a name="Intro">
An Octoprint print server running on a reimaged ChromeBox

[OctoPi](https://octoprint.org/download/#octopi) is a popular solution for running [OctoPrint](https://octoprint.org/) to control your 3D printer on an inexpensive [Raspberry Pi](https://www.raspberrypi.com/).  With the global chip shortage, Raspberry Pi boards have become virtually unobtainable without paying an exorbitant markup.

I came across a source of used Chromeboxes retired from service in a school district.  When reimaged with Linux, these little boxes are
perfect for running OctoPrint.  I've been using this setup with my Ender 3Pro for about two years now without a hitch.  If you bought
an OctoBox from me on eBay here are instructions for configuring your system.

# Table of Contents
1. [OctoBox](#Intro)
2. [Network Configuration](#NetworkConfiguration)
    1. [Wired Network](#WiredNetwork)
    2. [Wireless Network](#WirelessNetwork)
        1. [Using a Keyboard and Monitor](#KeyboardMonitor)
        2. [Configuring using the Desktop GUI](#DesktopGUI)
    3. [Using a Thumb Drive](#ThumbDrive)

3. [Configuring OctoPrint](#ConfiguringOctoPrint)
4. [Other OctoBox Configuration](#OtherConfiguration)
     1. [Disabling the Graphical User Interface](#DisableGUI)
5. [System Details](#SystemDetails)

# Network Configuration <a name="NetworkConfiguration">

The first thing you need to do is connect the OctoBox to your network.

## Wired Network <a name="WiredNetwork">

When plugged into a wired network, the OctoBox should self configure via dhcp and come up on your network as 'octoprint.local'  If you have
a convenient wired network connection near your 3D printer, this is an excellent option as it avoids any issues with spotty wireless
connections.  Simply open a browser and enter "http://octoprint.local:5000"

## Wireless Network <a name="WirelessNetwork">

To configure your OctoBox to join your wireless network, you have three options: 
1. connect a keyboard, mouse and monitor to the OctoBox and configure directly,
2. temporarily connect to a wired network and configure remotely via a terminal application, or 
3. edit a configuration file on the provided USB flash card and insert it into your OctoBox prior to booting.

Each option is explained in greater detail below.

### Using a keyboard and monitor <a name="KeyboardMonitor">
<details>
  <summary>Click to expand!</summary>

Connect a monitor to either the HDMI or Displayport connection on the back of the OctoBox and plug in a USB keyboard and mouse to any
of the USB ports.  Power on the OctoBox.  It boots into a desktop environment already logged in as user 'ocho'.

From the desktop, there are two options for enabling wireless.

#### Configure using the Desktop GUI
<details>
  <summary>Click to expand!</summary>

From the desktop, click on the power button in the upper right hand corner:

![Desktop](screenshots/desktop.png)

Then expand the "Wi-Fi Not Connected" option and click on "Select Network"

![Select Network](screenshots/select-network.png)

This will bring up a new window where you can select your wireless network and enter the password.
</details>

#### Configure using octobox-setup

<details>
  <summary>Click to expand!</summary>
Alternately you can configure using the octobox-setup script from a termina.  To open a terminal, click on
the terminal icon in the dock on the left hand side of the screen:

![Terminal](screenshots/terminal.png)

This will open a new terminal window.

In the terminal, type the command

```
sudo octobox-setup
```
and hit [enter]

You will be prompted for a password.  Use the password from the sticker on the bottom of the machine.

![sudo-password](screenshots/sudo-password.png)

This will run the octobox-setup script.

![setup main](screenshots/setup-main.png)
</details>

</details>

### Using a wired LAN connection and ssh
<details>
  <summary>Click to expand!</summary>
You can configure wireless access without a terminal and keyboard by temporarily plugging your OctoBox into a wired ethernet connection and accessing it remotely.

For remote access, you will need an ssh client.  For Windows, I recommend Putty.  You can install the latest Putty client from
[here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).

</details>

### Using a USB Thumb Drive <a name="ThumbDrive">
<details>
  <summary>Click to expand!</summary>

octobox-config.txt

```
# OctoBox startup configuration file
#
# Lines starting with a '#' are ignored
# Do not remove the '#-' line below!
#-

SSID=mySSID
password=mypassword
#desktop=disabled
```

replace the string 'your_SSID' with the name of your wireless network, and 'your_password' with the password.  Save the file, eject the flash drive and move it to
your OctoBox.  When the system boots, it scans for any attached USB drives or an SD card containing the file octobox-config.txt in the top level folder. If found, it
applies the options specified in the configuration file.

A word about the config file format.  The config parser tries to be agnostic about line terminators.  You can edit the file with Windows, Linux or MacOS.  As a result,
it does NOT process the config file line-by-line.  If you have a '#' character followed by any amount of whitespace (including line terminators) preceding a config
setting, the config will be considered commented out!

```
# This comment block ends in a trailing '#'
# The SSID config will not be processed!
#

SSDI=myssid
password=mypassword
```
verses:

```
# This comment block has a character after the last '#'
# thus separating the comment from the next config line.
# The SSID config will be processed.
#-

SSDI=myssid
password=mypassword
```

</details>

# Configuring OctoPrint <a name="ConfiguringOctoPrint">


# Other OctoBox Configuration<a name="OtherConfiguration">

## Disabling the Graphical User Interface

# System Details <a name="SystemDetails">

The system comes with Ubuntu 20.04 LTS with desktop support and the Cura slicer installed.  By default the graphical user interface is
enabled.  If you connect a monitor, keyboard and mouse the system will boot into a desktop environment with the user 'ocho' logged in.

There are two accounts created by default.

The user account is 'ocho' and the password is provided on a sticker attached to the bottom of the OctoBox. You can log into this account to run Cura or a web browser
to connect to the local Octoprint service.

The Octoprint service runs under the account 'octoprint'  This is a system account to run the service.  It does not have login or shell access. Sudo access is
restricted to shutting down and rebooting the system.

Octoprint was installed in a python venv at /home/octoprint/venv


