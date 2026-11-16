%option noyywrap noinput nounput
%{
#include <stdio.h>
#include <string.h>

int allow_negative = 1;
%}

%%
"//"[^\n]*                         ;
"/*"([^*]|\*+[^*/])*\*+"/"       ;
\"([^\"\\\n]|\\.)*\"             { allow_negative = 0; }
\'([^\'\\\n]|\\.)*\'             { allow_negative = 0; }
"return"                         { allow_negative = 1; }
[a-zA-Z_$][a-zA-Z0-9_$]*          { allow_negative = 0; }
-?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)? {
    /* After a value, the minus is subtraction rather than a sign. */
    if (yytext[0] == '-' && !allow_negative)
        printf("%s\n", yytext + 1);
    else
        printf("%s\n", yytext);
    allow_negative = 0;
}
[ \t\r\n\f\v]+                   ;
"++"|"--"                        ;
. {
    allow_negative = strchr("=(:,[{!~?;+*/%<>|&^-", yytext[0]) != NULL;
}

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
    yylex();
    fclose(yyin);
    return 0;
}
