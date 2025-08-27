# main.py

import os
import sys
from pathlib import Path
import glob
from datetime import datetime
import psutil
import duckdb

################################
print(f"PROGRESS 1", flush=True)
################################

###################################################################################################
# Add current script folder to sys.path
script_dir = Path(__file__).resolve().parent
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

# Import shared functions and config
from commonFunctions import verify_csv_files, add_date_time_string, timed_input
from cfg import site_data


glbdm_no = '284'

#glbdm_no = timed_input("Enter GLBDM number to change this\n (you have 5 seconds): ", timeout=5, default=glbdm_no)

# SQL and target filenames
sql_file    = f'{glbdm_no}.sql'
target_file = f'{glbdm_no}_validation.csv'

# Folder names
db_file         = 'db.duckdb'
SOURCE_DIR_NAME = 'source'
TARGET_DIR_NAME = 'target'
SQL_DIR_NAME    = 'sql'
TMP_DIR_NAME    = 'tmp'
NC_DIR_NAME     = 'nc'

# Construct paths
source_dir_nc   = os.path.join(script_dir.parent, SOURCE_DIR_NAME, NC_DIR_NAME, glbdm_no)
sql_dir         = os.path.join(script_dir.parent, SQL_DIR_NAME)
tmp_dir         = os.path.join(script_dir.parent, TMP_DIR_NAME)
target_filepath = os.path.join(script_dir.parent, TARGET_DIR_NAME, add_date_time_string(target_file))

###################################################################################################
# Verify main NC CSV files

source_dir_nc = verify_csv_files(source_dir_nc)
if source_dir_nc != 'x':
    pass
else:
    print('⚠️ Something went wrong.')
    print('\tCheck that a folder exists matching the GLBDM value inside the source/nc directory.')
    print('\tExample:')
    print(f'\t\tIf the GLBDM number is \033[1;32m{glbdm_no}\033[0m, there should be a folder \033[1;32msource/nc/{glbdm_no}\033[0m,')
    print('\t\tand inside it, a directory containing all the CSV files.')
    print(f'\t\tFor example: \033[1;32msource/nc/{glbdm_no}/TOMS_Extracts_06072025\033[0m')
    print('❌ Process aborted.\n')

    sys.exit()
###################################################################################################
# Initialize DuckDB
print('\nCreating \033[1;32mdb.duckdb\033[0m database file in tmp folder')
db = os.path.join(tmp_dir, db_file)
if os.path.exists(db):
    print('🔄 Deleting existing db file...')
    os.remove(db)
    print('🔄 Create new db file...')
con = duckdb.connect(db)
# Set the memory limit to be used.
# If the operation needs more memory than allowed, DuckDB will try to spill to disk (slower but prevents crash).
# Breakdown:
#     Your total physical RAM: 16GB
#     Apps running:
#         Heavy: Zoom, Firefox, Chrome, LibreOffice, Adobe Reader
#         Medium: VSCode, Spotify
#         Light: PaintX, security apps (depends)
# These apps easily use 4–8 GB combined, sometimes more when multitasking or handling large files (e.g. Zoom + Chrome tabs + LibreOffice = heavy RAM usage).
# Instead of allocating 12GB, play safe with 6–8GB:
# con.execute("SET memory_limit='12GB'")

# Get system memory info
mem = psutil.virtual_memory()

total_gb = mem.total / (1024**3)   # Total RAM in GB
used_gb = mem.used / (1024**3)     # RAM in use
free_gb = mem.available / (1024**3)  # Free RAM

# Example: use half of currently free memory, capped at 8GB
duckdb_limit_gb = min(free_gb / 2, 8)  # To use a fixed value instead, comment out this line and uncomment the next one
# duckdb_limit_gb = 8
con.execute(f"SET memory_limit='{duckdb_limit_gb}GB'")
print('💡 memory_limit has been set to:', con.execute("SELECT current_setting('memory_limit')").fetchone()[0])
print('💡 The memory_limit is set based on the calculated available system RAM.')
print('✅ Done\n')

################################
print(f"PROGRESS 30", flush=True)
################################

###################################################################################################
# Load CSV columns for schema
print('🔄 Loading NC csv files to tables:')
sample_csv = glob.glob(os.path.join(source_dir_nc, '*.csv'))[0]
column_names = duckdb.sql(
    f"""
    select * from read_csv_auto('{sample_csv}', all_varchar=true, sample_size=-1)
    limit 0
    """
).columns
columns_sql = "{" + ", ".join(f"'{col}': 'VARCHAR'" for col in column_names) + "}"

# Load SQL template and apply dynamic path replacements
sql_file_nc = os.path.join(sql_dir, 'nc.sql')
with open(sql_file_nc, 'r') as file:
    sql = file.read()

# Replace placeholders for csv paths
sql = sql.replace('nc_csv_path', source_dir_nc)
if glbdm_no in site_data:
    for name, item in site_data[glbdm_no].items():
        placeholder = f'{name}_csv_path'
        sql = sql.replace(placeholder, item['path'] if item['need'] else '')
else:
    print(f'❌ GLBDM \033[1;32m{glbdm_no}\033[0m has not been found in configuration file (cfg.py)')
    sys.exit()

sql = sql.replace('{{COLUMNS}}', columns_sql)

# Execute SQL to load data into DuckDB
try:
    con.execute(sql)
except Exception as e:
    print('❌ SQL Execution Error:', e)
print('✅ Done\n')

################################
print(f"PROGRESS 50", flush=True)
i = 50
################################

###################################################################################################
# Verify only needed 3rd-party source dirs
if glbdm_no in site_data:
    for name, item in site_data[glbdm_no].items():
        if item['need']:
            # Verify and update path
            verified_path = verify_csv_files(item['path'])
            site_data[glbdm_no][name]['path'] = verified_path
            # Attempt to run its SQL file
            print(f'🔄 Loading {name} csv file to table')
            sql_table_file = os.path.join(sql_dir, f'{name}.sql')
            if os.path.exists(sql_table_file):
                with open(sql_table_file, 'r') as f:
                    sql_snippet = f.read()
                sql_snippet = sql_snippet.replace(f'{name}_csv_path', verified_path)
                try:
                    con.execute(sql_snippet)
                except Exception as e:
                    print(f'❌ Error loading table {name}:', e)
            else:
                print(f'❌ Skipped SQL: {name}.sql not found')

        ################################
        i += 13
        print(f"PROGRESS {i}", flush=True)
        ################################
    print('✅ Done\n')
else:
    print('GLBDM number not found in configuration file (cfg.py)')

################################
if i < 83:
    print(f"PROGRESS 83", flush=True)
################################

###################################################################################################
# Run validation SQL
print('🔄 Executing SQL validation query.\n\t▸\033[1;32m', sql_file, '\033[0m')
sql_file = os.path.join(sql_dir, sql_file)
with open(sql_file, 'r') as file:
    sql = file.read()

sql = sql.replace('<target_path>', target_filepath)
print('💡 Result will be saved to:\n\t▸\033[1;32m', target_filepath, '\033[0m')
try:
    con.execute(sql)
except Exception as e:
    print('❌ Validation SQL Error:', e)
print('✅ Done\n')
################################
print(f"PROGRESS 100", flush=True)
print("DONE", flush=True)
################################
