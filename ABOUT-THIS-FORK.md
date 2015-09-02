ABOUT THIS FORK
===============


## What's new in this fork?

1. Extend the DH key size from 1024 to 2048.

2. Add another service [http://myip.dnsomatic.com](http://myip.dnsomatic.com) in case that [http://icanhazip.com](http://icanhazip.com) fails. 

3. Extract the `easy-rsa` customization logic to a single `myvars` file instead of being hardcoded `sed` command in `setup.sh`.

4. Add: `ec2-tools` and `gce-tools` to setup "split tunneling" for EC2 and GCE. 

5. Add: `add-user.sh` tool to facilitate the process of adding new user using current server configuration.

6. beef up cipher AES-256-CBC, auth SHA384, tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256 , tls-version-min 1.2 supported from OpenVPN 2.3.4+, [https://bettercrypto.org/static/applied-crypto-hardening.pdf](https://bettercrypto.org/static/applied-crypto-hardening.pdf)

7. tls-auth pre shared key [https://community.openvpn.net/openvpn/wiki/Hardening](https://community.openvpn.net/openvpn/wiki/Hardening)

8. certificates are embedded in an alternative ovpn file. it simplifies client configuration, skip unzipping files.

## Tested platforms


Google Compute Engine

 - CentOS 6.6, 6.5

Amazon EC2

 - CentOS 6.6, 6.5, 7.0

 - Ubuntu 14.04 LTS


## Installation instructions

### A. Preparation

1. Prepare CentOS environment:

   ```shell
   $ # install EPEL repository (for OpenVPN)
   $ sudo yum install epel-release

   $ # install utilities
   $ sudo yum install git curl
   ```

2. Change to the parent directory to be installed. For example:

   ```shell
   $ cd /opt
   ```

3. Clone the project:

   ```shell
   $ git clone https://github.com/William-Yeh/setup-simple-openvpn.git
   ```

4. Clean old configuration, if any:

   ```shell
   $ rm -rf /etc/openvpn

   $ # clean up iptable entries at the end of the rc.local file
   $ sudo vi /etc/rc.d/rc.local
   ```


### B. Edit configurations

1. Edit the `myvars` file for `easy-rsa` parameter settings:

   ```shell
   $ cd setup-simple-openvpn
   $ cp myvars.default  myvars
   $ vi myvars
   ```

2. Edit the `template-server-config` file:

   - Ordinary config:

     ```shell
     $ cp template-server-config.default  template-server-config
     $ vi template-server-config
     ```

   - If you want to establish a VPN service that only routes traffic for Amazon EC2 ("*split tunneling*"):

     ```shell
     $ cp template-server-config.ec2  template-server-config
     $ vi template-server-config
     ```

   - If "split tunneling" for GCE instances:

     ```shell
     $ cp template-server-config.gce  template-server-config
     $ vi template-server-config
     ```

### C. Install!


1. Execute the `normal-setup.sh` command:

   ```shell
   $ sudo normal-setup.sh
   ``` 
   
   If you need a different port, protocol, and name, take a look at command-line argument of `normal-setup.sh`:
   
   ```shell
   $ normal-setup.sh -h   
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

