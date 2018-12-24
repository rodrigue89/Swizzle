# Tutorial #x: Debugging.

Sometimes your code just does not work as you want it to. Instead of yelling at the top of your lungs and throwing your computer out the window, we will go through all the things you can do to make your code work again.

1. Double-check your code.

Did you make an obvious [syntax](https://github.com/SafelySwift/Swizzle/wiki/Syntax) error? You should fix that, and if the code still does not work, go on to step...
    
2. Look at the console.

Configure the interpreter for stack trace or add that to the  `var options: CodeFile.Options` property of the code file you are using.

This is the output of the "eat" program with the stack trace flag provided:

```
Frame #19: Eating Tim cause why not? 

Trace:
------
*** Frame #1: First iteration: ObjectStatement
*** Frame #2: Next iteration: ObjectStatement
*** Frame #3: Next iteration: FunctionStatement
*** Frame #4: Visiting declaration of 'eat(_:)'.
*** Frame #5: Next iteration: AssignStatement
*** Frame #6: Visiting assignment named 'p'.
*** Frame #7: Represents a constructor.
*** Frame #8: Constructing an object with type of 'Person' and storing in variable named 'p'
*** Frame #9: Getting data from expression.
*** Frame #10: Getting data from expression.
*** Frame #11: Next iteration: CallStatement
*** Frame #12: Visiting a function call at line 11
*** Frame #13: Getting data from expression. (caller: frame #12)
*** Frame #14: Getting data from expression.
*** Frame #15: Visiting a function call
*** Frame #16: Getting data from expression. (caller: frame #15)
*** Frame #17: Getting data from expression.
*** Frame #18: Getting data from expression.
*** Frame #19: Function 'print(...)' was executed.
*** Frame #20: Function 'eat(person:)' was executed.
----------------------------
Execution took 0.26 seconds.
```
I want you to take this in: you, the programmer, can actually see what is going on behind the scenes. Is that not amazing?

> Look at all the `Frame #X`s. Those tell you what stage the interpeter is with in executing your program. 

Another of Swizzle's debugging tools is allowing you to inspect each frame. Here is an example, where `i` is the interpreter:

```swift
if let debug = i.debug(frame: 4) {
    print(debug.info!)
}
```

That outputs this:

```
Statement: FunctionStatement(name: (type: identifier, value: \'eat\', line: 6), args: [(type: identifier, value: \'person\', line: 6)], body: [CallStatement(name: (type: identifier, value: \'print\', line: 7), args: [Expression(rep: anyToken((type: literal, literal: \"Eating\", line: 7))), Expression(rep: access(AccessStatement(object: (type: identifier, value: \'person\', line: 7), key: (type: identifier, value: \'name\', line: 7)))), Expression(rep: anyToken((type: literal, literal: \"cause why not?\", line: 7)))])]).
```
Useless, right? Actually I think the opposite. This way, you can see what actually made it into your program.  If you see something missing, like for example you had another call inside your function statement, you can go look back at your code to see what was the problem.

Another use of this tool is to find out what went wrong in your program. I changed the line `eat(p);` to `eat();` to see what happens. When I ran the code, this is a key section of the trace I noticed:

```
*** Frame #12: Visiting a function call at line 11
*** Frame #13: Incorrect number of arguments. Expected 1, given: 0. (caller: frame #12)
*** Frame #14: Arguments are not variable length.
*** Frame #15: Function 'eat(person:)' was executed.
```

I am still a bit confused, so I tried the last step...

3. Use error handling

The interpeter's execute function is a throwing function. Therefore, instead of usingt `try?` and ingoring the error, we can wrap it in a do-catch block!. The error output is:

```
Expected 1 argument in function call to 'eat(_:)'
```

That makes more sense. The function `eat` takes 1 argument, and I did not give it any!

## Takeaway

In summary, writing code can be both fun and painful. However, if you have the knowledge and ability to debug, you can take the pain part out of writing code, and just keep the fun part!
