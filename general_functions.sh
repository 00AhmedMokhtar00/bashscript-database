#!/bin/bash

# Messages colors
RED='\033[0;31m'  # Make the color of text Red
GREEN='\e[32m'    # Make the color of text Green
YELLOW='\033[33m' # Make the color of text Yellow
RESET='\033[0m'   # Resets the color to default

important_info_message() {
    local message="$1"
    local msg_type="$2"
    local min_width=42
    local total_width=$(( ${#message} + 4 ))  # 4 for spaces
    local COLOR=$YELLOW

    # Check the message type and set the color
    if [[ $msg_type == "success" ]]; then
        COLOR=$GREEN
    fi

    # Ensure total_width is at least min_width
    if [[ $total_width -lt $min_width ]]; then
        total_width=$min_width
    fi

    local padding_left=$(( (total_width - ${#message} - 2) / 2 ))  # -2 for the border characters
    local padding_right=$(( total_width - ${#message} - 2 - padding_left ))

    clear
    printf "%-${total_width}s\n" | tr ' ' '-'
    printf "|%*s${COLOR}%s${RESET}%*s|\n" "$padding_left" "" "$message" "$padding_right" ""
    printf "%-${total_width}s\n" | tr ' ' '-'
}


error_message() {
    local message=$1
    local min_width=42
    local total_width=$(( ${#message} + 4 ))  # 4 for spaces

    # Ensure total_width is at least min_width
    if [[ $total_width -lt $min_width ]]; then
        total_width=$min_width
    fi

    local padding_left=$(( (total_width - ${#message} - 2) / 2 ))  # -2 for the border characters
    local padding_right=$(( total_width - ${#message} - 2 - padding_left ))

    printf "\n%-${total_width}s\n" | tr ' ' '='
    printf "|%*s${RED}%s${RESET}%*s|\n" "$padding_left" "" "$message" "$padding_right" ""
    printf "%-${total_width}s\n\n" | tr ' ' '='
}


is_valid_name() {
    local name=$1
    local type=$2  # This should describe the type of entity, e.g., 'database', 'table', 'column', etc.

    # Check for an empty name
    if [[ -z $name ]]; then
        error_message "Error: $type name cannot be empty."
        return 1
    fi

    # Check the length of the name
    local length=${#name}
    if [[ $length -lt 2 || $length -gt 25 ]]; then
        error_message "Error: $type name must be between 2 and 25 characters in length."
        return 1
    fi

    # Check if name contains only valid characters
    if [[ ! $name =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        error_message "Error: $type name should only contain characters and numbers and should not start with a number."
        return 1
    fi

    # Check if a database with the given name already exists
    if [[ $type == "database" && -d "$name" ]]; then
        error_message "Error: A $type with the name '$name' already exists."
        return 1
    fi

    # Check if a table with the given name already exists
    if [[ $type == "table" && -e "$name.tbl" ]]; then
        error_message "Error: A $type with the name '$name' already exists."
        return 1
    fi

    # If all checks passed
    return 0
}


trim() {
  # Removes leading and trailing spaces
  echo $1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
