GLOBAL_LIST=""

hbf_pidtree() {
    #Give a pid as an argument
    local -x parent=$1
    local -x list
    while [ "$parent" ]
    do
        #If list is empty, start a new one else append
        if [ -n "$list" ]
        then
            list="$list,$parent"
        else
            list="$parent"
        fi
 
        #Make sure that the list is clean with only commas in the middle (if any)
        parent=$(echo "$parent" | sed -e 's/,,*/,/g' -e 's/,$//g' -e 's/^,//g')
 
        # ps - get processes with this ID as a parent
        #sed - filter out all but numerical characters (no spaces etc...)
        # tr - translate newline characters (multiple processes with one parent) to commas.
        #sed - remove any multiple commas
        #sed - remove any trailing comma
        parent=$(ps --ppid "$parent" -o pid h \
                   | sed -e 's/[^0-9]//g'     \
                   | tr '\n' ','              \
                   | sed -e 's/,,*/,/g'       \
                         -e 's/,$//g')
    done

    #Use ps to print the details of all processes in the list
    ps -f -p "$list" f

    #Update the GLOBAL list (split by pipe)
    GLOBAL_LIST="$list,${GLOBAL_LIST}"
}

#View running .sh scripts
bf_script_view() {
    GLOBAL_LIST=""
    local -i produce_output=1

    #get all pids for entries in ps ending in .sh or .bash (all running shell scripts)
    for USERPID in `ps ax | grep "\.sh\|\.bash" | grep -v "grep" | sed 's/^ *//g' | cut -d " " -f 1`
    do
        produce_output=1

        #Check if this PID is already in the global list (output has already been produced)
		#If it is, switch to not produce any output
        for GLOBAL_LIST_PID in `echo "${GLOBAL_LIST}" | tr ',' '\n' `
        do
            if [ $USERPID -eq $GLOBAL_LIST_PID ]
            then
                produce_output=0
                break
            fi
        done

        if [ $produce_output -eq 1 ]
        then
            # Produce tree for PID
            hbf_pidtree "$USERPID"
        fi

    done
}
 
#View processes of all SSH users
bf_session_view() {
    GLOBAL_LIST=""
    local -i produce_output=1

    # Filter for parent pid types:
    # - sshd:       ssh connections
    # - SCREEN      screen sessions (even if they aren't actively connected)
    # - /bin/login  login, shows if anyone has an active session physicaly on the machine (rather than virtual ssh)
    for USERPID in `ps ax | grep "sshd: .*@pts/\|SCREEN\|/bin/login" | grep -v "grep" | sed 's,^ *,,g' | cut -d " " -f 1`
    do
        produce_output=1

        #Check if this PID is already in the global list (output has already been produced)
        #If it is, switch to not produce any output
        for GLOBAL_LIST_PID in `echo "${GLOBAL_LIST}" | tr ',' '\n' `
        do
            if [ $USERPID -eq $GLOBAL_LIST_PID ]
            then
                produce_output=0
                break
            fi
        done

        if [ $produce_output -eq 1 ]
        then
            # Produce tree for PID
            hbf_pidtree "$USERPID"
        fi


    done
}

