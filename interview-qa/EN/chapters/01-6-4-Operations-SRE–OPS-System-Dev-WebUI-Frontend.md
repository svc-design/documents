## Frontend Web UI Interview Q&A Guide
1. Vue.js Q&A

Q: How does Vue achieve two-way data binding?

What: Vue uses the v-model directive.

How: It binds input values to component data and updates automatically via event listeners. Vue2 used Object.defineProperty, Vue3 uses Proxy.

Example:

<input v-model="message" />
<p>{{ message }}</p>


Q: What are Vue lifecycle hooks?

What: Lifecycle hooks allow running code at different stages of a component.

How: Examples include created, mounted, updated, destroyed.

Example: Use mounted() to fetch data after DOM is ready.

Q: What’s the difference between v-if and v-show?

v-if: Conditionally renders elements, removes/re-creates them. Good for infrequent toggles.

v-show: Controls display style, element always exists. Good for frequent toggles.

Q: How does parent-child communication work in Vue?

Parent → Child: Use props.

Child → Parent: Use $emit.

Non-related components: Use EventBus or Vuex.

Q: What’s the difference between ref and reactive in Vue3?

ref: Wraps simple values or DOM refs.

reactive: Makes an object deeply reactive.

2. React Q&A

Q: What are React Hooks? Why are they important?

What: Hooks let you use state and lifecycle in functional components.

How: useState for state, useEffect for side effects, useContext for context.

Example:

const [count, setCount] = useState(0);
useEffect(() => console.log(count), [count]);


Q: What’s the difference between useEffect and useLayoutEffect?

useEffect: Runs after render, async-friendly, non-blocking.

useLayoutEffect: Runs after DOM mutations but before paint, useful for sync DOM updates.

Q: What is React’s reconciliation mechanism?

What: React uses Virtual DOM + Diff algorithm.

How: It compares new and old VDOM trees and applies minimal changes to the real DOM.

Q: How do you optimize React performance?

What: Avoid unnecessary re-renders.

How: Use React.memo, useMemo, useCallback, lazy loading, virtualization.

Q: What are Error Boundaries in React?

What: Components that catch JavaScript errors in their children.

How: Provide fallback UI instead of crashing the app.

3. Next.js Q&A

Q: What’s the difference between React and Next.js?

React: UI library, CSR-first.

Next.js: Full-stack React framework with SSR, SSG, API routes, file-based routing.

Q: How does Next.js handle routing?

What: File-based routing from /pages directory.

How: Dynamic routes via [id].js.

Q: What’s the difference between SSR, SSG, CSR in Next.js?

SSR: Render on every request (getServerSideProps).

SSG: Pre-render at build time (getStaticProps).

CSR: Render on client (like React).

Q: How do you implement API routes in Next.js?

How: Place files in /pages/api.

Example:

export default function handler(req, res) {
  res.status(200).json({ message: 'Hello API' })
}


Q: How does Next.js optimize performance?

Built-in: Automatic code splitting, lazy loading, next/image optimization, ISR (Incremental Static Regeneration).

Q: How do you implement authentication in Next.js?

How: Use next-auth or custom JWT-based API routes.

4. Vue vs React vs Next.js (Comparison)
Dimension	Vue	React	Next.js
Positioning	Progressive framework, view-focused	UI library, flexible, ecosystem-rich	Full-stack React framework with SSR/SSG
Core Mechanism	Vue2: defineProperty, Vue3: Proxy	Virtual DOM + Reconciliation	React + SSR/SSG built-in
Data Binding	Two-way (v-model)	One-way data flow	One-way + pre-rendering
State Management	Vuex / Pinia	Redux / Context / Hooks	Same as React, with SSR hydration
Routing	Vue Router	React Router	File-based routing
Rendering	CSR, SSR via Nuxt	CSR, SSR via Next.js	CSR + SSR + SSG + ISR
Optimization	Proxy-based reactivity, v-if/v-show	React.memo, useMemo	Built-in optimizations
Learning Curve	Easy	Moderate, needs Hooks/JSX	Higher, needs React + SSR knowledge
Use Cases	SMEs, fast prototyping	Large apps, ecosystem-rich	SEO-heavy, enterprise full-stack