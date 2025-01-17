---
author:
- William E. Byrd
date: 2025-01-17
title: |
  Relational Interpreters in miniKanren\
   \
  (WORKING ROUGH DRAFT --- DRAFT 0)
---

 2024 William E. Byrd

This work is licensed under a Creative Commons Attribution 4.0
International License. (CC BY 4.0)\
<http://creativecommons.org/licenses/by/4.0/>

 \
 \
To Dan Friedman

# Preface

The intent of this book is to share the techniques, knowledge, pitfalls,
open problems, promising-looking future work/techniques, and literature
of writing interpreters as relations in miniKanren. Someone who reads
this book actively should be ready to understand, implement, modify, and
improve interpreters wtitten as miniKanren relations, read the related
literature, and perform original research on the topic.

## What this book is about

This book is about writing interpreters for programming languages,
especially for subsets of Scheme. While there are many books on writing
interpreters, this book is unusual in that it explores how to write
interpreters as *relations* in the miniKanren relational programming
language. By writing interpreters as relations, and by using the
implicit constraint solving and search in the `faster-miniKanren`
implementation, we can use the flexibility of relational programming to
allow us to experiment with programs in the language being interpreted.
For example, a relational interpreter can interpret a program with
missing subexpressions[^1], or *holes*, attempting to fill in the
missing subexpressions with values that result in valid programs in the
language being interpreted. Or we can give both a program containing
holes and the value we expect the program to produce when interpreted,
and let `faster-miniKanren` try to fill in the holes in a way to produce
the expected output. We can even write an interpreter that explicitly
handles errors, and ask `faster-miniKanren` to find inputs to the
program that trigger these errors.[^2]

## What you need to know to read this book

This book assumes you are familiar with the basics of Scheme or Racket,
and are comfortable with the ideas of functionals programming. The book
also assumes you understand the notions of evaluation order of
expressions, lexical scope, environments, environment-passing
interpreters.

\[TODO add topics that the reader should know, including Scheme,
miniKanren, lexical scope, environment-passing interpreters, etc\]

\[TODO add pointers to resources\]

## Running the code in this book

The code in this book was tested with Chez Scheme and Racket. It should
be possible to run most code in other Scheme implementations, with few
or no changes, with the exception of code that makes extensive use of
Chez-specific or Racket-specific features, which I will point out in
those chapters, as appropriate.

### Getting `pmatch` from GitHub

### Getting `faster-miniKanren` from GitHub

<https://github.com/michaelballantyne/faster-miniKanren>

`git``\ `{=latex}`clone``\ `{=latex}`git@github.com:michaelballantyne/faster-minikanren.git`

Alternatively, you can click on `<> Code` button and select
`Download ZIP` to download and uncompress the `.zip` file containing the
entire `faster-miniKanren` directory.

### Using this book with Chez Scheme

#### Installing Chez Scheme

#### Starting a Chez Scheme REPL

#### Loading a file in Chez Scheme

#### Loading `faster-miniKanren` in Chez Scheme

### Using this book with Racket

#### Installing Racket

<https://racket-lang.org/>

<https://download.racket-lang.org/>

#### Important differences between Chez Scheme and Racket

representation of quoted values

evaluation order

language levels

macros

#### The DrRacket IDE and the Racket REPL

#### Starting and configuring DrRacket

changing default language

changing default memory limit

#### Starting a Racket REPL

#### Requiring a module in Racket

#### Requiring the `faster-miniKanren` module in Racket

## Acknowledgements

Dan Friedman and Michael Ballantyne both encouraged me to continue
working on this book, and independently encouraged me to break down one
giant book into more than one book, each book being more manageable.
Both Dan and Michael encouraged me to avoid getting bogged down with a
lot of introductory material, which had caused me to abandon previous
writing efforts. Michael also encouraged me to continue working on the
book in the open.

Darius Bacon wrote me a very helpful email about how using two separate
lists to represent a lexical environment, rather than a single
association list, can result in better performance and divergence
behavior. I had played around with this representation in the past, but
had abandoned it before I understood its advantages. Thank you, Darius.

My mother has continually encouraged me to work on this book, and most
importantly, to finish it!

\[TODO add other acknowledgements\]

\[TODO add acks for typesetting tech, such as the fonts; also can add
colophon if I'm so inclined\]

# A simple environment-passing Scheme interpreter in Scheme

call-by-value (CBV) $\lambda$-calculus (variable reference,
single-argument $lambda$, and procedure application), plus `quote` and
`list`

association-list representation of the environment

empty initial environment

`list` is implemented as if it were a special form rather than as a
variable bound, in a non-empty initial environment, to a procedure. As a
result, although `list` can be shadowed, `(list list)` results in an
error that there is an attempt to reference an unbound variable `list`.

tagged list to represent closure

grammar for the language we are interpreting

`(load``\ `{=latex}`"pmatch.scm")`

\[TODO make sure I explain MIT vs Indiana syntax for `define`\]

`(define``\ `{=latex}`(eval``\ `{=latex}`expr)`\
`(eval-expr``\ `{=latex}`expr``\ `{=latex}`’()))`

`(define``\ `{=latex}`(eval-expr``\ `{=latex}`expr``\ `{=latex}`env)`\
`(pmatch``\ `{=latex}`expr`\
`((quote``\ `{=latex}`,v)`\
`(guard``\ `{=latex}`(not-in-env?``\ `{=latex}`’quote``\ `{=latex}`env))`\
`v)`\
`((list``\ `{=latex}`.``\ `{=latex}`,e*)`\
`(guard``\ `{=latex}`(not-in-env?``\ `{=latex}`’list``\ `{=latex}`env))`\
`(eval-list``\ `{=latex}`e*``\ `{=latex}`env))`\
`(,x`\
`(guard``\ `{=latex}`(symbolo?``\ `{=latex}`x))`\
`(lookup``\ `{=latex}`x``\ `{=latex}`env))`\
`((,rator``\ `{=latex}`,rand)`\
`(let``\ `{=latex}`((a``\ `{=latex}`(eval-expr``\ `{=latex}`rand``\ `{=latex}`env)))`\
`(pmatch``\ `{=latex}`(eval-expr``\ `{=latex}`rator``\ `{=latex}`env)`\
`((closure``\ `{=latex}`,x``\ `{=latex}`,body``\ `{=latex}`,env^)`\
`(guard``\ `{=latex}`(symbol?``\ `{=latex}`x))`\
`(eval-expr``\ `{=latex}`body``\ `{=latex}`‘((,x``\ `{=latex}`.``\ `{=latex}`,a)``\ `{=latex}`.``\ `{=latex}`,env^))))))`\
`((lambda``\ `{=latex}`(,x)``\ `{=latex}`,body)`\
`(guard``\ `{=latex}`(and``\ `{=latex}`(symbol?``\ `{=latex}`x)`\
`(not-in-env?``\ `{=latex}`’lambda``\ `{=latex}`env)))`\
`‘(closure``\ `{=latex}`,x``\ `{=latex}`,body``\ `{=latex}`,env))))`

`(define``\ `{=latex}`(not-in-env?``\ `{=latex}`x``\ `{=latex}`env)`\
`(pmatch``\ `{=latex}`env`\
`(((,y``\ `{=latex}`.``\ `{=latex}`,v)``\ `{=latex}`.``\ `{=latex}`,env^)`\
`(if``\ `{=latex}`(equal?``\ `{=latex}`y``\ `{=latex}`x)``\ `{=latex}`;;``\ `{=latex}`TODO``\ `{=latex}`eq?``\ `{=latex}`vs``\ `{=latex}`eqv?``\ `{=latex}`vs``\ `{=latex}`equal?,``\ `{=latex}`with``\ `{=latex}`equal?``\ `{=latex}`being``\ `{=latex}`semantically``\ `{=latex}`closest``\ `{=latex}`to``\ `{=latex}`==`\
`#f`\
`(not-in-env?``\ `{=latex}`x``\ `{=latex}`env^)))`\
`(()``\ `{=latex}`#t)))``\ `{=latex}`;;``\ `{=latex}`TODO``\ `{=latex}`empty``\ `{=latex}`env``\ `{=latex}`clause``\ `{=latex}`comes``\ `{=latex}`second;``\ `{=latex}`Dijkstra``\ `{=latex}`guard,``\ `{=latex}`and``\ `{=latex}`all``\ `{=latex}`that`

`(define``\ `{=latex}`(eval-list``\ `{=latex}`expr``\ `{=latex}`env)`\
`(pmatch``\ `{=latex}`expr`\
`(()``\ `{=latex}`’())`\
`((,a``\ `{=latex}`.``\ `{=latex}`,d)`\
`(let``\ `{=latex}`((t-a``\ `{=latex}`(eval-expr``\ `{=latex}`a``\ `{=latex}`env))`\
`(t-d``\ `{=latex}`(eval-list``\ `{=latex}`d``\ `{=latex}`env)))`\
`‘(,t-a``\ `{=latex}`.``\ `{=latex}`,t-d)))))`

`(define``\ `{=latex}`(lookup``\ `{=latex}`x``\ `{=latex}`env)`\
`(pmatch``\ `{=latex}`env`\
`(()``\ `{=latex}`(error``\ `{=latex}`’lookup``\ `{=latex}`"unbound``\ `{=latex}`variable"))``\ `{=latex}`;;``\ `{=latex}`TODO``\ `{=latex}`make``\ `{=latex}`sure``\ `{=latex}`error``\ `{=latex}`is``\ `{=latex}`introduced,``\ `{=latex}`and``\ `{=latex}`make``\ `{=latex}`error``\ `{=latex}`message``\ `{=latex}`nicer`\
`(((,y``\ `{=latex}`.``\ `{=latex}`,v)``\ `{=latex}`.``\ `{=latex}`,env^)`\
`(if``\ `{=latex}`(equal?``\ `{=latex}`y``\ `{=latex}`x)`\
`v`\
`(lookup``\ `{=latex}`x``\ `{=latex}`env^)))))`

# Rewriting the simple environment-passing Scheme interpreter in miniKanren

In this chapter we will translate the evaluator for the simple
environment-passing interpreter from the previous chapter from a Scheme
function to a miniKanren relation.

\[TODO cite the code from the Quines interp in faster-miniKanren, and
point to the 2012 SW paper on Quines\]

\[TODO this interp uses defrel---do I want to stick with defrel, or use
define + lambda? Or maybe the book shows both (probably needs to show
both at some point)\]

`(load``\ `{=latex}`"mk-vicare.scm")`\
`(load``\ `{=latex}`"mk.scm")`

`(defrel``\ `{=latex}`(evalo``\ `{=latex}`expr``\ `{=latex}`val)`\
`(eval-expro``\ `{=latex}`expr``\ `{=latex}`’()``\ `{=latex}`val))`

`(defrel``\ `{=latex}`(eval-expro``\ `{=latex}`expr``\ `{=latex}`env``\ `{=latex}`val)`\
`(conde`\
`((fresh``\ `{=latex}`(v)`\
`(==``\ `{=latex}`‘(quote``\ `{=latex}`,v)``\ `{=latex}`expr)`\
`(not-in-envo``\ `{=latex}`’quote``\ `{=latex}`env)`\
`(absento``\ `{=latex}`’closure``\ `{=latex}`v)``\ `{=latex}`;;``\ `{=latex}`TODO``\ `{=latex}`discuss``\ `{=latex}`the``\ `{=latex}`tradeoffs``\ `{=latex}`of``\ `{=latex}`moving``\ `{=latex}`this``\ `{=latex}`absento``\ `{=latex}`to``\ `{=latex}`evalo`\
`(==``\ `{=latex}`v``\ `{=latex}`val)))`\
`((fresh``\ `{=latex}`(e*)`\
`(==``\ `{=latex}`‘(list``\ `{=latex}`.``\ `{=latex}`,e*)``\ `{=latex}`expr)`\
`(not-in-envo``\ `{=latex}`’list``\ `{=latex}`env)`\
`(absento``\ `{=latex}`’closure``\ `{=latex}`e*)``\ `{=latex}`;;``\ `{=latex}`TODO``\ `{=latex}`is``\ `{=latex}`this``\ `{=latex}`absento``\ `{=latex}`really``\ `{=latex}`needed,``\ `{=latex}`if``\ `{=latex}`we``\ `{=latex}`have``\ `{=latex}`absento``\ `{=latex}`for``\ `{=latex}`quote?`\
`(eval-listo``\ `{=latex}`e*``\ `{=latex}`env``\ `{=latex}`val)))`\
`((symbolo``\ `{=latex}`expr)``\ `{=latex}`(lookupo``\ `{=latex}`expr``\ `{=latex}`env``\ `{=latex}`val))`\
`((fresh``\ `{=latex}`(rator``\ `{=latex}`rand``\ `{=latex}`x``\ `{=latex}`body``\ `{=latex}`env^``\ `{=latex}`a)`\
`(==``\ `{=latex}`‘(,rator``\ `{=latex}`,rand)``\ `{=latex}`expr)`\
`(eval-expro``\ `{=latex}`rator``\ `{=latex}`env``\ `{=latex}`‘(closure``\ `{=latex}`,x``\ `{=latex}`,body``\ `{=latex}`,env^))`\
`(eval-expro``\ `{=latex}`rand``\ `{=latex}`env``\ `{=latex}`a)`\
`(eval-expro``\ `{=latex}`body``\ `{=latex}`‘((,x``\ `{=latex}`.``\ `{=latex}`,a)``\ `{=latex}`.``\ `{=latex}`,env^)``\ `{=latex}`val)))`\
`((fresh``\ `{=latex}`(x``\ `{=latex}`body)`\
`(==``\ `{=latex}`‘(lambda``\ `{=latex}`(,x)``\ `{=latex}`,body)``\ `{=latex}`expr)`\
`(symbolo``\ `{=latex}`x)`\
`(not-in-envo``\ `{=latex}`’lambda``\ `{=latex}`env)`\
`(==``\ `{=latex}`‘(closure``\ `{=latex}`,x``\ `{=latex}`,body``\ `{=latex}`,env)``\ `{=latex}`val)))))`

`(defrel``\ `{=latex}`(not-in-envo``\ `{=latex}`x``\ `{=latex}`env)`\
`(conde`\
`((fresh``\ `{=latex}`(y``\ `{=latex}`v``\ `{=latex}`env^)`\
`(==``\ `{=latex}'`((,y``\ `{=latex}`.``\ `{=latex}`,v)``\ `{=latex}`.``\ `{=latex}`,env^)``\ `{=latex}`env)`\
`(=/=``\ `{=latex}`y``\ `{=latex}`x)`\
`(not-in-envo``\ `{=latex}`x``\ `{=latex}`env^)))`\
`((==``\ `{=latex}'`()``\ `{=latex}`env))))`

`(defrel``\ `{=latex}`(eval-listo``\ `{=latex}`expr``\ `{=latex}`env``\ `{=latex}`val)`\
`(conde`\
`((==``\ `{=latex}`’()``\ `{=latex}`expr)`\
`(==``\ `{=latex}`’()``\ `{=latex}`val))`\
`((fresh``\ `{=latex}`(a``\ `{=latex}`d``\ `{=latex}`t-a``\ `{=latex}`t-d)`\
`(==``\ `{=latex}`‘(,a``\ `{=latex}`.``\ `{=latex}`,d)``\ `{=latex}`expr)`\
`(==``\ `{=latex}`‘(,t-a``\ `{=latex}`.``\ `{=latex}`,t-d)``\ `{=latex}`val)`\
`(eval-expro``\ `{=latex}`a``\ `{=latex}`env``\ `{=latex}`t-a)`\
`(eval-listo``\ `{=latex}`d``\ `{=latex}`env``\ `{=latex}`t-d)))))`

`(defrel``\ `{=latex}`(lookupo``\ `{=latex}`x``\ `{=latex}`env``\ `{=latex}`t)`\
`(fresh``\ `{=latex}`(y``\ `{=latex}`v``\ `{=latex}`env^)`\
`(==``\ `{=latex}`‘((,y``\ `{=latex}`.``\ `{=latex}`,v)``\ `{=latex}`.``\ `{=latex}`,env^)``\ `{=latex}`env)`\
`(conde`\
`((==``\ `{=latex}`y``\ `{=latex}`x)``\ `{=latex}`(==``\ `{=latex}`v``\ `{=latex}`t))`\
`((=/=``\ `{=latex}`y``\ `{=latex}`x)``\ `{=latex}`(lookupo``\ `{=latex}`x``\ `{=latex}`env^``\ `{=latex}`t)))))`

# Quine time

McCarthy challenge given in 'A Micromanual for LISP'

`(run``\ `{=latex}`1``\ `{=latex}`(e)``\ `{=latex}`(evalo``\ `{=latex}`e``\ `{=latex}`e))`

`=>`

`((((lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0)))`\
`’(lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0))))`\
`(=/=``\ `{=latex}`((_.0``\ `{=latex}`closure))``\ `{=latex}`((_.0``\ `{=latex}`list))``\ `{=latex}`((_.0``\ `{=latex}`quote)))`\
`(sym``\ `{=latex}`_.0)))`

`>``\ `{=latex}`((lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0)))`\
`’(lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0))))`\
`((lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0)))`\
`’(lambda``\ `{=latex}`(_.0)``\ `{=latex}`(list``\ `{=latex}`_.0``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0))))`

We replace `_.0` with the arbitrary free variable name `x` to produce
the canonical LISP/Scheme Quine:

`((lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x)))`\
`’(lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x))))`

`>``\ `{=latex}`((lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x)))`\
`’(lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x))))`\
`((lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x)))`\
`’(lambda``\ `{=latex}`(x)``\ `{=latex}`(list``\ `{=latex}`x``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`x))))`

Twines

every Quine is trivially a Twine; we can add a disequality constraint to
ensure `p` and `q` are distinct terms

`>``\ `{=latex}`(run``\ `{=latex}`1``\ `{=latex}`(p``\ `{=latex}`q)`\
`(=/=``\ `{=latex}`p``\ `{=latex}`q)`\
`(evalo``\ `{=latex}`p``\ `{=latex}`q)`\
`(evalo``\ `{=latex}`q``\ `{=latex}`p))`\
`[TODO``\ `{=latex}`add``\ `{=latex}`the``\ `{=latex}`answer]`

[^3]

Thrines

`>``\ `{=latex}`(run``\ `{=latex}`1``\ `{=latex}`(p``\ `{=latex}`q``\ `{=latex}`r)`\
`(=/=``\ `{=latex}`p``\ `{=latex}`q)`\
`(=/=``\ `{=latex}`p``\ `{=latex}`r)`\
`(=/=``\ `{=latex}`q``\ `{=latex}`r)`\
`(evalo``\ `{=latex}`p``\ `{=latex}`q)`\
`(evalo``\ `{=latex}`q``\ `{=latex}`r)`\
`(evalo``\ `{=latex}`r``\ `{=latex}`p))`\
`[TODO``\ `{=latex}`add``\ `{=latex}`the``\ `{=latex}`answer]`

Structurally boring Quines, Twines, and Thrines

just moving quotes around

`absento` trick to generate more interesting Quines, Twines, and Thrines

`>``\ `{=latex}`(run``\ `{=latex}`1``\ `{=latex}`(p``\ `{=latex}`q)`\
`(absento``\ `{=latex}`p``\ `{=latex}`q)`\
`(absento``\ `{=latex}`q``\ `{=latex}`p)`\
`(evalo``\ `{=latex}`p``\ `{=latex}`q)`\
`(evalo``\ `{=latex}`q``\ `{=latex}`p))`\
`[TODO``\ `{=latex}`add``\ `{=latex}`the``\ `{=latex}`answer]`

\[similarly for Thrines\]

Revisiting our original Quine query with the `absento` trick

`(run``\ `{=latex}`1``\ `{=latex}`(p)`\
`(fresh``\ `{=latex}`(expr1``\ `{=latex}`expr2)`\
`(absento``\ `{=latex}`expr1``\ `{=latex}`expr2)`\
`(==``\ `{=latex}`‘(,expr1``\ `{=latex}`.``\ `{=latex}`,expr2)``\ `{=latex}`p)`\
`(evalo``\ `{=latex}`p``\ `{=latex}`p)))`

`=>`

`((((lambda``\ `{=latex}`(_.0)`\
`(list``\ `{=latex}`(list``\ `{=latex}`’lambda``\ `{=latex}`’(_.0)``\ `{=latex}`_.0)``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0)))`\
`’(list``\ `{=latex}`(list``\ `{=latex}`’lambda``\ `{=latex}`’(_.0)``\ `{=latex}`_.0)``\ `{=latex}`(list``\ `{=latex}`’quote``\ `{=latex}`_.0)))`\
`(=/=``\ `{=latex}`((_.0``\ `{=latex}`closure))``\ `{=latex}`((_.0``\ `{=latex}`list))``\ `{=latex}`((_.0``\ `{=latex}`quote)))`\
`(sym``\ `{=latex}`_.0)))`

# Using a two-list representation of the environment

association-list representation of an environment where `x` is mapped to
the list `(cat dog)` and `y` is mapped to `5`:

`((x``\ `{=latex}`.``\ `{=latex}`(cat``\ `{=latex}`dog))`\
`(y``\ `{=latex}`.``\ `{=latex}`5))`

"split" two-list representation of the same environment:

`(x``\ `{=latex}`y)``\ `{=latex}`;``\ `{=latex}`variables`

`((cat``\ `{=latex}`dog)``\ `{=latex}`6)``\ `{=latex}`;``\ `{=latex}`values`

;; a-list env ;; ((x . (cat dog)) ;; (y . 5))

;; split env ;; (x y) ;; ((cat dog) 6)

`absento` trick for lazy `not-in-envo`

;; (absento 'closure expr)

;; (absento t1 t2)

;; (not-in-envo 'lambda env) ;; (absento 'lambda '(x y))

`(defrel``\ `{=latex}`(evalo``\ `{=latex}`expr``\ `{=latex}`val)`\
`(eval-expro``\ `{=latex}`expr``\ `{=latex}`’(()``\ `{=latex}`.``\ `{=latex}`())``\ `{=latex}`val))`

`(defrel``\ `{=latex}`(eval-expro``\ `{=latex}`expr``\ `{=latex}`env``\ `{=latex}`val)`\
`(conde`\
`;;``\ `{=latex}`quote,``\ `{=latex}`list,``\ `{=latex}`and``\ `{=latex}`variable``\ `{=latex}`reference/lookup``\ `{=latex}`clauses``\ `{=latex}`elided`\
`((fresh``\ `{=latex}`(rator``\ `{=latex}`rand``\ `{=latex}`body``\ `{=latex}`env^``\ `{=latex}`a``\ `{=latex}`x``\ `{=latex}`x*``\ `{=latex}`v*)`\
`(==``\ `{=latex}`‘(,rator``\ `{=latex}`,rand)``\ `{=latex}`expr)`\
`(==``\ `{=latex}`‘(,x*``\ `{=latex}`.``\ `{=latex}`,v*)``\ `{=latex}`env^)`\
`(eval-expro``\ `{=latex}`rator``\ `{=latex}`env``\ `{=latex}`‘(closure``\ `{=latex}`,x``\ `{=latex}`,body``\ `{=latex}`,env^))`\
`(eval-expro``\ `{=latex}`rand``\ `{=latex}`env``\ `{=latex}`a)`\
`(eval-expro``\ `{=latex}`body`\
`‘((,x``\ `{=latex}`.``\ `{=latex}`x*)``\ `{=latex}`.``\ `{=latex}`(,a``\ `{=latex}`.``\ `{=latex}`v*))`\
`val)))`\
`;;``\ `{=latex}`lambda``\ `{=latex}`clause``\ `{=latex}`elided`\
`))`

`(defrel``\ `{=latex}`(not-in-envo``\ `{=latex}`x``\ `{=latex}`env)`\
`(fresh``\ `{=latex}`(x*``\ `{=latex}`v*)`\
`(==``\ `{=latex}`‘(,x*``\ `{=latex}`.``\ `{=latex}`,v*)``\ `{=latex}`env)`\
`(absento``\ `{=latex}`x``\ `{=latex}`x*)))`

\[TODO discuss tradeoffs between asserting (symbolo x) in these helper
relations---how stand-alone do we want them?\]

`(defrel``\ `{=latex}`(lookupo``\ `{=latex}`x``\ `{=latex}`env``\ `{=latex}`t)`\
`(fresh``\ `{=latex}`(y``\ `{=latex}`x*``\ `{=latex}`v``\ `{=latex}`v*)`\
`(==``\ `{=latex}`‘((,y``\ `{=latex}`.``\ `{=latex}`,x*)``\ `{=latex}`.``\ `{=latex}`(,v``\ `{=latex}`.``\ `{=latex}`,v*))``\ `{=latex}`env)`\
`(conde`\
`((==``\ `{=latex}`y``\ `{=latex}`x)``\ `{=latex}`(==``\ `{=latex}`v``\ `{=latex}`t))`\
`((=/=``\ `{=latex}`y``\ `{=latex}`x)``\ `{=latex}`(lookupo``\ `{=latex}`x``\ `{=latex}`‘(,x*``\ `{=latex}`.``\ `{=latex}`,v*)``\ `{=latex}`t)))))`

# Extending the interpreter to handle `append`

add `cons`, `car`, `cdr`, `null?`, and `if`

extend `lambda` and application to handle multiple arguments and
variadic

# Using a non-empty initial environment

new case to handle prim app rather than user-defined closure app

`cons`, `car`, `cdr`, and `null?` bound in the initial env to prims

`list` bound in the initial env to the closure that results from
evaluating the variadic `(lambda x x)`

# Adding explicit errors

# Angelic execution

\[TODO look at my code from PolyConf 2015, which includes an interpreter
for an imperative language, along with angelic execution\]

# Adding mutation

\[TODO look at my code from PolyConf 2015, which includes an interpreter
for an imperative language, along with angelic execution\]

support `set!` (can we get away with supporting `set!` without adding a
store?)

support mutiple pairs and have an explicit store

# Adding delimited control operators

delimited continuations and/or effect handlers---can we do so in such a
way that avoids "breaking the wires"?

talk about the problem with `call/cc` and breaking the wires

# Writing a parser as a relation

# Writing a type inferencer as a relation

# Build your own Barliman

# Speeding up the interpreter

\[restrict to interpreter changes that don't require hacking
faster-miniKanren or in-depth knowledge of the implementation\]

dynamic reordering of conjuncts, especially for application

fast environment lookup for environments that are sufficiently ground

# Open problems

[^1]: Such programs are often called *program sketches* \[TODO cite\].

[^2]: This is known in the literature as "angelic execution".

[^3]: I thank Larry Moss and the Indiana University Logic Symposium
    \[TODO check the name of the symposium\] for inviting me to give a
    talk where I demonstrated Quine generation, and where Larry
    suggested I tried generating Twines.
