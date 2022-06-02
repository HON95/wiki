---
title: Data Stuff
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## IEEE 754 Floating Points

## Linked Lists

### XOR Linked Lists

- A compressed version of doubly linked lists, where it stores the XOR of the previous and next pointers instead of storing them individually. The "other" pointer is retrieved by providing the pointer from the direction you're traversing from.
- One of the neighbor pointers is always required to get the other neighbor pointer, so traversing from a random internal node (without any neighbor pointers) isn't possible.
- Alternatives include addition linked lists and subtraction linked lists.
- The concept may also be applied to e.g. binary search trees.
- Debuggers, garbage collection etc. may get confused.

### Unrolled Linked Lists

- A linked list variation where each node stores multiple elements.
- This might significantly increase cache performance, reduce fragmentation, and reduce the reference-to-data ratio.
- Specifically, it contains an element array and an optional element counter instead of a single element.

## Miscellanea

### Tagged Pointers

- A method of embedding metadata (called tags) into unused bits of a pointer, typically in the most or least significant bits. This avoids wasting space (and cache lines) with a separate data structure containing the metadata.
- This is an alternative to tagged architectures, where extra hardware bits are reserved for the tags.
- The tags may contain e.g. type information, read-only flag, dirty flag, etc.
- Tags may also indicate that the pointer should be interpreted as a number, e.g. a small integer (SMI).
- Tagged pointers may provide a null type, providing an alternative to null pointers.
- For certain systems, the tags must be masked out before the pointer is accessed. For other systems this is not required as the tag bits are simply ignored.
- Debuggers, garbage collection etc. may get confused.
- Examples:
    - For example, for byte-addressable, word-aligned systems, the least significant bits representing the address within the word will always be zero and may thus be used for the tag.
    - For certain systems, the most significant bits may be unused (e.g. with 64-bit virtual addressing where only 48 bits are used), allowing them to be used for tags.
    - For CUDA, memory allocations are guaranteed to be aligned to 256 bytes, giving 8 bits for potential tagging. Remember to mask out the tag before accessing the pointer, though.

### NaN Boxing

- A method of embedding metadata into NaN floating point numbers (typically doubles).
- An alternative to tagged pointers.
- May contain doubles when non-NaN (duh), similar to how tagged pointers may contain SMIs.

### Pointer Compression

- Storing pointers (e.g. 64-bit) as a base and a set of offsets (e.g. 32-bit + 32-bit).

{% include footer.md %}
