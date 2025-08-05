#!/usr/bin/env python3

# Convert each tab of xls or xlsx document to separate tsv files, removing first two rows of each sheet
# usage: xlsx2tsv.sh filename.xlsx or filename.xls
# output: filename_sheetname.tsv for each sheet, starting from row 3 as header

# dependencies:
# pandas
# xlrd (for .xls)
# openpyxl (for .xlsx)

import pandas as pd
import sys
import os

input_file = sys.argv[1]

# Determine file type and set engine
if input_file.endswith('.xlsx'):
    engine = 'openpyxl'
elif input_file.endswith('.xls'):
    engine = 'xlrd'
else:
    print("Error: The input file must be either a .xls or .xlsx file.")
    sys.exit(1)

# Create a 'tsv' folder in the current working directory if it doesn't exist
output_folder = os.path.join(os.getcwd(), 'tsv')
os.makedirs(output_folder, exist_ok=True)

# Load workbook and get all sheet names
sheets = pd.ExcelFile(input_file, engine=engine)

# Iterate over all sheets, skip first two rows, and save each as a separate TSV file
for sheet_name in sheets.sheet_names:
    # Read each sheet, skipping the first two rows
    df = pd.read_excel(input_file, sheet_name=sheet_name, engine=engine, skiprows=2)
    output_file = os.path.join(output_folder, f"{os.path.splitext(os.path.basename(input_file))[0]}_{sheet_name}.tsv")
    df.to_csv(output_file, sep='\t', index=False)

print("Conversion completed: Each sheet has been saved as a separate TSV file with row 3 as the header.")
print(f"TSV files have been saved to: {output_folder}")