# Inicializamos el tamano de la estructura
.data 
	HEAP_SIZE:    .byte   100
	init_size:    .byte   0
	freeList:     .byte   0:100
	
	ini_bloq:     .word   0  # etiqueta que denota la direccion de inicio del bloque del init
	fin_bloq:     .word   0  # etiqueta que denota la direccion del final de bloque del init
	code:         .word   0
	
	wel_msg:       .asciiz "Ingrese el tamaño de memoria que desea inicializar: "
	msize_msg:     .asciiz "Ingrese el tamaño de memoria que desea asignar:  "
	menu_msg:      .asciiz "Indique la operacion que desea realizar: "
	newLine:       .asciiz "\n"
	init_error_msg:.asciiz "Error: el tamaño ingresado supera el almacenamiento del heap"
	init_success:  .asciiz "Memoria inicializada correctamente"
	malloc_error_msg:.asciiz "Error: el tamaño ingresado no está disponible"
	malloc_success_msg:  .asciiz "Memoria asignada correctamente"	 

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
	
	li $v0,4
	la $a0,newLine      # Imprimir mensaje de bienvenida
	syscall 
	
	li $v0,4
	la $a0,msize_msg      # Imprimir mensaje de malloc
	syscall 
	
	# Leemos tamano malloc
	li $v0,5
	syscall
	move $a0, $v0  
	
	# Llamamos a malloc
	jal malloc
	
	j exit
	

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
	sw $v0,ini_bloq

	# Guardamos el tamanio en un registro
	lb $t0,init_size
	lw $t1,ini_bloq
	
	# Sumamos la cantidad de espacio para saber donde termina nuestro bloque
	add $t2,$t1,$t0
	
	# Guardamos en la etiqueta el valor de t0
	sw $t2,fin_bloq
	
		
	# syscall de imprimir init exitoso
	li $v0,4
	la $a0,init_success   # Imprimir mensaje de allocate succesfull
	syscall 
	
	
	jr $ra
	

malloc:


	lb $s0, init_size    # Cargamos el valor de init size en t0
	lw $s1, ini_bloq
	lw $s2, fin_bloq
	
	# Inicializamos t0 en 0
	# Apuntador
	li $t0, 0
	
	# En t2 llevamos el contador
	# Inicializamos t0 en 0
	li $t2, 0
	
	#inicializamos t3 en cero
	li $t3,0
	
	# En t1 guardamos el valor de cada posicion de freeList (0 o 1)
	# En t3 llevamos el apuntador al indice del arreglo donde se hara el allocate
	
	# En a1 llevamos lo que queremos allocar mas 1
	# Condicion de parada
	addi $a1, $a0, 1 
 
	
	while:
		# Si el contador de ceros es igual a la cantidad de bytes para el malloc
		beq $t2,$a1,malloc_success
		
		# Si el indice del arreglo 
		lb $s3,init_size
		beq $t0,$s3,malloc_error
		
		# Guardamos el valor de cada posicion del arreglo
		lb $t1,freeList($t0)
		
		# Branch a una funcion que acumula los ceros
		beq $t1, 0, counter_0
		
		# Branch a una funcion que reinicia el contador de ceros si aparece un 1
		beq $t1, 1, counter_1
		
		
		# Contador de ceros
		counter_0:
		  addi $t2,$t2,1 
		  
		  addi $t4,$t0,-1
		  
		  beq $t4,1,freeList_pointer
		  
		  freeList_pointer:
		  
		  	# Guardamos la posicion del indice de posible inicio para allocate
		  	move $t0,$t3
		  
		  # Incrementamos el indice del arreglo
		  addi $t0,$t0,1
		  
		  j while
			
		# Reinicia contador de ceros si aparece un 1
		counter_1:
		  li $t2, 0
		  
		  # Incrementamos el indice del arreglo
		  addi $t0,$t0,1
		  
		  j while
		  
	malloc_success:
	
		# Llenamos con 1's las posiciones desocupadas
		add $t4,$t3,$a0	
		li $s3,1
		loop_1:
			# Guardar en stack $t3
			
				
			beq  $t3,$t4,print_message
   
          		# Modifico el valor de memoria  e incremento el indice 
          		sb $s3,freeList($t3)
          		addi $t3, $t3, 1
             
          		j loop_1
			
		print_message:
		
			# Imprime mensaje de exito
			li $v0,4
			la $a0,malloc_success_msg
			syscall
		 
		 li $t0,0
		 print_array:
		 
		 	beq  $t0, $s0, exit
   
          		# Recupero el valor de memoria  e incremento el indice 
          		lb $t6, freeList($t0)
          		addi $t0, $t0, 1
             
          		#Imprim el valor actual
          		li  $v0, 1
          		move $a0, $t6
          		syscall
          
          		#Print a new line
          		li $v0, 4
          		la $a0, newLine
          		syscall
          
          		j print_array
		 	
			jr $ra 












###########################

# BLOQUE DE ERRORES

##########################


init_error:
	# Maneja el error del init
	li $v0,0       
	addi $v0, $zero, -1
	
# Guardamos en el stack
	
	j perror
	
malloc_error:
	# Maneja el error del init
	li $v0,0       
	addi $v0, $zero, -2
	
	j perror
	
	
perror: 
	
	# Si code = -1 , error de init
	beq  $v0,-1,print_init  
	
	# Si code = -2 , error de malloc
	beq $v0,-2,print_malloc

		
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
	
exit:
	li $v0, 10
	syscall 
	
	



	
	
	
	


	

	
	
	
	
	 
	 
	
	
