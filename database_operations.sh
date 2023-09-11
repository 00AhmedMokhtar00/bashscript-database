#!/bin/bash

source table_operations.sh

create_database() {
  read -p "Enter the name of the database: " dbname

  # check if the database name  (dir) already exists
  # if yes => view "Database already exists"
  if [ -d "$dbname" ]; then
    clear
    printf "%-42s\n" | tr ' ' '-'
    printf "| %-38s |\n" "Database ($dbname) already exists."
    printf "%-42s\n" | tr ' ' '-'
    return
    fi

  # if no => create database dir with the same name
  # view "Database created successfully"
    mkdir -p $dbname
    clear
    printf "%-42s\n" | tr ' ' '-'
    printf "| %-38s |\n" "Database ($dbname) created successfully."
    printf "%-42s\n" | tr ' ' '-'
}


list_databases() {
  clear

  # check if the main dir is empty
  # if yes => view "No databases to list"
  dirs=$(ls -d */ 2>/dev/null)  # Redirecting any errors to /dev/null
  if [ -z "$dirs" ]; then
    printf "%-33s\n" | tr ' ' '-'
    echo "|      No databases to show     |"
    printf "%-33s\n" | tr ' ' '-'
  else
    # if no => view databases (dirs) available
    printf "%-33s\n" | tr ' ' '-'
    echo "|      Available databases      |"
    printf "%-33s\n" | tr ' ' '-'
    # Looping through directories and displaying them in a formatted manner
    for db in $dirs; do
      printf "| %-28s  |\n" "${db%/}"
    done

    printf "%-33s\n" | tr ' ' '-'
  fi
}


connect_to_database() {
  read -p "Enter the name of the database: " dbname

  # check if the database name (dir) already exists
  # if yes => table_menu() ( table_operations.sh )
  clear
  if [ -d "$dbname" ]; then
    clear
    cd ./$dbname
    printf "%-42s\n" | tr ' ' '-'
    printf "| %-38s |\n" "Connected to database ($dbname)."
    printf "%-42s\n" | tr ' ' '-'
    table_menu
    return

  # if no => view "Database doesn't exist"
  else
    printf "%-42s\n" | tr ' ' '-'
    printf "| %-38s |\n" "Database ($dbname) doesn't exist."
    printf "%-42s\n" | tr ' ' '-'
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
        printf "%-42s\n" | tr ' ' '-'
        printf "| %-38s |\n" "Database ($dbname) dropped successfully."
        printf "%-42s\n" | tr ' ' '-';;
    2) return ;;
    *) echo "Invalid choice try again!" ;;
  esac
    return

  # if no => view "Database dosen't exist"
  else
  printf "%-42s\n" | tr ' ' '-'
  printf "| %-38s |\n" "Database ($dbname) dosen't exist."
  printf "%-42s\n" | tr ' ' '-'
  fi
}
