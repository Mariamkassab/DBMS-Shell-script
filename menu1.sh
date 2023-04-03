#!/bin/bash
mkdir DataBases 2>> /dev/null
cd DataBases

# function to check if the database is exist
function check_database_exists {

read -p "Enter the database name : " database_name

if [ -d "$database_name" ]; then
    return 0
else
    echo "Error, kindly enter a valid database name"
    check_database_exists
fi

}

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
    read -p "So what is your choice? [1-5] : " choice
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
    elif [ -d "$db_name" ] ; then
        echo "The entered database name is already exist, kindly enter another name"
        create_database
    else
        mkdir "$db_name"
        echo "Database created successfully!"
    fi
    menu1
}

#list all databases
function list_databases {
    echo "List of existing databases:"
    ls
    menu1
}


#connect to the database
function connect_database {

    check_database_exists
    cd $database_name
    echo "you are now inside your database"
    echo "your current path is :"
    pwd
    menu1
}


#drop a database
 function drop_database {
 
    check_database_exists
    rm -ir $database_name
    echo "The entered database has been deleted"
    menu1 
 }


#exit program
function exit_program() {
    echo "Exiting program..."
    exit 0
}


menu1
