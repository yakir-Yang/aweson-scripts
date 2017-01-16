#! /bin/bash

SPEEDY_LIMIT=1024
LOOP_TIME_SEC=3

record_logs()
{
        # usage: record_logs [log file name] [log command]
        LOG_NAME=$1
        COMMAND=$2
        TIME=$3
        HACK=$4

        PWD=`pwd`
        LOG_FILE=`echo "$PWD/logs/$LOG_NAME/$LOG_NAME.$TIME"`
        LOG_LATEST_FILE=`echo "$PWD/logs/$LOG_NAME.LATEST"`

        # creat the log dir
        if [ ! -d "logs/$LOG_NAME/" ]; then
                mkdir -p "logs/$LOG_NAME/"
        fi

        # run comamnd
        if [ -z $HACK ]; then
                $COMMAND > $LOG_FILE
        else
                $COMMAND $HACK $LOG_FILE
        fi

        # re-link the latest log file
        if [ -f "$LOG_LATEST_FILE" ]; then
                rm $LOG_LATEST_FILE
        fi
        ln -s $LOG_FILE $LOG_LATEST_FILE
}

loop_time=20
while (($loop_time > 0)); do
        TIME=`date +%F--%H:%M:%S`

	# record ifstat results
        IN_OUT=`sudo ifstat -T $LOOP_TIME_SEC 1 | sed -n '3p'`
        IN=`echo $IN_OUT | awk {'print $1'}`
        OUT=`echo $IN_OUT | awk {'print $2'}`

	# print speed to log file
        echo "[DEBUG]: $TIME ||  KB/s in: $IN   KB/s out: $OUT" | tee -a rootkit.log

	# judge whether speedy is normal, if normal just continue.
	IS_SPEEDY_UNORMAL=`echo "$OUT > $SPEEDY_LIMIT" | bc`
	if [ $IS_SPEEDY_UNORMAL -eq 0 ]; then
		continue
	fi

	echo "[ERROR]: $TIME || Detect unormal speedy, start to record more info" | tee -a rootkit.log

        echo "[DEBUG]: Recording netstat logs..."
        record_logs "netstat_log" "sudo netstat -lnp -t -u" $TIME

        echo "[DEBUG]: Recording iftop logs..."
        record_logs "iftop_log" "sudo iftop -n  -i eth0 -P -B -t -s 5" $TIME

        echo "[DEBUG]: Recording ps logs..."
        record_logs "ps_log" "sudo ps -ef" $TIME

        echo "[DEBUG]: Recording lsof logs..."
        record_logs "lsof_log" "sudo lsof" $TIME

        echo "[DEBUG]: Recording tcpdump_1 logs..."
        record_logs "tcpdump1_log" "sudo tcpdump -i eth0 -s 0 -c 2000" $TIME

        echo "[DEBUG]: Recording tcpdump_2 logs..."
        record_logs "tcpdump2_log" "sudo tcpdump -i eth0 -s 0 -c 10000" $TIME "-w"

        loop_time=$(($loop_time - 1))
        echo "[DEBUG]: $TIME || loop_time = $loop_time" | tee -a rootkit.log
done

sync
