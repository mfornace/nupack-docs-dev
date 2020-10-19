# Advanced functionality

## Enabling sub-job dynamic program parallelism

By default, NUPACK 4 uses a single CPU core for each analysis job or design trial. That is, a call to `tube_analysis` will occupy 1 CPU, whereas a call to `tube_design` with `trials=4` will use 4 CPUs in total (up to the number of logical CPUs on the machine). Additional parallelism may be enabled using the `config.subjob_parallelism` flag (defaulted to `False`):

```python
from nupack import *
config.subjob_parallelism = True
```

If this flag is set to `True`, then NUPACK jobs may parallelize over all available CPU cores on your system. This type of parallelism enables:

- **Dynamic programming parallelism**. Subsequence results will be calculated in parallel within an individual dynamic program. This mode of parallelism will only be enabled for complexes of at least 128 nucleotides.
- **Block level parallelism**. Individual blocks in the dynamic programming will be calculated in parallel, corresponding to the difference sub-complexes that must be calculated (e.g. `A`, `B`, `C`, `AB`, `BC`, and `ABC` for a complex `ABC`; see [@Fornace20]). This mode of parallelism will be enabled for all complexes.

## Specifying block cache size

NUPACK 4 introduces block caching, a method to avoid recalculation of sub-complex intermediates for speedups in analyzing the test tube ensemble [@Fornace20]. The `config.block_cache_gb` flag (default 2.0) may be used to control the gigabytes of memory that **each** analysis job or design trial can use.

```python
from nupack import *
config.block_cache_gb = 8.0
```

The flag may be set to `0.0` to disable caching for a system with very little available RAM.
