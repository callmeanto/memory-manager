# Implementacion de lista simple enlazada

# Global symbols

    .eqv    node_next       0
    .eqv    node_str        4
    .eqv    node_size       8       # sizeof(struct node)

# NOTE: we don't actually use this struct
# struct list {
#   struct node *list_head;
#   struct node *list_tail;
# };
    .eqv    list_head       0
    .eqv    list_tail       4

# rutinas de strings
    .globl  read_string
    .globl  strcmp
    .globl  strlen
    .globl  nltrim

# rutinas de la lista
    .globl  create
    .globl  insert
    .globl  delete
    .globl  main
    .globl  print_list

# rutinas de la libreria
    .globl  get_string
    .globl  init
    .globl  malloc
    .globl  free
    .globl  print_newline
    .globl  print_string

# Constantes
.data
MAX_STRLEN: .word       50
newLine:    .asciiz     "\n"
name:       .asciiz     "Ingrese el nombre: "
id:         .asciiz     "Ingrese la cedula: "
modelo:     .asciiz     "Ingrese el modelo de vehiculo: "
wel_msg:    .asciiz     "Bienvenido a su manejador de memoria"
create_msg:   .asciiz    "Ingrese el tamaño de memoria que desea inicializar: "
menu_msg:   .asciiz     "Indique 1 si desea insertar en la lista o 2 si desea eliminar"

    # global registers:
    #   s0 -- list head pointer (list_head)

# Code
.text

main:

    #li      $s0,0                   # list_head = NULL
     
     li $v0,4
     la $a0,wel_msg      # Imprimir mensaje de bienvenida
     syscall 


     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 

     li $v0,4
     la $a0,create_msg      # Mensaje de init
     syscall 
          	     	
     li $v0,5
     syscall
     sb $v0,init_size   # Leemos size
     
     # Abrimos stack para guardar valores
     move $a0,$v0
     addi $sp,$sp,-4
     sb $a0,0($sp)
	 
     jal create         # Llamamos a create	
		
     # Guardamos en el stack el tamano de malloc y la direccion inicial antes de llamarlo
     addi $sp, $sp, -8
     sw   $s1, 0($sp)
     sw   $a0, 4($sp)
		
     loop_malloc:
		
	li $v0,4
	la $a0,msize_msg      # Imprimir mensaje de malloc
	syscall 
	
	# Leemos tamano malloc
	li $v0,5
	syscall
	move $a0, $v0
			
			
	# Llamamos a malloc
	jal malloc
		
	bnez $a0,loop_malloc
		
	# Leemos direccion de free
	#li $v0,5
	#syscall
	#move $a0, $v0 
		
	jal exit
		
    

main_loop:
    # prompt user for string
    la      $a0,STR_ENTER
    jal     print_string

    # read in string from user
    jal     read_string

    # save the string pointer as we'll use it repeatedly
    move    $s1,$v0

    # strip newline
    move    $a0,$s1
    jal     nltrim

    # get string length and save the length
    move    $a0,$s1
    jal     strlen

    # stop if given empty string
    blez    $v0,main_exit

    # insert the string
    jal     insert

    j       main_loop

main_exit:
    move    $a0,$s0
    jal     print_list

    jal     print_newline

    # exit simulation via syscall
    li      $v0,10
    syscall

    ##################################################
    # String routines
    ##################################################

# read_string: allocates MAX_STR_LEN bytes for a string
# and then reads a string from standard input into that memory address
# and returns the address in $v0
read_string:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s0,4($sp)

    lw      $a1,MAX_STR_LEN         # $a1 gets MAX_STR_LEN

    move    $a0,$a1                 # tell malloc the size
    jal     malloc                  # allocate space for string

    move    $a0,$v0                 # move pointer to allocated memory to $a0

    lw      $a1,MAX_STR_LEN         # $a1 gets MAX_STR_LEN
    jal     get_string              # get the string into $v0

    move    $v0,$a0                 # restore string address

    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

# nltrim: modifies string stored at address in $a0 so that
# first occurrence of a newline is replaced by null terminator
nltrim:
    li      $t0,0x0A                # ASCII value for newline

nltrim_loop:
    lb      $t1,0($a0)              # get next char in string
    beq     $t1,$t0,nltrim_replace  # is it newline? if yes, fly
    beqz    $t1,nltrim_done         # is it EOS? if yes, fly
    addi    $a0,$a0,1               # increment by 1 to point to next char
    j       nltrim_loop             # loop

nltrim_replace:
    sb      $zero,0($a0)            # zero out the newline

nltrim_done:
    jr      $ra                     # return

# strlen: given string stored at address in $a0
# returns its length in $v0
#
# clobbers:
#   t1 -- current char
strlen:
    move    $v0,$a0                 # remember base address

strlen_loop:
    lb      $t1,0($a0)              # get the current char
    addi    $a0,$a0,1               # pre-increment to next byte of string
    bnez    $t1,strlen_loop         # is char 0? if no, loop

    subu    $v0,$a0,$v0             # get length + 1
    subi    $v0,$v0,1               # get length (compensate for pre-increment)
    jr      $ra                     # return

# strcmp: given strings s, t stored at addresses in $a0, $a1
# returns <0 if s < t; 0 if s == t, >0 if s > t
# clobbers: t0, t1
strcmp:
    lb      $t0,0($a0)              # get byte of first char in string s
    lb      $t1,0($a1)              # get byte of first char in string t

    sub     $v0,$t0,$t1             # compare them
    bnez    $v0,strcmp_done         # mismatch? if yes, fly

    addi    $a0,$a0,1               # advance s pointer
    addi    $a1,$a1,1               # advance t pointer

    bnez    $t0,strcmp              # at EOS? no=loop, otherwise v0 == 0

strcmp_done:
    jr      $ra                     # return

########################################
#     RUTINAS DE LA LISTA              #
########################################

create:
	
     # Abrimos stack pointer para guardar $ra de la llamada de create
     addi $sp,$sp,-4
     sb $ra,0($sp)
	 
      	
     # LLamamos a init
     jal init
     
     # Si no se pudo hacer, se sale del programa
     beq $v0,-1,exit
     
     # Si se pudo, se continua
     			
     # syscall de imprimir init exitoso
     li $v0,4
     la $a0,create_success   # Imprimir mensaje de allocate succesfull
     syscall 
     
     # syscall de imprimir direccion inicial
     li $v0,1
     lw $a0,4($sp)   # Imprimir mensaje de allocate succesfull
     syscall
     
	



# insert: inserts new linked-list node in appropriate place in list
#
# returns address of new front of list in $s0 (which may be same as old)
#
# arguments:
#   s0 -- pointer to node at front of list (can be NULL)
#   s1 -- address of string to insert (strptr)
#
# registers:
#   s2 -- address of new node to be inserted (new)
#   s3 -- address of previous node in list (prev)
#   s4 -- address of current node in list (cur)
#
# clobbers:
#   a0, a1 (from strcmp)
#
# pseudo-code:
#     // allocate new node
#     new = malloc(node_size);
#     new->node_next = NULL;
#     new->node_str = strptr;
#
#     // for loop:
#     prev = NULL;
#     for (cur = list_head;  cur != NULL;  cur = cur->node_next) {
#         if (strcmp(new->node_str,cur->node_str) < 0)
#             break;
#         prev = cur;
#     }
#
#     // insertion:
#     new->node_next = cur;
#     if (prev != NULL)
#         prev->node_next = new;
#     else
#         list_head = new;
insert:
    addi    $sp,$sp,-4
    sw      $ra,0($sp)

    # allocate a new node -- do this first as we'll _always_ need it
    li      $a0,node_size           # get the struct size
    jal     malloc
    move    $s2,$v0                 # remember the address

    # initialize the new node
    sw      $zero,node_next($s2)    # new->node_next = NULL
    sw      $s1,node_str($s2)       # new->node_str = strptr

    # set up for loop
    li      $s3,0                   # prev = NULL
    move    $s4,$s0                 # cur = list_head
    j       insert_test

insert_loop:
    lw      $a0,node_str($s2)       # get new string address
    lw      $a1,node_str($s4)       # get current string address
    jal     strcmp                  # compare them -- new < cur?
    bltz    $v0,insert_now          # if yes, insert after prev

    move    $s3,$s4                 # prev = cur

    lw      $s4,node_next($s4)      # cur = cur->node_next

insert_test:
    bnez    $s4,insert_loop         # cur == NULL? if no, loop

insert_now:
    sw      $s4,node_next($s2)      # new->node_next = cur
    beqz    $s3,insert_front        # prev == NULL? if yes, fly
    sw      $s2,node_next($s3)      # prev->node_next = new
    j       insert_done

insert_front:
    move    $s0,$s2                 # list_head = new

insert_done:
    lw      $ra,0($sp)
    addi    $sp,$sp,4
    jr      $ra

# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
    addi    $sp,$sp,-8
    sw      $ra,0($sp)
    sw      $s0,4($sp)

    beq     $s0,$zero,print_list_exit

print_list_loop:
    lw      $a0,node_str($s0)
    jal     print_string
    jal     print_newline
    lw      $s0,node_next($s0)      # node = node->node_next
    bnez    $s0,print_list_loop

print_list_exit:
    lw      $s0,4($sp)
    lw      $ra,0($sp)
    addi    $sp,$sp,8
    jr      $ra

    # Pseudo-standard library routines:
    #   wrappers around SPIM/MARS syscalls
    #

# assumes buffer to read into is in $a0, and max length is in $a1
get_string:
    li      $v0,8
    syscall
    jr      $ra

# malloc: takes one argument (in $a0) which indicates how many bytes
# to allocate; returns a pointer to the allocated memory (in $v0)
malloc:
    li      $v0,9                   # SPIM/MARS code for "sbrk"
    syscall
    jr      $ra

# print_newline: displays newline to standard output
print_newline:
    li      $v0,4
    la      $a0,STR_NEWLINE
    syscall
    jr      $ra

# print_string: displays supplied string (in $a0) to standard output
print_string:
    li      $v0,4
    syscall
    jr      $ra



# exit
exit:
    li $v0, 10
    syscall
