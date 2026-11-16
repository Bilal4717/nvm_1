%option noyywrap yylineno noinput nounput
%{
#include <stdio.h>
#include <string.h>

char names[1000][256];
int count = 0;
int i, found;

int java_source = 0;

int save_identifier(void)
{
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
    return 0;
}
%}

%%
"//"[^\n]*                         ;
"/*"([^*]|\*+[^*/])*\*+"/"       ;
\"([^\"\\\n]|\\.)*\"             ;
\'([^\'\\\n]|\\.)*\'             ;
[0-9][a-zA-Z0-9_.]*               ;
"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"float"|"for"|"goto"|"if"|"int"|"long"|"return"|"short"|"static"|"switch"|"void"|"volatile"|"while" ;
"auto"|"extern"|"register"|"signed"|"sizeof"|"struct"|"typedef"|"union"|"unsigned" { if (java_source && save_identifier()) return 1; }
"abstract"|"assert"|"boolean"|"byte"|"catch"|"class"|"extends"|"false"|"final"|"finally"|"implements"|"import"|"instanceof"|"interface"|"native"|"new"|"null"|"package"|"private"|"protected"|"public"|"strictfp"|"super"|"synchronized"|"this"|"throw"|"throws"|"transient"|"true"|"try" { if (!java_source && save_identifier()) return 1; }
[a-zA-Z_$][a-zA-Z0-9_$]* { if (save_identifier()) return 1; }

\n                               ;
.                                ;

%%
int main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 1;
    }
    /* .java selects Java keywords; other filenames use C keywords. */
    if (strrchr(argv[1], '.') != NULL &&
        strcmp(strrchr(argv[1], '.'), ".java") == 0)
        java_source = 1;
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
