



## Specifying a sequence

A `Sequence` is specified by valid nucleotide letters, which can contain wildcards.  Run-length encoding may be used to specify repeats of a given nucleotide. For RNA, `'U'` is automatically replaced by `'T'` for printing purposes.

```python
s1 = Sequence('AAAAATTTTT')
s2 = Sequence('A5T5')
s3 = Sequence('A5U5')

s1 == s2 # --> True
s1 == s3 # --> True
s3 # --> Sequence('AAAAATTTTT')
```

You can access the reverse complement of a `Sequence` using the following syntaxes:

```python
s1.reverse_complement() # --> Sequence('TTTTTAAAAA')
~s1 # --> Sequence('TTTTTAAAAA')
```

The `~a` syntax is generally recommended for brevity. Thus `~a` corresponds to the usual complement specification `a*` (unfortunately, the latter is not valid Python).

---

## PairList

Under the hood, secondary structures are stored in NUPACK using the `PairList` object.
A pair list contains a list of zero-based indices $p$ such that if $p_i = j$, bases $i$ and $j$ are paired, and if $p_i = i$, base $i$ is unpaired.
Any secondary structure, including highly-nested pseudoknots, may be specified in this way.
(However, NUPACK 4 currently includes no functionality for analyzing pseudoknots.)

A `PairList` may be created using the following syntaxes in Python:

```python
s1 = PairList('((((((((((((+..........))))))))))))')
s2 = PairList('(12+.10)12')
s3 = PairList('D12 (+ U10)')
```

You can print a `PairList` to view its raw data:

```python
s = PairList('(...)')

s          # --> PairList([4, 1, 2, 3, 0])
print(s)   # --> [4 1 2 3 0]
```

Or you can access its data and calculating its corresponding structure matrix:

```python
s.array()  # --> array([4, 1, 2, 3, 0], dtype=int32)

s.structure_matrix() # --> array([[0, 0, 0, 0, 1],
                     #            [0, 1, 0, 0, 0],
                     #            [0, 0, 1, 0, 0],
                     #            [0, 0, 0, 1, 0],
                     #            [1, 0, 0, 0, 0]], dtype=int32)
```

---

## Structure

You might notice that the pair list specification does not include any information on structure nicks.
This can be inconvenient when printing a `PairList`.
As a result, NUPACK provides a `Structure` class, which inherits from `PairList` and adds a list of nick indices:


2. `nicks`: a list of indices where each integer is the (zero-based) index of a base after a strand break

```python
s = Structure('(((+)))')
s                      # --> Structure('(((+)))')
print(s)               # --> (((+)))
print(s.array())       # --> [5 4 3 2 1 0]
```

---

## Named objects

The remaining core objects accept a first argument of `name` to be specified by the user.

!!!note "Note"
    The name may specified as a `tuple` or `list` instead of a `str`, in which case a `'[]'` based string will be automatically generated. This is specifically useful for repeated definitions:

    ```python
    domains = [Domain('N6', name=['a', i]) for i in range(4)]
    print([d.name for d in domains]) # --> ['a[0]', 'a[1]', 'a[2]', 'a[3]']
    ```

Note that for text formatting, the following behavior has been implemented on the following objects:

- `str()` prints the value of the object
- `repr()` prints an expression which is equivalent to the one used to construct the object

For example:

```python
s = Domain('N6', name='a')
print(s) # --> NNNNNN
print(repr(s)) # --> Domain('a', 'NNNNNN')
```

!!! note
    In general, you should make every user-specified name unique. Uniqueness should hold across different classes of objects (`Domain`, `Strand`, etc.).

---

## Domain

A domain is a fixed-length sequence of nucleotides, primarily useful in a design context. It reflects a shared sequence that may appear multiple times in different strands. A domain may be created from a name and `Sequence` (or sequence string).

```python
a = Domain('ATCGTAGCTA', name='a')
b = Domain('ATATSSSKKN', name='b') # Wildcards are permitted
```

You can access the reverse complement of a `Domain` as you would a `Sequence`, e.g. as `~a`. In design, the invariant is maintained that the currently specified sequence of `a` is reverse complement to that of `~a`.

You may access the sequence of a `Domain` by calling `str()` on it:

```python
print(str(a)) # --> 'ATCGTAGCTA'
```

A domain only compares equal to another one if they have the same sequence and name:

```python
a1 = Domain('ATCGTAGCTA', name='a1')
a2 = Domain('ATCGTAGCTA', name='a2')

a1 == a2 # --> False
a1 == a1 # --> True
```

---




## Advanced usage

NUPACK 4 also provides a more flexible and lower-level interface for thermodynamic analysis as well. To use this interface, first create an `Specification` object by specifying the secondary structure model to use:

```python
spec = analysis.Specification(model=Model())
```

---

## Queuing calculations

Frequently, thermodynamic analysis can be sped up by computing quantities in aggregate, rather than one by one. For instance, caching may decrease the cost of analyzing complexes of up to $L$ strands by up to a factor of $L-1$. Therefore, the analysis API encourages queueing of all of the calculations you want to perform before computation actually takes place.

The way to queue each type of complex analysis computation is described in the below sections. After computation takes place, each method will yield a selection of field(s) in a `ComplexResult` object matching the specified complex.

Each method below takes a complex specification as its first argument. This should be given as an ordered sequence of strands (e.g. `strands=['AAA', 'TTT']`) or as an equivalent plus-separated string (e.g. `'AAA+TTT'`). An additional parameter `max_size` is provided as well. If `max_size=0` (the default), only the complex matching the specified ordered strands will be computed. Otherwise, each complexes of up to `max_size` (inclusive) consisting of a subset of the specified strands in any order will be computed.

After queueing your desired computations, follow the directions in [Computation](#computation).

---

### Partition function

**Example code:**

```python
strands = RawComplex('AAAAT+TTT')
spec.pfunc(strands, max_size=3)
```

**Description:** Schedule computation of the partition function, $Q(\phi)$, over the ensemble $\Gamma'$. This computation will yield the output fields:

- `pfunc`
- `free_energy`

---

### Pair probability

**Example code:**

```python
spec.pairs(strands, max_size=2)
```

**Description:** Schedule computation of *pair probabilities* $P_{i, j} \equiv p(i_n \cdot j_m)$ for the complex corresponding to the specified strand ordering $\pi$. The probability of an base being unpaired is on the matrix diagonal $P(i, i)$. The specified matrix $P$ is symmetric and satisfies $\sum_i P_{i, j} = 1$.

Analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands. This computation will yield the output fields:

- `pairs`
- `pfunc`
- `free_energy`

---

### Minimum free energy

**Example code:**

```python
spec.mfe(strands, max_size=2, structures=True)
```

**Description:** Schedule computation of the minimum free energy secondary structure(s), $s^\mathrm{MFE}(\phi)$, of sequence $\phi$ over the ensemble of the complex, $\Gamma$. This computation will yield the output fields:

- `mfe`

---

### Structure count

**Example code:**

```python
spec.ensemble_size(strands)
```

**Description:** Schedule computation of the number of secondary structures, $|\Gamma|$, in the ensemble of the complex, treating all strands as distinct. This computation will yield the output fields:

- `ensemble_size`

---

### Boltzmann sampling

**Example code:**

```python
spec.sample(strands, number=10)
```

**Description:** Schedule computation of `number` random secondary structures sampled from the equilibrium Boltzmann distribution. This computation will yield the output fields:

- `sample`
- `free_energy`
- `pfunc`

---

### Suboptimal structures

**Example code:**

```python
spec.subopt(strands, gap=0.4)
```

**Description:** Schedule computation of all secondary structures in $\Gamma$ with free energies within the specified (non-negative) free energy gap of the MFE. This could produce an astronomical number of structures if the specified gap is too large. This computation will yield the output fields:

- `subopt`
- `mfe`

## Computation

After queueing the computations you want to run, run the following command to start computation.

```python
analysis_result = spec.compute(analysis.Options(threads=1, cache_bytes=4e9)) # same as analysis.compute()
```

You may specify the number of threads via the `threads` keyword and the maximum memory to use via the `cache_bytes` keyword. It is especially important on Linux systems not to set `cache_bytes` higher than your available RAM. The specification is in bytes, so `cache_bytes=4e9` is equivalent to a limit of 4 GB.

 `Specification.compute()` returns a `RawResult`. This class is a thin wrapper around a `dict` mapping a tuple of strands (e.g. `('AAAA', 'TTTT)`) to a result of type `ComplexResult`.

## Outputs

To retrieve a complex result for a desired complex of ordered strands, use the `[]` (`__getitem__`) method of `RawResult`:

```python
complex_result = analysis_result[strands]
```

A `ComplexResult` is just a `namedtuple` of computed results for the given complex. Specifically, an instance of `ComplexResult` has the following fields which may or may not be `None` (depending on if a matching computation was requested):

- `pfunc`: the natural logarithm of the partition function. You can retrieve the partition function as `numpy.exp(complex_result.log_partition_function, dtype=numpy.float128)`, but be aware that this number may be too large to represent in a floating point format. The log partition function of an impossible complex is $-\infty$.

- `free_energy`: the complex free energy in kcal/mol. The free energy of an impossible complex is $+\infty$.

- `ensemble_size`: number of secondary structure or stacking states.

- `mfe`: a list of each [`Structure`](#structure-type) matching the minimum stacking state free energy.

- `pairs`: a `PairMatrix` of shape (N, N) of the base pairing probabilities. `P[i, j]` is a `float` of the probability that bases of zero-based indices `i` and `j` are paired. The pair probabilities of an impossible complex are all set to 0.

- `sample`: a randomly ordered list of each [`Structure`](#structure-type) sampled from the equilibrium Boltzmann distribution. The structures yielded for an impossible complex are represented as pair lists with no base pairs.

- `subopt`: a list of each pair of a [`Structure`](#structure-type) and its respective free energy derived from the suboptimal structure algorithm with a specified free energy gap.

---
<!--
### Structure probability

The equilibrium probability of complex `strands` being in the secondary structure `structure` is cheap to compute once the partition function is known. For this purpose, the following method of `RawResult` is provided.

``` python
prob = analysis_result.structure_probability(strands, structure) # yields a float between 0 and 1
``` -->

## Concentration solving

Test tube analysis enables prediction of equilibrium concentrations and related quantities for an ensemble of strands at user-specified concentrations.

---

### Specification

Create an instance of `nupack.ConcentrationSolver` using an iterable of strands and a `nupack.RawResult`. All partition function information from the previously calculated complex results is used by default. You must make sure that analysis was carried out on all complexes that you want to include in the test tube ensemble.

```python
solver = ConcentrationSolver(strands, analysis_result, distinguishable=True)
```

---

### Computation

Given a user-specified concentration for each strand species (in moles per liter), calculate the equilibrium concentration of each complex species or base pair in a dilute solution (e.g., a test tube) [@Dirks07]. This calculation is typically quick compared to the dynamic programming algorithms used in [Complex analysis](#complex-analysis).

```python
solver_result = solver.compute([1e-8, 1e-7])
concentration_result = solver_result.complex_concentrations
```

The output `concentration_result` is a `dict` which maps from a `tuple` of strands to a complex concentration in moles per liter. You can repeatedly invoke the solver with different strand concentrations.

You may alternatively view your output using the `complexes` and `concentrations` fields of the solver result:

```python
print(solver_result.complexes) # prints a list of tuples of integers
print(solver_result.concentrations) # prints a numpy.ndarray of equal length
```

Each item in `complexes` is a tuple of strand indices denoting a single complex. (The indices match those which were used to construct the `ConcentrationSolver`). Each item in `concentrations` is the concentration of the matching complex. Using this API is only recommended if you are interested in distinguishing between strands of identical sequences.

To restrict your test tube ensemble to only a subset of calculated complexes, `compute()` accepts an additional keyword `complexes`. If given, `complexes` should be an integer, in which case only complexes up to this maximum size will be incorporated, or a list of complexes to incorporate with each complex specified as a tuple of strand sequences.

For generic equilibrium concentration determination in any system of interacting particles, you may use the `nupack.concentration.solve_equilibrium()` function.

---

## Citations


