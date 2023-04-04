#!/bin/bash
mkdir DataBases 2>> /dev/null
cd DataBases
function menu1 {
    trap exit_program SIGINT #exit when pressing ctrl+c
    echo "----------------------------------------"
    echo Hello Dear,
    echo kindly choose one option from the list below 
    echo "1. Create a database "
    echo "2. List a database "
    echo "3. Connect to a database "
    echo "4. Delete a database "
    echo "5. Exit "
    echo "-----------------------------------------"
    read -p "So what is your choice? [1-5]" choice
    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) connect_database ;;
        4) drop_database ;;
        5) exit_program ;;
        *) echo "Invalid choice. Please try again." ; menu1 ;;
    esac
}
#create new database
function create_database {
    read -p "Enter the database name: " db_name
    if [[ ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid database name. Please use only alphanumeric characters and underscore."
        echo "Please try again"
        create_database
    elif check_database_exists "$db_name"; then
        return
    else
        mkdir "$db_name"
        echo "Database created successfully!"
    menu1
}

#list all databases
function list_databases {
    echo "List of existing databases:"
    ls -a
    menu1
}
#exit program
function exit_program() {
    echo "Exiting program..."
    exit 0
}
# Function to trap Ctrl + D (EOF) signal and redirect to main menu
# i personally think we won't need it though, because we can just redirect to the main menu by calling the function menu1
function redirect_on_ctrl_d() {
    echo "Press Ctrl + D to return to the main menu."
    while read -r line || [[ -n $line ]]; do
        # Do nothing - wait for Ctrl + D (EOF)
        :
    done
    menu1 # Redirect to main menu
}
menu1
