%option noyywrap yylineno noinput nounput
%{
#include <stdio.h>
#include <string.h>

char names[1000][256];
int count = 0;
int i, found;
%}

%%
"//"[^\n]*                         ;
"/*"([^*]|\*+[^*/])*\*+"/"       ;
\"([^\"\\\n]|\\.)*\"             ;
\'([^\'\\\n]|\\.)*\'             ;
[0-9][a-zA-Z0-9_.]*               ;
[a-zA-Z_$][a-zA-Z0-9_$]* {
    found = 0;
    for (i = 0; i < count; i++) {
        if (strcmp(names[i], yytext) == 0)
            found = 1;
    }
    if (!found) {
        if (count == 1000 || yyleng > 255) {
            fprintf(stderr, "Too many identifiers or identifier too long.\n");
            return 1;
        }
        strcpy(names[count], yytext);
        count++;
        printf("%s\t%d\n", yytext, yylineno);
    }
}
\n                               ;
.                                ;

%%
int main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror(argv[1]);
        return 1;
    }
    printf("Identifier\tFirst line\n");
    if (yylex() != 0) {
        fclose(yyin);
        return 1;
    }
    fclose(yyin);
    return 0;
}
