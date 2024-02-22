#!/bin/bash

# Remove-Sudo-Privileges-from-Logged-In-Users
#
# Created on: February 23, 2024
#
# Creator: Samstar777 aka Salim Ukani

# Define constants
LOG_FILE="/var/log/remove_sudo_privileges.log"
ERROR_LOG_FILE="/var/log/remove_sudo_privileges_error.log"
SUDOERS_FILE="/etc/sudoers"
SCRIPT_OWNER="$(stat -c '%U' "$0")"

# Function to log messages to standard output and log file
log() {
	local message="$1"
	echo "$(date +"%Y-%m-%d %T") - $SCRIPT_OWNER: $message" | tee -a "$LOG_FILE"
}

# Function to log errors to standard output and error log file
log_error() {
	local message="$1"
	echo "$(date +"%Y-%m-%d %T") - $SCRIPT_OWNER: ERROR: $message" | tee -a "$ERROR_LOG_FILE" >&2
}

# Function to remove sudo privileges from the current user
remove_sudo_privileges() {
	local current_user=$(ls -l /dev/console | awk '{ print $3 }')
	log "Removing sudo privileges from user: $current_user"
	if sudo sed -i "/^$current_user/d" "$SUDOERS_FILE"; then
		log "Sudo privileges successfully removed for user: $current_user"
	else
		log_error "Failed to remove sudo privileges for user: $current_user"
	fi
}

# Main script
main() {
	log "Script started"
	if [[ $(id -u) -ne 0 ]]; then
		log_error "Script must be run as root or with sudo privileges"
		exit 1
	fi
	
	if [ ! -w "$SUDOERS_FILE" ]; then
		log_error "Cannot write to sudoers file: $SUDOERS_FILE"
		exit 1
	fi
	
	remove_sudo_privileges
	log "Script completed"
}

# Execute main script
main
