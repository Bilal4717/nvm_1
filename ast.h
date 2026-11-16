#ifndef AST_H
#define AST_H

#include <string>
#include <iostream>
#include <cstdlib>
#include <sstream>

using namespace std;

namespace ast {

static int t_idx = 0;
static int l_idx = 0;

inline string temp() {
    stringstream ss;
    ss << ".t" << t_idx++;
    return ss.str();
}

inline string label() {
    stringstream ss;
    ss << ".L" << l_idx++;
    return ss.str();
}

// Base AST Node
class node {
public:
    virtual ~node() {}
};

// Base Statement Node
class stmt : public node {
public:
    virtual void gen() = 0;
};

// Base Expression Node
class expr : public node {
public:
    virtual expr* lvalue() {
        cerr << "Error: invalid lvalue\n";
        exit(1);
    }
    virtual expr* rvalue() {
        return this;
    }
    virtual string str() {
        return "Not implemented";
    }
};

// Identifier Expression Node
class id : public expr {
public:
    string lexeme;
    id(string name) : lexeme(name) {}
    expr* lvalue() {
        return this;
    }
    string str() {
        return lexeme;
    }
};

// Numeric Constant Expression Node
class num : public expr {
public:
    int value;
    num(int n) : value(n) {}
    string str() {
        stringstream t;
        t << value;
        return t.str();
    }
};

// Assignment Expression Node (left = right)
class assign : public expr {
public:
    expr *left, *right;
    assign(expr* l, expr* r) : left(l), right(r) {}
    expr* rvalue() {
        expr* l = left->lvalue();
        expr* r = right->rvalue();
        cout << l->str() << "=" << r->str() << "\n";
        return r;
    }
};

// Expression Statement (evaluating an expression, e.g. expr;)
class eval : public stmt {
public:
    expr* left;
    eval(expr* e) : left(e) {}
    void gen() {
        if (left) left->rvalue();
    }
};

// Statement Sequence Node (stmts -> stmt stmts)
class seq : public stmt {
public:
    stmt *left, *right;
    seq(stmt* l, stmt* r) : left(l), right(r) {}
    void gen() {
        if (left) left->gen();
        if (right) right->gen();
    }
};

// If Statement Node: if (left) right
class if_stmt : public stmt {
public:
    expr *left;
    stmt *right;
    string l;
    if_stmt(expr* e, stmt* s) : left(e), right(s) {
        l = label();
    }
    void gen() {
        expr* e = left->rvalue();
        cout << "ifFalse " << e->str() << " goto " << l << "\n";
        if (right) right->gen();
        cout << l << ":\n";
    }
};

// While Loop Node: while (cond) body
// Intermediate code translation pattern:
//   .L_start:
//     ifFalse <cond> goto .L_exit
//     <body>
//     goto .L_start
//   .L_exit:
class while_stmt : public stmt {
public:
    expr *cond;
    stmt *body;
    string l_start;
    string l_exit;

    while_stmt(expr* c, stmt* b) : cond(c), body(b) {
        l_start = label();
        l_exit = label();
    }

    void gen() {
        cout << l_start << ":\n";
        expr* e = cond->rvalue();
        cout << "ifFalse " << e->str() << " goto " << l_exit << "\n";
        if (body) body->gen();
        cout << "goto " << l_start << "\n";
        cout << l_exit << ":\n";
    }
};

// Do-While Loop Node: do body while (cond);
// Intermediate code translation pattern:
//   .L_start:
//     <body>
//     if <cond> goto .L_start
class do_while_stmt : public stmt {
public:
    stmt *body;
    expr *cond;
    string l_start;

    do_while_stmt(stmt* b, expr* c) : body(b), cond(c) {
        l_start = label();
    }

    void gen() {
        cout << l_start << ":\n";
        if (body) body->gen();
        expr* e = cond->rvalue();
        cout << "if " << e->str() << " goto " << l_start << "\n";
    }
};

} // namespace ast

#endif // AST_H

