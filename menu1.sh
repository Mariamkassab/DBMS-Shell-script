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

#Create table function
function create_table() {
    # Check if table exists
    read -p "Enter the table name : " ta_name
    if [[ ! "$ta_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid table name. Please use only alphanumeric characters and underscore."
        create_table
    elif [ -f "$ta_name" ] ; then
        echo "The entered table name already exists, kindly enter another name"
        create_table
    else
        touch ./"$ta_name"
        # Ask for column names and types
        echo "You must enter primary key column name and data type first"
        echo "Enter column name and type (e.g. 'ID:int'), one per line:"
        echo " Type 'done' when finished."
        columns=""
        types=""
        primary_key=""
        while true; do
            read input
            if [ "$input" == "done" ]; then
                break
            fi

            # split input into name and type
            name=$(echo $input | cut -d ":" -f 1)
            type=$(echo $input | cut -d ":" -f 2)
            #check if column name is a duplicate
            if [[ ":$columns:" == ":$name:" ]]; then
                echo "Error: Duplicate column name '$name'."
                continue
            fi
            #check if input contains both name and type
            if [ -z "$name" ] || [ -z "$type" ]; then
                echo "Error: Column name or type is missing."
                echo "Please enter the name of the column and type, seperated by a colon and try again"
                continue
            fi
            # Check if primary key
            if [ -z "$primary_key" ]; then
                echo "Is '$name' the primary key? [y/n]"
                read is_primary_key
                if [ "$is_primary_key" == "y" ]; then
                    while true; do
                        if [ "$type" == "int" ] || [ "$type" == "string" ]; then
                            primary_key="$name:$type"
                            break
                        else
                            echo "Error: Invalid data type. Please enter either 'int' or 'string' for the primary key column."
                            read -p "Enter primary key column name and type (e.g. 'ID:int'): " input
                            name=$(echo $input | cut -d ":" -f 1)
                            type=$(echo $input | cut -d ":" -f 2)
                        fi
                    done
                fi
            fi
            #Validate data type
            while true; do
                if [ "$type" == "int" ] || [ "$type" == "string" ]; then
                    break
                else
                    echo "Error: Invalid data type. Please enter either 'int' or 'string' for column '$name'."
                    read -p "Enter column name and type (e.g. 'ID:int'), one per line: " input
                    name=$(echo $input | cut -d ":" -f 1)
                    type=$(echo $input | cut -d ":" -f 2)
                fi
            done

            #Add column name and type to lists
            columns="$columns:$name"
            types="$types:$type"
        done

        #Check if primary key is set
        if [ -z "$primary_key" ]; then
            echo "Error: No primary key specified."
            return 1
        fi

        #Create table file
        echo $ta_name

        #Write column names and types to table file
        echo "${columns:1}" >> ./"$ta_name"
        echo "${types:1}" >> ./"$ta_name"
        echo "Primary key: $primary_key"

        echo "Table created successfully."
        menu2
        fi
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
         echo The table deleted sucessfully 
}

#
function drop_table {
         check_table_exists
         rm $t_name
}


# insert data in the table 
function insert_into_table {
    # prompt for table name
    read -p "Enter table name: " table_name

    # check if table exists
    if [ ! -f "$table_name" ]; then
        echo "Error: Table does not exist."
        insert_into_table
    fi

    # Read column names and types from table file
    columns=$(head -n 1 $table_name)
    types=$(head -n 2 $table_name | tail -n 1)

    # Print column names and types
    echo "The column names and data types of this table are: "
    echo "Columns:"
    echo "$columns"
    echo "Types:"
    echo "$types"

    #initialize values variable
    values=""

    #loop over column names and prompt user for data
    for name in $(echo "$columns" | tr ":" "\n"); do
        read -p "Enter data for column '$name' (type: $(echo "$types" | cut -d ":" -f $(echo "$columns" | tr ":" "\n" | grep -n "^$name$" | cut -d ":" -f 1))): " input

        #check if input is consistent with column data type
        type=$(echo "$types" | cut -d ":" -f $(echo "$columns" | tr ":" "\n" | grep -n "^$name$" | cut -d ":" -f 1))
        if [ "$type" == "int" ]; then
            if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                echo "Error: Value '$input' is not an integer."
                insert_into_table
            fi
        elif [ "$type" == "string" ]; then
            if [[ "$input" =~ ":" ]]; then
                echo "Error: Value '$input' contains invalid character ':'."
                insert_into_table
            fi
            if ! [[ "$input" =~ ^[[:alnum:]][[:alpha:]][[:alnum:]]$ ]]; then
                echo "Error: Value '$input' is not a string with at least one alphabet character."
                insert_into_table
            fi
        fi

        # If this is the primary key column, check for uniqueness and non-null value
        if [ "$name" == "$(echo "$columns" | cut -d ":" -f 1)" ]; then
            #check for null value
            if [ -z "$input" ]; then
                echo "Error: Primary key value cannot be null."
                insert_into_table
            fi

            #check for uniqueness
            if grep -q "^$input:" "$table_name"; then
                echo "Error: Primary key value '$input' already exists."
                insert_into_table
            fi
        fi

        #add value to list
        values="$values:$input"
    done

    # Write values to table file
    echo "${values:1}" >> $table_name

    # Ask user if they want to insert another row of data
    read -p "Data inserted successfully. Do you want to enter another row of data? (y/n): " choice
    if [ "$choice" == "y" ]; then
        insert_into_table
    else
        menu2
    fi
}

# detect the input column name number  
function column_detection {
    read -p "Which column's name would you want? " column_de
    export column_de
    m=$(awk -F: -v col="$column_de" 'NR==1{ for (i=1; i<=NF; i++){if($i==col) m=i } } END {print m}' "$t_name")
    if [ -z "$m" ]; then
        echo "Error: kindly enter a valid Column name as '$column_de' not found in the table '$t_name'"
       column_detection
    else
        export column_no=$m
        return 0
    fi
}

# detect the input row name number  
function row_detection {
     read -p "which row's name (PK's value) would you want? " row_de
     export row_de
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
    sed 's/:/ /g' ./$table_name | column -t
    check_table_exists
    column_detection
    row_detection
    read -p "Enter the new value for ${column_de} & PK = ${row_de}: " new_value
    awk -F: -v OFS=":" -v row_no="$row_no" -v column_no="$column_no" -v new_value="$new_value" 'NR==row_no {$column_no=new_value} {print}' "$t_name" > temp_file
    mv temp_file "$t_name"
    echo "Table updated successfully."   
}

#deleting from table
function delete_from_table {
    check_table_exists
    row_detection
    echo you can only delete an entir row
    awk -F: -v OFS=":" -v row="$row_no" '{if (NR!=row) print}' "$t_name" > temp_file
    mv temp_file "$t_name"
    echo "Row deleted successfully."
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



