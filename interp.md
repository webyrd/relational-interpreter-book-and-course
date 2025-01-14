---
author:
- William E. Byrd
date: 2025-01-14
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

What if we would like to add one to the number five? One way to do this
in Scheme is to write the expression `(add1 5)`:

`>``\ `{=latex}`(add1``\ `{=latex}`5)`\
`6`

The expression `(add1 5)` is an example of a *procedure application*, or
just *application* (sometimes called a *procedure call*, or just
*call*).

If the expression `(add1 5)` is a procedure application, then what is
`add1`? Let's find out at the REPL:

`>``\ `{=latex}`add1`\
`#<procedure``\ `{=latex}`add1>`

Aha! `add1` is a variable that is bound to a *procedure*. In Scheme
procedures are values, just like numbers, Booleans, and symbols. `add1`
is a *built-in* procedure that is bound in Chez Scheme's *initial
environment*, which is the default set of variable bindings that exist
when Chez is started. We can extend or modify the initial environment,
as we did before using `define`.

We can nest procedure applications in Scheme:

`>``\ `{=latex}`(add1``\ `{=latex}`(add1``\ `{=latex}`5))`\
`7`

There are many built-in procedures in the initial Scheme environment,
and even more in the initial Chez Scheme environment, since Chez extends
Scheme with many additional procedures. If we want to add two numbers,
we can use the built-in Scheme procedure `+`:

`>``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)`\
`7`

and:

`>``\ `{=latex}`(+``\ `{=latex}`7835467856``\ `{=latex}`98236472167)`\
`106071940023`

Of course, we can nest procedure applications:

`>``\ `{=latex}`(+``\ `{=latex}`(add1``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`(add1``\ `{=latex}`7)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))))`\
`23`

As is the case with `add1`, `+` is a variable that is bound to a
procedure in Chez Scheme's initial environment:

`>``\ `{=latex}`+`\
`#<procedure``\ `{=latex}`+>`

The procedure bound to `add1` takes exactly one argument. In contrast,
the procedure bound to `+` is *variadic*, meaning that it can take any
number of arguments. For example, the procedure bound to `+` can take
three arguments:

`>``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6``\ `{=latex}`7)`\
`18`

one argument:

`>``\ `{=latex}`(+``\ `{=latex}`5)`\
`5`

or even zero arguments:

`>``\ `{=latex}`(+)`\
`0`

The expression `(+)` evaluates to `0` because zero is the additive
identity (the number that when added to another number preserves the
value of that second number).

## Predicates, including type predicates

In Scheme, a *predicate* is a procedure that, when called, always
terminates (without signalling an error), and that always returns one of
the two Boolean literals: `#f` or `#t`.

A *type predicate* is a predicate that can be used to determine the type
of a value. For example, the predicate

`number?`

is a built-in procedure that determines whether its argument is a
number:

`>``\ `{=latex}`number?`\
`#<procedure``\ `{=latex}`number?>`\
`>``\ `{=latex}`(number?``\ `{=latex}`5)`\
`#t`\
`>``\ `{=latex}`(number?``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4))`\
`#t`\
`>``\ `{=latex}`(number?``\ `{=latex}`(quote``\ `{=latex}`cat))`\
`#f`\
`>``\ `{=latex}`(number?``\ `{=latex}`#t)`\
`#f`\
`>``\ `{=latex}`(number?``\ `{=latex}`number?)`\
`#f`

It is a Scheme convention to end the names of predicates with a question
mark. Also by convention, many people pronounce the `?` at the end of
the predicate's name as "huh"; for example, `number?` is pronounced
"number-huh".

Scheme's built-in type predicates also include `boolean?`, `symbol?`,
and `procedure?`:

`>``\ `{=latex}`(boolean?``\ `{=latex}`#t)`\
`#t`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`#f)`\
`#t`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`5)`\
`#f`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4))`\
`#f`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`(quote``\ `{=latex}`cat))`\
`#f`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`boolean?)`\
`#f`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`(number?``\ `{=latex}`5))`\
`#t`\
`>``\ `{=latex}`(boolean?``\ `{=latex}`(number?``\ `{=latex}`#f))`\
`#t`

`>``\ `{=latex}`(symbol?``\ `{=latex}`(quote``\ `{=latex}`cat))`\
`#t`\
`>``\ `{=latex}`(symbol?``\ `{=latex}`5)`\
`#f`\
`>``\ `{=latex}`(symbol?``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4))`\
`#f`\
`>``\ `{=latex}`(symbol?``\ `{=latex}`#f)`\
`#f`\
`>``\ `{=latex}`(symbol?``\ `{=latex}`symbol?)`\
`#f`\
`>``\ `{=latex}`(symbol?``\ `{=latex}`(symbol?``\ `{=latex}`5))`\
`#f`

`>``\ `{=latex}`(procedure?``\ `{=latex}`procedure?)`\
`#t`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`+)`\
`#t`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`add1)`\
`#t`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`5)`\
`#f`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4))`\
`#f`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`(quote``\ `{=latex}`cat))`\
`#f`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`(quote``\ `{=latex}`+))`\
`#f`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`#t)`\
`#f`\
`>``\ `{=latex}`(procedure?``\ `{=latex}`(symbol?``\ `{=latex}`(quote``\ `{=latex}`cat)))`\
`#f`

## `if`, test expressions, and truthiness

We can make choices in Scheme using an `if` expression, which is of the
form

`(if <test> <consequent> <alternative>)`

where `<test>`, `<consequent>`, and `<alternative>` are all expressions.
For example, in the expression `(if #t 3 4)`, the *subexpression* `#t`
is in the *test position*, the subexpression `3` is in the *consequent
position*, and the subexpression `4` is in the *alternative position*.

The rule for evaluation of an `if` expression is that first the test
subexpression is evaluated. If the test subexpression evaluates to a
true value, then the consequent subexpression is evaluated, and the
resulting value is the value of the entire `if` expression. If the test
subexpression evaluates to a false value, then the alternative
subexpression is evaluated, and the resulting value is the value of the
entire `if` expression.

For example:

`>``\ `{=latex}`(if``\ `{=latex}`#t``\ `{=latex}`3``\ `{=latex}`4)`\
`3`

`>``\ `{=latex}`(if``\ `{=latex}`#f``\ `{=latex}`3``\ `{=latex}`4)`\
`4`

Of course we can use more complex expressions for the consequent and
alternative subexpressions:

`>``\ `{=latex}`(if``\ `{=latex}`#t``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`7`\
`>``\ `{=latex}`(if``\ `{=latex}`#f``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`11`

And we can use more complex expressions for the test subexpression:

`>``\ `{=latex}`(if``\ `{=latex}`(number?``\ `{=latex}`72634786)``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`7`\
`>``\ `{=latex}`(if``\ `{=latex}`(symbol?``\ `{=latex}`72634786)``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`11`

`#t` is not the only true value in Scheme. In fact, *any* value in
Scheme other than `#f` is considered true. For example, both `5` and `0`
are considered true values in Scheme.

`>``\ `{=latex}`(if``\ `{=latex}`42``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`7`\
`>``\ `{=latex}`(if``\ `{=latex}`(*``\ `{=latex}`6``\ `{=latex}`7)``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`7`\
`>``\ `{=latex}`(if``\ `{=latex}`’cat``\ `{=latex}`(+``\ `{=latex}`3``\ `{=latex}`4)``\ `{=latex}`(+``\ `{=latex}`5``\ `{=latex}`6))`\
`7`

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

Any characters between matching `#|` and `|#` will be igored. For
example:

`(list`\
`(+``\ `{=latex}`3``\ `{=latex}`4)`\
`#|`\
`erfjkhrj``\ `{=latex}`hfjk`\
`kjrhjkrheg``\ `{=latex}`rjghjer``\ `{=latex}`gj`\
`rghrejhj``\ `{=latex}`rjegh``\ `{=latex}`jrehk`

`jehjkf``\ `{=latex}`klh``\ `{=latex}`fe`\
`|#`\
`(*``\ `{=latex}`5``\ `{=latex}`6)`\
`)`

is equivalent to

`(list`\
`(+``\ `{=latex}`3``\ `{=latex}`4)`\
`(*``\ `{=latex}`5``\ `{=latex}`6)`\
`)`

which is equivalent to `(list (+ 3 4) (* 5 6))`.

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
`(match``\ `{=latex}`expr`\
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

[^8]

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

\[TODO do I want to make eval-expro representation-independent wrt
environments?\]

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

multi-argument and variadic `lambda` and application

# Using a non-empty initial environment

`cons`, `car`, `cdr`, and `null?` bound in the initial env to prims

`list` bound in the initial env to the closure that results from
evaluating the variadic `(lambda x x)`

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

[^8]: I thank Larry Moss and the Indiana University Logic Symposium
    \[TODO check the name of the symposium\] for inviting me to give a
    talk where I demonstrated Quine generation, and where Larry
    suggested I tried generating Twines.
