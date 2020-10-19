# Advanced

## Parallelism

By default, NUPACK 4 uses a single CPU core for each [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs). For example, a call to `tube_analysis` will use 1 core, whereas a call to `tube_design` with `trials=4` will use 4 cores (up to the number of logical cores on the machine). Additional parallelism may be enabled using the `config.parallelism` flag (default `False`):

```python
from nupack import *
config.parallelism = True
```

If this flag is set to `True`, then NUPACK jobs will be permitted to use all available cores on your machine. This type of parallelism enables:

- **Block-level parallelism**. Subcomplex blocks in the dynamic program will be calculated in parallel (e.g., triangular blocks `A`, `B`, `C`, and rectangular blocks `AB`, `BC`, and `ABC` for complex `ABC`; see Figure 8 of [@Fornace20]). This mode of parallelism will be enabled for all complexes in a multi-tube ensemble. 

- **Element-level parallelism**. Subsequence elements will be calculated in parallel within a subcomplex block. This mode of parallelism will only be employed for subcomplex blocks containing at least 128 nt.


## Caching

NUPACK 4 introduces subcomplex block caching to achieve dramatic speedups by avoiding recalculation of subcomplex intermediates for a multi-tube ensemble (see Figure 8 of [@Fornace20]). The `config.cache` flag (GB; default 2.0) controls the gigabytes of memory that *each* [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs) can use.

```python
from nupack import *
config.cache = 8.0 # GB
```

This flag may be set to `0.0` to disable caching if your hardware has very little memory. 
