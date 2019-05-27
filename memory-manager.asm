# Inicializamos el tamano de la estructura

# rutinas de la libreria
 
.data
	
	
	HEAP_SIZE:    .word   500
	freeList:     .word   0:2000
	init_size:    .word   0
	ini_bloq:     .word   0  # etiqueta que denota la direccion de inicio del bloque del init
	fin_bloq:     .word   0  # etiqueta que denota la direccion del final de bloque del init
	cant_elem:     .word  0  
	

	msize_msg:           .asciiz "Ingrese el tamaño de memoria que desea asignar:  "
	menu_msg:            .asciiz "Indique la operacion que desea realizar: "
	init_error_msg:      .asciiz "Error: el tamaño ingresado supera el almacenamiento del heap"
	init_success:        .asciiz "Memoria inicializada correctamente"
	malloc_error_msg:    .asciiz "Error: el tamaño ingresado no está disponible"
	malloc_success_msg:  .asciiz "Memoria asignada correctamente"	 
	free_error_msg:      .asciiz "Error: la direccion ingresada no es correcta" 
.text 
	
init:

	# a0 es el parametro que recibe
	# s0 es el heap size
	# s1 es 0 o 1 si size es menor que heap size
	# t2 contiene la direccion donde termina la memoria reservada
	# v0 contiene la direccion de inicio de la memoria reservada
	
	
	move $a0,$v0      # Almacenamos size a0
	sw $a0,init_size
	lw $s0,HEAP_SIZE  # Almacenamos HEAP_SIZE en un registro temporal
	
	
	# Verificamos que el init pueda hacerse
	bgt $a0,$s0,init_error # Va a la etiqueta init_error si $s0 > $s1
	
	# syscall allocate
	li  $v0, 9
	# Creamos el espacio de tamano que esta en a0 (allocate)
	syscall   
	 
	# Guardamos en la etiqueta el valor de v0 y en t0
	sw $v0,ini_bloq
	move $t0,$v0
	
	# Sumamos la cantidad de espacio para saber donde termina nuestro bloque
	add $t1,$t0,$a0
	
	# Guardamos en la etiqueta el valor donde termina el bloque
	sw $t1,fin_bloq
	
	# Calculamos pool size para el free list
	mul $t2,$a0,16
	
	# Guardamos los valores en el freeList
	sw $t0,freeList($zero)
	sw $t1,freeList($t2)
	
	
	# Abrimos stack para guardar la direccion inicial
     	addi $sp,$sp,-4
     	sw $t0,0($sp)
	 
	
	jr $ra
	

malloc:
	
	lw $s0, freeList($zero)    # Direccion donde inicia el bloque
	lw $s1,init_size
	lw $s2, fin_bloq           # Cargamos el valor donde termina la memoria en s2
	
	
	# Verificamos si init ya fue hecho
	beqz $s0,malloc_error	
	
	# Verificamos si el tamano de malloc es mayor que el de init size
	bgt $a0,$s1,malloc_error
	
	# Verificamos cuantos elementos quedan
	lw $t1,cant_elem
	add $t1,$t1,$a0
	
	bgt $t1,$s1,malloc_error
		
	
	
	# t0 registro indice para ver disponibilidad
	li $t0, 8
	
	# t2 registro indice para ver tamanio
	li $t2, 12
	
	# inicializamos t3 en cero
	li $t3, 0
	 
	while_malloc:
		
		# Guardamos el valor de disponibilidad 
		lw $t1,freeList($t0)
		
		
		# Branch a una funcion de disponibilidad
		# Si t1 = 0 es porque el bloque esta libre
		beq $t1, 0, disponible
		
		# Si el indice del arreglo alcanza el tamano de init
		addi $t5,$t0,12
		lw $t5,freeList($t5)
		beq $t5,$s2,malloc_error
		
		
		# Si no esta disponible, sigue buscando
		addi $t0,$t0,16
	
		j while_malloc
		
		# Funcion de disponibilidad donde se chequea la 2da condicion
		disponible:
		
		  # Actualizamos el indice para revisar el size
		  addi $t2,$t0,4
		  
		  # Guardamos en t3 el valor del tamano del bloque
		  lw $t3,freeList($t2)
		  
		  # Si el size del bloque es igual al tamano del malloc solicitado, se puede hacer
		  beq $t3,$a0,malloc_success
		  
		  # Si es mayor, se puede hacer
		  bgt $t3,$a0,malloc_success
		  
		  # Si la casilla tiene 0
		  beqz $t3,malloc_success
		  
		  # Si es menor, sigue buscando en la lista 
		 
		  # Incrementamos el indice del arreglo
		  addi $t0,$t0,16
		  
		  # Saltamos de nuevo al ciclo
		  j while_malloc
		  
		  
	malloc_success:	
	
        	
        	# Modificamos la disponibilidad
        	li $t1,1
        	sw $t1,freeList($t0)
        	
        	# Incrementamos la cantidad de elementos alojados
        	lw $a1,cant_elem
        	add $a1,$a1,$a0
        	sw $a1,cant_elem
        	
        	# Guardamos la direccion de inicio
      		addi $t0,$t0,-8
      		lw $v0,freeList($t0)
      		addi $t0,$t0,4
      		
      		sw $v0,freeList($t0)    
        	
        	# Verificamos el tamanio
        	bgt $t3,$a0,resize
        	
        	# Si son iguales, no hay que hacer mas nada
        	beq $t3,$a0,goback
        	
        	# Si no existe caja creada
        	beqz $t3,create_box
        	
        	create_box: 
        	   # Apunta a direccion inicial de bloque actual
        	   addi $t2,$t2,-8
        	   
        	   # Salvamos valor de direccion inicial de bloque actual
        	   lw $t1,freeList($t2)
        	   
        	   # Actualizamos direccion final del bloque
        	   add $t1,$t1,$a0
        	   
        	   lw $t3,fin_bloq
        	   bgt $t1,$t3,malloc_error
        	   
        	   
        	   addi $t2,$t2,12
        	   sw $t1,freeList($t2)
        	   
        	  addi $t2,$t2,-4 
        	  # Asignar size
        	  sw $a0,freeList($t2)
        	  
        	    
     		
     		addi $sp,$sp,-4
     		sw $v0,0($sp)   
     		
        	# imprimir direccion de memoria final
        	move $a0,$t1
        	li $v0,1
        	syscall
        	
        	lw $v0,0($sp)
        	   
        	   jr $ra
        	   
        	
        	
        	resize:
        	
        	   # Salvamos el size actual en un registro
        	   # para recuperarlo cuando se quiera guardar el size del sobrante
        	   
        	   lw $t6,freeList($t2)
        	   
        	   # Modificamos el tamanio
        	   sw $a0,freeList($t2)
        	     
        	   # Salvamos la direccion final vieja en un registro
        	   # para que pueda ser utilizado por el bloque sobrante despues
        	   addi $t2,$t2,4
        	   lw $t5,freeList($t2)
        	   
        	   # T5 TIENE LA DIRECCION FINAL DEL BLOQUE ORIGINAL
        	   # SERA UTILIZADO PARA ASIGNAR LA DIRECCION FINAL DEL NUEVO BLOQUE SOBRANTE 
        	  
        	   
        	   # Modificamos direccion final que es la inicial vieja mas tamanio nuevo
        	   addi $t2,$t2,-12
        	   lw $s0,freeList($t2)
        	   add $t4,$a0,$s0
        	     
        	   # Guardamos la nueva direccion final
        	   addi $t2,$t2,12
        	   sw $t4,freeList($t2)
        	
        	   # Regresamos los apuntadores a size
        	   addi $t2,$t2,-4 
        	   
        	   # Reubicar los bytes libres sobrantes
        	     
        	   # Reiniciamos t0 para buscar casillas disponibles
        	   li $t0,8
        	     
        	   # Funcion para buscar espacio libre empezando desde el inicio de la lista
        	   loop_disp:
        	     
        	     lw $t1,freeList($t0)
        	     
        	     # Si t1 = 0, el bloque esta libre
        	     beq $t1,0,segunda_cond
        	     
        	     # Sino, incrementamos t0 y entramos al ciclo de nuevo
        	     addi $t0,$t0,16
        	     j loop_disp
        	     
        	     segunda_cond:
        	     	addi $t0,$t0,4
        	     	
        	     	lw $t1,freeList($t0)
        	     	
        	     	beq $t1,0,disp
        	     	
        	     	addi $t0,$t0,16
        	        j loop_disp
        	      
        	     
        	     # Funcion para asignar nuevo bloque de bytes sobrantes (cambiar apuntadores)
        	     disp:
			# Accedemos a la direccion inicial
			addi $t0,$t0,-8
			
			# Guardamos en la posicion de direccion inicial el nuevo valor
			sw $t4,freeList($t0)        	     
        	     
        	    	
        	     	# t0 apunta a direccion final sobrante
        	     	addi $t0,$t0,12
        	     	
        	     	# Recuperamos el valor de direccion final antiguo 
        	     	sw $t5,freeList($t0)
        	     	
        	
        	     	# Nuevo tamanio libre
        	     	sub $t6,$t6,$a0
        	     	
        	     	# Modificamos apuntador para que apunte a size
        	     	add $t0,$t0,-4
        	     	
        	     	# Sumamos sobrante mas valor de libre actual
        	     	lw $s0,freeList($t0)
        	     	add $t6,$t6,$s0
        	     	
        	     	# Guardamos el nuevo tamanio en la posicion de la lista
        	     	sw $t6,freeList($t0)
        	     	
        	     	# Devolvemos el apuntador a disponibilidad
        	     	addi $t0,$t0,-4
        	     	
        	     	move $v0,$t4
        	     	
    	     	        addi $sp,$sp,-4
	     		sw $v0,0($sp)   
     		
     			
        		# imprimir direccion de memoria final
        		move $a0,$t4
        		li $v0,1
        		syscall
        	
	        	lw $v0,0($sp)

        	     	
        	     	jr $ra
        	     
 	
free: 
	# Hacemos busqueda lineal para buscar el bloque de la direccion proporcionada
	li $t0,4
	move $a0,$v0
	
	while_free:
		lw $t1,freeList($t0)
		
		# Si las direcciones coinciden
		beq $t1,$a0,segunda_cond1
		
		
		addi $t0,$t0,16
		
		# Si llego al final del arreglo
		lw $t1,freeList($t0)
		lw $s1,fin_bloq
		beq $t1,$s1,free_error
		
	
		j while_free
		
		segunda_cond1:
			addi $t0,$t0,4
			
			lw $t1,freeList($t0)
			
			beq $t1,1,free_success
			
			beq $t1,0,free_error
			
		
		free_success:
		
			# Liberamos el bloque en cuestion colocando un 0 en la posicion correspondiente
			li $v0,0
			sw $v0,freeList($t0)
			
			
			
			# Restamos la cantidad de elementos
			addi $t0,$t0,4
			lw $t1,freeList($t0)
			lw $t2,cant_elem
			sub $t2,$t2,$t1
			
			sw $t2,cant_elem
			
			jr $ra
			
			# Movemos el size de t1 a t3
			#move $t3,$t1
			
			#addi $sp,$sp,-4
			#sw $ra,0($sp)
			
			# Actualizamos direccion final
			
			
			#jal linear_search
			
			# Si regresa es porque no hay bloques adyacentes disponibles
			
			
			

###################################		
#  FUNCIONES AUXILIARES           #
###################################


# Ahora buscamos linealmente si hay algun bloque libre adyacente
			
# Buscamos a la izquierda
			
# Movemos el apuntador $t0 a direccion inicial  
addi $t0,$t0,-8
			
# La guardamos en el registro
			lw $t1,freeList($t0)
			
			
			# Guardamos la direccion a la izquierda en un registro
			sub $t1,$t1,$t3
			
			
			# Guardamos el apuntador en un registro
			# T5 APUNTA A DIRECCION INCIAL DE BLOQUE A LA DERECHA
			move $t5,$t0
			
			# Movemos el apuntador
			addi $t0,$t0,12
			
			# Guardamos la direccion final del bloque actual
			lw $t2,freeList($t0)
			
	
		
			# Seteamos t0 en el primer apuntador a direccion final
			li $t0,12
			
			
			# Hacemos busqueda lineal llamando a while_2
			jal while_2
			  	
				  	
				  
			# Buscamos a la derecha
			# Para este punto $t5 apunta a la direccion final del bloque actual
			
			# En t2 va la direccion siguiente a la final del bloque que buscamos 
			# Que es la inicial del bloque adyacente
			
			# La guardamos en el registro
			lw $t1,freeList($t5)
			
			# Guardamos la direccion a la derecha en un registro
			add $t1,$t1,$t4 
			

			# Guardamos en t3 el size del bloque actual
			addi $t5,$t5,-4
		
			lw $t3,freeList($t5)
			
			# Seteamos t0 en el primer apuntador a direccion inicial
			li $t0,4
			
			
			# Buscamos con busqueda lineal
			j while_2
				  
			
			
while_2:
	lw $t3,freeList($t0)
				
	# Si coinciden, hay que ver si esta libre
	beq $t3,$t1,segunda_cond2
			
	# Si llego al final del arreglo
	addi $s0,$t0,16
				
	lw $s1,fin_bloq
	
	# recuperamos el valor de $ra del stack
	addi $sp,$sp,-4
	lw $ra,0($sp)
	
	# Regresar, free exitoso						
	beq $s0,$s1,goback
				
	# Sino, regresa al ciclo
	addi $t0,$t0,16
	j while_2
	
				
# Condicion de dir inicial			
segunda_cond2:
	addi $t0,$t0,4
	lw $t1,freeList($t0)
				  
	# Esta libre
	beq $t1,0,merge
	
	
	lw $ra,0($sp)
	bne $t1,0,goback
			
	
# Condicion de dir final
segunda_cond3:
	addi $t0,$t0,-8
	lw $t1,freeList($t0)
				  
	# Esta libre
	beq $t1,0,merge	  

# Pegar bloques				  
merge:
				  
	# Actualizamos el bloque mas a la izquierda
				  
	# Movemos el apuntador a direccion final
	addi $t0,$t0,8
				  
	# Guardamos el valor de la direccion final del bloque viejo en la final de su adyacente
	sw $t2,freeList($t0)
				  
	# Movemos el apuntador al size
	addi $t0,$t0,-4
				  
	# Restauramos el valor actual de size
	lw $t1,freeList($t0)
				  
	# Sumamos el size actual al del anterior
	add $t1,$t1,$t4
				  
	# Lo salvamos en el arreglo
	sw $t1,freeList($t0)
	
	j zero
				  
# Seteamos con 0 las casillas del bloque anterior
zero:
	# colocamos 0
	sw $zero,freeList($t5)
				  	
	# incrementamos el apuntador
	addi $t5,$t5,4
				  	
	# saltamos a la etiqueta
	blt $t5,12,zero
	
	# recuperamos el valor de $ra del stack
	addi $sp,$sp,-4
	lw $ra,0($sp)
	
	beq $t5,12,goback

goback:
	jr $ra
				
	


###########################

# BLOQUE DE ERRORES

##########################


init_error:
	# Maneja el error del init
	li $v0,0       
	addi $v0, $zero, -1
	
	j perror
	
malloc_error:
	# Maneja el error del free
	li $v0,0       
	addi $v0, $zero, -2
	
	j perror
	
free_error:
	# Maneja el error del free
	li $v0,0       
	addi $v0, $zero, -3
	
	j perror
	
	
perror: 
	
	# Si code = -1 , error de init
	beq  $v0,-1,print_init  
	
	# Si code = -2 , error de malloc
	beq $v0,-2,print_malloc

	# Si code = -3 , error de free
	beq $v0,-3,print_free
		
print_init:

	# abrimos stack pointer para guardar $v0 en otro lado
	addi $sp,$sp,-4
	sw $v0,0($sp)

	
	li $v0,4
	la $a0,init_error_msg
	syscall
	
	# lo recuperamos
	lw $v0,0($sp)
	addi $sp,$sp,4
	
	jr $ra
	
print_malloc:

	
	# abrimos stack pointer para guardar $v0 en otro lado
	addi $sp,$sp,-4
	sw $v0,0($sp)

	li $v0,4
	la $a0,malloc_error_msg
	syscall
	
	# lo recuperamos
	lw $v0,0($sp)
	addi $sp,$sp,4
	
	jr $ra
	
print_free:

	# abrimos stack pointer para guardar $v0 en otro lado
	addi $sp,$sp,-4
	sw $v0,0($sp)

	li $v0,4
	la $a0,free_error_msg
	syscall
	
	# lo recuperamos
	lw $v0,0($sp)
	addi $sp,$sp,4
	
	jr $ra
	
	



	
	
	
	


	

	
	
	
	
	 
	 
	
	
