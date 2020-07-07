

# Utilities

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



## Calculate the partition function 

`pfunc` returns the complex partition function of a single specified complex as a `decimal.Decimal`:

```python
partition_function = pfunc(['CCC', 'GGG'],  
    model=Model(parameters='RNA', ensemble='stacking'))
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

<hr>
## Design a sequence given a structure
`des` designs a sequence intended to adopt a specified target structure at equilibrium. 

```python
designed_sequence = des(['(((+)))'])
print(designed_sequence)
# --> ['CCC', 'GGG']
```

<hr>
## Calculate the ensemble defect of a structure
`defect` designs a sequence intended to adopt a specified target structure at equilibrium. 

```python
designed_sequence = des(['(((+)))'])
print(designed_sequence)
# --> ['CCC', 'GGG']
```