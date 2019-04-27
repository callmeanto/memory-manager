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
create_msg:   .asciiz   "Ingrese el tamaño de memoria que desea inicializar: "
create_success:   .asciiz   "Lista creada con exito. La cabeza se encuentra en: "
menu_msg:   .asciiz     "Indique 1 si desea insertar en la lista o 2 si desea eliminar y 0 para salir"

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
     
      
     jal create         # Llamamos a create
     
loop_main:

     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 

     li $v0,4
     la $a0,menu_msg      # Mensaje de menu
     syscall
     
     li $v0,5
     syscall   # Leemos opcion
     
     
     # Ve a insert si opcion 1
     beq $v0,1,insert_option
     
     # Ve a delete si opcion 2
     beq $v0,2,delete_option
     
     # se cierra el programa si es 0
     beqz $v0,exit
     
     # vuelve a iterar si no es 0
     j loop_main
     
     

##################################################
# Rutinas de menu
##################################################

insert_option:



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

########################################
#     RUTINAS DE LA LISTA              #
########################################

create:
	
     # Abrimos stack pointer para guardar $ra de la llamada de create
     addi $sp,$sp,-4
     sw $ra,0($sp)
   
	 
      	
     # LLamamos a init
     jal init
     
     # Si no se pudo hacer, se sale del programa
     beq $v0,-1,exit
     
     # Si se pudo, se crea la cabeza
     lw $a0,4($sp)
     
     # Todavia no hay nodos
     lw 4($a0),$zero  # direccion de primer nodo
     lw 8($a0),$zero  # direccion de ultimo nodo
     lw 16($a0),$zero # cantidad de nodos
     
     			
     # syscall de imprimir init exitoso
     li $v0,4
     la $a0,create_success   # Imprimir mensaje de allocate succesfull
     syscall 
     
     # syscall de imprimir direccion inicial
     li $v0,1
     lw $a0,4($sp)   # Se recupera del stack pointer la direccion de la cabeza de la lista
     syscall
     
     # recuperamos el valor de $ra del stack pointer
     lw $ra,0($sp)
     
     addi $sp,$sp,4
     
     # Regresamos a donde fuimos llamados 
     jr $ra
     
	
# Insertar un elemento en la lista

insert:
    # Abrimos el stack pointer para guardar el $ra
    addi    $sp,$sp,-8
    sw      $ra,0($sp)

    # reservar un nuevo nodo
    li $a0,node_size           # tamano fijo
    jal malloc
    move $s2,$v0                 # la direccion que retorna malloc
    addi $s1,$s2,$a0             # la siguiente direccion 
    
    # inicializar el nuevo nodo
    sb      $zero,node_next($s2)    # colocamos el apuntador al siguiente como nulo
    sb      $zero,node_str($s2)       # y el nodo como null

    
    # Abrimos stack pointer para recuperar string
    lb $a0,4($sp)
    
    # crear los nodos
    sb $a0,node_str($s2)   # Guardamos la direccion del string
    sb $s1,node_next($s2)  # la direccion al siguiente
    
    
    # actualizamos cabeza de la lista
    li $a1,8
    sb $s2,freeList($a1)  # el ultimo elemento es el actual
    
    # aumentamos la cantidad de elementos en 1
    li $a1,4
    lb $s3,freeList($a1)
    addi $s3,$s3,1
    
    
    
    
    jr $ra

   
    
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

   

# assumes buffer to read into is in $a0, and max length is in $a1
get_string:
    li      $v0,8
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
