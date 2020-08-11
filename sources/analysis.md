# Analysis Jobs

NUPACK provides the capability to analyze equilibrium properties over one of two ensembles:

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$ A, A$\cdot$ B, B$\cdot$ B) so as to capture both concentration information (how much A$\cdot$ B forms?) and structural information (what are the base-pairing properties of A$\cdot$ B when it does form?).

<hr> 

## Specify a strand

A `Strand` is a single RNA or DNA molecule specified as a strand name and sequence:   
```python
A = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')
```

If desired, the strand sequence can be specified as a list of [sequence domains](design.md#sepcify-a-domain) (this approach is primarily useful in the context of design jobs):
```python
a1 = Domain('a1', 'AGTCTAGGATTCGGCGT')
a2 = Domain('a2', 'GGGTTAA')
D = Strand('D', [a1, a2]) 
```

Two strands compare as equal only if they are the same Python object:

```python
A1 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
A2 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')

A1 == A2 # False
A1 == A1 # True
```

<hr> </hr>

## Specify a complex ensemble

A `Complex` of one or more interacting strands is specified as a strand ordering (i.e., an ordering of strands around a circle in a [polymer graph](definitions.md#secondary-structure)): 
```python
c1 = Complex([A])
c2 = Complex([A, B, B, C])
c3 = Complex([A, A])
```

Optionally, the name of the complex may be specified as the first argument: 
```python
c4 = Complex('A+B+C', [A, B, C])
```

Two complexes compare as equal if they represent the same strand ordering:

```python
c3a = Complex('A-B-C', [A, B, C])
c3b = Complex('B-C-A', [B, C, A])
c4  = Complex('A-C-B', [A, C, B])

c3a == c3b # True
c3a == c3a # True
c3a == c4 # False
```

In general, commands that expect a complex identifier as an argument (e.g., `c4`) will alternatively accept a strand ordering (e.g.,`[A,C,B]`).


<hr> </hr>

## Specify a test tube ensemble

A `Tube` is specified as a tube name and a set of strands (keyword `strands`) each introduced at a user-specified concentration (keyword `concentrations`), that interact to form a set of complexes. The set of complexes is specified in any of three ways: 1) combinatorially using keyword `max_size` to automatically generate the set of all complexes up to a specified number of strands (default: `max_size=1`); 2) using keyword `include` to include an explicitly specified set of complexes; 3) using keyword `exclude` to exclude an explicitly specified set of complexes:  

```python
t1 = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8]) # max_size=1 by default
t2 = Tube('t2', strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12], 
    max_size=3, include=[c2,[B, B, B, B]], exclude=[c1])
```

Note that `include` and `exlude` accept both complex identifiers (e.g., `c2`) and strand orderings (e.g., `[B, B, B, B]`). 

<!-- If a tube will only be used for calculations that do not :

```python
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```  
-->

Two tubes compare as equal only if they are the same Python object

```python
t1a = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])
t1b = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])

t1a == t1b # False
t1a == t1a # True
```

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
result34[c1] # --> ComplexResult
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

print(t1_result.complex_concentrations) # result concentrations
```

Note that `complex_concentrations` operates on a single tube ensemble at a time since each tube represesnts a separate coupled equilibrium problem and no savings can be achieved by considering multiple concentration solves at the same time. 




## Job options

For `tube_analysis` and `complex_analysis`, the optional `compute` keyword specifies a list of strings denoting additional calculations to be performed for each complex [@Fornace20]:  

- `'mfe'`

compute the free energy of the minimum free energy (MFE) stacking state $s_\mathrm{MFE}^\shortparallel(\phi) \in\overline\Gamma^\shortparallel(\phi)$ treating all strands as distinct:

$\overline{\Delta G}(\phi,s^\shortparallel_{\rm MFE}) \equiv \min_{s^\shortparallel\in\overline\Gamma^\shortparallel(\phi)} \overline{\Delta G}(\phi,s^\shortparallel)$

and calculate the MFE proxy structure

$s_\mathrm{MFE'} \equiv \{s\in\overline\Gamma(\phi) | s^\shortparallel_\mathrm{MFE}\!\in\! s, s^\shortparallel_\mathrm{MFE}(\phi) = \arg \min_{s^\shortparallel\in\overline\Gamma^\shortparallel(\phi)} \overline{\Delta G}(\phi,s^\shortparallel)\}$

defined as the secondary structure containing the MFE stacking state within its subensemble.
If there is more than one MFE stacking state, the algorithm returns all corresponding MFE proxy structures. 

- `'pairs'`

Compute the base-pairing probability matrix $\overline P(\phi)$ with entries $\overline P^{i,j}(\phi)\in[0,1]$ corresponding to the probability

$\overline P^{i,j}(\phi) = \sum_{s\in\overline\Gamma(\phi)} \overline p(\phi,s) S^{i,j}(s)$

that base pair $i\cdot j$ forms at equilibrium within ensemble $\overline\Gamma(\phi)$, treating all strands as distinct.
Here, $S(s)$ is a structure matrix with entries
$S^{i,j}(s) = 1$ if structure $s$ contains base pair $i\cdot j$ and $S^{i,j}(s)=0$ otherwise.
Abusing notation, the entry $S^{i,i}(s)$ is 1 if base $i$ is unpaired in structure $s$ and 0 otherwise; the entry $P^{i,i}(\phi) \in [0,1]$ denotes the equilibrium probability that base $i$ is unpaired over ensemble $\overline\Gamma(\phi)$.
Hence $S(s)$ and $\overline P(\phi)$ are symmetric matrices with row and column sums of 1.

- `'sample'`

Compute a set of $J$ secondary structures: 

$\Gamma_\mathrm{sample}(\phi,J) \in \Gamma(\phi)$

Boltzmann sampled from ensemble $\Gamma(\phi)$ treating strands with the same sequence as indistinguishable.


- `'subopt'`

Compute the set of suboptimal secondary structures:

$\overline\Gamma_{\rm subopt}(\phi,\Delta G_{\rm gap}) = \{s\in\overline\Gamma(\phi) | s^\shortparallel\!\in\! s, \overline{\Delta G}(\phi,s^\shortparallel) \le \overline{\Delta G}(\phi,s^\shortparallel_{\rm MFE}) + \Delta G_{\rm gap}\}$

with stacking states within a specified $\Delta G_\mathrm{gap}\ge 0$ of the MFE stacking state.


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

