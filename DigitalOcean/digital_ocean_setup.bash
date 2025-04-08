#!/bin/bash

################################################################################
# Helper Functions
################################################################################

check_sudo_root() {
  local attempts=0
  local max_attempts=3

  while true; do
    if sudo -n true 2>/dev/null; then
      if sudo whoami | grep -q '^root$'; then
        echo "Sudo access and root permissions are working."
        return 0 # Success
      else
        echo "Sudo access is working, but you are not root."
        return 1 # Sudo working, but not root
      fi
    else
      attempts=$((attempts + 1))
      if [[ "$attempts" -le "$max_attempts" ]]; then
        echo "Sudo access is not working. Please try again (attempt $attempts/$max_attempts)."
        read -p "Press Enter to try again, or type 'q' to quit: " choice
        if [[ "$choice" == "q" ]]; then
          echo "Exiting."
          return 2 # User chose to quit
        fi
      else
        echo "Sudo access failed after $max_attempts attempts."
        echo "Please check your sudo configuration or contact your system administrator."
        echo "Exiting."
        return 3 # Failed after multiple attempts
      fi
    fi
  done
}

check_previous_command() {
  local previous_exit_code="$?"
  local choice

  if [[ "$previous_exit_code" -ne 0 ]]; then
    echo "Previous command failed with exit code: $previous_exit_code"
    read -p "Do you want to halt the program? (y/N): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      echo "Halting the program."
      exit 1 # Exit with a non-zero code to indicate failure
    else
      echo "Continuing the program."
    fi
  fi
}

################################################################################
# Core Execution
################################################################################

################################################################################
# Check for root/sudo access
if check_sudo_root; then
  echo "Continuing with root privileges..."
else
  echo "Could not verify sudo and root access."
  exit 1
fi

################################################################################
# Update packages
sudo apt-get update && sudo apt-get update -y

# Check the result
check_previous_command

################################################################################
# More to come in the future 
################################################################################

