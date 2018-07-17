# About
Vagrantfile for BIRD Route Server development.

# Environment
## Requirements
* Memory 3G~

## Network Construction
```
                      IX Network                         PNI
  +---------------+   10.0.0.0/24     +---------------+  10.0.1.0/29      +---------------+
  | BIRD          |   2001:db8::/64   | gobgp1        |  2001:db8:1::/64  | gobgp4        |
  |               +-------------------+               +-------------------+               |
  | Route Server  |         |         | RS Client#1   |                   | BGP Speaker   |
  +---------------+         |         +---------------+                   +---------------+
  AS65100                   |         AS65001                             AS65004
  10.0.0.100                |         10.0.0.1,    10.0.1.1               10.0.1.4
  2001:db8::100             |         2001:db8::1, 2001:db8:1::1          2001:db8:1::4
                            |
                            |         +---------------+
                            |         | gobgp2        |
                            +---------+               |
                            |         | RS Client#2   |
                            |         +---------------+
                            |         AS65002
                            |         10.0.0.2
                            |         2001:db8::2
                            |
                            |         +---------------+
                            |         | gobgp3        |
                            +---------+               |
                                      | RS Client#3   |
                                      +---------------+
                                      AS65003
                                      10.0.0.3
                                      2001:db8::3
```

# Setup

## Install
```
git clone https://github.com/7310510/bird-rs-dev.git
cd bird-rs-dev
./setup.sh
```
You'll see five VMs up.
* bird
* gobgp{1|2|3|4}

## Deploy configuration file

You have to generate BIRD configuration, for example by using [ARouteServer](https://github.com/pierky/arouteserver).<br>
Once you get configuration file (bird.conf/bird6.conf), deploy it to bird VM and start BIRD.

```
mv bird.conf provisioning/bird
mv bird6.conf provisioning/bird6
vagrant ssh bird

# terminal of bird VM
sudo systemctl start bird
sudo systemctl start bird6
sudo birdc
sudo birdc6
```

## Play

You can use gobgp{1,2,3,4} as route server clients.<br>
Refer `gobgp` comamnd [here](https://github.com/osrg/gobgp/blob/master/docs/sources/cli-command-syntax.md).

```
vagrant ssh gobgp1

# terminal of gobgp1
gobgp global rib -a ipv4 add 192.168.0.0/16 origin igp nexthop 10.0.0.1
gobgp global rib -a ipv6 add 2001:db8:ffff::/32 origin igp nexthop 2001:db8::1
```

```
vagrant ssh bird

# terminal of bird
sudo birdc
bird> show route
192.168.0.0/16     via 10.0.0.1 on eth1 [B10_0_0_1 Tue Jul 17 07:42:16 2018] * (100) [AS65001i]

sudo birdc6
bird> show route
2001:db8:ffff::/48 via 2001:db8::1 on eth1 [B2001_db8__1 Tue Jul 17 07:46:22 2018] * (100) [AS65001i]
```

```
vagrant ssh gobgp3

# terminal of gobgp3
gobgp neighbor 10.0.0.100 adj-in
   ID  Network              Next Hop             AS_PATH              Age        Attrs
   0   192.168.0.0/16       10.0.0.1             65001                00:00:52   [{Origin: i}]
gobgp neighbor 2001:db8::100 adj-in
   ID  Network              Next Hop             AS_PATH              Age        Attrs
   0   2001:db8:ffff::/48   2001:db8::1          65001                00:00:44   [{Origin: i}]
```
