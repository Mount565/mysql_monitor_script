# mysql_monitor_script

Shell script to monitor mysql or innodb status and plot. 

Rquired gnuplot version: Version 4.6 patchlevel 2

An Usage example [here](https://dbalife.info/2018/07/01/%E6%8E%A2%E7%B4%A2%E5%8F%91%E7%8E%B0%EF%BC%9AInnoDB-%E5%86%85%E9%83%A8IO%E6%B4%BB%E5%8A%A8%E7%9B%91%E6%8E%A7/)

### Usage
```
monitor_checkpoint_age.sh -u test -p test -h 192.168.21.2 -P 3306 -i 1 -m 300   
```
this script doesn't work with mysql8
