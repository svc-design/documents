## Go Interview Q&A

1. What is CPU profiling in Go?

What: CPU profiling records where CPU time is spent in your program.

How: Go provides runtime/pprof to generate CPU profiles for performance analysis.

Example:

import "runtime/pprof"

pprof.StartCPUProfile(file)
defer pprof.StopCPUProfile()

2. What are lock mechanisms in Go?

What: sync.Mutex and sync.RWMutex protect shared data in concurrent programs.

How: Mutex allows one goroutine at a time; RWMutex allows multiple readers or one writer. Best for read-heavy workloads.

Example:

var mu sync.Mutex

mu.Lock()
// critical section
mu.Unlock()

3. What is the worker pool pattern in Go?

What: A worker pool limits the number of goroutines to avoid excessive resource usage.

How: Use channels to distribute jobs among fixed workers.

Example:

func worker(id int, jobs <-chan int, results chan<- int) {
    for j := range jobs {
        results <- j * 2
    }
}

4. How does dependency management work in Go?

What: Go uses Go Modules to manage dependencies and ensure version consistency.

How: Dependencies are defined in go.mod. go get updates modules.

Example:

go mod init example.com/mymodule
go get -u

5. How do you build RESTful APIs with Go?

What: The standard net/http package supports efficient web servers and clients.

How: Define handlers and start a server.

Example:

http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, Go!")
})
http.ListenAndServe(":8080", nil)

6. How is context used in Go?

What: The context package manages goroutine lifecycles, timeouts, and cancellations.

How: Use context.WithTimeout or context.WithCancel to control operations.

Example:

ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

7. What are best practices for error handling in Go?

What: Go uses explicit error handling, no hidden exceptions.

How: Always check if err != nil, and wrap errors with context.

Example:

if err != nil {
    return fmt.Errorf("failed to process: %v", err)
}

8. Why is Go a good fit with Docker?

What: Go compiles to small, static binaries.

How: Use minimal base images like scratch or alpine to reduce image size.

Example:

FROM golang:alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o app

FROM scratch
COPY --from=builder /app/app /app
CMD ["/app"]

9. What are common Go design patterns?

What: Go often uses patterns like Singleton and Producer-Consumer.

How: sync.Once ensures Singleton; channels implement Producer-Consumer.

Example:

var once sync.Once
once.Do(func() {
    // initialize only once
})

10. How do you test and benchmark in Go?

What: Go’s testing package supports unit tests and benchmarks.

How: Write TestXxx for unit tests, BenchmarkXxx for performance tests.

Example:

func TestSum(t *testing.T) {
    if Sum(1, 2) != 3 {
        t.Errorf("wrong result")
    }
}
func BenchmarkSum(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Sum(1, 2)
    }
}

11. What logging libraries are used in Go?

What: Standard log is simple; third-party libraries like logrus and zap provide structured and performant logging.

How: They integrate with monitoring stacks like ELK and Prometheus.

Example: Use zap for high-performance structured logging in production.
