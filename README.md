<p align="center">
<img src="https://raw.githubusercontent.com/SafelySwift/Swizzle/prerelease/Images/Swizzle%20Logo%20Wide%20New.png" alt="Swizzle Banner">
</p>

```
struct Person {
    public ref name: String;
    public ref age: Float;
}

var vec = Vector4(1, 2, 3, 4);
swizzle4(vec, "wxxy");

func eat(person: Person) {
    print("Eating", person.name, #, ". They were only", person.age, "years old.");
}
```

> Some code in Swizzle

#### Quick Links

- [Overview](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/README.md#what-is-it)
- [What is included](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/README.md#what-is-included)
- [How to use it](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/README.md#how-can-i-use-it)
- [Versions](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/README.md#versions)
- [Documentation](https://github.com/SafelySwift/Swizzle/wiki)
- [Analytics](https://codebeat.co/projects/github-com-safelyswift-swizzle-swizzle-1.0)

## Roadmap
- Basic
  - [x] Implement lexer
    - [ ] Speed up lexer
  - [x] Parsing 
  - [x] Basic scope resolution
- Analysis
  - [ ] Static type checking
- Compiling
  - [ ] Compile time custom phases
  - [ ] Building the IR
- Executing
  - [x] Stage 2 Compiler
  - [x] Virtual Machine

## What is it?

Swizzle is a fast, static typed programming language that is all new and all fun. Swizzle has a syntax that is similar to other popular programming languages.

Though Swizzle is still in development, I would say it is slightly functional.

Here is a (small) list of Swizzle's functionality.
- Variables and constants
- User defined functions
- Control flow (if, while, for)
- Operators
- Custom structures
- Extension of structures
- Protocols

For more, visit the [documentation](https://github.com/SafelySwift/Swizzle/wiki).

## The Goal

Swizzle attempts to fill in a niche for graphics programming. There are not many simple, powerful and fast compiled langauges for this purpose. Swizzle hopes to succeed in all those categories. 

**Tutorials:**
- [Hello World](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Hello%20World%20(%231).md)
- [Comments](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Comments%20(%232).md)
- [Variables](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Variables%20(%233).md)
- [Functions](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Functions%20(%234).md)
- [Structures](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Structures%20(%235).md)

Similar to many languages, Swizzle requires semicolons to terminate statements. Even though this may be annoying, it actually helps make the error messages better so you can write cleaner and safer code. See [this pull request](https://github.com/SafelySwift/Swizzle/pull/36) if you do not want to use semicolons.

## What is included?

Swizzle comes with an compiler and virtual machine. It uses 2 stages in compiling. One stage is for turning the AST into an IR. This is where Swizzle checka to make sure you did not write anything wrong. The next stage is turning the IR into bytecode, which can be interpreted by the vm. Swizzle is written in Swift so there is not much of a performance loss in all these stages.


## How can I use it?

You cannot use it as of now because the source code is still in active development.

## Contributing

Swizzle is not perfect. Or rather only as perfect as the people who help. If you want to make Swizzle a better language or want to see a feature added/report a bug, see [the contributing guidelines](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/CONTRIBUTING.md)!

## Versions

The latest feature release is [v0.3](https://github.com/SafelySwift/Swizzle/releases/tag/v0.3.0).
The latest small release is [v0.3.3](https://github.com/SafelySwift/Swizzle/releases/tag/v0.3.3).

For more information on releases, go [here](https://github.com/SafelySwift/Swizzle/releases).

## Beyond Swizzle

- My [reddit](https://www.reddit.com/user/SafelySwift) is a great place to chat about ideas or discuss coding. There is also the dedicated [subreddit](https://www.reddit.com/r/swizzle_lang/).- The [Crafting Interpreters](http://craftinginterpreters.com) book is a really helpful reference.

## Requirements

You will need Xcode 9 or higher, and Swift 4 or higher.

## License 

Swizzle is released under the [MIT License](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/LICENSE)

## Code of Conduct

We will not tolerate unacceptable behavior. If you feel that someone has made an action that is not appropreiate, be sure to contact me at [safelyswift@gmail.com](mailto:safelyswift@gmail.com).

Read the [full document](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/CODE_OF_CONDUCT.md) for more details.
