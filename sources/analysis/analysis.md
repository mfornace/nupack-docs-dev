```python
%matplotlib inline
from matplotlib import pyplot as plt
import numpy as np
import nupack
```


```python
mod = nupack.Model(T=310, ensemble=nupack.Ensemble.stacking, parameters='RNA')
```

## Schedule the calculations to perform


```python
strands = ('CAGTCGATC', 'ATCGACGTA')

# Create an Analysis object for calculating complex ensemble quantities
analysis = nupack.Analysis(mod)

# Schedule calculation of partition functions for all complexes composed from the given strands, up to size 3
analysis.partition_function(strands, max_size=3)

# Schedule calculation of pair probabilities for all complexes up to size 2
analysis.pair_probability(strands, max_size=2)

# Schedule calculation of pair probabilities for all complexes up to size 2
analysis.min_free_energy(strands, max_size=2)

# Schedule calculation of 10 random Boltzmann samples from the given complex
analysis.boltzmann_sample(strands, number=10)

# Schedule calculation of all suboptimal structures within 0.4 kcal/mol of the MFE for the given complex
analysis.suboptimal_structure(strands, gap=0.4)
```




    <nupack.analysis.Analysis at 0x135b68450>




```python
results = analysis.compute()
```


```python
print('\nThe complex free energy is %.4f kcal/mol' % results[strands].free_energy)

print('\nThe complex MFE is %.4f kcal/mol' % results[strands].min_free_energy)

print('\nAll complex partition functions up to size 3')
for seqs, result in results.items():
    print('    %8.4e is the partition function of %s' % (np.exp(result.log_partition_function), '+'.join(seqs)))

print('\nThe single strand free energies:')
for seq in strands:
    print('    %s: %.4f kcal/mol' % (seq, results[(seq,)].free_energy))

print('\nSome Boltzmann samples, done simultaneously:')
for i, s in enumerate(results[strands].sampled_structures):
    print('   ', i, s.dp())
    
print('\nSubopt structures, done simultaneously:')
for i, (s, e) in enumerate(results[strands].suboptimal_structures):
    print('    %d %s %7.3f' % (i, s.dp(), e))
    
print('\nThe complex pair probability matrix:')
plt.matshow(results[strands].pair_probability)
plt.colorbar(fraction=0.046, pad=0.04);
```

    
    The complex free energy is -11.2137 kcal/mol
    
    The complex MFE is -10.0045 kcal/mol
    
    All complex partition functions up to size 3
        1.2547e+10 is the partition function of ATCGACGTA+ATCGACGTA+CAGTCGATC
        2.7050e+05 is the partition function of ATCGACGTA+ATCGACGTA
        3.9439e+06 is the partition function of CAGTCGATC+CAGTCGATC
        8.0474e+07 is the partition function of ATCGACGTA+CAGTCGATC
        2.5624e+08 is the partition function of CAGTCGATC+CAGTCGATC+CAGTCGATC
        1.0911e+00 is the partition function of ATCGACGTA
        5.4143e+09 is the partition function of ATCGACGTA+CAGTCGATC+CAGTCGATC
        1.1315e+00 is the partition function of CAGTCGATC
        2.0810e+09 is the partition function of ATCGACGTA+ATCGACGTA+ATCGACGTA
    
    The single strand free energies:
        CAGTCGATC: -0.0761 kcal/mol
        ATCGACGTA: -0.0537 kcal/mol
    
    Some Boltzmann samples, done simultaneously:
        0 .(((((...+..)))))..
        1 ((((((...+..)))))).
        2 ((((((...+..)))))).
        3 ((((((...+..)))))).
        4 ((((((...+..)))))).
        5 .(((((...+..)))))..
        6 .(((((...+..)))))..
        7 ((((((...+..)))))).
        8 ((((((...+..)))))).
        9 .(((((...+..)))))..
    
    Subopt structures, done simultaneously:
        0 ((((((...+..)))))). -10.005
        1 ((((((...+..)))))).  -9.904
        2 .(((((...+..)))))..  -9.903
        3 ((((((...+..)))))).  -9.804
        4 ((((((...+..)))))).  -9.704
        5 .(((((...+..)))))..  -9.702
    
    The complex pair probability matrix:



![png](output_5_1.png)



```python
solver = nupack.ConcentrationSolver(strands, results)

concentration_result = solver.compute([1e-6, 1e-7]).complex_concentrations()

for seqs, c in concentration_result.items():
    print('%.3e is the concentration of %s' % (c, '+'.join(seqs)))
```

    6.470e-15 is the concentration of ATCGACGTA+ATCGACGTA+CAGTCGATC
    4.820e-12 is the concentration of ATCGACGTA+ATCGACGTA
    2.277e-08 is the concentration of CAGTCGATC+CAGTCGATC
    5.162e-08 is the concentration of ATCGACGTA+CAGTCGATC
    1.427e-14 is the concentration of CAGTCGATC+CAGTCGATC+CAGTCGATC
    4.837e-08 is the concentration of ATCGACGTA
    5.026e-14 is the concentration of ATCGACGTA+CAGTCGATC+CAGTCGATC
    9.028e-07 is the concentration of CAGTCGATC
    1.987e-17 is the concentration of ATCGACGTA+ATCGACGTA+ATCGACGTA



```python

```
