#!/bin/bash


# Prompts the user for a table name and values for its columns.
# Inserts the values into the table.
# Also checks for the table's existence before proceeding.
insert_into_table() {
    while true; do
        while true; do
            # Prompt for Table Name
            read -p "Enter the name of the table: " table_name

            # Check if table exists
            if is_table_exists $table_name; then
                break
            fi
        done

        # Extract primary key from the first line
        IFS=':' read -r primary_key primary_key_field <<< "$(head -n 1 $table_name.tbl)"

        # Extract columns and their data types from the second line
        IFS=' ' read -ra fields_data <<< "$(sed -n '2p' $table_name.tbl)"

        columns=()
        data_types=()
        for field_data in "${fields_data[@]}"; do
            IFS=':' read -r column data_type <<< "$field_data"
            columns+=("$column")
            data_types+=("$data_type")
        done

        values=()

        # Prompt user for values for each column and validate
        for index in "${!columns[@]}"; do
            while true; do
                read -p "Enter value for ${columns[$index]} (Type: ${data_types[$index]}): " value

                value=$(trim "$value")
                # Validate based on data type
                case "${data_types[$index]}" in
                    "int")
                        if ! is_valid_int "$value"; then
                            error_message "Please enter a valid integer for ${columns[$index]}"
                            continue
                        fi
                        ;;
                    "string")
                        if ! is_valid_string "$value"; then
                            error_message "Please enter a valid string for ${columns[$index]}"
                            continue
                        fi
                        ;;
                    "date")
                        if ! is_valid_date "$value"; then
                            error_message "Please enter a valid date (YYYY-MM-DD) for ${columns[$index]}"
                            continue
                        fi
                        ;;
                    *)
                        error_message "Invalid data type for ${columns[$index]}"
                        return
                        ;;
                esac

                values+=("$value")
                break
            done
        done

        # Check primary key uniqueness
        local is_primary_key_unique=true
        for i in "${!columns[@]}"; do
            if [[ "${columns[$i]}" == "$primary_key_field" ]]; then
                if grep -q "${values[$i]}" $table_name.tbl; then
                    error_message "Record with primary key ${values[$i]} already exists."
                    is_primary_key_unique=false
                    break
                fi
            fi
        done
        if ! $is_primary_key_unique;then
            continue
        fi


        # Construct the string without appending a comma for the last value
        value_string=""
        for i in "${!values[@]}"; do
            if [[ $i -eq $((${#values[@]} - 1)) ]]; then
                # Last value, don't append comma
                value_string+="${values[$i]}"
            else
                value_string+="${values[$i]},"
            fi
        done

        # Append the constructed string to the table
        echo "$value_string" >> $table_name.tbl

        important_info_message "Record inserted successfully." "success"
        return
    done
}




# Prompts the user for a table name and then displays its content in a formatted manner.
# Extracts the column names from the table file and then prints each row.
# select_from_table() {

# }

# Asks the user to enter the primary key of the row that he wants to delete
# check:
#   - if the key exists then delete the row and return success message.
#   - if the key doesn't exist then return an error message.
# In both cases we should go back to the tables menu
# delete_from_table() {

# }

# Asks the user to enter the column that he wants to update
# check:
#   - if the column doesn't exist or it's the primary key then output error message
#   - if the column exists:
#       - Ask the user about the new value that he wants to put.
#       - Replace the old column values with the new value.
#       - Return a success message
# check:
#   - if the key exists then delete the row and return success message.
#   - if the key doesn't exist then return an error message.
# In both cases we should go back to the tables menu
update_table() {
    # Prompt for Table Name
    read -p "Enter the name of the table: " table_name

    # Check if table exists
    is_table_exists $table_name || return

    # Extract primary key field from the first line
    IFS=':' read -r primary_key primary_key_field <<< "$(head -n 1 $table_name.tbl)"

    # Extract columns and their data types from the second line
    IFS=' ' read -ra fields_data <<< "$(sed -n '2p' $table_name.tbl)"
    columns=()
    data_types=()
    for field_data in "${fields_data[@]}"; do
        IFS=':' read -r column data_type <<< "$field_data"
        columns+=("$column")
        data_types+=("$data_type")
    done

    # Prompt user for the primary key value of the record they wish to update
    read -p "Enter the primary key value of the record you wish to update: " primary_value

    # Check if the record exists using primary key field
    if ! grep -q "^$primary_value," $table_name.tbl; then
        error_message "Record with primary key $primary_value not found."
        return
    fi

    # Prompt user for column to update and new value
    echo "Available columns: ${columns[*]}"
    read -p "Enter the column you want to update: " update_column

    # Validate if update_column exists
    update_column_index=-1
    for index in "${!columns[@]}"; do
        if [[ "${columns[$index]}" == "$update_column" ]]; then
            update_column_index=$index
            break
        fi
    done

    if [[ $update_column_index == -1 ]]; then
        error_message "Column $update_column does not exist."
        return
    fi

    read -p "Enter the new value for $update_column: " new_value

    # Check if user is trying to update the primary key column
    if [[ "$update_column" == "$primary_key_field" ]]; then
        # Check if the new primary key value already exists in the table
        if grep -q "^$new_value," $table_name.tbl; then
            error_message "Error: duplicate key value violates unique constraint $table_name pkey"
            return
        fi
    fi

    # Validate new value based on data type
    case "${data_types[$update_column_index]}" in
        "int")
            if ! is_valid_int "$new_value"; then
                error_message "Please enter a valid integer for $update_column"
                return
            fi
            ;;
        "string")
            if ! is_valid_string "$new_value"; then
                error_message "Please enter a valid string for $update_column"
                return
            fi
            ;;
        "date")
            if ! is_valid_date "$new_value"; then
                error_message "Please enter a valid date (YYYY-MM-DD) for $update_column"
                return
            fi
            ;;
        *)
            error_message "Invalid data type for $update_column"
            return
            ;;
    esac

    # Use awk to update the record and save it atomically
    temp_file="${table_name}_$(date +%s%N).tmp"
    awk -F, -v col="$update_column" -v val="$new_value" -v key="$primary_value" -v fields="${columns[*]}" '
        BEGIN {
            # Convert fields to an array
            split(fields, arr, " ")
            for(i in arr) {
                if(arr[i] == col) {
                    idx = i
                    break
                }
            }
        }
        {
            # Update the specific field of the matching record
            if($1 == key) {
                split($0, line, ",")
                line[idx] = val
                $0 = line[1]
                for(i=2; i<=length(line); i++) {
                    $0 = $0 "," line[i]
                }
            }
            print $0
        }
    ' $table_name.tbl > $temp_file && mv $temp_file $table_name.tbl

    important_info_message "Record updated successfully." "success"
}

