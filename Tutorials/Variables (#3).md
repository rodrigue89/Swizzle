# Tutorial #3: Variables

Variables are away of labeling data that can be manipulated later on. They can be accessed anywhere in your program. 

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
set foo = "something else"
```

> If you try to set something that does not exist, or declare something that already exists, you will get an error.

**Challenge:** Make a variable that contains your age, then design a program that outputs:

```
My age:
my age
```

Where "my age" is your age.

## Takeaway

Variables can be used to store and retrieve data. 
