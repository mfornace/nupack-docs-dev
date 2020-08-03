

# Utilities Jobs

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
Each of the following functions also takes an optional trailing parameter `model`, which should be an instance of `nupack.Model` if specified. (See [Physical Model](model.md) for help on creating a model object).



## Calculate the partition function 

`pfunc` returns the complex partition function of a single specified complex as a `decimal.Decimal`:

```python
partition_function = pfunc(['CCC', 'GGG'],  
    model=Model(material='RNA', ensemble='stacking'))
print(partition_function)
# --> 1581.5360063360488947
```



## Calculate base-pairing probabilities

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




## Calculate the MFE structure(s) 

`mfe` returns a list of MFE structures and their associated free energies. If the MFE is unique, the list will be length one:

```python
mfe_structures = mfe(['CCC', 'GGG'])
print(mfe_structures)
# --> [(Structure('(((+)))'), -4.181351661682129)]
```


<hr> </hr>

## Calculate an ensemble of suboptimal structures

`subopt` calculates all secondary structures within a specified free energy `gap` of the MFE. The free energy gap is specified in kcal/mol:

```python
subopt_structures = subopt(['CCC', 'GGG'], gap=1.0)
print(subopt_structures)
# --> [
#   (Structure('(((+)))'), -4.181351661682129),
#   (Structure('((.+)).'), -3.3813514709472656)
# ]
```



<hr> 

## Calculate the equilibrium probability of a structure

`prob` calculates the probability of a given secondary structure appearing in a single specified complex:

```python
probability = prob(['CCC', 'GGG'], structure='(((+)))')
print(probability)
# --> 0.5589045601083861
```



<hr>

## Boltzmann sample an ensemble of structures

`sample` calculates a specified `number` of random secondary structures drawn according to the equilibrium Boltzmann distribution:

```python
sampled_structures = sample(['CCC', 'GGG'], number=3)
print(sampled_structures)
# --> [Structure('.((+)).'), Structure('(((+)))'), Structure('((.+)).')]
```

<hr> 

## Count the states in the ensemble 
`count` calculates the number of secondary structures that can form for a specified complex:

```python
ensemble_size = count(['CCC', 'GGG'])
print(ensemble_size)
# --> 19
```

## Calculate a loop free energy

<!-- Typically a `Model` will be used as an input to dynamic programming algorithms (see [Analysis](analysis.md) and [Design](design.md)).
However, a `Model` also contains a few useful methods (below) to analyze individual secondary structures.

First, one can calculate the free energy of a single loop defined by an ordered list of bounding sequences. To specify an exterior loop, specify `nick` as the zero-based index of the strand that follows the strand break:
 -->
`loop_energy` calculates the loop free energy $\Delta G(\textrm{loop})$ for a specified loop and model. The loop is specified by:

1. A list of ordered sequences bounding the loop. Generally the last base of one sequence pairs to the first base of another sequence
2. A nick index (defaulting to -1). If the nick is -1, the loop is assumed to not contain a strand break. Otherwise, the nick is the zero-based index of the strand following the strand break.

```python
dGloop1 = loop_energy(['AA', 'TT'], model=Model(material='RNA', ensemble='stacking')) # stack energy
```

!!!example Examples
    - Calculate the free energy of an unstructured strand: 
    ```python
    dGloop2 = loop_energy(['AATT'], nick=0) 
    ```
    - Calculate the free energy of a hairpin loop: 
    ```python
    dGloop3 = loop_energy(['AATT']) 
    ```
    - Calculate the free energy of an exterior loop comprising a stacked base pair with a nick: 
    ```python
    dGloop4 = loop_energy(['AA', 'TT'], nick=1) 
    ```
     - Calculate the free energy of a multiloop: 
    ```python
    dGloop5 = loop_energy(['AAT', 'ACT', 'AGT']) 
    ```



## Calculate a structure free energy
`structure_energy` calculates the secondary structure free energy $\overline{\Delta G}(\phi,s)$ for the specified sequence, structure, and model: 

```python
dGstruc1 = structure_energy(['AAAA', 'TTTT'], structure='((((+))))',  
    model=Model(material='DNA', celcius = 25, ensemble='stacking'))
```

If the physical model includes [coaxial and dangle stacking](index.md#coaxial-and-dangle-stacking), the structure free energy will include stacking contributions $\Delta G^\textrm{stacking}$. If the secondary structure $s$ has a rotational symmetry, the structure free energy will include the [symmetry correction](index.md#symmetry-correction) $\Delta G^\textrm{sym}(\phi,s)$.






<hr>
## Design a sequence given a structure
`des` designs a sequence intended to adopt a specified target structure at equilibrium. 

```python
designed_sequence = des('(((+)))', model=Model())
print(designed_sequence)
# --> ['CCC', 'GGG']
```

<hr>
## Calculate the ensemble defect of a structure
`defect` evaluates a sequence intended to adopt a specified target structure at equilibrium. 

```python
ensemble_defect = defect('(((+)))', ['CCC', 'GGG'], model=Model())
print(ensemble_defect)
# --> 0.01
```