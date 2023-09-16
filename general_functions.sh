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
    local type=$2
    # This should describe the type of entity, e.g., 'database', 'table', 'column', etc.

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

# Removes leading and trailing spaces
trim() {
    echo "$1" | sed -e 's/^ *//' -e 's/ *$//'
}

is_valid_int() {
    local value=$1
    local max_int=2147483647

    # Check if the value has leading zeros
    if [[ "$value" =~ ^0[0-9]+ ]]; then
        return 1
    fi

    # Check if the value is a positive integer
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    # Check if the value exceeds the maximum allowed integer
    if [[ $value -gt $max_int ]]; then
        return 1
    fi

    return 0
}


is_valid_string(){
    local string="$1"

    # Check for an empty name
    if [[ -z "$string" ]]; then
        error_message "Error: value cannot be empty."
        return 1
    fi

    # Check the length of the name
    local length=${#string}
    if [[ $length -lt 2 || $length -gt 40 ]]; then
        error_message "Error: value must be between 1 and 40 characters in length."
        return 1
    fi

    if [[ ! $string =~ ^[a-zA-Z][a-zA-Z0-9\ ]*$ ]]; then
        error_message "Error: $type name should start with a character and can contain characters, numbers, and spaces."
        return 1
    fi


    # Check if name contains a comma
    if [[ "$string" =~ , ]]; then
        error_message "Error: vlaue should not contain commas."
    return 1
    fi

    # If all checks passed
    return 0
}

is_valid_date(){
    local value=$1
    if [[ ! "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    return 0
}

is_valid_date() {
    local date="$1"
    if [[ ! "$date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
        return 1
    fi

    # Extract year, month, and day
    local year="${BASH_REMATCH[1]}"
    local month="${BASH_REMATCH[2]}"
    local day="${BASH_REMATCH[3]}"

    # Check for valid month
    if (( month < 1 || month > 12 )); then
        return 1
    fi

    # Check for valid day based on month
    case "$month" in
        "01"|"03"|"05"|"07"|"08"|"10"|"12")
            if (( day < 1 || day > 31 )); then
                return 1
            fi
            ;;
        "04"|"06"|"09"|"11")
            if (( day < 1 || day > 30 )); then
                return 1
            fi
            ;;
        "02")
            # Check for leap year
            if (( year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) )); then
                # February in a leap year
                if (( day < 1 || day > 29 )); then
                    return 1
                fi
            else
                # February in a non-leap year
                if (( day < 1 || day > 28 )); then
                    return 1
                fi
            fi
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}


table_exists(){
    local table_name=$1

    # Check for an empty table name
    if [[ -z $table_name ]]; then
        error_message "Error: table name cannot be empty."
        return 1
    fi
    # Check if table exists
    if [[ ! -f "$table_name.tbl" ]]; then
        error_message "Table ($table_name) doesn't exist."
        return 1
    fi
    return 0
}
