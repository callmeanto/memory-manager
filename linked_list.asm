# Implementacion de lista simple enlazada

# equivalencias (sustituciones textuales)

    .eqv    node_next       0
    .eqv    node_str        4
    .eqv    node_size       8
       

# rutinas de la lista
    .globl  create
    .globl  insert
    .globl  delete
    .globl  main
    .globl  print_option

# rutinas de la libreria
    .globl  init
    .globl  malloc
    .globl  free


.data
newLine:          .asciiz     "\n"
INSERT_MSG:       .asciiz     "Ingrese un numero"
DELETE_MSG:       .asciiz     "Ingrese direccion de bloque a eliminar"
wel_msg:          .asciiz     "Bienvenido a su manejador de memoria"
create_msg:       .asciiz     "Ingrese el tamaño de memoria que desea inicializar: "
create_success:   .asciiz     "Lista creada con exito. La cabeza se encuentra en: "
menu_msg:         .asciiz     "Indique 1 si desea insertar en la lista, 2 si desea eliminar, 3 para ver el estado de la lista, o 0 para salir"

   

.text

main:
 
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
     
     li $v0,4
     la $a0,newLine      # Salto de linea
     syscall 
     
     li $v0,5
     syscall   # Leemos opcion
     
     
     # Ve a insert si opcion 1
     beq $v0,1,insert_option
     
     
     # Ve a delete si opcion 2
     beq $v0,2,delete_option
     
     # Ve a imprimir si opcion 3
     beq $v0,2,print_option
     
     # Se cierra el programa si es 0
     beqz $v0,exit
     	
     # Vuelve a iterar si no es ninguna (usuario se equivoca)
     jal loop_main
     
     

##################################################
# Rutinas de menu                                #
##################################################
insert_option:

	  li $v0,4
	  lw $a0,INSERT_MSG
    	  syscall

 	   # leemos un entero
           li $v0, 5
           syscall
           
           # Abrimos el stack para guardar este valor
           addi $sp,$sp,-4
           la $t0,($a0)
           sb $t0,0($sp)
           addi $sp,$sp,4
           
           jal insert
           
           j loop_main

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
           
           j loop_main
           
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
     
     # Si no se pudo hacer, se sale del programa
     beq $v0,-1,exit
    
     # Si se pudo, se crea la cabeza
     lw $a0,4($sp)
     
    			
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
    sw      $ra,4($sp)

    # reservar un nuevo nodo
    li $a0,node_size           # tamano fijo
    jal malloc
    
    # si hay un error en el malloc, se sale
    beq $v0,-2,exit
    
    # si se puede, se crea el nodo
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

# Eliminar elemento de la lista
delete: 
    # abrimos el stack pointer para guardar $ra y el valor s0
    addi $sp,$sp,-8
    sw $ra,0($sp)
    sw $s0,4($sp)
    
    
    # Recuperamos el valor que corresponde a la cantidad de elementos en la lista
    li $t0,8
    lb $a0,freeList($t0)
    
    
    # Si no hay elementos en la lista, error
    beqz $a0,exit_error
    
    jal free
    
    # Si hubo error con free, se sale del programa
    beq $v0,-3,exit
    
    # Sino, se modifican los apuntadores de la cabeza
    
    
    # Recuperamos el $ra
    lw $ra,0($sp)
    
    # Disminuimos la cantidad de elementos en 1
    li $t0,8
    lb $a0,freeList($t0)
    sub $a0,$a0,1
    sb $a0,freeList($t0)
    
    # Si $v0 es el primer nodo
    li $t0,4
    lb $a0,freeList($t0)
    
    beq $v0,$a0,change_first
    
    # Si $v0 es el ultimo nodo
    li $t0,12
    lb $a0,freeList($t0)
    
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
