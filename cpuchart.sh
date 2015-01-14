#!/bin/bash
  
# VARIABLES
  columns=40
  
# FUNCTIONS #
function draw()
{
        echo -en "\033[s"
        tput cup $1 $2
        echo -en "\033[1;3$3m$4\033[0m"
        echo -en "\033[u"
}
function wipe()
{
        echo -en "\033[s"
        tput cup $1 $2
        echo -en "\033[1;31m \033[0m"
        echo -en "\033[u"
}
#############
  
# HIDE CURSOR AND CLEAR SCREEN #
  tput civis & clear
  
while true; do
  
    # COLLECT UPDATE
    #
  
    idle=`mpstat 1 1 | grep "Average" | tail -1 | sed 's/ \+/ /g' | cut -d " " -f 11 | tr -d "\n"`;
  
    usage=`echo "scale=0;(100-$idle)/10" |bc`;
  
    # BACKUP PREVIOUS DATA #
    # CUT THE OLDEST LINE  #
    cat cpu.log | tail -$columns >> temp.tmp

    # UPDATE STATS #
    if [[ $usage -eq 0 ]];
    then
            # IF USAGE LESS THEN 20% DRAW SINGLE BAR #
            echo "1" >> temp.tmp
    else
            echo $usage >> temp.tmp
    fi

    # UPDATE LOG #
    cat temp.tmp > cpu.log
    rm temp.tmp

    # DRAW GRAPH #

    var=6;
    # BEGIN FROM COLUMN 1 #
    j=1

    while read usage
    do
            # DRAW USAGE #
            for i in `seq 1 $usage`
            do
                    top=`echo "11-$usage" | bc`
                    var=`echo "11-$i"     | bc`

                    if [[ $usage -gt 3 ]]; then
                            if [[ $usage -gt 6 ]]; then
                                    if [[ $var -eq $top ]];then
                                            draw    $var $j "1" "+"
                                    else
                                            draw    $var $j "1" "|"
                                    fi
                            else
                                    if [[ $var -eq $top ]];then
                                            draw    $var $j "3" "+"
                                    else
                                            draw    $var $j "3" "|"
                                    fi
                            fi
                    else
                            if [[ $var -eq $top ]]; then
                                    draw     $var $j "2" "+"
                            else
                                    draw     $var $j "2" "|"
                            fi
                    fi
            done

            # WIPE PREVIOUS BAR REMAINNING IF THEY EXIST #
            usage=`echo "$usage+1" | bc`

            for k in `seq $usage 11`;
            do
                    var=`echo "11-$k" | bc`
                    wipe $var $j
            done

            # PROCEED TO NEXT COLUMN #
            j=`echo "$j+1" | bc`

            # ADD LATENCY IF NEEDED #
            sleep 0.1

    done < "cpu.log"
    tput cup 11 0
#
done