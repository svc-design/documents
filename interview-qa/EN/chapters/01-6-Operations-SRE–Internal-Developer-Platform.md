# **Python**

## 1. **What is GIL in Python and how does it affect multithreading?**

- **GIL (Global Interpreter Lock)** is a global lock in the Python interpreter that prevents multiple threads from executing Python bytecode simultaneously. This means that even on multi-core CPUs, Python’s multithreaded programs cannot truly execute CPU-bound tasks in parallel (though I/O-bound tasks are less affected). To address this, you can use multiprocessing or opt for asynchronous programming (asyncio).

## 2. **Python Decorators**

- Decorators are used to modify the behavior of functions or classes. They are higher-order functions that take a function and return another function. Common uses include logging, performance monitoring, and access control. For example:def my\_decorator(func):

```python
   def wrapper():

        print("Something before the function.")

        func()

        print("Something after the function.")

    return wrapper

@my\_decorator

def say\_hello():

    print("Hello!")

say\_hello()
```

## 3. **Difference between** **`is`** **and** **`==`**

- **`is`** checks if two objects are the same (i.e., if they have the same memory address).
- **`==`** checks if the values of two objects are equal.

## 4. **Difference between Generators and Iterators in Python**

- **Generators** are a special type of iterator created using the `yield` statement. They produce values one at a time and can only be iterated over once. They are characterized by lazy evaluation.
- **Iterators** are objects that implement the `__iter__()` and `__next__()` methods. Generators are a type of iterator.

## 5. **Python Garbage Collection Mechanism**

- Python uses reference counting primarily, combined with mark-and-sweep and generational garbage collection to manage memory. When an object's reference count drops to zero, the memory is automatically freed. Circular references are handled by the mark-and-sweep algorithm.

## 6. **Python Context Managers**

- Context managers handle resources using the `with` statement, automatically managing resource acquisition and release. They are implemented by defining `__enter__()` and `__exit__()` methods, used for operations like file handling and database connections.

```python
with open('file.txt', 'r') as file:
    content = file.read()
```

## 7. Internal Implementation of Python Dict

Python dictionaries are implemented based on hash tables. They use the hash value of keys to quickly access values, with an average time complexity of O(1). To resolve hash collisions, Python dictionaries use either open addressing or chaining methods.

## 8. **Shallow Copy vs. Deep Copy in Python**

- **Shallow Copy**: Copies the object’s references but not the nested objects. Created using `copy.copy()`.
- **Deep Copy**: Copies the entire object, including nested objects. Created using `copy.deepcopy()`.

## 9. **Use Cases for Lambda Anonymous Functions**

- Lambda functions are used for short-lived, one-time-use functions, commonly in sorting and custom filtering.
python复制代码sorted\_list = sorted(items, key=lambda x: x.age)

## 10. **Python Singleton Pattern**

- The Singleton pattern ensures that a class has only one instance. A common implementation is:

```python
class Singleton:
    _instance = None
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

## 11. **Writing Asynchronous Code with** **`asyncio`**

- asyncio is Python’s asynchronous programming library, supporting coroutines. Use the async and await keywords for asynchronous operations, particularly suitable for I/O-bound tasks.

```python
import asyncio

async def fetch_data():

    await asyncio.sleep(1)

    return "data"

async def main():

    result = await fetch_data()

    print(result)

asyncio.run(main())
```

## 12. **JWT Authentication**

- **JWT (JSON Web Token)** is a compact, URL-safe token used for authentication. It typically contains user information and a signature to ensure the token’s integrity. JWTs are commonly used for stateless REST API authentication.

# Go

## 1. **Concurrency Model in Go**

Go uses Goroutines to achieve concurrency. Goroutines are lightweight threads managed by the Go runtime and scheduled across multiple threads by the Go scheduler. Go's concurrency model is based on CSP (Communicating Sequential Processes), with channels used for communication between Goroutines.

```go
   go func() {
       fmt.Println("Hello, Goroutine!")
   }()
```

## 2. Usage and Implementation of Channels

Channels are a communication mechanism between Goroutines, allowing safe data transfer. They are thread-safe and support both synchronous and asynchronous communication.

Usage Scenarios: Data synchronization, worker pool patterns, controlling execution order of concurrent tasks, etc.

```go
ch := make(chan int)

go func() {
    ch <- 42
}()

result := <-ch
```

## 3. Memory Management and Garbage Collection in Go

Go uses an automatic garbage collection (GC) mechanism, employing a mark-and-sweep algorithm and a three-color marking method. It simplifies memory management by automatically handling heap memory allocation and reclamation. In large systems, GC pauses may impact performance. Go introduces the G1 garbage collector for optimization, and the GOGC environment variable can adjust the garbage collection frequency.

## 4. Performance Tuning in Go

Profiling Tools (pprof): Go provides the pprof package for analyzing CPU, memory, and Goroutine performance.

Reduce Memory Allocation: Use object pools (sync.Pool) or reuse objects to reduce frequent memory allocations and GC pressure.

Efficient Concurrency: Optimize the use of Goroutines and channels, avoiding frequent blocking operations.

```go
import "runtime/pprof"

pprof.StartCPUProfile(file)
defer pprof.StopCPUProfile()
```

## 5. Lock Mechanisms and sync Package

in Go The sync.Mutex and sync.RWMutex are used to protect shared data from concurrent read and write access. sync.RWMutex provides separate read and write locks, suitable for read-heavy scenarios.

```go
var mu sync.Mutex

mu.Lock()
// critical section
mu.Unlock()
```

## Worker Pool Pattern

in Go The worker pool pattern efficiently controls the number of Goroutines, preventing excessive memory usage.

```go
func worker(id int, jobs <-chan int, results chan<- int) {
    for j := range jobs {
        results <- j * 2
    }
}
```

## Dependency Management

in Go Go uses Go Modules to manage dependencies, defining dependency versions through the go.mod file to ensure reproducibility and consistency.

```bash
go mod init example.com/mymodule
go get -u
```

## HTTP Package and RESTful API Development

in Go The Go standard library provides the net/http package for building efficient web servers and clients, suitable for REST APIs, load balancing, reverse proxies, etc.

```go
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, Go!")
})

http.ListenAndServe(":8080", nil)
```

## Context Management

in Go The context package manages Goroutine lifecycles, commonly used for handling request timeouts and cancellation. Use context.WithTimeout or context.WithCancel to create cancellable contexts.

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

## Error Handling Best Practices

in Go Go uses explicit error handling, avoiding hidden errors, and encourages checking errors with if err != nil. Custom error types are often used to simplify repetitive error handling logic.

```go
if err != nil {
    return fmt.Errorf("failed to process: %v", err)
}
```

## Integration of Go with Docker

Go's compiled binaries are highly portable and small in size, making them ideal for deployment with Docker. Use scratch or alpine images to minimize the image size.

```dockerfile
FROM golang:alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o app

FROM scratch
COPY --from=builder /app/app /app
CMD "/app"
```

## Common Go Design Patterns

- Singleton Pattern: Implemented using sync.Once to ensure thread safety.
- Producer-Consumer Pattern: Easily implemented with channels for asynchronous data processing.

## Unit Testing and Benchmarking

in Go The Go standard library offers a robust testing framework (testing) for writing unit tests and performance benchmarks.

```go
func TestSum(t *testing.T) {
    result := Sum(1, 2)
    if result != 3 {
        t.Errorf("Sum was incorrect, got: %d, want: %d.", result, 3)
    }
}

func BenchmarkSum(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Sum(1, 2)
    }
}
```

## Logging Libraries

in Go and Their Application in Operations The standard log package in Go is simple, but third-party libraries like logrus and zap offer more complex features. Combining with ELK and Prometheus can facilitate efficient log analysis and monitoring.

## Web UI

## 1. **Vue Two-Way Data Binding** Vue.js achieves two-way data binding using the `v-model` directive, which automatically updates the UI and data by combining getters and setters.

## 2. **Task Reliability and Monitoring in Celery**

- **Reliability:** Ensure tasks do not get lost by storing task results in persistent storage like Redis or databases.
- **Monitoring:** Use Celery’s event system or Flower to monitor task statuses. For troubleshooting blockages or delays, analyze logs and implement task retries.

## 3. **Vue Two-Way Data Binding**

Vue's two-way data binding is achieved using the `v-model` directive. It binds the `value` attribute of an HTML element to a Vue instance’s data and automatically updates the data through event listeners. This mechanism relies on data hijacking and the publish-subscribe pattern, allowing the DOM to automatically update when data changes and vice versa.

## 4. **Vue Instance Lifecycle Hooks**

Vue lifecycle hooks allow developers to execute code at different stages of a component’s life. Common hooks include:

- `beforeCreate`: Called before the instance is created; `data` and `methods` are not yet available.
- `created`: Called after the instance is created; `data` and `methods` can be used.
- `beforeMount`: Called before the component is mounted to the DOM.
- `mounted`: Called after the component is mounted to the DOM.
- `beforeUpdate`: Called before data updates.
- `updated`: Called after data updates.
- `beforeDestroy`: Called before the instance is destroyed.
- `destroyed`: Called after the instance is destroyed.

## 5. **Difference Between** **`v-if`** **and** **`v-show`**

- `v-if`: Conditional rendering; the DOM element is destroyed or re-created based on the condition, suitable for infrequently toggled content.
- `v-show`: Controls visibility through the `display` style; the DOM element always exists, suitable for frequently shown/hidden content.

## 6. **Difference Between Cookie and Session**

- **Cookie:** Stored in the client’s browser with limited data storage, suitable for storing small and non-sensitive data like user preferences or session identifiers.
- **Session:** Stored on the server-side, typically using cookies to store the session ID. Sessions are suitable for storing sensitive data.

## 7. **Vue Parent-Child Component Communication**

- **Parent to Child:** Pass data to child components using `props`.
- **Child to Parent:** Trigger events from child components using the `$emit` method.
- **Non-Parent-Child Communication:** Use EventBus or Vuex for global data passing.

## 8. **`nextTick`** **Usage** `nextTick` is used to wait until after the DOM updates have been completed before executing some code. It is commonly used when needing to perform actions on the DOM after it has been updated.

```javascript
this.$nextTick(() => {
    // DOM 更新完毕，执行操作

});
```

## 9. **Difference Between** **`ref`** **and** **`reactive`**

- **`ref`****\*\***:\*\* Used to wrap basic types (e.g., numbers, strings) or objects into reactive objects, suitable for single DOM element references and reactive data.
- **`reactive`****\*\***:\*\* Used to turn objects into reactive, suitable for more complex data structures, returning a deeply reactive object.

## 10. **Vue Custom Directives**

Vue supports custom directives, allowing the creation of your own `v-xxx` directives. Common use cases include focusing input fields and drag operations.

```javascript
Vue.directive('focus', {
    inserted: function (el) {
        el.focus();
    }
});
```

1. **Vue3 Composition API vs. Options API**
- **Composition API:** Introduced in Vue3, allows encapsulation of logic through functions, providing greater flexibility and reusability. The `setup` function is core, allowing direct access to component `props` and `context`.
- **Options API:** Used in Vue2, defines components through options like `data`, `methods`, `computed`, etc., with a more straightforward structure but can lead to logic scattering in complex components.

**Difference:** Composition API is better for logic reuse and code organization, while Options API is more suitable for smaller, simpler components.

## 12. **Difference Between Proxy in Vue3 and Object.defineProperty in Vue2**

- **Vue3 uses Proxy:** Proxies the entire object, allowing monitoring of property additions, deletions, and accesses, with better performance and coverage of Vue2 limitations.
- **Vue2 uses Object.defineProperty:** Only intercepts existing property reads/writes, cannot listen to property additions or deletions, and is more complex with arrays.

Proxy improves Vue3’s efficiency and flexibility in handling reactive data.

## 13 **Difference Between React Hooks and Class Components**

- **Hooks:** Introduced in React 16.8, allow using state and lifecycle features in functional components through functions like `useState` and `useEffect`, simplifying code structure and logic.
- **Class Components:** Traditional React component definition using classes and lifecycle methods (e.g., `componentDidMount`, `shouldComponentUpdate`).

**Difference:** Hooks provide a cleaner and more reusable approach, while Class components can be verbose and less modular for complex logic.

## 14  **Difference Between** **`useEffect`** **and** **`useLayoutEffect`** **in React**

- **`useEffect`****\*\***:\*\* Executes after the component renders, suitable for asynchronous operations, data fetching, and subscriptions. It does not block page rendering.
- **`useLayoutEffect`****\*\***:\*\* Executes after DOM mutations but before painting, useful for reading layout information or synchronously modifying DOM. It may block rendering and is typically used for direct DOM manipulation.

## 15 **Optimizing React and Vue Applications Performance**

- **Component Splitting:** Break large components into smaller ones to avoid unnecessary re-renders.
- **Lazy Loading:** Load components or resources on demand using React.lazy or Vue’s dynamic components.
- **List Virtualization:** Use tools like react-window or Vue’s virtual-scroll component to handle large list rendering with reduced memory and rendering costs.
- **Memoization:** Use React.memo or Vue’s computed to cache computed results and avoid unnecessary calculations.
- **shouldComponentUpdate/PureComponent:** In React, use shouldComponentUpdate or PureComponent to reduce redundant component re-renders.

## 16. **Performance Optimization Differences Between Vue3 and React**

- **Vue3’s Proxy-based Reactivity System:** More efficient than Vue2’s system; React relies on setState to trigger renders, with differing performance mechanisms.
- **Vue’s** **`v-if`****\*\***/\***\*****`v-show`** **vs. React’s Conditional Rendering:** Vue provides `v-if`/`v-show` for controlling visibility, React uses JavaScript expressions for rendering control.
- **Reactivity:** Vue’s reactivity system automatically tracks dependencies, while React requires manual useState and useEffect to manage dependencies.

## 17. **Common Tools and Techniques for Frontend Performance Monitoring**

- **Lighthouse:** Google’s performance assessment tool for measuring page load speed, SEO, and best practices, with optimization suggestions.
- **Web Vitals:** Google’s core metrics (e.g., LCP, FID, CLS) for measuring user experience and page performance.
- **Sentry:** Monitors frontend errors and performance bottlenecks, providing detailed error logs and performance data.
- **FCP, TTFB, LCP:** Common performance metrics for measuring first paint, server response time, and largest contentful paint.
    - **Performance API:** Browser’s window.performance API for capturing page load times, resource loading, and other data for detailed monitoring.

## 18. **Monitoring and Optimizing Frontend Application Performance in Operations**

- **CDN Deployment:** Distribute static resources via CDN to global nodes, reducing latency.
- **Frontend Resource Monitoring:** Use tools like Google Analytics or Web Vitals to monitor frontend performance.
- **Log Monitoring and Analysis:** Combine tools like ELK or Prometheus to capture frontend logs, errors, and performance data.
- **Resource Compression:** Use Webpack, Rollup, etc., for code compression and splitting to improve transmission efficiency.
- **Caching Strategies:** Configure browser and server-side caching (e.g., Cache-Control) to speed up page loading.

## 19. **Optimizing Frontend Build Performance with Webpack**

- **Code Splitting:** Use Webpack’s splitChunks configuration to split code and reduce initial load size.
- **Tree Shaking:** Remove unused code to reduce the bundle size.
- **Gzip/Brotli Compression:** Enable compression in Webpack to reduce data transfer size.
- **Caching:** Use output.filename with hash values to ensure files update correctly after modifications.

## 20. **Capturing User Interaction Behavior in Frontend Monitoring**

- **User Behavior Tracking Tools:** Use Hotjar, FullStory, etc., to record user clicks, scrolls, inputs, and generate heatmaps.
- **Custom Event Tracking:** Use Google Analytics or Sentry to manually track specific events (e.g., button clicks, form submissions).
- **Performance Metrics Collection:** Use Performance API or Web Vitals to capture page load, interaction response, and other performance data.

## 21. **Performance Impact of** **`ref`** **vs.** **`reactive`** **in Vue3**

- **`ref`****\*\***:\*\* Suitable for simple data types, with better performance as it tracks individual value changes.
- **`reactive`****\*\***:\*\* Suitable for complex objects, with higher performance overhead due to deep property tracking.

## 22. **React’s Reconciliation Mechanism**

React uses a virtual DOM to achieve efficient updates by comparing new and old virtual DOM trees through the Diff algorithm, identifying the minimal changes needed to update the actual DOM.

## 23. **Vue’s** **`v-model`** **Directive**

`v-model` provides two-way data binding between form elements and Vue data. It simplifies synchronization between input elements and data properties.

## 24. **Common Vue and React Performance Optimization Strategies**

- **Component Optimization:** Use shouldComponentUpdate (React) or computed properties (Vue) to avoid unnecessary re-renders.
- **Code Splitting:** Break down code into smaller chunks and lazy load components when needed.
- **State Management:** Optimize state updates and management with efficient techniques (e.g., Vuex, Redux).

## 25. **Event Delegation vs. Event Binding**

- **Event Delegation:** Attach a single event listener to a parent element and handle events for child elements through event propagation. Reduces the number of listeners and improves performance for dynamic content.
- **Event Binding:** Attach event listeners directly to individual elements, suitable for static content or specific requirements.

## 26. **Vue and React Differences in Component State Management**

- **Vue:** Utilizes Vuex for centralized state management with a more formalized approach and Vue’s reactivity system.
- **React:** Uses Redux, Context API, or Hooks for state management with a more flexible and functional approach.

## 27. **Error Boundaries in React vs. Error Handling in Vue**

- **React:** Uses Error Boundaries to catch JavaScript errors in components and provide fallback UI.
- **Vue:** Uses the `errorCaptured` lifecycle hook to catch errors in child components and perform error handling.

## 28. **Optimizing Webpack Build Performance**

- **Cache:** Enable caching for faster builds.
- **Parallel Builds:** Use tools like `thread-loader` to build in parallel.
- **Minification:** Minify and optimize code to reduce build size and improve loading performance.

## 29. **Vue3 vs. React in Large-Scale Applications**

- **Vue3:** Provides improved performance with Proxy-based reactivity and better TypeScript support.
- **React:** Offers a mature ecosystem, extensive third-party libraries, and strong community support, with better performance optimizations in recent versions.

## 30. **Frontend Security Best Practices**

- **Input Validation:** Prevent XSS and injection attacks by validating and sanitizing user inputs.
- **HTTPS:** Use HTTPS to secure data transmission and protect user privacy.
- **Content Security Policy (CSP):** Implement CSP to control the sources of content and scripts loaded on the page.

## 31. **Strategies for Handling Large-Scale State in Vue and React**

- **Vue:** Use Vuex for centralized state management and modular stores.
- **React:** Use Redux or Context API with Hooks for efficient state management.

## 32. **Common Frontend Performance Bottlenecks**

- **Slow Resource Loading:** Minimize and optimize asset sizes and load times.
- **Inefficient Rendering:** Optimize rendering and re-rendering by minimizing unnecessary updates.
- **Large Bundle Sizes:** Split bundles and use code splitting to reduce initial load times.

## 33. **Effective Monitoring Tools for Frontend Performance**

- **Lighthouse:** Assess performance, accessibility, and best practices.
- **WebPageTest:** Analyze page load times from various locations and devices.
- **Sentry:** Monitor frontend errors and performance bottlenecks with detailed logs.

## 34. **Frontend and Backend Communication Optimization**

- **API Caching:** Cache API responses to reduce server load and improve response times.
- **Compression:** Use gzip or Brotli to compress API responses.
- **Pagination:** Implement pagination to handle large data sets efficiently.

## 35. **Common Frontend Performance Pitfalls**

- **Unoptimized Images:** Use responsive images and compression techniques.
- **Blocking Resources:** Minimize render-blocking resources like CSS and JavaScript.
- **Inefficient JavaScript Execution:** Optimize JavaScript code and reduce execution time.

## 36. **Optimizing API Performance in Frontend Applications**

- **Batch Requests:** Combine multiple API requests into a single request when possible.
- **Caching:** Cache API responses to improve load times.
- **Asynchronous Requests:** Use asynchronous requests to avoid blocking the main thread.

## 37. **Vue and React Performance Optimization Techniques**

- **Vue:** Use computed properties and watchers for efficient data handling.
- **React:** Use memoization techniques and React.memo to prevent unnecessary re-renders.

## 38. **Common Frontend Build Tools and Techniques**

- **Webpack:** Use for module bundling, code splitting, and optimization.
- **Babel:** Transpile modern JavaScript for compatibility with older browsers.
- **ESLint:** Enforce coding standards and catch errors early in development.
