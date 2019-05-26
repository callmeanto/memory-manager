# Implementacion de lista simple enlazada

# equivalencias (sustituciones textuales)

    .eqv    node_next       4
    .eqv    node_str        0
    .eqv    node_size       8    
       

# rutinas de la lista
    .globl  create
    .globl  insert
    .globl  delete
    .globl  main
    .globl  print_option

.data	

	
newLine:          .asciiz     "\n"
INSERT_MSG:       .asciiz     "Ingrese un numero"
DELETE_MSG:       .asciiz     "Ingrese direccion de bloque a eliminar"
free_addr_msg:    .asciiz     "Ingrese la direccion del bloque que desea borrar"
malloc_size_msg:  .asciiz     "Ingrese tamano de malloc que desea hacer"
wel_msg:          .asciiz     "Bienvenido a su manejador de memoria"
create_msg:       .asciiz     "Ingrese el tamaño de memoria que desea inicializar: "
create_success:   .asciiz     "Lista creada con exito. La cabeza se encuentra en: "
free_success_msg:     .asciiz     "Memoria liberada con exito"
init_menu_msg:    .asciiz     "Indique 1 si desea inicializar la memoria"
malloc_menu_msg:  .asciiz     "Indique 2 si desea hacer malloc"
free_menu_msg:    .asciiz     "Indique 3 si desea hacer free"
create_menu_msg:  .asciiz     "Indique 4 si desea crear una lista"
insert_menu_msg:  .asciiz     "Indique 5 si desea insertar en la lista"
delete_menu_msg:  .asciiz     "Indique 6 si desea eliminar en la lista"
print_menu_msg:   .asciiz     "Indique 7 si desea imprimir la lista"
exit_menu_msg:    .asciiz     "Indique 0 para salir del programa"

   

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
     la $a0,free_menu_msg      # Mensaje de init
     syscall 
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
     
     li $v0,4
     la $a0,create_menu_msg      # Mensaje de init
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
        
        
        # imprimir direccion de memoria final
        lw $t1,init_size
        mul $t1,$t1,16
        lw $t1,freeList($t1)
        li $v0,1
        move $a0,$t1
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
        move $t1,$v0
        
         # Si no se pudo hacer, se sale del programa
        beq $v0,-2,exit
   
   			
        # syscall de imprimir init exitoso
        li $v0,4
        la $a0,create_success   # Imprimir mensaje de allocate succesfull
        syscall 
        
        
        # imprimir direccion de memoria
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
	li $t0,4
	lb $a0,freeList($t0)
	
	# Almacenamos la cantidad de elementos en un registro
	addi $t0,$t0,8
	lb $a1,freeList($t0)
	
	# reiniciamos $t0 para usarlo de indexador
	# t0 contiene la direccion de inicio del primer nodo
	move $t0,$a0
	
	while:
          beq $t0, $a1, exit
   
          # Recuperamos el valor  
          lw $t1, node_str($t0)
          
          # Incrementamos el indice
          lw $t0,node_next($t0)
             
          # syscall para imprimir
          li  $v0, 1
          move $a0, $t1
          syscall
          
          # salto de linea
          li $v0, 4
          la $a0, newLine
          syscall
          
          j while
       

########################################
#     RUTINAS DE LA LISTA              #
########################################

create:
	
     # Abrimos stack pointer para guardar $ra de la llamada de create
     addi $sp,$sp,-4
     sw $ra,0($sp)
         	
     # LLamamos a init
     jal init
     
     # Guardamos en t1 la direccion que retorna malloc en v0
     move $t1,$v0
     
     # Si no se pudo hacer, se sale del programa
     beq $v0,-1,exit
    
     # Si se pudo, se crea la cabeza
     lw $a0,4($sp)
     
    			
     # syscall de imprimir init exitoso
     li $v0,4
     la $a0,create_success   # Imprimir mensaje de allocate succesfull
     syscall 
     
     # recuperamos el valor de $ra del stack pointer
     lw $ra,4($sp)
     
     addi $sp,$sp,8
     
     # Regresamos a donde fuimos llamados 
     jr $ra
     
	
# Insertar un elemento en la lista

insert:
    # Abrimos el stack pointer para guardar el $ra
    addi    $sp,$sp,-8
    sw      $ra,4($sp)

    jal malloc
    
    move $s2,$v0                 # la direccion que retorna malloc
    add $s1,$s2,$a0             # la siguiente direccion 
    
    move $a0,$v0
   
    
    # si hay un error en el malloc, se sale
    beq $v0,-2,exit
    
    # si se puede, se crea el nodo
    
    # inicializar el nuevo nodo
    sw      $zero,node_next($s2)      # colocamos el apuntador al siguiente como nulo
    sw      $zero,node_str($s2)       # y el nodo como null

    
    # Abrimos stack pointer para recuperar string
    lw $a0,4($sp)
    
    # crear los nodos
    sb $a0,node_str($s2)   # Guardamos la direccion del string
    sb $s1,node_next($s2)  # la direccion al siguiente
    
    
    # actualizamos cabeza de la lista
    li $a1,8
    sw $s2,freeList($a1)  # el ultimo elemento es el actual
    
    # aumentamos la cantidad de elementos en 1
    li $a1,4
    lw $s3,freeList($a1)
    addi $s3,$s3,1
    
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



# salir del programa
exit:
    li $v0, 10
    syscall


.include "memory-manager.asm"
