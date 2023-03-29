%{
/* Primer Programa: Analizador Lexico
*/


#include <stdlib.h>
#include <stdio.h>
#include<stdlib.h>
#include <string.h>
int count = 0;

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



union datosToken{
   int valEntero;
   char valCaracter;
};


typedef struct tk{
   int  valT;
   union datosToken infoToken;
}token;



/*Debido a que algunas tablas conservan la misma estructura es posible definir mas de una con una misma estructura para diferentes tipos de datos*/
typedef struct simbEspeciales{
    int valor;
    char simbolo;
}simbEspeciales, operadoresAritmeticos, consCar;

/*Se define un unico struct para ambos tipos de operadores ya que manejan un valor y una cadena*/
typedef struct operador{
    int valor;
    char* cadena;
}opRelacionales, opAsignacion, palabrasReservadas, consNumEnt, consNumReal, consCad, clasesCompLex;



typedef struct ident{
    int posValor;
    char *cadena_ts;
}identificador; 

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




typedef struct nodo{
    union datos datoU;
    struct nodo *siguiente, *anterior;
}nodoL;

opAsignacion tablaOpAsig = {0,"->"};
simbEspeciales tablaSimbEsp [8]= {{0,'('},{1,')'},{2,'{'},{3,'}'},{4,';'},{5,','},{6,'['},{7,']'}};
opRelacionales tablaOpRelacionesles [6] = {{0,"=" },{1,"/=" },{2,">=" },{3,">" },{4,"<" },{5,"<=" }};
operadoresAritmeticos tablaOpArit [5] = {{0,'+'},{1,'-'},{2,'*'},{3,'/'},{4,'%'}};
palabrasReservadas tablaPalRes [11] ={{0,"ent"},{1,"finsi"},{2,"haz"},{3,"mientras"},{4,"large"},{5,"para"},{6,"real"},{7,"regresa"},{8,"si"},{9,"simb"},{10,"sino"}};

int contadoresTIdentificador = 0;
int contadoresTCadena = 0;
int contadoresTCaracter = 0;
int contadoresTNumReal = 0;
int contadoresTNumEntero = 0;





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
/*
int yywrap() {
    return 1;
}
*/
void imprimeContenido(nodoL *inicio, int constanteValor) {
    nodoL *auxiliar  = inicio;
    while (auxiliar != NULL) {
        switch (constanteValor)
        {
        case IDENTIFICADORES:
            printf("Valor de identificador. %s, %d\n", auxiliar->datoU.identValorU.cadena_ts,auxiliar->datoU.identValorU.posValor);
            break;
        case CONSTANTE_NUMERICA_ENTERA:
            printf("Valor en constantes enteras. %s, %d\n", auxiliar->datoU.entValorU.cadena,auxiliar->datoU.entValorU.valor);
            break;
        case CONSTANTE_CADENA:
            printf("Valor en constantes cadenas. %s, %d\n", auxiliar->datoU.cadValorU.cadena,auxiliar->datoU.cadValorU.valor);
            break;
        case CONSTANTE_NUMERICA_REAL:
            printf("Valor en constante real. %s, %d\n", auxiliar->datoU.realValorU.cadena,auxiliar->datoU.realValorU.valor);
            break;
        default:
            printf("Error al realizar busqueda de informacion");
            break;
        }
        auxiliar = auxiliar->siguiente;
    }

    printf("\n");
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


void imprimeContenidoTokens(nodoL *inicio) {
    nodoL *auxiliar  = inicio;
    int selector = 0;
    while (auxiliar != NULL) {
        selector = auxiliar->datoU.valToken.valT;
        switch (selector)
        {
            //caso en el que se recibe como entrada un numero
        case IDENTIFICADORES:
        case OPERADORES_RELACIONALES:
        case OPERADORES_ASIGNACION:
        case PALABRA_RESERVADA:
        case CONSTANTE_NUMERICA_ENTERA:
        case CONSTANTE_CADENA:
        case CONSTANTE_NUMERICA_REAL:
            printf("Valor en tabla de tokens. %d, %d\n", auxiliar->datoU.valToken.infoToken.valEntero,auxiliar->datoU.valToken.valT);
            break;
        case SIMBOLOS_ESPECIALES:
        case OPERADOR_ARITMETICOS:
        case CONSTANTE_CARACTER:
            printf("Valor en tabla de tokens. %c, %d\n", auxiliar->datoU.valToken.infoToken.valCaracter,auxiliar->datoU.valToken.valT);
            break;
        default:
            printf("Error al realizar busqueda dentro de la tabla de tokens");
            break;
        }
        auxiliar = auxiliar->siguiente;
    }

    printf("\n");
}

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

int  busquedaTablasEstaticas(int tablaValor, char *cadena){
    /*Asignaremos un valor distinto dependiendo del tamaño de la tabla el cual conoceremos por medio de su valor en la funcion*/
    int i = 0; 
    switch(tablaValor){
        /*
        case SIMBOLOS_ESPECIALES:

            while(caracter != tablaSimbEsp[i].simbolo){
                i++;
            }
            return tablaSimbEsp[i].valor;
            break;
        */
        case OPERADORES_RELACIONALES:
            while(strcmp(cadena ,tablaOpRelacionesles[i].cadena)){
                //printf("Avnza while\n");
                i++;
            }
            return tablaOpRelacionesles[i].valor;
            break;
        /*case OPERADORES_ASIGNACION:
            //Ya que solo hay uno se le asigna 0
            return 0;
            break;
*/
        case PALABRA_RESERVADA:
            while(strcmp(cadena ,tablaPalRes[i].cadena)){
                //printf("Avnza while %s y %s \n", cadena, tablaPalRes[i].cadena);
                i++;
            }
            //return i;
            return tablaPalRes[i].valor;
            break;
            
           /* 
        case OPERADOR_ARITMETICOS:
            while(caracter != tablaOpArit[i].simbolo){
                i++;
            }
            return tablaSimbEsp[i].valor;
            break;
            */
        default:
            return -1;
            break;

    }
    return -1;
}

void crearInformacion(int TablaT, nodoL** tablaTokens, nodoL** tablaIdentificadores, nodoL** tablaConstantesEnteras, nodoL** tablaCadenas, nodoL** tablaConstantesReales){
    union datos auxiliar;
    union datos tk;

    switch (TablaT){
    case IDENTIFICADORES:
        auxiliar.identValorU.cadena_ts = strdup(yytext);
        auxiliar.identValorU.posValor = contadoresTIdentificador;

        
        tk.valToken.valT = IDENTIFICADORES;
        
        
        tk.valToken.infoToken.valEntero = contadoresTIdentificador; //asignar indice
        contadoresTIdentificador++; //Incrementa para el proximo valor

        insercion(tablaIdentificadores, auxiliar);
        insercion(tablaTokens, tk);
        break;
    case SIMBOLOS_ESPECIALES:

        tk.valToken.valT = SIMBOLOS_ESPECIALES;
        tk.valToken.infoToken.valCaracter = *yytext; //asignar indice
        

        //insercion(tablaSimbEsp, auxiliar);
        insercion(tablaTokens, tk);
        break;
    case OPERADORES_RELACIONALES:

        //printf("contenido de OPRelacional %s a\n", strdup(yytext));
        tk.valToken.valT = OPERADORES_RELACIONALES;
        tk.valToken.infoToken.valEntero = busquedaTablasEstaticas(OPERADORES_RELACIONALES, strdup(yytext)); 
        /*
            implementar metodo de busqueda para asignar el valor
        */

        insercion(tablaTokens, tk);
        break;
    case OPERADORES_ASIGNACION:

        tk.valToken.valT = OPERADORES_ASIGNACION;
        tk.valToken.infoToken.valEntero = 0; //siempre sera 0 ya que es una tabla con un unico elemento
        
        //insercion(tablaOpAsig, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case PALABRA_RESERVADA:
        //printf("contenido de palabras reserbadas %d s\n", busquedaTablasEstaticas(PALABRA_RESERVADA, (strdup(yytext))));
        tk.valToken.valT = 4;
        tk.valToken.infoToken.valEntero = busquedaTablasEstaticas(PALABRA_RESERVADA, yytext);  //asignar indice
        /*
            implementar metodo de busqueda para asignar el valor
        */
        insercion(tablaTokens, tk);
        break;

    case OPERADOR_ARITMETICOS:
        tk.valToken.valT = 5;
        tk.valToken.infoToken.valCaracter = *yytext; //asignar indice
        
        auxiliar.opAritU.valor = 5;
        auxiliar.opAritU.simbolo = *yytext;
        //insercion(tablaOpArit, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_NUMERICA_ENTERA:
        tk.valToken.valT = CONSTANTE_NUMERICA_ENTERA;
        tk.valToken.infoToken.valEntero = contadoresTNumEntero; //asignar indice
        auxiliar.entValorU.valor = contadoresTNumEntero;
        contadoresTNumEntero++; //aumenta el valor para el siguiente valor de la tabla
        
        auxiliar.entValorU.cadena = strdup(yytext);

        insercion(tablaConstantesEnteras, auxiliar);
        insercion(tablaTokens, tk);
        break;
    
    case CONSTANTE_CADENA:
        tk.valToken.valT = CONSTANTE_CADENA;
        tk.valToken.infoToken.valEntero = contadoresTCadena; //asignar indice
        
        auxiliar.cadValorU.valor = contadoresTCadena;
        contadoresTCadena++;//aumenta el valor para el siguiente valor de la tabla

        auxiliar.cadValorU.cadena = strdup(yytext);
        insercion(tablaCadenas, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_CARACTER:
        tk.valToken.valT = 8;
        //printf("%c resultado de la funcion caracter\n", *(yytext+1));
        tk.valToken.infoToken.valCaracter = *(yytext+1); //asignar indice
        

        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_NUMERICA_REAL:
        tk.valToken.valT = CONSTANTE_NUMERICA_REAL;
        tk.valToken.infoToken.valEntero = contadoresTNumReal; //asignar indice
        
        auxiliar.realValorU.valor = contadoresTNumReal;
        contadoresTNumReal++;
        auxiliar.realValorU.cadena = strdup(yytext);
        insercion(tablaConstantesReales, auxiliar);
        insercion(tablaTokens, tk);
        break;

    default:
        break;
    }
}

/*
opAsignacion tablaOpAsig = {0,"->"};
simbEspeciales tablaSimbEsp [8]= {{0,'('},{1,')'},{2,'{'},{3,'}'},{4,';'},{5,','},{6,'['},{7,']'}};
opRelacionales tablaOpRelacionesles [6] = {{0,"=" },{1,"/=" },{2,">=" },{3,">" },{4,"<" },{5,"<=" }};
operadoresAritmeticos tablaOpArit [5] = {{0,'+'},{1,'-'},{2,'*'},{3,'/'},{4,'%'}};
palabrasReservadas tablaPalRes [11] ={{0,"ent"},{1,"finsi"},{2,"haz"},{3,"mientras"},{4,"large"},{5,"para"},{6,"real"},{7,"regresa"},{8,"si"},{9,"simb"},{10,"sino"}};
*/



main (int argc, char * argv[]){
    nodoL *tablaTokens = NULL;
    nodoL *tablaIdentificadores = NULL;
    nodoL *tablaConstantesEnteras = NULL;
    nodoL *tablaCadenas = NULL;
    nodoL *tablaConstantesReales = NULL;
    int res,c;
    yyin = fopen(argv[1],"r");
    int aux;
        
    do{
        res = yylex();
        aux = res;
        printf("%d es el valor de d\n", res);
        crearInformacion(res, &tablaTokens,&tablaIdentificadores,&tablaConstantesEnteras,&tablaCadenas,&tablaConstantesReales);
    }while(res);

    imprimeContenido(tablaIdentificadores, IDENTIFICADORES);
    imprimeContenido(tablaConstantesEnteras, CONSTANTE_NUMERICA_ENTERA);
    imprimeContenido(tablaCadenas, CONSTANTE_CADENA);
    imprimeContenido(tablaConstantesReales, CONSTANTE_NUMERICA_REAL);
    
    imprimeContenidoTokens(tablaTokens);
   /* 
    int a = busquedaTablasEstaticas(OPERADOR_ARITMETICOS, "",'+');
    printf("%d es el resultado\n", a);
    int b = busquedaTablasEstaticas(OPERADOR_ARITMETICOS, "-",'-');
    printf("%d es el resultado\n", b);
int c1 = busquedaTablasEstaticas(OPERADOR_ARITMETICOS, "*",'*');
    printf("%d es el resultado\n", c1);
int d = busquedaTablasEstaticas(OPERADOR_ARITMETICOS, "/",'/');
    printf("%d es el resultado\n", d);
int e = busquedaTablasEstaticas(OPERADOR_ARITMETICOS, " ",'%');
    printf("%d es el resultado\n", e);

    int a = busquedaTablasEstaticas(OPERADORES_RELACIONALES, "=",'+');
    printf("%d es el resultado\n", a);
    int b = busquedaTablasEstaticas(OPERADORES_RELACIONALES, "/=",'-');
    printf("%d es el resultado\n", b);
int c1 = busquedaTablasEstaticas(OPERADORES_RELACIONALES, ">=",'*');
    printf("%d es el resultado\n", c1);
int d = busquedaTablasEstaticas(OPERADORES_RELACIONALES, ">",'/');
    printf("%d es el resultado\n", d);
int e = busquedaTablasEstaticas(OPERADORES_RELACIONALES, "<",'%');
    printf("%d es el resultado\n", e);
    int f = busquedaTablasEstaticas(OPERADORES_RELACIONALES, "<=",'%');
    printf("%d es el resultado\n", f);


    int a = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "=",'(');
    printf("%d es el resultado\n", a);
    int b = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "/=",')');
    printf("%d es el resultado\n", b);
int c1 = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, ">=",'{');
    printf("%d es el resultado\n", c1);
int d = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, ">",'}');
    printf("%d es el resultado\n", d);
int e = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "<",';');
    printf("%d es el resultado\n", e);
    int f = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "<=",',');
    printf("%d es el resultado\n", f);
    int g = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "<=",'[');
    printf("%d es el resultado\n", g);
    int h = busquedaTablasEstaticas(SIMBOLOS_ESPECIALES, "<=",']');
    printf("%d es el resultado\n", h);
*/


    //imprimeContenido(tablaSimbEsp,SIMBOLOS_ESPECIALES);
    return 0;
}
