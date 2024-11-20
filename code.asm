; *********************************************************************************
; * Projeto de IAC - CHUVA DE METEOROS                                            *
;                                                                                 *
; * Grupo 29                                                                      *
; * Autores/Numero: Diogo Rodrigues - 102848                                      *
;                   Pedro Ribeiro   - 102663                                      *
;                   Simão Sanguinho - 102082                                      *
;                                                                                 *
; * Descrição:                                                                    *
;       Este programa simula um jogo, em que um robot defende o seu planeta.      *
;       Destruindo meteoros e absorvendo energia. O jogo acaba quando a energia   *
;   do robot chega ao fim ou um dos meteoros destrói o robot                      *
;                                                                                 *
; * Data: 18.06.2022                                                              *
; *********************************************************************************


; *********************************************************************************
; *                                                                               *
; *                                * CONSTANTES *                                 *
; *                                                                               *
; *********************************************************************************

MASCARA                 EQU 0FH      ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
ITERADOR                EQU 10H      ; iterador de teclado - linhas e colunas
ATRASO	                EQU 0A00H	 ; atraso para limitar a velocidade de movimento do boneco
HA_EXPLOSAO             EQU 1        ; indica que há explosao
JOGO_PERDIDO            EQU 1        ; indica que o utilizador perdeu o jogo
MIN_COLUNA		        EQU 0        ; coluna mais à esquerda
MAX_COLUNA		        EQU 64       ; coluna mais à direita
MAX_LINHA		        EQU 32       ; linha mais a baixo
ULTIMA_LINHA_TECLADO    EQU 8        ; linha inferior do teclado

; Estado do jogo - Valores não interessam
RESET                   EQU 4        ; indica que o jogo esta parado
JOGO_ATIVO              EQU 5        ; indica que o jogo está a correr
JOGO_PAUSADO            EQU 6        ; indica que o jogo esta no modo pausa
JOGO_PARADO             EQU 7        ; indica que o jogo está parado/acabado

; TECLAS
TECLA_MOVE_ESQ          EQU 00H      ; tecla para andar para a esquerda
TECLA_MOVE_DIR          EQU 02H      ; tecla para andar para a direita
TECLA_DISPARO           EQU 01H      ; tecla para disparar missil
TECLA_COMECA_JOGO       EQU 0CH      ; tecla para começar o jogo
TECLA_PAUSA_JOGO        EQU 0DH      ; tecla para pausar/recomeçar o jogo
TECLA_TERMINA_JOGO      EQU 0EH      ; tecla para terminar o jogo
TECLA_CREDITOS          EQU 0FH      ; tecla para mostrar/ocultar os creditos
TECLA_PONTUACAO         EQU 0AH       ; tecla para mostrar a pontuacao

; ROBOT
LINHA_ROBOT        		EQU 28       ; linha inicial do robot
COLUNA_ROBOT			EQU 29       ; posicao final do meteoro
LARGURA_ROBOT		    EQU	7        ; largura do robot
ALTURA_ROBOT            EQU 4        ; altura do robot

; METEORO
LINHA_METEORO			EQU	0        ; linha inicial do meteoro
COLUNA_METEORO_1	    EQU 30       ; coluna do meteoro 1
COLUNA_METEORO_2        EQU 5        ; coluna do meteoro 2
COLUNA_METEORO_3        EQU 20       ; coluna do meteoro 3
COLUNA_METEORO_4        EQU 49       ; coluna do meteoro 4
DIM_METEORO				EQU 5	     ; tamanho meteoro
METEORO_APROXIMA        EQU 50       ; o meteoro aproxima, e fica maior
NUM_METEOROS            EQU 8        ; 8 porque é usado numa word (4*2), mas sao apenas 4 meteoros
METEORO_BOM             EQU 1        ; tipo do meteoro bom
METEORO_MAU             EQU 0        ; tipo do meteoro mau

; MISSIL
LINHA_INICIAL_MISSIL    EQU 27       ; linha onde o missíl é disparado
LINHA_FINAL_MISSIL      EQU 15       ; linha ate onde o missil pode ir
DIM_MISSIL              EQU 1        ; dimensao do missil
NAO_EXISTE_MISSIL       EQU -1       ; Quando não existe missil, este fica guardado na linha -1
COLUNA_CENTRAL_ROBOT    EQU 3        ; para o missil sair do meio do robot

; ENERGIA
LIMITE_ENERGIA_INF      EQU 0        ; limite de energia inferior do robot
LIMITE_ENERGIA_SUP      EQU 100      ; limite de energia superior do robot
ENERGIA_DISPARO         EQU 5        ; energia gasta no disparo do missil
ENERGIA_CORACAO         EQU 10       ; energia ganha quando o robot colide com meteoro bom
ENERGIA_EXPLOSAO_MAU    EQU 5        ; energia ganha quando o robot destroi um meteoro mau  


; Enderecos perifericos
DISPLAYS    EQU 0A000H   ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN     EQU 0C000H   ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL     EQU 0E000H   ; endereço das colunas do teclado (periférico PIN)

; Comandos do MEDIA CENTER
COMANDO_LINHA    		    EQU 600AH       ; definir a linha do pixel
COMANDO_COLUNA   		    EQU 600CH       ; definir a coluna do pixel
COMANDO_ALTERA_PIXEL        EQU 6012H       ; escrever no pixel selecionado
APAGA_AVISO     		    EQU 6040H       ; apagar o aviso de nenhum cenário selecionado
APAGA_ECRAS	 		        EQU 6002H       ; apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU 6042H       ; selecionar uma imagem de fundo
SELECIONA_CENARIO_FRONTAL   EQU 6046H       ; selecionar cenario frontal
APAGA_CENARIO_FRONTAL       EQU 6044H       ; apagar cenario frontal
APAGA_TODOS_PIXEIS          EQU 6002H       ; apagar todos os pixeis
COMANDO_SELECIONA_SOM       EQU 6048H       ; seleciona um som para comandos seguintes
COMANDO_PRODUZ_SOM          EQU 605AH       ; inicia a reproducao de um som
COMANDO_PRODUZ_VIDEO        EQU 605AH       ; inicia a reproducao de um video
COMANDO_TERMINA_VIDEOS      EQU 6068H       ; termina todos os video que estao a ser reproduzidos

; Enderecos de Cores ARGB
AMARELO					    EQU 0FFD0H      ; amarelo
LARANJA					    EQU 0FF80H		; laranja
VERMELHO_VIVO		        EQU	0FF00H		; vermelho vivo
VERMELHO_ESCURO             EQU 0FC00H      ; vermelho escuro
VERMELHO_CLARO              EQU 08F00H      ; vermelho claro
CASTANHO				    EQU 0F410H	    ; castanho
BRANCO                      EQU 0FFFFH      ; branco
PRETO                       EQU 0F000H      ; preto
CINZENTO                    EQU 09005H      ; cinzento
CINZENTO_ESCURO             EQU 0A000H      ; cinzento escuro
VERDE                       EQU 0F460H      ; verde
AZUL                        EQU 0F09FH      ; azul
LARANJA_ESCURO              EQU 0FD70H      ; laranja escuro
LARANJA_CLARO               EQU 0BE90H      ; laranja claro

; Sons e videos
SOM_DISPARO                 EQU 0           ; som do disparo
SOM_MORTE                   EQU 1           ; som da morte do robo por colisao com meteoro mau
SOM_EXPLOSAO                EQU 2           ; som da explosão do meteoro mau
SOM_CORACAO_PARTIDO         EQU 3           ; som da explosao do meteoro bom
SOM_GANHA_ENERGIA           EQU 4           ; som do robo a absorver energia
SOM_SEM_ENERGIA             EQU 5           ; som da morte do robo por ficar sem energia
SOM_FIM                     EQU 6           ; som de quando o player acaba o jogo
VIDEO_INICIO                EQU 7           ; animacao do ecra inicial
VIDEO_FIM_EXPLOSAO          EQU 8           ; ecra final quando o robot e atingido por um meteoro
VIDEO_FIM_ENERGIA           EQU 9           ; ecra final quando o robot perde a energia
VIDEO_FIM                   EQU 10          ; ecra final quando o utilizador acaba o jogo
VIDEO_CREDITOS              EQU 11          ; ecra final quando os creditos sao exibidos

; Imagens 
IMAGEM_INICIO               EQU 0           ; imagem do ecra inicial
IMAGEM_JOGO                 EQU 1           ; imagem de fundo do jogo
IMAGEM_PAUSA                EQU 2           ; imagem do modo pausa do jogo
IMAGEM_FIM_EXPLOSAO         EQU 3           ; imagem do fim quando o robot explode
IMAGEM_FIM_ENERGIA          EQU 4           ; imagem do fim quando o robot perde energia
IMAGEM_FIM                  EQU 5           ; imagem do fim quando o utilizador acaba o jogo
IMAGEM_CREDITOS             EQU 6           ; imagem do fim dos creditos


; *********************************************************************************
; *                                                                               *
; *                                  * DADOS *                                    *
; *                                                                               *
; *********************************************************************************

; *********************************************************************************
; * Tabelas de desenho
; *********************************************************************************

	PLACE       1000H

; Tabela que define o robot
DEF_ROBOT:

    WORD        0, 0, 0, PRETO, 0, 0, 0
	WORD		0, PRETO, CINZENTO_ESCURO, VERMELHO_VIVO, PRETO, PRETO, 0		
    WORD        PRETO, 0, PRETO, CINZENTO_ESCURO, CINZENTO_ESCURO, 0, PRETO
    WORD        0, 0, PRETO, 0, PRETO, 0, 0

; Tabela que define o missil
DEF_MISSIL:                         
    WORD VERMELHO_VIVO

;************************ METEORO BOM ******************************

; Tabela que define o meteoro bom
DEF_METEORO_BOM:

    DEF_METEORO_BOM_0:                          ; meteoro bom na 1ª fase
        WORD    0, 0, CINZENTO, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_BOM_1:                          ; meteoro bom na 2ª fase
        WORD    0, CINZENTO, CINZENTO, 0, 0
        WORD    0, CINZENTO, CINZENTO, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_BOM_2:                          ; meteoro bom na 3ª fase 
        WORD    0, VERMELHO_VIVO, 0, VERMELHO_VIVO, 0
        WORD    0, VERMELHO_VIVO, VERMELHO_VIVO, VERMELHO_VIVO, 0
        WORD    0, 0 , VERMELHO_VIVO, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_BOM_3:                          ; meteoro bom na 4ª fase
        WORD    0, VERMELHO_ESCURO, 0, 0,  VERMELHO_VIVO
        WORD    0, VERMELHO_VIVO, VERMELHO_VIVO, VERMELHO_VIVO, VERMELHO_VIVO
        WORD    0, 0 , VERMELHO_ESCURO, VERMELHO_CLARO, 0
        WORD    0, 0, VERMELHO_ESCURO, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_BOM_4:                          ; meteoro bom na 5ª fase
        WORD    0, VERMELHO_VIVO, 0, VERMELHO_VIVO, 0
        WORD    VERMELHO_ESCURO, VERMELHO_CLARO, VERMELHO_VIVO, VERMELHO_CLARO, VERMELHO_VIVO
        WORD    VERMELHO_ESCURO, VERMELHO_CLARO, VERMELHO_CLARO, VERMELHO_CLARO, VERMELHO_CLARO
        WORD    0, VERMELHO_ESCURO, VERMELHO_CLARO, VERMELHO_ESCURO, 0
        WORD    0, 0, VERMELHO_ESCURO, 0, 0

DEF_METEORO_BOM_EXPL:                           ; define a explosao do meteoro bom
    WORD    0, 0, 0, VERMELHO_VIVO, 0
    WORD    VERMELHO_ESCURO, VERMELHO_CLARO, 0, VERMELHO_CLARO, VERMELHO_VIVO
    WORD    VERMELHO_ESCURO, VERMELHO_CLARO, 0, VERMELHO_CLARO, VERMELHO_CLARO
    WORD    0, VERMELHO_ESCURO, VERMELHO_CLARO, 0, 0
    WORD    0, 0, VERMELHO_ESCURO, 0, 0

;************************ METEORO MAU ******************************

; Tabela que define o meteoro mau
DEF_METEORO_MAU:

    DEF_METEORO_MAU_0:                          ; meteoro bom na 1ª fase
        WORD    0, 0, CINZENTO, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_MAU_1:                          ; meteoro bom na 2ª fase
        WORD    0, CINZENTO, CINZENTO, 0, 0
        WORD    0, CINZENTO, CINZENTO, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_MAU_2:                          ; meteoro bom na 3ª fase 
        WORD    0, CASTANHO, CASTANHO, CASTANHO, 0
        WORD    0, LARANJA_CLARO, CASTANHO, LARANJA_CLARO, 0
        WORD    0, LARANJA_CLARO, LARANJA_CLARO, LARANJA_CLARO, 0
        WORD    0, 0, 0, 0, 0
        WORD    0, 0, 0, 0, 0

    DEF_METEORO_MAU_3:                          ; meteoro bom na 4ª fase 
        WORD    0, 0, CASTANHO, CASTANHO, 0
        WORD    0, CASTANHO, CASTANHO, CASTANHO, CASTANHO
        WORD    0, LARANJA_CLARO, LARANJA_CLARO, LARANJA_CLARO, LARANJA_CLARO
        WORD    0, 0, AMARELO, AMARELO, 0
        WORD    0, 0, 0, 0, 0
        
    DEF_METEORO_MAU_4:                          ; meteoro bom na 5ª fase           
        WORD 		0,CASTANHO, CASTANHO, CASTANHO,0
        WORD		CASTANHO,CASTANHO,CASTANHO,CASTANHO,CASTANHO
        WORD		LARANJA, CASTANHO, CASTANHO, CASTANHO, LARANJA
        WORD		AMARELO, LARANJA, LARANJA, LARANJA, AMARELO
        WORD 		0,AMARELO, AMARELO, AMARELO,0

DEF_METEORO_MAU_EXPL:                            ; define a explosao do meteoro mau
    WORD        0, LARANJA_ESCURO, 0, LARANJA_ESCURO, 0
    WORD        LARANJA_CLARO, 0, LARANJA_CLARO, LARANJA_CLARO, LARANJA_ESCURO
    WORD        0, AMARELO, AMARELO, LARANJA_CLARO, 0
    WORD        LARANJA_ESCURO, LARANJA_CLARO, AMARELO, 0, LARANJA_ESCURO
    WORD        0, LARANJA_ESCURO, 0, LARANJA_CLARO, 0


; *********************************************************************************
; * Variáveis globais
; *********************************************************************************

linha_atual_meteoro:                    
    WORD LINHA_METEORO                    ; linha onde se encontra o primeiro meteoro
    WORD LINHA_METEORO                    ; linha onde se encontra o segundo meteoro
    WORD LINHA_METEORO                    ; linha onde se encontra o terceiro meteoro
    WORD LINHA_METEORO                    ; linha onde se encontra o quarto meteoro
    
coluna_atual_meteoro:
    WORD COLUNA_METEORO_1                 ; coluna onde se encontra o primeiro meteoro
    WORD COLUNA_METEORO_2                 ; coluna onde se encontra o segundo meteoro
    WORD COLUNA_METEORO_3                 ; coluna onde se encontra o terceiro meteoro
    WORD COLUNA_METEORO_4                 ; coluna onde se encontra o quarto meteoro
    
tipo_meteoro:     ; 0 e mau 1 e bom
    WORD 0                                ; indica o tipo do primeiro meteoro 
    WORD 0                                ; indica o tipo do segundo meteoro
    WORD 0                                ; indica o tipo do terceiro meteoro
    WORD 0                                ; indica o tipo do quarta meteoro

eliminar_explosao:      ; para o processo do meteoro saber se precisa de apagar a explosao ...
    WORD 0                                ; ... do primeiro meteoro
    WORD 0                                ; ... do segundo meteoro
    WORD 0                                ; ... do terceiro meteoro 
    WORD 0                                ; ... do quarto meteoro

; Posicao atual do ROBOT
linha_atual_robot:                  
    WORD LINHA_ROBOT                    ; 
coluna_atual_robot:
    WORD COLUNA_ROBOT

; Posicao atual do MISSIL
linha_atual_missil:
    WORD NAO_EXISTE_MISSIL
coluna_atual_missil:
    WORD 0

; Variaveis de controlo
estado_jogo:                            ; indica que se o jogo esta a correr ou em pausa
    WORD JOGO_PARADO             

perdeu_jogo:                            ; indica se o utilizador perdeu o jogo 
    WORD 0

missil_explodiu:                        ; indica que houve uma explosao no ciclo do missil
    WORD 0

energia:                                ; valor do display:                        
    WORD LIMITE_ENERGIA_SUP             ; inicializa a energia a 100

pontuacao:
    WORD 0                              ; pontuacao do jogador

; Tabela de interrupcoes 
tab:
    WORD interupcao_meteoro             ; interupcao do meteoro
    WORD interupcao_missil              ; interupcao do missil  
    WORD interupcao_energia             ; interrupcao da energia do robot

; Pilhas dos processos
STACK 100H
    sp_processo_principal:              ; pilha do processo principal
STACK 100H
    sp_processo_meteoro_0:                ; pilha do processo do meteoro 1
STACK 100H
    sp_processo_meteoro_2:              ; pilha do processo do meteoro 2
STACK 100H
    sp_processo_meteoro_3:              ; pilha do processo do meteoro 3
STACK 100H
    sp_processo_meteoro_4:              ; pilha do processo do meteoro 4
STACK 100H
    sp_processo_teclado:                ; pilha do processo do teclado
STACK 100H
    sp_processo_robot:                  ; pilha do processo do robot
STACK 100H
    sp_processo_missil:                 ; pilha do processo do missil
STACK 100H
    sp_processo_estado_jogo:            ; pilha do processo do estado de jogo

; Eventos_interrupcoes para
baixa_meteoro:                          ; ... baixar meteoro
    LOCK 0
move_missil:                            ; ... subir o missil
    LOCK 0
decrementa_energia:                     ; ... decrementar energia do robot
    LOCK 0

; Eventos
tecla_premida:                          ; Evento teclado
    LOCK 0                              ; sinaliza que uma foi premida
comeca_jogo:                            ; Evento para comecar o jogo
    LOCK 0                              ; evento para dar inicio ao jogo
fim_pausa:                              ; Evento pausar o jogo
    LOCK 0                              ; para indicar que a pausa terminou


; *********************************************************************************
; *                                                                               *
; *                                  * INICIO *                                   *
; *                                                                               *
; *********************************************************************************

    PLACE 0                                 

; Operacoes iniciais
inicio:
    MOV SP, sp_processo_principal           ; inicializa SP do processo principal
    MOV BTE, tab                            ; inicializa os bits de estado 
    MOV [APAGA_AVISO], R0	                ; apaga o aviso de nenhum cenário selecionado
    MOV [APAGA_ECRAS], R0	                ; apaga todos os pixels já desenhados
    MOV [APAGA_CENARIO_FRONTAL], R0         ; apaga quaisquer cenarios frontais

    MOV R8, LIMITE_ENERGIA_SUP              ; guarda o valor da energioa inicial do robot
    CALL escrever_display                   ; escreve no display a enrgia inicial do robot


    MOV R0, VIDEO_INICIO                    ; seleciona o video inicial
    MOV [COMANDO_PRODUZ_VIDEO], R0	        ; reproduz o video inicial


	MOV R0, IMAGEM_INICIO			        ; cenário de fundo inicial
    MOV [SELECIONA_CENARIO_FUNDO], R0	    ; seleciona o cenário de fundo


    EI0                   ; permite a interrupção 0 - relogio dos meteoros
    EI1                   ; permite a interrupção 1 - relogio do missil
    EI2                   ; permite a interrupção 2 - relogio da energia
    EI                    ; permite todas as interrupcoes 

    MOV R11, NUM_METEOROS                   ; guarda o numero de meteoros
    
loop_ciclo_meteoros:                        ; cria os processos para os 4 meteoros
    SUB	 R11, 2			                    ; proximo meteoro (2 porque é uma word)
	CALL meteoro							; inicializa o processo do meteoro	
	CMP  R11, 0			                    ; compara se já criou os 4 processos
    JNZ	loop_ciclo_meteoros                 ; se já tiverem todos, passa para os proximos processos

    CALL teclado                            ; inicializa o processo teclado
    CALL robot                              ; inicializa o processo robot
    CALL missil                             ; inicializa o processo missil
    CALL estado                             ; inicializa o processo estado de jogo
  
display:
    MOV R0, [comeca_jogo]                   ; bloqueia o processo até o jogo começar
    MOV R8, LIMITE_ENERGIA_SUP              ; argumento da função escrever_display (Energia_máxima)
    CALL escrever_display                   ; escreve no display a energia máxima
    
espera_int_display:

    MOV R0, [decrementa_energia]            ; bloqueio o processo à espera da interupção do missíl

    MOV R0, [estado_jogo]                   ; verifica o estado de jogo
    CMP R0, JOGO_PAUSADO                    ; se estiver pausado
    JZ bloqueia_display                     ; bloqueia o processo

    CMP R0, RESET                           ; verifica se o jogo recomecou
    JZ reset_display                        ; se sim atualiza o valor do display

    CALL sub_display                        ; decrementa o valor do display
    MOV R1, [energia]                       ; guarda a energia atual
    CMP R1, 0                               ; verifica se a energia é igual a zero
    JNZ espera_int_display                  ; se for igual a 0, sai do loop

    MOV R3, JOGO_PERDIDO                    ; guarda o valor que sinaliza que o jogo foi perdido
    MOV [perdeu_jogo], R3                   ; escreve o valor na flag que indica que o jogo foi perdido
    MOV [tecla_premida], R3                 ; desbloqueia o processo teclado, para que ele altere o estado de jogo
    JMP espera_int_display

bloqueia_display:
    MOV     R0, [fim_pausa]                 ; bloqueia o processo se o jogo estiver em pausa
    JMP espera_int_display

reset_display:  
    MOV R8, [energia]                       ; guarda o valor da energia atual
    CALL escrever_display                   ; escreve esse valor no display
    MOV R8, LIMITE_ENERGIA_SUP              ; guarda o valor da energia maxima
    MOV [energia], R8                       ; reseta o valor da energia total
    JMP display

;***************************************************************************
; PROCESSO- METEORO - R11 é o indice do meteoro
;***************************************************************************

PROCESS sp_processo_meteoro_0

meteoro:
    CALL escolhe_coluna             ; escolhe uma coluna para o meteoro em causa
    MOV R0, [comeca_jogo]           ; bloqueia o processo até ser clicado no c
    MOV R7, 0                       ; inicializa a fase da evolução do meteoro
    CALL escolhe_meteoro            ; o meteoro a ser desenhado e bom ou mau?
    CALL desenha_meteoro            ; desenha o meteoro

ciclo_meteoro:
    
    CALL colisoes_meteoro_robot     ; verifica se o meteoro colidiu com o robot
    CALL colisoes_meteoro_missil    ; verifica se o meteoro colidiu com o missil

    MOV R0, [baixa_meteoro]         ; bloqueia o processo meteoro
    MOV R0, [estado_jogo]           ; verifica o estado  de jogo
    CMP R0, JOGO_PAUSADO            ; verifica se  o jogo esta pausado
    JZ bloqueia_meteoro             ; se sim, bloqueia o meteoro

    CMP R0, RESET                   ; verifica se o jogo recomecou
    JZ reset_meteoro                           

    MOV R0, HA_EXPLOSAO             ; guarda a flag que sinaliza uma explosao
    MOV R2, eliminar_explosao       ; guarda o estado da explosao do meteoro
    MOV R1, [R2+R11]                ; seleciona a explosao do meteoro em causa
    CMP R0, R1                      ; verifica se houve explosao
    JNZ continua_ciclo_meteoro      ; se nao houve, continua o ciclo do meteoro
    
    CALL apaga_explosao             ; apaga a explosao do meteoro
    MOV R2, linha_atual_meteoro     ; guarda o endereco da tabela que contem as linhas dos meteoros
    MOV R0, LINHA_METEORO           ; guarda a linha inicial do meteoro
    MOV [R2+R11], R0                ; escreve a nova linha do meteoro
    CALL escolhe_coluna             ; escolhe uma nova para o meteoro

continua_ciclo_meteoro:
    MOV R2, linha_atual_meteoro     ; guarda o endereco da tabela com as linhas atuais dos meteoros
    MOV R1, [R2+R11]                ; guarda a linha atual do meteoro em causa

    CALL evolui_meteoro             ; verifica se o meteoro tem de evoluir de fase e se sim evolui
    CALL testa_baixo                ; verifica se o limite inferior do ecra foi alcancado
    JMP ciclo_meteoro                           
    

bloqueia_meteoro:
    MOV   R0, [fim_pausa]           ; bloqueia o processo se o jogo estiver em pausa
    JMP ciclo_meteoro                           

reset_meteoro:                      ; antes de recomecar o jogo tenho de repor a posicao do meteoro
    CALL apaga_meteoro              ; apaga o desenho do meteoro
    MOV R0, LINHA_METEORO           ; guarda a linha inicial do meteoro
    MOV R2, linha_atual_meteoro     ; guarda o enderco da tabela que tem as linhas atuais dos meteoros
    MOV [R2+R11], R0                ; reinicializa a linha atual do meteoro em causa
    JMP meteoro                     ; volta ao inicio

;***************************************************************************
; PROCESSO- ROBOT
;***************************************************************************

PROCESS sp_processo_robot

robot:
    MOV R0, [comeca_jogo]          ; bloqueia o processo até o jogo começar
    CALL desenha_robot             ; desenha o robot

ciclo_robot:

    MOV R1, [tecla_premida]        ; processo bloqueado - guarda o valor da tecla premida ??????????

    MOV R0, [estado_jogo]          ; le o estado de jogo
    CMP R0, JOGO_PAUSADO           ; se estiver pausado
    JZ bloqueia_robot              ; bloqueia

    CMP R0, RESET                  ; verifica se o jogo recomeçou
    JZ reset_robot

    ;comparar com reinicia se for mandar para o ciclo reset_robot
    
    MOV R2, TECLA_MOVE_ESQ         ; guarda a tecla que move o robot para a esquerda
    MOV R3, TECLA_MOVE_DIR         ; guarda a tecla que move o robot para a direita
    CMP R1, R2                     ; anda para a esquerda?
    JZ anda_esquerda
    CMP R1, R3                     ; anda para a direita?
    JZ anda_direita                             
    JMP ciclo_robot

anda_esquerda:                     ; verifica se o limite esquerdo do ecra foi alcancado
    CALL testa_esquerda            ; se não for anda para a esquerda
    ;compasso de espera
    MOV R0, ATRASO                  ; guarda o numero de ciclos do atraso
    YIELD
ciclo_atraso_esquerda:
	SUB R0, 1                       ; menos um ciclo
	JNZ ciclo_atraso_esquerda       ; há mais ciclos?
    JMP ciclo_robot                

anda_direita:                      ; verifica se o limite direito do ecra foi alcancado
    CALL testa_direita             ; se não for anda para a direita
    ;compasso de espera
    MOV R0, ATRASO                  ; guarda o numero de ciclos do atraso
    YIELD
ciclo_atraso_direita:
	SUB R0, 1                       ; menos um ciclo
	JNZ ciclo_atraso_direita        ; há mais ciclos?
    JMP ciclo_robot                 


bloqueia_robot:
    MOV     R0, [fim_pausa]        ; bloqueia o processo se o jogo estiver em pausa 
    JMP ciclo_robot

reset_robot:                       
    MOV R0, LINHA_ROBOT            ; linha inicial do robot
    MOV [linha_atual_robot], R0    ; reinicializa a linha atual do robot para a inicial
    MOV R0, COLUNA_ROBOT           ; coluna inicial do robot
    MOV [coluna_atual_robot], R0   ; reinicializa a coluna atual do robot para a inicial
    JMP robot

;***************************************************************************
; PROCESSO MISSIL
;***************************************************************************

PROCESS sp_processo_missil

missil:
    MOV R1, [tecla_premida]          ; le o valor da tecla premida, e bloqueia o processo

    MOV R6, [estado_jogo]            ; le o estado de jogo
    CMP R6, JOGO_PAUSADO             ; se estiver pausado
    JZ bloqueia_missil_inicio        ; bloqueia o processo

    CMP R6, RESET                    ; verifica se o jogo recomecou
    JZ para_de_disparar              ; se sim apaga o missil

    CMP R6, JOGO_PARADO              ; verifica se o jogo está em pausa
    JZ missil                            

    MOV R2, TECLA_DISPARO            ; compara se a tecla premida
    CMP R1, R2                       ; é igual a tecla 1 (Disparar míssil)
    JNZ missil                       ; se não for não dispara

    MOV R7, [energia]                ; verifica se o robo tem energia suficiente
    CMP R7, ENERGIA_DISPARO          ; para disparar um missíl
    JLT missil                       ; se não tiver não dispara

dispara_primeira_vez:                ; o missil só é disparado se passar todas as condicoes
    
    MOV R0, LINHA_INICIAL_MISSIL     ; guarda a linha inicial do missil 
    MOV [linha_atual_missil], R0     ; reinicializa a linha atual do missil
    
    MOV R1, [coluna_atual_robot]     ; guarda a coluna correspondente a parte esqueda do robot
    ADD R1, COLUNA_CENTRAL_ROBOT            ; a coluna do missil corresponde a coluna do robo + a metade da largura do robo
    MOV [coluna_atual_missil], R1    ; guarda a coluna inicial do missil
    
    MOV R2, SOM_DISPARO              ; som de disparo selecionado (argumento da função produz-som)
    CALL produz_som                  ; produz o som do disparo
    CALL sub_display                 ; decrementa o display em 5% após o disparo
    CALL desenha_missil              ; desenha o missil
    
    MOV R5, [missil_explodiu]        ; verifica se o missil explodiu (ativado no processo do meteoro)
    CMP R5, 1                        ; se sim, para de disparar o missil
    JZ para_de_disparar

continua_a_disparar:
    MOV R3, [move_missil]            ; faz uma iteraçao a cada ciclo do relógio que controla o missil

    MOV R4, [estado_jogo]            ; le o estado do jogo
    CMP R4, JOGO_PAUSADO             ; se estiver pausado
    JZ bloqueia_missil_meio          ; bloqueia o processo

    CMP R4, RESET                    ; verifica se o jogo recomecou
    JZ para_de_disparar              ; se sim apaga o missil

    CALL apaga_missil

    SUB R0, 1                        ; decrementa pois a linha mais acima é 0
    MOV [linha_atual_missil], R0     ; passa para a linha seguinte do missil

    CALL desenha_missil
    
    MOV R5, [missil_explodiu]        ; verifica se o missil explodiu 
    CMP R5, 1                        ; se sim, deixa de disparar
    JZ para_de_disparar 
    
    MOV R3, LINHA_FINAL_MISSIL       ; verifica se o missil já
    CMP R0, R3                       ; chegou ao seu limite  
    JNZ continua_a_disparar          ; se sim para de disparar

para_de_disparar:
    MOV R8, 0                        ; reinicializa a variavel de controlo a indicar que houve explosão 
    MOV [missil_explodiu], R8        ; missil_explodiu passa a 0, ou seja, indica que o missil já foi destruido
    CALL apaga_missil                ; apaga o missil que colidiu
    MOV R0, NAO_EXISTE_MISSIL        ; remove o missil da posicao atual, para uma que não existe
    MOV [linha_atual_missil], R0     ; simula que o missil foi 
    JMP missil


bloqueia_missil_inicio:
    MOV     R6, [fim_pausa]         ; bloqueia o processo se o jogo estiver na pausa
    JMP missil

bloqueia_missil_meio:
    MOV     R6, [fim_pausa]         ; bloqueia o processo se o jogo estiver na pausa
    JMP continua_a_disparar

;***************************************************************************
; PROCESSO ESTADO DE JOGO
;***************************************************************************
PROCESS sp_processo_estado_jogo

estado:
    MOV R0, 0
    MOV [pontuacao], R0
    MOV R0, [tecla_premida]                     ; guarda a tecla do teclado

    MOV R1, TECLA_COMECA_JOGO                   ; verifica se corresponde a letra para começar o jogo
    CMP R0, R1                                  ; se sim, começa a jogo
    JZ estado_comeca_jogo

    MOV R1, TECLA_CREDITOS                      ; verifica se corresponde a letra para mostrar os creditos
    CMP R0, R1                                  ; se sim mostra os créditos
    JZ estado_credito
    
    JMP estado

estado_comeca_jogo:

    MOV [COMANDO_TERMINA_VIDEOS], R0            ; termina a reproducao do video
    MOV [comeca_jogo], R0                       ; indica aos outros processos para comecarem, desbloquia-os
    MOV R0, JOGO_ATIVO                          ; escreve na variável global que 
    MOV [estado_jogo], R0                       ; o estado de jogo é ativo
    MOV R0, 0                                   ; reinicializa o valor da variável global perdeu_jogo
    MOV [perdeu_jogo], R0                       ; com o valor 0
    MOV R0, IMAGEM_JOGO                         ; guarda o cenario de fundo correspondente ao fundo de jogo
    MOV [SELECIONA_CENARIO_FUNDO], R0           ; troca para o cenário de jogo

    
espera_mudanca:
    MOV R0, [perdeu_jogo]                       ; verifica-se o utilizador perdeu o jogo
    CMP R0, 1                                   ; se sim, termina o jogo
    JZ termina_jogo
    MOV R0, [tecla_premida]                     ; quando é pressionada uma tecla
    MOV R1, TECLA_PAUSA_JOGO                    ; verifica-se se a tecla pressionada
    CMP R0, R1                                  ; é a tecla para pausar/continuar o jogo
    JZ pausa_jogo                               ; se for, o jogo é pausado ou continua, dependendo do estado atual
    MOV R1, TECLA_TERMINA_JOGO                  ; se a tecla pressionada for a que termina o jogo
    CMP R0, R1                                  ; então o jogo é terminado
    JZ termina_jogo
    JMP espera_mudanca                           ; senao volta a esperar um alteracao no estado do jogo

estado_credito:
    CALL espera_nao_tecla                       ; verifica se a letra D deixou de ser pressionada
    MOV R0, VIDEO_CREDITOS                      ; insere o cenário frontal, que indica o inicio da pausa
    MOV [COMANDO_PRODUZ_VIDEO], R0 
    MOV R0, IMAGEM_CREDITOS
    MOV [SELECIONA_CENARIO_FUNDO], R0           ; exibe a imagem do fim dos creditos

ciclo_credito:
    MOV R0, [tecla_premida]                      ; espera até uma tecla ser premida novamete
    MOV R1, TECLA_CREDITOS                       ; compara a tecla premida com a tecla de pausa
    CMP R0, R1                                   ; se a tecla premida for igual a da pausa
    JNZ ciclo_credito                            ; então o jogo é parado ou cointinua, dependendo do estado atual do jogo
    
    CALL espera_nao_tecla                        ; espera até a tecla E deixar de ser pressionada
    MOV [COMANDO_TERMINA_VIDEOS], R0             ; termina a reproducao do video
    MOV R0, IMAGEM_INICIO                        
    MOV [SELECIONA_CENARIO_FUNDO], R0            ; volta a colocar a imagem inicial

    JMP estado


pausa_jogo:
    CALL espera_nao_tecla                           ; verifica se a letra D deixou de ser pressionada
    MOV R1, JOGO_PAUSADO                            ; altera o estado de jogo
    MOV [estado_jogo], R1                           ; para o modo de pausa
    
    MOV R0, IMAGEM_PAUSA                            ; guarda o indice da imagem do ecra da pausa
    MOV [SELECIONA_CENARIO_FRONTAL], R0             ; insere o cenário frontal, que indica o inicio da pausa
    
    MOV R0, [tecla_premida]                         ; espera até uma tecla ser premida novamete
    MOV R1, TECLA_PAUSA_JOGO                        ; compara a tecla premida com a tecla de pausa
    CMP R0, R1                                      ; se a tecla premida for igual a da pausa
    JNZ pausa_jogo                                  ; então o jogo é parado ou cointinua, dependendo do estado atual do jogo
    CALL espera_nao_tecla                           ; espera até a tecla D deixar de ser pressionada
    MOV R0, JOGO_ATIVO                              ; guarda o valor da flag para indicar que o jogo esta ativo
    MOV [estado_jogo], R0                           ; altera o estado de jogo para ativo

    MOV [APAGA_CENARIO_FRONTAL], R0                 ; apaga o cenário frontal, que indica o fim da pausa
    MOV [fim_pausa], R0                             ; reinicia os processos, que foram bloqueados quando se inicio a pausa
    JMP espera_mudanca 

termina_jogo:
    MOV R1, RESET                                   ; altera o estado de jogo para o modo reset
    MOV [estado_jogo], R1                           ; que indica que os valores do robot, display, missil tem de ser reinicializados
    MOV [decrementa_energia], R1                    ; para dar reset ao valor da energia instantaneamente, mantêm o valor do display
    MOV [APAGA_TODOS_PIXEIS], R1                    ; apaga todos os pixeis do ecrã
    
    MOV R1, TECLA_TERMINA_JOGO                      ; verifica se o jogo terminou por opcao do utilizador
    CMP R0, R1                                      ;  se a tecla premida for igual a da pausa
    JZ termina_jogo_pelo_utilizador                 ; entao o jogo é terminado
    
    MOV R1, [energia]                               ; verifica se o jogo acoubou por falta de energia
    CMP R1, 0                                       ; a energia acabou ...
    JZ termina_jogo_sem_energia                     ; ... termina o jogo

    ; Colisão com meteoro
    MOV R0, VIDEO_FIM_EXPLOSAO                      ; guarda o indice do video do fim quando o robot explode
    MOV [COMANDO_PRODUZ_VIDEO], R0                  ; produz esse video
    MOV R0, IMAGEM_FIM_EXPLOSAO                     ; guarda o indice da imagem do fim quando o robot explode
    MOV [SELECIONA_CENARIO_FUNDO], R0               ; exibe essa imagem
    MOV R0, [tecla_premida]
    MOV R1, TECLA_PONTUACAO
    CMP R0, R1
    JZ mostra_pontuacao
    JMP estado
    
; Sem energia 
termina_jogo_sem_energia:
    MOV R0, SOM_SEM_ENERGIA                         ; guarda o indice do som do fim quando o robot fica sem energia
    MOV [COMANDO_PRODUZ_SOM], R0                    ; produz esse som
    MOV R0, VIDEO_FIM_ENERGIA                       ; guarda o indice do video do fim quando o robot fica sem energia
    MOV [COMANDO_PRODUZ_VIDEO], R0                  ; exibe esse video
    MOV R0, IMAGEM_FIM_ENERGIA                      ; guarda o indice da imagem do fim quando o robot fica sem energia
    MOV [SELECIONA_CENARIO_FUNDO], R0               ; exibe essa imagem
    MOV R0, [tecla_premida]
    MOV R1, TECLA_PONTUACAO
    CMP R0, R1
    JZ mostra_pontuacao
    JMP estado

; Utilizador terminou o jogo
termina_jogo_pelo_utilizador:
    MOV R0, SOM_FIM                                 ; guarda o indice do som do fim quando o utilizador termina o jogo
    MOV [COMANDO_PRODUZ_SOM], R0                    ; produz esse som
    MOV R0, VIDEO_FIM                               ; guarda o indice do video do fim quando o utilizador termina o jogo
    MOV [COMANDO_PRODUZ_VIDEO], R0                  ; exibe esse video
    MOV R0, IMAGEM_FIM                              ; guarda o indice da imagem do fim quando o utilizador termina o jogo
    MOV [SELECIONA_CENARIO_FUNDO], R0               ; exibe essa imagem
    MOV R0, [tecla_premida]
    MOV R1, TECLA_PONTUACAO
    CMP R0, R1
    JZ mostra_pontuacao
    JMP estado

mostra_pontuacao:
    MOV R8, [pontuacao]
    CALL escrever_display
    JMP estado

;***************************************************************************
; PROCESSO - TECLADO
;***************************************************************************

PROCESS sp_processo_teclado

teclado:
    MOV  R4, DISPLAYS           ; endereço do periférico dos displays
    MOV  R5, MASCARA            ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R6, TEC_LIN            ; endereço do periférico das linhas
    MOV  R7, TEC_COL            ; endereço do periférico das colunas

ciclo_teclado:
    MOV     R0, 0               ; registo auxiliar
    MOV     R2, ITERADOR        ; inicializar iterador de linhas

espera_tecla:                   ; aguarda que uma tecla seja premida

    WAIT                        ; pode sair aqui do processo

    SHR     R2, 1               ; linha atual
    JZ      ciclo_teclado       ; voltar ao inicio do programa
    MOVB    [R6], R2            ; guardar n linha na memoria - dar input ao teclado
    MOVB    R0, [R7]            ; receber output do teclado - R0 coluna
    AND     R0, R5              ; isolar os 4 bits de menor peso
    CMP     R0, 0               ; a coluna esta a ser premida?
    JZ      espera_tecla        ; nenhuma tecla permida - analisa linha seguinte
    
    MOV     R8, 0               ; inicializar indice de linha
    MOV     R9, 0               ; inicializar indice coluna
    MOV     R3, R2              ; guardar o numero da linha em binario

    CALL conv_teclado_dec       ; coverte o output do teclado decimal 

    MOV [tecla_premida], R9     ; avisa que foi pressionada uma tecla, o valor importa
    JMP espera_tecla
    
;***************************************************************************
; Temporizadores para decrementar display, descer meteorito e subir missil
;**************************************************************************
interupcao_meteoro:
    MOV [baixa_meteoro], R9      ; processo meteoro desbloqueado
    RFE

interupcao_missil:
    MOV [move_missil], R9        ; processo missil desbloqueado
    RFE

interupcao_energia:
    MOV [decrementa_energia], R9 ; processo principal(display) desbloqueado
    CALL adiciona_pontuacao
    RFE


; *********************************************************************************
; *                                                                               *
; *                                 * ROTINAS *                                   *
; *                                                                               *
; *********************************************************************************

; *********************************************************************************
; *                                                                               *
; *                           * ROTINAS DE DESENHO *                              *
; *                                                                               *
; *********************************************************************************


;**************************************************************************
; DESENHA_ROBOT - Com a posicao atual do robot desenha-o no ecra de jogo
; ARGUMENTOS: NAO TEM
;**************************************************************************
desenha_robot:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

    ; Argumentos da funcao desenha_objeto
	MOV R0,	[linha_atual_robot]             ; guarda a linha atual do robot 
	MOV R1,	[coluna_atual_robot]            ; guarda a coluna atual do robot
	MOV R2,	ALTURA_ROBOT                    ; guarda a altura atual do robot
	MOV R3,	LARGURA_ROBOT                   ; gurada a largura atual do robot
	MOV R4,	DEF_ROBOT                       ; guarda o endereco da tabela que define o robot
	CALL desenha_objeto                     ; desenha o robot

	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
    RET

;**************************************************************************
; APAGA_ROBOT - Com a posicao atual do robot apaga-o do ecra de jogo
; ARGUMENTOS: NAO TEM
;**************************************************************************
apaga_robot:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

    ; Argumentos da funcao apaga_objeto
	MOV R0,	[linha_atual_robot]             ; guarda a linha atual do robot           
	MOV R1,	[coluna_atual_robot]            ; guarda a coluna atual do robot
	MOV R2,	ALTURA_ROBOT                    ; guarda a altura atual do robot
	MOV R3,	LARGURA_ROBOT                   ; gurada a largura atual do robot
	CALL apaga_objeto                       ; apaga o robot        

	POP R3
	POP R2
	POP R1
	POP R0
    RET

; ***********************************************************************
;  DESENHA_MISSIL - desenha o missil
;  Argumentos: R0- LINHA DO MISSIL
;              R1- COLUNA DO MISSIL
;************************************************************************
desenha_missil:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    ; argumentos da funcao desenha_missil
    MOV R2, DIM_MISSIL              ; guarda a altura do missil
    MOV R3, DIM_MISSIL              ; guarda a coluna do missil
    MOV R4, DEF_MISSIL              ; guarda o endereco da tabela que define o missil
    CALL desenha_objeto             ; desenha o objeto
    
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

;***********************************************************************
; APAGA_MISSIL- apaga o pixel que representa o missil 
; Argumentos: R0- LINHA DO MISSIL
;             R1- COLUNA DO MISSIL
;***********************************************************************
apaga_missil:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3

    MOV R2, 1                       ; guarda a altura do missil
    MOV R3, 1                       ; guarda a coluna do missil
    CALL apaga_objeto               ; apaga o missil
    
    POP R3
    POP R2
    POP R1
    POP R0
    RET


;**************************************************************************
; DESENHA_METEORO - reúne as informações do meteoro e dá ordens para o desenhar
; Argumentos: NAO TEM 
;**************************************************************************
desenha_meteoro:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
    PUSH R5
    PUSH R6

    MOV R5, linha_atual_meteoro     ; endereço das linhas dos meteoros
	MOV R0,	[R5+R11]                ; guarda a linha do meteoro
    MOV R6, coluna_atual_meteoro    ; endereço das colunas dos meteoros
	MOV R1,	[R6+R11]                ; guarda a coluna do meteoro
	MOV R2,	DIM_METEORO             ; guarda o numero de linhas do meteoro
	MOV R3,	DIM_METEORO             ; guarda o numero de colunas do meteoro
    
    MOV R6, tipo_meteoro              ; endereço do tipo dos meteoros
    MOV R5, [R6+R11]                ; seleciona o tipo do meteoro
    MOV R6, 0                       ; 0 representa um meteoro mau
    CMP R5, R6                      ; compara o tipo de meteoro atual
    JZ def_meteoro_mau

    MOV R4, DEF_METEORO_BOM         ; guarda o endereco da tabela do meteoro bom
    ADD R4, R7                      ; guarda a evolucao do meteoro
    JMP fim_desenha_meteoro

def_meteoro_mau:
	MOV R4, DEF_METEORO_MAU         ; guarda o endereco da tabela do meteoro mau
    ADD R4, R7                      ; guarda a evlucao do meteoro

fim_desenha_meteoro:
    CALL desenha_objeto             ; desenha o meteoro
    
    POP R6
    POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
    RET

;**************************************************************************
; APAGA_METEORO - reúne as informações do meteoro e dá ordens para o apagar
; Argumentos: NAO TEM
;**************************************************************************
apaga_meteoro:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
    PUSH R5
    PUSH R6

    MOV R5, linha_atual_meteoro                 ; endereço das linhas dos meteoros
	MOV R0,	[R5+R11]                            ; guarda a linha do meteoro
    MOV R6, coluna_atual_meteoro                ; endereço das colunas dos meteoros
	MOV R1,	[R6+R11]                            ; guarda a coluna do meteoro
	MOV R2,	DIM_METEORO                         ; guarda a altura do meteoro
	MOV R3,	DIM_METEORO                         ; guarda a coluna do meteoro
	CALL apaga_objeto                           ; apaga o meteoro

    POP R6
    POP R5
	POP R3
	POP R2
	POP R1
	POP R0
    RET


;*************************************************************************************
; DESENHA_EXPLOSAO: desenha a explosao de um meteoro
; Argumentos: R4 - 1 ou 0 para selecionar a explosão
;*************************************************************************************

desenha_explosao:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6

    MOV R0 , 1                                  ; guarda valor de flag ativa
    MOV R6, eliminar_explosao                   ; guarda o endereco da tabela que indica que os meteoros explodiram
    MOV [R6+R11], R0                            ; ativa a flag que indica a explosao tem de ser eliminada posteriormente
    MOV R6, linha_atual_meteoro                 ; guarda o endereco da tabela com as linhas atuais dos meteoros   
    MOV R0, [R6+R11]                            ; guarda a linha do primeiro pixel do meteoro
    MOV R6, coluna_atual_meteoro                ; guarda o endereco da tabela com as colunas atuais dos meteoros
    MOV R1, [R6+R11]                            ; guarda a coluna do primeiro pixel do meteoro
    MOV R2, DIM_METEORO                         ; guarda a altura do meteoro
    MOV R3, DIM_METEORO                         ; guarda a largura do meteoro
    MOV R5, R4                                  ; guarda o tipo tipo de explosão
    CMP R5, 0                                   ; a explosao é de um meteoro mau?
    JZ desenha_explosao_mau                     ; meteoro mau

desenha_explosao_bom:    
    MOV R4, DEF_METEORO_BOM_EXPL                ; guarda o endereco da tabela que define a explosao do meteoro bom
    JMP fim_explosao

desenha_explosao_mau:
    MOV R4, DEF_METEORO_MAU_EXPL                ; guarda o endereco da tabela que define a explosao do meteoro mau

fim_explosao:
    CALL desenha_objeto                         ; desenha a explosao do meteoro
    POP R6
    POP R5
    POP R3
    POP R2
    POP R1
    POP R0
    RET

;******************************************************************************************
; APAGA_EXPLOSAO: Apaga o desenho da explosao de um meteoro
; ARGUMENTOS: NAO TEM
;******************************************************************************************

apaga_explosao:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R6

    MOV R0, 0                               ; guarda o valor de flag desativa
    MOV R6, eliminar_explosao               ; guarda o endereco da tabela que indica que os meteoros explodiram
    MOV [R6+R11], R0                        ; ativa a flag que indica a explosao tem de ser eliminada posteriormente
    MOV R6, linha_atual_meteoro             ; guarda o endereco da tabela com as linhas atuais dos meteoros
    MOV R0, [R6+R11]                        ; guarda a linha do primeiro pixel do meteoro
    MOV R6, coluna_atual_meteoro            ; guarda o endereco da tabela com as colunas atuais dos meteoros
    MOV R1, [R6+R11]                        ; guarda a coluna do primeiro pixel do meteoro
    MOV R2, DIM_METEORO                     ; guarda a altura do meteoro
    MOV R3, DIM_METEORO                     ; guarda a largura do meteoro
    CALL apaga_objeto                       ; apaga a explosao do meteoro

    POP R6
    POP R3
    POP R2
    POP R1
    POP R0
    RET


;**************************************************************************
; DESENHA_OBJETO - desenha um objeto no MediaCenter
; Argumentos:   R0 - linha do primeiro pixel do objeto
;               R1 - coluna do primeiro pixel do objeto
;               R2 - altura do objeto
;               R3 - largura do objeto
;               R4 - endereco da tabela do objeto
;**************************************************************************
desenha_objeto:
	PUSH R7					
    PUSH R8					
	PUSH R9				    
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R8, R1				; guarda a coluna numa var auxiliar, para depois dar reset ao valor
	MOV R9, R3				; guarda largura numa var auxiliar, para depois dar reset ao valor

desenha_linha:       		; desenha os pixels do boneco a partir da tabela
	MOV	R7, [R4]			; obtém a cor do próximo pixel do boneco
	CALL  escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			    ; endereço da cor do próximo pixel 
    ADD R1, 1               ; proxima coluna
    SUB R3, 1               ; colunas restantes
    JNZ desenha_linha       ; continua até percorrer toda a largura do objeto

    MOV R1, R8  			; reinicia a coluna para a nova linha
    MOV R3, R9              ; reinicia a largura para a nova linha
    ADD R0, 1               ; proxima linha
    SUB R2, 1               ; linhas restantes
    JNZ desenha_linha       ; escreve a proxima linha do objeto

    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    POP R9
	POP	R8
	POP	R7
	RET                     


;**************************************************************************
; APAGA_OBJETO - apaga um objeto no MediaCenter
; Argumentos:   R0 - linha do primeiro pixel do objeto
;               R1 - coluna do primeiro pixel do objeto
;               R2 - altura do objeto
;               R3 - largura do objeto
;**************************************************************************
apaga_objeto:
	PUSH R7					
    PUSH R8					
	PUSH R9
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3					

	MOV R7, 0	            ; cor do pixel -> pixel apagado
    MOV R8, R1				; guarda a coluna numa var auxiliar, para depois dar reset ao valor
	MOV R9, R3				; guarda largura numa var auxiliar, para depois dar reset ao valor
			
apaga_linha:       		    ; apaga os pixels do boneco a partir da tabela
	CALL  escreve_pixel		; escreve cada pixel do boneco
    ADD R1, 1               ; proxima coluna
    SUB R3, 1               ; colunas restantes
    JNZ apaga_linha         ; continua até percorrer toda a largura do objeto

    MOV R1, R8  			; reinicia a coluna para a nova linha
    MOV R3, R9              ; reinicia a largura para a nova linha
    ADD R0, 1               ; proxima linha
    SUB R2, 1               ; linhas restantes
    JNZ apaga_linha         ; escreve a proxima linha

    POP R3
    POP R2
    POP R1
    POP R0
	POP R9
    POP R8
	POP	R7
	RET                    

; **********************************************************************
; ESCREVE_PIXEL - escreve um pixel no MediaCenter
; Argumentos:   R0 - linha do pixel escrito
;               R1 - coluna do pixel a ser escrito
;               R7 - cor do pixel a ser escrito
; **********************************************************************
escreve_pixel:
	MOV  [COMANDO_LINHA], R0		    ; seleciona a linha
	MOV  [COMANDO_COLUNA], R1	        ; seleciona a coluna
	MOV  [COMANDO_ALTERA_PIXEL], R7		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; *************************************************************************
; *                                                                       *
; *                       * ROTINAS PRINCIPAIS *                          *
; *                                                                       *
; *************************************************************************

; **********************************************************************
; TESTA_ESQUERDA - Testa se o robot chegou ao limite esquerdo do ecrã
; Argumentos: NAO TEM
; **********************************************************************
testa_esquerda:                     
    PUSH R0
    PUSH R1
    PUSH R3

    MOV R0, MIN_COLUNA              ; guarda o limite inferior das colunas do ecra
    MOV R1, coluna_atual_robot      ; guarda o enderco que contem a coluna atual do robot     
    MOV R3, [R1]                    ;  guarda a coluna do primeiro pixel do robot
    CMP R0, R3                      ; atingiu o limite esquerdo do ecra?   
    JZ fim_test_esq                 ; o  limite foi alcançado - nao faz nada
    CALL apaga_robot                ; apaga o robot
    SUB R3, 1                       ; determina a coluna da esquerda do robot
    MOV [R1], R3                    ; guarda essa nova coluna do robot
    CALL desenha_robot              ; robot desenhado
fim_test_esq:

    POP R3
    POP R1
    POP R0
    RET


; **********************************************************************
; TESTA_DIREITA - Testa se o robot chegou ao limite direito do ecrã
; Argumentos: NAO TEM
; **********************************************************************
testa_direita:                     
    PUSH R0
    PUSH R1
    PUSH R3
    
    MOV R1 , coluna_atual_robot     ; guarda o endereco da primeira coluna do robot
    MOV R3, [R1]                    ; guarda a coluna do primeiro pixel do robot
    MOV R0, MAX_COLUNA              ; guarda o limite direito do ecra
    SUB R0, LARGURA_ROBOT           ; determina o limite direito para o robot
    CMP R3, R0                      ; chegou a esse limite?
    JZ fim_test_dir                 ; o limite foi alcancado - nao faz nada
    CALL apaga_robot                ; o robot é apagado
    ADD R3, 1                       ; determina a coluna dadireita do robot
    MOV [R1], R3                    ; guarda essa nova coluna do robot
    CALL desenha_robot              ; o robot é desenhado
fim_test_dir:   
    POP R3
    POP R1
    POP R0
    RET


; **********************************************************************
; TESTA_BAIXO - Testa se o meteoro chegou ao limite inferior do ecrã
; Argumentos: R7 - Evolução de meteoro
; **********************************************************************
testa_baixo:                       
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R5
	
    MOV R0, MAX_LINHA               ; guarda o limite da linha
	SUB R0, DIM_METEORO             ; guarda a altura do meteoro
    MOV R2, linha_atual_meteoro     ; guarda o endereco da word da primeira linha do robot
    MOV R5, [R2+R11]                ; guarda a linha do primeiro pixel do meteoro
	CMP R5, R0                      ; verifica se o limite de baixo foi alcançado
	JZ volta_para_cima              ; o limite foi alcancado - nao faz nada
    
	CALL apaga_meteoro              ; apaga o meteoro
	ADD R5, 1                       ; determina a linha linha de baixo
    MOV [R2+R11], R5                ; atualiza a nova linha do robot
	CALL desenha_meteoro            ; desenha o meteoro na nova posicao
    JMP fim_testa_baixo                        
                            

volta_para_cima:                    
    CALL apaga_meteoro              ; apaga o meteoro 
    MOV R7, 0                       ; guarda indice da fase inicial do meteoro
    MOV R5, LINHA_METEORO           ; reinicializa a linha do meteoro
    MOV [R2+R11], R5                ; atualiza a nova linha do meteoro
    CALL escolhe_coluna             ; escolhe a proxima coluna do meteoro
    CALL escolhe_meteoro            ; escolhe o tipo do novo meteoro
    CALL desenha_meteoro            ; desenha o meteoro
    CALL desenha_robot              ; desenha o robot (para quando o meteoro ao descer passa por cima dele)
   
fim_testa_baixo:
    POP R5
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
; ADD_DISPLAY - Aumenta o valor exibido no display
; Argumentos: R0 - valor a incrementar no display
; **********************************************************************
add_display:
    PUSH R1
    PUSH R2
    PUSH R7
    PUSH R8
    
    MOV R1, LIMITE_ENERGIA_SUP      ; guarda o limite superior de energia
    MOV R2, energia                 ; guarda o endereco dos displays
    MOV R7, [R2]                    ; guarda o valor atual nos display
    CMP R7, R1                      ; testa se a energia chegou ao limite superior
    JZ fim_add_display              ; o limite foi alcancado - nao faz nada
    ADD R7, R0                      ; valor de energia vai aumentar
    MOV [R2], R7                    ; atualiza o valor na word dos displays
    MOV R8, R7                      ; valor a escrever no display
    CALL escrever_display           ; atualiza o valor nos displays

fim_add_display:
    POP R8
    POP R7
    POP R2
    POP R1
    RET


; **********************************************************************
; SUB_DISPLAY - Decrementa o valor exibido no display
; Argumentos: NAO TEM
; **********************************************************************
sub_display:
    PUSH R1
    PUSH R2
    PUSH R7
    PUSH R8
    
    MOV R1, LIMITE_ENERGIA_INF      ; guarda o limite inferior de energia
    MOV R2, energia                 ; guarda o endereco dos displays
    MOV R7, [R2]                    ; guarda o valor atual nos displays
    CMP R7, R1                      ; testa se a enrgia chegou ao limite inferior
    JLE fim_sub_display             ; o limite foi alcancado - nao faz nada
    SUB R7, ENERGIA_DISPARO         ; valor de energia vai diminuir
    MOV [R2], R7                    ; atualiza o valor na word dos displays
    MOV R8, R7                      ; valor a escrever no display
    CALL escrever_display           ; atualiza o valor nos displays
fim_sub_display:
    POP R8
    POP R7
    POP R2
    POP R1
    RET


;********************************************************************
;COLISOES_METEORO_MISSIL - Verifica se há colisões entre os meteoros e o missil
;ARGUMENTOS: R11 - indice do meteoro a analisar
;*******************************************************************
colisoes_meteoro_missil:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    MOV R4, linha_atual_meteoro             ; guarda o endereco da tabela que contem as linhas dos meteoros
    MOV R0, [R4+R11]                        ; guarda a linha do meteoro em causa
    MOV R4, coluna_atual_meteoro            ; guarda o endereco da tabela que contem as colunas dos meteoros
    MOV R1, [R4+R11]                        ; guarda a coluna do meteoro em causa
    MOV R2, [linha_atual_missil]            ; guarda a linha atual do missil
    MOV R3, [coluna_atual_missil]           ; guarda a coluna atual do missil

    ; verifica se as linhas coincidem
    CMP R0, R2                              ; a primeira linha do meteoro é a mesma que a do missil?
    JGT nao_colisao                         ; nao ha colisao - a linha do missil e superior
    MOV R5, R0                              ; guarda a primeira linha do meteoro
    ADD R5, DIM_METEORO                     ; determina a linha final do meteoro
    SUB R5, 1                               ; ajusta a linha final pois o indice da linha comeca em 0
    CMP R5, R2                              ; a ultima linha do meteoro é a mesma que a do missil?
    JLT nao_colisao                         ; nao ha colisao - a linha do missil e inferior

    ; verifica se as colunas coincidem
    CMP R1, R3                              ; a primeira coluna do meteoro é a mesma que a do missil?
    JGT nao_colisao                         ; nao ha colisao - a coluna do missil e superior
    MOV R5, R1                              ; guarda a primeira coluna do meteoro
    ADD R5, DIM_METEORO                     ; determina a coluna final do meteoro
    SUB R5, 1                               ; ajusta a coluna final pois o indice da coluna comeca em 0
    CMP R5, R3                              ; a ultima coluna do meteoro é a mesma que a do missil?
    JLT nao_colisao                         ; nao ha colisao - a coluna do missil e inferior

    ;existe colisao, repor posicoes
    CALL apaga_meteoro                      ; apaga o meteoro em causa

    ; se for mau ganha energia
    MOV R2, tipo_meteoro                    ; guarda o indice da tabela que contem os tipos dos meteoros
    MOV R0, [R2+R11]                        ; guarda o tipo do meteoro em causa
    MOV R1, METEORO_MAU                     ; guarda o valor do tipo bom de meteoro 
    CMP R0, R1                              ; o meteoro em causa é mau?
    JNZ explosao_meteoro_bom                ; nao é mau - é um meteoro bom

explosao_meteoro_mau:
    
    MOV R0, ENERGIA_EXPLOSAO_MAU            ; quantia de energia ganha
    CALL add_display                        ; incrementa o display - meteoro mau destruido
    MOV R4, METEORO_MAU                     ; guarda o tipo do meteoro - mau
    CALL desenha_explosao                   ; desenha a explosao do meteoro mau
    MOV R2, SOM_EXPLOSAO                    ; guarda o indice do som da explosao do meteoro mau
    CALL produz_som                         ; produz o som da explosao do meteoro mau
    CALL adiciona_pontuacao                 ; aumenta a pontuacao 
    JMP continua_colisao

explosao_meteoro_bom:
    MOV R4, METEORO_BOM                     ; guarda o tipo do meteoro - bom
    CALL desenha_explosao                   ; desenha a explosao do meteoro bom
    MOV R2, SOM_CORACAO_PARTIDO             ; guarda o indice do som da explosao do meteoro bom
    CALL produz_som                         ; produz o som da esxplosao do meteoro bom

continua_colisao:
    MOV R6, HA_EXPLOSAO                     ; guarda o valor da flag que indica que houve uma explosao
    MOV [missil_explodiu], R6               ; escreve essa flag na word do missil - missil explodiu
    MOV R2, NAO_EXISTE_MISSIL               ; guarda o valor da flag que indica que o missil desapareceu
    MOV [linha_atual_missil], R2            ; apaga a linha atual do missil
    MOV R7, 0                               ; reinicializa a fase de evolucao do meteoro
    CALL escolhe_meteoro                    ; escolhe o tipo de meteoro

nao_colisao:
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET



;*******************************************************************************
; COLISOES_METEORO_ROBOT - Verifica se há colisões entre os meteoros e o robot
; ARGUMENTOS: R11 - indice do meteoro a analisar
;*******************************************************************************
colisoes_meteoro_robot:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R6

    MOV R4, linha_atual_meteoro             ; guarda o endereco da tabela que contem as linhas dos meteoros
    MOV R0, [R4+R11]                        ; guarda a linha do meteoro em causa 
    MOV R4, coluna_atual_meteoro            ; guarda o endereco da tabela que contem as colunas dos meteoros
    MOV R1, [R4+R11]                        ; guarda a coluna do meteoro em causa
    MOV R2, [linha_atual_robot]             ; guarda a linha atual do robot
    MOV R3, [coluna_atual_robot]            ; guarda a coluna atual do robot

    ; verifica se as linhas coincidem
    MOV R6, R0                              ; guarda a linha do meteoro em causa
    ADD R6, DIM_METEORO                     ; determina a ultima linha do meteoro
    SUB R6, 1                               ; ajusta a ultima linha do meteoro pois o indice das linhas comeca em 0
    CMP R6, R2                              ; ha colisao ?
    JLT nao_colisao_robot                   ; nao - a linha mais a direita do meteoro esta à esquerda do robot

    ; verifica se as colunas coincidem pela ...
    ; ... direita
    MOV R6, R3                              ; guarda a coluna do robot em causa
    ADD R6, LARGURA_ROBOT                   ; determina a ultima coluna do robot 
    SUB R6,1                                ; ajusta a ultima coluna do robot pois o indice das colunas comeca em 0
    CMP R1, R6                              ; ha colisao ?
    JGT nao_colisao_robot                   ; nao - a coluna mais à esquerda do robot esta à direita do meteoro

    ; ... esquerda
    MOV R6, R1                              ; guarda a coluna atual do meteoro em causa
    ADD R6, DIM_METEORO                     ; determina a ultima coluna do meteoro  
    SUB R6, 1                               ; ajusta a ultima coluna do meteoro pois o indice das colunas comeca em 0
    CMP R6, R3                              ; ha colisao ?
    JLT nao_colisao_robot                   ; nao - a coluna mais à direita do meteoro esta à esquera do robot

    ; existe colisao
    CALL apaga_meteoro                      ; apaga meteoro em causa

    ; se for bom ganha energia
    MOV R4, tipo_meteoro                    ; guarda o indice da tabela que contem os tipos dos meteoros 
    MOV R0, [R4+R11]                        ; guarda o tipo do meteoro em causa
    MOV R1, METEORO_MAU                     ; guarda o tipo do meteoro - mau
    CMP R0, R1                              ; o meteoro em causa é mau ?
    JZ colisao_robot_mau                    ; houve colisao com meteoro mau

colisao_robot_bom:    
    MOV R2, SOM_GANHA_ENERGIA               ; guarda o indice do som de colisao do robot com meteoro bom
    CALL produz_som                         ; produz esse som
    CALL desenha_robot                      ; desenha o robot para o meteoro bom nao decapitar o robot
    MOV R0, ENERGIA_CORACAO                 ; quantia de energia ganha
    CALL add_display                        ; incrementa o display - ganho de energia
    JMP fim_colisao_robot                   

colisao_robot_mau:
    CALL apaga_robot                        ; apaga o robot 
    MOV R4, METEORO_MAU                     ; guarda o tipo do meteoro mau 
    CALL desenha_explosao                   ; desenha a explosao do meteoro mau
    MOV R4, JOGO_PERDIDO                               
    MOV [perdeu_jogo], R4                   ; ativa a flag que indica que o jogo foi perdido
    MOV [tecla_premida], R3                 ; desbloqueia os processos que estao a espera de tecla
    MOV R2, SOM_MORTE                       ; guarda o indice do som da morte do robot
    CALL produz_som                         ; produz o som de morte do robot
    MOV R2, LINHA_ROBOT                     ; guarda a linha inicial do robot
    MOV R3, COLUNA_ROBOT                    ; guarda a coluna inicial do robot
    MOV [linha_atual_robot], R2             ; reinicializa a linha do robot 
    MOV [coluna_atual_robot], R3            ; reinicializa a coluna do robot

fim_colisao_robot:
    MOV R7, 0                               ; reinicializa a fase de evolucao do meteoro
    CALL escolhe_meteoro                    ; escolhe o tipo do meteoro
    MOV R0, LINHA_METEORO                   ; guarda a linha inicial do meteoro
    MOV R4, linha_atual_meteoro             ; guarda o endereco da tabela que contem as linhas dos meteoros
    MOV [R4+R11], R0                        ; reinicializa a linha do meteoro
    CALL escolhe_coluna                     ; escolhe uma nova coluna para o meteoro em causa

nao_colisao_robot:
    POP R6
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

;*******************************************************************************
; ESCOLHE_METEORO - Escolhe um tipo de meteoro - mau ou bom
; ARGUMENTOS: R11 - indice do meteoro a analisar - COMENTAR PEDRO
;*******************************************************************************

escolhe_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2

    MOV R0, [TEC_COL]               ; guarda o output do teclado - aleatorio
    MOV R1, 7                       ; mascara para isolar os 3 primeiros bits
    SHR R0, 5                       ; usa apenas os 3 ultimos bits do output do teclado
    AND R0, R1                      ; isola os ultimos 3 bits
    MOV R1, 6                           
    CMP R1, R0                       ; de 0 a 6 e selecionado o meteoro mau
    JGE seleciona_mau
    MOV R1, 1                           
    MOV R2, tipo_meteoro
    MOV [R2+R11], R1                  ; o meteoro vai aparecer como mau
    JMP fim_escolhe_meteoro
seleciona_mau:
    MOV R1, 0
    MOV R2, tipo_meteoro
    MOV [R2+R11], R1                  ; o meteoro vai aparecer como bom
fim_escolhe_meteoro:
    POP R2
    POP R1
    POP R0
    RET


; ***********************************************************
; *                                                         *
; *               * ROTINAS DE AUXILIARES *                 *
; *                                                         *
; ***********************************************************

; **********************************************************************
; CONV_TECLADO_DEC - Converte o output do teclado em numero decimal (0 a 3)
; Argumentos: R1 - limite superior de energia
;             R7 - valor atual do display
; Resultado:  R9 - tecla presionada em formato decimal 
; **********************************************************************
conv_teclado_dec:
    PUSH R0
    PUSH R2
    PUSH R8

conv_linha:                     ; converte o numero da linha para decimal
    SHR     R2, 1               ; decrementar a linha
    JZ      conv_coluna         ; termina de contar as linhas 
    ADD     R8, 1               ; mais uma linha
    JMP conv_linha

conv_coluna:                    ; converte o numero da coluna para decimal
    SHR     R0, 1               ; decrementar a coluna
    JZ      termina_conversao   ; termina de contar as colunas
    ADD     R9, 1               ; mais uma coluna
    JMP conv_coluna

termina_conversao:              ; termina a conversao para um numero entre 0-F
    SHL     R8, 2               ; conversao para hexadecimal
    ADD     R9, R8              ; une os dois valores 

    POP R8
    POP R2
    POP R0
    RET

; **********************************************************************
; ESPERA_NAO_TECLA - espera até que a tecla nao esteja a ser premida
; Argumentos:  NAO TEM         
; **********************************************************************
espera_nao_tecla:
	PUSH R3
	PUSH R5
    PUSH R4
	PUSH R6
	PUSH R7
    
    MOV R4, ULTIMA_LINHA_TECLADO    ; linha inferior do teclado
espera_nao_tecla_ciclo:
    MOV  R5, MASCARA                ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R6, TEC_LIN                ; endereço do periférico das linhas
    MOV  R7, TEC_COL                ; endereço do periférico das colunas
	
	MOV   R0, R4                    ; guarda o indice da ultima linha do teclado
	MOVB [R6], R0                   ; guardar a linha na memoria - dar input ao teclado
    MOVB  R3, [R7]                  ; receber output do teclado 
    AND   R3, R5                    ; isolar os 4 bits de menor peso
    MOV   R0, 0                     ; guarda o valor recebido do teclado se nenhuma tecla for premida
    CMP   R3, R0                    ; a coluna esta a ser premida?
	JNZ espera_nao_tecla_ciclo      ; tecla nao esta a ser premida

	POP R7
	POP R6
	POP R5
    POP R4
	POP R3
	RET

; ************************************************************************
; PRODUZ_SOM - produz um determinado som
; Argumentos: R2 - registo auxiliar, valor nao interessa
; ************************************************************************
produz_som:

    PUSH R0
    PUSH R1
    PUSH R2

    MOV R0, COMANDO_SELECIONA_SOM   ; guarda endereco para selecionar som
    MOV R1, COMANDO_PRODUZ_SOM      ; guarda o endereco para reproduzir o som
    MOV [R0], R2                    ; seleciona o enderco do som a usar
    MOV [R1], R2                    ; produz o som desejado

    POP R2
    POP R1
    POP R0
    RET


;**************************************************************************
; ESCREVE_DISPLAY  - escreve um valor no display de energia
; Argumentos:   R1 - numero da linha com as teclas que mudam o display
;               R8 - Valor a escrever no display
;**************************************************************************
escrever_display:
    PUSH R0

    MOV R0, DISPLAYS            ; guarda o endereco dos displays
    CALL conv_dec               ; converte o valor a escrever nos displays para decimal
    MOV [R0], R8                ; escreve o valor nos displays

    POP R0
    RET


; *******************************************************************
; CONV_DEC - Converte um valor numerico de hexadecimal em decimal
; Argumentos: R8 - valor a escrever em hexadecimal
; Resultado:  R8 - valor a escrever em decimal
; *******************************************************************
conv_dec:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R0, 1000                            ; fator inicial de divisao
    MOV R2, 0                               ; resultado da conversão
    MOV R5, 10                              ; guardar o limite do fator

ciclo_conv_dec:
    MOD R8, R0                              ; resto da divisao pelo fator inicial
    DIV R0, R5                              ; divide pelo fator 10 - obtem o digito da direita
    MOV R1, R8                              ; guarda o valor a escrever
    DIV R1, R0                              ; mais um digito do valor decimal
    SHL R2, 4                               ; desloca para dar espaco ao proximo bit
    OR R2, R1                               ; compoe o resultado
    CMP R0, R5                              ; a conversão terminou?
    JLT fim_conv_dec                        ; fim da conversao
    JMP ciclo_conv_dec

fim_conv_dec:
    MOV R8, R2                              ; guarda o valor convertido para ser escrito no display

    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


;*******************************************************************************************
; ESCOLHE_COLUNA: Escolhe uma coluna de modo aleatorio para um dado meteoro cair
; Argumentos: R11 - indice do meteoro a analisar - COMENTAR PEDRO 
;*******************************************************************************************

escolhe_coluna:
    PUSH R0
    PUSH R1
    PUSH R2

    MOV R0, [TEC_COL]                         ; guarda o output do teclado - aleatorio
    MOV R1, 59                               
    ADD R0, R1                                ; adiciona-lhe o numero maximo da coluna ate onde pode ir
    MOV R1, 5   
    ADD R0, R1                                ; adiciona-lhe o numero minimo da coluna ate onde pode ir
    MOV R1, 59
    MOD R0, R1                                ; o valor nao pode ultrapassar 59
    MOV R2, coluna_atual_meteoro
    MOV [R2+R11], R0                          ; guarda a nova coluna

    POP R2
    POP R1
    POP R0
    RET


;*******************************************************************************************
; EVOLUI_METEORO: Determina se o meteoro precisa de evoluir de fase
; Argumentos: R1 - linha atual do meteoro em causa
;             R7 - fase atual do meteoro em causa
;*******************************************************************************************
evolui_meteoro:
    PUSH R2
    PUSH R3

    MOV R2, 2                               ; guarda a linha onde a fase inicial comeca
    MOV R3, 14                              ; guarda a linha onde a fase final comeca

ciclo_evolui:  
    CMP R1, R2                              ; o meteoro tem de passar para a proxima fase ?
    JZ proxima_evolucao                     ; sim - incremneta fase
    ADD R2, 3                               ; determina linha da proxima fase
    CMP R2, R3                              ; o meteoro chegou à ultima fase?  
    JLT ciclo_evolui                        ; nao - volta a testar
    JMP fim_evolucao                        ; meteoro nao tem de evoluir

proxima_evolucao:
    MOV R2, METEORO_APROXIMA                ; guarda o incremento para a proxima tabela da fase do meteoro
    ADD R7, R2                              ; incrementa a fase de evolucao do meteoro

fim_evolucao:
    POP R3
    POP R2
    RET

;********************************************************************************************
;  ADICIONA_PONTUACAO: INCREMENTA 1 A PONTUACAO
; ARGUMENTOS: NAO TEM
;********************************************************************************************

adiciona_pontuacao:
    PUSH R1

    MOV R1, [pontuacao]                     ; valor atual da pontuacao
    ADD R1, 1                               ;adiciona 1
    MOV [pontuacao], R1                     ; guarda o novo valor

    POP R1
    RET

