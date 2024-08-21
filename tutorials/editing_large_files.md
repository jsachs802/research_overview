Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

For my work, we will occasionally contract some data collection out to a niche service, and they will deliver a large SQL file. Sometimes the service will provide these large .sql files on a scheduled basis (like every month), and there can be inconsistencies in the files that prevent you from just updating your database. For one thing, the files will usaully assume that tables will need to be created instead of updated, and the table names in the .sql file might not match the table names in your current database. The files are large, so they can be difficult to open and edit, as they require too much memory.

One solution: use stream editor command which allows you to scroll and make edits, but does not commit the entire file to memory. 

For instance, you can use this to comment out CREATE TABLE commands:
```bash

sed -i '' 's/^CREATE TABLE/--CREATE TABLE/' path/to/your/file.sql

```

Here, '-i' tells sed to edit the file in-place, and the 's' is the substitute command in sed. There are many other commands that you can use, just look up stream editor commands. 

Another example would be changing an existing table name to a new table name where ever it occurs in the .sql file: 

```bash

sed -i '' 's/old_table_name/new_table_name/g' /path/to/your/file.sql 

```

Here, we substitute old_table_name for new_table_name anywhere it occurs in the .sql file. The flag 'g' tells the interpreter to execute this command globally. 
