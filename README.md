# OctoBox
An Octoprint print server running on a reimaged ChromeBox

[OctoPi](https://octoprint.org/download/#octopi) is a popular solution for running [OctoPrint](https://octoprint.org/) to control your 3D printer on an inexpensive [Raspberry Pi](https://www.raspberrypi.com/).  With the global chip shortage, Raspberry Pi boards have become virtually unobtainable without paying an exorbitant  markup.

I came across a source of used Chromeboxes retired from service in a School district.  When reimaged with Linux, these little boxes are perfect for running OctoPrint.  I've been using this setup with my Ender 3Pro for about two years now without a hitch.  If you bought an OctoBox from me on eBay here are instructions for pr

## Configuring Wireless

### Using a keyboard and monitor

Connect a monitor to either the HDMI or Displayport connection on the back of the OctoBox and plug in a USB keyboard to any of the USB ports.  Power on the OctoBox.  It will display a series of messages as it boots, followed by a login prompt.  Enter the username 'octoprint' (without the quotation marks).  You will be prompted for a password. You can find the password on a label affixed to the bottom of the unit.  Once logged in, enter the command 'setup-octobox' and the return key.  You 

### Using a wired LAN connection and ssh

### Using a USB Thumb Drive

## Enabling the Graphical User Interface

The system comes with Ubuntu 20.04 LTS with desktop support and the Cura slicer installed.  By default the graphical user interface is *not* enabled.  The assumption is that the OctoBox will be installed next to your 3D printer without a monitor and all access will be via the web-based OctoPrint interface.  Running the desktop interface would unnecessarily consume CPU and memory.

If you want to run the desktop, you can configure it 
