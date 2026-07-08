# Deepening

How to deepen a cluster of shallow modules safely. Assumes vocabulary in [SKILL.md](SKILL.md).

## Dependency Categories

Classify dependencies before deepening. Category determines testing strategy.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable. Merge modules, test through new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies with local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if stand-in exists. Seam is internal; no port at external interface.

### 3. Remote but owned

Your own services across network boundary. Define a **port** (interface) at seam. Deep module owns logic; transport is injected **adapter**. Tests use in-memory adapter. Production uses
HTTP/gRPC/queue adapter.

### 4. True external

Third-party services you don't control. Take dependency as injected port; tests provide mock adapter.

## Seam Discipline

- **One adapter = hypothetical seam. Two adapters = real seam.** Don't introduce port unless at least two adapters justified (production + test). Single-adapter seam is just indirection.
- **Internal seams vs external seams.** Deep module can have internal seams (private, used by own tests) and external seam at interface. Don't expose internal seams through interface.

## Testing: Replace, Don't Layer

- Old unit tests on shallow modules become waste once deepened module interface tests exist — delete them.
- Write new tests at deepened module's interface. Interface is test surface.
- Assert on observable outcomes through interface, not internal state.
- Tests survive internal refactors. If test changes when implementation changes — it's testing past the interface.
