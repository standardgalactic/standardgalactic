Raw text of Haskell considerations from user:

https://github.com/dzchoi

Skip to content
dzchoi
/
Haskell-Considerations
Code
Issues
Pull requests
Actions
Projects
Wiki
Security
Insights
Home
Jump to bottom
dzchoi edited this page on 25 Jan · 107 revisions
Haskell-Insights
Why function application is left-associative
In a sense, Haskell is similar to the FORTH language: all 'words' are executed in the order of presence (left-to-right), but they may be:

just a value (if it stands alone) or
a single-argument function (if it is accompanied by another word) that consumes(takes) the next word as its argument unevaluated.
If a right-associative function application is needed, we can use the lowest precedence and left-binding operator, $, which can be well regarded as a left parenthesis and we can also assume the corresponding right parenthesis being all the way down at the end of the line. So,

f a b is interpreted as (f a) b, and
f $ a b is interpreted as f (a b).
Haskell vs Lambda Calculus
Lambda calculus is not a practical language, although it can be simulated under a computer. Lambda calculus is more abstract than Haskell. Everything in lambda calculus is defined as a function (e.g., the number 0 is a synonym for the identity function.)
That said, there is some heritage in Haskell from lambda caculus, the lazy evaluation. Function application is a matter of parameters substitution rather than evaluation. So, functions in Haskell can be thought as smart macros as in typical imperative languages. That means a function call in Haskell does not trigger the function evaluation and it is just a macro-expansion. That is why the evaluation in Haskell is called lazy (on-demand) as opposed to the strict evaluation.
Evaluation and execution differ in Haskell
Evaluation: a look-up of a value or a function application

Evaluation cannot be controlled by a user, but entirely depends on the Haskell compiler.
Evaluation might be omitted; if Haskell already knows the result from previous run of the same evaluation Haskell may reuse it.
Evaluation might be done by looking up a table; e.g., referencing trigonometric tables for sine and cosine functions.
Evaluation does not have a specific order (and might be done even concurrently), unless the case has a predefined rule such as precedence or associativity or the case involves a natural order like a function result being used as an argument for another function.
Evaluation is done lazily only if it is necessary, that is, only if it is triggered.
Execution: (monadic) IO actions are evaluated and then executed at runtime

IO actions as well as other values can be created(returned) by the evaluation, but only IO actions are executed at runtime (automatically when the IO actions are returned by main and by nothing else.)
The main should be defined of type main :: IO t.
There are other functions that generate IO actions on evaluation, e.g.,
putStrLn :: String -> IO ()
getLine :: IO String
Execution is forced by the runtime, so it is the fundamental trigger to evaluations, which will not be done unless triggered.
In Haskell, we can't create an IO action from scratch, no matter how hard we try. Also, we can't execute an IO action inside the program. For that we have to return it from main. So an IO action is truly indescribable.
What is an IO action in a formal perspective?
IO action is a value of type :: IO a, which is defined as a type synonym (see https://wiki.haskell.org/IO_inside):

type IO a = RealWorld -> (RealWorld, a)
    -- where RealWorld is a fake type for something that is used like a baton which gets passed
    -- between all procedures (IO actions) called by 'main' in strict order.
    -- Actually IO a is defined in GHC.Types as,
    -- newtype IO a = IO (State# RealWorld -> (# State# RealWorld, a #))
Thus, IO a is a function and is as normal as a pure function. It can be passed as an argument to a function and returned as a result from a function. But,

It can be evaluated only with a RealWorld and a RealWorld is only given to the main function when our program is about to run. (We call the evaluation of IO action on a RealWorld its execution.) That means, we can execute it only through main.
The only way to deal with a from IO a is through applying another IO action function (:: a -> IO b) on it with the binding operator (>>=) :: IO a -> (a -> IO b) -> IO b. (The (<-) binding operator, mapM, filterM and something like them are all based on (>>=).)
Haskell uses the type :: IO a for a function that has a side-effect, because:

Honestly, Haskell knows nothing about whether a function actually has a side-effect or not. But, all runtime library functions having side-effects have been marked with type ::IO a.
There is no way of making an IO action from scratch (without using foreign import). We can make an IO action only by expanding (and/or composing) other IO actions. Then, the new IO action also comes to have a type ::IO a, since the only manipulators on IO a are (>>) :: IO a -> IO b -> IO b and (>>=) :: IO a -> (a -> IO a) -> IO b, which just builds another IO actions.
Those IO actions are executed only through calling main.
Bottom (⊥)
def: undefined = undefined :: a
an object(expression) that leads to a runtime error when evaluated
It would be nearly useless without the lazy evaluation; the strict evaluation would lead to a runtime error immediately at its very existence.
error :: String -> a can also be used as undefined with an error message being printed to the console.
By virtue of the laziness, Haskell allows:
optimized iteration; even if we map something over a list several times and filter it several times, it will only pass over the list once.
short-circuit evaluation for free (Even in the pure functional programming, the short-circuit evaluation is necessary to avoid some runtime errors such as singleton ls = not (null ls) && null (tail ls).)
handling of infinite lists (as streams)
no forward declarations needed
non-tail recursive functions to evaluate with the same amount of stack space as the recursive ones would do; Assuming take' :: [a] -> Int -> [a] -> [a] is a user-defined, strictly evaluated and tail recursive version of take, with the lazy evaluation, we will get take' [] 3 [1..] == take' (1 : 2 : 3 : []) 0 [4..] and take 3 [1..] == 1 : 2 : 3 : take 0 [4..]. That means, take' stores (and updates) the intermediate 1 : 2 : 3 : [] in an argument on the stack, while take stores (and updates) it in the thunk managed by Haskell internally.
Nullary functions (functions with no parameters)
Because of functions having no side-effects, Haskell does not distinguish a nullary function and a (named) constant.
For example, the constant True is called as a value constructor for the Bool type.
Like C, Haskell can actually define a function accepting only unit () (say, f () = "hello"). But, it's useless because it acts as nothing but a named constant (f = "hello").
Polymorphism vs static typing
There are two kinds of polymorphism in Haskell, the parametric polymorphism and the ad-hoc polymorphism (see https://wiki.haskell.org/Polymorphism). However, this distinction is only for when defining functions, not when calling functions.

For example, the function id :: a -> a is believed to be defined using the parametric polymorphism and the function (+) :: Num a => a -> a -> a is defined using the ad-hoc polymorphism. However, no more distinguished consideration is needed for calling (+) than for calling id, except that (+) should take only arguments of the types in Num typeclass.

However, when calling these functions at all, we have to use very specific types for the arguments with each call, although we can use different types from one call to another. It's because since Haskell is a statically typed language, it has to know all the types before the code is compiled. That said, do not be confused by that these polymorphic functions still can be used for defining other polymorphic functions.

test x y = fromIntegral x + y -- y may be of any type in Num typeclass
main = do
    print $ test 2 3               -- will output Int
    print $ test 2 (3 :: Integer)  -- will output Integer
    print $ test 2 3.1             -- will output Double
For example, the Reverse Polish notation calculator in the book, "Learn You a Haskell for Great Good!" is implemented as a function to calculate a given RPN expression and return a result of any numerical type. Note it is using read in it without a type annotation. It returns a polymorphic type a and is polymorphic as such, but is polymorphic in regard to the implementation only. If we want to use it and we want to display its result to screen, we have to choose a specific type for the result before calling it, or the compiler will choose Int by default.

import Data.List (words)

solveRPN :: (Num a, Read a) => String -> a
solveRPN = head . (foldl foldingFunction []) . words where
    foldingFunction (x:y:ys) "*" = (x * y):ys
    foldingFunction (x:y:ys) "+" = (x + y):ys
    foldingFunction (x:y:ys) "-" = (x - y):ys
    foldingFunction xs numberString = (read numberString):xs

main :: IO ()
main = do
    putStrLn "enter an RPN expression:"
    expression <- getLine
    putStrLn $ "= " ++ show(solveRPN expression)
    main

-- When running,
-- enter an RPN expression:
-- 1 2 3 + *
-- = 5
-- 1.0 2 3 + *
-- solveRPN: Prelude.read: no parse
Seemingly weak typing
Haskell seems to allow an implicit type conversion; 1 + 2.1 == 3.1.
But, it's not; (1 :: Int) + 2.1 would lead to a compile-time error.
This seemingly weak typing comes from that numbers in Haskell are of polymorphic type Num a (that is, of any type in the typeclass Num a) and + is defined on Num a. And the compiler chooses Double for 2.1 and also chooses Double for 1 in accordance with 2.1. (?)
No serial or parallel bindings in let unlike ML
ML distinguishes serial bindings and parallel bindings in let.
(* In SML/NJ *)

let (* serial bindings *)
    val x = 1
    val x = x + 1
in
    x             (* x = 2 *)
end;

val x = 1;
let (* parallel bindings *)
    val x = x + 1 (* x = 2 *)
    and y = x + 2 (* y = 3 *)
in
    y             (* y = 3 *)
end
In Haskell, order of declarations does not matter and bindings occur lazily.
{- In Haskell -}

let
    y = x + 1     -- y == 2
    x = 1
    -- x = x + 1  -- Error: the same x cannot be defined again
    z = z + 1     -- It's ok but takes forever to evaluate
    a = 1 : a     -- a == [1,1,...]
    fib = 1 : 1 : [ x+y | x <- fib, y <- tail fib ]  -- infinite list of fibonacci sequence
in
    y             -- y == 2
Fibonacci sequence
-- naive version
fib1 0 = 0
fib1 1 = 1
fib1 n = fib1 (n-2) + fib1 (n-1)

-- using memoization
{-# LANGUAGE PatternGuards #-}
fib2' 1 = (0, 1)
fib2' n | (m, n) <- fib2' (n-1) = (n, m+n)
fib2 = snd . fib2'

{-# LANGUAGE ViewPatterns -#}
fib3' 1 = (0, 1)
fib3' (fib3' . pred -> (m, n)) = (n, m+n)
fib3 = snd . fib3'

-- as an infinite list
fib4 = 0 : 1 : [ x+y | (x, y) <- zip fib4 (tail fib4) ]

fib5 @ (_ : fib5') = 0 : 1 : [ x+y | (x, y) <- zip fib5 fib5' ]
Patterns are not a first-class citizen.
Patterns are not allowed to be passed as an argument, returned from a function, or bound to a name.
They are used only in special constructs such as function definition, case-of expression, let binding, and where binding.
Functions!
In Haskell, functions are not only passed as arguments to other functions and returned as return values from other functions, but can also be generated on the fly (though they should conform to the types that are known to the compiler), whereas functions in C are given birth by a programmer at the source code and cannot be generated dynamically.

For example, foldl can be defined with foldr by making a function dynamically and gradually:

myFoldl' f acc as = foldr (\a g z -> f (g z) a) id as acc
  -- "foldr (\a g z -> f (g z) a) id as" will give us a function of
  -- "\z -> f (... (f (f (id z) a1) a2) ...) an" and we can call it with acc.
Functions that generate other functions are the happiest ones among all functions!

Repeated applications of (.)
Let's define o = o1 = (.), o2 = (.) (.), o3 = (.) (.) (.), ...
Then, we can have the following rules (each of the rules comes trivially or from the rules above it):

[o0] a b c == (a b) c
[o1] a (b c) == o a b c
[o2] a b (c d) == o2 a b c d
[o3] a (b c d) == o3 a b c d
[o4] a b c (d e) == o4 a b c d e
[o5] a (b (c d)) == o5 a b c d
[o6] a (b c) (d e) == o6 a b c d e
[o7] a b (c d e) == o7 a b c d e
[o8] a (b c d e) == o8 a b c d e
[o9] a b c d (e f) == o9 a b c d e f
[o10] o10 == o6, that is, oN == o(N-4) if N >= 10
We might be tempted to define these oNs in a general form, but only to fail.

  -- We cannot define these as follows since the type cannot be determined.
  o 1 = (.)
  o n | n > 1 = o (n-1) (.)
These rules can be used in writing point-free definitions.
The o3 is called as (.:) and the o8 is (.:.) in Data.Composition.
Some facts about o-notations:
o2 o == o3 (oN o == o(N+1) in general)
but, o o2 /= o3 (o o2 == o4 by rule [o1])
a o o /= a o2 (a o2 == a (o o) /= a o o)
o . a == o2 a (e.g., o . (o . o) == o . o3 == o2 o3 == o8 by rules [o7] and [o10])
o o2 == o4 (by rule [o1])
o o3 == o7 (by rule [o3])
o o4 == o9 (by rules [o8] and [o10])
o2 o2 == o6 (by rule [o2])
o2 o3 == o8 (by rules [o7] and [o10])
o3 o2 == o9 (by rule [o4])
o o2 o2 == o7 (by rules [o6] and [o10])
o4 o2 == o7 (using o o2 == o4 for the above)
o (o o2) == o9 (by rule [o5])
Compositions of unary function and binary function
Let f be a binary function, and g and h be unary functions.

fgxy  f g x y = f (g x) y        --or fgxy = o, that is, (.)
fxgy  f g x y = f x (g y)        --or fxgy = o flip o2, which is (.) flip ((.) (.))
fgxgy f g x y = f (g x) (g y)    --or fgxgy = on = o8 dup o3 flip o6 where dup f x = f x x
fgxhy f g h x y = f (g x) (h y)  --or fgxhy = o3 flip o6
gfxy  g f x y = g (f x y)        --or gfxy = o3
The above gfxfy comes from:

g (f x) (f y)
== o6 g f x f y              -- by rule [o6])  
== flip (o6 g f) f x y  
== o3 flip o6 g f f x y       -- by rule [o3])  
== dup (o3 flip o6 g) f x y  
== o8 dup o3 flip o6 g f x y  -- by rule [o8])
We can consider (.) :: g -> f -> g ∘ f, assuming g and f are composable.
Then, we have (.) . (.) :: g -> (a -> f) -> a -> g ∘ f, because

if we let the second (.) be of type :: g -> f -> g ∘ f, then
we can say the first (.) is of type :: (f -> g ∘ f) -> (a -> f) -> a -> g ∘ f.
Equivalently, (.) . (.) :: (c -> d) -> (a -> b -> c) -> a -> b -> d.

Or, we can deduce (.) . (.) from
g (f x y)
== o g (f x) y -- using the definition of (.)
== (o g) (f x) y -- function application is left associative
== o (o g) f x y -- using the definition of (.)
== o o o g f x y -- using the definition of (.)
(We could also apply the rule [o3] directly to get the final expression.)

For example,

notElem' = not .: elem
nand = not .: (&&)
countIf = length .: filter
minus = (+) `fxgy` negate where fxgy = o flip o2
find = head .: dropWhile . (not .)  -- find p as = head $ dropWhile (not . p) as
Point-free definitions involving pairs
Prelude has:
curry :: ((a,b) -> c) -> a -> b -> c
uncurry :: (a -> b -> c) -> (a,b) -> c
So, we can have, for any function f:
f x y == uncurry f (x, y)
f (x, y) == curry f x y
For example, apply1 :: (a -> b) -> (a,c) -> (b,c) can be defined as:
apply1 f (a, c) = (f a, c) = (,) (f a) c = ((,) . f) a c = uncurry ((,) . f) (a, c)
so apply1 f = uncurry ((,) . f) = uncurry ( ((,) .) f ) = ( uncurry . ((,) .) ) f
so apply1 = uncurry . ((,) .)
Why foldl cannot be used with an infinite list, while foldr can do?
foldl f acc [a1, a2, a3, ..., an] == f (... (f (f (f acc a1) a2) a3) ...) an
foldr f acc [a1, a2, a3, ..., an] == f a1 (f a2 (f a3 (... (f an acc) ...)))

Both functions are supposed to evaluate its expression with from a1 to an (in spite of most documents describing foldr to be defined with from an to a1.)

And the actual definitions would be:

foldl _ acc [] = acc
foldl f acc (a:as) = foldl f (f acc a) as
  -- The acc here acts as the accumulator holding the intermediate result so far.

foldr _ acc [] = acc
foldr f acc (a:as) = f a (foldr f acc as)
  -- The acc here is just for sending an initial value all the way down to the end.
Note that foldr invokes foldr through an argument of f (acc actually). So, if f in foldr does not need the argument acc during its evaluation, foldr can cut off the next foldr being evaluated. On the other hand, foldl invokes foldl directly regardless of the return value from f and we have no way to cut off the evaluation proceeding to the next foldl and all the way down to the end. Being defined as tail-recursive, foldl cannot be controlled to exit early in the repeated evaluations.

If we want to define a recursive function with the same way of foldl that is tail-recursive with a so-far accumulator as an argument, but we want it to exit early in some condition, we need to define it manually, without using the foldl.

-- Instead of defining `elem1 e = foldl (\acc a -> acc || e == a) False`, we can write:
elem1 _ [] = False
elem1 e (a:as) = e == a || elem1 e as
With foldr, we have to define f not to access acc in some condition, to properly deal with infinite lists. That is, even foldr might blow up with infinite lists unless f is defined as such.

elem2 e = foldr (\a acc -> e == a || acc) False  -- ok with infinite lists
elem3 e = foldr (\a acc -> acc || e == a) False  -- it will always try to the end of the list
Use foldl' instead of foldl whenever possible
foldl is a way of recursion accumulating the intermediate results with an accumulator as an argument of each recursive call while traversing a list. With the lazy nature of Haskell, foldl while running keeps each accumulator as a thunk, not as a strict value. But, why do we need it as a thunk, even we already know the every part of the thunk? Laziness is useful only when we don't need to know whether some parts of a thunk are ready or not unless necessary.
The only case that foldl is really needed instead of foldl' is when the initial value itself should be better evaluated lazily.
Functors and Foldables
3 + 1 == 4
3 + Nothing -- compile-error
fmap (3+) (Just 1) == Just 4
fmap (3+) Nothing == Nothing  -- Nothing is used as a functor
(+) <$> Just 3 <*> Just 1 == Just 4
(+) <$> Just 3 <*> Nothing == Nothing  -- Nothing is used as an applicative functor
foldr (+) 1 (Just 3) == 4
foldr (+) 1 Nothing == 1  -- Nothing is used as a foldable
 Pages 1
Find a Page…
Home
Clone this wiki locally
https://github.com/dzchoi/Haskell-Considerations.wiki.git
© 2020 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
