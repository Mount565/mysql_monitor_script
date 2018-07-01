# monitor_innodb_pending_io_status.sh
# Usage: monitor_innodb_pending_io_status.sh -u test -p test -h 192.168.21.2 -P 3306 -i 1 -m 300
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
data=/tmp/innodb_pending_io_status.data
echo "#interval_times Innodb_data_pending_fsyncs Innodb_data_pending_reads Innodb_data_pending_writes Innodb_os_log_pending_fsyncs Innodb_os_log_pending_writes"> $data
i=1
while :; do
    $mysqlcmd  -e "show global status like 'innodb_%pending%'" 2>/dev/null | awk -v iv="$i" 'BEGIN{dpf;dpr;dpw;lpf;lpw;}{if($1~/Innodb_data_pending_fsyncs/){dpf=$2;}else if($1~/Innodb_data_pending_reads/){dpr=$2;}else if($1~/Innodb_data_pending_writes/){dpw=$2;}else if($1~/Innodb_os_log_pending_fsyncs/){lpf=$2;}else if($1~/Innodb_os_log_pending_writes/){lpw=$2;}}END{print iv, dpf,dpr,dpw,lpf,lpw}' >> $data 2>/dev/null

   t=`expr $i \* $interval`
   if [ $t -ge $maxTime ];then
       break;
   fi

    sleep $interval
    i=`expr $i + 1`

done

gnuplot <<EOF
set encoding utf8
set terminal pngcairo enhanced size 50in,14in
set output "innodb_pending_io_status.png"
set key bmargin center horizontal Right noreverse enhanced autotitles box linetype -1 linewidth 1.000
set title "Innodb pending io status"
set ylabel "Pending times"
set xlabel "Interval"
set grid
plot "$data" using 1:2  with linespoints title "Innodb data pending fsyncs", "$data" using 1:3  with linespoints title "Innodb data pending reads","$data" using 1:4  with linespoints title "Innodb data pending writes","$data" using 1:5  with linespoints title "Innodb os log pending fsyncs" , "$data" using 1:6  with linespoints title "Innodb os log pending writes"
EOF
