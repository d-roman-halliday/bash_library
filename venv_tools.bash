    
check_venv(){
  if [[ "$VIRTUAL_ENV" != "" ]]
  then
    INVENV=1
  else
    INVENV=0
  fi
}

kickof_venv(){
  # Check venv is running, if it isn't start it
  check_venv
  if [[ INVENV -eq 0 ]]
  then
    # Lazy way to get first instance of activate file found (looking in this directory)
    activate_script_location=`find . -type f -name 'activate' | head -n 1`
    
    # Lazy way to get first instance of activate file found (looking in the parent directory)
    if [[ ! -f "${activate_script_location}" ]]
    then
      activate_script_location=`find .. -type f -name 'activate' | head -n 1`
    fi
    
    #If variable references a file, source it
    if [[ -f "${activate_script_location}" ]]
    then
      echo "Starting venv from: ${activate_script_location}"
      source "${activate_script_location}"
    else
      echo "No venv activate file found: ${activate_script_location}"
    fi
  fi
  
  # Check venv is running, if it isn't throw an error
  check_venv
  if [[ INVENV -eq 0 ]]
  then
    echo "ERROR: venv not running, unable to start: ${activate_script_location}"
    exit 1
  fi
}