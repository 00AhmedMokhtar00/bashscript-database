#!/bin/bash

source general_functions.sh

create_table() {
  # Prompt for Table Name
  while true; do
    read -p "Enter the name of the table: " table_name
    table_name=$(trim "$table_name")
    if is_valid_name "$table_name" "table"; then
        break
    fi
  done
  # Prompt for columns
  while true; do
    read -p "Enter the columns (separated by comma): " columns

    # Check if user didn't enter anything
    if [[ -z $columns ]]; then
      error_message "Table must contain at least one column!"
      continue
    fi

    IFS=',' read -ra column_array <<< "$columns"

    valid=true
    duplicate_check=()

    for col in "${column_array[@]}"; do
      col=$(trim "$col")

      # Check if column names are valid
      if ! is_valid_name "$col" "column"; then
        valid=false
        break
      fi

      # Check for duplicates
      if [[ " ${duplicate_check[@]} " =~ " $col " ]]; then
        error_message "Error: Duplicate column name '$col' detected."
        valid=false
        break
      fi

      duplicate_check+=("$col")
    done

    if [[ $valid == true ]]; then
      break
    fi
  done


  # Ask for data types and validate
  data_type_array=()
  for col in ${column_array[@]}; do
    while true; do
      read -p "Enter the data type for column '$col' (int, string, date): " data_type
      if [[ $data_type == "int" || $data_type == "string" || $data_type == "date" ]]; then
        data_type_array+=($data_type)
        break
      else
        error_message "Error: Invalid data type. Please enter 'int', 'string', or 'date'."
      fi
    done
  done


  # Prompt for Primary Key
  while true; do
    read -p "Enter the primary key column: " primary_key

    # Check for an empty name
    if [[ -z $primary_key ]]; then
        error_message "you must specify a primary key!"
        continue
    fi

    # Check if primary key exists in columns
    if ! [[ " ${column_array[@]} " =~ " ${primary_key} " ]]; then
       error_message "The primary key column does not exist among the provided columns."
      continue
    fi
    break
  done

   # Creates a new .tbl file for the table with the provided name and saves the primary key and columns into the file.
  echo "primary_key:$primary_key" > "${table_name}.tbl"
  for index in "${!column_array[@]}"; do
    printf "%s " "${column_array[$index]}:${data_type_array[$index]}" >> "${table_name}.tbl"
  done
  # remove trailing white space in the columns line in the table
  sed -i '' '2s/[[:space:]]*$//' ${table_name}.tbl

  important_info_message "Table created." "success"
}


list_tables() {
  # check if the current dir is empty
  # if yes => view "No tables to list"
  tables=$(ls *.tbl 2>/dev/null)  # Redirecting any errors to /dev/null
  if [ -z "$tables" ]; then
    error_message "No tables to show"
  else
    # if no => view tables (.tbl files) available
    important_info_message "Available tables"
    # Looping through tables and displaying them in a formatted manner
    for tb in $tables; do
      printf "| %-38s |\n" "${tb%.tbl}"
    done
    printf "%-42s\n" | tr ' ' '-'
  fi
}


drop_table() {

  read -p "Enter the name of the Table: " table_name
  
  # Check for an empty input
  if [[ -z $table_name ]]; then
      error_message "You must provide a Table name"
      return 1
  fi

  # check if the table name (.tbl file) already exists
  # if yes => view "Are you sure you want to drop Table (name)"
   # if yes => delete table (.tbl file) with the same name
   # view "Table dropped successfully"
  
  clear
  if [ -f "$table_name".tbl ]; then
   clear
   printf "\n%s\n" " ------------------------------------------------- "
   printf "| %-45s  |\n" "Are you sure you want to drop Table ($table_name)?"
   printf "| %-45s  |\n" "1. Yes"
   printf "| %-45s  |\n" "2. No"
   printf "%s\n" " ------------------------------------------------- "

  read -p "| Enter your choice: " choice

  case $choice in
    1) rm $table_name.tbl
        important_info_message "Table ($table_name) dropped successfully." "success";;
    2) return ;;
    *) error_message "Invalid choice try again!" ;;
  esac
    return

  # if no => view "Table dosen't exist"
  else
    error_message "Table ($table_name) dosen't exist."
  fi  
}


alter_table() {
  # view list to the user to choose from ( crate table - drop table - list tables - alter table )
  while true; do
    printf "\n%s\n" " ------------------------- "
    printf "| %-22s  |\n" "Alter Table"
    printf "| %-22s  |\n" "1. Insert into Table"
    printf "| %-22s  |\n" "2. Select from Table"
    printf "| %-22s  |\n" "3. Update Table"
    printf "| %-22s  |\n" "4. Delete from Table"
    printf "| %-22s  |\n" "5. Back to Table menu"
    printf "| %-22s  |\n" "6. Exit"
    printf "%s\n" " ------------------------- "

    read -p "| Enter your choice: " choice

    printf "%s\n\n" " -------------------------"


  # if the user choose (crate table) => create_table() ( record_operations.sh )
  # if the user choose (drop table) => drop_table() ( record_operations.sh )
  # if the user choose (list tables) => list_tables() ( record_operations.sh )
  # if the user choose (alter table) => alter_table() ( record_operations.sh )
  case $choice in
      1) insert_into_table ;;
      2) select_from_table ;;
      3) update_table ;;
      4) delete_from_table ;;
      5) break;;
      6) exit 0 ;;
      *) error_message "Invalid choice try again!" ;;
    esac
  done
    
}
