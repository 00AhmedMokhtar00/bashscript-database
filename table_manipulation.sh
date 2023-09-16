#!/bin/bash
source general_functions.sh

insert_into_table() {
    while true; do
        # Prompt for Table Name
        read -p "Enter the name of the table: " table_name

        # Check if table exists
        if table_exists $table_name; then
            return
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
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$primary_key_field" ]]; then
            # The grep command match only the primary key column using the ^ and , delimiters
            primary_key_pattern="^([^,]*,){$i}${values[$i]}(,|$)"
            if grep -qE "$primary_key_pattern" $table_name.tbl; then
                error_message "Record with primary key ${values[$i]} already exists."
                return
            fi
        fi
    done


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
}


select_from_table() {
    # Prompt for Table Name
    read -p "Enter the name of the table: " table_name

    # Check if table exists
    table_exists $table_name || return

    # Prompt user for the primary key value of the record they wish to select
    read -p "Enter the primary key value of the record you wish to select: " primary_value

    # Check if the record exists using primary key field
    if ! grep -q "^$primary_value," $table_name.tbl; then
        error_message "Record with primary key $primary_value not found."
    else
        # Extract columns and their data types from the second line
        IFS=' ' read -ra fitched_columns <<< "$(sed -n '2p' $table_name.tbl)"
        length=${#fitched_columns[@]}
        printf "%-40s\n" | tr ' ' '-'
        for (( i=0; i<$length; i++ )); do
           x=$((i+1))
           IFS=' ' read -ra fitched_data <<< "$(grep "^$primary_value," $table_name.tbl | cut -d, -f$x )"
           data+="$fitched_data"
           printf "| %-15s %-4s %-15s |\n" "${fitched_columns[$i]}" "|" "$fitched_data"
           printf "%-40s\n" | tr ' ' '-'
        done
    fi
}

delete_from_table() {
    # Prompt for Table Name
    read -p "Enter the name of the table: " table_name

    # Check if table exists
    table_exists $table_name || return

    # Extract primary key field from the first line
    IFS=':' read -r primary_key primary_key_field <<< "$(head -n 1 $table_name.tbl)"

    # Extract columns from the second line
    IFS=' ' read -ra fields <<< "$(sed -n '2p' $table_name.tbl)"
    columns=()
    for field in "${fields[@]}"; do
        IFS=':' read -r column _ <<< "$field"
        columns+=("$column")
    done

    # Find the position of the primary key
    primary_key_index=-1
    for index in "${!columns[@]}"; do
        if [[ "${columns[$index]}" == "$primary_key_field" ]]; then
            primary_key_index=$index
            break
        fi
    done

    # Prompt user for the primary key value of the record they wish to delete
    read -p "Enter the primary key value of the record you wish to delete: " primary_value

    # Check if the record exists using primary key field
    primary_key_pattern="^([^,]*,){$primary_key_index}$primary_value(,|$)"
    if ! grep -qE "$primary_key_pattern" $table_name.tbl; then
        error_message "Record with primary key $primary_value not found."
        return
    else
        temp_file="${table_name}_$(date +%s%N).tmp"
        grep -vE "$primary_key_pattern" $table_name.tbl > $temp_file
        if [[ $? -eq 0 ]]; then
            mv $temp_file $table_name.tbl
            important_info_message "Record deleted successfully." "success"
        else
            error_message "Error deleting record."
            rm -f $temp_file
        fi
    fi
}



update_table() {
    # Prompt for Table Name
    read -p "Enter the name of the table: " table_name

    # Check if table exists
    table_exists $table_name || return

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

    # Find the position of the primary key
    primary_key_index=-1
    for index in "${!columns[@]}"; do
        if [[ "${columns[$index]}" == "$primary_key_field" ]]; then
            primary_key_index=$index
            break
        fi
    done

    # Prompt user for the primary key value of the record they wish to update
    read -p "Enter the primary key value of the record you wish to update: " primary_value

    # Adjust the grep command to match only the primary key column
    primary_key_pattern="^([^,]*,){$primary_key_index}$primary_value(,|$)"
    if ! grep -qE "$primary_key_pattern" $table_name.tbl; then
        error_message "Record with primary key $primary_value not found."
        return
    fi

    # Prompt user for column to update
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
        # Adjust the grep command to match only the primary key column
        new_primary_key_pattern="^([^,]*,){$primary_key_index}$new_value(,|$)"
        if grep -qE "$new_primary_key_pattern" $table_name.tbl; then
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
    temp_file="${table_name}_$(date +%s%N)"
    awk -F, -v col_idx="$update_column_index" -v val="$new_value" -v key="$primary_value" -v pk_idx="$primary_key_index" '
        {
            # For the first two lines (metadata), simply print them as they are
            if (NR <= 2) {
                print $0;
                next;
            }

            split($0, line, ",")
            # If updating the primary key column
            if (col_idx == pk_idx) {
                if (line[pk_idx + 1] == key) {
                    line[col_idx + 1] = val
                }
            }
            # If updating a column other than the primary key column
            else {
                if (line[pk_idx + 1] == key) {
                    line[col_idx + 1] = val
                }
            }
            $0 = ""
            for(i=1; i<=length(line); i++) {
                if (i > 1) {
                    $0 = $0 ","
                }
                $0 = $0 line[i]
            }
            print $0
        }
    ' $table_name.tbl > $temp_file && mv $temp_file $table_name.tbl


    important_info_message "Record updated successfully." "success"
}
