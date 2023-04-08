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



# function to check if the table is exist
function check_table_exists {
read -p "Enter the table name : " table_name
    export t_name="$table_name"
if [ -f "$table_name" ]; then
    return 0
else
    echo "Error, kindly enter a valid table name"
    check_table_exists
fi
}


# menu2 skeleton
function menu2 {
    trap exit_program SIGINT #exit when pressing ctrl+c
    echo "----------------------------------------"
    echo Hello Dear,
    echo kindly choose one option from the list below 
    echo "1. Create a Table "
    echo "2. List Tables"
    echo "3. Drop Table "
    echo "4. Insert into Table "
    echo "5. Select From Table "
    echo "6. Delete From Table "
    echo "7. Update Table "
    echo "8. Bake "
    echo "9. Exit "
    echo "-----------------------------------------"
    read -p "So what is your choice? [1-9] : " choice
    case $choice in
        1) create_table ;;
        2) list_tables ;;
        3) drop_table ;;
        4) insert_into_table ;;
        5) select_from_table ;;
        6) delete_from_table ;;
        7) update_table ;;
        8) back ;;
        5) exit_program ;;
        *) echo "Invalid choice. Please try again." ; menu1 ;;
    esac
}



# list from/all table
function list_tables {
         echo "The tables are :"
         ls -l
         menu2
}

# listing options
function table_listing {
         echo "1. show all table :"
         echo "2. List from the table :"
         read -p "So what is your choice? [1-2] : " choice
             case $choice in
             1) sed 's/:/ /g' ./$table_name | column -t
                  ;;
             2)read -p "which rows value would you want to display its value? " row
               sed 's/:/\t/g' ./$table_name | head -1 | column -t
               sed 's/:/\t/g' ./$table_name | grep $row | column -t 
                  menu2
                  ;;
             *) echo "Invalid choice. Please try again." ; table_listing ;;
             esac
}
    
#select from the table
function select_from_table { 
         echo "kindly select a spasific table to list, "
         check_table_exists
         table_listing  
}


# detect the input column name number  
function column_detection {
    read -p "Which column name would you like to detect? " column_de
    m=$(awk -F: -v col="$column_de" 'NR==1{ for (i=1; i<=NF; i++){if($i==col) m=i } } END {print m}' "$t_name")
    if [ -z "$m" ]; then
        echo "Error: kindly enter a valid Column name as '$column_de' not found in the table '$t_name'"
       column_detection
    else
        echo "$m"
        export column_no=$m
        return 0
    fi
}

# detect the input row name number  
function row_detection {
     read -p "which row name (PK's value) would you want? " row_de
     num_of_rows=$(awk 'END{ print NR }' "$t_name")
     export num_of_rows
     m=$(awk -F: -v roww="$row_de" '{if($1==roww) m=NR } END {print m}' "$t_name")
     
if [ -z "$m" ]; then
        echo "Error: kindly enter a valid row name as '$row_de' not found in the table '$t_name'"
       row_detection
    else
        export row_no=$m
        return 0
    fi
}




#updateing a value in a table 
function update_table {
    
}


#back funcation from menu2 to menu1 
function back {
#when we connect to the database we didnot get back to all data bases
# we should cd ..  
   cd ..       
   menu1
}

#-----------------------------------------------------------------------------------------
# menu1 skeleton
function menu1 {
    trap exit_program SIGINT #exit when pressing ctrl+c
    echo "----------------------------------------"
    echo Hello Dear,
    echo kindly choose one option from the list below 
    echo "1. Create a database "
    echo "2. List database "
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
    menu2
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

#calling function menu1
menu1



