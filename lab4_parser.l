%option noyywrap
%{
#include <cstdlib>
#include <cstdio>
#include <string>
#include <iostream>
#include "symtab.h"

using namespace std;

// Forward declarations
void program();
void block();
void decls();
void decl();
void stmts();
void stmt();
void expr();
void expr_prime();
void term();
void term_prime();
void factor();
void match(int terminal);
void error();

// Global symbol table pointer for current scope
sym_tab* top = NULL;
int lookahead;
int line = 1;
int scope_depth = 0;
bool has_semantic_error = false;

// Token definitions
const int T_TYPE = 350;
const int T_ID   = 351;
const int T_NUM  = 352;
%}

letter      [A-Za-z_]
digit       [0-9]
id          {letter}({letter}|{digit})*
num         {digit}+(\.{digit}+)?

%%

[ \t\r]+    ; /* Ignore whitespace */
\n          { line++; }
int|float|bool|char { return T_TYPE; }
{id}        { return T_ID; }
{num}       { return T_NUM; }
.           { return *yytext; }

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
        cout << "Reading input from stdin...\n";
    }

    // Read first token
    lookahead = yylex();
    program();

    // Check for trailing unexpected input
    if (lookahead != 0) {
        error();
    }

    if (has_semantic_error) {
        cerr << "\n>>> Parsing completed with SEMANTIC ERROR(S). <<<\n";
        return 1;
    } else {
        cout << "\n>>> Parsing and translation completed SUCCESSFULLY. <<<\n";
        return 0;
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
    cerr << "Syntax error on line " << line;
    if (yytext && yytext[0] != '\0') {
        cerr << " near token '" << yytext << "'";
    }
    cerr << "\n";
    exit(1);
}

void program()
{
    top = NULL;
    scope_depth = 0;
    block();
}

void block()
{
    match('{');
    // Push new symbol table for nested scope
    sym_tab* saved = top;
    top = new sym_tab(top);
    scope_depth++;

    cout << "{\n";
    decls();
    stmts();

    match('}');
    // Pop symbol table and restore enclosing scope
    delete top;
    top = saved;
    scope_depth--;

    cout << "}\n";
}

void decls()
{
    if (lookahead == T_TYPE) {
        decl();
        decls();
    }
}

void decl()
{
    if (lookahead == T_TYPE) {
        string type(yytext);
        match(T_TYPE);

        if (lookahead != T_ID) {
            cerr << "Syntax error on line " << line << ": expected identifier after type '" << type << "'\n";
            exit(1);
        }

        string id(yytext);
        match(T_ID);
        match(';');

        sym_ent* s = new sym_ent(type, line);
        if (!top->put(id, s)) {
            cerr << "Semantic Error on line " << line << ": Multiple declarations of variable '" 
                 << id << "' in the same scope.\n";
            has_semantic_error = true;
            delete s;
        } else {
            cout << "  [DECL] " << id << " : " << type << " (scope level " << scope_depth << ")\n";
        }
    } else {
        error();
    }
}

void stmts()
{
    if (lookahead == '{' || lookahead == T_ID) {
        stmt();
        stmts();
    }
}

void stmt()
{
    switch (lookahead) {
        case '{':
            block();
            break;

        case T_ID: {
            string target(yytext);
            match(T_ID);

            sym_ent* s = top->get(target);
            if (!s) {
                cerr << "Semantic Error on line " << line << ": Undeclared variable '" 
                     << target << "' used as assignment target.\n";
                has_semantic_error = true;
                cout << target << ":<undeclared> = ";
            } else {
                cout << target << ":" << s->type << " = ";
            }

            match('=');
            expr();
            match(';');
            cout << ";\n";
            break;
        }

        default:
            error();
    }
}

void expr()
{
    term();
    expr_prime();
}

void expr_prime()
{
    if (lookahead == '+') {
        match('+');
        cout << " + ";
        term();
        expr_prime();
    } else if (lookahead == '-') {
        match('-');
        cout << " - ";
        term();
        expr_prime();
    }
}

void term()
{
    factor();
    term_prime();
}

void term_prime()
{
    if (lookahead == '*') {
        match('*');
        cout << " * ";
        factor();
        term_prime();
    } else if (lookahead == '/') {
        match('/');
        cout << " / ";
        factor();
        term_prime();
    }
}

void factor()
{
    switch (lookahead) {
        case T_ID: {
            string id(yytext);
            match(T_ID);
            sym_ent* s = top->get(id);
            if (!s) {
                cerr << "Semantic Error on line " << line << ": Undeclared variable '" 
                     << id << "' referenced in expression.\n";
                has_semantic_error = true;
                cout << id << ":<undeclared>";
            } else {
                cout << id << ":" << s->type;
            }
            break;
        }

        case T_NUM: {
            string num_val(yytext);
            match(T_NUM);
            cout << num_val;
            break;
        }

        case '(':
            match('(');
            cout << "(";
            expr();
            match(')');
            cout << ")";
            break;

        default:
            error();
    }
}




need help with my compiler lab exam prep. will send u question and u need to give code for that as well as all the relevant files including .txt file if any
Write a parser for statements of the form id = expr;. Examples of valid input are a=a+b*c;,
a=3*b; The grammar for this is the following.
stmt æid = expr ;
expr æexpr + term
|term
term æterm * f actor
|f actor
f actor æ id
| num
| (expr)
Here id and num are the tokens for identifiers and numerals respectively. You need to extend
the lexical analyzer to return these tokens. As it stands the grammar is left-recursive, so you
need to rewrite the grammar to remove left recursion. As before the parser should output
"syntax error" if the input is invalid.
