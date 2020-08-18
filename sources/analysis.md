# Analysis Jobs

NUPACK provides the capability to analyze equilibrium properties over one of two ensembles:

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$ A, A$\cdot$ B, B$\cdot$ B) so as to capture both concentration information (how much A$\cdot$ B forms?) and structural information (what are the base-pairing properties of A$\cdot$ B when it does form?).

<hr>

## Specify a strand

A `Strand` is a single RNA or DNA molecule specified as a sequence:
```python
A = Strand('AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')
```

A `Strand` sequence must contain no wildcard bases; thus it should be specified as only containing the letters `'ACGTU'`.

<hr> </hr>

## Specify a complex ensemble

A `Complex` of one or more interacting strands is specified as an ordered list of strands (i.e., an ordering of strands around a circle in a [polymer graph](definitions.md#secondary-structure)):
```python
c1 = Complex([A])
c2 = Complex([A, B, B, C])
c3 = Complex([A, A])
```

A `Complex` may also be specified conveniently by a single `'+'`-delimited string or list of strings:

```python
c4 = Complex('AAA+TTT+AAA')
c5 = Complex(['AAA', 'TTT', 'AAA'])
print(c4 == c5) # --> True
```

In general, commands that expect a `Complex` as an argument (e.g., `c5`) will alternatively accept a strand ordering (e.g.,`[A,C,B]`).

<hr> </hr>

## Specify a test tube ensemble

A `Tube` is specified as a set of strands (keyword `strands`) each introduced at a user-specified concentration (keyword `concentrations`), that interact to form a set of complexes. The set of complexes is specified in any of three ways: 1) combinatorially using keyword `max_size` to automatically generate the set of all complexes up to a specified number of strands (default: `max_size=1`); 2) using keyword `include` to include an explicitly specified set of complexes; 3) using keyword `exclude` to exclude an explicitly specified set of complexes:

```python
t1 = Tube(strands=[A, B], concentrations=[1e-6, 1e-8]) # max_size=1 by default

t2 = Tube(strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12],
    max_size=3, include=[c2,[B, B, B, B]], exclude=[c1])
```

Note that `include` and `exlude` accept both complex identifiers (e.g., `c2`) and strand orderings (e.g., `[B, B, B, B]`).

<!-- If a tube will only be used for calculations that do not :

```python
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```
-->

<hr> </hr>

## Run a test tube analysis job

The `tube_analysis` command calculates the partition function, $Q(\phi_j)$, and equilibrium concenration, $x(\phi_j)$, for each complex species $j$ in one or more test tube ensembles. The test tube ensembles to be analyzed are specified using the `tubes` keyword. If desired, a [physical model](model.md#modelspecification) is specified using the `model` keyword (otherwise the default physical model is used):

```python
# specify strands
a = Strand('a', 'CTGATCGAT')
b = Strand('b', 'GATCGTAGTC')

# specify tubes
t1 = Tube('t1', strands=[a, b], concentrations=[1e-8, 1e-9], max_size=3)
t2 = Tube('t2', strands=[a, b], concentrations=[1e-10, 1e-9], max_size=2)

# analyze tubes
result1 = tube_analysis(tubes=[t1, t2], model=model1)
```

Optionally, additional quantities are calculated for each complex in the tube (see [Job Options](analysis.md#job_options)). For example, additionally calculate equilibrium base-pairing probabilities, the MFE structure(s), and 100 Boltzmann sampled structures for each complex in the tube:

```python
result2 = tube_analysis(tubes=[t1, t2], model=model1, compute=['pairs', 'mfe', 'sample'],
    options={'num_sample': 100})
```

If desired, the results of a `tube_analysis` job can alternatively be calculated in two steps:

- Step 1: run a `complex_analysis` job (to calculate the partition function for each complex);
- Step 2: run a `complex_concentrations` job (to calculate the equilibrium concentration for each complex in the context of a test tube given user-specified strand concentrations).

Most of the computational cost is in Step 1. The strand concentrations are used only in Step 2.
Hence, if you intend to analyze N test tubes containing the same strand species but N different sets of strand concentrations, it is cheaper to call `complex_analysis` once and `complex_concentrations` N times, rather than to call `tube_analysis` N times.



## Run a complex analysis job
Use the `complex_analysis` command to calculate the partition function (and other additional quantities -- see [Job Options](analysis.md#job_options)) for each complex in a set:

```python
t3 = Tube('t3', strands=[A, B], include=[c1, c2, c3])

t4 = Tube('t4', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=2)

my_plexes = complex_analysis(tubes=[t3, t4], compute=['pairs', 'mfe'])
my_plexes[c1] # --> ComplexResult
```

Note that tube `t3` defines a set of complexes (all complexes of up to `max_size=1` strands plus pre-defined complexes `c1`, `c2`, `c3`) but omits optional concentrations for strands `A` and `B` since `complex_analysis` does not calculate equilibrium complex concentrations, and hence does not require concentration information for the strand species. On the other hand, tube `t4` defines optional strand concentrations that will be ignored by `complex_analysis`.

<hr> </hr>

## Run a complex concentration job

Use the `complex_concentrations` command to calculate the equilibrium concentration of each complex in a test tube ensemble using the output from a previous call to `complex_analysis`:

```python
 # specify strand concentrations for t3
t3_result = complex_concentrations(my_plexes, t3, concentrations=[1e-8, 1e-9])

# use strand concentrations previously specified for t4
t4_result = complex_concentrations(my_plexes, t4)

# access result concentrations as a dict from Complex to float
print(t1_result.complex_concentrations)
```

Note that `complex_concentrations` operates on a single tube ensemble at a time since each tube represesnts a separate coupled equilibrium problem and no savings can be achieved by considering multiple concentration solves at the same time.




## Job options

For `tube_analysis` and `complex_analysis`, the optional `compute` keyword specifies a list of strings denoting additional calculations to be performed for each complex [@Fornace20]:

- `'pairs'`: calculate the matrix of [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities). If `'pairs'` is specified, `tube_analysis` or `complex_concentrations` will further calculate the matrix of [test tube ensemble pair fractions](definitions.md#ensemble-pair-fractions).

- `'sample'`: calculate a set of [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures) from the complex ensemble.

- `'mfe'`: calculate the [MFE proxy structure](definitions.md#mfe-proxy-structure), the free energy of the MFE stacking state, and the free energy of the MFE proxy secondary structure. If there is more than one MFE stacking state, the algorithm returns a list of the corresponding MFE proxy secondary structures, each with the (same) free energy of the MFE stacking state, and with the free energy of the MFE proxy secondary structure.

- `'subopt'`: calculate the set of [suboptimal proxy structures](definitions.md#suboptimal-proxy-structures) with a stacking state within a specified free energy gap of the MFE stacking state. The algorithm returns a list of suboptimal proxy secondary strutures, each with the free energy of its lowest-energy stacking state that falls within the energy gap, and with the free energy of the MFE proxy secondary structure.


- `'size'`: calculate the [complex ensemble size](definitions.md#complex-ensemble-size) in terms of either the number of secondary structures (if using a [physical model](model.md#model-specification) with `nostacking`) or the number of stacking states (if using a physical model with `stacking`).

The optional `options` keyword specifies options that modify the calculations performed for each complex:

- `'sparsity': f` can be used in conjuction with `'pairs'` to return a sparse matrix containing the fraction `f` of the largest pair probabilities for each base (default `'sparsity': 1` returns the full pair probability matrix).

- `'num_sample': n` can be used in conjunction with `'sample'` to specify the number of structures to be sampled (default `'num_sample': 1`).

- `'subopt_gap': g` can be used in conjunction with `'subopt'` to specify the (positive) free energy gap in kcal/mol (default `'subopt_gap': 0`).



<hr> </hr>

## Job results

Some of the main results of NUPACK analysis can be visually displayed for a convenient first glance. This includes partition functions, minimum free energies, equilibrium concentrations, and other scalar quantities. Larger result objects (like pair probability matrices) can be printed by [introspecting into the result](Result_introspection). Take the following example analysis result:

```python
a = Strand('CAGTCGATC')
b = Strand('ATCGACGTA')
c = Complex([a, b])

t1 = Tube([a, b], concentrations=[1e-6, 1e-9], include=[c])
t2 = Tube([a, b], concentrations=[1e-8, 1e-9], include=[c])

result = tube_analysis([t1, t2], compute=['pfunc', 'pairs', 'mfe', 'sample', 'subopt'], options={'num_sample': 2, 'energy_gap': 0.5})
```

### Visual display

You may get a table summary of your result by simply running the following cell in a Jupyter notebook:

```python
result
```

> <img src="/figs/analysis-output.png" alt="Analysis output" title="Example analysis output" width="500" />

---

You may also view an ASCII representation of the same data by using the `print` function:

```python
print(result)
```

Output:

> ```python
> Complex results:
>                complex partition_function free_energy  min_free_energy
> 0  CAGTCGATC+ATCGACGTA          9.1286e+7      -11.30       -10.960994
> 1            CAGTCGATC          1.0148e+0       -0.01         0.000000
> 2            ATCGACGTA          1.0056e+0       -0.00         0.000000
> Concentration results:
>                complex       tube 0       tube 1
> 0  CAGTCGATC+ATCGACGTA 6.185218e-10 1.593980e-11
> 1            CAGTCGATC 9.993815e-07 9.984060e-09
> 2            ATCGACGTA 3.814782e-10 9.840602e-10
> ```

Finally, you can print the ASCII result to a text file using the `save_text` function:

```python
result.save_text('my_result.txt')
```

<hr> </hr>

### Programmatic access

The result of `tube_analysis` is an `analysis.Result` with fields `.complexes` and `.tubes`. For convenience, you may index into the result via a `Tube` :

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

- `partition_function`: complex partition function (held as a `PartitionFunction`). Convert to a `float` via `float(pf)`, calculate the logarithm via `float(pf.log())`, or access the equivalent free energy as `pf.free_energy`.
- `mfe_structures`: list of `StructureEnergy`, a tuple of (`structure`, `energy`, and `stack_energy`). `energy` is the secondary structure free energy, while `stack_energy` is the free energy of the most stable stacking state.
- `pair_probability`: equilibrium pair probability matrix (as a `numpy.ndarray` unless sparsity is specified).
- `sampled_structures`: list of Boltzmann sampled structures
- `suboptimal_structures`: same as `mfe_structures`, but for all suboptimal structures below the specified energy gap
- `structure_count`: number of secondary structures (held as `int`)
- `stack_count`: number of stacking states (held as `int`)
- `structure_probabilities`: list of pairs of requested structures and their associated probabilities

<hr> </hr>

