# Inicializamos el tamano de la estructura
.data 
	HEAP_SIZE:    .byte   100
	init_size:    .byte   0
	freeList:     .byte   0:1600
	
	ini_bloq:     .byte   0  # etiqueta que denota la direccion de inicio del bloque del init
	fin_bloq:     .byte   0  # etiqueta que denota la direccion del final de bloque del init
	
	wel_msg:             .asciiz "Ingrese el tamaño de memoria que desea inicializar: "
	msize_msg:           .asciiz "Ingrese el tamaño de memoria que desea asignar:  "
	menu_msg:            .asciiz "Indique la operacion que desea realizar: "
	newLine:             .asciiz "\n"
	init_error_msg:      .asciiz "Error: el tamaño ingresado supera el almacenamiento del heap"
	init_success:        .asciiz "Memoria inicializada correctamente"
	malloc_error_msg:    .asciiz "Error: el tamaño ingresado no está disponible"
	malloc_success_msg:  .asciiz "Memoria asignada correctamente"	 
	free_error_msg:      .asciiz "Error: la direccion ingresada no es correcta"
	free_success_msg:    .asciiz "Memoria liberada correctamente"	 
.text 

main: 
	li $v0,4
	la $a0,wel_msg      # Imprimir mensaje de bienvenida
	syscall 
	
	li $v0,5
	syscall
	sb $v0, init_size   	# Leemos size
	 
	
	# LLamamos a init
	jal init
	
	
	# Inicializamos el registro s1 que es donde se actualiza la dir de memoria del malloc anterior
	lb $s1,ini_bloq
	
	li $v0,4
	la $a0,newLine      # Imprimir salto de linea
	syscall 
	

		
		
		
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
		
		
		
	

init:
	lb $s0,init_size      # Almacenamos size en un registro temporal
	lb $s1,HEAP_SIZE      # Almacenamos HEAP_SIZE en un registro temporal
	
	
	# Verificamos que el init pueda hacerse
	sgt $v0,$s0,$s1
	bgt $s0,$s1,init_error # Va a la etiqueta init_error si $s0 > $s1
	
	
	# syscall allocate
	li  $v0, 9
	lb $a0,init_size      # Creamos el espacio de tamano size (allocate)
	syscall   
	 
	# Guardamos en la etiqueta el valor de v0
	sb $v0,ini_bloq

	# Guardamos el tamanio en un registro
	lb $t0,init_size
	lb $t1,ini_bloq
	
	
	# Sumamos la cantidad de espacio para saber donde termina nuestro bloque
	add $t2,$t1,$t0
	
	# Guardamos en la etiqueta el valor de t0
	sb $t2,fin_bloq
	
	# Reiniciamos los apuntadores
	li $s2,0
	li $s1,16
	
	mul $s1,$s1,$s0

	
	
	# Guardamos las direcciones inicial y final en freeList
	sb $t1,freeList($s2)
	
	sb $t2,freeList($s1) 
	
			
	# syscall de imprimir init exitoso
	li $v0,4
	la $a0,init_success   # Imprimir mensaje de allocate succesfull
	syscall 
	
	
	jr $ra
	

malloc:
	lb $s0, init_size    # Cargamos el valor de init size en t0
	lb $s2, fin_bloq
	
	# t0 registro indice para ver disponibilidad
	li $t0, 8
	
	# t2 registro indice para ver tamanio
	li $t2, 0
	
	# inicializamos t3 en cero
	li $t3,0
	 
	while:
		
		# Guardamos el valor de disponibilidad 
		lb $t1,freeList($t0)
		
		bgt $a0,$s0,malloc_error
		
		# Branch a una funcion de disponibilidad
		# Si t1 = 0 es porque el bloque esta libre
		beq $t1, 0, disponible
		
		# Si el indice del arreglo alcanza el tamano de init
		addi $t5,$t0,12
		beq $t5,$s2,malloc_error
		
		# Si no esta disponible, sigue buscando
		addi $t0,$t0,16
	
		j while
		
		# Funcion de disponibilidad donde se chequea la 2da condicion
		disponible:
		
		  # Actualizamos el indice para revisar el size
		  addi $t2,$t0,4
		  
		  # Guardamos en t3 el valor del tamano del bloque
		  lb $t3,freeList($t2)
		  
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
		  j while
		  
		  
	malloc_success:	
		
          	# Restauramos direccion de inicio de memoria y tamano del malloc hecho
      
        	#lw   $s1, 0($sp)
        	#lw   $a0, 4($sp)
        	#addi $sp, $sp, 8
        	
        	# Nueva direccion
        	#add $s1,$s1,$a0
        	
        	# Modificamos la disponibilidad
        	li $t1,1
        	sb $t1,freeList($t0)
        	
        	# Verificamos el tamanio
        	bgt $t3,$a0,resize
        	
        	# Si no existe caja creada
        	beqz $t3,create_box
        	
        	create_box:
        	   # Asignar size
        	   sb $a0,freeList($t2)
        	   
        	   # Apunta a direccion final de bloque anterior
        	   addi $t0,$t0,-8
        	   
        	   # Salvamos valor de direccion final de bloque anterior
        	   sb $t1,freeList($t0)
        	   
        	   # Actualizamos direccion inicial del bloque
        	   addi $t1,$t1,4
        	   
        	   # Guardamos direccion inicial del bloque
        	   addi $t0,$t0,4
        	   sb $t1,freeList($t0)
        	   
        	   
        	   # Para la direccion final
        	   
        	   # Apuntamos a la direccion final
        	   addi $t0,$t0,12
        	   
        	   # Calculamos valor de direccion final
        	   add $t1,$t1,$a0
        	   
        	   # Guardamos direccion 
        	   sb $t1,freeList($t0)
        	   
        	
        	
        	resize:
        	
        	   # Salvamos el size actual en un registro
        	   # para recuperarlo cuando se quiera guardar el size del sobrante
        	   
        	   lb $t6,freeList($t2)
        	   
        	   # Modificamos el tamanio
        	   sb $a0,freeList($t2)
        	     
        	   # Salvamos la direccion final vieja en un registro
        	   # para que pueda ser utilizado por el bloque sobrante despues
        	   addi $t2,$t2,4
        	   lb $t5,freeList($t2)
        	   
        	   # T5 TIENE LA DIRECCION FINAL DEL BLOQUE ORIGINAL
        	   # SERA UTILIZADO PARA ASIGNAR LA DIRECCION FINAL DEL NUEVO BLOQUE SOBRANTE 
        	  
        	   
        	   # Modificamos direccion final que es la inicial vieja mas tamanio nuevo
        	   addi $t2,$t2,-12
        	   lb $s0,freeList($t2)
        	   add $t4,$a0,$s0
        	     
        	   # Guardamos la nueva direccion final
        	   addi $t2,$t2,12
        	   sb $t4,freeList($t2)
        	
        	   # Regresamos los apuntadores a size
        	   addi $t2,$t2,-4 
        	   
        	   # Reubicar los bytes libres sobrantes
        	     
        	   # Reiniciamos t0 para buscar casillas disponibles
        	   li $t0,8
        	     
        	   # Funcion para buscar espacio libre empezando desde el inicio de la lista
        	   loop_disp:
        	     
        	     lb $t1,freeList($t0)
        	     
        	     # Si t1 = 0, el bloque esta libre
        	     beq $t1,0,segunda_cond
        	     
        	     # Sino, incrementamos t0 y entramos al ciclo de nuevo
        	     addi $t0,$t0,16
        	     j loop_disp
        	     
        	     segunda_cond:
        	     	addi $t0,$t0,4
        	     	
        	     	lb $t1,freeList($t0)
        	     	
        	     	beq $t1,0,disp
        	     	
        	     	addi $t0,$t0,16
        	        j loop_disp
        	      
        	     
        	     # Funcion para asignar nuevo bloque de bytes sobrantes (cambiar apuntadores)
        	     disp:
			# Accedemos a la direccion inicial
			addi $t0,$t0,-4
			
			# Guardamos en la posicion de direccion inicial el nuevo valor
			sb $t4,freeList($t0)        	     
        	     
        	    	
        	     	# t0 apunta a direccion final sobrante
        	     	addi $t0,$t0,12
        	     	
        	     	# Recuperamos el valor de direccion final antiguo 
        	     	sb $t5,freeList($t0)
        	     	
        	
        	     	# Nuevo tamanio libre
        	     	sub $t6,$t6,$a0
        	     	
        	     	# Modificamos apuntador para que apunte a size
        	     	add $t0,$t0,-4
        	     	
        	     	# Sumamos sobrante mas valor de libre actual
        	     	lb $s0,freeList($t0)
        	     	add $t6,$t6,$s0
        	     	
        	     	# Guardamos el nuevo tamanio en la posicion de la lista
        	     	sb $t6,freeList($t0)
        	     	
        	     	# Devolvemos el apuntador a disponibilidad
        	     	addi $t0,$t0,-4
        	     	
        	     	j print_message
        	     
        	     
			
		print_message:
		
			# Imprime mensaje de exito
			li $v0,4
			la $a0,malloc_success_msg
			syscall
			
			li $v0,4
			la $a0,newLine      # Imprimir salto de linea
			syscall 
	
			
			jr $ra
	

free: 
	li $t0,4
	
	while_free:
		lb $t1,freeList($t0)
		
		# Si las direcciones coinciden
		beq $t1,$a0,segunda_cond1
		
		# Si llego al final del arreglo
		addi $t0,$t0,12
		lb $t1,freeList($t0)
		lb $s1,fin_bloq
		beq $t1,$s1,free_error
		
		addi $t0,$t0,-12
		
		# sino, sigue buscando
		addi $t0,$t0,16
		
		j while_free
		
		segunda_cond1:
			addi $t0,$t0,4
			
			lb $t1,freeList($t0)
			
			beq $t1,1,free_success
			
		
		free_success:
		
			# Liberamos el bloque en cuestion colocando un 0 en la posicion correspondiente
			li $t1,0
			sb $t1,freeList($t0)
			
			# Ahora buscamos linealmente si hay algun bloque libre adyacente
			
			# Buscamos a la izquierda
			
			# Movemos el apuntador $t0 a direccion inicial  
			addi $t0,$t0,-4
			
			# La guardamos en el registro
			lb $t1,freeList($t0)
			
			# Guardamos la direccion a la izquierda en un registro
			addi $t1,$t1,-4 
			
			
			# Guardamos el apuntador en un registro
			# T5 APUNTA A DIRECCION INCIAL DE BLOQUE A LA IZQUIERDA
			move $t5,$t0
			
			# Movemos el apuntador
			addi $t0,$t0,12
			
			# Guardamos la direccion final del bloque actual
			lb $t2,freeList($t0)
			
			# Guardamos el size del bloque actual
			addi $t0,$t0,-4
		
			lb $t4,freeList($t0)
			
		
			# Seteamos t0 en el primer apuntador a direccion final
			li $t0,12
			
			
			# Hacemos busqueda lineal llamando a while_2
			jal while_2
			  	
				  	
				  
			# Buscamos a la derecha
			# Para este punto $t5 apunta a la direccion final del bloque actual
			
			# En t2 va la direccion siguiente a la final del bloque que buscamos 
			# Que es la inicial del bloque adyacente
			
			# La guardamos en el registro
			lb $t1,freeList($t5)
			
			# Guardamos la direccion a la derecha en un registro
			addi $t2,$t1,4 
			

			# Guardamos en t3 el size del bloque actual
			addi $t5,$t5,-4
		
			lb $t3,freeList($t5)
			
			# Seteamos t0 en el primer apuntador a direccion inicial
			li $t0,4
			
			# Buscamos con busqueda lineal
			jal while_2
				  
			# Despues de verificar, se imprime el mensaje de exito
			j print_msg_free
			
			
.text

		###################################		
		#  FUNCIONES AUXILIARES           #
		###################################
while_2:
	lb $t3,freeList($t0)
				
	# Si coinciden, hay que ver si esta libre
	beq $t3,$t1,segunda_cond2
			
	# Si llego al final del arreglo
	addi $s0,$t0,16
				
	lb $s1,fin_bloq
				
	beq $s0,$s1,print_msg_free
				
				
	# Sino, regresa al ciclo
	addi $t0,$t0,16
	j while_2
				
				
segunda_cond2:
	addi $t0,$t0,4
	lb $t1,freeList($t0)
				  
	# Esta libre
	beq $t1,0,merge
				  

# Pegar bloques				  
merge:
				  
	# Actualizamos el bloque mas a la izquierda
				  
	# Movemos el apuntador a direccion final
	addi $t0,$t0,8
				  
	# Guardamos el valor de la direccion final del bloque viejo en la final de su adyacente
	sb $t2,freeList($t0)
				  
	# Movemos el apuntador al size
	addi $t0,$t0,-4
				  
	# Restauramos el valor actual de size
	lb $t1,freeList($t0)
				  
	# Sumamos el size actual al del anterior
	add $t1,$t1,$t4
				  
	# Lo salvamos en el arreglo
	sb $t1,freeList($t0)
				  
# Seteamos con 0 las casillas del bloque anterior
zero:
	# colocamos 0
	sb $zero,freeList($t5)
				  	
	# incrementamos el apuntador
	addi $t5,$t5,4
				  	
	# saltamos a la etiqueta
	blt $t5,12,zero

				  					  	
###################################		
#  IMPRIMIR MENSAJES              #
###################################				

print_msg_free:
			
	# Imprime mensaje de exito
	li $v0,4
	la $a0,free_success_msg
	syscall
				
	li $v0,4
	la $a0,newLine      # Imprimir salto de linea
	syscall 
		
	










###########################

# BLOQUE DE ERRORES

##########################


init_error:
	# Maneja el error del init
	li $v0,0       
	addi $v0, $zero, -1
	
	j perror
	
malloc_error:
	# Maneja el error del malloc
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

	li $v0,4
	la $a0,init_error_msg
	syscall
	
	j exit
	
print_malloc:

	li $v0,4
	la $a0,malloc_error_msg
	syscall
	
	j exit
	
print_free:

	li $v0,4
	la $a0,free_error_msg
	syscall
	
	j exit

exit:
	li $v0, 10
	syscall 
	
	



	
	
	
	


	

	
	
	
	
	 
	 
	
	
