/*
 * CST432 Assignment 2
 */

    .align 4
    .data

// The student struct
student: .space 96
first_name: .asciz "Siti"
last_name: .asciz "Aminah"
class: .word 5
grades: .word 67, 59, 71, 92, 85, 63

// Store the min and max grades in two variables
min_grade: .word 0
max_grade: .word 0

// Strings
szString1: .asciz "%s %s\n"
szString2: .asciz "First element = %d%, last element = %d%\n"
szString3: .asciz "Min grade = %d%, max grade = %d%\n"

// Defines
    .equ N, 6  // Number of elements of array
    .equ FN_OFFSET, 0
    .equ LN_OFFSET, 32
    .equ CLASS_OFFSET, 64
    .equ GRADES_OFFSET, 68

    .text
    .global main
main:
    bl init_student

    adr X19, student    // Base pointer to student

    // Print the first and last name
    adr X0, szString1
    add X1, X19, #FN_OFFSET
    add X2, X19, #LN_OFFSET
    bl printf

    // Get the first and last element
    add X0, X19, #GRADES_OFFSET
    mov X1, #0
    bl get_element
    mov X3, X0  // We have to store X2 again, so store it somewhere else...

    add X0, X19, #GRADES_OFFSET
    mov X1, #5
    bl get_element

    mov X1, X3  // Move first element back to X1
    mov X2, X0  // Move last element to X2
    adr X0, szString2
    bl printf

    // Get the min max grades
    add X0, X19, #GRADES_OFFSET
    mov X1, #N
    adr X2, min_grade
    adr X3, max_grade
    bl min_max_grade

    adr X0, szString3
    ldr X1, [X2]
    ldr X2, [X3]
    bl printf

    b end

// I just thought about this, but we're actually updating global variables,
// So ummm, this isnt' really good practice. But oh well...
init_student:
    stp X29, X30, [SP, #-16]!   // Preserve the link register

    adr X19, student            // X19 = base pointer
    add X0, X19, #FN_OFFSET     // X0 = address of first_name in student
    adr X1, first_name
    bl strcpy

    add X0, X19, #LN_OFFSET     // X0 = address of last_name in student
    adr X1, last_name
    bl strcpy

    add X0, X19, #CLASS_OFFSET  // X0 = address of class in student
    adr X1, class               // Load the address of class to X1
    str X1, [X0]                // Store the class value to X0

    add X0, X19, #GRADES_OFFSET // X0 = address of grades in student
    adr X1, grades              // Load the address of grades to X1
    mov X2, #N                  // Number of elements
    bl arraycpy

    ldp X29, X30, [SP], #16     // Restore the link register

    ret

/*
 * Copies an array
 * X0 = destination array
 * X1 = source array
 * X2 = number of elements
 */
arraycpy:
    mov X3, #0  // let i = 0

for_loop:
    // W4 = array[i]
    // Base pointer = X1, X3 = index, Offset = X1 + (X3*4)
    ldr W4, [X1, X3, lsl #2]    // W4 = array[i]
    str W4, [X0, X3, lsl #2]    // Store W4 to destination array
    cmp X3, X2                  // i < n?
    bge end_loop                // If True, then terminate
    add X3, X3, #1              // i++
    b for_loop                  // Continue looping

end_loop:
    ret

/*
 * Gets an element of index i from an array
 * X0 = Pointer to the array
 * X1 = Index
 * Returns the element in X0
 */
get_element:
    // X0 = base pointer, X1 = index, Offset = X0 + (X1*4)
    ldr W2, [X0, X1, lsl #2]
    mov X0, X2  // Move the element to X0
    ret

/*
 * Gets the minimum and maximum grades
 * min_max(int* grades, int n, int* min, int* max);
 * max = grades[0]; min = grades[0]
 * for (i = 1; i < n; i--):
 *    if grades[i] < min then min = grades[i]
 *    if grades[i] > max then max = grades[i]
 *
 * X0 = Pointer to grades array
 * X1 = Number of elements
 * X2 = Pointer to minimum grade
 * X3 = Pointer to maximum grade
 */
min_max_grade:
    mov X4, #1
    ldr W5, [X0]    // min = grades[0]
    ldr W6, [X0]    // max = grades[0]

check_min:
    ldr W7, [X0, X4, lsl #2]    // grades[i]
    cmp W5, W7
    csel W5, W5, W7, lo         // W5 = W5 < W7 ? W5 : W7

check_max:
    cmp W6, W7
    csel W6, W6, W7, hi         // W6 = W6 > W7 ? W6 : W7

incr_min_max:
    add X4, X4, #1              // i++
    cmp X4, X1                  // i < n?
    bge end_min_max             // If True, then returned
    b check_min                 // Keep looping

end_min_max:
    str W5, [X2]
    str W6, [X3]
    ret

end:
    // syscall exit(0) to terminate the program
    mov X0, #0
    mov X8, #93
    svc #0

    .end
