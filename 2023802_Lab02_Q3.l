%option noyywrap noinput nounput
%{
#include <stdio.h>
%}

%%
[ \t\r\n\f\v]+                  ;
"//"[^\n]*                      ;
"/*"([^*]|\*+[^*/])*\*+"/"    ;
\"([^\"\\\n]|\\.)*\"          { printf("<STRING>"); }
\'([^\'\\\n]|\\.)*\'          { printf("<CHAR_LITERAL>"); }
"auto"                            { printf("<AUTO>"); }
"break"                           { printf("<BREAK>"); }
"case"                            { printf("<CASE>"); }
"char"                            { printf("<CHAR>"); }
"const"                           { printf("<CONST>"); }
"continue"                        { printf("<CONTINUE>"); }
"default"                         { printf("<DEFAULT>"); }
"do"                              { printf("<DO>"); }
"double"                          { printf("<DOUBLE>"); }
"else"                            { printf("<ELSE>"); }
"enum"                            { printf("<ENUM>"); }
"extern"                          { printf("<EXTERN>"); }
"float"                           { printf("<FLOAT>"); }
"for"                             { printf("<FOR>"); }
"goto"                            { printf("<GOTO>"); }
"if"                              { printf("<IF>"); }
"int"                             { printf("<INT>"); }
"long"                            { printf("<LONG>"); }
"register"                        { printf("<REGISTER>"); }
"return"                          { printf("<RETURN>"); }
"short"                           { printf("<SHORT>"); }
"signed"                          { printf("<SIGNED>"); }
"sizeof"                          { printf("<SIZEOF>"); }
"static"                          { printf("<STATIC>"); }
"struct"                          { printf("<STRUCT>"); }
"switch"                          { printf("<SWITCH>"); }
"typedef"                         { printf("<TYPEDEF>"); }
"union"                           { printf("<UNION>"); }
"unsigned"                        { printf("<UNSIGNED>"); }
"void"                            { printf("<VOID>"); }
"volatile"                        { printf("<VOLATILE>"); }
"while"                           { printf("<WHILE>"); }
[a-zA-Z_][a-zA-Z0-9_]*           { printf("<ID>"); }
([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)? { printf("<NUM>"); }
"<<="                             { printf("<LSHIFT_ASSIGN>"); }
">>="                             { printf("<RSHIFT_ASSIGN>"); }
"..."                             { printf("<ELLIPSIS>"); }
"++"                              { printf("<INC>"); }
"--"                              { printf("<DEC>"); }
"=="                              { printf("<EQ>"); }
"!="                              { printf("<NE>"); }
"<="                              { printf("<LE>"); }
">="                              { printf("<GE>"); }
"&&"                              { printf("<AND>"); }
"||"                              { printf("<OR>"); }
"+="                              { printf("<PLUS_ASSIGN>"); }
"-="                              { printf("<MINUS_ASSIGN>"); }
"*="                              { printf("<MUL_ASSIGN>"); }
"/="                              { printf("<DIV_ASSIGN>"); }
"%="                              { printf("<MOD_ASSIGN>"); }
"<<"                              { printf("<LSHIFT>"); }
">>"                              { printf("<RSHIFT>"); }
"&="                              { printf("<AND_ASSIGN>"); }
"|="                              { printf("<OR_ASSIGN>"); }
"^="                              { printf("<XOR_ASSIGN>"); }
"->"                              { printf("<ARROW>"); }
"("                               { printf("<LPAREN>"); }
")"                               { printf("<RPAREN>"); }
"{"                               { printf("<LBRACE>"); }
"}"                               { printf("<RBRACE>"); }
"["                               { printf("<LBRACKET>"); }
"]"                               { printf("<RBRACKET>"); }
";"                               { printf("<SEMICOLON>"); }
","                               { printf("<COMMA>"); }
"+"                               { printf("<PLUS>"); }
"-"                               { printf("<MINUS>"); }
"*"                               { printf("<MUL>"); }
"/"                               { printf("<DIV>"); }
"%"                               { printf("<MOD>"); }
"="                               { printf("<ASSIGN>"); }
"<"                               { printf("<LT>"); }
">"                               { printf("<GT>"); }
"!"                               { printf("<NOT>"); }
"&"                               { printf("<BITAND>"); }
"|"                               { printf("<BITOR>"); }
"^"                               { printf("<BITXOR>"); }
"~"                               { printf("<BITNOT>"); }
"?"                               { printf("<QUESTION>"); }
":"                               { printf("<COLON>"); }
"."                               { printf("<DOT>"); }
"#"                               { printf("<HASH>"); }
.                                 { printf("<UNKNOWN>"); }

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
    printf("\n");
    fclose(yyin);
    return 0;
}
