#! /bin/bash

if [ $# -lt 1 ]; then
    echo "ERROR: $0 [commands]"
    echo "ovs-appctl of/proto/trace [commands]"
    exit
fi

COMMANDS=$@
DEBUG_KEYWORD="OpenFlow actions|Rule|Final flow|Datapath actions"
LOG_FILE=/tmp/ovs-appctl.log

ct_zone=
recirc=

function parse_ct_recirc()
{
    Target=$1

    # Splite the 'Datapath actions' result
    Datapath_actions=`echo $Target | sed 's/.*Datapath actions//g'`
    echo -e "\033[32mDatapath Actions $Datapath_actions\033[0m"

    if [ -z "`echo $Datapath_actions | grep "zone"`" ]; then
        return 0
    fi

    # Splite the 'ct_zone' and 'recirc' result
    result=`echo $Datapath_actions | sed  's/.*\((.*)\).*\((.*)\).*/\1 \2/' | sed 's/zone=//g; s/(//g; s/)//g' `

    ct_zone=`echo $result | cut -d ' ' -f 1`
    recirc=`echo $result | cut -d ' ' -f 2`

    return 1
}

function print_match_rules()
{
    if [ -z $DEBUG ]; then
        return
    fi

    echo -e "\033[33m--------------------------------------------------------\n\033[0m"
    cat $LOG_FILE | sed 's/^[ \t]*//g' | grep  -E --color=auto "$DEBUG_KEYWORD"
}

sudo ovs-appctl ofproto/trace $COMMANDS -generate > $LOG_FILE

print_match_rules

while true; do
    ret=`cat $LOG_FILE`
    parse_ct_recirc "$ret"
    if [ $? -eq 0 ]; then
        break;
    fi

    sudo ovs-appctl ofproto/trace $COMMANDS,ct_zone=$ct_zone,recirc_id=$recirc -generate > $LOG_FILE

    print_match_rules
done
