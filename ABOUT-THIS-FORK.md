ABOUT THIS FORK
===============


## What's new in this fork?

1. Extend the DH key size from 1024 to 2048.

2. Add another service [ifconfig.me](http://ifconfig.me/ip) in case that [ipecho.net](http://ipecho.net/plain) fails. 

3. Extract the `easy-rsa` customization logic to a single `myvars` file instead of being hardcoded `sed` command in `setup.sh`.

4. Add: `ec2-tools` and `gce-tools` to setup "split tunneling" for EC2 and GCE. 

5. Add: `add-user.sh` tool to facilitate the process of adding new user using current server configuration.



## Tested platforms


Google Compute Engine

 - CentOS 6.6, 6.5

Amazon EC2

 - CentOS 6.6, 6.5




## Installation instructions


0. Prepare CentOS environment:

   ```shell
   $ # install EPEL repository (for OpenVPN)
   $ sudo rpm -iv http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

   $ # install utilities
   $ sudo yum install git wget
   ```

1. Change to the parent directory to be installed. For example:

   ```shell
   $ cd /opt
   ```

2. Clone the project:

   ```shell
   $ git clone https://github.com/William-Yeh/setup-simple-openvpn.git
   ```

3. Edit the `myvars` file:

   ```shell
   $ cd setup-simple-openvpn
   $ vi myvars
   ```

4. Clean old configuration, if any:

   ```shell
   $ rm -rf /etc/openvpn

   $ # clean up iptable entries at the end of the rc.local file
   $ sudo vi /etc/rc.d/rc.local
   ```

5. If you want to establish a VPN service that only routes traffic for GCE instances ("split tunneling"):

   ```shell
   $ cd gce-tools
   $ ./add-gce-ip-ranges.sh
   $ cd ..
   ```
   
   Paste the output into `template-gce-server-config`, and re-link the `template-server-config` to this file.

   Ditto for Amazon EC2:

   ```shell
   $ cd ec2-tools
   $ ./add-ec2-ip-ranges.sh
   $ cd ..
   ```

6. Execute the `normal-setup.sh` command:

   ```shell
   $ sudo bash normal-setup.sh
   ``` 
   
   If you need a different port, protocol, and name, take a look at command-line argument of `normal-setup.sh`:
   
   ```shell
   $ bash normal-setup.sh -h   
   ```

For more details, see the original document [`README.md`](README.md).



## Adding a new user

1. Change to the project directory.

2. Execute the `add-user.sh` command:

   ```shell
   $ sudo ./add-user.sh  USERNAME
   ```

3. Test the user configuration file:

   ```shell
   $ unzip -t openvpn.USERNAME/*.zip
   ```



## Troubleshooting


- Verify if TUN support is enabled on the system:

  ```shell
  $ test ! -c /dev/net/tun && echo openvpn requires tun support || echo tun is available

  $ ls -al /dev/net/tun

  $ ip -s link

  $ lsmod | grep tun

  $ modprobe tun
  ```

- Enable IP forwarding:

  ```shell
  $ sysctl net.ipv4.ip_forward
  
  $ sudo sysctl -w net.ipv4.ip_forward=1

  $ vi /etc/sysctl.conf
  net.ipv4.ip_forward = 1

  $ sudo sysctl -p /etc/sysctl.conf 
  ```



## References


1. [How to install and set-up OpenVPN in Debian 7 (Wheezy)](http://d.stavrovski.net/blog/post/how-to-install-and-set-up-openvpn-in-debian-7-wheezy)


2. [How to Install OpenVPN on Debian Wheezy with Two-Factor Login](http://midactstech.blogspot.tw/2013/07/how-to-install-openvpn-on-debian-wheezy.html)


3. [OpenVPN Basics](http://netwizards.co.uk/openvpn-basics/)

