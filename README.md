![](https://github.com/SafelySwift/Swizzle/blob/master/Images/Swizzle%20Logo%20Wide.png)

```
objc Person {
    decl name;
    decl age;
}

func eat(person) {
    print("Eating", person.name, "cause why not?");
}

var p = Person("Tim", 99);
eat(p);
```
> Some code in Swizzle

## What is it?

Swizzle is a programming language that is all new, yet all fun. Swizzle has a syntax that is similar to other popular programming languages. It is simple to write code and simpler to run it.

Though Swizzle is still in development, I would say it is slightly functional.

**Tutorials:**
- [Hello World](https://github.com/SafelySwift/Swizzle/blob/gh-pages/Tutorials/Hello%20World%20(%231).md)
- [Comments](https://github.com/SafelySwift/Swizzle/blob/gh-pages/Tutorials/Comments%20(%232).md)
- [Variables](https://github.com/SafelySwift/Swizzle/blob/gh-pages/Tutorials/Variables%20(%233).md)
- [Functions](https://github.com/SafelySwift/Swizzle/blob/gh-pages/Tutorials/Functions%20(%234).md)
- [Objects](https://github.com/SafelySwift/Swizzle/blob/gh-pages/Tutorials/Objects%20(%235).md)


##### Swizzle allows:

- Custom objects
- User defined functions
- Variables

##### Still in development

- Control flow (if, while, for)
- Operators
- Extending

Similar to many langauges, Swizzle requires semicolons to terminate statements. Even though this may be annoying, it actually helps make the error messages better so you can write cleaner and safer code.

## What is included?

Swizzle comes with an interpreter and debugger, and compiler support should come sooner or later. You may have heard that interpreters are very slow and all that, but Swizzle is written in Swift so there is not much of a performance loss. The code example above takes 0.26 seconds to execute, which although is slighty slow is one of the best speeds I have gotton in interpreters. Eventually a bytecode compiler will be built as I mentioned, and speeds are likey going to blow off the roof. Well, not literally.

## How can I use it?

Using it is simple: just clone or download the directory to your computer and add it to your Swift project.

![](https://github.com/SafelySwift/Swizzle/blob/master/Images/Screen%20Shot%202018-12-17%20at%209.20.42%20PM.png)

## How can I write better code?

Swizzle already outputs helpful error messages and I am working on making them more human readable. However, you already have access to the the debugging tools included in Swizzle.

### 1. Stack Trace

You can see what and how your program did what it did.

### 2. Debug

You can inspect a frame of execution in great detail
