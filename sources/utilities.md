

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

To initialize a model for the following examples, run the following code:

```python
my_model = Model(material='RNA')
```

---

## Compute partition function

`pfunc` calculates the [partition function](definitions.md#partition-function) of the complex as well as the free energy of the complex:

```python
partition_function = pfunc(['CCC', 'GGG'], model=my_model)
print(partition_function)
# --> (Decimal('4525.512868'), -5.187871791642832)
```

---

## Compute structure free energy
`structure_energy` calculates the [structure free energy](definitions.md#structure-free-energy) for the specified secondary structure:

```python
dGstruc = structure_energy(['AAAA', 'TTTT'], structure='((((+))))', model=my_model)
print(dGstruc)
# --> -0.18135141907945873
```

---

## Compute equilibrium structure probability

`structure_probability` calculates the [equilibrium structure probability](definitions.md#equilibrium-structure-probability) of a specified secondary structure contained in the complex ensemble:

```python
probability = structure_probability(['CCC', 'GGG'], structure='(((+)))', model=my_model)
print(probability)
# --> 0.7152766753194949
```

---


## Compute Boltzmann-sampled structures

`sample` calculates a set of [Boltzmann-sampled structures](definitions.md#boltzmann-sampled-structures) from the complex ensemble. The number of structures is specified using the keyword `num_sample`:

```python
sampled_structures = sample(['CCC', 'GGG'], num_sample=3, model=my_model)
print(sampled_structures)
# --> [Structure('(((+)))'), Structure('(((+)))'), Structure('(((+)))')]
```

---

## Compute equilibrium base-pairing probabilities

`pairs` calculates the matrix of [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities):

```python
probability_matrix = pairs(['CCC', 'GGG'], model=my_model)
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
mfe_structures = mfe(['CCC', 'GGG'], model=my_model)
print(mfe_structures)
# --> [StructureEnergy(Structure('(((+)))'), energy=-4.981351375579834, stack_energy=-4.981351375579834)]
```
If there is more than one MFE stacking state, the algorithm returns a list of the corresponding MFE proxy secondary structures, each with the (same) free energy of the MFE stacking state, and with the free energy of the MFE proxy secondary structure.

---

## Compute suboptimal proxy structures

`subopt` calculates the set of [suboptimal proxy structures](definitions.md#suboptimal-proxy-structures) with a stacking state within a specified free energy gap of the MFE stacking state. The free energy gap is specified with keyword `gap` in kcal/mol. The algorithm returns a list of suboptimal proxy secondary strutures, each with the free energy of its lowest-energy stacking state that falls within the energy gap, and with the free energy of the MFE proxy secondary structure:

```python
subopt_structures = subopt(['CCC', 'GGG'], energy_gap=1.5, model=my_model)
print(subopt_structures)
# --> [StructureEnergy(Structure('(((+)))'), energy=-4.981351375579834, stack_energy=-4.981351375579834),
#      StructureEnergy(Structure('((.+)).'), energy=-4.000725746154785, stack_energy=-3.781351089477539)]
```

---

## Compute complex ensemble size
`ensemble_size` calculates the [complex ensemble size](definitions.md#complex-ensemble-size) in terms of either number of secondary structures or number of stacking states. Specify a [physical model](model.md#model-specification) with `nostacking` to obtain the number of secondary structures:

```python
num_struc = ensemble_size(['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='nostacking'))
print(num_struc)
# --> 18
```

Specify a physical model with `stacking` to obtain the number of stacking states:

```python
num_stack = ensemble_size(['CCC', 'GGG'],
    model=Model(material='RNA', ensemble='stacking'))
print(num_stack)
# --> 90
```

---

## Design a sequence
`des` performs complex design to generate a sequence intended to adopt a target secondary structure at equilibrium within the ensemble of the complex. The complex is specified using IUPAC [degenerate nucleotide codes](definitions.md#IUPAC-degenerate-nucleotide-codes) to incorporate any sequence constraints. The target structure is specified using keyword `structure`:


```python
# design a sequence without sequence constraints
designed_sequence1 = des(['NNN','NNN'], structure='(((+)))', model=my_model)
print(designed_sequence1)
# --> ['GGC', 'GCC']

# design a sequence with sequence constraints
designed_sequence2 = des(['HHH','BBW'], structure='(((+)))', model=my_model)
print(designed_sequence2)
# --> ['ACC', 'GGT']
```

---

## Compute complex ensemble defect
`defect` evaluates the normalized [complex ensemble defect](definitions.md#complex-ensemble-defect) with respect to the structure specified using keyword `structure`:

```python
ensemble_defect = defect(['CCC', 'GGG'], structure='(((+)))', model=my_model)
print(ensemble_defect)
# --> 0.20883411169052118
```
