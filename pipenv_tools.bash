


xk_pipenv_safe_shell_start() {
  # If pipenv is already running we are good
  if [ -n "${PIPENV_ACTIVE}" ] && [ "${PIPENV_ACTIVE}" -eq 1  ]
  then
  	return 0
  fi

  # If not, are we in a place to run it
  pipenv verify
  if [ $? -eq 0 ]
  then
  	# We are in the right place to start it
  	pipenv shell
  	
  	# Did it work
  	if [ $? -eq 0 ]
  	then
  	  return 0
  	else
  	  echo "Something went wrong starting peipenv shell"
  	  return 1
  	fi
  else
    echo "Not in the right place to run pipenv shell"
    return 0
  fi

}