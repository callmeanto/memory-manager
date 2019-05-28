# Implementacion de lista simple enlazada

# equivalencias (sustituciones textuales)

    .eqv    node_next       4
    .eqv    node_str        0
    .eqv    node_size       8                   
      



.data	
array:            .word        0
hola:             .asciiz       "hola"
list_head:        .word 	0
newLine:          .asciiz     "\n"
INSERT_MSG:       .asciiz     "Ingrese un numero"
DELETE_MSG:       .asciiz     "Ingrese direccion de bloque a eliminar"
free_addr_msg:    .asciiz     "Ingrese la direccion del bloque que desea borrar"
malloc_size_msg:  .asciiz     "Ingrese tamano de malloc que desea hacer"
wel_msg:          .asciiz     "Bienvenido a su manejador de memoria"
create_msg:       .asciiz     "Ingrese el tamaño de memoria que desea inicializar: "
create_success:   .asciiz     "Lista creada con exito. La cabeza se encuentra en: "
free_success_msg: .asciiz     "Memoria liberada con exito"
init_menu_msg:    .asciiz     "Indique 1 si desea inicializar la memoria"
malloc_menu_msg:  .asciiz     "Indique 2 si desea hacer malloc"
free_menu_msg:    .asciiz     "Indique 3 si desea hacer free"
create_menu_msg:  .asciiz     "Indique 4 si desea crear una lista"
insert_menu_msg:  .asciiz     "Indique 5 si desea insertar en la lista"
delete_menu_msg:  .asciiz     "Indique 6 si desea eliminar en la lista"
print_menu_msg:   .asciiz     "Indique 7 si desea imprimir la lista"
print2_menu_msg:  .asciiz     "Indique 8 si desea imprimir varias listas"
lists_print_msg:  .asciiz     "Ingrese la direccion del primer nodo"
array_menu_msg:   .asciiz     "Indique 9 si desea probar caso 6"
exit_menu_msg:    .asciiz     "Indique 0 para salir del programa"
create_error_msg:  .asciiz    "no esta inicializada la memoria"
   

.text

main:
 
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
 
     li $v0,4
     la $a0,wel_msg      # Imprimir mensaje de bienvenida
     syscall 


     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 

     li $v0,4
     la $a0,init_menu_msg      # Mensaje de init
     syscall 
          	     	
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 

     li $v0,4
     la $a0,malloc_menu_msg      # Mensaje de menu
     syscall
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
     
     li $v0,4
     la $a0,free_menu_msg      # Mensaje de free
     syscall 
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
     
     li $v0,4
     la $a0,create_menu_msg      # Mensaje de create
     syscall 
          	     	
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
          
     
     li $v0,4
     la $a0,insert_menu_msg      # Mensaje de insertar
     syscall 	     	
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
     
     
     li $v0,4
     la $a0,delete_menu_msg      # Mensaje de delete
     syscall 
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall
     
     li $v0,4
     la $a0,print_menu_msg      # Mensaje de imprimir lista
     syscall  
     
     
     # salto de linea
     li $v0, 4
     la $a0, newLine
     syscall
 
     li $v0,4
     la $a0,print2_menu_msg      # Mensaje de imprimir varias listas
     syscall  
     
     
     # salto de linea
     li $v0, 4
     la $a0, newLine
     syscall

         
     li $v0,4
     la $a0,array_menu_msg      # Mensaje de crear arreglo
     syscall  
     
     # salto de linea
     li $v0, 4
     la $a0, newLine
     syscall
     
     li $v0,4
     la $a0,exit_menu_msg      # Mensaje para salir
     syscall 
     
     # salto de linea
     li $v0, 4
     la $a0, newLine
     syscall
     
     li $v0,5
     syscall   # Leemos opcion
     
     
     # Ve a init si opcion 1
     beq $v0,1,init_option
     
     # Ve a malloc si opcion 2
     beq $v0,2,malloc_option
     
     # Ve a free si opcion 3
     beq $v0,3,free_option
     
     # Ve a create si opcion 4
     beq $v0,4,create
     
     # Ve a insert si opcion 5
     beq $v0,5,insert_option
     
     # Ve a delete si opcion 6
     beq $v0,6,delete
     
     # Ve a imprimit si opcion 7
     beq $v0,7,print_option
     
     # Ve a imprimir varias listas si opcion 8
     beq $v0,8,print2_option
     
     # Ve a caso 6 listas si opcion 9
     beq $v0,9,case_6
     
     # Se cierra el programa si es 0
     beqz $v0,exit
     	
     # Vuelve a iterar si no es ninguna (usuario se equivoca)
     jal main
     
     

##################################################
# Rutinas de menu                                #
##################################################
init_option:
	li $v0,4
	la $a0,malloc_size_msg
	syscall
	
	# salto de linea
        li $v0, 4
        la $a0, newLine
        syscall
	
	# leemos el size del init
	li $v0, 5
        syscall
        
        jal init
        
        # Guardamos en t1 la direccion que retorna malloc en v0
        move $t1,$t0
     
        # Si no se pudo hacer, se sale del programa
        beq $v0,-1,exit
   
   			
        # syscall de imprimir init exitoso
        li $v0,4
        la $a0,create_success   # Imprimir mensaje de allocate succesfull
        syscall 
        
        
        # imprimir direccion de memoria
        li $v0,1
        move $a0,$t1
        syscall
        
        # salto de linea
        li $v0,4
        la $a0,newLine
        syscall
        
               
        j main



malloc_option:
	li $v0,4
	la $a0,malloc_size_msg
	syscall
	
	# salto de linea
        li $v0, 4
        la $a0, newLine
        syscall
	
	# leemos el size del malloc
	li $v0, 5
        syscall
        move $a0,$v0
        
        jal malloc
        
        addi $sp,$sp,-4
        sw $v0,0($sp)
        
        move $t1,$v0
        
         # Si no se pudo hacer, se sale del programa
        beq $v0,-2,main
   
   			
        # syscall de imprimir init exitoso
        li $v0,4
        la $a0,create_success   # Imprimir mensaje de allocate succesfull
        syscall 
        
        
        # imprimir direccion de memoria inicial
        move $a0,$t1
        li $v0,1
        syscall
        
       
        # salto de linea
        li $v0,4
        la $a0,newLine
        syscall
       
        
        j main

free_option:
	li $v0,4
	la $a0,free_addr_msg
	syscall
	
	# salto de linea
        li $v0, 4
        la $a0, newLine
        syscall
	
	# leemos la direccion a borrar
	li $v0, 5
        syscall
        
        jal free
      
     
        # Si no se pudo hacer, se sale del programa
        beq $v0,-3,exit
   
   			
        # syscall de imprimir init exitoso
        li $v0,4
        la $a0,free_success_msg   # Imprimir mensaje de allocate succesfull
        syscall 
        
        
       
        # salto de linea
        li $v0,4
        la $a0,newLine
        syscall
        
                
        j main



insert_option:

	  li $v0,4
	  la $a0,INSERT_MSG
    	  syscall

 	   # leemos un entero
           li $v0, 5
           syscall
           move $a0,$v0
           
           # Abrimos el stack para guardar este valor
           addi $sp,$sp,-4
           sb $a0,0($sp)
           addi $sp,$sp,4
           
           jal insert
           
           j main

delete_option:

	  li $v0,4
	  lw $a0,DELETE_MSG
    	  syscall

 	   # leemos la direccio
           li $v0, 5
           syscall
           
           # Abrimos el stack para guardar este valor
           addi $sp,$sp,-4
           la $t0,($a0)
           sb $t0,0($sp)
           addi $sp,$sp,4
           
           jal delete
           
           j main
           
print_option:
	
	# Accedemos a la cabeza de la lista
	
	# apuntador a primer nodo de la lista
	lw $t0,list_head
	
	addi $t4,$t0,-12
	
	
	# size
	lw $t1,4($t4)
	
	li $t2,0
	
	
	while:
          beq $t2, $t1, main
   
          # Recuperamos el valor del nodo  
          lw $t3, node_str($t0)
          
          # Incrementamos el indice
          lw $t0,node_next($t0)
             
          # syscall para imprimir
          li  $v0, 1
          move $a0, $t3
          syscall
          
          # salto de linea
          li $v0, 4
          la $a0, newLine
          syscall
          
          addi $t2,$t2,1
          
          j while

print2_option:

	li $v0,4
	la $a0,newLine
	syscall
	
	li $v0,4
	la $a0,lists_print_msg
	syscall
	
	# Leemos la cabeza de la lista
	li $v0,5
	syscall
	
	
	move $t0,$v0
	
	addi $t4,$t0,-12
	
	
	# size
	lw $t1,4($t4)
	
	li $t2,0
	
	
	while_list:
          beq $t2, $t1, main
   
          # Recuperamos el valor del nodo  
          lw $t3, node_str($t0)
          
          # Incrementamos el indice
          lw $t0,node_next($t0)
          
          
          # salto de linea
          li $v0,4
	  la $a0,newLine
	  syscall
             
          # syscall para imprimir
          li  $v0, 1
          move $a0, $t3
          syscall
          
          
          addi $t2,$t2,1
          
          j while_list
      
      
 case_6:
 
  lw $t0,0($sp)
	
  li $t1,0
	
	
  loop_array:
         beq $t1, 100, main
   
          sw $t1,($t0)
          
         
          # salto de linea
          li $v0,4
	  la $a0,newLine
	  syscall
            
          addi $t1,$t1,1
          
          addi $t0,$t0,4
          
         
          
          j loop_array
 	

print_array:

  lw $t0,0($sp)
  
  jal case_6
  
  li $t2,0
  
  loop_print:
  
  	  beq $t2,100,main
  	  
  	  lw $t1,($t0)
  	  # syscall para imprimir
          li  $v0, 1
          move $a0, $t1
          syscall
          
          addi $t0,$t0,4
          addi $t2,$t2,1

	
########################################
#     RUTINAS DE LA LISTA              #
########################################

create:
	
     # Abrimos stack pointer para guardar $ra de la llamada de create
     #addi $sp,$sp,-4
     #sw $ra,0($sp)
     
     #Verificar si el manejador no fue inicializado
     lw $t1, freeList($zero)
     beq $t1, 0, create_error
     
         
     
     # Creamos bloque en freeList
     #li $t0,4
     #sw $t1,freeList($t0)
     
     # Disponibilidad
     #addi $t0,$t0,4
     #li $t2,1
     #sw $t2,freeList($t0)
     
     # SIze
     #addi $t0,$t0,4
     #li $t2,12
     #sw $t2,freeList($t0)
     
     # Dir final
     #addi $t0,$t0,4
     #add $t1,$t2,$t1
     #sw $t1,freeList($t0)
     
     li $a0,12
     jal malloc
     
     move $t1,$v0
     
     # Si se pudo, se crea la cabeza
     addi $t2,$t1,12
     sw $t2,list_head   
  
     # Guardamos direccion inicial
     sw $t2,0($t1)
     
     # Guardamos size
     li $t3,0
     sw $t3,4($t1)
     
     # Guardamos direccion final
     sw $t2,8($t1)
     
     
    			
     # syscall de imprimir create exitoso
     li $v0,4
     la $a0,create_success   # Imprimir mensaje de allocate succesfull
     syscall 
     
     # salto de linea
     li $v0,4
     la $a0,newLine
     syscall
     
     lw $a0,0($t1)
     li $v0,1
     syscall
     
     # salto de linea
     li $v0,4
     la $a0,newLine
     syscall 
     
     lw $a0,4($t1)
     li $v0,1
     syscall
     
     # salto de linea
     li $v0,4
     la $a0,newLine
     syscall
     
     lw $a0,8($t1)
     li $v0,1
     syscall
     
     # salto de linea
     li $v0,4
     la $a0,newLine
     syscall
     
     
     # recuperamos el valor de $ra del stack pointer
     #lw $ra,4($sp)
     
     #addi $sp,$sp,8
     
     # Regresamos a donde fuimos llamados 
     j main
     
	
# Insertar un elemento en la lista

insert:
  
    move $a3,$a0
    
    addi $sp,$sp,-4
    sw $ra,0($sp)
    
    
    li $a0,8
    jal malloc
    
    lw $ra,0($sp)
    
    move $s2,$v0                 # la direccion que retorna malloc
    
    # si hay un error en el malloc, se sale
    beq $v0,-2,exit
    
    
    # actualizar la cabeza
    lw $t2,list_head
    addi $t2,$t2,-12
    lw $t3,8($t2)
   
     # Aumentamos en 1 el size de la lista
    lw $t4,4($t2)
    addi $t4,$t4,1
    sw $t4,4($t2) 
      
    # veamos si es el primer nodo
    beq $t2,$t3,node_first
    
    # Modificamos el apuntador de next del nodo anterior (ultimo nodo)
    sw $s2,node_next($t3)
            
    # Modificamos el apuntador a la direccion del ultimo nodo (actual a insertar)
    sw $s2,8($t2)
    
    
    # salto de linea
    li $v0,4
    la $a0,newLine
    syscall
    
    # imprimir s2      
    li $v0,1
    move $a0,$s2
    syscall
    
     # salto de linea
    li $v0,4
    la $a0,newLine
    syscall
    
    
    # imprimir a3      
    li $v0,1
    move $a0,$a3
    syscall
   
    
    # crear los nodos
    sw $a3,node_str($s2)   # Guardamos la direccion del string
    li $t5,0  # la direccion al siguiente (NULL)
    sw $t5,node_next($s2)
    
   
    jr $ra
    
    
node_first:

    sw $a3,node_str($s2)
    sw $zero,node_next($s2)
    
    jr $ra

# Eliminar elemento de la lista
delete: 
    # abrimos el stack pointer para guardar $ra y el valor s0
    addi $sp,$sp,-8
    sw $ra,0($sp)
    sw $s0,4($sp)
    
    
    # Recuperamos el valor que corresponde a la cantidad de elementos en la lista
    li $t0,8
    lw $a0,freeList($t0)
    
    
    # Si no hay elementos en la lista, error
    beqz $a0,exit
    
    jal free
    
    # Si hubo error con free, se sale del programa
    beq $v0,-3,exit
    
    # Sino, se modifican los apuntadores de la cabeza
    
    
    # Recuperamos el $ra
    lw $ra,0($sp)
    
    # Disminuimos la cantidad de elementos en 1
    li $t0,8
    lw $a0,freeList($t0)
    sub $a0,$a0,1
    sw $a0,freeList($t0)
    
    # Si $v0 es el primer nodo
    li $t0,4
    lw $a0,freeList($t0)
    
    beq $v0,$a0,change_first
    
    # Si $v0 es el ultimo nodo
    li $t0,12
    lw $a0,freeList($t0)
    
    beq $v0,$a0,change_last
    
    
    # Sino, delete listo
    # Regresamos a donde fuimos llamados
    jr $ra
    
	
change_first:

   # Recuperamos la cabeza actual
   li $t0,4
   lb $a0,freeList($t0)
   
   # Accedemos al siguiente de la lista
   lb $a1,node_next($a0)
   
   # Lo colocamos en la cabeza
   sb $a1,freeList($t0)
   
   jr $ra

	
change_last:
	
   # Recuperamos la cabeza actual
   li $t0,12
   lb $a0,freeList($t0)
   
   # Obtenemos la direccion
   addi $a1,$a0,-8
   
   
   # Lo colocamos en la cabeza
   sb $a1,freeList($t0)
  
   jr $ra

create_error:
   li $v0, 4
   la $a0, create_error_msg
   syscall
   
   

# salir del programa
exit:
    li $v0, 10
    syscall


.include "memory-manager.asm"
