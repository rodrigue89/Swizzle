<p align="center">
<img src="https://raw.githubusercontent.com/SafelySwift/Swizzle/prerelease/Images/Swizzle%20Logo%20Wide%20New.png" alt="Swizzle Banner">
</p>

<!--![](https://travis-ci.com/SafelySwift/Swizzle.svg?branch=master)-->


```
objc Person {
    decl name;
    decl age;
}

var vec = Vector4(1, 2, 3, 4);
swizzle4(vec, "wxxy");

func eat(person) {
    print("Eating", person.name, #, ". They were only", person.age, "years old.");
}
```
> Some code in Swizzle

#### Quick Links

- [Overview](https://github.com/SafelySwift/Swizzle/blob/prerelease/README.md#what-is-it)
- [What is included](https://github.com/SafelySwift/Swizzle/blob/prerelease/README.md#what-is-included)
- [How to use it](https://github.com/SafelySwift/Swizzle/blob/prerelease/README.md#how-can-i-use-it)
- [Versions](https://github.com/SafelySwift/Swizzle/blob/prerelease/README.md#versions)
- [Documentation](https://github.com/SafelySwift/Swizzle/wiki)

**IMPORTANT: We are hard at work [here](https://github.com/SafelySwift/Swizzle/tree/swizzle-1.0), so this branch is going to be dormant for a while**

## What is it?

Swizzle is a programming language that is all new, yet all fun. Swizzle has a syntax that is similar to other popular programming languages. It is simple to write code and simpler to run it.

Though Swizzle is still in development, I would say it is slightly functional.

## The Goal

Swizzle attempts to fill in a niche for graphics programming. There are not many simple, powerful and fast compiled langauges for this purpose. Swizzle hopes to succeed in all those categories. 

##### Swizzle allows:

- Custom objects
- User defined functions
- Variables

##### Still in development

- Control flow (if, while, for)
- Operators
- Extending

For more, visit the [documentation](https://github.com/SafelySwift/Swizzle/wiki).

**Tutorials:**
- [Hello World](https://github.com/SafelySwift/Swizzle/blob/prerelease/Tutorials/Hello%20World%20(%231).md)
- [Comments](https://github.com/SafelySwift/Swizzle/blob/prerelease/Tutorials/Comments%20(%232).md)
- [Variables](https://github.com/SafelySwift/Swizzle/blob/prerelease/Tutorials/Variables%20(%233).md)
- [Functions](https://github.com/SafelySwift/Swizzle/blob/prerelease/Tutorials/Functions%20(%234).md)
- [Objects](https://github.com/SafelySwift/Swizzle/blob/prerelease/Tutorials/Objects%20(%235).md)

Similar to many languages, Swizzle requires semicolons to terminate statements. Even though this may be annoying, it actually helps make the error messages better so you can write cleaner and safer code. See [this pull request](https://github.com/SafelySwift/Swizzle/pull/36) if you do not want to use semicolons.

## What is included?

Swizzle comes with an interpreter and debugger, and compiler support [is in development](https://github.com/SafelySwift/Swizzle/tree/swizzle-1.0). You may have heard that interpreters are very slow and all that, but Swizzle is written in Swift so there is not much of a performance loss. The code example above takes 1 millisecond to execute, which although is slightly slow is one of the best speeds I have gotten in interpreters. Eventually a bytecode compiler will be built as I mentioned, and speeds are likely going to blow off the roof. Well, not literally.

## How can I use it?

### There are 2 ways to use it

1. Use the app to run, edit and make Swizzle files _[RECOMMENDED]_

    URL: [https://github.com/SafelySwift/SwizzleApp](https://github.com/SafelySwift/SwizzleApp)

    ![](https://github.com/SafelySwift/Swizzle/blob/prerelease/Images/Screen%20Shot%202019-01-06%20at%2012.02.03%20AM.png)
    
    Though interpreters are slow, the app handles them with insanely fast speed.

2. Clone or download the directory to your computer and add it to your Swift project.

  ![](https://github.com/SafelySwift/Swizzle/blob/prerelease/Images/Screen%20Shot%202018-12-17%20at%209.20.42%20PM.png)

## Contributing

Swizzle is not perfect. Or rather only as perfect as the people who help. If you want to make Swizzle a better language or want to see a feature added/report a bug, see [the contributing guidelines](https://github.com/SafelySwift/Swizzle/blob/prerelease/CONTRIBUTING.md)!

## Versions

The latest feature release is [v0.3](https://github.com/SafelySwift/Swizzle/releases/tag/v0.3.0).
The latest small release is [v0.3.2](https://github.com/SafelySwift/Swizzle/releases/tag/v0.3.2).

For more information on releases, go [here](https://github.com/SafelySwift/Swizzle/releases).

## Beyond Swizzle

- My [reddit](https://www.reddit.com/user/SafelySwift) is a great place to chat about ideas or discuss coding. There is also the dedicated [subreddit](https://www.reddit.com/r/swizzle_lang/).
- The [Crafting Interpreters](http://craftinginterpreters.com) book is really helpful

## Requirements

You will need Xcode 9 or higher, and Swift 4 or higher.

## Analytics

- GPA: 2.87
- Lines: 1745

## License 

Swizzle is released under the [MIT License](https://github.com/SafelySwift/Swizzle/blob/prerelease/LICENSE)

## Code of Conduct

We will not tolerate unacceptable behavior. If you feel that someone has made an action that is not appropreiate, be sure to contact me at [safelyswift@gmail.com](mailto:safelyswift@gmail.com).

Read the [full document](https://github.com/SafelySwift/Swizzle/blob/prerelease/CODE_OF_CONDUCT.md) for more details.

## Notes

- The interpreter is dynamically typed, while the compiler will be statically typed.
