%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>

#define T_ID  1
#define T_NUM 2

int lookahead;

int yylex(void);

void stmt(void);
void expr(void);
void exprPrime(void);
void term(void);
void termPrime(void);
void factor(void);

void match(int terminal);
void error(void);
%}

%%

[ \t\r\n]+                  ; /* Skip whitespace */

[A-Za-z_][A-Za-z0-9_]*      { return T_ID; }

[0-9]+                      { return T_NUM; }

"="                         { return '='; }
"+"                         { return '+'; }
"*"                         { return '*'; }
";"                         { return ';'; }
"("                         { return '('; }
")"                         { return ')'; }

.                           { return yytext[0]; }

%%

// Match the current lookahead token with expected terminal
void match(int terminal)
{
    if (lookahead == terminal)
    {
        lookahead = yylex();
    }
    else
    {
        error();
    }
}

// Print error message and terminate
void error(void)
{
    printf("syntax error\n");
    exit(1);
}

// stmt -> id = expr ;
void stmt(void)
{
    match(T_ID);
    match('=');
    expr();
    match(';');
}

// expr -> term expr'
void expr(void)
{
    term();
    exprPrime();
}

// expr' -> + term expr' | epsilon
void exprPrime(void)
{
    if (lookahead == '+')
    {
        match('+');
        term();
        exprPrime();
    }
}

// term -> factor term'
void term(void)
{
    factor();
    termPrime();
}

// term' -> * factor term' | epsilon
void termPrime(void)
{
    if (lookahead == '*')
    {
        match('*');
        factor();
        termPrime();
    }
}

// factor -> id | num | ( expr )
void factor(void)
{
    if (lookahead == T_ID)
    {
        match(T_ID);
    }
    else if (lookahead == T_NUM)
    {
        match(T_NUM);
    }
    else if (lookahead == '(')
    {
        match('(');
        expr();
        match(')');
    }
    else
    {
        error();
    }
}

int main(int argc, char *argv[])
{
    FILE *fp;

    if (argc < 2)
    {
        printf("Usage: Lab3_Task1.exe <input_file>\n");
        return 1;
    }

    fp = fopen(argv[1], "r");
    if (fp == NULL)
    {
        printf("Error opening file: %s\n", argv[1]);
        return 1;
    }

    yyin = fp;

    // Fetch initial lookahead token
    lookahead = yylex();

    // Begin parsing
    stmt();

    // Verify no extraneous unparsed input remains
    if (lookahead != 0)
    {
        error();
    }

    printf("Valid syntax\n");

    fclose(fp);
    return 0;
}
