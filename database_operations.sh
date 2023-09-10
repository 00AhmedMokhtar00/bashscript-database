#!/bin/bash

source table_operations.sh

create_database() {

  # check if the database name  (dir) already exists
  
  # if yes => view "Database already exists"
  
  # if no => create database dir with the same name
  # view "Database created successfully"

}

connect_to_database() {

  # check if the database name (dir) already exists
  
  # if yes => table_menu() ( table_operations.sh )
  
  # if no => view "Database doesn't exist"

}

list_databases() {

  # check if the main dir is empty
  
  # if yes => view "No databases to list"
  
  # if no => view databases (dirs) available
  
}

drop_database() {

  # check if the database name  (dir) already exists
  
  # if no => view "Database dosen't exist"
  
  # if yes => view "Are you sure you want to drop database (name)"
    # if yes => delete database (dir) with the same name
    # view "Database dropped successfully"

}
