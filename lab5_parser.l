%option noyywrap
%{
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include "ast.h"

using namespace std;

// Define token constants
const int T_IF    = 310;
const int T_WHILE = 311;
const int T_DO    = 312;
const int T_ID    = 350;
const int T_NUM   = 360;

// Global lookahead token and line counter
int lookahead;
int line = 1;

// Function prototypes
void match(int terminal);
void error();
ast::stmt* program();
ast::stmt* block();
ast::stmt* stmts();
ast::stmt* stmt();
ast::expr* expr();
ast::expr* rp();
ast::expr* rel();
ast::expr* factor();
%}

alpha     [a-zA-Z_]
alphanum  [0-9a-zA-Z_]
digit     [0-9]

%%

[ \t\r]+                    ; /* Ignore whitespace */
\n                          { line++; }
if                          { return T_IF; }
while                       { return T_WHILE; }
do                          { return T_DO; }
{alpha}{alphanum}*          { return T_ID; }
{digit}+                    { return T_NUM; }
.                           { return *yytext; }

%%

int main(int argc, char* argv[])
{
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            cerr << "Error: Could not open input file '" << argv[1] << "'\n";
            return 1;
        }
    } else {
        cout << "Reading input from standard input...\n";
    }

    // Read initial token
    lookahead = yylex();

    // Parse syntax tree
    ast::stmt* s = program();

    // Check for trailing unexpected input
    if (lookahead != 0) {
        error();
    }

    // Generate intermediate code
    cout << "=== Intermediate Code (Three-Address Code) ===\n";
    if (s) {
        s->gen();
    }
    cout << "===============================================\n";

    return 0;
}

ast::stmt* program()
{
    return block();
}

ast::stmt* block()
{
    if (lookahead == '{') {
        match('{');
        ast::stmt* s = stmts();
        match('}');
        return s;
    } else {
        error();
        return NULL;
    }
}

ast::stmt* stmts()
{
    switch (lookahead) {
        case T_ID:
        case T_NUM:
        case T_IF:
        case T_WHILE:
        case T_DO:
        case '{': {
            ast::stmt* l = stmt();
            ast::stmt* r = stmts();
            return new ast::seq(l, r);
        }

        case '}':
        case 0:
            return NULL;

        default:
            error();
            return NULL;
    }
}

ast::stmt* stmt()
{
    ast::expr* e;
    ast::stmt* s;

    switch (lookahead) {
        case T_ID:
        case T_NUM:
            e = expr();
            match(';');
            return new ast::eval(e);

        case T_IF:
            match(T_IF);
            match('(');
            e = expr();
            match(')');
            s = stmt();
            return new ast::if_stmt(e, s);

        case T_WHILE:
            match(T_WHILE);
            match('(');
            e = expr();
            match(')');
            s = stmt();
            return new ast::while_stmt(e, s);

        case T_DO:
            match(T_DO);
            s = stmt();
            match(T_WHILE);
            match('(');
            e = expr();
            match(')');
            match(';');
            return new ast::do_while_stmt(s, e);

        case '{':
            s = block();
            return s;

        default:
            error();
            return NULL;
    }
}

// expr -> rel rp
ast::expr* expr()
{
    ast::expr* left;
    ast::expr* right;

    switch (lookahead) {
        case T_ID:
        case T_NUM:
            left = rel();
            right = rp();
            if (right == NULL) {
                return left;
            } else {
                return new ast::assign(left, right);
            }

        default:
            error();
            return NULL;
    }
}

// rp -> = expr | epsilon
// FOLLOW(rp) is ')', ';'
ast::expr* rp()
{
    switch (lookahead) {
        case '=': {
            match('=');
            ast::expr* e = expr();
            return e;
        }

        case ')':
        case ';':
            return NULL;

        default:
            error();
            return NULL;
    }
}

ast::expr* rel()
{
    return factor();
}

ast::expr* factor()
{
    switch (lookahead) {
        case T_ID: {
            string name(yytext);
            match(T_ID);
            return new ast::id(name);
        }

        case T_NUM: {
            int val = atoi(yytext);
            match(T_NUM);
            return new ast::num(val);
        }

        default:
            error();
            return NULL;
    }
}

void match(int terminal)
{
    if (lookahead == terminal) {
        lookahead = yylex();
    } else {
        error();
    }
}

void error()
{
    cerr << "syntax error on line " << line;
    if (yytext && yytext[0] != '\0') {
        cerr << " near token '" << yytext << "'";
    }
    cerr << "\n";
    exit(1);
}

