# Tutorial #4: Objects

In the last tutorial, we designed a function that can greet anyone. What if you wanted to extend the function so it also printed their age? Well, you would have to extend the function like this:

```
func greet(name, age) {
print("Hello,", name, #, "!");
    print("You are now", age, #, ".");
}

greet("Jamil", 10);

// Prints: Hello, Jamil!
//         You are now 10.
```

But we have to use 2 parameters, What if I told you there was a way to do the exact same thing with just 1 parameter. That is where objects come in.

A object defines a set of properties. It allows you to group related things together. Here is an example of an object:

```
objc Person {
    decl name;
    decl age;
}
```

> **Important:** All object names must be capital so that the parser can recognize constructors. That is how it distinguishes between a function and an initializer.

Objects are created using initializers. These look similar to function calls except they have the name of the object as the call name and the properties as parameters.

```
var p = Person("Mary", 12)
```

## Takeaway
