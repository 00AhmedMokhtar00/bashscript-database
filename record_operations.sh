#!/bin/bash

source general_functions.sh




# Prompts the user to enter a table name, columns, and a primary key column.

# Creates a new .tbl file for the table with the provided name
# and saves the primary key and columns into the file.
create_table() {
  # Prompt for Table Name
  while true; do
    read -p "Enter the name of the table: " table_name
    table_name=$(trim "$table_name")
    if is_valid_name "$table_name" "table"; then
        break
    fi
  done

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


  echo "primary_key:$primary_key" > "${table_name}.tbl"
  for index in "${!column_array[@]}"; do
    printf "%s " "${column_array[$index]}:${data_type_array[$index]}" >> "${table_name}.tbl"
  done
  # remove trailing white space in the columns line in the table
  sed -i '' '2s/[[:space:]]*$//' ${table_name}.tbl

  important_info_message "Table created." "success"
}

# Lists all available .tbl files, which represent the tables in the database.
list_tables() {
  # check if the current dir is empty
  # if yes => view "No tables to list"
  tables=$(ls *.tbl 2>/dev/null)  # Redirecting any errors to /dev/null
  if [ -z "$tables" ]; then
    error_message "No tables to show"
  else
    # if no => view tables (dirs) available
    important_info_message "Available tables"
    # Looping through tables and displaying them in a formatted manner
    for tb in $tables; do
      printf "| %-38s |\n" "${tb%.tbl}"
    done
    printf "%-42s\n" | tr ' ' '-'
  fi
}


# Prompts the user for a table name.
# Check first:
#   - if the table exists drop and show success message.
#   - if the table doesn't exists show information message.
# In both cases we should go back to the tables menu
drop_table() {

}


alter_table() {
    # menu (insert/update/delete/back)
}

