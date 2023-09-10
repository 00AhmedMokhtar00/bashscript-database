#!/bin/bash

# source table_operations.sh

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
  printf "| %-38s |\n" "Database created ($dbname)"
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

  # check if the database name (dir) already exists

  # if yes => table_menu() ( table_operations.sh )

  # if no => view "Database doesn't exist"
}

drop_database() {

  # check if the database name  (dir) already exists

  # if no => view "Database dosen't exist"

  # if yes => view "Are you sure you want to drop database (name)"
    # if yes => delete database (dir) with the same name
    # view "Database dropped successfully"

}
