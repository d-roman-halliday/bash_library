

xk_fetch_to_master() {
	
	# If pipenv is not running we shoud start it
    if ! [ -n "${PIPENV_ACTIVE}" ] || ! [ "${PIPENV_ACTIVE}" -eq 1  ]
    then
  	  	echo "Trying to start pipenv, if succesfull try again"
        xk_pipenv_safe_shell_start
        return 0
    fi
	
	# If pipenv is still not running we shoud stop
    if ! [ -n "${PIPENV_ACTIVE}" ] || ! [ "${PIPENV_ACTIVE}" -eq 1  ]
    then
  	  echo "pipenv not (or nolonger) running"
  	  return 1
    fi
	
	git fetch
	git checkout master
	git pull
	
	dbt clean
	dbt deps
}

#Fetch To Master (and rest)
alias ftm='xk_fetch_to_master'

#Generate and serve docs
alias gsd='dbt docs generate && dbt docs serve'