#!/usr/bin/env python3

import openpyxl
import sys

def insert_empty_rows_and_columns(excel_file):
    try:
        # Load the existing workbook
        wb = openpyxl.load_workbook(excel_file)

        # Loop through all sheets in the workbook
        for sheet_name in wb.sheetnames:
            worksheet = wb[sheet_name]
            
            # Insert two empty rows at the top
            worksheet.insert_rows(1, amount=2)
            
            # Insert two empty columns at the left
            worksheet.insert_cols(1, amount=2)
            
            print(f"Empty rows and columns inserted in sheet: {sheet_name}")

        # Save the workbook after modifications
        wb.save(excel_file)
        print(f"Empty rows and columns inserted successfully in {excel_file}")
    
    except Exception as e:
        print(f"Error processing the file: {e}")

# Check if an output Excel file name was provided via command line argument
if len(sys.argv) < 2:
    print("Please provide the output Excel file name as a command line argument.")
    sys.exit(1)

# Get the output Excel file name from the first command line argument
excel_file = sys.argv[1]


insert_empty_rows_and_columns(excel_file)

