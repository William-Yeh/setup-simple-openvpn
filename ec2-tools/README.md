Extract Amazon EC2 ip ranges for "split tunneling".
===


## Requirements

1. Perl
2. [jq](http://stedolan.github.io/jq/)


## Usage

```shell
$ ./add-ec2-ip-ranges.sh

```


## Reference

Amazon announced its [AWS IP Address Ranges](http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html) officially in 2014.

## Credit

This program was first inspired by `refresh.py` from the [ec2-ip](https://github.com/ab/ec2-ip) project; later, inspired by darron's [Get IP Ranges from EC2](https://gist.github.com/darron/811cf41a6ec3dbfcb97a) gist.