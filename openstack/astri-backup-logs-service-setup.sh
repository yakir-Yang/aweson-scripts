#! /bin/bash

touch /dev &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[31mYou need run this with root premission"
    exit
fi

function print_help()
{
    echo -e "\033[32m"
    echo "usage: `basename "${BASH_SOURCE[0]}"` [--service_name] [--log_dir] [--ftp_server] [--ftp_username] [--ftp_password] [--ftp_remotepath] [--loop_cycle]"
    echo ""
    echo "This script is used for setup the Astri-Backup-Logs service. And if you want to adjust"
    echo "some parameters for the ABL, you can also try this script. Once you have setup the ABL"
    echo "service, no need to do this again, just start the ABL service."
    echo ""
    echo "optional arguments:"
    echo "  --help             show this help message and exit"
    echo "  --ftp_server       FTP server address (exp. 127.0.0.1)"
    echo "  --ftp_username     username for login the FTP server"
    echo "  --ftp_password     password for login the FTP server"
    echo "  --ftp_remotepath   remote directory path in the FTP server"
    echo "  --service_name     the unique string for this service"
    echo "  --log_dir          the log directory that need to be listened"
    echo "  --loop_cycle       how long that service need to re-listen the logs (default to '10s')"
    echo "  --skip_today_file  do not collect today's documents (default to 'False')"
    echo "  --listen_default_log_dirs   listen the hard code log dirs (default to 'False')"

    printf  "      \033[33m%-15s %-18s %-30s %s\n" "--service_name" "--skip_today_file" "--ftp_remotepath" "--log_dir" 
    printf  "      -----------------------------------------------------------------------------------------\n"
    for n in $(seq 1 ${#DEFAULT_ARG_LOG_DIRS[@]}); do
        ARG_SERVICE_NAME=${DEFAULT_ARG_SERVICE_NAMES[$(($n-1))]} 
        ARG_LOG_DIR=${DEFAULT_ARG_LOG_DIRS[$(($n-1))]}
        ARG_NOT_COLLECT_TODAY_FILE=${DEFAULT_ARG_SKIP_TODAY_LOG_FILE[$(($n-1))]}
        ARG_FTP_REMOTEPATH=${DEFAULT_ARG_FTP_REMOTEPATH[$(($n-1))]}

        printf  "      %-15s %-18s %-30s %s\n" $ARG_SERVICE_NAME $ARG_NOT_COLLECT_TODAY_FILE $ARG_FTP_REMOTEPATH $ARG_LOG_DIR
    done

    echo -e "\033[0m"
}

DEFAULT_ARG_SERVICE_NAMES=(
mme
sgw
pgw
pgwUserDataLog)

DEFAULT_ARG_FTP_REMOTEPATH=(
/root/astri/mme/
/root/astri/sgw/
/root/astri/pgw/
/root/astri/pgw/userDataLog/
)

DEFAULT_ARG_LOG_DIRS=(
/root/astri/mme/mme1/log/
/root/astri/sgw/sgw1/log/
/root/astri/pgw/pgw1/log/
/root/astri/pgw/pgw1/log/userDataLog/
)

DEFAULT_ARG_SKIP_TODAY_LOG_FILE=(
False
False
False
True
)


ARG_FTP_SERVER=
ARG_FTP_USERNAME=
ARG_FTP_PASSWORD=
ARG_FTP_REMOTEPATH=
ARG_LOG_DIR=
ARG_SERVICE_NAME=
ARG_LOOP_CYCLE=10s
ARG_NOT_COLLECT_TODAY_FILE=False
ARG_LISTEN_DEFAULT_LOG_DIRS=False

for arg in $@; do
    if [ -z $1 ]; then break; fi
    case $1 in
        --ftp_server)
            ARG_FTP_SERVER=$2
            shift 2
            ;;
        --ftp_username)
            ARG_FTP_USERNAME=$2
            shift 2
            ;;
        --ftp_password)
            ARG_FTP_PASSWORD=$2
            shift 2
            ;;
        --ftp_remotepath)
            ARG_FTP_REMOTEPATH=$2
            shift 2
            ;;
        --service_name)
            ARG_SERVICE_NAME=$2
            shift 2
            ;;
        --log_dir)
            ARG_LOG_DIR=$2
            shift 2
            ;;
       --skip_today_file)
            ARG_NOT_COLLECT_TODAY_FILE=$2
            shift 2
            ;;
        --loop_cycle)
            ARG_LOOP_CYCLE=$2
            shift 2
            ;;
        --listen_default_log_dirs)
            ARG_LISTEN_DEFAULT_LOG_DIRS=$2
            shift 2
            ;;
       --)
            shift
            break
            ;;
        --help|*)
            print_help
            exit 1
            ;;
    esac
done


if [ $ARG_LISTEN_DEFAULT_LOG_DIRS == True ]; then
    if [ -z $ARG_FTP_SERVER ] || [ -z $ARG_FTP_USERNAME ] || \
       [ -z $ARG_FTP_PASSWORD ] || [ -z $ARG_LOOP_CYCLE ] ; then
        echo "ftp_server = $ARG_FTP_SERVER"
        echo "ftp_username = $ARG_FTP_USERNAME"
        echo "ftp_password = $ARG_FTP_PASSWORD"
        echo "loop_cycle = $ARG_LOOP_CYCLE"
        echo "listen_default_log_dirs = $ARG_LISTEN_DEFAULT_LOG_DIRS"
        echo -e "\033[31mInvalid arguments, please check help document.\033[0m"
        print_help
        exit 1
    fi
fi


if [ $ARG_LISTEN_DEFAULT_LOG_DIRS == False ]; then
    if [ -z $ARG_FTP_SERVER ] || [ -z $ARG_FTP_USERNAME ] || [ -z $ARG_FTP_PASSWORD ] || \
       [ -z $ARG_FTP_REMOTEPATH ] || [ -z $ARG_LOOP_CYCLE ] || [ -z "$ARG_LOG_DIR" ] || \
       [ -z $ARG_SERVICE_NAME ] || [ -z $ARG_NOT_COLLECT_TODAY_FILE ] ; then
        echo "ftp_server = $ARG_FTP_SERVER"
        echo "ftp_username = $ARG_FTP_USERNAME"
        echo "ftp_password = $ARG_FTP_PASSWORD"
        echo "ftp_remotepath = $ARG_FTP_REMOTEPATH"
        echo "service_name = $ARG_SERVICE_NAME"
        echo "log_dir = $ARG_LOG_DIR"
        echo "loop_cycle = $ARG_LOOP_CYCLE"
        echo "skip_today_file = $ARG_NOT_COLLECT_TODAY_FILE"
        echo "listen_default_log_dirs = $ARG_LISTEN_DEFAULT_LOG_DIRS"
        echo -e "\033[31mInvalid arguments, please check help document.\033[0m"

        print_help
        exit 1
    fi
fi

if [ $ARG_LISTEN_DEFAULT_LOG_DIRS != True -a $ARG_LISTEN_DEFAULT_LOG_DIRS != False ]; then
    echo -e "\033[31mInvalid argument: --listen_default_log_dirs '$ARG_LISTEN_DEFAULT_LOG_DIRS'.\033[0m"
    exit 1
fi

if [ $ARG_NOT_COLLECT_TODAY_FILE != True -a $ARG_NOT_COLLECT_TODAY_FILE != False ]; then
    echo -e "\033[31mInvalid argument: --skip_today_file '$ARG_NOT_COLLECT_TODAY_FILE'.\033[0m"
    exit 1
fi

if [ ! -d $ARG_LOG_DIR ]; then
    echo -e "\033[31mInvalid argument: --log_dir '$ARG_LOG_DIR' is not a directory.\033[0m"
    exit 1
fi

###############################################################################

function setup_astri_backup_log_service()
{
    SERVICE_NAME=astri-backup-logs-$ARG_SERVICE_NAME
    SERVICE_INIT_FILE=/etc/init.d/$SERVICE_NAME
    SERVICE_FILE=/usr/local/sbin/$SERVICE_NAME
    SERVICE_LOG_FILE=/var/log/$SERVICE_NAME.log
    SERVICE_FILE_OPTS="--service_name $ARG_SERVICE_NAME --log_dir $ARG_LOG_DIR --ftp_server $ARG_FTP_SERVER --ftp_username $ARG_FTP_USERNAME --ftp_password $ARG_FTP_PASSWORD --ftp_remotepath $ARG_FTP_REMOTEPATH --loop_cycle $ARG_LOOP_CYCLE --skip_today_file $ARG_NOT_COLLECT_TODAY_FILE"

    #
    # Setup service init.d file
    #
    echo -e "\033[32mSetup the $SERVICE_INIT_FILE with parameters:\033[0m"
    echo -e "$SERVICE_FILE_OPTS"
    echo ""
    touch $SERVICE_INIT_FILE
    chmod 755 $SERVICE_INIT_FILE
cat>$SERVICE_INIT_FILE<<EOF
    #! /bin/bash
    # Author: KK Yang <kkyang@astri.org>
    # Data: 2016-11-26

    touch /dev &> /dev/null
    if [ \$? -ne 0 ]; then
        echo -e "\033[31mYou need run this with root premission"
        exit
    fi

    function start_astri_daemon_check()
    {
        EXIST_SERVICE=\`ps aux | grep -E "$SERVICE_FILE" | grep -v grep\`
        if [ ! -z "\$EXIST_SERVICE" ]; then
            echo -e "\033[31mAlready have a ABL service, please stop it first.\033[0m"
            echo "\$EXIST_SERVICE"
            exit
        fi
    }

    function stop_astri_daemon()
    {
        ps aux | grep "$SERVICE_FILE" | grep -v grep | \\
            awk '{print \$2}' | xargs -i kill -9 {} > /dev/null
    }

    case "\$1" in
        start)
            echo -e "Starting daemon: \033[32m$SERVICE_NAME\033[0m"
            start_astri_daemon_check
            nohup $SERVICE_FILE $SERVICE_FILE_OPTS > $SERVICE_LOG_FILE &
            echo -e "To ensure every goes right, please check the service log: \033[32m$SERVICE_LOG_FILE\033[0m"
            ;;

        stop)
            echo -e "Stopping daemon: \033[32m$SERVICE_NAME\033[0m"
            stop_astri_daemon
            ;;

        restart)
            echo -e "Restarting daemon: \033[32m$SERVICE_NAME\033[0m"
            stop_astri_daemon
            nohup $SERVICE_FILE $SERVICE_FILE_OPTS > $SERVICE_LOG_FILE &
            echo -e "To ensure every goes right, please check the service log: \033[32m$SERVICE_LOG_FILE\033[0m"
            ;;
    esac
EOF


    #
    # Setup service script file 
    #
    echo -e "\033[32mSetup the $SERVICE_FILE\033[0m"
    echo ""
    touch $SERVICE_FILE
    chmod 755 $SERVICE_FILE
cat>$SERVICE_FILE<<EOF
    #! /bin/sh
    # Author: KK Yang <kkyang@astri.org>
    # Data: 2016-11-26

    ARG_FTP_SERVER=
    ARG_FTP_USERNAME=
    ARG_FTP_PASSWORD=
    ARG_FTP_REMOTEPATH=
    ARG_LOOP_CYCLE=
    ARG_LOG_DIR=
    ARG_SERVICE_NAME=
    ARG_NOT_COLLECT_TODAY_FILE=False

    for arg in \$@; do
        if [ -z \$1 ]; then break; fi

        case \$1 in
            --ftp_server)
                ARG_FTP_SERVER=\$2
                shift 2
                ;;
            --ftp_username)
                ARG_FTP_USERNAME=\$2
                shift 2
                ;;
            --ftp_password)
                ARG_FTP_PASSWORD=\$2
                shift 2
                ;;
            --ftp_remotepath)
                ARG_FTP_REMOTEPATH=\$2
                shift 2
                ;;
            --service_name)
                ARG_SERVICE_NAME=\$2
                shift 2
                ;;
           --log_dir)
                ARG_LOG_DIR=\$2
                shift 2
                ;;
            --loop_cycle)
                ARG_LOOP_CYCLE=\$2
                shift 2
                ;;
            --skip_today_file)
                ARG_NOT_COLLECT_TODAY_FILE=\$2
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done

    if [ -z \$ARG_FTP_SERVER ] || [ -z \$ARG_FTP_USERNAME ] || [ -z \$ARG_FTP_PASSWORD ] || \\
       [ -z \$ARG_FTP_REMOTEPATH ] || [ -z "\$ARG_LOG_DIR" ] || [ -z \$ARG_LOOP_CYCLE ] || \\
       [ -z \$ARG_SERVICE_NAME ] || [ -z \$ARG_NOT_COLLECT_TODAY_FILE ]; then
        echo "ftp_server = \$ARG_FTP_SERVER"
        echo "ftp_username = \$ARG_FTP_USERNAME"
        echo "ftp_password = \$ARG_FTP_PASSWORD"
        echo "ftp_remotepath = \$ARG_FTP_REMOTEPATH"
        echo "service_name = \$ARG_SERVICE_NAME"
        echo "log_dir = \$ARG_LOG_DIR"
        echo "loop_cycle = \$ARG_LOOP_CYCLE"
        echo "skip_today_file = \$ARG_NOT_COLLECT_TODAY_FILE"
        echo -e "\033[31mInvalid arguments, please run 'service astri-backup-logs start ' to check more.\033[0m"

        exit 1
    fi

    if [ \$ARG_NOT_COLLECT_TODAY_FILE != True -a \$ARG_NOT_COLLECT_TODAY_FILE != False ]; then
        echo -e "\033[31mInvalid argument: --skip_today_file '\$ARG_NOT_COLLECT_TODAY_FILE'.\033[0m"
        exit 1
    fi

    if [ ! -d \$ARG_LOG_DIR ]; then
        echo -e "\033[31mInvalid argument: --log_dir '\$ARG_LOG_DIR' is not a directory.\033[0m"
        exit 1
    fi

    ###############################################################################
    ###############################################################################
    #
    # function: setup the environment for this scripts 
    #
    function setup_scritp_env()
    {
        G_LOG_BACKUP_TIMESTAMP_FILE=\$ARG_LOG_DIR/backup-timestamp
        G_LOG_TYPE_NAME=\$ARG_SERVICE_NAME

        touch \$G_LOG_BACKUP_TIMESTAMP_FILE
        source \$G_LOG_BACKUP_TIMESTAMP_FILE
        if [ -z \$G_LAST_BACKUP_LOGS_TIMESTAMP ]; then
            echo "export G_LAST_BACKUP_LOGS_TIMESTAMP=0" > \$G_LOG_BACKUP_TIMESTAMP_FILE
            source \$G_LOG_BACKUP_TIMESTAMP_FILE
        fi

        lftp -v > /dev/null
        if [ \$? -ne 0 ]; then
            echo -e "\033[31mYou need to install the 'lftp' tools on your OS.\033[0m" 
            exit
        fi

        LAST_COLLECTED_LOGS_TIME=\$G_LAST_BACKUP_LOGS_TIMESTAMP
        COLLECTING_NEEDED=False
        COLLECTING_FILES=""
        COLLECTING_LOGS_TIME=0
    }

    #
    # function: destory the environment for this scripts
    #
    function destory_script_env()
    {
        exit
    }
     
    #
    # function: collecting logs
    #
    function collecting_logs()
    {
        files=\`ls -al \$ARG_LOG_DIR | awk '{print \$9}' | grep -E "astri" | xargs -i echo \$ARG_LOG_DIR/{}\`

        collected_failed=0
        collected_files=

        mkdir -p /backup

        # Creat directory for collecting logs
        collecting_dir=/backup/\${G_LOG_TYPE_NAME}-\`date +"%Y-%m-%d-%H:%M:%S"\`
        if [ -d \$collecting_dir ]; then
            rm -rf \$collecting_dir
        fi
        mkdir -p \$collecting_dir

        # Copy logs to temp directory
        for file in \$files; do
            origin_file_name=\`basename \$file\`
     
            new_file_name=\`echo \$origin_file_name | sed 's/^\.astri\.//'\`
            new_file_path=\$collecting_dir/\$new_file_name

            mv \$file \$new_file_path

            echo -e "\033[32mCollecting log file: \`basename \$file\`\033[0m"

            collected_files="\$collected_files \$new_file_path"
        done

        # Tar the backup log files
        collected_tar_file=\`echo \$collecting_dir | sed 's/:/./g'\`.tar.gz
        tar czvf \$collected_tar_file \$collecting_dir/ &> /dev/null

        send_logs_to_ftp_server \$collected_tar_file
        if [ \$? -ne 0 ]; then
            echo -e "\033[32mFailed at FTP Server."
            collected_failed=1

            # Roll back the failed log file
            for file in \$files; do
                origin_file_name=\`basename \$file\`
                origin_file_dir=\`dirname \$file\`
     
                new_file_name=\`echo \$origin_file_name | sed 's/^\.astri\.//'\`
                new_file_path=\$collecting_dir/\$new_file_name

                mv \$new_file_path \$file

                echo -e "\033[32mRoll back log file: \`basename \$file\`\033[0m"
            done
        fi

        # Remove the collected directory and tar file
        rm -rf \$collecting_dir
        rm -rf \$collected_tar_file

        return \$collected_failed
    }

    #
    # function:
    #
    function update_system_lasted_collected_time()
    {
        LAST_COLLECTED_LOGS_TIME=\$COLLECTING_LOGS_TIME

        echo "export G_LAST_BACKUP_LOGS_TIMESTAMP=\$LAST_COLLECTED_LOGS_TIME" > \$G_LOG_BACKUP_TIMESTAMP_FILE

        echo "Collected log finished at '\$LAST_COLLECTED_LOGS_TIME'"
    }

    #
    # function: send collected logs to ftp server
    #
    function send_logs_to_ftp_server()
    {
        file=\$1

        echo -e "\033[32m ------  \`basename \$file\`\033[0m"
        if [ ! -f "\$file" ]; then
            echo "ERROR: Invalid collected logs file === \$1"
            return 1
        fi

        echo "sending \$COLLECTING_TAR_FILE to sftp://\$ARG_FTP_USERNAME:\$ARG_FTP_PASSWORD@\$ARG_FTP_SERVER (\$ARG_FTP_REMOTEPATH)"
        
        lftp sftp://\$ARG_FTP_USERNAME:\$ARG_FTP_PASSWORD@\$ARG_FTP_SERVER  -e "cd \$ARG_FTP_REMOTEPATH; bye"
        if [ \$? -ne 0 ]; then
            echo -e "\033[31mFTP Server: '\$ARG_FTP_REMOTEPATH' doesn't existed or have no permission to execute."
            return 1;
        fi

        lftp sftp://\$ARG_FTP_USERNAME:\$ARG_FTP_PASSWORD@\$ARG_FTP_SERVER  -e "cd \$ARG_FTP_REMOTEPATH; put \$file; bye"
        if [ \$? -ne 0 ]; then
            echo -e "\033[31mFTP Server: Failed to upload '\$file' to FTP Server '\$ARG_FTP_REMOTEPATH'."
            return 1;
        fi

        return 0;
    }


    #
    # function: check whether we need collec the logs
    #
    function checking_logs()
    {
        COLLECTING_LOGS_TIME=0

        collecting_needed=0

        files=\`ls \$ARG_LOG_DIR | grep -E "[0-9]" | xargs -i echo \$ARG_LOG_DIR/{}\`

        for file in \$files; do
            file_time=\`date +"%Y-%m-%d %H:%M:%S" -r \$file\`

            time=\`echo \$file_time | xargs -i date -d {} +%s\`

            if [ \$ARG_NOT_COLLECT_TODAY_FILE == True ]; then
                today=\`date  +"%Y-%m-%d" | xargs -i  date -d {} +"%s"\` 
                if [ \$time -gt \$today ]; then
                    continue;
                fi
            fi

            if [ \$time -gt \$LAST_COLLECTED_LOGS_TIME ]; then
                origin_file_name=\`basename \$file\`

                new_file_prefix=\`echo \$origin_file_name | sed 's/\.[0-9].*//g'\`
                new_file_name=".astri."\$new_file_prefix-\`date -d "\$file_time" +"%Y-%m-%d-%H:%M:%S"\`
                new_file=\$ARG_LOG_DIR/\$new_file_name

                mv \$file \$new_file
                echo -e "\033[32mFind new log file: \`basename \$file\` ---- \`basename \$new_file\`\033[0m"

                collecting_needed=1

                if [ \$time -gt \$COLLECTING_LOGS_TIME ]; then
                    COLLECTING_LOGS_TIME=\$time
                fi
            fi
        done

        return \$collecting_needed
    }

    ###############################################################################
    ###############################################################################

    setup_scritp_env \$@

    while true; do
        checking_logs
        if [ \$? = 1 ]; then
            collecting_logs
            if [ \$? -eq 0 ]; then
                update_system_lasted_collected_time
            else
                echo -e "\033[31mFailed to backup log at '\`date +"%Y-%m-%d-%H:%M:%S"\`'\033[0m"
            fi
        fi

        echo "sleeping..... ", \$ARG_LOOP_CYCLE
        sleep \$ARG_LOOP_CYCLE
    done

    destory_script_env
EOF

    echo -e "Congratulations! You have setup the Astri-Backup-Logs service successfully."
    echo -e "Now, you just need to start the ABL service throught:"
    echo -e "\033[32m  $ sudo service $SERVICE_NAME start \033[0m"
}


# If user want to use this default argument, then we need to assume that user
# is every famil
if [ $ARG_LISTEN_DEFAULT_LOG_DIRS == True ]; then
    for n in $(seq 1 ${#DEFAULT_ARG_LOG_DIRS[@]}); do
        ARG_SERVICE_NAME=${DEFAULT_ARG_SERVICE_NAMES[$(($n-1))]} 
        ARG_LOG_DIR=${DEFAULT_ARG_LOG_DIRS[$(($n-1))]}
        ARG_NOT_COLLECT_TODAY_FILE=${DEFAULT_ARG_SKIP_TODAY_LOG_FILE[$(($n-1))]}
        ARG_FTP_REMOTEPATH=${DEFAULT_ARG_FTP_REMOTEPATH[$(($n-1))]}

        if [ ! -d $ARG_LOG_DIR ]; then
            echo -e "\033[31mInvalid log directory: $ARG_LOG_DIR"
            exit 1;
        fi

        echo -e "\033[33m\n\n======================================================================\033[0m"
        echo -e "\033[33mSetting up service: $ARG_SERVICE_NAME [$ARG_NOT_COLLECT_TODAY_FILE]---> $ARG_LOG_DIR [$ARG_FTP_REMOTEPATH]\033[0m"
        setup_astri_backup_log_service

    done


    echo -e "\033[33m\n\n======================================================================\033[0m"
    for n in $(seq 1 ${#DEFAULT_ARG_LOG_DIRS[@]}); do
        ARG_SERVICE_NAME=${DEFAULT_ARG_SERVICE_NAMES[$(($n-1))]} 
        SERVICE_NAME=astri-backup-logs-$ARG_SERVICE_NAME
        sudo service $SERVICE_NAME start
    done
 
    exit 0
fi

setup_astri_backup_log_service
