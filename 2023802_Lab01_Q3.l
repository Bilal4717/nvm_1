%option noyywrap noinput nounput
%{
#include <stdio.h>

long characters = 0, words = 0, lines = 0;
int last = '\n';
%}

%%
\n {
    characters++;
    lines++;
    last = '\n';
}
[ \t\r\f\v]+ {
    characters += yyleng;
    last = yytext[yyleng - 1];
}
[^ \t\r\f\v\n]+ {
    characters += yyleng;
    words++;
    last = yytext[yyleng - 1];
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
    if (characters > 0 && last != '\n')
        lines++;
    printf("Characters: %ld\nWords: %ld\nLines: %ld\n", characters, words, lines);
    fclose(yyin);
    return 0;
}
