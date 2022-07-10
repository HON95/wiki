---
title: C++
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

### Functions

- (New in C++) Supports function overloading.

### Classes and Structs

- (New in C++) Supports classes with member functions. Structs can also have members functions now.
- (New in C++) Structs no longer need the `struct` part in variable declarations.

#### Constructors and Destructors

- One or more constructors may be declared using overloading.
- Only one destructor may be declared (since it takes no arguments).
- Use virtual destructors when using inheritance to avoid calling the wrong destructor.
- Default constructors are _usually_ called implicitly when leaving out the `()`, but if you want the object in a consistent state, you may want to explicitly specify it (e.g. `A a()`, `new A()`, `new A[n]()`), to avoid subtle cases where the default constructor is called but certain member variables are still left uninitialized. (See default and value initialization.)
- **TODO** `= delete` and `= default`.
- Constructors may use initializer lists to initialize member variables from constructor arguments. The initializer list is called before the constructor body.
- After the destructor executed, the destructors for all direct member variables are called.
- See the rule of three/five below for more info about copy and move constructors.

#### Visibility (aka Access Modifiers)

- For class/struct members (fields and functions), declared using `private:`/`public:`/`protected:` modifiers in the class declaration, applies to all members below it.
- Modifiers:
    - Private: Only member functions (and friend classes/functions) can access the member.
    - Protected: Like private, but derived classes can access the member too.
    - Public: All parts of the program can access the member.
- Defaults: Classes default to private, structs to public (pretty much the only difference between classes and structs in C++).
- Friend class/function: Declared in the class/struct itself (`friend {class|struct|function|<empty>} <name>`), allows the referenced class/struct/function to access private and protected members of this class. The `{class|struct|function}` part may be left out if the type is already declared, as using it redeclares the type (which may cause subtle errors).

#### Inheritance

- **TODO**
- Use virtual destructors to avoid calling the wrong destructor.

### Enums

- (New in C++) Supports enum classes (in addition to plain enums).

### Strings

- (New with C++) `string` is generally used instead of raw `char *`, which is more sophisticated and handles its own resource usage.

### Arrays and Containers

- (New with C++) `array` (static), `vector` (dynamic), `map` (dynamic) etc. instead of raw arrays (`A a[]` or `A *a`).
- Using `new A[n]` will default-initialize the elements, meaning classes will have their default constructor called but primitive types will not get assigned any value (i.e. they may contain garbage data after initialization). To null-initialize an array of primitives, use `new A[]()` instead (has no effect for class/struct types).

### Exceptions

- (New in C++) Supports exceptions (for better or worse).

### Miscellanea

- **Plain old data (POD) types**: Primitive types or classes/structs without constructors, destructors and virtual member functions.
- **Placement new**: Allows allocating data within an existing allocation, e.g. to avoid fragmentation when allocating many objects. "Placement delete" does not exist.

## Mechanisms and Idioms

### Resource Acquisition is Initialization (RAII)

- RAII is a way to tie a resource held by an object to the objects lifetime, thus automatically allocating the resource when the object is constructed and automatically deallocating the resource when the object is destructed.
- It's typically implemented using a class with `new` in the constructor and `delete` in the destructor.
- Examples:
    - `string` and `vector` manages their own resources (no manual `new[]` or `delete[]`).
    - `unique_ptr` and `shared_ptr` makes it simpler to manage heap-allocated elements, including C-style arrays.
    - `std::lock_guard<mutex>` makes automatically locks the mutex and automatically releases it when deallocated (e.g. when returning from the function).

### Argument-dependent lookup (ADL)

- ADL is a language feature where the namespace for a function or overloaded operator does not have to be qualified if at least one argument type is defined in the namespace of the function.
- Examples:
    - This is frequently used e.g. with `friend ostream &operator<<(ostream& os, A &a)` in a certain namespace, such that `std::cout << a` may be used in any namespace even though `operator<<` has not been defined for `A` neither in the standard library nor any active namespaces (and `friend` since it can't be a class member due to the parameter order).
    - This is also used to implement `swap(a1, a2)` functions, with a fallback to `std::swap` if `using std::swap` is specified.

### The Rule of Zero/Three/Five

- The rule of three denotes that if you need to explicitly declare either the destructor, copy constructor or copy assignment operator, you probably need to explicitly declare all of them.
- The rule of five extends the rule of three with the move constructor and move assignment operator (introduced in C++11).
- For simple classes with no resources to manage directly, the rule of zero is typically good enough (no special member functions).

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

- Don't specify `using namespace std`, keep the `std::` specifiers.

{% include footer.md %}
