# Advanced

## Parallelism

By default, NUPACK 4 uses a single CPU core for each [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs). For example, a call to `tube_analysis` will use 1 core, whereas a call to `tube_design` with `trials=4` will use 4 cores (up to the number of logical cores on the machine). Parallelism may be further controlled using the `config.threads` setting (default `0` as of 4.0.1.1; previously `1`):

```python
from nupack import *
config.threads = 1
```

This setting denotes the maximum number of threads that *all* NUPACK thermodynamic analysis routines can use concurrently within a single Python process. As a special case, if `config.threads` is set to `0`, then NUPACK jobs will be permitted to use all available cores on your machine. This type of parallelism enables:

- **Block-level parallelism**. Subcomplex blocks in the dynamic program will be calculated in parallel (e.g., triangular blocks `A`, `B`, `C`, and rectangular blocks `AB`, `BC`, and `ABC` for complex `ABC`; see Figure 8 of [@Fornace20]). This mode of parallelism will be enabled for all complexes in a multi-tube ensemble.

- **Element-level parallelism**. Subsequence elements will be calculated in parallel within a subcomplex block. This mode of parallelism will only be employed for subcomplex blocks containing at least 128 nt.


## Caching

NUPACK 4 introduces subcomplex block caching to achieve dramatic speedups by avoiding recalculation of subcomplex intermediates for a multi-tube ensemble (see Figure 8 of [@Fornace20]). The `config.cache` flag (GB; default 2.0) controls the gigabytes of memory that *each* [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs) can use.

```python
from nupack import *
config.cache = 8.0 # GB
```

This flag may be set to `0.0` to disable caching if your hardware has very little memory.


## Naming conventions

Analysis objects of type `Strand`, `Complex`, `Tube` and design objects of type `Domain`, `TargetStrand`, `TargetComplex`, and `TargetTube` all accept a name specified using the `name` keyword.

!!! note
    Within the context of a single calculation, every object name must be unique (e.g., each `Strand`, `Complex`, and `Tube` in an analysis calculation must have a unique name).

The name may specified as a `tuple` or `list` instead of a `str`, in which case a `'[]'`-based string will be automatically generated. This convention is especially useful for repeated definitions:

```python
domains = [Domain('N6', name=['a', i]) for i in range(4)]
print([d.name for d in domains]) # --> ['a[0]', 'a[1]', 'a[2]', 'a[3]']
```

See the examples below that make use of this convention to specify designs for orthogonal reaction pathways.


## Design orthogonal reaction pathways
[Reaction pathways](definitions.md#reaction-pathways) can be designed by specifying [target test tubes](definitions.md#target-test-tubes) and formulating a [constrained multi-tube design problem](definitions.md#constrained-multi-tube-design-problem). Following the target test tube specification of [@Wolfe17] (see Supplemenatary Section S2.2), for a reaction pathway with M elementary steps, to design N orthogonal systems, there are N*(M+1) elementary step tubes plus 1 global crosstalk tube. Below, we provide example design specifications and Jupyter notebooks for designing N orthogonal systems for 1-step and multi-step reaction pathways:

- **Multi-tube design (simple):**
    - [design specification](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design-specs/design-spec-displacement.pdf) ([tex](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design-specs/design-spec-displacement.tex))
    - [design N orthogonal one-step reaction pathways](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design/multi-tube-design-simple-ortho.ipynb)
- **Multi-tube design (advanced):**
    - [design specification](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design-specs/design-spec-dicer.pdf) ([tex](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design-specs/design-spec-dicer.tex))
    -  [design N orthogonal multi-step reaction pathways](https://nbviewer.jupyter.org/github/Piercelab-Caltech/nupack-docs/tree/main/examples/design/multi-tube-design-advanced-ortho.ipynb)

!!! Note
    Note that target test tubes for N orthogonal systems can be concisely defined using a Python loop.


!!! Note
    Sample $\LaTeX$ files are provided for the above multi-tube design specifications to assist with making new design specs in a standardized format.
