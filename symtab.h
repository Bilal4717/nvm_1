#ifndef SYMTAB_H
#define SYMTAB_H

#include <iostream>
#include <string>
#include <map>

using namespace std;

// Symbol table entry
struct sym_ent {
    string type;
    int decl_line;

    sym_ent(string t = "", int l = 0) : type(t), decl_line(l) {}
};

// Symbol table class supporting chained scopes (linked list of symbol tables)
class sym_tab {
public:
    map<string, sym_ent*> table;
    sym_tab* prev;

    sym_tab(sym_tab* p) {
        prev = p;
    }

    sym_tab* get_prev() {
        return prev;
    }

    // Insert a new symbol in the CURRENT scope.
    // Returns true on success, false if the symbol already exists in this scope.
    bool put(string s, sym_ent* sym) {
        if (table.count(s) == 0) {
            table[s] = sym;
            return true;
        }
        return false;
    }

    // Lookup a symbol starting from current scope and traversing outwards through parent scopes.
    sym_ent* get(string s) {
        for (sym_tab* i = this; i != NULL; i = i->prev) {
            if (i->table.count(s) > 0)
                return i->table[s];
        }
        return NULL;
    }

    // Check if symbol exists ONLY in the current local scope
    bool exists_in_current_scope(string s) {
        return table.count(s) > 0;
    }

    // Destructor to clean up dynamically allocated symbol entries
    ~sym_tab() {
        for (map<string, sym_ent*>::iterator x = table.begin(); x != table.end(); ++x) {
            delete (*x).second;
        }
    }
};

#endif // SYMTAB_H

