# Tutorial #4: Functions

Remmber that line of code from the first tutorial?

```
print("Hello, world!");
```

This line of code is called a `call`. It calls what is called a `function`.
> That was a lot of calls and calling!

In this tutorial, we will be making a function that says hello to anyone. We will start of with the declaration of a function:

```
func
```

This tells the computer to make a new func

After that, we put the name of the function.

```
func greet
```

> **Important:** All function names must start with a lowercased character.. It will be made clearer why later on.

Then, we put parentheses and brackets:

```
func greet() {

}
```

Now, inside those brackets we can put whatever we want!

```
func greet() {
    print("Hello, Tim!");
}
```

Then we just call it:

```
func greet() {
    print("Hello, Tim!");
}

greet();
```

But wait, you say. What if I want to greet Bob? Well, we will have to change the function. What about saying hello to Norah? We will have to change the function again! That is not very helpful :). We need a way to fix it, so that the function can greet anyone.

### Parameters

Go back to the `greet` function. Inside the parentheses, put the word `name`. Then, change the inside code to look like this:

```
func greet(name) {
    print("Hello,", name, "!");
}

greet("Norah");
```

But something weird happends. It prints "Hello, Norah !". Why that extra space? Look at the documentation for the `print` function:

> The print function outputs the given arguments to the console seperated by spaces and terminated by a new line.

In order to tell the `print` function not to do this, we put the join (`#`) symbol as an argument:

```
print("Hello,", name, #, "!");
```

Now, it should run as expected.

**Challenge:** Can you make the function have a second parameter for age and print out something else with that new parameter?

## Takeaway

Functions are very useful to enscapulate behavior. They can make code cleaner and easier to read. They also help break down tasks into smaller tasks.

[Previous: Variables](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Variables%20(%233).md) | [Next: Objects](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Objects%20(%235).md)
