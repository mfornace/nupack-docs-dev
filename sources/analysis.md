# Analysis Jobs

NUPACK provides the capability to analyze equilibrium properties over one of two ensembles:

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$A, A$\cdot$B, B$\cdot$B) so as to capture both concentration information (how much A$\cdot$B forms?) and structural information (what are the base-pairing properties of A$\cdot$B when it does form?).

<hr>

## Specify a strand

A `Strand` is a single RNA or DNA molecule specified as a sequence and a strand name (keyword `name`):
```python
A = Strand('AGTCTAGGATTCGGCGTGGGTTAA', name='A') # name is required for strands
B = Strand('TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG', name='B')
C = Strand('AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG', name='C')
```

A `Strand` sequence must contain only `'ACGTU'`. Two strands are treated as indistinguishable only if they have the same name and the same sequence.

---

## Specify a complex ensemble

A `Complex` of one or more interacting strands is specified as an ordered list of strands (i.e., an ordering of strands around a circle in a [polymer graph](definitions.md#secondary-structure)) and an optional complex name (keyword `name`):
```python
c1 = Complex([A]) # name is optional for complexes
c2 = Complex([A, B, B, C], name='ABBC')
c3 = Complex([A, A], name='AA')
```

<!-- A `Complex` may also be specified conveniently by a single `'+'`-delimited string or list of strings:

```python
c4 = Complex('AAA+TTT+AAA')
c5 = Complex(['AAA', 'TTT', 'AAA'])
print(c4 == c5)
```
-->

In general, commands that expect a `Complex` as an argument (e.g., `c2`) will alternatively accept a strand ordering (e.g.,`[A, B, B, C]`). Two complexes are considered to be the same if they represent the same strand ordering around a circle independent of rotations (e.g., `Complex([A,B,C]) == Complex([B,C,A]) == Complex([C,A,B])`).

---

## Specify a test tube ensemble

A `Tube` is specified as a tube name (keyword `name`) and a set of strands (keyword `strands`), each introduced at a user-specified concentration (keyword `concentrations`; units of `M`), that interact to form a set of complexes. The set of complexes is specified in any of three ways: 1) combinatorially using keyword `max_size` to automatically generate the set of all complexes up to a specified number of strands (default: `max_size=1`); 2) using keyword `include` to include an explicitly specified set of complexes; 3) using keyword `exclude` to exclude an explicitly specified set of complexes:

```python
t1 = Tube(strands=[A, B], concentrations=[1e-6, 1e-8], name='t1') # max_size=1 default

t2 = Tube(strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12],
    max_size=3, include=[c2,[B, B, B, B]], exclude=[c1], name='t2')
```

Note that `include` and `exlude` accept both complex identifiers (e.g., `c2`) and strand orderings (e.g., `[B, B, B, B]`).

<!-- If a tube will only be used for calculations that do not :

```python
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```
-->

---

## Run a test tube analysis job

The `tube_analysis` command calculates the [partition function](definitions.md#partition-function), and [equilibrium concentration](definitions.md#equilibrium-complex-concentrations), for each complex species $j$ in one or more test tube ensembles. The test tube ensembles to be analyzed are specified using the `tubes` keyword. If desired, a [physical model](model.md#model-specification) is specified using the `model` keyword (otherwise the default physical model is used):

```python
# specify strands
a = Strand('CTGATCGAT', name='a')
b = Strand('GATCGTAGTC', name='b')

# specify tubes
t1 = Tube(strands=[a, b], concentrations=[1e-8, 1e-9], max_size=3, name='t1')
t2 = Tube(strands=[a, b], concentrations=[1e-10, 1e-9], max_size=2, name='t2')

# analyze tubes
model1 = Model()
tube_results = tube_analysis(tubes=[t1, t2], model=model1)
```

`tube_analysis` returns an `AnalysisResult` object that can be viewed as a table in a Jupyter notebook, for example:

```python
tube_results
```
Output:
> <img src="/figs/tube-analysis-output.png" alt="Tube analysis output" title="Example tube analysis output" width="280" />

For each complex in the ensemble, the [partition function](definitions.md#partition-function) and [complex free energy](definitions.md#complex-free-energy) (units of kcal/mol) are displayed. For each tube, the [equilibrium complex concenration](definitions.md#equilibrium-complex-concentration) of each complex in the tube is displayed (units of M).

---

Optionally, additional quantities are calculated for each complex in the specified tubes (see [Job Options](analysis.md#job-options)). For example, additionally calculate [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities), the [MFE proxy structure(s)](definitions.md#mfe-proxy-structure), 100 [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures), and the [ensemble size](definitions.md#complex-ensemble-size) for each complex in the tube:

```python
model1 = Model()
tube_results2 = tube_analysis(tubes=[t1, t2], model=model1,
    compute=['pairs', 'mfe', 'sample', 'ensemble_size'],
    options={'num_sample': 100}) # max_size=1 default
```
To display a summary table of results in a Jupyter notebook:

```python
tube_results2
```
Output:

> <img src="/figs/tube-analysis-output-2.png" alt="Tube analysis output" title="Example tube analysis output" width="480" />

Note that `pairs` and `sample` results are too large to be included in the summary table. See below for [programmatic access](#programmatic-access) to these results.

---

If desired, the results of a `tube_analysis` job can alternatively be calculated in two steps:

- Step 1: run a `complex_analysis` job (to calculate the [partition function](definitions.md#partition-function) for each complex);
- Step 2: run a `complex_concentrations` job (to calculate the [equilibrium concentration](definitions.md#equilibrium-complex-concentrations) for each complex in the context of a test tube given user-specified strand concentrations).

Most of the computational cost is in Step 1. The user-specified strand concentrations are used only in Step 2.
Hence, if you intend to analyze N test tubes containing the same strand species but N different sets of strand concentrations, it is cheaper to call `complex_analysis` once and `complex_concentrations` N times, rather than to call `tube_analysis` N times.


## Run a complex analysis job

Use the `complex_analysis` command to calculate the [partition function](definitions.md#partition-function) (and other additional quantities -- see [Job Options](analysis.md#job-options)) for each complex in a set (specified as a `Tube`):

```python
# specify strands
a = Strand('CTGATCGAT', name='a')
b = Strand('GATCGTAGTC', name='b')

# specify tubes
t1 = Tube(strands=[a, b], max_size=3, name='t1')
t2 = Tube(strands=[a, b], concentrations=[1e-10, 1e-9], max_size=2, name='t2')

# analyze tubes
model1 = Model()
complex_results = complex_analysis(tubes=[t1, t2], model=model1, compute=['pfunc'])
```

Note that tube `t1` defines a set of complexes (all complexes of up to `max_size=3` strands) but omits optional concentrations for strands `a` and `b` since `complex_analysis` does not calculate equilibrium complex concentrations, and hence does not require concentration information for the strand species. On the other hand, tube `t4` defines optional strand concentrations that will be ignored by `complex_analysis`.

---

`complex_analysis` returns an `AnalysisResult` object that can be viewed as a table in a Jupyter notebook, for example:

```python
complex_results
```

Output:

> <img src="/figs/complex-analysis-output.png" alt="Complex analysis output" title="Example complex analysis output" width="270" />

---

## Run a complex concentration job

Use the `complex_concentrations` command to calculate the [equilibrium concentration](definitions.md#equilibrium-complex-concentrations) of each complex in a test tube ensemble using the output from a previous call to `complex_analysis`:

```python
 # specify strand concentrations for t1
concentration_results = complex_concentrations(t1, complex_results,
    concentrations={a: 1e-8, b: 1e-8})

# use strand concentrations previously specified for t2
concentration_results2 = complex_concentrations(t2, complex_results)
```

Note that `complex_concentrations` operates on a single tube ensemble at a time since each tube represents a separate coupled equilibrium problem and no savings can be achieved by considering multiple concentration solves at the same time.

---

`complex_concentrations` returns an `AnalysisResult` object that can be viewed as a table in a Jupyter notebook, for example:

```python
concentration_results
```

Output:

> <img src="/figs/concentration-analysis-output.png" alt="Concentration analysis output" title="Example concentration analysis output" width="180" />

---

## Job options

For `tube_analysis` and `complex_analysis`, the optional `compute` keyword specifies a list of strings denoting additional calculations to be performed for each complex [@Fornace20]:

- `'pairs'`: calculate the matrix of [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities). If `'pairs'` is specified, `tube_analysis` or `complex_concentrations` will further calculate the matrix of [test tube ensemble pair fractions](definitions.md#ensemble-pair-fractions). See the `sparsity_fraction` and `sparsity_threshold` options below.

- `'sample'`: calculate a set of [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures) from the complex ensemble. See option `num_sample` below.

- `'mfe'`: calculate the [MFE proxy structure](definitions.md#mfe-proxy-structure), the free energy of the MFE proxy secondary structure and the free energy of the MFE stacking state. If there is more than one MFE stacking state, the algorithm returns a list of the corresponding MFE proxy secondary structures, each with the free energy of the MFE proxy secondary structure and with the (same) free energy of the MFE stacking state.

- `'subopt'`: calculate the set of [suboptimal proxy structures](definitions.md#suboptimal-proxy-structures) with a stacking state within a specified free energy gap of the MFE stacking state. The algorithm returns a list of suboptimal proxy secondary strutures, each with the free energy of the MFE proxy secondary structure, and with the free energy of its lowest-energy stacking state that falls within the energy gap. See option `subopt_gap` below.


- `'ensemble_size'`: calculate the [complex ensemble size](definitions.md#complex-ensemble-size) in terms of either the number of secondary structures (if using a [physical model](model.md#model-specification) with `nostacking`) or the number of stacking states (if using a [physical model](model.md#model-specification) with `stacking`).

The optional `options` keyword specifies options that modify the calculations performed for each complex:

- `'sparsity_fraction': f` can be used in conjuction with `'pairs'` to return a sparse matrix containing the fraction `f` of the largest pair probabilities for each base (default `'sparsity': 1` returns the full pair probability matrix).

- `'sparsity_threshold': t` can be used in conjuction with `'pairs'` to return a sparse matrix containing the only pair probabilities greater than or equal to `t` (default `'sparsity_threshold': 0` returns the full pair probability matrix).

- `'num_sample': n` can be used in conjunction with `'sample'` to specify the number of structures to be sampled (default `'num_sample': 1`).

- `'subopt_gap': g` can be used in conjunction with `'subopt'` to specify the (non-negative) free energy gap in kcal/mol (default `'subopt_gap': 0`).



---

## Job results

Scalar results of NUPACK analysis jobs can be conveniently displayed as a table, printed as text, or introspected programmatically. Consider the following test tube analysis job:

```python
a = Strand('CAGTCGATC', name='a')
b = Strand('ATCGACGTA', name='b')
c = Complex([a, b])

t1 = Tube([a, b], concentrations=[1e-6, 1e-9], include=[c], name='t1')
t2 = Tube([a, b], concentrations=[1e-8, 1e-9], include=[c], name='t2')

result = tube_analysis([t1, t2],
    compute=['pfunc', 'pairs', 'mfe', 'sample', 'subopt'],
    options={'num_sample': 2, 'energy_gap': 0.5})
```

### Tabular display
You can display a summary table of results in a Jupyter notebook as follows:

```python
result
```

Output:

> <img src="/figs/tube-analysis-output-3.png" alt="Tube analysis output" title="Example tube analysis output" width="380" />

### Textual display

You can view an ASCII representation of the same data by using the `print` function:

```python
print(result)
```

Output:

> ```
> Complex results:
>   Complex      Pfunc dG (kcal/mol) MFE (kcal/mol)
> 0   [a+b]  4.5255e+3        -5.188         -4.981
> 1     [a]  1.0000e+0        -0.000          0.000
> 2     [b]  1.0000e+0        -0.000          0.000
> Concentration results:
>   Complex    t1 (M)    t2 (M)
> 0   [a+b] 8.207e-14 8.208e-16
> 1     [a] 1.000e-06 1.000e-08
> 2     [b] 9.999e-10 1.000e-09
> ```

For convenience, you can print the identical ASCII result to a text file using the `save_text` function:

```python
result.save_text('my_result.txt')
```


### Programmatic access

More detailed results can also be displayed by programmatic access into an `AnalysisResult` object. This class contains two fields:

- `.complexes`: a Python `dict` mapping each `Complex` to a `ComplexResult`
- `.tubes`: a Python `dict` mapping each `Tube` to a `TubeResult`

The information contained in these two fields depends on which type of analysis calculation was performed:

- For [`tube_analysis`](#run-a-tube-analysis-job), both the `.tubes` and `.complexes` are non-empty.
- For [`complex_analysis`](#run-a-complex-analysis-job), the `.tubes` field is empty.
- For [`complex_concentrations`](#run-a-complex-concentration-job), the `.complexes` field is empty.

For convenience, you can index into a `TubeResult` via a `Tube` or `Complex`. The next two sections will show how this facilitates introspection of complex and tube ensemble results, respectively.


### Results for individual complexes

You can index into the result via a `Complex` to get its complex ensemble results, held in a `ComplexResult`. For instance:

```python
c_result = result[c]
```

The returned `ComplexResult` holds all complex ensemble quantities that were calculated in a `tube_analysis` or `complex_analysis` calculation. In full, this class contains the following fields, closely mirroring the `compute` keywords used. If a quantity was not computed, it is set to `None`.

- `pfunc`: complex [partition function](definitions.md#partition-function) (held as a `decimal.Decimal`). Convert to a `float` via `float(pf)` or calculate the logarithm via `float(pf.log())`
- `free_energy`: the [complex free energy](definitions.md#complex-free-energy) in kcal/mol (held as a `float`)
- `pairs`: [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities) (held as a `PairMatrix` containing a `.to_array()` method for conversion to numpy)
- `mfe`: a list of [MFE proxy structures](definitions.md#mfe-proxy-structure). Each structure contains fields `.structure`, `.energy`, and `.stack_energy`. `.energy` is the free energy of the MFE proxy secondary structure, while `.stack_energy` is the free energy of the MFE stacking state.
- `subopt`: same as `mfe`, but for all suboptimal structures below the specified energy gap (sorted by stacking state energy)
- `sample`: list of Boltzmann sampled structures (each an instance of `Structure`)
- `ensemble_size`: number of secondary structures (held as `int`)
- `model`: the `Model` that was used in the analysis calculation

<!-- - `mfe`: the [free energy of the MFE proxy structure(s)](definitions.md#mfe-proxy-structure) (held as `float`) -->
<!-- - `mfe_stack`: the [free energy of the MFE stacking state](definitions.md#mfe-proxy-structure) (held as `float`) -->

---

Depending on which types of analysis calculations were requested, these attributes may be looked up on any `ComplexResult` object. For example:

```python
print('The free energy of complex c is %.2f kcal/mol' % result[c].free_energy)
print('\nThe partition function of complex c is %.2e' % result[c].pfunc)
print('\nThe MFE of complex c is %.2f kcal/mol' % result[c].mfe[0].energy)
print('\nThe MFE structure of complex c is %s' % result[c].mfe[0].structure)
print('\nThe pair probabilities of complex c are: \n%s' % result[c].pairs)
```

Output:

```
The free energy of complex c is -5.19 kcal/mol

The partition function of complex c is 4.53e+03

The MFE of complex c is -4.98 kcal/mol

The MFE structure of complex c is (((+)))

The pair probabilities of complex c are:
[[0.1002 0.0000 0.0000 0.0007 0.1474 0.7518]
 [0.0000 0.0037 0.0000 0.1474 0.8307 0.0182]
 [0.0000 0.0000 0.1904 0.7910 0.0185 0.0001]
 [0.0007 0.1474 0.7910 0.0609 0.0000 0.0000]
 [0.1474 0.8307 0.0185 0.0000 0.0035 0.0000]
 [0.7518 0.0182 0.0001 0.0000 0.0000 0.2299]]
```

Using this, you can easily plot a pair probability matrix visually inside a Jupyter notebook. For example:

```python
%matplotlib inline
import matplotlib.pyplot as plt

plt.imshow(c_result.pairs.to_array())
plt.xlabel('Base index')
plt.ylabel('Base index')
plt.title('Pair probability of complex c')
plt.colorbar()
plt.savefig('my-figure.pdf') # optionally, save a PDF of your figure
```

Output:

> <img src="/figs/pairs-output.png" alt="Pair probability output" title="Example pair probability output" width="450" />

---

You can collect complex ensemble information for all calculated complexes easily as well. Since `result.complexes` is an ordinary python `dict`, iterating through its `.items()` will let you collect each complex result. For example, to iterate through the pair probabilitis for each complex:

```python
import numpy as np

for my_complex, complex_result in result.complexes.items():
    P = complex_result.pairs.to_array()
    s = 'Expected number of unpaired nucleotides in complex %s = %.2f'
    print(s % (my_complex.name, np.diagonal(P).sum()))
```

Output:

```
Expected number of unpaired nucleotides in complex [a+b] = 0.59
Expected number of unpaired nucleotides in complex [a] = 3.00
Expected number of unpaired nucleotides in complex [b] = 3.00
```

To collect a `dict` of MFEs for each complex:

```python
my_mfes = {my_complex.name: complex_result.mfe[0].energy
    for my_complex, complex_result in result.complexes.items()}

print(my_mfes)
```

Output:

```
{'[a+b]': -4.981351375579834, '[a]': 0.0, '[b]': 0.0}
```

To print out the complex concentrations for a given tube:

```python
for my_complex, conc in result.tubes[t1].complex_concentrations.items():
    print('The concentration of %s is %.2e' % (my_complex.name, conc))
```

Output:

```
The concentration of [a] is 1.00e-06
The concentration of [a+b] is 8.21e-14
The concentration of [b] is 1.00e-09
```

---



### Results for individual tubes

Access tube properties by indexing the result by a `Tube` object:

```python
t1_result = result[t1]
```

The returned `TubeResult` holds all tube ensemble quantities that were calculated in a `tube_analysis` or `complex_concentrations` calculation. This class contains the following fields:

- `complex_concentrations`: a `dict` from `Complex` to its (`float`) [equilibrium concentration](definitions.md#equilibrium-complex-concentrations) in molar.
- `ensemble_pair_fractions`: a square matrix of [equilibrium base pairing probablities](definitions.md#test-tube-ensemble-pair-fractions) averaged across complexes. The row and column index refers to the concatenated base index formed by concatenating the strands of the input `Tube` (in order). This field is `None` if  pair probabilities were not calculated.

Concentrations are held as a Python `dict` which may be printed as follows:

```python
for my_complex, conc in t1_result.complex_concentrations.items():
    print('The concentration of %s is %.3e M' % (my_complex, conc))
```

Output:

```
The concentration of CCC is 1.000e-06 M
The concentration of CCC+GGG is 8.207e-14 M
The concentration of GGG is 9.999e-10 M
```

If calculated, the ensemble pair fractions may be printed as follows:

```python
print(t1_result.ensemble_pair_fractions)
```

Output:

```
[[1.000e+00 0.000e+00 0.000e+00 5.653e-11 1.209e-08 6.170e-08]
 [0.000e+00 1.000e+00 0.000e+00 1.210e-08 6.817e-08 1.497e-09]
 [0.000e+00 0.000e+00 1.000e+00 6.492e-08 1.518e-09 6.893e-12]
 [5.653e-08 1.210e-05 6.492e-05 9.999e-01 0.000e+00 0.000e+00]
 [1.209e-05 6.817e-05 1.518e-06 0.000e+00 9.999e-01 0.000e+00]
 [6.170e-05 1.497e-06 6.893e-09 0.000e+00 0.000e+00 9.999e-01]]
```

