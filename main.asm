%include    './macros.asm'

section .data
    ; --Constantes ligadas al Kernel--
        sys_exit        EQU 	1
        sys_read        EQU 	3
        sys_write       EQU 	4
        sys_open        EQU     5
        sys_close       EQU     6
        sys_execve      EQU     11
        stdin           EQU 	0
        stdout          EQU 	1
    ;--Variables de Impresion en Pantalla--f


    ; ruta para el almacenamiento de las palabras
    palabrasAltoArchivo db "./palabras/palabrasAlto.txt", 0
    palabrasMedioArchivo db "./palabras/palabrasMedio.txt", 0
    palabrasBajoArchivo db "./palabras/palabrasBajo.txt", 0

    totalPalabras db 10

    ; mensajes durante el juego
    iniciarJuego db "1. Iniciar Juego", 10, "2. Salir", 10, 0
    iniciarJuegoLen equ $-iniciarJuego

    dificultad db "Seleccione la Dificultad: ", 10, "1. Bajo", 10, "2. Medio", 10, "3. Alto", 10, "4. Ir a Menú Anterior", 10, 0
    dificultadLen equ $-dificultad

section .bss
    entrada resb 4
    contenidoArchivo  	resb 512		    ; Reserva espacio para 255 bytes

    numero resb 1                           ; almacenar opcion de seleccion
    nivelDificultad resb 1                  ; dificultad seleccionada
    turnosDesponibles resb 1                ; cantidad de turnos por juego
    palabra resb 255                        ; palabra seleccionada para cada juego
    indicePalabra resb 1
    palabraGuion resb 256
    palabraLen resb 1

section .text
    global _start

_start:
    ; Generar guiones bajos segun la longitud
    ;movzx ecx, byte [palabraLen]          ; Cargar la longitud en ecx correctamente
    ;lea edi, [palabraGuion]
    ;generarGuion ecx, edi

    imprimeEnPantalla palabraGuion, palabraLen

    imprimeEnPantalla iniciarJuego, iniciarJuegoLen
    leeTeclado
    capturaNumero numero

    ; seguir o salir del programa
    cmp byte [numero], 1
    je Juego
    jne SALIR

Juego:
    ; num [0,9]
    random indicePalabra ; obtener indice para usar una palabra determinada de los archivos

    imprimeEnPantalla dificultad, dificultadLen

    ; obtener opcion de dificultad
    leeTeclado
    capturaNumero nivelDificultad

    cmp byte [nivelDificultad], 4               ; si nivelDificultad = 4 devolver a menu inicial
    je _start

    cmp byte [nivelDificultad], 2               ; asignacion turnos maximos
    jl DificultadBajo
    je DificultadMedio
    jg DificultadAlto

; asignacion de los turnos disponibles inicialmente
DificultadBajo:
    mov byte [turnosDesponibles], 9

    abreArchivo palabrasBajoArchivo
    leeArchivo contenidoArchivo

    call seleccionaPalabraAleatoria ; obtenemos la palabra aleatoria
    imprimeEnPantalla palabra, 255

    longitudPalabra palabra, palabraLen

    cierraArchivo palabrasBajoArchivo
    jmp SALIR

DificultadMedio:
    mov byte [turnosDesponibles], 9

    abreArchivo palabrasMedioArchivo
    leeArchivo contenidoArchivo
    call seleccionaPalabraAleatoria ; obtenemos la palabra aleatoria
    imprimeEnPantalla palabra, 255
    cierraArchivo palabrasMedioArchivo

    jmp SALIR

DificultadAlto:
    mov byte [turnosDesponibles], 9

    abreArchivo palabrasAltoArchivo
    leeArchivo contenidoArchivo
    despliegaContenidoArchivo contenidoArchivo

    call seleccionaPalabraAleatoria ; obtenemos la palabra aleatoria
    ;imprimeEnPantalla palabra, 255
    cierraArchivo palabrasAltoArchivo

    jmp SALIR

SALIR:
    salir

seleccionaPalabraAleatoria:
    xor ecx, ecx
    xor edi, edi
    mov esi, contenidoArchivo
    mov eax, [indicePalabra]

LEER:
    cmp byte [esi], 0
    je FIN

    cmp byte [esi], 10
    je CONTAR

    cmp ecx, eax
    jne SIGUIENTE_PALABRA

CopiarPalabra:
    mov al, [esi]
    cmp al, 10
    je FIN

    mov [palabra + edi], al
    inc edi
    inc esi
    jmp CopiarPalabra

SIGUIENTE_PALABRA:
    inc esi
    jmp LEER

CONTAR:
    inc ecx
    inc esi
    cmp ecx, [totalPalabras]
    ja FIN
    jmp LEER

FIN:
    mov byte [palabra + edi], 0
    ret
