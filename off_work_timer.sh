#!/bin/bash
kill_notice(){
    sleep 5;
    kill $(pgrep ^notify-osd$) 2>/dev/null;
}
time_str_off="18:30:00";
time_str_noon_break="12:00:00";

if [ ! -z "$2" ]; then
    time_str_off="$2";
fi

while [ 1=1 ]; do
    off=$(date -d "today $time_str_off" +%s);
    noon_break=$(date -d "today $time_str_noon_break" +%s)
    now=$(date +%s);
    if [ $now -lt $noon_break ];then
        seconds=$(($noon_break-$now));
    else
        seconds=$(($off-$now));
    fi

    echo -n "$(date -u --date @$seconds +%H:%M:%S)\r";
    
    if [ $now -eq $noon_break ];then
        sudo -u joe notify-send -i face-tired " Time off! Go back and relax!";
        kill_notice &
    elif [ $now -eq $off ];then
        sudo -u joe notify-send -i face-cool " Work off! Feed your cat and do some exercise!";
        kill_notice &
    elif [ $(($seconds % 3600)) -eq 0 ];then
        sudo -u joe notify-send -i face-smile " take a break";
        kill_notice &
    fi

    if [ $now -eq $(date -d "today 11:05:00" +%s) ];then
        sudo -u joe notify-send " Time to order food";
        kill_notice &
    fi

    # with command args
    #     -d    show time left
    #     -f    hold and never stop, working everyday
    #     -t 17:00
    if [ ! -z "$1" ];then
        if [ "$1" = "-d" ]; then
            echo "$(date -u --date @$seconds +%H:%M:%S)";
            break
        elif [ "$1" = "-f" ]; then
            continue
        fi
    # with no args, break when off work
    elif [ $((($seconds - 0) < 0)) -eq "1" ];then
        break
    fi
    sleep 1;
done
