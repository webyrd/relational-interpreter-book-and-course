---
author:
- William E. Byrd
date: 2025-01-04
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

Although this book contains a brief introduction to Scheme, and an
introduction to miniKanren, the book is not intended as a tutorial on
the fundamentals of programming, nor as an introduction to functional
programming. Similarly, the book is not intended to be a primer on the
fundamentals of programming language theory, design, or implementation.
While I do try to explain important Scheme and programming languages
concepts as they arise (such as lexical scope, closures, and
environment-passing interpreters), I assume the reader has enough
experience and knowledge to follow along with minimal examples and
explanations of these fundamental concepts. If you've encountered these
ideas before, and just need a little refresher, I hope the level of
explanations and examples will be helpful and sufficient. If you are
familiar with functional programming and interpreters, but don't know
Scheme, the examples and explanation should also be helpful and
sufficient. If you are familiar with some version of miniKanren or
microKanren, the chapters on miniKanren should be helpful, since we'll
be using aspects of the `faster-miniKanren` implementation of miniKanren
that extend (and may differ from) the languages described in the first
and second editions of *The Reasoned Schemer*, the microKanren papers,
my dissertation, and other miniKanren literature.

Since I know different readers will be coming to this book with very
different backgrounds, I've added "pretests" to the Scheme and
miniKanren introduction chapters, to help you determine if you already
know the concepts well enough to skip ahead. Even if you are a Scheme
expert, you should probably read the section on pattern matching to make
sure you understand the syntax and semantics of the pattern-matcher
we'll be using. If you haven't used `faster-miniKanren` before, or a
miniKanren that supports the `=/=`, `symbolo`, `numbero`, and `absento`
constraints, I strongly suggest you read the entire introduction to
miniKanren.

## What is not in this book

One important topic this book does not cover is how to implement a
miniKanren---for example, how `faster-miniKanren` is implemented. While
this is an interesting topic, and is especially important for some
advanced optimizations and for implementing new constraints, this book
focuses on writing interpreters as relations. There are other resouces
on implementing simple miniKanrens, such as the papers on microKanren
\[TODO cite these\], which is the basis for the miniKanren
implementation in the second edition of *The Reasoned Schemer* \[TODO
cite\].

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
giant book into more than one book, each book being more manageable. Dan
encouraged me to write a short and direct primer on Scheme with only the
needed parts of the language. Michael also encouraged me to continue
working on the book in the open.

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

# Enough Scheme to get by

We need to know some Scheme, since Scheme is the host language for the
`faster-miniKanren` version of miniKanren we will be using.
`faster-miniKanren` inherits Schemely features such as `cons` pairs,
`quote`, and `letrec`.

We also need to know some Scheme because we will be writing interpreters
for subsets of Scheme. In particular, we need to feel comfortable with
the evaluation rules for Scheme, including the notions of expressions
and values.

And we need to know some Scheme if we want to be able to read much of
the miniKanren literature.[^3]

## A few comments on Scheme

small core

compositional

few exceptions to rules

very powerful---lots of ways to do meta-programming, including the
ability to extend the syntax of the language

great for writing interpreters, compilers, and DSLs

## The Scheme reports, versions of Scheme, and implementations of Scheme

## Which version and implementations of Scheme we are using, and why

## What we need to know about Scheme, and when

## Useful Scheme resources

\[todo add full references and URLs; can point to the relevant sections
as I describe aspects of Scheme\]

The Scheme Programming Language, 4th Edition

The Chez Scheme User's Guide \[TODO check spelling\]

R6RS

## Pretest

a "pre-test" for Scheme, so the reader can see if they need to read any
of this

Even a reader who knows Scheme might want to read the pattern matching
section

We also describe a few important differences between Scheme and Racket,
to ensure the reader can use either one

## Numbers

In this book we restrict ourselves to non-negative integers, which may
be of any size:

`5`

`42`

`0`

`37623489762387946782365476`

## Booleans

The Boolean `#f` represents "false", while the Boolean `#t` represents
"true".

## `quote` and symbols

In addition to numbers and Booleans, Scheme can represent abstract
concepts and symbolic data using *symbols*, sometimes called *quoted
symbols*.

If we want to create a symbol to represent the abstract concept of
"love", we can write `(quote love)` which produces the symbol `love`.
Because symbols are used so often in Scheme, the equivalent shorthand
notation `'love` can also be used to produce the symbol `love`.

## Expressions, values, and evaluation

In Scheme terminology, `(quote love)` is an *expression*. In Scheme,
expressions are *evaluated* to produce *values*. In this case, the
expression `(quote love)` evaluates to the value `love`, which is a
symbol. \[todo consider pointing out that in Racket, by default, `'love`
will be displayed, and how to adjust that setting\]

All Scheme symbols are values. Numbers and the Booleans `#f` and `#t`
are also values.

In Scheme we can also quote numbers and Booleans. For example, the
expression `(quote 5)` evaluates to the value `5`, which is a number.
Similarly, the expression `(quote #f)` evaluates to the value `#f`,
which is a Boolean.

Actually, we don't need to quote numbers or Booleans in Scheme---numbers
and Booleans are "self-evaluating" (or "self-quoting"). For example, the
expression `42` evaluates to the value `42`, which is a number. The
expression `#t` evaluates to the value `#t`, which is a Boolean. Scheme
symbols, on the other hand, are not self-evaluating, and must be
explicitly quoted.[^4]

As shorthand, we write "the expression `(quote 5)` evaluates to the
value `5`" as:

`(quote 5) => 5`

where the arrow `=>` can be read as "evaluates to".

Similarly, we can write

`(quote #f) => #f`

`(quote love) => love`

`'love => love`

`(quote quote) => quote`

`'quote => quote`

`42 => 42`

`6375764356 => 6375764356`

and

`#t => #t`.

### The general evaluation rule for `quote`

We know that

`(quote 0) => 0`

`(quote 1) => 1`

$\ldots$

`(quote 42) => 42`

$\ldots$

`(quote 3765783657849) => 3765783657849`

$\ldots$

and so forth.

We can generalize our "evaluates to" `=>` notation; the more general
*evaluation rule* for quoting numbers is:

`(quote <num>) => <num>`

for any number `<num>`. We use the name `num` surrounded by the angle
brackets `<` and `>` to represent any number.

Similarly, the evaluation rule for quoting Booleans is:

`(quote <bool>) => <bool>`

for any Boolean `<bool>`. (Of course there are only two Boolean values,
`#f` and `#t`.) And the evaluation rule for quoting symbols is

`(quote <sym>) => <sym>`

for any symbol `<sym>`.

More generally, the evaluation rule for `quote` is:

`(quote <datum>) => <datum>`

The word *datum* is the singular form of *data*. Numbers, Booleans, and
symbols are three types of data we have encountered so far.

## `define`, definitions, and variables

We can use `define` to give a name to a value.

For example,

`(define x 5)`

gives the name `x` to the number `5`, while

`(define cool-cat (quote Sugie))`

gives the name `cool-cat` to the symbol `Sugie`.[^5]

More generally, we can write:

`(define <id> <expr>)`

where `<id>` is any Scheme *identifier* (such as `x`, `my-cat`,
`Hello_there=137^`, or `関連-42`) and where `<expr>` is any expression.

A use of `define` is called a *definition*. A definition is neither an
expression nor a value---it is a *statement*. While evaluation of
expressions produces values, statements are evaluated for their
*effects*. The effect of evaluating `(define x 5)` is to introduce a new
*variable* named `x` that is *bound* to the number `5`.[^6]

Once we have defined a variable (such as `x`), we can *reference* (or
*refer to*) that variable to get the value to which it is bound (such as
the number 5, in the case of the variable `x`).

We can see the behavior of `define` and variable reference at the Chez
Scheme Read-Eval-Print Loop, or *REPL*. First we start Chez Scheme:

`Chez``\ `{=latex}`Scheme``\ `{=latex}`Version``\ `{=latex}`10.1.0`\
`Copyright``\ `{=latex}`1984-2024``\ `{=latex}`Cisco``\ `{=latex}`Systems,``\ `{=latex}`Inc.`

`>`

and then define `x` to be `5`:

`Chez``\ `{=latex}`Scheme``\ `{=latex}`Version``\ `{=latex}`10.1.0`\
`Copyright``\ `{=latex}`1984-2024``\ `{=latex}`Cisco``\ `{=latex}`Systems,``\ `{=latex}`Inc.`

`>``\ `{=latex}`(define``\ `{=latex}`x``\ `{=latex}`5)`\
`>`

The `> ` prompt on the line following `> (define x 5)` indicates that
Chez has evaluated the statement `(define x 5)` and is ready to evaluate
the next expression or statement. To save space, we'll not show the `> `
prompt whenever an expression evaluates to a value that is printed at
the REPL.

Now that we have defined the variable `x`, we can refer to it:

`>``\ `{=latex}`x`\
`5`

`x` is an expression (a variable reference) that evaluates to the value
`5` (a number).

(In our arrow notation, we would write `x => 5`.)

Let's define another variable, like we did above:

`>``\ `{=latex}`(define``\ `{=latex}`cool-cat``\ `{=latex}`(quote``\ `{=latex}`Sugie))`\
`>`

`>``\ `{=latex}`cool-cat`\
`Sugie`

`cool-cat` is an expression (a variable reference) that evaluates to the
value `Sugie` (a symbol).

What happens if we refer to an *unbound variable*---that is, a variable
that has not been defined?

`>``\ `{=latex}`w`

`Exception:``\ `{=latex}`variable``\ `{=latex}`w``\ `{=latex}`is``\ `{=latex}`not``\ `{=latex}`bound`\
`Type``\ `{=latex}`(debug)``\ `{=latex}`to``\ `{=latex}`enter``\ `{=latex}`the``\ `{=latex}`debugger.`

Chez Scheme evaluates the expression `w`, which is a variable reference.
Since `w` is an unbound variable, Chez is not able to determine the
value bound to `w`. Instead, Chez Scheme *throws an exception* \[todo
check terminology: throw exception?\] indicating that `w` is a variable
that is not bound.

Let's define `w` to have the same value as does the variable `x`:

`>``\ `{=latex}`(define``\ `{=latex}`w``\ `{=latex}`x)`\
`>``\ `{=latex}`w`\
`5`

Recall the syntax for uses of `define`:

`(define <id> <expr>)`

Also recall that `(define x 5)` is a statement rather than an
expression. What happens if use a definition where an expression is
required? Chez Scheme complains by throwing a different type of
exception:

`>``\ `{=latex}`(define``\ `{=latex}`z``\ `{=latex}`(define``\ `{=latex}`y``\ `{=latex}`6))`

`Exception:``\ `{=latex}`invalid``\ `{=latex}`context``\ `{=latex}`for``\ `{=latex}`definition``\ `{=latex}`(define``\ `{=latex}`y``\ `{=latex}`6)`\
`Type``\ `{=latex}`(debug)``\ `{=latex}`to``\ `{=latex}`enter``\ `{=latex}`the``\ `{=latex}`debugger.`

We have now encountered the crucial notions of Scheme expressions,
values, and statements, which we will need in order to understand and
write interpreters.[^7]

## Procedures and procedure application

built-in procedures

initial environment

`(add1 5) => 6`

`>``\ `{=latex}`(add1``\ `{=latex}`5)`\
`6`

`>``\ `{=latex}`add1`\
`#<procedure``\ `{=latex}`add1>`

`>``\ `{=latex}`(add1``\ `{=latex}`(add1``\ `{=latex}`5))`\
`7`

`>``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)`\
`7`

`>``\ `{=latex}`(+``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`18`

`>``\ `{=latex}`(+``\ `{=latex}`7835467856``\ `{=latex}`98236472167)`\
`106071940023`

`>``\ `{=latex}`+`\
`#<procedure``\ `{=latex}`+>`

`+` is variadic

`>``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6``\ `{=latex}`7)`\
`18`

`>``\ `{=latex}`(+``\ `{=latex}`5)`\
`5`\
`>``\ `{=latex}`(+)`\
`0`

## Predicates, including type predicates

In Scheme, a *predicate* is a procedure that, when called, always
terminates (without signalling an error), and that always returns one of
the two Boolean literals: `#f` or `#t`.

A *type predicate* is a predicate that can be used to determine the type
of a value.

`number?`

It is a Scheme convention to end the names of predicates with a question
mark. Also by convention, many people "huh?"

`(number? 5) => #t`

`(number? #t) => #f`

`boolean?`

`symbol?`

## `if`, test expressions, and truthiness

`(if #t (+ 3 4) (+ 5 6)) => 7`

`(if #f (+ 3 4) (+ 5 6)) => 11`

`(if (number? 72634786) (+ 3 4) (+ 5 6)) => 7`

`(if (symbol? 72634786) (+ 3 4) (+ 5 6)) => 11`

`(if <expr> <expr> <expr>)`

one-armed vs. two-armed `if`

`#t` is not the only true value in Scheme. In fact, *any* value in
Scheme other than `#f` is considered true. For example, both `5` and `0`
are considered true values in Scheme.

`(if 42 (+ 3 4) (+ 5 6)) => 7`

`(if 'cat (+ 3 4) (+ 5 6)) => 7`

## Evaluation order and special forms

special forms vs. application

keywords

`quote`, `define`, and `if` are keywords; `(quote <datum>)`,
`(define <id> <expr>)`, and `(if <expr> <expr> <expr>)` are special
forms.

Recall that in the initial Scheme environment `+` is a variable bound to
a procedure that adds zero or more numbers:

`>``\ `{=latex}`+`\
`#<procedure``\ `{=latex}`+>`

In contrast, in the initial Scheme environment `quote` is the *keyword*
of a special form. Recall that `(quote <datum>)` is the general syntax
for a `quote` expression. The expression `(quote cat)` evaluates to the
symbol `cat`. However, evaluating the keyword `quote` by itself leads to
a *syntax error*:

`>``\ `{=latex}`quote`

`Exception:``\ `{=latex}`invalid``\ `{=latex}`syntax``\ `{=latex}`quote`\
`Type``\ `{=latex}`(debug)``\ `{=latex}`to``\ `{=latex}`enter``\ `{=latex}`the``\ `{=latex}`debugger.`

## Comments

Any characters on a line following the `;` character will be ignored.
For example,

`(* 3 4) ; (/ 5 0)`

evaluates to `12`.

The entire S-expression following `#;` will be ignored. For example,

`(+``\ `{=latex}`4``\ `{=latex}`5)``\ `{=latex}`#;(*``\ `{=latex}`6`\
`7)`

`#|` and `|#`

## `cond`

## A few other predicates

`zero?`

`even?`

`odd?`

## Lists

`list`

`list?`

empty list (quoted)

`null?`

quoted non-empty lists

nested lists

## Pairs and improper lists

`cons`

`pair?`

## S-expressions

\[todo need to introduce the concept of the s-expression. Now might be a
good time, since we have symbols, numbers, booleans, pairs\]

## `lambda`

## Procedures

`procedure?`

variable ref to procs

## Equality predicates

`=`

`eq?`

`equal?`

## Simple examples

### `member?`

### `length`

### `append`

### `assoc`

## `let`

## `letrec`

## Lexical scope

## More examples

### `append` (`letrec` version)

### `even?` and `odd?` (`define` version)

### `even?` and `odd?` (`letrec` version)

### Curried adder

spelling of Curried?

## `eval`

## Pattern matching

## Grammar for our subset of Scheme

## Differences between Scheme and Racket

evaluation order

printed rep of quoted values

pattern mathing

require vs load

repl usage

`eval` usage

## Exercises

# A whirlwind introduction to relational programming in miniKanren

## What is relational programming?

## Which version of miniKanren we are using, and why

faster-miniKanren without defrel

## Useful miniKanren resources

## Pretest

someone who has read TRS1 or TRS2, or who has implemented microKanren,
still needs to know about `=/=`, `symbolo`, `numbero`, `absento`, and
the differences between miniKanren in those books and in this book

## miniKanren as an embedded DSL, and otherwise

Scheme as host language

## Core miniKanren

### `==`

simlarity to equal? (but not to eq?)

first-order syntactic unification

### `run`$^{n}$

### `conde`

### `fresh`

### `run*`

### What miniKanren inherits from Scheme

## Logic variables (or, what does "variable" even mean?)

## Expressions and terms

## Groundness, and the parts of Scheme we can safely use

## Relational vs. non-relational programming in miniKanren

## Simple examples

### `appendo`

### `membero` (broken version)

## Other useful constraints

### `=/=`

disequality

### `symbolo` and `numbero`

not needed in OCanren, for example

### `absento`

prevention of quoted closures (not needed in OCanren) and other uses,
such as `not-in-envo` in split env

## miniKanren Grammar

beware nesting run or ==, calling Scheme eliminators, unifying with
procedures, assuming a term is ground, assuming Scheme can handle even
ground logic variables as values

revist in style and gotchas chapter

## More examples

### `membero` (fixed version)

### Differences between the miniKanren in this book and other miniKanrens

TRS1

TRS2

microKanren

core.logic

OCanren

### Exercises

# miniKanren style and common pitfalls

"Will's Rule"

syntactic issue 1: lambda (implicit begin) containing more than one goal
expression (without a fresh wrapping those goals)---very hard to debug,
since only one of the goals is actually run---defrel prevents this
problem

syntactic issue 2: nesting a goal expression inside of a call to
==---can actually succeed, although rarely does what you would intend

use of car, cdr, +, etc.

assuming a Scheme function can operate on the value of a ground logic
variable

unifying with a Scheme procedure

mixing Scheme and mk code in a way that doesn't preserve relationality

incorrect tagging

# Debugging miniKanren code

## Debugging unexpected failure

leave all args fresh

comment out clauses and goals

## Taming and debugging apparent divergence

`run 1` vs. `run*`

run program with all arguments ground

reordering conjuncts

adding a depth counter

adding bounds (as in rel interp)

tabling

using occur check, presumably?

## Debugging interpreters (and interpreter-like programs)

how to build up a `conde`-based program, such as an interpreter, one
expression at a time Dan Friedman-style and then run/test it

run program "forward" to test it

perhaps inclue alternative `run` interafce/streaming/alternative
set-based test macro

# A simple environment-passing Scheme interpreter in Scheme

CBV lambda-calc plus quote and cons

a list for env

tagged list to represent closure

grammar for the language we are interpreting

# Rewriting the simple environment-passing Scheme interpreter in miniKanren

# Quine time

McCarthy challenge given in 'A Micromanual for LISP'

Quines, Twines, Thrines

absento trick to generate more interesting Twines and Thrines

# Using a two-list representation of the environment

# Extending the interpreter to handle `append`

# Adding explicit errors

# Adding delimited control operators

delimited continuations and/or effect handlers---can we do so in such a
way that avoids "breaking the wires"?

talk about the problem with `call/cc` and breaking the wires

# Adding mutation

support `set!` (can we get away with supporting `set!` without adding a
store?)

support mutiple pairs and have an explicit store

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

[^3]: A reading knowledge of OCaml would also be helpful for reading the
    miniKanren literature that uses OCanren, a miniKanren-like language
    embedded in OCaml.

[^4]: Scheme symbols must be explicitly quoted so that they are distinct
    syntactically from variable references, which will encounter
    shortly.

[^5]: Actually, in Scheme `(define x 5)` gives the name `x` to a
    *location* that contains the value `5`. It is possible to assign a
    different value to the location named by `x` using `set!`---for
    example, `(set! x 6)`. We will avoid the use of `set!` for now,
    which means we pretend that `define` just gives a name to a value.

[^6]: Actually, the variable `x` is bound to a *location* that contains
    the value `5`.

[^7]: miniKanren also has the notions of expressions, values, and
    statements, and introduces the new notion of *terms*, a
    generalization of the notion of values. \[todo add crossref\]
