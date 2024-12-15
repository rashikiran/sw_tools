#include <stdio.h>
#include <stdbool.h>
#include <string.h>

void remove_multiline_comments(FILE *input, FILE *output) {
    char ch;
    bool inside_comment = false;

    while ((ch = fgetc(input)) != EOF) {
        
        if (ch == '/' && !inside_comment) {
            char next_ch = fgetc(input);
            if (next_ch == '*') {
                
                inside_comment = true;
            } else {
                
                fputc(ch, output);
                if (next_ch != EOF) {
                    fputc(next_ch, output);
                }
            }
        }
        
        else if (ch == '*' && inside_comment) {
            char next_ch = fgetc(input);
            if (next_ch == '/') {
                inside_comment = false;
            }
        }
        
        else if (!inside_comment) {
            fputc(ch, output);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("./%s <input_file>", argv[0]);
        return 1;
    }

    
    const char *input_filename = argv[1];
    const char *temp_filename = "temp_cleaned.c";

    FILE *input = fopen(input_filename, "r");
    if (input == NULL) {
        return 2;
    }

    // Open temporary output file for writing
    FILE *output = fopen(temp_filename, "w");
    if (output == NULL) {
        fclose(input);
        return 3;
    }

    // Remove multiline comments
    remove_multiline_comments(input, output);

    // Close files
    fclose(input);
    fclose(output);

    // Replace original file with cleaned file
    if (rename(temp_filename, input_filename) != 0) {
        return 4;
    }

    
    return 0;
}
