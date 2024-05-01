---
title: C++ (Language)
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## Changes from C

- Classes and structs:
    - Supports classes with member functions. Structs can also have members functions now.
    - Structs no longer need the `struct` part in variable declarations.
- Enum:
    - Supports enum classes (in addition to plain enums).
- Namespaces:
    - Yes.
- Libraries:
    - C++ provides `c<name>` variants of the `<name>.h` C libraries, which generally puts symbols inside the `std` namespace.
- Pointers:
    - Provides smart pointers (`unique_ptr`, `shared_ptr` etc.) as an alternative to raw pointers. Smart pointers automatically deallocates the references data once no longer referenced. This helps to reduce memory leaks.
- (More &hellip;)

## Features

(Mainly stuff that's different from C.)

### Namespaces

- (New in C++) Yes.
- To assign functions and variables to a namespace, put it inside a `namespace [name] {}` bracket, declared top-level in the file.
- Omit the name for an unnamed/anonymous namespace, such that symbols inside can't be referred to from outside (similar to how `static` is used for compilation unit-scope).
- To use symbols from a namespace, prefix with `<name>::`.
- To use symbols from the global namespace, prefix with `::`.
- To import all symbols from a namespace, specify `using namespace <namespace>`.
- To import specific symbols from a namespace, specify `using <namespace>::<symbol>`.
- Most C libraries are migrated into the `std` namespace, in header files with a `c` prepended and no `.h` extension (e.g. `math.h` becomes `cmath`).

### Functions

- (New in C++) Supports function overloading.

### Classes and Structs

- (New in C++) Supports classes with member functions. Structs can also have members functions now.
- (New in C++) Structs no longer need the `struct` part in variable declarations.

#### Constructors and Destructors

- One or more constructors may be declared using overloading.
- Only one destructor may be declared (since it takes no arguments).
- The default constructor is the one constructor that takes no arguments and is implicitly created.
- Default constructors are _usually_ called implicitly when leaving out the `()`, but if you want the object in a consistent state, you may want to explicitly specify it (e.g. `A a()`, `new A()`, `new A[n]()`), to avoid subtle cases where the default constructor is called but certain member variables are still left uninitialized. (See default and value initialization.)
- **TODO** `= delete` and `= default`.
- Constructors may use initializer lists to initialize member variables from constructor arguments. The initializer list is called before the constructor body.
- After the destructor has executed (for the specified type or the most-derived if virtual), the destructors for all direct member variables are called.
- `delete` implicitly calls the destructor of a single object, `delete[]` for all objects in the array.
- One-argument constructors may be used for inplicit conversion, such that e.g. `Balance b = 100` implicitly calls the `Balance(long value)` constructor. Use keyword `explicit` for the constructor declaration to deny implicit conversions (only valid for one-argument constructors).
- See the rule of three/five below for more info about copy and move constructors.

#### Access Levels (aka Visibility)

- For class/struct members (fields and functions), declared using `private:`/`public:`/`protected:` modifiers in the class declaration, applies to all members below it.
- Modifiers:
    - Private: Only member functions (and friend classes/functions) can access the member.
    - Protected: Like private, but derived classes can access the member too.
    - Public: All parts of the program can access the member.
- Defaults: Classes default to private, structs to public (pretty much the only difference between classes and structs in C++).
- Friend class/function: Declared in the class/struct itself (`friend {class|struct|function|<empty>} <name>`), allows the referenced class/struct/function to access private and protected members of this class. The `{class|struct|function}` part may be left out if the type is already declared, as using it redeclares the type (which may cause subtle errors).

#### Inheritance

- Derived classess (aka subclasses) inherit one or more base classes (aka superclasses), using syntax `class B : public A`.
- Derived classes may inherit multiple base classes by specifying multiple (comma-separated) base classes (with individual access levels) in the class declaration. For duplicate inherited members, scopes must be specified in order to refer to the right version.
- For cases of multiple inheritance where base classes derive the same base class higher in the inheritance hierarchy, base classses may be marked as virtual (called virtual base classes) derived class declarations to avoid getting duplicated members from the multiple inherited base class.
- To control the access level of inherited members, specify `public`, `protected` or `private` in the inheritance part of the declaration (`class B : public/protected/private A`).
    - `public` leaves inherited member access levels unchanged.
    - `protected` makes inherited public members protected.
    - `private` makes all inherited members private.
- Use virtual member functions (`virtual`) to use polymorphism (aka dynamic bindings), in order to override member functions of base classes. Not marking the member as virtual will instead call the member function of the current class the instantiated class is assigned to, which may cause unexpected behavior. When a member function is marked at some point in the derivation chain, it is virtual from that point regardless of whether derived classes mark it as such too, but it's useful for documentation purposed to mark it in derived classes too.
- Use virtual destructors to avoid breaking the polymorphism and potentially cause memory leaks.
- For construction, the most base class is constructed first. The default constructors of base classes are implicitly called. To call a specific non-default constructor of the base class, specify it as the first element in the initialization list (`sub_class(...) : super_class(...) {}`).
- For destruction, the most derived class is destructed first.
- Member functions may be purely virtual by specifying both `virtual` and `= 0` in the declaration, meaning any concrete, derived classes need to implement it. A class with any pure virtual member functions is called an abstract class since it can't be instantiated. (Although, a definition of the pure virtual member function may actually be provided for the same class that declares it as pure virtual. Destructors may also be declared as pure virtual, but need an implementation in the same class.)
- Keep in mind that the use of virtual mechanisms (aka dynamic bindings) may reduce performance as it incurs a required lookup at run-time.
- Remember to pass-by-reference to avoid implicit copying and breaking polymorphism.

### Enums

- (New in C++) Supports enum classes (in addition to plain enums).

### Strings

- `string` is generally used instead of raw `char *` as in C, which is more sophisticated and handles its own resource usage.
- Raw string literals may be used to avoid interpreting escape sequences and quotation marks, e.g. `R"--(File("yolo")\n)--"` contains string `File("yolo")\n` (the `--` part used here is optional and may be anything).

### Streams

- For writing to STDOUT/STDERR and reading from STDIN, C++ uses the `cout`/`cerr`/`clog` and `cin` streams from the `iostream` library, unlike C which uses `print` variants (`clog` is the buffered version of `cerr`).
- To set `cout` to print floating-point numbers as fixed-precision, set `cout.setf(ios::fixed)` and `cout.precision(3)` (for 3 decimals).

### Arrays and Containers

- Containers like `array` (static), `vector` (dynamic), `map` (dynamic) etc. are recommended instead of raw arrays as in C (`A a[]` or `A *a`).
- Using `new A[n]` will default-initialize the elements, meaning classes will have their default constructor called but primitive types will not get assigned any value (i.e. they may contain garbage data after initialization). To null-initialize an array of primitives, use `new A[]()` instead (has no effect for class/struct types).
- `vector`:
    - It has a capacity and a size. Use `.reserve(n)` to change the capacity (same as size or larger) and `.resize(n)` to change the size (create new elements or drop the tail).

### Templates

- Classes and functions may be templated with type (`class/typename T`) and non-type (e.g. `int t`) arguments in order to generate multiple variants at compile-time. Instantiations of them for specific types are called specializations of the template.
- Templated classes/functions are preceded by e.g. `template <class T>`. If multiple types are required, comma-separate them.
- `class` and `typename` are generally interchangable, but there are some special cases where only one is appropriate (e.g. dependent types).
- Non-type arguments must be constant. They're useful e.g. to allocate storage for a specified number of elements (tuples and constant-length arrays).
- Explicit specialization is typically used for overloading classes/functions for specific types. It uses `template <>` (no types here), then e.g. `<double>` (the type to overload for) after the class/function name.

### Exceptions

- (New in C++) Supports exceptions (for better or worse).
- Typical `try/catch(Exception &ex)` and `throw ex` syntax. `catch(...)` is used as catch-all.
- For multiple `catch` clauses, the first one to match is used. If no clauses match, it's thrown further up the stack.
- Standard exceptions are derived from the `exception` class from library `exception`. It has a `what()` function to get its name.
- Receive exceptions by reference to avoid breaking polymorphism.
- Exception specifications:
    - Used to guarantee which exceptions a function may throw.
    - Specified as `throw(ExceptionA, ExceptionB)` after the function signature (both in the declaration and definition).
    - An empty list means that it can't throw any exceptions.
    - No specification means that it can throw any exception.
    - An overridden member function in a derived class must be at least as restructive as in the base class.
    - If it throws an exception not specified in the list, the standard function `unexpected` is called, which terminates the program by default.
- Examples:
    - Use `new(nothrow) ...` to return a null-pointer instead of throwing a `bad_cast` exception if the allocation fails.

### Operator Overloading

- A function `operatorX` for some unary or binary operator `X` (e.g. `<<` or `+`). May be part of a class, where the implicit parameter becomes the first argument.
- The associativity, precedence and arity of the operator can't be changed.
- The `()` operator may be overloaded to create function objects.
- The `new/new[]/delete/delete[]` operators (including placement new) may also be overloaded in order to implement custom resource management.
- Examples:
    - Used for I/O streams to print stuff with `<<`.
    - Used by classes to implement/override the copy and move assignment operators.

### Casts

- C-style casting (e.g. `(int) 1.0`) is allowed but not recommended. No checks are performed so usage is unsafe.
- C++-style casts look like `int b = static_cast<int>(a)` (bad example).
- `dynamic_cast<>()`:
    - Used to cast objects between derived classes of some shared base class, either by upcasting, downcasting or crosscasting. The class must (?) be polymorphic, i.e. using virtual functions.
    - Runtime type information must be turned on for it to work properly, although the compiler catches whichever errors it can.
    - For illegal casts with pointer types, it returns a null-pointer. For reference types, it throws an exception.
- `static_cast<>()`:
    - Like `dynamic_cast`, but without the runtime checks so it can cast between non-polymorphic types etc. It's more similar to C-style casts.
- `const_cast<>()`:
    - Used to cast away `const` and/or `volatile`.
    - Considered safe only if the data was initially declared without `const`/`volatile`.
- `reinterpret_cast<>()`:
    - Used to cast between any pointer types, including to/from integral types.
    - Typically only used for byte-level data fuckery.
- About runtime type informatin (RTTI):
    - RTTI may not be embedded by default, since C++ is a statically typed language and doesn't need it during runtime (with significant exceptions).
    - `typeid()` returns type info about a value, in the form of a `type_info`. The `typeinfo` header is required to use it.
    - For polymorphic types, `typeid()` returns the dynamic type.
    - `type_info` overloads `==` and `!=` in order to easily compare types.
    - `type_info` contains a `name()` method to get the name of the type.

### Miscellanea

- **Plain old data (POD) types**: Primitive types or classes/structs without constructors, destructors and virtual member functions.
- **Placement new**: Allows allocating data within an existing allocation, e.g. to avoid fragmentation when allocating many objects. "Placement delete" does not exist.

## Mechanisms and Idioms

### Asserts

- Asserts may be used to implement pre-conditions and post-conditions when deloping applications.
- Asserts can be disabled when building for release by setting `#define NDEBUG` (before the `cassert` import) or by specifying `-DNDEBUG` for GCC.
- Include `cassert` to use macro `void assert(bool)`.

### Resource Acquisition is Initialization (RAII)

- RAII is a way to tie a resource held by an object to the objects lifetime, thus automatically allocating the resource when the object is constructed and automatically deallocating the resource when the object is destructed.
- It's typically implemented using a class with `new` in the constructor and `delete` in the destructor.
- Examples:
    - `string` and `vector` manages their own resources (no manual `new[]` or `delete[]`).
    - `unique_ptr` and `shared_ptr` makes it simpler to manage heap-allocated elements, including C-style arrays.
    - `std::lock_guard<mutex>` automatically locks the mutex when created and automatically releases it when deallocated (e.g. when returning from the function).

### Argument-dependent lookup (ADL)

- ADL is a language feature where the namespace for a function or overloaded operator does not have to be qualified if at least one argument type is defined in the namespace of the function.
- Examples:
    - This is frequently used e.g. with `friend ostream &operator<<(ostream& os, A &a)` in a certain namespace, such that `std::cout << a` may be used in any namespace even though `operator<<` has not been defined for `A` neither in the standard library nor any active namespaces (and `friend` since it can't be a class member due to the parameter order).
    - This is also used to implement `swap(a1, a2)` functions, with a fallback to `std::swap` if `using std::swap` is specified.

### The Rule of Zero/Three/Five

- The rule of three denotes that if you need to explicitly declare either the destructor, copy constructor or copy assignment operator, you probably need to explicitly declare all of them.
- The rule of five extends the rule of three with the move constructor and move assignment operator (introduced in C++11).
- For simple classes with no resources to manage directly, the rule of zero is typically good enough (no special member functions).
- For polymorphic classes, it may be an appropriate idea to implement a virtual `clone()` function instead of a the copy constructor.

#### Copy Semantics

- Classes (and structs) are treated with value semantics by default, meaning a shallow copy is implicitly performed when doing `A a2(a1)` (copy constructor) or `A a2 = a1` (copy assignment operator).
- Both the copy constructor and copy assignment operator are implicitly declared unless declared explicitly. Both will perform a shallow copy of all member variables.
- The copy constructor generally has signature `A(const A&)`.
- The copy assignment operator generally has signature `A &operator=(const A &)`.
- If the class is managing resources (e.g. heap-allocates an array in some constructor), the copy constructor and copy assignment operator should be explicitly defined to avoid memory errors (e.g. where multiple objects' destructors try to deallocate the same array due to shallow copies).
- While the copy constructor only allocates new state, the copy assignment operator also has to cleanup any existing allocations first. See the _copy-and-swap_ idiom for how to implement the copy assignment operator.
- If the class should not be copyable, simply declare the copy constructor and copy assignment operator as deleted.

#### Move Semantics

- The move constructor generally has signature `A(const A&&)`.
- The move assignment operator generally has signature `A &operator=(const A &&)`.
- Typical move constructor implementation:
    - Construct the local instance using the default constructor with delegated constructors syntax.
    - Swap the local instance's members with the other instance's members (e.g. using the same swap function as you may have implemented for the _copy-and-swap_ idiom.
- Typical move assigmnent implementation:
    - Just like the move constructor, but with the local class already constructed.
- Since both the constructor and operator in typical implementations never throw exceptions, they may be marked as `noexcept`.

### Copy-and-Swap

- The copy-and-swap idium is a way to implement the copy assignment operator in the rule of three that provides code deduplication and (optionally) a strong exception guarantee. (Only the swap part is required for move semantics, i.e. thr rule of five, so only copy semantics are covered here.)
- It depends on a functioning copy constructor and destructor, as well as some swap function.
- Steps (within the copy assignment operator):
    - Change the `other` argument to call-by-value (noe `&`), so it automatically creates a full copy using the copy constructor.
    - Use some swap function to swap all the member variables from the argument instance with the local instance.
    - Let the function return, such that the argument instance is destructed along with the old data from this instance.
- The above steps handle the following:
    - Not failing if trying to copy itself. An alternative simple solution is a self-test (`this == &other`), which makes sure nothing happens if equal, but self-assignment almost never happens so it's better to optimize for the unequal case.
    - Provides a strong exception guarantee, meaning it leaves the object untouched if any exception happens.
- The swapping steps may alternatively be put into a `friend void swap(A &a1, A &a2)` function to allow swapping from outside the copy assignment operator.

### Miscellanea

- Don't rely on default-initialization, the rules are really clunky (some things are zero-initialized, some things are not initialized at all).
- Don't specify `using namespace std`, keep the `std::` specifiers.
- Never use `wchar_t` or `wstring` (e.g. for UTF-16) unless you have to (e.g. for library calls), use regular `char` and `string` (e.g. for UTF-8).

{% include footer.md %}
