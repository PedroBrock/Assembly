; Pedro Luccas de Brito Brock
; Matricula: 20200007985

.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data 
    outputEntrada db "Digite o nome do arquivo de entrada", 0ah, 0h ; Frase a ser escrita no console
    outputSaida db "Digite o nome do arquivo de saida", 0ah, 0h     ; Frase a ser escrita no console
    outputChave db "Digite a chave (de 1 a 20):", 0ah, 0h           ; Frase a ser escrita no console
    outputMenu db "MENU", 0ah, 0h                                   ; Frase a ser escrita no console
    outputCriptografar db "1.Criptografar", 0ah, 0h                 ; Frase a ser escrita no console
    outputDescriptografar db "2.Descriptografar", 0ah, 0h           ; Frase a ser escrita no console
    outputSair db "3.Sair", 0ah, 0h                                 ; Frase a ser escrita no console
    outputOpcao db "Escolha um numero (de 1 a 3)", 0ah, 0h          ; Frase a ser escrita no console
    
    outputHandle dd 0  ; Variavel para armazenar o handle de saida
    inputHandle dd 0   ; Variavel para armazenar o handle de entrada
    console_count dd 0 ; Variavel para armazenar caracteres lidos/escritos na console

    opcao dd 0               ; Variavel para armazenar a opcao escolhida
    nomeEntrada db 50 dup(0) ; Variavel para armazenar o nome do arquivo de entrada
    nomeSaida db 50 dup(0)   ; Variavel para armazenar o nome do arquivo de saida
    chave dd 0               ; Variavel para armazenar o valor da chave
    buffer db 512 dup(0)     ; Buffer para ler e escrever no arquivo
    bytesLidos dd 0          ; Variavel para armazenar os bytes lidos do buffer
    bytesEscritos dd 0       ; Variavel para armazenar os bytes escritos do buffer

    inFileHandle dd ?  ; Handle para o arquivo de entrada
    outFileHandle dd ? ; Handle para o arquivo de saida
  
.code
start:
    ; Handle para entrada e saida do console
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; Mostrar o menu no console
menu:
    invoke WriteConsole, outputHandle, addr outputMenu, sizeof outputMenu, addr console_count, NULL
    invoke WriteConsole, outputHandle, addr outputCriptografar, sizeof outputCriptografar, addr console_count, NULL
    invoke WriteConsole, outputHandle, addr outputDescriptografar, sizeof outputDescriptografar, addr console_count, NULL
    invoke WriteConsole, outputHandle, addr outputSair, sizeof outputSair, addr console_count, NULL
    invoke WriteConsole, outputHandle, addr outputOpcao, sizeof outputOpcao, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr opcao, sizeof opcao, addr console_count, NULL

    ;converter string lida do console em um numero que vai ser a opcao
    mov esi, offset opcao ; Armazenar apontador da string em esi
prox:
    mov al, [esi] ; Mover caractere atual para al
    inc esi       ; Apontar para o proximo caractere
    cmp al, 13    ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne prox
    dec esi       ; Apontar para caractere anterior, onde o CR foi encontrado
    xor al, al    ; ASCII 0, terminado de string
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
    invoke atodw, addr opcao
    mov opcao, eax

    ; Se a opcao for igual 3, finaliza o programa
    cmp opcao,3
    je final_programa

    ; Printa na tela e recebe o nome do arquivo de entrada
    invoke WriteConsole, outputHandle, addr outputEntrada, sizeof outputEntrada, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr nomeEntrada, sizeof nomeEntrada, addr console_count, NULL
    mov esi, offset nomeEntrada ; Armazenar apontador da string em esi
proximo:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

    ; Printa na tela e recebe o nome do arquivo de saida
    invoke WriteConsole, outputHandle, addr outputSaida, sizeof outputSaida, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr nomeSaida, sizeof nomeSaida, addr console_count, NULL
    mov esi, offset nomeSaida ; Armazenar apontador da string em esi
proximo1:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo1
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
    
    ; Printa na tela e recebe o valor da chave
    invoke WriteConsole, outputHandle, addr outputChave, sizeof outputChave, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr chave, sizeof chave, addr console_count, NULL
    
    ; Converter string lida do console em int 
    mov esi, offset chave ; Armazenar apontador da string em esi
proximo2:
    mov al, [esi] ; Mover caractere atual para al
    inc esi       ; Apontar para o proximo caractere
    cmp al, 13    ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo2
    dec esi       ; Apontar para caractere anterior, onde o CR foi encontrado
    xor al, al    ; ASCII 0, terminado de string
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
    invoke atodw, addr chave
    mov chave, eax
    
    ; Criacao dos arquivos de entrada e saida
    invoke CreateFile, addr nomeEntrada, GENERIC_READ, 0, NULL, 
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inFileHandle, eax
    invoke CreateFile, addr nomeSaida, GENERIC_WRITE, 0, NULL, 
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov outFileHandle, eax

    cmp opcao,1
    je criptografar
    cmp opcao,2
    je descriptografar
    
    ; Criptografar o arquivo de entrada e escrever no buffer
    
criptografar:
    
    invoke ReadFile, inFileHandle, addr buffer, 512, addr bytesLidos, NULL ; Le 512 bytes do arquivo
    cmp dword ptr[bytesLidos], 0
    jle fechar_arquivos ; Se nao houver mais bytes para ser lidos fechar os arquivos

    ; Chama a funcao que criptografa o buffer

    push offset buffer
    push bytesLidos
    push chave
    call criptografarProc
    
    ; Apos criptografar escreve no arquivo de saida
    invoke WriteFile, outFileHandle, addr buffer, bytesLidos, addr bytesEscritos, NULL ; Escreve os byte lidos no arquivo
    jmp criptografar; Repetir o criptografar ate nao terem mais bytes para serem lidos

    ; Descriptografar o arquivo de entrada e escrever no buffer

descriptografar:
    invoke ReadFile, inFileHandle, addr buffer, 512, addr bytesLidos, NULL ; Le 512 bytes do arquivo
    cmp dword ptr[bytesLidos], 0
    jle fechar_arquivos ; Se nao houver bytes para ser lidos fechar os arquivos

    ; Chama a funcao que descriptografa o buffer
    push offset buffer
    push bytesLidos
    push chave
    call descriptografarProc
    
    ; Apos descriptografar escreve no arquivo de saida
    invoke WriteFile, outFileHandle, addr buffer, bytesLidos, addr bytesEscritos, NULL ; Escreve os byte lidos no arquivo
    jmp descriptografar; Repetir o criptografar ate nao terem mais bytes para serem lidos

fechar_arquivos:
    ; Fecha os arquivos e volta para o menu
    invoke CloseHandle, inFileHandle
    invoke CloseHandle, outFileHandle
    jmp menu
    
final_programa:
    invoke ExitProcess, 0

    ; Funcao que criptografa o buffer
criptografarProc:
    push ebp          ; Subrotina da funcao
    mov ebp, esp      ; Subrotina da funcao
    xor ecx, ecx      ; INDICE do caractere atual
    mov edx, [ebp+16] ; Armazena o endereço do buffer em edx
    mov eax, [ebp+8]  ; Armazena a chave em eax
    
criptoBuffer: 
    mov bl, [edx+ecx]          ; Armazena o caractere do buffer em bl
    add bl, al                 ; Desloca de acordo com a chave
    mov [edx+ecx], bl          ; Armazena o caractere ja deslocado no buffer
    inc ecx                    ; incrementa para fazer em todos os caracteres do buffer
    cmp ecx, dword ptr[ebp+12] ; Verificar se chegou ao fim do buffer
    jl criptoBuffer            ; Repetir o loop se ainda houver caracteres no buffer

    mov esp, ebp ; Subrotina da funcao
    pop ebp      ; Subrotina da funcao
    ret 12       ; Subrotina da funcao

    ; Funcao que descriptografa o buffer
descriptografarProc:
    push ebp          ; Subrotina da funcao
    mov ebp, esp      ; Subrotina da funcao
    xor ecx, ecx      ; INDICE do caractere atual
    mov edx, [ebp+16] ; Armazena o endereço do buffer em edx
    mov eax, [ebp+8]  ; Armazena a chave em eax
    
descriptoBuffer: 
    mov bl, [edx+ecx]          ; Armazena o caractere do buffer em bl
    sub bl, al                 ; Desloca de acordo com a chave
    mov [edx+ecx], bl          ; Armazena o caractere ja deslocado no buffer
    inc ecx                    ; incrementa para fazer em todos os caracteres do buffer
    cmp ecx, dword ptr[ebp+12] ; Verificar se chegou ao fim do buffer
    jl descriptoBuffer         ; Repetir o loop se ainda houver caracteres no buffer

    mov esp, ebp ; Subrotina da funcao
    pop ebp      ; Subrotina da funcao
    ret 12       ; Subrotina da funcao

end start
 