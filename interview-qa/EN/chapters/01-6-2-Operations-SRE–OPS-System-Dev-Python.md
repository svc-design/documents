## Python

1. What is the GIL in Python? How does it affect multithreading?

What: GIL (Global Interpreter Lock) is a mutex in CPython that allows only one thread to execute Python bytecode at a time.

How: It prevents true parallel execution of CPU-bound tasks in multithreading. I/O-bound tasks are less affected. To bypass this, use multiprocessing or asyncio.

Example: Running CPU-heavy computation in threads will not scale across multiple cores due to GIL.

2. What are decorators in Python?

What: A decorator is a higher-order function that takes a function and returns a new function with modified behavior.

How: It is often used for logging, performance measurement, or access control.

Example:

def my_decorator(func):
    def wrapper():
        print("Before")
        func()
        print("After")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()

3. What is the difference between is and ==?

What: is checks object identity (same memory address). == checks value equality.

How: Use is for singleton objects (None, True, False), and == for comparing values.

Example:

a = [1,2]; b = [1,2]
a == b   # True
a is b   # False

4. What is the difference between generators and iterators?

What: An iterator implements __iter__() and __next__(). A generator is a special iterator created using yield.

How: Generators compute values lazily and can only be iterated once.

Example:

def gen():
    for i in range(3):
        yield i
for x in gen():
    print(x)

5. How does Python garbage collection work?

What: Python uses reference counting as the main strategy, plus mark-and-sweep and generational GC.

How: When reference count drops to zero, memory is freed. Cyclic references are handled by mark-and-sweep.

Example: Two objects referencing each other get cleaned up by GC even if ref count doesn’t reach zero.

6. What is a context manager in Python?

What: A context manager defines resource setup and cleanup using __enter__ and __exit__.

How: It is used with the with statement.

Example:

with open('file.txt', 'r') as f:
    data = f.read()

7. What is the internal implementation of Python dictionaries?

What: Dictionaries are implemented as hash tables.

How: Keys are hashed, and values are stored in slots. Collisions are handled with open addressing. Average lookup is O(1).

Example: Accessing my_dict["key"] is O(1) on average.

8. What is the difference between shallow copy and deep copy?

What: Shallow copy copies references to objects; deep copy recursively copies all nested objects.

How: Use copy.copy() for shallow, copy.deepcopy() for deep.

Example:

import copy
a = [[1,2]]
b = copy.copy(a)   # shallow
c = copy.deepcopy(a) # deep

9. When should you use lambda functions?

What: Lambda is an anonymous inline function.

How: Use it for short, throwaway functions.

Example:

sorted_list = sorted(items, key=lambda x: x.age)

10. How do you implement Singleton in Python?

What: Singleton ensures only one instance of a class exists.

How: Override __new__ to control instantiation.

Example:

class Singleton:
    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super().__new__(cls)
        return cls._instance

11. How do you write asynchronous code with asyncio?

What: asyncio is a library for asynchronous programming using coroutines.

How: Use async and await to run I/O tasks concurrently.

Example:

import asyncio

async def fetch_data():
    await asyncio.sleep(1)
    return "data"

async def main():
    print(await fetch_data())

asyncio.run(main())


👉 These answers are now structured (What → How → Example), clear, and concise — suitable for both technical interviews and English communication practice.
