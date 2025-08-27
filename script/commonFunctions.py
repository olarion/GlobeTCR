import pandas as pd
from datetime import datetime
from pathlib import Path
import os
import sys
import gc
import threading
import getpass


def modify_sn(sn):
    result = True
    sn = str(sn)
    if len(sn) == 16:
        try:
            # Extract the first 8 characters (hexadecimal part)
            hex_part = sn[:8]

            # Convert the hexadecimal part to ASCII
            ascii_part = bytes.fromhex(hex_part).decode('utf-8')

            # Get the remaining part of the string (non-hexadecimal)
            remaining_part = sn[8:]

            # Combine the converted ASCII part with the remaining part
            sn = ascii_part + remaining_part
        except Exception as e:
            print('- Failed:', e)

    return sn.upper()

def df_to_csv(df=pd.DataFrame(), target_file:str='', idx=False, append_date_time=True):
    '''
    Description:
        This function saves a DataFrame to a CSV file.

    Parameters:
        df:
            The DataFrame to be written to a CSV file.

        target_file:
            Full path of the output CSV file.

        idx (bool, optional):
            True: Include the index in the CSV file.
            False: Exclude the index.

        append_date_time (bool, optional):
            True: Appends the current date and time to the filename in the format YYYYMMDDTHHMMSS.
                example: 
                    date and time = Apr 14 2025, 01:38:45 pm
                    filename_20250414T133845
            False: Saves the file without adding date and time.
    '''
    if append_date_time:
        base_name, extension = os.path.splitext(target_file)
        current_time = datetime.now().strftime('%Y%m%dT%H%M%S')
        # Create a new file name with date and time appended
        target_file = f"{base_name}_{current_time}{extension}"

    print(f'Writing to csv file: {target_file}')
    try:
        df.reset_index(drop=True, inplace=True)
        df.index += 1
        df.index.name = 'Index'

        df.to_csv(
            target_file, 
            index=idx, 
            header=True, 
            sep=',',       # comma separator
            quotechar='"', # use double quotes for string values 
            lineterminator = '\r\n', # Use Windows-style line endings (⁠ \r\n ⁠).
            #quoting=0,     # Only quote fields that contain special characters such as the delimiter, newline characters, or the quote character itself.
            #quoting=1,     # Quote all fields, even those that don't contain special characters
            quoting=2,     # Quote all non-numeric fields, but not numeric fields.
            #quoting=3,     # Never quote any fields, even if they contain special characters.
            encoding='utf-8',
            na_rep='',      # use blank space for missing values
            #encoding_errors='replace'
        )
        df = None

        print('- Sucess')
    except Exception as e:
        print('- Failed:', e)

def read_all_csv_in_dir(dir_path: str='', pattern: str='', rows_toskip: int=0, row_header: int=0, usecols: list=None, add_indx: bool=True):
    '''
    Description:
        Reads all CSV files located in the specified dir_path folder.
        tmp folder will be ignored

    Parameters:
        dir_path (str):
            the path where the csv is located
        
        pattern (str, optional):
            what files to be read:
                *.csv, file_*.csv, etc...

        rows_toskip (int, optional):
            Number of rows to skip from the top of each file.
            Default is 0 (no rows skipped).

        row_header (int, optional):
            Specifies which row to use as the header.
            If set, that row number will be treated as the column headers.
            The default value is 0, meaning the first row is treated as the header.
            If set to 1, the second row becomes the header;
            if set to 2, the third row is used as the header, and so on.
        
        usecols:
            list of columns to be used
    '''
    # Get list of all subfolders inside the main path
    subfolders = [f.path for f in os.scandir(dir_path) if f.is_dir() and f.name not in ("tmp", "temp")]
    if not subfolders:
        raise ValueError("No subfolders found in the provided main path.")
    # We'll use the first subfolder found
    child_folder_path = subfolders[0]
    
    fname = os.path.basename(child_folder_path)
    print('Reading csv files in folder', fname)
    
    files = ''
    if pattern:
        files = [f for f in os.listdir(child_folder_path) if f.endswith('.csv') and pattern in f]  # Assuming CSV files, change if necessary
    else:
        files = [f for f in os.listdir(child_folder_path) if f.endswith('.csv')]  # Assuming CSV files, change if necessary
    
    files = sorted(files)
    df_list = []

    l = len(files)
    if l:
        for file in files:
            if len(files) == 1:
                filename = Path(file)
                fname = filename.stem
            print('Reading csv file: ', file)
            file_path = os.path.join(child_folder_path, file)

            df = pd.read_csv(
                file_path, 
                dtype=str, 
                skiprows=rows_toskip, 
                header=row_header,
                usecols=usecols,
                encoding_errors='replace'
            )
            df = df.fillna('')
            df['filename'] = file
            df_list.append(df)
        df = pd.concat(df_list, ignore_index=True)
        if add_indx:
            df['Indx'] = df.index + 1
        print('Rows: ', df.shape[0])

        return df, fname
    else:
        print("No files found in the provided path.")
        return None,None

def filter_duplicated_rows(df: pd.DataFrame=None, cols: list[str]=None, return_duplicated_rows: bool=False):
    '''
    Description:
        This will return a dataframe with no duplicate rows.
        It has an option to return a dataframe of duplicated rows.

    Parameters:
        df (DataFrame):
            the dataframe to be filtered

        cols (list):
            list of columns to be filtered

        return_duplicated_rows (bool):
            if function will return the dataframe of duplicated rows
    '''
    # Get all occurrences of duplicated rows based on column 'A'
    if df is not None and not df.empty and cols:
        df_duplicated_rows = df[df.duplicated(subset=cols, keep=False)]

        has_dups = len(df_duplicated_rows) > 0
        if has_dups:
            print('Duplicates: ', df_duplicated_rows.shape[0])

            df_no_duplicates = df.drop_duplicates(subset=cols, keep='first')
            print('Unique rows: ', df_no_duplicates.shape[0])

            del df
            gc.collect()

            if return_duplicated_rows:
                return df_no_duplicates, df_duplicated_rows.sort_values(by=cols, ascending=True)
            else:
                return df_no_duplicates
        else:
            return None
        
    else:
        raise

def clean_csv_file(csv_file: str=None):
    '''
    Validates whether a given CSV file is readable by DuckDB's read_csv_auto function 
    by attempting to load the file and catching any exceptions. 
    This ensures the CSV format is compatible and free from structural or encoding issues 
    that would prevent DuckDB from parsing it successfully.

    Parameters:
        csv_file:
            String type, full path of the csv file to be verified/clean.
    '''
    input_file = csv_file
    tmp_file = csv_file + '.original_file'

    def try_read_csv(file_path):
        try:
            pd.read_csv(file_path, encoding='utf-8', low_memory=False)  # Try strict UTF-8 read
            return True
        except UnicodeDecodeError:
            return False

    def clean_csv(input_path, output_path):
        with open(input_path, 'r', encoding='utf-8', errors='replace') as f_in, \
            open(output_path, 'w', encoding='utf-8') as f_out:

            for line in f_in:
                line = line.replace('\\', '') 
                line = line.replace('|', '') 
                line = line.replace('","', '|||')
                line = line.replace('""', "'") 
                line = line.replace("'\"", '"')
                line = line.replace('|||', '","')
                line = line.replace("\"'", '"')
                line = line.replace("\t", '')

                f_out.write(line)

    print('Reading: \033[1;32m', input_file, '\033[0m')
    # Check if the file is clean
    status = try_read_csv(input_file)

    if status:
        print("✅ File is UTF-8 clean. No cleaning needed.")
    else:
        print("⚠️ File has encoding issues. Cleaning...")
        if os.path.exists(tmp_file):
            os.remove(tmp_file)
        
        # Rename original to .tmp
        os.rename(input_file, tmp_file)
        clean_csv(tmp_file, input_file)
        
        print('✅ Done')

def verify_csv_files(source_dir) -> str:
    '''
    Verify CSV files for proper format that is readable by DuckDB
    This will return the full path as a string.
    '''
    try:
        source_path = Path(source_dir)

        if not source_path.exists():
            raise FileNotFoundError(f"Source folder not found: {source_dir}")

        # Walk through all subdirectories and files
        root = None
        for root, _, files in os.walk(source_path):
            for file in files:
                file_path = Path(root) / file
                if file.lower().endswith('.csv') or file.lower().endswith('.xlsx'):
                    clean_csv_file(str(file_path))
        return root
    except:
        return 'x'
    
def add_date_time_string(file: str) -> str:
    base_name, extension = os.path.splitext(file)
    current_time = datetime.now().strftime('%Y%m%dT%H%M%S')
    username = getpass.getuser()
    # Create a new file name with date and time appended
    return f"{base_name}_{current_time}_{username}{extension}"

def timed_input(prompt, timeout=5, default='default_value'):
    user_input = [default]

    def get_input():
        inp = input(prompt)
        if inp.strip():  # Non-blank input
            user_input[0] = inp

    thread = threading.Thread(target=get_input)
    thread.daemon = True
    thread.start()
    thread.join(timeout)

    return user_input[0]

