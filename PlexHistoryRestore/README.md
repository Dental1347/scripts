This script requires a bit of manual work. Unfortunately, there is nothing I can do about this to make it more interactive. Lets first dive into how plex stores it's viewhistory and how it stores the different libraries. 

When looking into the database of plex there are two tables of interest here:
- library_sections
- metadata_item_views

1. library_sections
This table contains the different libraries *currently* within plex. As you may notice, this does not include the old libraries.
![image](https://github.com/Quafley/scripts/assets/44779473/d511e33e-4a6c-4eef-9739-e405095ac360)
Every library has a unique ID. As an example, when you remove your library called "Movies" with ID 1. When re-creating the "Movies" a new ID is assigned. The old "Movies" library entry is removed from the database table.

2. metadata_item_views
All watch history is kept, even when an old library is removed. However, this data is not edited upon re-creation of the same Library (see example above), this means that history is not automatically moved over to the new library.
![image](https://github.com/Quafley/scripts/assets/44779473/606a479e-fe7f-4a38-bb11-4045f38db8dd)
Luckily, we can easily restore the history. (Thanks plex, please don't change this) As can be seen from the above screenshot, every entry is accompanied by the "library_section_id". We simply need a way to change this old library id to the new one.

**BEFORE PROCEEDING, MAKE A BACKUP OF YOUR CURRENT DATABASE**

**SHUTDOWN YOUR PLEX INSTANCE!!**

**Please note, I am not responsible for wrongful execution or corruption of your database, do your own due diligence**

# Info phase
First, lets index our metadata_item_views table for the different library_section_id's. This is done with the PlexLibraryOverview.sh, this script does not make changes, it simply queries the database. 
1. `cd to the \Plug-in Support\Databases.`
2. `bash PlexLibraryOverview.sh com.plexapp.plugins.library.db` (The assumption is made that the script is stored within the same directory, if not, change the path accordingly)
3. Overview is generated like so:
```
Overview of entry count per library_section_id:
|241
1|686
2|6323
3|13243
4|2
6|87
7|10081
8|60
9|3
11|3
12|55
13|1230
14|623
15|2
18|2
```

Now that we know the different id's, and have gotten a bit of insight into the database, it is time to export the table to somewhere, to investigate which IDs we need to change. This can be done with the following command:
`echo -e ".mode column\nPRAGMA table_info(metadata_item_views);\nSELECT * FROM metadata_item_views;" | sqlite3 com.plexapp.plugins.library.db > export.sql`

If you also want to gain a bit more knowledge on what ID's are connected the current libraries (remember old ones are removed from the library_sections table) Execute the following command:
`echo -e ".mode column\nPRAGMA table_info(library_sections);\nSELECT * FROM library_sections;" | sqlite3 com.plexapp.plugins.library.db > libraries.sql`

You can open these files in your favorite text editor and read the entries. I've made sure to make it human readable. It is now time to discover what id's need to be updated. To give an example, mine looked like this:
```
Series:  2 > 13
Anime:   3 > 14
```

# Execution phase
Be very sure your ids are correct, as incorrect usage will mess up your history. The usage of the PlexHistoryRestore.sh is as follows:
`Usage: PlexHistoryRestore.sh <database_file> <old_library_section_id1> <new_library_section_id1> [<old_library_section_id2> <new_library_section_id2> ...]`
This may look daunting, but it's rather simple.
```
bash PlexHistoryRestore.sh com.plexapp.plugins.library.db 2 13
            ^                   ^                          ^
            Path to the file    ^                          ^
                                ^                          ^
                                Database to be used.       ^   
                                                           ^
                                                           The old ID followed up by the new id.
```
If you want to change multiple id's in on go, just repeat in pairs:
`bash PlexHistoryRestore.sh com.plexapp.plugins.library.db 2 13 3 14`

If everything has gone according to plan you will see the following output in your terminal:
```
This will update the library_section_id in the database. Are you sure? (y/n): y
User input: y
Updating library_section_id in the database for pair 2 to 13...
Library_section_id updated successfully. Rows updated: 6323
Updating library_section_id in the database for pair 3 to 14...
Library_section_id updated successfully. Rows updated: 13243
```

Start your plex container and rejoice as your watch history has returned. :)
