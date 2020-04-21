

# Simple analysis

Within the approximations of the secondary structure model that NUPACK uses, exact thermodynamic analysis may be performed, typically in $O(N^3)$ time in the number of nucleotides $N$. For ease of use and compatibility with NUPACK 3, we have provided simple functions for thermodynamic analysis in the `nupack.simple` submodule:

- `pfunc`: calculate a partition function
- `mfe`: calculate a complex's MFE structure(s) and free energy(s)
- `count`: calculate the size of the secondary structure ensemble
- `pairs`: calculate equilibrium base pair probability
- `prob`: calculate equilibrium structure probability
- `subopt`: determine a set of suboptimal structures
- `sample`: randomly generate a set of secondary structures
- `tube_analysis`: predict equilibrium complex concentrations from a given test tube ensemble

For a more advanced API, see the [Complex analysis](#complex-analysis) and [Test tube analysis](#test-tube-analysis) sections.

## Usage

To use the simple API, you can first import the functions like this:

```python
from nupack.simple import *
```

Then call any of the functions documented below. The first input to each function is a list of strands. This may be specified as a list (e.g. `['AAT', 'TTTA']`) or as a `+`-delimited string (e.g. `'AAT+TTTA'`). Each of the following functions also takes an optional trailing parameter `model`, which should be an instance of `nupack.Model` if specified. (See [Model](model.md) for help on creating a model object).

`pfunc` returns the complex partition function of a single specified complex:

```python
partition_function = pfunc(['CCC', 'GGG'], model=Model(parameters='RNA', ensemble='stacking'))
print(partition_function)
# --> 1581.5360063360488947
```

`mfe` returns a list of MFE structures and their associated free energies. If the MFE is unique, the list will be length one:

```python
mfe_structures = mfe(['CCC', 'GGG'])
print(mfe_structures)
# --> [(Structure('(((+)))'), -4.181351661682129)]
```

`prob` calculates the probability of a given secondary structure appearing in a single specified complex:

```python
probability = prob(['CCC', 'GGG'], structure='(((+)))')
print(probability)
# --> 0.5589045601083861
```

`subopt` calculates all secondary structures within a specified free energy `gap` of the MFE. The free energy gap is specified in kcal/mol:

```python
subopt_structures = subopt(['CCC', 'GGG'], gap=1.0)
print(subopt_structures)
# --> [
#   (Structure('(((+)))'), -4.181351661682129),
#   (Structure('((.+)).'), -3.3813514709472656)
# ]
```

`pairs` calculates the equilibrium base pair probability matrix as a `numpy.ndarray`. The diagonal of the matrix is the probability that a given base is unpaired.

```python
probability_matrix = pairs(['CCC', 'GGG'])
import numpy as np
print(np.round(probability_matrix, 3))
# -->
# [[0.17  0.    0.    0.002 0.222 0.607]
#  [0.    0.01  0.    0.223 0.739 0.028]
#  [0.    0.    0.288 0.683 0.029 0.   ]
#  [0.002 0.223 0.683 0.092 0.    0.   ]
#  [0.222 0.739 0.029 0.    0.01  0.   ]
#  [0.607 0.028 0.    0.    0.    0.365]]
```

`sample` calculates a specified `number` of random secondary structures drawn according to the equilibrium Boltzmann distribution:

```python
sampled_structures = sample(['CCC', 'GGG'], number=3)
print(sampled_structures)
# --> [Structure('.((+)).'), Structure('(((+)))'), Structure('((.+)).')]
```

`count` calculates the number of secondary structures that can form for a specified complex:

```python
ensemble_size = count(['CCC', 'GGG'])
print(ensemble_size)
# --> 19
```

`tube_analysis` calculates the predicted complex concentrations in a test tube, given a set of strands, respective strand concentrations, and a `max_size` of complex to consider.

```python
complex_concentrations = tube_analysis(['CCCCC', 'GGGGG'], [1e-5, 1e-4], max_size=2)
print(complex_concentrations)
# --> {
#   ('GGGGG', 'GGGGG'): 0.0,
#   ('GGGGG',): 9.030597007787946e-05,
#   ('CCCCC',): 3.0597007787941787e-07,
#   ('CCCCC', 'CCCCC'): 0.0,
#   ('CCCCC', 'GGGGG'): 9.694029922120778e-06
# }
```

# Complex analysis

## Specification

NUPACK 4 provides a more flexible and efficient interface for thermodynamic analysis as well. To use this interface, first create an `Analysis` object by specifying the secondary structure model to use:

```python
analysis = nupack.Analysis(model=model)
```

Frequently, thermodynamic analysis can be sped up by computing quantities in aggregate, rather than one by one. For instance, caching may decrease the cost of analyzing complexes of up to $L$ strands by up to a factor of $L-1$. Therefore, the analysis API encourages queueing of all of the calculations you want to perform before computation actually takes place.

The way to queue each type of complex analysis computation is described in the below sections. After computation takes place, each method will yield a selection of field(s) in a `ComplexResult` object matching the specified complex.

Each method below takes a complex specification as its first argument. This should be given as an ordered sequence of strands (e.g. `strands=['AAA', 'TTT']`) or as an equivalent plus-separated string (e.g. `'AAA+TTT'`). An additional parameter `max_size` is provided as well. If `max_size=0` (the default), only the complex matching the specified ordered strands will be computed. Otherwise, each complexes of up to `max_size` (inclusive) consisting of a subset of the specified strands in any order will be computed.

After queueing your desired computations, follow the directions in [Computation](#computation).

### Partition function

**Example code:**

```python
analysis.partition_function(strands, max_size=3)
```

**Description:** Schedule computation of the partition function, $Q(\phi)$, over the ensemble $\Gamma'$. This computation will yield the output fields:

- `log_partition_function`
- `free_energy`

### Pair probability

**Example code:**

```python
analysis.pair_probability(strands, max_size=2)
```

**Description:** Schedule computation of *pair probabilities* $P_{i, j} \equiv p(i_n \cdot j_m)$ for the complex corresponding to the specified strand ordering $\pi$. The probability of an base being unpaired is on the matrix diagonal $P(i, i)$. The specified matrix $P$ is symmetric and satisfies $\sum_i P_{i, j} = 1$.

Analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands. This computation will yield the output fields:

- `pair_probability`
- `log_partition_function`
- `free_energy`

### Minimum free energy

**Example code:**

```python
analysis.min_free_energy(strands, max_size=2, structures=True)
```

**Description:** Schedule computation of the minimum free energy secondary structure(s), $s^\mathrm{MFE}(\phi)$, of sequence $\phi$ over the ensemble of the complex, $\Gamma$. This computation will yield the output fields:

- `min_free_energy`
- `mfe_structures` if `structures == True`

### Structure count

**Example code:**

```python
analysis.structure_count(strands, stacks=False)
```

**Description:** Schedule computation of the number of secondary structures, $|\Gamma|$, in the ensemble of the complex, treating all strands as distinct. This computation will yield the output fields:

- `log_structure_count` if `stacks == False`
- `log_stack_count` if `stacks == True`

### Boltzmann sampling

**Example code:**

```python
analysis.boltzmann_sample(strands, number=10)
```

**Description:** Schedule computation of `number` random secondary structures sampled from the equilibrium Boltzmann distribution. This computation will yield the output fields:

- `sampled_structures`
- `free_energy`
- `log_partition_function`

### Suboptimal structures

**Example code:**

```python
analysis.suboptimal_structure(strands, gap=0.4)
```

**Description:** Schedule computation of all secondary structures in $\Gamma$ with free energies within the specified (non-negative) free energy gap of the MFE. This could produce an astronomical number of structures if the specified gap is too large. This computation will yield the output fields:

- `suboptimal_structures`
- `mfe_structures`
- `min_free_energy`

## Computation

After queueing the computations you want to run, run the following command to start computation.

```python
analysis_result = analysis.compute(threads=1, cache_bytes=4e9) # same as analysis.compute()
```

You may specify the number of threads via the `threads` keyword and the maximum memory to use via the `cache_bytes` keyword. It is especially important on Linux systems not to set `cache_bytes` higher than your available RAM. The specification is in bytes, so `cache_bytes=4e9` is equivalent to a limit of 4 GB.

 `nupack.Analysis.compute()` returns a `nupack.AnalysisResult`. This class is a thin wrapper around a `dict` mapping a tuple of strands (e.g. `('AAAA', 'TTTT)`) to a result of type `nupack.ComplexResult`.

## Outputs

To retrieve a complex result for a desired complex of ordered strands, use the `__getitem__` method of `nupack.AnalysisResult`:

```
complex_result = analysis_result[('AAAA', 'TTTT')]
```

A `ComplexResult` is just a `namedtuple` of computed results for the given complex. Specifically, an instance of `ComplexResult` has the following fields which may or may not be `None` (depending on if a matching computation was requested):

- `log_partition_function`: the natural logarithm of the partition function. You can retrieve the partition function as `numpy.exp(complex_result.log_partition_function, dtype=numpy.float128)`, but be aware that this number may be too large to represent in a floating point format. The log partition function of an impossible complex is $-\infty$.

- `free_energy`: the complex free energy in kcal/mol. The free energy of an impossible complex is $+\infty$.

- `log_structure_count`: natural logarithm of the number of possible secondary structures (analogous to `log_partition_function`).

- `log_stack_count`: natural logarithm of the number of possible stacking states (analogous to `log_partition_function`).

- `min_free_energy`: the minimum stacking state free energy in kcal/mol.

- `mfe_structures`: a list of each [`Structure`](#structure-type) matching the minimum stacking state free energy.

- `pair_probability`: a `numpy.ndarray` of shape (N, N) of the base pairing probabilities. `P[i, j]` is a `float` of the probability that bases of zero-based indices `i` and `j` are paired. The pair probabilities of an impossible complex are all set to 0.

- `sampled_structures`: a randomly ordered list of each [`Structure`](#structure-type) sampled from the equilibrium Boltzmann distribution. The structures yielded for an impossible complex are represented as pair lists with no base pairs.

- `suboptimal_structures`: a list of each pair of a [`Structure`](#structure-type) and its respective free energy derived from the suboptimal structure algorithm with a specified free energy gap.

### Structure type

The output fields `mfe_structures`, `sampled_structures`, and `suboptimal_structures` contain secondary structures which are represented in NUPACK using the `Structure` type. A `Structure` instance contains two members:

1. `pairs`: a `PairList` of the base pairs in a given structure such that `pairs[i] == j` if the bases of zero-based index `i` and `j` are paired, and `pairs[i] == i` if the base of index `i` is unpaired.

2. `nicks`: a list of indices where each integer is the (zero-based) index of a base after a strand break

```python
s = nupack.Structure(nupack.PairList([5,4,3,2,1,0]), nicks=[3])
print(s.dp())          # output (str): (((+)))
print(s.pairs.array()) # output (numpy.ndarray): [5 4 3 2 1 0]
```

### Structure probability

The equilibrium probability of complex `strands` being in the secondary structure `structure` is cheap to compute once the partition function is known. For this purpose, the following method of `AnalysisResult` is provided.

```python
prob = analysis_result.structure_probability(strands, structure) # yields a float between 0 and 1
```

# Test tube analysis

Test tube analysis enables prediction of equilibrium concentrations and related quantities for an ensemble of strands at user-specified concentrations.

## Specification

Create an instance of `nupack.ConcentrationSolver` using an iterable of strands and a `nupack.AnalysisResult`. All partition function information from the previously calculated complex results is used by default. You must make sure that analysis was carried out on all complexes that you want to include in the test tube ensemble.

```python
solver = nupack.ConcentrationSolver(strands, analysis_result)
```

## Computation

Given a user-specified concentration for each strand species (in moles per liter), calculate the equilibrium concentration of each complex species or base pair in a dilute solution (e.g., a test tube) [@Dirks07]. This calculation is typically quick compared to the dynamic programming algorithms used in [Complex analysis](#complex-analysis).

```python
solver_result = solver.compute([1e-8, 1e-7])
concentration_result = solver_result.complex_concentrations()
```

The output `concentration_result` is a `dict` which maps from a `tuple` of strands to a complex concentration in moles per liter. You can repeatedly invoke the solver with different strand concentrations.

You may alternatively view your output using the `complexes` and `concentrations` fields of the solver result:

```python
print(solver_result.complexes) # prints a list of tuples of integers
print(concentrations) # prints a numpy.ndarray of equal length
```

Each item in `complexes` is a tuple of strand indices denoting a single complex. (The indices match those which were used to construct the `ConcentrationSolver`). Each item in `concentrations` is the concentration of the matching complex. Using this API is only recommended if you are interested in distinguishing between strands of identical sequences.

To restrict your test tube ensemble to only a subset of calculated complexes, `compute()` accepts an additional keyword `complexes`. If given, `complexes` should be an integer, in which case only complexes up to this maximum size will be incorporated, or a list of complexes to incorporate with each complex specified as a tuple of strand sequences.

For generic equilibrium concentration determination in any system of interacting particles, you may use the `nupack.concentration.solve_equilibrium()` function.

## Citations


