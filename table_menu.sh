#!/bin/bash

source table_operations.sh

table_menu() {

  # view list to the user to choose from ( crate table - drop table - list tables - alter table )
  while true; do
    printf "\n%s\n" " ------------------------- "
    printf "| %-22s  |\n" "Table Menu"
    printf "| %-22s  |\n" "1. Create Table"
    printf "| %-22s  |\n" "2. List Tables"
    printf "| %-22s  |\n" "3. Drop Table"
    printf "| %-22s  |\n" "4. Table Manipulation"
    printf "| %-22s  |\n" "5. Back to main menu"
    printf "| %-22s  |\n" "6. Exit"
    printf "%s\n" " ------------------------- "

    read -p "| Enter your choice: " choice

    printf "%s\n\n" " -------------------------"


  # if the user choose (crate table) => create_table() ( record_operations.sh )
  # if the user choose (drop table) => drop_table() ( record_operations.sh )
  # if the user choose (list tables) => list_tables() ( record_operations.sh )
  # if the user choose (alter table) => alter_table() ( record_operations.sh )
  case $choice in
      1) create_table ;;
      2) list_tables ;;
      3) drop_table ;;
      4) table_manipulation ;;
      5) cd ..
      break;;
      6) exit 0 ;;
      *) error_message "Invalid choice try again!" ;;
    esac
  done
}
