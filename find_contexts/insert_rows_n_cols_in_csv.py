#!/usr/bin/env python3

import openpyxl

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

# Example usage
excel_file = 'contexts.xlsx'  # Replace with your Excel file
insert_empty_rows_and_columns(excel_file)

