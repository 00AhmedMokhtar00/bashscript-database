#!/bin/bash

source table_operations.sh
source table_manipulation.sh

# Prompts the user for a table name and values for its columns.
# Inserts the values into the table.
# Also checks for the table's existence before proceeding.
insert_into_table() {
touch test
}

# Prompts the user for a table name and then displays its content in a formatted manner.
# Extracts the column names from the table file and then prints each row.
select_from_table() {

}

# Asks the user to enter the primary key of the row that he wants to delete
# check:
#   - if the key exists then delete the row and return success message.
#   - if the key doesn't exist then return an error message.
# In both cases we should go back to the tables menu
delete_from_table() {

}

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

}
