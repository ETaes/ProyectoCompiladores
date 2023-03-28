%{
/* Primer Programa: Analizador Lexico
*/
#include <stdlib.h>
#include <stdio.h>
#include<stdlib.h>
int count = 0;

#define IDENTIFICADORES                    0
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
digblank [\t\n]     /* Ignorar Los espacios en blanco */
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

%%
{consEntera} {return CONSTANTE_NUMERICA_ENTERA;}
{consNumReales} {return CONSTANTE_NUMERICA_REAL;}
{consCaracter} {return CONSTANTE_CARACTER;}
{consCadena} {return CONSTANTE_CADENA;}
{opArit} {return OPERADOR_ARITMETICOS;}
{palRes} {return PALABRA_RESERVADA;}
{opRelacionales} {return OPERADORES_RELACIONALES;}
{simEspeciales} {return SIMBOLOS_ESPECIALES;}
{ident} {return IDENTIFICADORES;}

. {printf("No se ha podido identificar su tipo\n");}
%%



union datosToken{
   int valEntero;
   char valCaracter;
   char *valCadena;
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



/*
void borrar (identificador *p)
{
   if (p->anterior != NULL)
	p->anterior->siguiente = p->siguiente;
   free(p);
}*/
/*Crear */

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
            //printf("La condicion si entra hasta este punto %d\n",prueba);
        }
        aux2 = aux;
        nuevoIdent->anterior = aux2;
        
        //printf("valor del PUNTO anterior %s, %d %d\n", aux2->cadena_ts,aux2->posTablaSimb,aux2->posValor);
        //printf("valor del PUNTO nuevo %s, %d %d\n", nuevoIdent->cadena_ts,nuevoIdent->posTablaSimb,nuevoIdent->posValor);
        
        aux->siguiente = nuevoIdent;
    }
    
}

void imprimeContenido(nodoL *inicio, int constanteValor) {
    nodoL *auxiliar  = inicio;
    while (auxiliar != NULL) {
        switch (constanteValor)
        {
        case 0:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.identValorU.cadena_ts,auxiliar->datoU.identValorU.posValor);
            break;
        case 1:
            printf("Valor de cadena actual. %c, %d\n", auxiliar->datoU.carValorU.simbolo,auxiliar->datoU.carValorU.valor);
            break;
        case 2:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.opRelacioneslesU.cadena,auxiliar->datoU.opRelacioneslesU.valor);
            break;
        case 3:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.asigValorU.cadena,auxiliar->datoU.asigValorU.valor);
            break;
        case 4:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.palResU.cadena,auxiliar->datoU.palResU.valor);
            break;
        case 5:
            printf("Valor de cadena actual. %c, %d\n", auxiliar->datoU.opAritU.simbolo,auxiliar->datoU.opAritU.valor);
            break;
        case 6:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.entValorU.cadena,auxiliar->datoU.entValorU.valor);
            break;
        case 7:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.cadValorU.cadena,auxiliar->datoU.cadValorU.valor);
            break;
        case 8:
            printf("Valor de cadena actual. %c, %d\n", auxiliar->datoU.carValorU.simbolo,auxiliar->datoU.carValorU.valor);
            break;
        case 9:
            printf("Valor de cadena actual. %s, %d\n", auxiliar->datoU.realValorU.cadena,auxiliar->datoU.realValorU.valor);
            break;
        
        default:
            printf("No hay nada");
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

void crearInformacion(int TablaT, nodoL** tablaTokens, nodoL** tablaIdentificadores, nodoL** tablaConstantesEnteras, nodoL** tablaCadenas, nodoL** tablaConstantesReales){
    union datos auxiliar;
    union datos tk;
    /*Esto se quita*/
    //char *yytext;

    switch (TablaT){
    case IDENTIFICADORES:
        auxiliar.identValorU.cadena_ts = yytext;
        auxiliar.identValorU.posValor = contadoresTIdentificador;
        //Incrementa el valor para el nuevo elementro de la tabla
        
        
        tk.valToken.valT = IDENTIFICADORES;
        
        
        tk.valToken.infoToken.valEntero = contadoresTIdentificador; //asignar indice
        contadoresTIdentificador++; //Incrementa para el proximo valor

        insercion(tablaIdentificadores, auxiliar);
        insercion(tablaTokens, tk);
        break;
    case SIMBOLOS_ESPECIALES:
    //Nota usamos la deficion de caracter ya que cuenta con la misma estructura
        //auxiliar.especialValorU.valor = 1;
        //auxiliar.especialValorU.simbolo = yytext;
        
        tk.valToken.valT = SIMBOLOS_ESPECIALES;
        tk.valToken.infoToken.valCaracter = *yytext; //asignar indice
        

        //insercion(tablaSimbEsp, auxiliar);
        insercion(tablaTokens, tk);
        break;
    case OPERADORES_RELACIONALES:
        //auxiliar.opRelacioneslesU.valor = 2;
        //auxiliar.opRelacioneslesU.cadena = yytext;

        tk.valToken.valT = OPERADORES_RELACIONALES;
        tk.valToken.infoToken.valEntero = -1; 
        /*
            implementar metodo de busqueda para asignar el valor
        */
        //insercion(tablaOpRelacionesles, auxiliar);
        insercion(tablaTokens, tk);
        break;
    case OPERADORES_ASIGNACION:
        
        //auxiliar.asigValorU.valor = 3;
        //auxiliar.asigValorU.cadena = yytext; 
        tk.valToken.valT = OPERADORES_ASIGNACION;
        tk.valToken.infoToken.valEntero = 0; //siempre sera 0 ya que es una tabla con un unico elemento
        
        //insercion(tablaOpAsig, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case PALABRA_RESERVADA:

        //auxiliar.asigValorU.valor = 4;
        //auxiliar.asigValorU.cadena = yytext;
        //insercion(tablaPalRes, auxiliar);
        tk.valToken.valT = 4;
        tk.valToken.infoToken.valEntero = -1; //asignar indice
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
        
        auxiliar.entValorU.cadena = yytext;

        insercion(tablaConstantesEnteras, auxiliar);
        insercion(tablaTokens, tk);
        break;
    
    case CONSTANTE_CADENA:
        tk.valToken.valT = CONSTANTE_CADENA;
        tk.valToken.infoToken.valEntero = contadoresTCadena; //asignar indice
        
        auxiliar.cadValorU.valor = contadoresTCadena;
        contadoresTCadena++;//aumenta el valor para el siguiente valor de la tabla

        auxiliar.cadValorU.cadena = yytext;
        insercion(tablaCadenas, auxiliar);
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_CARACTER:
        tk.valToken.valT = 8;
        tk.valToken.infoToken.valCaracter = *yytext; //asignar indice
        
        //auxiliar.carValorU.valor = 8;
        //auxiliar.cadValorU.cadena = yytext;
        //insercion(tablaCaracteres, auxiliar); no hay insercion ya que no existe tabla de este tipo 
        insercion(tablaTokens, tk);
        break;

    case CONSTANTE_NUMERICA_REAL:
        tk.valToken.valT = CONSTANTE_NUMERICA_REAL;
        tk.valToken.infoToken.valEntero = contadoresTNumReal; //asignar indice
        
        auxiliar.realValorU.valor = contadoresTNumReal;
        contadoresTNumReal++;
        auxiliar.realValorU.cadena = yytext;
        insercion(tablaConstantesReales, auxiliar);
        insercion(tablaTokens, tk);
        break;

    default:
        break;
    }
}

main (int argc, char * argv[])
{

    nodoL *tablaTokens = NULL;
    nodoL *tablaIdentificadores = NULL;
    nodoL *tablaConstantesEnteras = NULL;
    nodoL *tablaCadenas = NULL;
    //nodoL *tablaCaracteres = NULL;
    nodoL *tablaConstantesReales = NULL;


int res;
yyin = fopen(argv[1],"r");
//archSal = fopen("salida.txt","w");
res = yylex();

//fclose(archSal);
while (res)
{
    crearInformacion(res,&tablaTokens,&tablaIdentificadores,&tablaConstantesEnteras,&tablaCadenas,&tablaConstantesReales);
    res = yylex();
}
printf("Llegue a este punto");
imprimeContenido(tablaIdentificadores, 0);

    //Pruebas
    nodoL *comienzo = NULL;
    union datos prueba1;
    consCar pruebas1 = {1,'a'};
    prueba1.carValorU = pruebas1;
    union datos prueba2;
    consCar prubas2 = {2,'b'};
    prueba2.carValorU = prubas2;

    union datos prueba3;
    consCar prubas3 = {3,'c'};
    prueba3.carValorU = prubas3;

    union datos prueba4;
    consCar prubas4 = {4,'d'};
    prueba4.carValorU = prubas4;

    insercion(&comienzo, prueba1);
    insercion(&comienzo, prueba2);
    insercion(&comienzo, prueba3);
    insercion(&comienzo, prueba4);
    char resultado = comienzo->datoU.carValorU.valor;
    
    //borrar(&comienzo);
    //free(comienzo);
    
    return 0;
}