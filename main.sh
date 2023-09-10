#!/bin/bash

source database_operations.sh

main_menu() {
  while true; do
    printf "\n%s\n" " ------------------------- "
    printf "| %-22s  |\n" "Main Menu"
    printf "| %-22s  |\n" "1. Create Database"
    printf "| %-22s  |\n" "2. List Databases"
    printf "| %-22s  |\n" "3. Connect To Database"
    printf "| %-22s  |\n" "4. Drop Database"
    printf "| %-22s  |\n" "5. Exit"
    printf "%s\n" " ------------------------- "

    read -p "| Enter your choice: " choice

    printf "%s\n\n" " -------------------------"


    case $choice in
      1) create_database ;;
      2) list_databases ;;
      3) connect_to_database ;;
      4) drop_database ;;
      5) exit 0 ;;
      *) echo "Invalid choice" ;;
    esac
  done
}

main_menu
