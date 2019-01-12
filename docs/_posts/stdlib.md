Swizzle comes with a few built-in functions and objects.
***


## Functions

- [Basic Functions](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library/#basic-functions)
- [File Handling](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library/#file-handling)
- [Vectors](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library/#vectors)
- [Miscellaneous](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library/#miscellaneous)

### Basic Functions

- #### `print(...)`:

  **Usage**

  The print function is used for outputting data to the console, usually for debugging or program output.

  **Discussion**

  The print function outputs the given arguments to the console separated by spaces and terminated by a new line.

  **Examples**

  ```
  print("Hello, world!");
  ```

- #### `formOperation(r: String, lhs: Float, rhs: Float)`:

  Where `Operation` is one of the following binary operations:

      - Sum (addition)
      - Dif (subtraction)
      - Prod (multiplication)
      - Quo (division)
      - Rem (remainder)

  **Usage**

  While Swizzle does not support operators yet, these functions will be handy when arithmetic operations are  
  necessary.

  **Discussion**

  The form{Operation} function dumps the result of the corresponding binary expression evaluated with the 2nd and
  3rd parameters to the variable named by the 1st parameter, assuming it exists.

  **Examples**

  ```
  formSum("r", 1, 2); // r = 3 now
  ```

### File Handling

- #### `fileManagerDocumentGetString(output: String, path: String)`

  **Usage**

  This function is used to read files.

  **Discussion**

  The `fileManagerDocumentGetString` function reads a file at the given path in the current user's Documents directory.

  **Examples**

  ```
  var r = "";
  fileManagerDocumentGetString("r", "My/Path/To/File.txt");
  // r == your file contents
  ```

- #### `fileManagerDocumentWriteString(text: String, path: String)`

  **Usage**

  This function is used to write files.

  **Discussion**

  The `fileManagerDocumentWriteString` function writes the text given to the file at the given path in the current user's Documents directory.

  **Examples**

  ```
  fileManagerDocumentWriteString("Hello, world!", "My/Path/To/File.txt");
  // Your file mow has the contents "Hello, world!"
  ```

### Vectors

- #### `swizzle4(vector: Vector4, newLayout: String)`:
  
  **Usage**

  The swizzle4 function is used to swizzle the contents of a vector.

  **Discussion**

  The swizzle4 function reorganizes the vector based on the layout described the the second parameter,

  **Examples**

  ```
  swizzle4(vector, "wzzy");
  ```

### Miscellaneous

- #### `random(...)`:

  **Usage**

  The random function is used for randomizing a list of objects

  **Discussion**

  The random function uses the common and efficient Fisher and Yates shuffle algorithm to shuffle the elements of
  the list.

  > This function will be added to the standard library once lists are created. Currently you can implement a
  dummy version of this in Swift using the `registerExternalFunction(name:block:)` method of `Interpreter` as
  such:

  ```swift
  i.registerExternalFunction(name: "random") { input in
    var args = input.args
    for index in args.indices {
      let rand = Int(arc4random_uniform(UInt32(args.count)))
      args.swapAt(index, rand)
    }
    print(args)
  }
  ```

## Objects

- **Basic**
  - [Float](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library#float)
  - [String](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library#string)
  - [Point](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library#point)
  - [Color](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library#color)
- **Advanced**
  - [Vector4](https://github.com/SafelySwift/Swizzle/wiki/Standard-Library#vector4)

- ### Float:

  ```
  objc Float {
    %{decl Float *value;}
  }
  ```

  Float represents a 32-bit precision floating-point type.

  **Discussion**

  A `Float` can only be initialized with a floating-point literal.

  **Examples**

  ```
  4.0, 22, -1000
  ```

- ### String:

  ```
  objc String {
    %{decl String *value;}
  }
  ```

  String represents a unicode-aware string.

  **Discussion**

  A `String` can only be initialized with a string literal.

  **Examples**

  ```
  "Banana", "393", "true"
  ```

- ### Point

  ```
  objc Point {
    decl x; decl y;
  }
  ```

  Point represents a position on a 2D plane.

  **Discussion**

  A point holds a reference to two `Float` objects, one for the x coordinate and one for the y.

  **Examples**

  ```
  Point(0, 0), Point(100, 100), Point(-122, 3838383838.433)
  ```

- ### Color

  ```
  objc Color {
    decl hue; decl saturation; decl brightness; decl alpha;
  }
  ```

  Color represents a [HSV](https://en.wikipedia.org/wiki/HSL_and_HSV) color

  **Discussion**

  A color holds a reference to four `Float` objects, each for a HSVA component.

  **Examples**

  ```
  Color(1, 1, 1, 1), Color(0.4, 0.4, 0.2, 0.5)
  ```

- ### Vector4

  ```
  objc Vector4 {
    decl w; decl x; decl y; decl z;
  }
  ```

  Vector4 is a vector in a four dimensional space.

  **Discussion**

  Vector4 represents a vector with four parameters of type `Float`.
