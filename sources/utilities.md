

# Utilities Jobs

<!--!!! note
    Seems less error-prone to just insist on specified model, especially for utilities?
-->

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
Utilities commands analyze or design a single complex ensemble. For each command, the first argument is the strand ordering of the complex.  If desired, a [physical model](model.md#model-specification) is specified using the `model` keyword (otherwise the default physical model is used).
For commands that require a structure (e.g., calculation of the equilibrium structure probability using `prob`), the structure is specified using the keyword `structure`.

## Compute partition function

`pfunc` calculates the [partition function](definitions.md#partition-function) of the complex as well as the free energy of the complex:

```python
partition_function = pfunc(complex=['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='stacking'))
print(partition_function)
# --> 1581.5360063360488947
```


## Compute structure free energy
`structure_energy` calculates the [structure free energy](definitions.md#structure-free-energy) for the specified secondary structure:

```python
dGstruc = structure_energy(complex=['AAAA', 'TTTT'], structure='((((+))))',
    model=Model(material='DNA', celsius = 25, ensemble='stacking'))
print(dGstruc)
# --> ????
```



## Compute equilibrium structure probability

`structure_probability` calculates the [equilibrium structure probability](definitions.md#equilibrium-structure-probability) of a specified secondary structure contained in the complex ensemble:

```python
probability = structure_probability(complex=['CCC', 'GGG'], structure='(((+)))')
print(probability)
# --> 0.5589045601083861
```

<hr>




## Compute Boltzmann-sampled structures

`sample` calculates a set of [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures) from the complex ensemble. The number of structures is specified using the keyword `num_sample`:

```python
sampled_structures = sample(complex=['CCC', 'GGG'], num_sample=3)
print(sampled_structures)
# --> [Structure('.((+)).'), Structure('(((+)))'), Structure('((.+)).')]
```

<hr>

## Compute equilibrium base-pairing probabilities

`pairs` calculates the matrix of [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities):

```python
probability_matrix = pairs(complex=['CCC', 'GGG'])
print(probability_matrix.round(3))
# -->
# [[0.17  0.    0.    0.002 0.222 0.607]
#  [0.    0.01  0.    0.223 0.739 0.028]
#  [0.    0.    0.288 0.683 0.029 0.   ]
#  [0.002 0.223 0.683 0.092 0.    0.   ]
#  [0.222 0.739 0.029 0.    0.01  0.   ]
#  [0.607 0.028 0.    0.    0.    0.365]]
```

<!--`numpy.ndarray`. -->


## Compute MFE proxy structure(s)

`mfe` calculates [MFE proxy structure](definitions.md#mfe-proxy-structure). The algorithm returns the MFE proxy secondary structure, the free energy of the MFE stacking state, and the free energy of the MFE proxy secondary structure:

```python
mfe_structures = mfe(complex=['CCC', 'GGG'])
print(mfe_structures)
# --> ['(((+)))', -4.181351661682129, ??]
```
If there is more than one MFE stacking state, the algorithm returns a list of the corresponding MFE proxy secondary structures, each with the (same) free energy of the MFE stacking state, and with the free energy of the MFE proxy secondary structure.

<hr> </hr>

## Compute suboptimal proxy structures

`subopt` calculates the set of [suboptimal proxy structures](definitions.md#suboptimal-proxy-structures) with a stacking state within a specified free energy gap of the MFE stacking state. The free energy gap is specified with keyword `gap` in kcal/mol. The algorithm returns a list of suboptimal proxy secondary strutures, each with the free energy of its lowest-energy stacking state that falls within the energy gap, and with the free energy of the MFE proxy secondary structure:

```python
subopt_structures = subopt(complex=['CCC', 'GGG'], gap=1.0)
print(subopt_structures)
# --> [
#   (Structure('(((+)))'), -4.181351661682129),
#   (Structure('((.+)).'), -3.3813514709472656)
# ]
```


<hr>



## Compute complex ensemble size
`ensemble_size` calculates the [complex ensemble size](definitions.md#complex-ensemble-size) in terms of either number of secondary structures or number of stacking states. Specify a [physical model](model.md#model-specification) with `nostacking` to obtain the number of secondary structures:

```python
num_struc = ensemble_size(complex=['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='nostacking'))
print(num_struc)
# --> 19
```

Specify a physical model with `stacking` to obtain the number of stacking states:

```python
num_stack = ensemble_size(complex=['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='stacking'))
print(num_stack)
# --> 19
```




<hr>
## Design a sequence
`structure_design` generates a sequence intended to adopt a target secondary structure at equilibrium. The complex is specified using IUPAC [degenerate nucleotide codes](design.md#specify-a-strand) to specify any sequence constraints. The target structure is specified using keyword `structure`.



```python
# design a sequence without sequence constraints
designed_sequence1 = structure_design(complex=['NNN','NNN'], structure='(((+)))')
print(designed_sequence1)
# --> ['CCC', 'GGG']

# design a sequence with sequence constraints
designed_sequence2 = structure_design(complex=['HHH','BBW'], structure='(((+)))')
print(designed_sequence2)
# --> ['CCC', 'GGG']
```

<hr>
## Compute complex ensemble defect
`structure_defect` evaluates the normalized complex ensemble defect with respect to a structure specified using keyword `structure`:

```python
ensemble_defect = structure_defect(complex=['CCC', 'GGG'], structure='(((+)))',
    model=Model(material='RNA', ensemble='stacking'))
print(ensemble_defect)
# --> 0.01
```
