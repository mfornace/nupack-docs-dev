# Analysis

NUPACK provides the capability to analyze equilibrium properties over one of two ensembles:

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa), and complex design is inherent in test tube design (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing and designing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze or design the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$ A, A$\cdot$ B, B$\cdot$ B) so as to capture both concentration information (how much A$\cdot$ B forms?) and structural information (what are the base-pairing properties of A$\cdot$ B when it does form?).

<hr> </hr>

## Tube and complex analysis

`tube_analysis` may be used to to solve for the complex and tube ensemble properties of a set of [tubes](basics.md#Tube).

The following example computes the partition function, MFE structure, and 100 Boltzmann sampled structures of each complex in the specified tubes, as well as the equilibrium concentrations of complexes in each tube.

```python
a = Strand('a', 'CTGATCGAT')
b = Strand('b', 'GATCGTAGTC')

t1 = Tube('t1', [a, b], [1e-8, 1e-9], max_size=3)
t2 = Tube('t2', [a, b], [1e-10, 1e-9], max_size=2)

result = tube_analysis(tubes=[t1, t2],
    compute=['pairs', 'mfe', 'sample'], model=model,
    options={'num_sample': 100})
```

Sometimes it is unnecessary to compute equilibrium concentrations, and you just want complex ensemble information. You can compute these results by using the `complex_analysis` function. `complex_analysis` is almost identical to `tube_analysis` but does not compute any concentration information. It is thus unnecessary to specify strand concentrations in the input tubes:

```python
t1 = Tube('t1', strands=[A, B], include=[c1, c2, c3])
result = complex_analysis(tubes=[t1], compute=['pairs', 'mfe'])
result[c1] # --> ComplexResult
```

After running `complex_analysis`, you may solve for the equilibrium concentrations separately if this fits your workflow better. Computing equilibrium concentrations is generally very fast compared to evaluating the dynamic programs. This is done one tube at a time since no savings can be made by computing them together.

```python
t1_result = complex_concentrations(result, t1, concentrations=[1e-8, 1e-9]) # use manually specified concentrations if desired
t2_result = complex_concentrations(result, t2) # use concentration from t2

print(t1_result.complex_concentrations) # result concentrations
```

<hr> </hr>

### Specifying computations

For `tube_analysis` and `complex_analysis`, the `compute` keyword should be specified to be a list of strings denoting calculation types. The full list of possible complex ensemble calculations is:

- `'pfunc'`: compute partition function and free energy.
- `'mfe'`: compute MFE energy and structure(s).
- `'pairs'`: compute pair probability.
- `'sample'`: compute Boltzmann sampled keywords.
- `'subopt'`: compute suboptimal structures.
- `'structure_count'`: compute number of possible secondary structures.
- `'stack_count'`: compute number of possible stacking states.
- `'prob'`: compute probability of a secondary structure.

Several customizing options may be specified in the `options` field:

- `'sparsity': f` may be specified to return a sparse matrix of only the highest `f * n` pair probabilities for a given base, where `n` is the total number of bases in the complex. `f=1` (the default) returns the full pair probability matrix.
- `'num_sample': n` returns `n` sampled structures. `'n'` defaults to 1.
- `'energy_gap: e'` computes all structures within `e` kcal/mol of the MFE. `e` defaults to 0.
- Structures must be specified via `prob_structures` as a list of structures.

<hr> </hr>

### Result display

Some of the main results of NUPACK analysis can be visually displayed for a convenient first glance. This includes partition functions, minimum free energies, equilibrium concentrations, and other scalar quantities. Larger result objects (like pair probability matrices) can be printed by [introspecting into the result](Result_introspection). Take the following example analysis result:

```python
a = Strand('a', 'CAGTCGATC')
b = Strand('b', 'ATCGACGTA')
c = Complex([a, b])

t1 = Tube('t1', [a, b], concentrations=[1e-6, 1e-9], include=[c])
t2 = Tube('t2', [a, b], concentrations=[1e-8, 1e-9], include=[c])

result = tube_analysis([t1, t2], compute=['partition_function', 'pairs', 'mfe', 'sample', 'subopt'], options={'num_sample': 2, 'energy_gap': 0.5})
```

You may get a table summary of your result by simply running the following cell in a Jupyter notebook:

```python
result
```

> <img src="/figs/analysis-output.png" alt="Analysis output" title="Example analysis output" width="450" />

---

You may also view an ASCII representation of the same data by using the `print` function:

```python
print(result)
```

Output:

> ```python
> Complex results:
>   complex             partition_function  free_energy  min_free_energy
> 0     [a]  1.137196182165421254181526080    -0.079238         0.000000
> 1   [a+b]  54093099.97352546614889705124   -10.974342        -9.781352
> 2     [b]  1.083707216580423924606910741    -0.049545         0.000000
> Concentration results:
>   complex            t1            t2
> 0     [a]  9.995569e-07  9.992109e-09
> 1   [a+b]  4.431142e-10  7.891451e-12
> 2     [b]  5.568877e-10  9.921086e-10
> ```

<hr> </hr>

### Result introspection

The result of `tube_analysis` is an `AnalysisResult` with fields `.complexes` and `.tubes`. For convenience, you may index into the result via a `Tube` :

<!-- I'm not sure this indexing is a good idea. Maybe better to just use the `complexes` and `tubes` fields separately. -->

```python
result[t1] # --> TubeResult

result[t1].complex_concentrations # --> [1.5e-10]
result[t1].strand_pair_probability # --> [[1.0, 0.0], [0.0, 1.0]]
```

A `TubeResult` contains the following fields:

- `complex_concentrations`: a `dict` from `Complex` to its (`float`) equilibrium concentration in molar.
- `strand_pair_probability`: a square matrix of equilibrium base pairing probablities averaged across complexes. The row and column index refers to the concatenated base index formed by concatenating the strands of the input `Tube` (in order).

You may also index a result by a specified complex to get its complex ensemble results, held in a `ComplexResult`. For instance:

```python
result[c1]
# pfunc for complex c1
result[c1].partition_function
# mfe for complex c1
result[c1].min_free_energy
# mfe structure for complex c1
result[c1].mfe_structure
# ppairs matrix for complex c1
result[c1].pair_probability
```

Using this, you can easily plot a pair probability matrix visually inside a Jupyter notebook. For example:

```python
%matplotlib inline
import matplotlib.pyplot as plt

plt.imshow(result[c].pair_probability)
plt.xlabel('Base index')
plt.ylabel('Base index')
plt.title('Pair probability of complex c')
plt.colorbar()
plt.savefig('my-figure.pdf') # optionally, save a PDF of your figure
```

> <img src="/figs/pairs-output.png" alt="Pair probability output" title="Example pair probability output" width="450" />

You can collect complex ensemble information for all calculated complexes quite easily. For example:

```python
# set of MFEs for all complexes
{k: v.mfe for k, v in result.complexes.items()}
# set of pair probabilities for all complexes
{k: v.pair_probability for k, v in result.complexes.items()}
```

A `ComplexResult` contains the following fields, closely mirroring the `compute` keywords used. If a quantity was not computed, it is set to `None`.

- `partition_function`: complex partition function (held as `decimal.Decimal`)
- `free_energy`: complex free energy, in kcal/mol
- `mfe_structures`: list of pairs of structures and their associated free energies
- `pair_probability`: equilibrium pair probability matrix
- `sampled_structures`: list of Boltzmann sampled structures
- `suboptimal_structures`: list of suboptimal structures and their associated free energies
- `structure_count`: number of secondary structures (held as `decimal.Decimal`)
- `stack_count`: number of stacking states (held as `decimal.Decimal`)
- `structure_probabilities`: list of pairs of requested structures and their associated probabilities

<hr> </hr>

## Utilities

!!! note
    Seems less error-prone to just insist on specified model, especially for utilities?

<!--
Use `pfunc` to calculate a partition function:
my_pfunc = pfunc(c1, model=model) # pfunc(c1, model)

Use `mfe` to calculate a complex's MFE structure(s) and free energy(s):
my_mfe = mfe(c1, model=model)

Use `count` to calculate the size of the secondary structure ensemble:
my_count = count(c1, model=model)

Use `pairs` to calculate equilibrium base pair probability:
my_pairs = pairs(c1, model=model)

Use `prob` to calculate equilibrium structure probability:
my_prob = prob(c1, structure=s1) # 0.12385347

Use `subopt` to determine a set of suboptimal structures:
my_subopt = subopt(c1, energy_gap=1.2)

Use `sample` to randomly generate a set of secondary structures:
my_samples = sample(c1, num_sample=100)

s1 = Structure('.1(3.8)3.9') # Is there a use for named structures?
my_energy = energy(c1, structure='.(((........))).........') -->


<!-- Then call any of the functions documented below. The first input to each function is a list of strands. This may be specified as a list (e.g. `['AAT', 'TTTA']`) or as a `+`-delimited string (e.g. `'AAT+TTTA'`).  -->
NUPACK includes a number of utility functions meant for simple usage.
These functions can be very convenient, but they might involve unnecessary calculations compared to the full analysis API.
Each of the following functions also takes an optional trailing parameter `model`, which should be an instance of `nupack.Model` if specified. (See [Model](model.md) for help on creating a model object).

<hr> </hr>

### Partition function

`pfunc` returns the complex partition function of a single specified complex as a `decimal.Decimal`:

```python
partition_function = pfunc(['CCC', 'GGG'], model=Model(parameters='RNA', ensemble='stacking'))
print(partition_function)
# --> 1581.5360063360488947
```

<hr> </hr>

### Minimum free energy structure

`mfe` returns a list of MFE structures and their associated free energies. If the MFE is unique, the list will be length one:

```python
mfe_structures = mfe(['CCC', 'GGG'])
print(mfe_structures)
# --> [(Structure('(((+)))'), -4.181351661682129)]
```

`pairs` calculates the equilibrium base pair probability matrix as a `numpy.ndarray`. The diagonal of the matrix is the probability that a given base is unpaired.

```python
probability_matrix = pairs(['CCC', 'GGG'])
print(probability_matrix.round(3))
# -->
# [[0.17  0.    0.    0.002 0.222 0.607]
#  [0.    0.01  0.    0.223 0.739 0.028]
#  [0.    0.    0.288 0.683 0.029 0.   ]
#  [0.002 0.223 0.683 0.092 0.    0.   ]
#  [0.222 0.739 0.029 0.    0.01  0.   ]
#  [0.607 0.028 0.    0.    0.    0.365]]
```

<hr> </hr>

### Equilibrium structure probability

`prob` calculates the probability of a given secondary structure appearing in a single specified complex:

```python
probability = prob(['CCC', 'GGG'], structure='(((+)))')
print(probability)
# --> 0.5589045601083861
```

<hr> </hr>

### Equilibrium structure probability

`subopt` calculates all secondary structures within a specified free energy `gap` of the MFE. The free energy gap is specified in kcal/mol:

```python
subopt_structures = subopt(['CCC', 'GGG'], gap=1.0)
print(subopt_structures)
# --> [
#   (Structure('(((+)))'), -4.181351661682129),
#   (Structure('((.+)).'), -3.3813514709472656)
# ]
```

<hr> </hr>

### Boltzmann sampling

`sample` calculates a specified `number` of random secondary structures drawn according to the equilibrium Boltzmann distribution:

```python
sampled_structures = sample(['CCC', 'GGG'], number=3)
print(sampled_structures)
# --> [Structure('.((+)).'), Structure('(((+)))'), Structure('((.+)).')]
```

<hr> </hr>

### Structure and stacking state counts
`count` calculates the number of secondary structures that can form for a specified complex:

```python
ensemble_size = count(['CCC', 'GGG'])
print(ensemble_size)
# --> 19
```

<hr> </hr>

## Advanced usage

NUPACK 4 also provides a more flexible and lower-level interface for thermodynamic analysis as well. To use this interface, first create an `Specification` object by specifying the secondary structure model to use:

```python
analysis = nupack.analysis.Specification(model=model)
```

<hr> </hr>

### Queuing calculations

Frequently, thermodynamic analysis can be sped up by computing quantities in aggregate, rather than one by one. For instance, caching may decrease the cost of analyzing complexes of up to $L$ strands by up to a factor of $L-1$. Therefore, the analysis API encourages queueing of all of the calculations you want to perform before computation actually takes place.

The way to queue each type of complex analysis computation is described in the below sections. After computation takes place, each method will yield a selection of field(s) in a `ComplexResult` object matching the specified complex.

Each method below takes a complex specification as its first argument. This should be given as an ordered sequence of strands (e.g. `strands=['AAA', 'TTT']`) or as an equivalent plus-separated string (e.g. `'AAA+TTT'`). An additional parameter `max_size` is provided as well. If `max_size=0` (the default), only the complex matching the specified ordered strands will be computed. Otherwise, each complexes of up to `max_size` (inclusive) consisting of a subset of the specified strands in any order will be computed.

After queueing your desired computations, follow the directions in [Computation](#computation).

<hr> </hr>

#### Partition function

**Example code:**

```python
analysis.partition_function(strands, max_size=3)
```

**Description:** Schedule computation of the partition function, $Q(\phi)$, over the ensemble $\Gamma'$. This computation will yield the output fields:

- `log_partition_function`
- `free_energy`

<hr> </hr>

#### Pair probability

**Example code:**

```python
analysis.pair_probability(strands, max_size=2)
```

**Description:** Schedule computation of *pair probabilities* $P_{i, j} \equiv p(i_n \cdot j_m)$ for the complex corresponding to the specified strand ordering $\pi$. The probability of an base being unpaired is on the matrix diagonal $P(i, i)$. The specified matrix $P$ is symmetric and satisfies $\sum_i P_{i, j} = 1$.

Analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands. This computation will yield the output fields:

- `pair_probability`
- `log_partition_function`
- `free_energy`

<hr> </hr>

#### Minimum free energy

**Example code:**

```python
analysis.min_free_energy(strands, max_size=2, structures=True)
```

**Description:** Schedule computation of the minimum free energy secondary structure(s), $s^\mathrm{MFE}(\phi)$, of sequence $\phi$ over the ensemble of the complex, $\Gamma$. This computation will yield the output fields:

- `min_free_energy`
- `mfe_structures` if `structures == True`

<hr> </hr>

#### Structure count

**Example code:**

```python
analysis.structure_count(strands, stacks=False)
```

**Description:** Schedule computation of the number of secondary structures, $|\Gamma|$, in the ensemble of the complex, treating all strands as distinct. This computation will yield the output fields:

- `log_structure_count` if `stacks == False`
- `log_stack_count` if `stacks == True`

<hr> </hr>

#### Boltzmann sampling

**Example code:**

```python
analysis.boltzmann_sample(strands, number=10)
```

**Description:** Schedule computation of `number` random secondary structures sampled from the equilibrium Boltzmann distribution. This computation will yield the output fields:

- `sampled_structures`
- `free_energy`
- `log_partition_function`

<hr> </hr>

#### Suboptimal structures

**Example code:**

```python
analysis.suboptimal_structure(strands, gap=0.4)
```

**Description:** Schedule computation of all secondary structures in $\Gamma$ with free energies within the specified (non-negative) free energy gap of the MFE. This could produce an astronomical number of structures if the specified gap is too large. This computation will yield the output fields:

- `suboptimal_structures`
- `mfe_structures`
- `min_free_energy`

### Computation

After queueing the computations you want to run, run the following command to start computation.

```python
analysis_result = analysis.compute(threads=1, cache_bytes=4e9) # same as analysis.compute()
```

You may specify the number of threads via the `threads` keyword and the maximum memory to use via the `cache_bytes` keyword. It is especially important on Linux systems not to set `cache_bytes` higher than your available RAM. The specification is in bytes, so `cache_bytes=4e9` is equivalent to a limit of 4 GB.

 `Specification.compute()` returns a `RawResult`. This class is a thin wrapper around a `dict` mapping a tuple of strands (e.g. `('AAAA', 'TTTT)`) to a result of type `ComplexResult`.

### Outputs

To retrieve a complex result for a desired complex of ordered strands, use the `[]` (`__getitem__`) method of `RawResult`:

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

<hr> </hr>

#### Structure probability

The equilibrium probability of complex `strands` being in the secondary structure `structure` is cheap to compute once the partition function is known. For this purpose, the following method of `RawResult` is provided.

```python
prob = analysis_result.structure_probability(strands, structure) # yields a float between 0 and 1
```

### Concentration solving

Test tube analysis enables prediction of equilibrium concentrations and related quantities for an ensemble of strands at user-specified concentrations.

<hr> </hr>

#### Specification

Create an instance of `nupack.ConcentrationSolver` using an iterable of strands and a `nupack.RawResult`. All partition function information from the previously calculated complex results is used by default. You must make sure that analysis was carried out on all complexes that you want to include in the test tube ensemble.

```python
solver = nupack.ConcentrationSolver(strands, analysis_result)
```

<hr> </hr>

#### Computation

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

<hr> </hr>

## Citations


