hbf_date_loop_help() {
    echo "Take a command and execute it for each date in a range (using date as argument)"
    echo "    -s  : Start Date YYYY-MM-DD"
    echo "    -e  : End Date   YYYY-MM-DD"
    echo "    -c  : Command (string)"
    echo "    -f  : Format (see date command man page for formats)"
    echo " -h -H  : Help (this text)"
    echo ""
    echo "Examples:"
    echo 'bf_date_loop -s "2018-04-28" -e "2018-05-03" -c "echo date: " -f "%Y%m%d"'
    echo 'bf_date_loop -s "2018-04-28" -e "2018-05-03" -c "date --date " -f "%F"'
}


hbf_is_date() {
    local -x string_to_check="${1}"
    local -i date_check_count=0

    #Check using grep (forces a format)
    date_check_count=`echo "${string_to_check}" | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' | wc -l`

    if [ ${date_check_count} -eq 1 ]
    then
        #Check using date command
        date_check_count=`date -d "${string_to_check}" | wc -l`
    fi
    
    if [ ${date_check_count} -eq 1 ]
    then
        #Print 1 = True
        echo "1"
        #Exit status success
        #return 0
    else
        #Print 0 = False
        echo "0"
        #Exit status failure
        #return 1
    fi
}

bf_date_loop() {
    #Set vars to 0 so that they contain a value (used to check later)
    local -i sdate_set=0
    local -i edate_set=0
    local -i command_set=0
    local -i format_set=0
 
    #options that require a further argument mut be followed by a further argument, if not they are passed to the case ":"
    while getopts "s:e:c:f:hH" opt
    do
        case $opt in
            s)
                local -i hbf_is_date_argument=$(hbf_is_date "$OPTARG")
                if [ ${hbf_is_date_argument} -eq 1 ]
                then
                    local -i sdate="$(date +"%Y%m%d" --date "$OPTARG")"
                    sdate_set=1
                else
                    echo "Not a valid date: $OPTARG"
                    echo "Exiting"
                    return 1
                fi
                ;;
            e)
                local -i hbf_is_date_argument=$(hbf_is_date "$OPTARG")
                if [ ${hbf_is_date_argument} -eq 1 ]
                then
                    local -i edate="$(date +"%Y%m%d" --date "$OPTARG")"
                    edate_set=1
                else
                    echo "Not a valid date: $OPTARG"
                    echo "Exiting"
                    return 1
                fi
                ;;
            c)
                local -x command="$OPTARG"
                command_set=1
                ;;
            f)
                local -x format="$OPTARG"
                format_set=1
                ;;
            h|H)
                hbf_date_loop_help
                return 0
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
 
    unset opt
    unset OPTARG
    unset OPTIND
 
    #Check the required paramaters are set
    if [ ${sdate_set} -eq 0 ]
    then
        echo "Not Set: sdate : ${sdate_set}"
        hbf_date_loop_help
        return 1
    fi
    if [ ${edate_set} -eq 0 ]
    then
        echo "Not Set: edate : ${edate_set}"
        hbf_date_loop_help
        return 1
    fi
    if [ ${command_set} -eq 0 ]
    then
        echo "Not Set: command : ${command_set}"
        hbf_date_loop_help
        return 1
    fi
    if [ ${format_set} -eq 0 ]
    then
        echo "Not Set: format : ${format_set}"
        hbf_date_loop_help
        return 1
    fi
 
    #Check that start date is before end date. If not, throw error and exit.
    if [ ${edate} -lt ${sdate} ]
    then
        echo "End Date LESS THAN start date!"
        hbf_date_loop_help
        return 1
    fi
 
    echo "Loop From: $(date +"${format}" -d "${sdate}")"
    echo "       To: $(date +"${format}" -d "${edate}")"
    echo "=================================="

    #Current date (we want to start from start date)
    declare -i cdate=$(date +"%Y%m%d" -d "${sdate}")
 
    #loop for all dates in order:
    while [ ${edate} -ge ${cdate} ]
    do
      #Processing date (with a different format to the numerical counters)
      pdate=$(date +"${format}" -d "${cdate}")
      echo "Processing command  : ${command}"
      echo "Processing for date : ${pdate}"
      ${command} "${pdate}"
      cdate=$(date +"%Y%m%d" -d "${cdate} + 1 day" )
      echo "=================================="
    done
}

