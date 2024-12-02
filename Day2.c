#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define PATH "data/day2.txt"
#define LENGTH 500
#define MAX_LENGTH 100
#define SEPERATOR " "

bool is_increasing(int arr[], size_t length) {
    for (size_t i = 1; i < length; ++i) {
        int previous = arr[i - 1];
        int current = arr[i];

        if (!(previous < current)) {
            return false;
        }
    }

    return true;
}

bool is_decreasing(int arr[], size_t length) {
    for (size_t i = 1; i < length; ++i) {
        int previous = arr[i - 1];
        int current = arr[i];

        if (!(previous > current)) {
            return false;
        }
    }

    return true;
}

bool valid_differences(int arr[], size_t length) {
    for (size_t i = 1; i < length; ++i) {
        int previous = arr[i - 1];
        int current = arr[i];

        int diff = abs(previous - current);

        if (diff != 1 && diff != 2 && diff != 3) {
            return false;
        }
    }

    return true;
}

int *remove_element(int arr[], size_t length, size_t idx) {
    int *new_array = calloc(length - 1, sizeof(int));

    size_t it = 0;
    for (size_t i = 0; i < length; ++i) {
        if (i != idx) {
            new_array[it++] = arr[i];
        }
    }

    return new_array;
}

bool part2_valid(int arr[], size_t length) {
    for (size_t i = 0; i < length; ++i) {
        int *with_removed = remove_element(arr, length, i);

        if ((is_increasing(with_removed, length - 1) || is_decreasing(with_removed, length - 1)) && valid_differences(with_removed, length - 1)) {
            free(with_removed);
            return true;
        }

        free(with_removed);
    }

    return false;
}

int main(int argc, char *argv[]) {
    FILE *file = fopen(PATH, "r");

    char text[LENGTH];

    size_t part1_counter = 0;
    size_t part2_counter = 0;

    while (fgets(text, LENGTH - 1, file) != NULL) {
        text[strcspn(text, "\n")] = '\0';
        int nums[MAX_LENGTH] = { 0 };

        size_t len = 0;
        char *token = strtok(text, SEPERATOR);

        while (token) {
            nums[len] = atoi(token);
            ++len;
            token = strtok(NULL, SEPERATOR);
        }

        if ((is_increasing(nums, len) || is_decreasing(nums, len)) && valid_differences(nums, len)) {
            ++part1_counter;
            ++part2_counter;
        } else if (part2_valid(nums, len)) {
            ++part2_counter;
        }
    }

    printf("%zu\n", part1_counter);
    printf("%zu\n", part2_counter);

    return 0;
}
