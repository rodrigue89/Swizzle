# Tutorial #5: Structures

In the last tutorial, we designed a function that can greet anyone. What if you wanted to extend the function so it also printed their age? Well, you would have to extend the function like this:

```
func greet(name: String, age: Float) {
    print("Hello,", name, #, "!");
    print("You are now", age, #, ".");
}

greet("Jamil", 10);

// Prints: Hello, Jamil!
//         You are now 10.
```

But we have to use 2 parameters, What if I told you there was a way to do the exact same thing with just 1 parameter. That is where structures come in.

A structure defines a set of references to other structures called properties. It allows you to group related things together. Here is an example of an object:

```
structure Person {
    ref name: String;
    ref age: String;
}
```

In this case, the property `name` is referring to the name of the person. If the structure was representing a file, then the property name means something else.

Structure are created using initializers. These look similar to function calls except they have the name of the structure as the call name and the properties as parameters.

```
var p = Person("Mary", 12);
```

You can access properties on an structure using a dot ( `.`) followed by the property name.

```
print("Person p is named", p.name);
```

With dot notation you can also set property values.

```
p.name = "Norton";
print("p's name is now", p.name);
```

Now we have enough knowledge to make our function:

```
func greet(person: Person) {
    print("Hello,", person.name, #, "!");
    print("You are now", person.age, #, ".");
}
```

## Takeaway

Structure are useful for grouping related things and make code easier to understand by providing context.

[Previous: Functions](https://github.com/SafelySwift/Swizzle/blob/master/Tutorials/Functions%20(%234).md) | [Next: Protocols](https://github.com/SafelySwift/Swizzle/blob/swizzle-1.0/Tutorials/Protocols%20(%236).md)
