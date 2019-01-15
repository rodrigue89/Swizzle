# Tutorial #5: Objects

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

A object defines a set of references to other objects called properties. It allows you to group related things together. Here is an example of an object:

```
objc Person {
    ref name: String;
    ref age: String;
}
```

In this case, the property `name` is referring to the name of the person. If the object was representing a file, then the property name means something else.

Objects are created using initializers. These look similar to function calls except they have the name of the object as the call name and the properties as parameters.

```
var p = Person("Mary", 12)
```

You can access properties on an object using a dot ( `.`) followed by the property name.

```
print("Person p is named", p.name);
```

With dot notation you can also set property values.

```
p.name = "Norton";
print("p's name is now", p.name);
```

## Takeaway

Objects are useful for grouping related things and make code easier to understand by providing context.

[Previous: Functions](https://github.com/SafelySwift/Swizzle/blob/master/Tutorials/Functions%20(%234).md)
