#!/bin/bash

source general_functions.sh




# Prompts the user to enter a table name, columns, and a primary key column.

# Creates a new .tbl file for the table with the provided name
# and saves the primary key and columns into the file.
create_table() {
  # Prompt for Table Name
  while true; do
    read -p "Enter the name of the table: " table_name
    table_name=$(trim $table_name)
    if is_valid_name $table_name "table"; then
        break
    fi
  done


  while true; do
    read -p "Enter the columns (separated by comma): " columns

    valid=true

    # Check if user didn't enter anything
    if [[ -z $columns ]]; then
      error_message "Table must contain at least one column!"
      continue 2
    fi

    # remove trailing comma if exists
    # columns="${columns%,}"

    # Convert columns into an array by separating the columns by commas
    IFS=',' read -ra column_array <<< $columns

    # Trim spaces from each individual column name
    for index in "${!column_array[@]}"; do
      column_array[$index]=$(trim ${column_array[$index]})
    done

    # Check if column names are valid
    for col in "${column_array[@]}"; do
      if is_valid_name $col "column"; then
          valid=false
          continue 2
      fi
    done


    # Check for valid column names and duplicate column names
    duplicate_check=()
    for col in "${column_array[@]}"; do
      # Check column name validity
      if [[ ! $col =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        echo "Error: Column name '$col' is invalid. Column names should only contain characters and numbers and should not start with a number."
        valid=false
        break
      fi

      # Check for duplicates
      duplicate_found=false
      for existing_col in ${duplicate_check[@]}; do
        if [[ $existing_col == $col ]]; then
          duplicate_found=true
          break
        fi
      done
      # if a duplicate found then prompt error message and start over
      if [[ $duplicate_found == true ]]; then
        echo "Error: Duplicate column name '$col' detected."
        valid=false
        break
      fi

      # Add the current column name into duplicate_check to ensure that
      # the user did not repeat it.
      duplicate_check+=($col)
    done

    # If columns are not valid, restart the loop to prompt for columns again
    if [[ $valid == false ]]; then
      continue
    fi

    # If columns are valid, break out of the loop to proceed to next steps
    break
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
        echo "Error: Invalid data type. Please enter 'int', 'string', or 'date'."
      fi
    done
  done



  # Prompt for Primary Key
  while true; do
    read -p "Enter the primary key column: " primary_key
    # Check if primary key exists in columns
    if ! [[ " ${column_array[@]} " =~ " ${primary_key} " ]]; then
      echo "Error: The primary key column does not exist among the provided columns."
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

  echo "Table created."
}

# Lists all available .tbl files, which represent the tables in the database.
list_tables() {
  echo "Available tables:"
  echo "------------------"
  ls *.tbl
  echo "------------------"


  clear

  # check if the current dir is empty
  # if yes => view "No tables to list"
  tables=$(ls -f *.tbl 2>/dev/null)  # Redirecting any errors to /dev/null
  if [ -z "$tables" ]; then
    printf "%-33s\n" | tr ' ' '-'
    echo "|       No tables to show      |"
    printf "%-33s\n" | tr ' ' '-'
  else
    # if no => view tables (dirs) available
    printf "%-33s\n" | tr ' ' '-'
    echo "|       Available tabels        |"
    printf "%-33s\n" | tr ' ' '-'
    # Looping through tables and displaying them in a formatted manner
    for tb in $tables; do
      printf "| %-28s  |\n" "${tb%.tb}"
    done

    printf "%-33s\n" | tr ' ' '-'
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

