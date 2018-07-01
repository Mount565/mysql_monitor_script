# monitor_checkpoint_age.sh
# Usage:  monitor_checkpoint_age.sh -u test -p test -h 192.168.21.2 -P 3306 -i 1 -m 300
#!/usr/bin/bash
set -e
user=test
passwd=test
host=192.168.216.183
port=3306
interval=1
maxTime=300

function fillArgs(){
  while getopts u:p:h:P:i:m: opt;do
      case $opt in
          u) user="$OPTARG" ;;
          p) passwd="$OPTARG" ;;
          h) host="$OPTARG" ;;
          P) port="$OPTARG" ;;
          i) interval="$OPTARG" ;;
          m) maxTime="$OPTARG" ;;
      \?) echo "Invalid params ; only -u(user),-p(password) -h(host) -P(port) -i(interval) -m(max running time in secs)are accepted.";exit 1 ;;
    esac
  done
}

fillArgs $@

mysqlcmd="mysql -u$user -p$passwd -h$host -P$port"
data=/tmp/ckpoint.data
echo "#interval_times chkpoinAge"> $data
i=1
while :; do
    $mysqlcmd  -e "show engine innodb status\G" 2>/dev/null | awk -v iv="$i" 'BEGIN{f}{if($1~/LOG/) { n=-7;} else if (n<0) { if($1~/Log/ && $2=/flushed/){f=$5;}else if($2~/checkpoint/){c=$4;print iv, f-c;n=1;} n++;}}' >> $data 2>/dev/null

   t=`expr $i \* $interval`
   if [ $t -ge $maxTime ];then
       break;
   fi

    sleep $interval
    i=`expr $i + 1`

done

gnuplot <<EOF
set encoding utf8
set terminal pngcairo enhanced size 20in,14in
set output "checkpoint_age.png"
set key bmargin center horizontal Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set title "Check Point Age(bytes)"
set ytics 10485760 # 10M
set ylabel "chk_point_age(bytes)"
set xlabel "interval"
set grid
plot "$data" using 1:2  with linespoints title "Checkpoint Age"
EOF
