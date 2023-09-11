#!/bin/bash

source table_operations.sh
source general_functions.sh

create_database() {
  read -p "Enter the name of the database: " dbname

  # check if the database name (dir) already exists
  # if yes => view "Database already exists"
  if is_valid_name "$dbname" "database"; then
    mkdir -p $dbname
    important_info_message "Database ($dbname) created successfully." "success"
  fi
}


list_databases() {
  clear

  # check if the main dir is empty
  dirs=$(ls -d */ 2>/dev/null)  # Redirecting any errors to /dev/null
  if [ -z $dirs ]; then
    # if yes => view "No databases to list"
    error_message "No databases to show"
  else
    # if no => view databases (dirs) available
    important_info_message "Available databases"

    # Looping through directories and displaying them in a formatted manner
    for db in $dirs; do
      printf "| %-38s |\n" "${db%/}"
    done

    printf "%-42s\n" | tr ' ' '-'
  fi
}


connect_to_database() {
  read -p "Enter the name of the database: " dbname

  # Check for an empty input
  if [[ -z $dbname ]]; then
      error_message "You must provide a database name"
      return 1
  fi

  # check if the database name (dir) already exists
  # if yes => table_menu() ( table_operations.sh )
  clear
  if [ -d "$dbname" ]; then
    cd ./$dbname
    important_info_message "Connected to database ($dbname)." "success"
    table_menu
    return

  # if no => view "Database doesn't exist"
  else
    error_message "Database ($dbname) doesn't exist."
  fi
}


drop_database() {
  read -p "Enter the name of the database: " dbname

  # check if the database name  (dir) already exists
  # if yes => view "Are you sure you want to drop database (name)"
  # if yes => delete database (dir) with the same name
  # view "Database dropped successfully"
  clear
  if [ -d "$dbname" ]; then
   clear
   printf "\n%s\n" " ------------------------------------------------- "
   printf "| %-45s  |\n" "Are you sure you want to drop database ($dbname)?"
   printf "| %-45s  |\n" "1. Yes"
   printf "| %-45s  |\n" "2. No"
   printf "%s\n" " ------------------------------------------------- "

  read -p "| Enter your choice: " choice

  case $choice in
    1) rm -r $dbname
        important_info_message "Database ($dbname) dropped successfully." "success";;
    2) return ;;
    *) error_message "Invalid choice try again!" ;;
  esac
    return

  # if no => view "Database dosen't exist"
  else
    error_message "Database ($dbname) dosen't exist."
  fi
}
