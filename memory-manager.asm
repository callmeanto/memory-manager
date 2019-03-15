# Inicializamos el tamano de la estructura
.data 
	HEAP_SIZE:    .word   100
	init_size:    .word   0
	size:         .word   0
	code:         .word   0
	freeList:     .word   0:100
	ini_bloq:     .word   0  # etiqueta que denota la direccion de inicio del bloque del init
	fin_bloq:     .word   0  # etiqueta que denota la direccion del final de bloque del init
	
	
	wel_msg:       .asciiz "Ingrese el tamaño de memoria que desea inicializar: "
	menu_msg:      .asciiz "Indique la operacion que desea realizar: "
	newLine:       .asciiz "\n"
	init_error_msg:.asciiz "Error: el tamaño ingresado supera el almacenamiento del heap"
	init_suc_msg:  .asciiz "Memoria inicializada correctamente"
	 

.text 

main: 
	li $v0,4
	la $a0,wel_msg      # Imprimir mensaje de bienvenida
	syscall 

	li $v0,5
	sw $v0, init_size   	# Leemos size
	syscall
	 
	
	# LLamamos a init
	jal init
	
	jal malloc
	
	j exit
	

init:
	lw $s0,init_size      # Almacenamos size en un registro temporal
	lw $s1,HEAP_SIZE      # Almacenamos HEAP_SIZE en un registro temporal
	
	
	# Verificamos que el init pueda hacerse
	sgt $v0,$s0,$s1
	bgt $s0,$s1,init_error # Va a la etiqueta init_error si $s0 > $s1
	
	
	# syscall allocate
	li  $v0, 9    
	lw $a0,init_size      # Creamos el espacio de tamano size (allocate)
	syscall
	
	
	# syscall de imprimir init exitoso
	li $v0,4
	la $a0,init_suc_msg   # Imprimir mensaje de allocate succesfull
	syscall 
	
	
	jr $ra
	

malloc:
	lw $t0,init_size    # Cargamos el valor de init size en t1 
	lw $t1,size
	
	
	
	 
	jr $ra 












###########################

# BLOQUE DE ERRORES

##########################


init_error:
	# Maneja el error del init
	lw $t0,code       
	addi $t0, $zero, -1
	
	sw $t0,code
	
	j perror
	
perror: 
	# Cargamos en t0 el valor de code
	# lw $t0,code
	
	# Si code = -1 , error de init
	beq  $t0,-1,print1  # branch to print1
	
print1:
	li $v0,4
	la $a0,init_error_msg
	syscall
	
	j exit
	
exit:
	li $v0, 10
	syscall 
	
	



	
	
	
	


	

	
	
	
	
	 
	 
	
	
