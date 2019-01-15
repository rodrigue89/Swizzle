# Tutorial #3: Variables

Variables are a way of labeling data that can be manipulated later on. They can be accessed anywhere in your program. 

A variable is declared as such:

```
var foo = "bar";
```

Notice that the `var` keyword is first, then the name of the variable, then an equals sign (the assignment operator) followed by the data.

Variables can be accessed anywhere and used anywhere, as in this example, which prints "bar".

```
print(foo);
```

A variable can be changed, or mutated with the `set` keyword.

```
set foo = "something else";
```

> If you try to set something that does not exist, or declare something that already exists, you will get an error.

Variables in Swizzle use *Type Inference*. Take the first example:

```
var foo = "bar";
```

`foo` is inferred to have the type `String`.

You can explicitly say what type a variable has to give clarity:

```
var foo: String = "bar";
```

**Challenge:** Make a variable that contains your age, then design a program that outputs:

```
My age:
my age
```

Where "my age" is your age. (HINT: Use the print function twice)

## Takeaway

Variables can be used to store and retrieve data. 

[Previous: Comments](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Comments%20(%232).md) | [Next: Functions](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Functions%20(%234).md)
