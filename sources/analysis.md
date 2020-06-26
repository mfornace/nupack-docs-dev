# Analysis

NUPACK provides the capability to analyze equilibrium properties over one of two ensembles:

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa), and complex design is inherent in test tube design (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing and designing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze or design the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$ A, A$\cdot$ B, B$\cdot$ B) so as to capture both concentration information (how much A$\cdot$ B forms?) and structural information (what are the base-pairing properties of A$\cdot$ B when it does form?).

<hr> 

## Specify a strand

A strand representes a single physical strand of RNA or DNA (with no nicks n the phosphate backbone). A strand may be initialized either from a single sequence or from a list of domains:

```python
A = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

a1 = Domain('a1', 'AGTCTAGGATTCGGCGT')
a2 = Domain('a2', 'GGGTTAA')
D = Strand('D', [a1, a2]) # mostly useful in a design context
```

A strand only compares equal to another one if they are the same Python object.

```python
A1 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
A2 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')

A1 == A2 # --> False
A1 == A1 # --> True
```

<hr> </hr>

## Specify a complex ensemble

A complex may be created from an ordered list of strands. Unlike the other named objects, the name for a `Complex` is optional and may be omitted:

```python
c1 = Complex([A])
c2 = Complex([A, B, B, C])
c3 = Complex([A, A])
```

In general, anytime a `Complex` is expected, a list of strands may be used instead. Optionally, a complex may be given a name by specifying it first:

```python
c4 = Complex('A+B+C', [A, B, C])
```

Complexes are compared based on the lowest rotational order of the contained strands:

```python
c1a = Complex('A-B', [A, B])
c1b = Complex('B-A', [B, A])

c1a == c1b # --> True
c1a == c1a # --> True
```

<hr> </hr>

## Specify a test tube ensemble

A `Tube` is a collection of interacting strands, each at a user-specified concentration. A `Tube` may be created from a set of strands with specified concentrations. Complexes may be explicitly included via the keyword `include`. All complexes of up to size `n` may be included by specifying `max_size=n` (`max_size` defaults to 1). Complexes may be specifically excluded from the automatically generated set via the `exclude` keyword.

```python
t1 = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8])
t2 = Tube('t2', strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12], include=[c2], max_size=3, exclude=[c1])
```

For convenience, the concentrations may be left out, in which case the strands may be given without concentrations:

```python
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```

A tube only compares equal to itself if it is the same Python object

```python
t1a = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])
t1b = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])

t1a == t1b # --> False
t1a == t1a # --> True
```

<hr> </hr>



## Run a test tube analysis job

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

## Run a complex analysis job

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




## Job options

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

## Job results

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

