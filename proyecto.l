%{
/* Primer Programa: Analizador Lexico
*/

#include <stdlib.h>
#include <stdio.h>
#include<stdlib.h>
#include <string.h>

//La constante IDENTIFICADOR tomara un valor de 10 en vez de 0 debido a en caso de presentarse un identificador dentro del archivo la funcion yylex retornara 0
//Debido a que C toma al 0 como una negacion y hacmos uso de la salida de yylex como condicion del ciclo do-while que permite la lectura del archivo fue necesario cambiar su valor   
#define IDENTIFICADORES                    10 
#define SIMBOLOS_ESPECIALES                1
#define OPERADORES_RELACIONALES            2
#define OPERADORES_ASIGNACION              3
#define PALABRA_RESERVADA                  4
#define OPERADOR_ARITMETICOS               5
#define CONSTANTE_NUMERICA_ENTERA          6
#define CONSTANTE_CADENA                   7
#define CONSTANTE_CARACTER                 8
#define CONSTANTE_NUMERICA_REAL            9
FILE *archSal;

%}
digblank [\t\n ]     
palRes ent|finsi|haz|mientras|large|para|real|regresa|si|simb|sino
simEspeciales [\(\)\{\}\;\,\[\]]
digOctal [0-7]
digDecimal [1-9]
digHexadecimal [0-9A-Fa-f]
dig [0-9]
letHex [a-fA-F]
num {dig}+
guionBajo [_]
letrasMinusculas [a-z]
consCaracter '.'
consEnteraOctal 0{digOctal}*
consEnteraDecimal {digDecimal}+({digDecimal}|0)*
consEnteraHexadecimal 0(x|X){digHexadecimal}+
consEntera {consEnteraDecimal}|{consEnteraHexadecimal}|{consEnteraOctal}
consNumReales {num}+(\.){num}+|(\.){num}+|{num}+(\.)
consCadena \"(.)*\"
opArit "+"|"-"|"*"|"/"|"%"
opRelacionales "="|"/="|">="|"<"|">"|"<="
ident {letrasMinusculas}{letrasMinusculas}({guionBajo}|{letrasMinusculas})*
opAsignacion "->"

%%
{digblank} {return 11;}
{consEntera} {return CONSTANTE_NUMERICA_ENTERA;}
{consNumReales} {return CONSTANTE_NUMERICA_REAL;}
{consCaracter} {return CONSTANTE_CARACTER;}
{consCadena} {return CONSTANTE_CADENA;}
{opAsignacion} {return OPERADORES_ASIGNACION;}
{opArit} {return OPERADOR_ARITMETICOS;}
{palRes} {return PALABRA_RESERVADA;}
{opRelacionales} {return OPERADORES_RELACIONALES;}
{simEspeciales} {return SIMBOLOS_ESPECIALES;}
{ident} {return IDENTIFICADORES;}

. {return 11;}
%%
//Informacion la cual puede almacenarse en token  
union datosToken{
   int valEntero;
   char valCaracter;
};

//Informacion del token
typedef struct tk{
   int  valT;
   union datosToken infoToken;
}token;

/*Debido a que algunas tablas conservan la misma estructura es posible definir una mismo tipo de dato con la misma estructura*/
typedef struct simbEspeciales{
    int valor;
    char simbolo;
}simbEspeciales, operadoresAritmeticos, consCar;

/*Se define una estructura para distintos tipos de datos*/
typedef struct operador{
    int valor;
    char* cadena;
}opRelacionales, opAsignacion, palabrasReservadas, consNumEnt, consNumReal, consCad, clasesCompLex;

/*Se define una estructura unica para el identificador */
typedef struct ident{
    int posValor;
    char *cadena_ts;
    int tipo;
}identificador; 

/*se crea un tipo de dato el cual pueda almacenar los diferentes tipos de datos creados anteriormente*/
union datos{
    //datos dinamicos 
    identificador identValorU;
    consNumEnt entValorU;
    consCad cadValorU;
    consCar carValorU;
    consNumReal realValorU;
    //datos estaticos
    opAsignacion asigValorU;
    simbEspeciales especialValorU;
    opRelacionales opRelacioneslesU;
    operadoresAritmeticos opAritU;
    palabrasReservadas palResU;
    //datos token
    token valToken;
};

//Se define una estructura de datos para que almacene la informacion y realice las funciones de una lista doblemente enlazada 
typedef struct nodo{
    union datos datoU;
    struct nodo *siguiente, *anterior;
}nodoL;
/*Definicion de las tablas estaticas*/
opAsignacion tablaOpAsig = {0,"->"};
simbEspeciales tablaSimbEsp [8]= {{0,'('},{1,')'},{2,'{'},{3,'}'},{4,';'},{5,','},{6,'['},{7,']'}};
opRelacionales tablaOpRelacionesles [6] = {{0,"=" },{1,"/=" },{2,">=" },{3,">" },{4,"<" },{5,"<=" }};
operadoresAritmeticos tablaOpArit [5] = {{0,'+'},{1,'-'},{2,'*'},{3,'/'},{4,'%'}};
palabrasReservadas tablaPalRes [11] ={{0,"ent"},{1,"finsi"},{2,"haz"},{3,"mientras"},{4,"large"},{5,"para"},{6,"real"},{7,"regresa"},{8,"si"},{9,"simb"},{10,"sino"}};

/*Contadores para la posicion */
int contadoresTIdentificador = 0;
int contadoresTCadena = 0;
int contadoresTCaracter = 0;
int contadoresTNumReal = 0;
int contadoresTNumEntero = 0;
void imprimeTablasEstaticas(){

    
    int i = 0;
    printf("Contenido de operador asignacion %d, %s\n", tablaOpAsig.valor,tablaOpAsig.cadena);
    fprintf(archSal,"Contenido de operador asignacion %d, %s\n", tablaOpAsig.valor,tablaOpAsig.cadena);
    printf("\n");
    fprintf(archSal,"\n");
    
    for(int j=0; j<8;j++){
        printf("Contenido de tabla simbolos especiales %d, %c\n", tablaSimbEsp[j].valor,tablaSimbEsp[j].simbolo);
        fprintf(archSal,"Contenido de tabla simbolos especiales %d, %c\n", tablaSimbEsp[j].valor,tablaSimbEsp[j].simbolo);
    }
    printf("\n");
    fprintf(archSal,"\n");
    for(int k=0; k<6;k++){
        printf("Contenido de tabla operadores relacionales%d, %s\n", tablaOpRelacionesles[k].valor,tablaOpRelacionesles[k].cadena);
        fprintf(archSal,"Contenido de tabla operadores relacionales%d, %s\n", tablaOpRelacionesles[k].valor,tablaOpRelacionesles[k].cadena);
    }
    printf("\n");
    fprintf(archSal,"\n");
    for(int l=0; l<5;l++){
        printf("Contenido de tabla operadores aritméticos %d, %c\n", tablaOpArit[l].valor,tablaOpArit[l].simbolo);
        fprintf(archSal,"Contenido de tabla operadores aritméticos %d, %c\n", tablaOpArit[l].valor,tablaOpArit[l].simbolo);
    }
    printf("\n");
    fprintf(archSal,"\n");
    for(int m=0; m<11;m++){
        printf("Contenido de tabla palabras reservadas %d, %s\n", tablaPalRes[m].valor,tablaPalRes[m].cadena);
        fprintf(archSal,"Contenido de tabla palabras reservadas %d, %s\n", tablaPalRes[m].valor,tablaPalRes[m].cadena);
    }
    printf("\n");
    fprintf(archSal,"\n");

}


/*Funciones para la lista*/
nodoL *crear(union datos dato){
    nodoL *puntero = malloc(sizeof(nodoL));
    puntero->siguiente = NULL; 
    puntero->anterior = NULL;
    puntero->datoU = dato;
    return puntero;
}

void insercion(nodoL** inicio, union datos dato) {
        nodoL *nuevoIdent = crear(dato);
    if (*inicio == NULL) {
        nuevoIdent->anterior = NULL;
        nuevoIdent->siguiente = NULL;
        *inicio = nuevoIdent;
    } else {

        nodoL *aux = *inicio;
        nodoL *aux2 = NULL;
        
        while (aux->siguiente != NULL) {
            aux = aux->siguiente;
        }
        aux2 = aux;
        nuevoIdent->anterior = aux2;
        aux->siguiente = nuevoIdent;
    }
}

//Muestra el contenido de las de las listas
void imprimeContenido(nodoL *inicio, int constanteValor) {
    nodoL *auxiliar  = inicio;
    while (auxiliar != NULL) {
        switch (constanteValor)
        {
        case IDENTIFICADORES:
            printf("Valor de identificador. %d, %s\n", auxiliar->datoU.identValorU.posValor, auxiliar->datoU.identValorU.cadena_ts);
            fprintf(archSal,"Valor de identificador. %d, %s\n", auxiliar->datoU.identValorU.posValor, auxiliar->datoU.identValorU.cadena_ts);
            
            break;
        case CONSTANTE_NUMERICA_ENTERA:
            printf("Valor en constantes enteras. %d, %s\n", auxiliar->datoU.entValorU.valor, auxiliar->datoU.entValorU.cadena);
            fprintf(archSal,"Valor en constantes enteras. %d, %s\n", auxiliar->datoU.entValorU.valor, auxiliar->datoU.entValorU.cadena);
            
            break;
        case CONSTANTE_CADENA:
            printf("Valor en constantes cadenas. %d, %s\n", auxiliar->datoU.cadValorU.valor, auxiliar->datoU.cadValorU.cadena);
            fprintf(archSal,"Valor en constantes cadenas. %d, %s\n", auxiliar->datoU.cadValorU.valor, auxiliar->datoU.cadValorU.cadena);
            
            break;
        case CONSTANTE_NUMERICA_REAL:
            printf("Valor en constante real. %d, %s\n", auxiliar->datoU.realValorU.valor, auxiliar->datoU.realValorU.cadena);
            fprintf(archSal,"Valor en constante real. %d, %s\n", auxiliar->datoU.realValorU.valor, auxiliar->datoU.realValorU.cadena);
            
            break;
        default:
            printf("Error al realizar busqueda de informacion");
                        
            break;
        }
        auxiliar = auxiliar->siguiente;
    }
    printf("\n");
}

//Borra la lista
void borrar(nodoL **inicio){
    nodoL *auxiliar  = *inicio;
    nodoL *auxiliar2  = NULL;
    while (auxiliar->siguiente != NULL) {
        auxiliar = auxiliar->siguiente;
    }
    while(auxiliar->anterior != NULL){
        auxiliar2 = auxiliar->anterior;
        free(auxiliar);
        auxiliar = auxiliar2;   
    }
}

/*
identificadores numero  0
simbolos especiales caracter 1 
operador relacional numero 2
operador asignacion numero 3
palabra reservada numero 4
operador aritmetico caracter 5
constante numerica numero 6
constante cadena numero 7
caracte carácter 8
constante real numero 9
*/

//muestra de la tabla de tokens
void imprimeContenidoTokens(nodoL *inicio) {
    nodoL *auxiliar  = inicio;
    int selector = 0;
    while (auxiliar != NULL) {
        selector = auxiliar->datoU.valToken.valT;
        switch (selector)
        {
        //Casos donde el token retorna un numero
        case IDENTIFICADORES:
        case OPERADORES_RELACIONALES:
        case OPERADORES_ASIGNACION:
        case PALABRA_RESERVADA:
        case CONSTANTE_NUMERICA_ENTERA:
        case CONSTANTE_CADENA:
        case CONSTANTE_NUMERICA_REAL:
            printf("Valor en tabla de tokens. %d, %d\n", auxiliar->datoU.valToken.valT,auxiliar->datoU.valToken.infoToken.valEntero);
            fprintf(archSal,"Valor en tabla de tokens. %d, %d\n", auxiliar->datoU.valToken.valT,auxiliar->datoU.valToken.infoToken.valEntero);
            break;
        //Casos donde el token retorna un caracter
        case SIMBOLOS_ESPECIALES:
        case OPERADOR_ARITMETICOS:
        case CONSTANTE_CARACTER:
            printf("Valor en tabla de tokens. %d, %c\n", auxiliar->datoU.valToken.valT,auxiliar->datoU.valToken.infoToken.valCaracter);
            fprintf(archSal,"Valor en tabla de tokens. %d, %c\n", auxiliar->datoU.valToken.valT,auxiliar->datoU.valToken.infoToken.valCaracter);
            break;
        default:
            printf("Error al realizar busqueda dentro de la tabla de tokens");
            break;
        }
        auxiliar = auxiliar->siguiente;
    }

    printf("\n");
}

//Busca la posicion en la tabla de los elementos 
int  busquedaTablasEstaticas(int tablaValor, char *cadena){
    /*Asignaremos un valor distinto dependiendo del tamaño de la tabla el cual conoceremos por medio de su valor en la funcion*/
    int i = 0; 
    switch(tablaValor){
        case OPERADORES_RELACIONALES:
            while(strcmp(cadena ,tablaOpRelacionesles[i].cadena)){
                i++;
            }
            return tablaOpRelacionesles[i].valor;
            break;
        
        case PALABRA_RESERVADA:
            while(strcmp(cadena ,tablaPalRes[i].cadena)){
                i++;
            }
            return tablaPalRes[i].valor;
            break;    
        default:
            return -1;
            break;
    }
    return -1;
}

//Verifica que no se encuentre almacenado el identificador dentro de la tabla
int duplicados(nodoL* tablaIdent, char* cadena ){
    nodoL *auxiliar = tablaIdent;
    while (auxiliar != NULL) {
        if(!strcmp(auxiliar->datoU.identValorU.cadena_ts, cadena)){
            return 0;
        }
        auxiliar = auxiliar->siguiente;
    }
    return 1;
}

//Almacena dentro de las tablas dinamicas los nuevos elementos 
void crearInformacion(int TablaT, nodoL** tablaTokens, nodoL** tablaIdentificadores, nodoL** tablaConstantesEnteras, nodoL** tablaCadenas, nodoL** tablaConstantesReales){
    union datos auxiliar;
    union datos tk;
    //Dependiendo del valor que reciba ingresara dentro de una distinta tabla los datos
    switch (TablaT){
    case IDENTIFICADORES:
        auxiliar.identValorU.cadena_ts = strdup(yytext);
        
        if(duplicados(*tablaIdentificadores , auxiliar.identValorU.cadena_ts)){
            
            //Ingresa la informacion del nuevo elemento de la tabla
            auxiliar.identValorU.posValor = contadoresTIdentificador;
            auxiliar.identValorU.tipo = -1;
            
            //Ingresa la informacion del token
            tk.valToken.valT = IDENTIFICADORES;
            tk.valToken.infoToken.valEntero = contadoresTIdentificador; 
            contadoresTIdentificador++; 

            //Inserta en la tabla el nuevo elemento
            insercion(tablaIdentificadores, auxiliar);
            insercion(tablaTokens, tk);
        }
        break;
    case SIMBOLOS_ESPECIALES:
        
        //Ingresa la informacion del token
        tk.valToken.valT = SIMBOLOS_ESPECIALES;
        tk.valToken.infoToken.valCaracter = *yytext; 

        //Unicamente ingresa el nuevo token
        insercion(tablaTokens, tk);
        break;
    case OPERADORES_RELACIONALES:
        //Ingresa la informacion del token
        tk.valToken.valT = OPERADORES_RELACIONALES;
        //Realiza la busqueda dentro de la tabla para obtener su posicion 
        tk.valToken.infoToken.valEntero = busquedaTablasEstaticas(OPERADORES_RELACIONALES, strdup(yytext)); 
        //Inserta el nuevo elemento a la tabla de tokens
        insercion(tablaTokens, tk);
        break;
    case OPERADORES_ASIGNACION:
        //Ingresa informacion del token
        tk.valToken.valT = OPERADORES_ASIGNACION;
        tk.valToken.infoToken.valEntero = 0; 
        
        //Inserta el nuevo elemento a la tabla de tokens 
        insercion(tablaTokens, tk);
        break;

    case PALABRA_RESERVADA:
        //Ingresa informacion del nuevo token
        tk.valToken.valT = 4;
        tk.valToken.infoToken.valEntero = busquedaTablasEstaticas(PALABRA_RESERVADA, yytext);  //asignar indice
        //Inserta nuevo token a la tabla
        insercion(tablaTokens, tk);
        break;

    case OPERADOR_ARITMETICOS:
        //Ingresa informacion del nuevo token
        tk.valToken.valT = 5;
        tk.valToken.infoToken.valCaracter = *yytext;
        //Inserta nuevo token
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_NUMERICA_ENTERA:
        //Ingresa informacion del nuevo token 
        tk.valToken.valT = CONSTANTE_NUMERICA_ENTERA;
        tk.valToken.infoToken.valEntero = contadoresTNumEntero; 
        //Ingresa informacion del nuevo elemento de la tabla
        auxiliar.entValorU.valor = contadoresTNumEntero;
        contadoresTNumEntero++; 
        auxiliar.entValorU.cadena = strdup(yytext);
        //Inserta los nuevos elementos en las tablas
        insercion(tablaConstantesEnteras, auxiliar);
        insercion(tablaTokens, tk);
        break;
    
    case CONSTANTE_CADENA:
        //Ingresa informacion del nuevo token
        tk.valToken.valT = CONSTANTE_CADENA;
        tk.valToken.infoToken.valEntero = contadoresTCadena; 
        //Ingresa informacion del nuevo elemento de la tabla
        auxiliar.cadValorU.valor = contadoresTCadena;
        contadoresTCadena++;
        auxiliar.cadValorU.cadena = strdup(yytext);

        //Inserta los nuevos elementos en las tablas
        insercion(tablaCadenas, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_CARACTER:
        //Ingresa informacion del nuevo token
        tk.valToken.valT = CONSTANTE_CARACTER;
        tk.valToken.infoToken.valCaracter = *(yytext+1); 
        
        //Inserta el nuevo token
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_NUMERICA_REAL:
        //Ingresa informacion del nuevo token
        tk.valToken.valT = CONSTANTE_NUMERICA_REAL;
        tk.valToken.infoToken.valEntero = contadoresTNumReal; //asignar indice
        
        //Ingresa informacion en la tabla 
        auxiliar.realValorU.valor = contadoresTNumReal;
        contadoresTNumReal++;
        auxiliar.realValorU.cadena = strdup(yytext);
        
        //Inserta los nuevos elementos en las tablas
        insercion(tablaConstantesReales, auxiliar);
        insercion(tablaTokens, tk);
        break;

    default:
        break;
    }
}

main (int argc, char * argv[]){
    //Abre el archivo para la escritura de los nuevos elementos
    archSal = fopen("salida.txt","w");
    //Crea los nodos los cuales representan las nuevas tablas 
    nodoL *tablaTokens = NULL;
    nodoL *tablaIdentificadores = NULL;
    nodoL *tablaConstantesEnteras = NULL;
    nodoL *tablaCadenas = NULL;
    nodoL *tablaConstantesReales = NULL;
    
    yyin = fopen(argv[1],"r");
    //almacena los resultados de la lectura del archivo
    int res;
    //Realiza el almacenamiento dentro de las tablas hasta terminar de leer el archivo
    do{
        res = yylex();
        crearInformacion(res, &tablaTokens,&tablaIdentificadores,&tablaConstantesEnteras,&tablaCadenas,&tablaConstantesReales);
    }while(res);

    //Muestra el contenido de las tablas dinamicas 
    imprimeContenido(tablaIdentificadores, IDENTIFICADORES);
    imprimeContenido(tablaConstantesEnteras, CONSTANTE_NUMERICA_ENTERA);
    imprimeContenido(tablaCadenas, CONSTANTE_CADENA);
    imprimeContenido(tablaConstantesReales, CONSTANTE_NUMERICA_REAL);
    imprimeTablasEstaticas();
    //Muestra el contenido de los token
    imprimeContenidoTokens(tablaTokens);

    //Cierra el archivo
    fclose(archSal);
    return 0;
}
