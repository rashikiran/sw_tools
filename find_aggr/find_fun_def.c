#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define BUFFER_SIZE 1024


char* trim_whitespace(char* str) {
    while (*str == ' ' || *str == '\t' || *str == '\n' || *str == '\r') {
        str++;
    }
    return str;
}


int is_function_defined(const char *filename, const char *function_name) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        return 0; 
    }

    
    char *buffer = NULL;
    size_t total_size = 0;
    size_t bytes_read;

    
    do {
        buffer = realloc(buffer, total_size + BUFFER_SIZE);
        if (!buffer) {
            fclose(file);
            return 0; 
        }
        bytes_read = fread(buffer + total_size, 1, BUFFER_SIZE, file);
        total_size += bytes_read;
    } while (bytes_read == BUFFER_SIZE);

    
    buffer[total_size] = '\0';

    
    char *ptr = buffer;
    while ((ptr = strstr(ptr, function_name)) != NULL) {
        
        if ((ptr == buffer || *(ptr - 1) == ' ' || *(ptr - 1) == '\t' || *(ptr - 1) == '\n' || *(ptr - 1) == '\r' || (!isalnum(*(ptr - 1)) && *(ptr - 1) != '_') ) &&
            *(ptr + strlen(function_name)) == '(') {
            
            char *after_function = ptr + strlen(function_name);
            after_function = trim_whitespace(after_function); 
            
            
            if (*after_function == '(') {
                
                char *after_parenthesis = after_function + 1;
                
                int paren_count = 1;  
                
                
                while (*after_parenthesis != '\0') {
                    if (*after_parenthesis == '(') {
                        paren_count++;  
                    } else if (*after_parenthesis == ')') {
                        paren_count--;  
                    }

                    
                    if (paren_count == 0) {
                        after_parenthesis++;  
                        after_parenthesis = trim_whitespace(after_parenthesis); 
                        
                        
                        if (*after_parenthesis == '{') {
                            free(buffer);
                            fclose(file);
                            return 1;  
                        }
                        break;  
                    }
                    after_parenthesis++;  
                }
            }
        }
        ptr++;  
    }

    free(buffer);
    fclose(file);
    return 0;  
}


int count_lines(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        return 0; 
    }

    int count = 0;
    char line[BUFFER_SIZE];
    while (fgets(line, sizeof(line), file)) {
        count++;
    }

    fclose(file);
    return count;  
}


char** read_function_names(const char *filename, int *num_functions) {
    *num_functions = count_lines(filename);
    if (*num_functions == 0) {
        return NULL;  
    }

    
    char **function_names = malloc(*num_functions * sizeof(char*));
    if (!function_names) {
        return NULL;
    }

    for (int i = 0; i < *num_functions; i++) {
        function_names[i] = malloc(BUFFER_SIZE * sizeof(char));
        if (!function_names[i]) {
            // Free previously allocated memory
            for (int j = 0; j < i; j++) {
                free(function_names[j]);
            }
            free(function_names);
            return NULL;
        }
    }

    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening functions file");
        // Free all allocated memory
        for (int i = 0; i < *num_functions; i++) {
            free(function_names[i]);
        }
        free(function_names);
        return NULL;  
    }

    int count = 0;
    while (count < *num_functions && fgets(function_names[count], BUFFER_SIZE, file) != NULL) {
        // Remove newline character if present
        function_names[count][strcspn(function_names[count], "\n")] = '\0'; 
        count++;
    }

    fclose(file);
    return function_names;  
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        return 1; 
    }

    const char *c_filename = argv[1];
    const char *functions_filename = argv[2];

    int num_functions = 0;
    char **function_names = read_function_names(functions_filename, &num_functions);

    if (function_names == NULL) {
        return 2; 
    }

    if (num_functions == 0) {
        free(function_names);
        return 3; 
    }

    for (int i = 0; i < num_functions; i++) {
        if (is_function_defined(c_filename, function_names[i])) {
            printf("%s\n", function_names[i]); 
        }
    }

    // Free allocated memory
    for (int i = 0; i < num_functions; i++) {
        free(function_names[i]);
    }
    free(function_names);

    return 0;
}
