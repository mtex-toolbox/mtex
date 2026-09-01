# A `@spatialTransform` array is a chain, not a collection

**Status: decided, not implemented.** The methods are still scalar-only, so nothing in the
tree behaves this way yet. This records what an array *means*, so that whoever seals the
methods does not have to re-derive it — and so that no code is written in the meantime that
assumes the other reading.

`inv(job.T)` does not work:

```
Cannot call method 'inv' because 'T' is heterogeneous and 'inv' is not sealed.
```

A hop sequence is a heterogeneous array — `[composite, id, shift, tilt]` held together by
their common root — and MATLAB dispatches a method on such an array only if the root
declares it `Sealed`. Only `mtimes`, `plus` and `display` are, which is why the sequence
displays but `inv`, `isid`, `char` and even `displacement` all fail the same way. Nor is
heterogeneity the whole of it: `inv` on a *homogeneous* `[shift shift]` dies with "Too many
input arguments", because `T.M` on a 1x2 array expands to a comma-separated list. The
classes are scalar-first throughout and the array is a container.

Making them work needs the meaning of the array settled first, because the two readings
give `inv` different answers.

## Considered Options

We chose **a chain** — the array is one composite written out, `[T1 T2 T3]` meaning apply
T1, then T2, then T3 — over **a collection**, the elementwise reading every other MTEX
class uses.

The class help already says it: *"a chain of differently modelled hops is `[T1 T2 T3]`
rather than a cell array"*. And the same idea is already implemented one level down:
`spatialTransformComposite/inv` inverts each stage and then `fliplr`s them, and
`spatialTransformTilt/inv` does the same, returning a composite. A composite's `stages` and
a hop array are the same structure at two levels, so they must not disagree about what
inversion is. Under the collection reading they would.

So the algebra is the composite's, and the whole of it follows from the one decision:

| | |
| --- | --- |
| `eval(T,pos)` | apply the hops in order — a point in map 1 lands in the reference frame |
| `inv(T)` | flip the order, invert each |
| `isid(T)` | one logical: does the chain move anything |
| `T(end)*...*T(1)` | the same chain collapsed into a single transform |

The cost is that this class is then the exception to MTEX's array-is-N-entities contract,
where `inv` on a `rotation` array inverts in place and reverses nothing. It is a deliberate
exception: these are maps between frames, not a sample of measurements, and the array is
ordered by *composition* rather than by index.

## Consequences

- Implementing it means sealing the public names in `@spatialTransform` and renaming the
  scalar implementations in all eleven subclasses to hooks the sealed wrapper loops over —
  a sealed method cannot be overridden, so the two cannot share a name. Now is the cheap
  time: nothing outside the repo subclasses these yet.
- `job.T = inv(job.T)` would then pass `trueEbsd/set.T`, which checks only the count, and
  leave a job whose hops run against its `imgList`. Reversal is a chain-level operation and
  the job's sequence is not reversed with it, so the setter should say so.
- Until it is implemented: `arrayfun(@inv,T,'UniformOutput',false)` inverts hop by hop
  without reversing, and `inv(T(end)*...*T(1))` is the whole chain, since `mtimes` is
  sealed already.
