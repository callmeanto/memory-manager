# Inicializamos el tamano de la estructura

.data 
	HEAP_SIZE:    .word   35
	size:         .word   0
	code:         .word   0
	
	wel_msg:      .asciiz "Ingrese el tamaño de memoria que desea inicializar: "
	newLine:      .asciiz "\n"
	init_msg:     .asciiz "Error: el tamaño ingresado supera el almacenamiento del heap"
	 

.text 

main: 
	li $v0,4
	la $a0,wel_msg   # Imprimir mensaje de bienvenida
	syscall 

	li $v0,5
	sw $v0, size   	# Leemos size
	syscall 
	
	jal init
	

init:
	lw $t1,size       # Almacenamos size en un registro temporal
	lw $t2,HEAP_SIZE  # Almacenamos HEAP_SIZE en un registro temporal
	
	sgt $t0,$t1,$t2   # Coloca 1 en t0 si size > HEAP_SIZE sino 0
	beq $t0,1,init_error  # Va a la etiqueta init_error si t0 = 1
	
	li  $v0, 9    
	lw $a0,size   # Creamos el espacio de tamano size (allocate)
	syscall


init_error:
	# Maneja el error del init
	lw $t0,code       
	addi $t0, $zero, -1
	
	sw $t0,code
	
	j perror
	
perror: 
	# Cargamos en t0 el valor de code
	lw $t0,code
	
	# Si code = -1 , error de init
	beq  $t0,-1,print1  # branch to print1
	
print1:
	li $v0,4
	la $a0,init_msg
	syscall
	
	j exit
	
exit:
	li $v0, 10
	
	



	
	
	
	


	

	
	
	
	
	 
	 
	
	