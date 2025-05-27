# mini-reddit
Simplified Reddit database 


## Installation Instructions

Run these scripts in this order to create the schema:
```bash
1.1-create_tables.sql
1.2-create_packages.sql
1.3-create_indices.sql
1.4-create_triggers.sql
1.5-create_views.sql
3-create_statistics.sql
```

This script will add demonstration data to the database:
```bash
2-insert_data.sql
```

To drop the schema, run these scripts in this order:
```bash
4-drop_statistics.sql
5-drop_schema.sql
```

## Database Diagram 

![Database Diagram](database_diagram/mini-reddit.svg)