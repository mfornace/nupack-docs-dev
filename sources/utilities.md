

# Utilities Jobs

Utilities commands analyze or design a single complex ensemble. For each command, the strand ordering of the complex is specified using keyword `strands` and the [physical model](model.md#model-specification) is specified using keyword `model`.
For commands that require a structure (e.g., calculation of the equilibrium structure probability using `prob`), the structure is specified using the keyword `structure`. By default, NUPACK utilities jobs run in [parallel](advanced.md#parallelism).

To initialize a model for the following examples, run the following code:

```python
my_model = Model(material='RNA')
```

---

## Compute partition function

`pfunc` calculates the [partition function](definitions.md#partition-function) of the complex as well as the free energy of the complex:

```python
partition_function = pfunc(strands=['CCC', 'GGG'], model=my_model)
print(partition_function)
# --> (Decimal('4525.512868'), -5.187871791642832)
```

---

## Compute structure free energy
`structure_energy` calculates the [structure free energy](definitions.md#structure-free-energy) for the specified secondary structure:

```python
dGstruc = structure_energy(strands=['AAAA', 'UUUU'], structure='((((+))))',
    model=my_model)
print(dGstruc)
# --> -0.18135141907945873
```

---

## Compute equilibrium structure probability

`structure_probability` calculates the [equilibrium structure probability](definitions.md#equilibrium-structure-probability) of a specified secondary structure contained in the complex ensemble:

```python
probability = structure_probability(strands=['CCC', 'GGG'], structure='(((+)))',
    model=my_model)
print(probability)
# --> 0.7152766753194949
```

---


## Compute Boltzmann-sampled structures

`sample` calculates a set of [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures) from the complex ensemble. The number of structures is specified using the keyword `num_sample`:

```python
sampled_structures = sample(strands=['CCC', 'GGG'], num_sample=3, model=my_model)
print(sampled_structures)
# --> [Structure('(((+)))'), Structure('(((+)))'), Structure('(((+)))')]
```

---

## Compute equilibrium base-pairing probabilities

`pairs` calculates the matrix of [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities):

```python
probability_matrix = pairs(strands=['CCC', 'GGG'], model=my_model)
print(probability_matrix)
# -->
# [[0.1002 0.0000 0.0000 0.0007 0.1474 0.7518]
#  [0.0000 0.0037 0.0000 0.1474 0.8307 0.0182]
#  [0.0000 0.0000 0.1904 0.7910 0.0185 0.0001]
#  [0.0007 0.1474 0.7910 0.0609 0.0000 0.0000]
#  [0.1474 0.8307 0.0185 0.0000 0.0035 0.0000]
#  [0.7518 0.0182 0.0001 0.0000 0.0000 0.2299]]
```

(Convert the result to a numpy array via `probability_matrix.to_array()`.)

## Compute MFE proxy structure(s)

`mfe` calculates [MFE proxy structure](definitions.md#mfe-proxy-structure). The algorithm returns the MFE proxy secondary structure, the free energy of the MFE stacking state, and the free energy of the MFE proxy secondary structure:

```python
mfe_structures = mfe(strands=['CCC', 'GGG'], model=my_model)
print('Free energy of MFE proxy structure: %.2f kcal/mol' % mfe_structures[0].energy)
print('MFE proxy structure in dot-parens-plus notation: %s' % mfe_structures[0].structure)
print('MFE proxy structure as structure matrix:\n%s' % mfe_structures[0].structure.matrix())
```

Output:

```
Free energy of MFE proxy structure: -4.98 kcal/mol
MFE proxy structure in dot-parens-plus notation: (((+)))
MFE proxy structure as structure matrix:
[[0 0 0 0 0 1]
 [0 0 0 0 1 0]
 [0 0 0 1 0 0]
 [0 0 1 0 0 0]
 [0 1 0 0 0 0]
 [1 0 0 0 0 0]]
```


If there is more than one MFE stacking state, the algorithm returns a list of the corresponding MFE proxy secondary structures, each with the free energy of the MFE proxy secondary structure and the (same) free energy of the MFE stacking state.

Use the keyword `indistinguishable_search` to specify that the structure search for mfe structure (s) is performed treating all strands as distinct (default `indistinguishable_search=False` ) or treating strands of the same species as indistinguishable (`indistinguishable_search=True`). Use the keyword `max_subopt_count` to specify that the structure search for mfe structure(s) will terminate upon generating this number of structures (default `max_subopt_count=100000`).

---

## Compute suboptimal proxy structures

`subopt` calculates the set of [suboptimal proxy structures](definitions.md#suboptimal-proxy-structures) with a stacking state within a specified free energy gap of the MFE stacking state. The (non-negative) free energy gap is specified with keyword `energy_gap` in kcal/mol. The algorithm returns a list of suboptimal proxy secondary strutures, each with the free energy of the suboptimal proxy secondary structure and with the free energy of its lowest-energy stacking state that falls within the energy gap:

```python
subopt_structures = subopt(strands=['CCC', 'GGG'], energy_gap=1.5, model=my_model)
print(subopt_structures)
# --> [StructureEnergy(Structure('(((+)))'), energy=-4.981351375579834, stack_energy=-4.981351375579834),
#      StructureEnergy(Structure('((.+)).'), energy=-4.000725746154785, stack_energy=-3.781351089477539)]
```

Use the keyword `indistinguishable_search` to specify that the structure search for mfe structure (s) is performed treating all strands as distinct (default `indistinguishable_search=False` ) or treating strands of the same species as indistinguishable (`indistinguishable_search=True`). Use the keyword `max_subopt_count` to specify that the structure search for mfe structure(s) will terminate upon generating this number of structures (default `max_subopt_count=100000`).

---

## Compute complex ensemble size
`ensemble_size` calculates the [complex ensemble size](definitions.md#complex-ensemble-size) in terms of either number of secondary structures or number of stacking states. Specify a [physical model](model.md#model-specification) with `nostacking` to obtain the number of secondary structures:

```python
num_struc = ensemble_size(strands=['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='nostacking'))
print(num_struc)
# --> 18
```

Specify a physical model with `stacking` to obtain the number of stacking states:

```python
num_stack = ensemble_size(strands=['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='stacking'))
print(num_stack)
# --> 90
```

---

## Design a sequence
`des` performs complex design to generate a sequence intended to adopt a target secondary structure at equilibrium within the ensemble of the complex. The strand ordering of the complex can be specified using IUPAC [degenerate nucleotide codes](definitions.md#degenerate-nucleotide-codes) to incorporate any sequence constraints (the strand ordering can be omitted if there are no sequence constraints). The target structure is specified using keyword `structure`:


```python
# design a sequence without sequence constraints
designed_sequence1 = des(structure='(((+)))', model=my_model)
print(designed_sequence1)
# --> ['GGC', 'GCC']

# alternative specification to design a sequence without sequence constraints
designed_sequence1 = des(strands=['NNN','NNN'], structure='(((+)))', model=my_model)
print(designed_sequence1)
# --> ['GGC', 'GCC']

# design a sequence with sequence constraints
designed_sequence2 = des(strands=['HHH','BBW'], structure='(((+)))', model=my_model)
print(designed_sequence2)
# --> ['ACC', 'GGU']
```

---

## Compute complex ensemble defect
`defect` evaluates the normalized [complex ensemble defect](definitions.md#complex-ensemble-defect) with respect to the structure specified using keyword `structure`:

```python
ensemble_defect = defect(strands=['CCC', 'GGG'], structure='(((+)))', model=my_model)
print(ensemble_defect)
# --> 0.20883411169052118
```

---

## Represent a structure

A [secondary structure](definitions.md#secondary-structure) can be defined using any of three notations (keyword `Structure`):

```python
s1 = Structure('((((((((((((+..........))))))))))))') # dot-parens-plus notation
s2 = Structure('(12+.10)12') # run-length-encoded dot-parens-plus notation
s3 = Structure('D12 (+ U10)') # DU+ notation
```

Any object or command that accepts a structure as an argument (e.g, `TargetComplex` in Design or `structure_probability` in Utilities) will accept either a structure defined in one of the above three notations, or a previously defined `Structure` object:

```python
dGstruc = structure_energy(strands=['AAAA', 'TTTT'], structure='((((+))))',
    model=my_model)

my_struc = Structure('((((+))))')
dGstruc = structure_energy(strands=['AAAA', 'TTTT'], structure=my_struc,
    model=my_model)
```

`Structure` supports the following methods to assist with structure representation:

- `pairlist()`: A pair list contains a list $S$ of zero-based indices such that $S_i = j$ if bases $i$ and $j$ are paired, and $S_i = i$ if base $i$ is unpaired.
- `matrix()`: A [structure matrix](definitions.md#secondary-structure) of the structure.
- `nicks()`: A list of zero-based indices of each base 3$'$ of a nick between strands (one entry per strand)
- `dotparensplus()`: Representation of the structure in dot-parens-plus notation.
- `rle_dotparensplus()`: Representation of the structure in run-length-encoded dot-parens-plus notation.

For example:

```python
s4 = Structure('(((+))).')

print(s4.pairlist())          # --> [5 4 3 2 1 0 6]

print(s4.matrix())            # --> [[0 0 0 0 0 1 0]
                              #      [0 0 0 0 1 0 0]
                              #      [0 0 0 1 0 0 0]
                              #      [0 0 1 0 0 0 0]
                              #      [0 1 0 0 0 0 0]
                              #      [1 0 0 0 0 0 0]
                              #      [0 0 0 0 0 0 1]]
print(s4.nicks())             # --> [3 7]
print(s4.dotparensplus())     # --> (((+))).
print(s4.rle_dotparensplus()) # --> (3+)3.
```

## Compute sequence distance
`seq_distance` calculates the [sequence distance](definitions.md#secondary-structure) for two sequences that have the same number of nucleotides:

```python
my_model.alphabet.seq_distance('ACGUUUU+ACCC','ACGUUUU+AGGG') # --> 3
my_model.alphabet.seq_distance('G5', 'G3C2') # --> 2
```

An `Alphabet` object (most often associated with a `Model`) must be specified to avoid ambiguities with material specifier characters.


## Compute structure distance
`struc_distance` calculates the [structure distance](definitions.md#secondary-structure) for two structures that have the same number of nucleotides:

```python
struc_distance('((((((((+..........))))))))', '(((((((.+...........)))))))') # --> 2

struc_distance('.15', '(5.5)5') # --> 10
```

!!! Note
    Note that [sequence distance](definitions.md#sequence) and [structure distance](definitions.md#secondary-structure) are defined independent of whether the nick locations match between two sequences or two structures. However, `seq_distance` and `struc_distance` will return a warning if the nick locations do not match.
