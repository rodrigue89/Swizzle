# Performance

Swizzle was designed from the ground up in pure Swift with performance in mind. Swizzle uses a simple object model that can access references by index.

Imagine this hypothetical structure

```
objc URL {
  ref string: String;
  ref flag: Int;
}
```

Swizzle converts this into the `AST`, so now we have this (abstract) representation:

```
Object(name: "URL", references: [
  (access: "exposed", name: "string", type: "String"),
  (access: "exposed", name: "flag", type: "Int")
])
```

Finally, the compiler and vm refer to this when a new instance of `URL` is created. They store the object as a pointer to values.

```
Address:  | x                 | x+1              |
          | ------------------|------------------|
Value:    | "www.example.com" | 0                |
```

- Swizzle: 0.000121 seconds
- C: 0.000002 seconds
- C++: 0.000005799 seconds
- Objective-C: 0.000005 seconds
- Swift: 0.000014 seconds
- Python: 0.000003 seconds
