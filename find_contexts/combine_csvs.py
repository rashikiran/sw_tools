#!/usr/bin/env python3

#!/usr/bin/env python3
import pandas as pd
import os
import time

def create_excel_with_tabs(csv_directory, output_excel_file, chunksize=100000):
    try:
        with pd.ExcelWriter(output_excel_file, engine='openpyxl') as writer:
            print(f"Excel file '{output_excel_file}' will be created.")
            
            # Start timer to track how long it takes
            start_time = time.time()
            
            # Loop through each CSV file in the specified directory
            for csv_file in os.listdir(csv_directory):
                if csv_file.endswith('.csv'):
                    # Full path to the CSV file
                    csv_path = os.path.join(csv_directory, csv_file)
                    print(f"Processing file: {csv_path}")

                    try:
                        # Extract the base name of the CSV file (without extension) for the header
                        sheet_name = os.path.splitext(csv_file)[0]
                        print(f"Processing file {csv_file} and writing to sheet {sheet_name}")
                        
                        # Read the CSV file in chunks
                        chunk_iter = pd.read_csv(csv_path, chunksize=chunksize)
                        first_chunk = True  # Flag to write header only for the first chunk
                        
                        for i, chunk in enumerate(chunk_iter):
                            # Create a header row that is the same as the CSV file name
                            # This header row will be the same for every chunk (set to the CSV file's base name)
                            header_row = [sheet_name] * len(chunk.columns)
                            
                            # For the first chunk, include the custom header row
                            if first_chunk:
                                # Write the chunk with the custom header row
                                chunk.columns = header_row  # Set the column names as the CSV file name
                                chunk.to_excel(writer, sheet_name=sheet_name, index=False, header=True)
                                first_chunk = False  # Set flag to False after the first chunk
                            else:
                                # For subsequent chunks, write without header row
                                chunk.columns = header_row  # Set the column names as the CSV file name
                                chunk.to_excel(writer, sheet_name=sheet_name, index=False, header=False)
                            
                            print(f"Processed chunk {i+1} of file {csv_file}")

                        print(f"Completed file {csv_file}")
                    
                    except Exception as e:
                        print(f"Error processing file {csv_file}: {e}")
            
            print(f"All files processed in {time.time() - start_time:.2f} seconds.")
            print(f"Excel file with tabs created successfully: {output_excel_file}")
    
    except Exception as e:
        print(f"Error writing to Excel file: {e}")

# Example usage
csv_directory = './'  # Replace with the directory containing your CSV files
output_excel_file = 'contexts.xlsx'  # Output Excel file

# Call the function to create the Excel file with multiple tabs
create_excel_with_tabs(csv_directory, output_excel_file)

