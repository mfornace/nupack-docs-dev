

```python
import nupack
import math
import matplotlib.pyplot as plt
```

# Secondary structure model specification

Specify a free energy model including:
- `parameters`: the parameter set description to use. If 'RNA' or 'DNA' are specified, the default parameter sets for those materials will be used. A full parameter file may be specified, for example, by `parameters=nupack.ParameterFile(material='RNA', dG='rna1995.dG', dH='rna1995.dH')`
- `T`: the temperature, in Kelvin (default=`310.15`)
- `mg`: the magnesium ion concentration $`\textrm{Mg}^{2+}`$, in moles per liter (default=`0.0`)
- `na`: the sodium ion concentration $\textrm{Na}^{+}$, in moles per liter (default=`1.0`)
- `gt`: whether wobble pairs (G$\cdot$U or G$\cdot$T) are allowed (default=`True`)
- `dangles`: the recursions to use, from `['none', 'min', 'all', 'coax']` (default=`'min'`). Using `'none'`, no dangle or stacking energies will be incorporated. Using `'min'`, a dangle energy is incorporated for each unpaired base flanking a duplex (a base flanking two duplexes contributes only the minimum of the two possible dangle energies). Using `'all'`, a dangle energy is incorporated for each base flanking a duplex regardless of whether it is paired. Using `'coax'`, every possible coaxial stacking and dangle state is incorporated into the recursions.


```python
model = nupack.Model(parameters='DNA', T=(23+273.15), mg=0, na=0.1, gt=True, dangles='min')
```

# Example 2: Partition function for a complex.
Calculate the partition function for a complex of four DNA strands at 23 ◦C, two of which are indistinguishable.

## Input file contents:

```
3
AGTCTAGGATTCGGCGTGGGTTAA 
TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
1223
```

## Command: 

```bash
pfunc -T 23 -multi -material dna $NUPACKHOME/doc/examples/complex-analysis/advanced/input/hcr
```


```python
analysis = nupack.Analysis(model=model)

strands = (
    'AGTCTAGGATTCGGCGTGGGTTAA',
    'TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG',
    'TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG',
    'AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG'
)

analysis.partition_function(strands)
complex_result = analysis.compute()[strands]

print('Free energy = %.2f kcal/mol' % complex_result.free_energy)
print('Partition function = %.3e' % math.exp(complex_result.log_partition_function))
```

    Free energy = -104.47 kcal/mol
    Partition function = 1.254e+77


# Example 3: Test tube analysis. 

Calculate the partition function, equilibrium pair probabilities, MFE structure(s), and equilibrium concentration for each complex in a test tube containing three DNA strand species that interact to form all complex species of up to four strands, plus additional larger complexes specified in a .list file.

## Input file contents:

```
3
AGTCTAGGATTCGGCGTGGGTTAA
TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
4
```

## List file contents:

```
1 2 2 3 3
1 2 3 2 3
2 3 2 3 2
1 2 2 2 3 3
```

## Strand concentrations file contents:

```
1e-6
1.1e-6
0.9e-6
```

## Commands: 

```bash
complexes -T 23 -material dna -pairs -mfe -degenerate $NUPACKHOME/doc/examples/tube-analysis/advanced/input/hcr
concentrations -pairs $NUPACKHOME/doc/examples/tube-analysis/advanced/input/hcr
```


```python
analysis = nupack.Analysis(model=model)

strands = (
    "AGTCTAGGATTCGGCGTGGGTTAA",
    "TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG",
    "AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG",
)

analysis.pair_probability(strands, max_size=4)
analysis.min_free_energy(strands, max_size=4)

larger_complex_specs = [
    [1, 2, 2, 3, 3],
    [1, 2, 3, 2, 3],
    [2, 3, 2, 3, 2],
    [1, 2, 2, 2, 3, 3],
]

additional_complexes = [[strands[i-1] for i in x] for x in larger_complex_specs]

for cx in additional_complexes:
    analysis.pair_probability(cx)
    analysis.min_free_energy(cx)

complex_results = analysis.compute()

tube_solver = nupack.ConcentrationSolver(strands, complex_results)

strand_concentrations = [1e-6, 1.1e-6, 0.9e-6]

complex_concentrations = tube_solver.compute(strand_concentrations).complex_concentrations()

# tube = Tube(strands=strands, max_size=4, additional_complexes=additional_complexes)
# shows the sequences of the complexes in the tube
for cx, result in complex_concentrations.items():
    complex_result = complex_results[cx]
    print('Complex =', '+'.join(cx))
    print('    Strand indices =', [strands.index(strand) for strand in cx])
    print('    Concentration = %.3e M' % result)
    print('    Complex free energy = %.3f kcal/mol' % complex_result.free_energy)
    print('    MFE = %.3f kcal/mol' % complex_result.min_free_energy)
    print('    MFE structure = %s' % complex_result.suboptimal_structure[0][0])
    plt.matshow(complex_result.pair_probability, cmap='viridis')
    plt.colorbar()
    plt.grid(False)
    plt.show()    
```

    Complex = TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [1, 1]
        Concentration = 3.603e-14 M
        Complex free energy = -49.674 kcal/mol
        MFE = -49.081 kcal/mol
        MFE structure = ......((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))



![png](output_6_1.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 2, 2, 1]
        Concentration = 5.108e-24 M
        Complex free energy = -105.043 kcal/mol
        MFE = -101.172 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......((((((((((((((((((......+))))))))))))))))))......)))))))))))))))))).....(+....).((((((((((((((((((......))))))))))))))))))



![png](output_6_3.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 2, 1]
        Concentration = 2.511e-14 M
        Complex free energy = -60.573 kcal/mol
        MFE = -58.255 kcal/mol
        MFE structure = .(((((((((((((((((((((((+((((((((((((((((((......))))))))))))))))))...)).+..))))))))))))))))))))).........................



![png](output_6_5.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA
        Strand indices = [0, 0]
        Concentration = 1.463e-09 M
        Complex free energy = -9.595 kcal/mol
        MFE = -9.400 kcal/mol
        MFE structure = ...........((.((........+...........)).))........



![png](output_6_7.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [2, 2, 2]
        Concentration = 1.585e-18 M
        Complex free energy = -78.209 kcal/mol
        MFE = -75.219 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_9.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 0, 2, 2]
        Concentration = 1.397e-17 M
        Complex free energy = -67.682 kcal/mol
        MFE = -66.244 kcal/mol
        MFE structure = ((((((((((((((((((......+...........((.((........+...........)).))........((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_11.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [2]
        Concentration = 3.872e-07 M
        Complex free energy = -23.630 kcal/mol
        MFE = -23.255 kcal/mol
        MFE structure = ((((((((((((((((((......))))))))))))))))))......



![png](output_6_13.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 2, 1, 1]
        Concentration = 3.421e-19 M
        Complex free energy = -88.902 kcal/mol
        MFE = -85.853 kcal/mol
        MFE structure = .(((((((((((((((((((((((+((((((((((((((((((......))))))))))))))))))...)).+..))))))))))))))))))))).......((((((((((((((((((+......))))))))))))))))))........................



![png](output_6_15.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 2, 1, 1]
        Concentration = 1.063e-23 M
        Complex free energy = -105.715 kcal/mol
        MFE = -103.323 kcal/mol
        MFE structure = ........................((((((((((((((((((((((((+.(((((((((((((((((((((..((((((((((((((((((((((((+........................))))))))))))))))))))))))+..))))))))))))))))))))).))))))))))))))))))))))))



![png](output_6_17.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 1]
        Concentration = 2.862e-07 M
        Complex free energy = -35.454 kcal/mol
        MFE = -34.048 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).........................



![png](output_6_19.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 0, 1]
        Concentration = 8.580e-09 M
        Complex free energy = -45.151 kcal/mol
        MFE = -43.855 kcal/mol
        MFE structure = ...........((.((........+.(((((((((((((((((((((((+)))))))))))))))))))))))..................)).))..



![png](output_6_21.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 1]
        Concentration = 1.684e-13 M
        Complex free energy = -49.933 kcal/mol
        MFE = -48.562 kcal/mol
        MFE structure = ((((((((((((((((((......)))))))))))))))))).....(+....).((((((((((((((((((......))))))))))))))))))



![png](output_6_23.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 1, 1]
        Concentration = 1.385e-19 M
        Complex free energy = -76.610 kcal/mol
        MFE = -74.980 kcal/mol
        MFE structure = ((((((((((((((((((......)))))))))))))))))).....(+....).((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))



![png](output_6_25.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 1, 1, 1]
        Concentration = 1.003e-25 M
        Complex free energy = -103.212 kcal/mol
        MFE = -100.049 kcal/mol
        MFE structure = ((((((((((((((((((......)))))))))))))))))).....(+..((..((((((((((((((((((......))))))))))))))))))+))..).((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))



![png](output_6_27.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA
        Strand indices = [0, 0, 0]
        Concentration = 2.654e-13 M
        Complex free energy = -16.524 kcal/mol
        MFE = -15.329 kcal/mol
        MFE structure = ...((((....((.((........+...........)).))........+...)))).................



![png](output_6_29.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 2, 2, 1]
        Concentration = 1.913e-19 M
        Complex free energy = -88.319 kcal/mol
        MFE = -84.856 kcal/mol
        MFE structure = .(((((((((((((((((((((((+((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))...)).+..))))))))))))))))))))).........................



![png](output_6_31.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 2, 0, 2]
        Concentration = 5.025e-18 M
        Complex free energy = -67.488 kcal/mol
        MFE = -65.836 kcal/mol
        MFE structure = ((((((((((((((((((......+...........((.((........((((((((((((((((((......+))))))))))))))))))......+...........)).))........))))))))))))))))))......



![png](output_6_33.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 1, 2, 1]
        Concentration = 1.581e-25 M
        Complex free energy = -103.647 kcal/mol
        MFE = -100.063 kcal/mol
        MFE structure = ((((((((((((((((((......)))))))))))))))))).....(+....).((((((((((((((((((......((((((((((((((((((+((((((((((((((((((......)))))))))))))))))).....(+....).))))))))))))))))))......))))))))))))))))))



![png](output_6_35.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA
        Strand indices = [0]
        Concentration = 2.788e-07 M
        Complex free energy = -0.516 kcal/mol
        MFE = 0.000 kcal/mol
        MFE structure = ........................



![png](output_6_37.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 0, 0, 2]
        Concentration = 1.262e-16 M
        Complex free energy = -46.056 kcal/mol
        MFE = -44.193 kcal/mol
        MFE structure = ((((((((((((((((((......+...((((.................+...))))....((.((........+...........)).))........))))))))))))))))))......



![png](output_6_39.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 1, 2]
        Concentration = 1.060e-07 M
        Complex free energy = -104.474 kcal/mol
        MFE = -102.262 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+..(((((((((((((((((((((.........................+.)))))))))))))))))))))..))))))))))))))))))))))))



![png](output_6_41.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [2, 2, 2, 2]
        Concentration = 6.705e-24 M
        Complex free energy = -105.778 kcal/mol
        MFE = -101.931 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......((((((((((((((((((......+))))))))))))))))))......((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_43.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 0, 2, 1]
        Concentration = 7.536e-16 M
        Complex free energy = -70.270 kcal/mol
        MFE = -68.063 kcal/mol
        MFE structure = ...........((.((........+.(((((((((((((((((((((((+((((((((((((((((((......))))))))))))))))))...)).+..)))))))))))))))))))))..................)).))..



![png](output_6_45.png)


    Complex = TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [1]
        Concentration = 1.408e-07 M
        Complex free energy = -23.276 kcal/mol
        MFE = -23.071 kcal/mol
        MFE structure = ......((((((((((((((((((......))))))))))))))))))



![png](output_6_47.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA
        Strand indices = [0, 0, 0, 0]
        Concentration = 2.610e-15 M
        Complex free energy = -25.734 kcal/mol
        MFE = -24.967 kcal/mol
        MFE structure = ...((((....((.((........+...........)).))........+...))))....((.((........+...........)).))........



![png](output_6_49.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 0, 1, 2]
        Concentration = 5.183e-13 M
        Complex free energy = -74.115 kcal/mol
        MFE = -72.073 kcal/mol
        MFE structure = ((((((((((((((((((......+.(((((((((((((((((((((((+)))))))))))))))))))))))..................((.((..+...........)).))........))))))))))))))))))......



![png](output_6_51.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 0, 2]
        Concentration = 3.962e-09 M
        Complex free energy = -79.377 kcal/mol
        MFE = -78.232 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+...........((.((........+...........)).))........))))))))))))))))))))))))



![png](output_6_53.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 2]
        Concentration = 1.863e-07 M
        Complex free energy = -69.883 kcal/mol
        MFE = -68.424 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+........................))))))))))))))))))))))))



![png](output_6_55.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [2, 2]
        Concentration = 7.892e-13 M
        Complex free energy = -51.008 kcal/mol
        MFE = -49.449 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_57.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 2, 2]
        Concentration = 1.370e-11 M
        Complex free energy = -98.963 kcal/mol
        MFE = -96.642 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+........................((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))))))))



![png](output_6_59.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 0, 0, 1]
        Concentration = 2.469e-12 M
        Complex free energy = -52.113 kcal/mol
        MFE = -50.023 kcal/mol
        MFE structure = ...((((.................+...))))....((.((........+.(((((((((((((((((((((((+)))))))))))))))))))))))..................)).))..



![png](output_6_61.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 1, 1, 1]
        Concentration = 3.387e-17 M
        Complex free energy = -91.848 kcal/mol
        MFE = -89.244 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).......((((((((((((((((((+......))))))))))))))))))......((((((((((((((((((+......))))))))))))))))))........................



![png](output_6_63.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 2, 2, 2]
        Concentration = 2.543e-20 M
        Complex free energy = -86.891 kcal/mol
        MFE = -84.654 kcal/mol
        MFE structure = ((((((((((((((((((......+........................((((((((((((((((((......+))))))))))))))))))......((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_65.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 0, 1, 1]
        Concentration = 1.437e-13 M
        Complex free energy = -73.601 kcal/mol
        MFE = -71.453 kcal/mol
        MFE structure = ...........((.((........+.(((((((((((((((((((((((+))))))))))))))))))))))).......((((((((((((((((((+......)))))))))))))))))).................)).))..



![png](output_6_67.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 1, 0, 1]
        Concentration = 3.180e-09 M
        Complex free energy = -79.897 kcal/mol
        MFE = -77.495 kcal/mol
        MFE structure = .(((((((((((((((((((((((+)))))))))))))))))))))))..................((.((..+.(((((((((((((((((((((((+)))))))))))))))))))))))..................)).))..



![png](output_6_69.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 2]
        Concentration = 1.563e-11 M
        Complex free energy = -29.437 kcal/mol
        MFE = -28.218 kcal/mol
        MFE structure = ((((((((((((((((((......+........................))))))))))))))))))......



![png](output_6_71.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 2, 2]
        Concentration = 6.612e-16 M
        Complex free energy = -58.192 kcal/mol
        MFE = -56.436 kcal/mol
        MFE structure = ((((((((((((((((((......+........................((((((((((((((((((......+))))))))))))))))))......))))))))))))))))))......



![png](output_6_73.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 2, 1, 2]
        Concentration = 1.634e-14 M
        Complex free energy = -95.002 kcal/mol
        MFE = -92.632 kcal/mol
        MFE structure = .(((((((((((((((((((((((+((((((((((((((((((......))))))))))))))))))...)).+..))))))))))))))))))))).((((((((((((((((((((((((+........................))))))))))))))))))))))))



![png](output_6_75.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 2, 1]
        Concentration = 1.299e-18 M
        Complex free energy = -77.686 kcal/mol
        MFE = -75.164 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((......+))))))))))))))))))......)))))))))))))))))).....(+....).((((((((((((((((((......))))))))))))))))))



![png](output_6_77.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAA+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 0, 2]
        Concentration = 3.380e-13 M
        Complex free energy = -38.941 kcal/mol
        MFE = -38.026 kcal/mol
        MFE structure = ((((((((((((((((((......+...........((.((........+...........)).))........))))))))))))))))))......



![png](output_6_79.png)


    Complex = TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [1, 1, 1]
        Concentration = 1.298e-20 M
        Complex free energy = -76.104 kcal/mol
        MFE = -73.911 kcal/mol
        MFE structure = ..((..((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))+))....((((((((((((((((((......))))))))))))))))))



![png](output_6_81.png)


    Complex = TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [1, 1, 1, 1]
        Concentration = 6.061e-27 M
        Complex free energy = -102.618 kcal/mol
        MFE = -100.159 kcal/mol
        MFE structure = ..((..((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))+))....((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))



![png](output_6_83.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 1, 2, 1]
        Concentration = 3.672e-15 M
        Complex free energy = -94.364 kcal/mol
        MFE = -91.825 kcal/mol
        MFE structure = .(((((((((((((((((((((((+)))))))))))))))))))))))(((((((((((((((((((((((((+........................))))))))))))))))))))))))+..)...((((((((((((((((((......))))))))))))))))))



![png](output_6_85.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [0, 1, 1]
        Concentration = 3.856e-12 M
        Complex free energy = -63.777 kcal/mol
        MFE = -61.646 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).......((((((((((((((((((+......))))))))))))))))))........................



![png](output_6_87.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 1, 2, 2]
        Concentration = 6.900e-08 M
        Complex free energy = -138.903 kcal/mol
        MFE = -136.639 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+..(((((((((((((((((((((.((((((((((((((((((((((((+........................))))))))))))))))))))))))+.)))))))))))))))))))))..))))))))))))))))))))))))



![png](output_6_89.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 2, 1, 2]
        Concentration = 7.824e-15 M
        Complex free energy = -129.491 kcal/mol
        MFE = -125.618 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+((((((((((((((((((......))))))))))))))))))....(.+..(((((((((((((((((((((.........................+.)))))))))))))))))))))).))))))))))))))))))))))))



![png](output_6_91.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG
        Strand indices = [2, 1, 2, 1, 1]
        Concentration = 6.700e-31 M
        Complex free energy = -130.881 kcal/mol
        MFE = -126.888 kcal/mol
        MFE structure = ((((((((((((((((((......((((((((((((((((((.....(+....).((((((((((((((((((......))))))))))))))))))+))))))))))))))))))......)))))))))))))))))).....(+....).((((((((((((((((((......((((((((((((((((((+......))))))))))))))))))......))))))))))))))))))



![png](output_6_93.png)


    Complex = AGTCTAGGATTCGGCGTGGGTTAA+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG+AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG
        Strand indices = [0, 1, 1, 1, 2, 2]
        Concentration = 3.926e-08 M
        Complex free energy = -173.493 kcal/mol
        MFE = -170.477 kcal/mol
        MFE structure = .(((((((((((((((((((((((+))))))))))))))))))))))).((((((((((((((((((((((((+..(((((((((((((((((((((.((((((((((((((((((((((((+..(((((((((((((((((((((.........................+.)))))))))))))))))))))..))))))))))))))))))))))))+.)))))))))))))))))))))..))))))))))))))))))))))))



![png](output_6_95.png)


# Example 4: 

Design a sequence for a complex of three DNA strands intended to adopt a target secondary structure at 23 ◦C. The first 24 nucleotides are constrained to nucleotide H (corresponding to a 3-letter alphabet) and the specified list of patterns are prevented throughout. A seed is set to make the design repeatable.

# Input file contents:

```
((((((((((((((((((((((((+((((((((((((((((((((((((.......................
.+))))))))))))))))))))))))))))))))))))))))))))))))
HHHHHHHHHHHHHHHHHHHHHHHH
```

# Prevent file contents:

```
AAAA
CCCC
GGGG
UUUU
KKKKKK
MMMMMM
RRRRRR
SSSSSS
WWWWWW
YYYYYY
```

# Seed file contents:

```
93
```

# Command: 

```bash
complexdesign -T 23 -material dna -pairs -loadseed -prevent $NUPACKHOME/doc/examples/complex-design/advanced/input/hcr-design.prevent $NUPACKHOME/doc/examples/complex-design/advanced/input/hcr-design
```


```python
structure = "((((((((((((((((((((((((+((((((((((((((((((((((((........................+))))))))))))))))))))))))))))))))))))))))))))))))"
design = nupack.design.complex_design(structure)

design.model = nupack.design.ModelSettings(material="DNA", temperature=(23+273.15))
design.parameters.seed = 93

design.domains[0].allowed_bases = "HHHHHHHHHHHHHHHHHHHHHHHH"

patterns = ["AAAA", "CCCC", "GGGG", "UUUU", "KKKKKK", "MMMMMM", "RRRRRR", "SSSSSS", "WWWWWW", "YYYYYY"]
design.add_pattern_constraints(patterns)

print(design)
print("\n")
print(design())
```

    Specification
        domains: [DomainSpec {name: domain 0, allowed_bases: HHHHHHHHHHHHHHHHHHHHHHHH}, DomainSpec {name: domain 0*, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: domain 1, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: domain 1*, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: domain 2, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: domain 2*, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}]
        strands: [StrandSpec {name: strand 0, domain_names: [domain 0]}, StrandSpec {name: strand 1, domain_names: [domain 1]}, StrandSpec {name: strand 2, domain_names: [domain 2]}]
        complexes: [ComplexSpec
                name: complex
                strands: [strand 0, strand 1, strand 2]
                structure: Structure("(24+(24.24+)48")]
        tubes: [TubeSpec {name: tube, targets: [([complex] : 1)]}]
        model: ModelKey {parameters: ParameterFile {material: DNA, dG: dna1998.dG, dH: dna1998.dH}, dangle_type: none, conditions: ModelConditions {temperature: 296.15, na_molarity: 1, mg_molarity: 0}}
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: [1]}
        constraints: ConstraintSpec {complementarity: [], match: [], pattern: [PatternSpec {name: , pattern: AAAA}, PatternSpec {name: , pattern: CCCC}, PatternSpec {name: , pattern: GGGG}, PatternSpec {name: , pattern: UUUU}, PatternSpec {name: , pattern: KKKKKK}, PatternSpec {name: , pattern: MMMMMM}, PatternSpec {name: , pattern: RRRRRR}, PatternSpec {name: , pattern: SSSSSS}, PatternSpec {name: , pattern: WWWWWW}, PatternSpec {name: , pattern: YYYYYY}], word: [], similarity: []}
        objectives: [Objective {variant: MultitubeObjective()}]
        parameters: DesignParameters {rng_seed: 93, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        sources: {}
        libraries: {}
    
    
    DesignResult
        model: ModelKey {parameters: ParameterFile {material: DNA, dG: dna1998.dG, dH: dna1998.dH}, dangle_type: none, conditions: ModelConditions {temperature: 296.15, na_molarity: 1, mg_molarity: 0}}
        parameters: DesignParameters {rng_seed: 93, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        stats: DesignStats {num_leaf_evaluations: 16, num_reseeds: 0, num_redecompositions: [], offtargets_added_per_refocus: [], design_time: 0.158909, analysis_time: 0.0135931, final_Psi: EnsemblePartition {mask: [1], deflate: 0.0002}}
        objectives: [Objective {variant: MultitubeObjective()}]
        results: [SingleResult
                domains: {(domain 0 : TTTCAACATACATTTCCATAACTC), (domain 0* : GAGTTATGGAAATGTATGTTGAAA), (domain 1 : CACAGGTAAGGCAGCTAGAGGTGCTTAAAGATCAGCACGAGGACATAG), (domain 1* : CTATGTCCTCGTGCTGATCTTTAAGCACCTCTAGCTGCCTTACCTGTG), (domain 2 : GCACCTCTAGCTGCCTTACCTGTGGAGTTATGGAAATGTATGTTGAAA), (domain 2* : TTTCAACATACATTTCCATAACTCCACAGGTAAGGCAGCTAGAGGTGC)}
                strands: {(strand 0 : TTTCAACATACATTTCCATAACTC), (strand 1 : CACAGGTAAGGCAGCTAGAGGTGCTTAAAGATCAGCACGAGGACATAG), (strand 2 : GCACCTCTAGCTGCCTTACCTGTGGAGTTATGGAAATGTATGTTGAAA)}
                complexes: [ComplexResult
                        name: complex
                        sequence: [TTTCAACATACATTTCCATAACTC, CACAGGTAAGGCAGCTAGAGGTGCTTAAAGATCAGCACGAGGACATAG, GCACCTCTAGCTGCCTTACCTGTGGAGTTATGGAAATGTATGTTGAAA]
                        structure: Structure("(24+(24.24+)48")
                        log_partition_function: 128.855
                        defect: 2.02636
                        normalized_defect: 0.0168864]
                tubes: [TubeResult {name: tube, nucleotide_concentration: 120, defect: 2.02636, normalized_defect: 0.0168864, complexes: [TubeComplex {name: complex, concentration: 1, target_concentration: 1, defect: 2.02636, structural_defect: 2.02636, concentration_defect: 0, normalized_defect_contribution: 0.0168864}]}]
                defects: [0.0168864]
                weighted_defects: [0.0168864]]
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: [1]}
        success: 1


# Example 5: Test tube design. 

Design a sequence for a target test tube at default temperature 37 ◦C. The target test tube contains 1 on-target dimer (with a target structure and target concentration) and all off-target complexes of up to 2 strands (each with vanishing target concentration).

## Script file contents:

```python
# set properties
material = dna
seed = 93 # set seed to make design repeatable
# define target structure for 1 on-target complex
structure legs = ((((((((((((((((((((.......................+.......................))))))))))))))))))))
# define target test tube containing 1 on-target complex
tube walker = legs
# define target concentration for 1 on-target complex (molar)
# default: 1.0e-6
walker.legs.conc = 1.0e-6
# augment tube with all off-target complexes of up to 2 strands
# default: 0
walker.maxsize = 2
```

## Command: 

```bash
tubedesign $NUPACKHOME/doc/examples/tube-design/simple/input/walker-design
```


```python
design = nupack.design.Design()
design.model = nupack.design.ModelSettings(material='DNA')

structure = '((((((((((((((((((((.......................+.......................))))))))))))))))))))'
lengths = [len(s) for s in structure.split('+')]

design.add_domain('left', 'N'*lengths[0])
design.add_domain('right', 'N'*lengths[1])

design.add_strand('sleft', ['left'])
design.add_strand('sright', ['right'])

design.add_complex("legs", ['sleft', 'sright'], structure=structure)

design.add_tube("walker", {"legs": 1e-6})
design.add_off_targets("walker", maxsize=2)

design.parameters.seed = 93

print(design)
print("\n")
print(design())
```

    Specification
        domains: [DomainSpec {name: left, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: left*, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: right, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}, DomainSpec {name: right*, allowed_bases: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN}]
        strands: [StrandSpec {name: sleft, domain_names: [left]}, StrandSpec {name: sright, domain_names: [right]}]
        complexes: [ComplexSpec {name: legs, strands: [sleft, sright], structure: Structure("(20.23+.23)20")}, ComplexSpec {name: , strands: [sleft], structure: Structure("")}, ComplexSpec {name: , strands: [sleft, sleft], structure: Structure("")}, ComplexSpec {name: , strands: [sright], structure: Structure("")}, ComplexSpec {name: , strands: [sright, sright], structure: Structure("")}]
        tubes: [TubeSpec {name: walker, targets: [([legs] : 1e-06), ([sleft] : 0), ([sleft, sleft] : 0), ([sright] : 0), ([sright, sright] : 0)]}]
        model: ModelKey {parameters: ParameterFile {material: DNA, dG: dna1998.dG, dH: dna1998.dH}, dangle_type: none, conditions: ModelConditions {temperature: 310.15, na_molarity: 1, mg_molarity: 0}}
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: []}
        constraints: ConstraintSpec {complementarity: [], match: [], pattern: [], word: [], similarity: []}
        objectives: []
        parameters: DesignParameters {rng_seed: 93, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        sources: {}
        libraries: {}
    
    
    DesignResult
        model: ModelKey {parameters: ParameterFile {material: DNA, dG: dna1998.dG, dH: dna1998.dH}, dangle_type: none, conditions: ModelConditions {temperature: 310.15, na_molarity: 1, mg_molarity: 0}}
        parameters: DesignParameters {rng_seed: 93, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        stats: DesignStats {num_leaf_evaluations: 1, num_reseeds: 0, num_redecompositions: [], offtargets_added_per_refocus: [], design_time: 0.0441088, analysis_time: 0.0156782, final_Psi: EnsemblePartition {mask: [1, 0, 0, 0, 0], deflate: 0.0002}}
        objectives: []
        results: [SingleResult
                domains: {(left : TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC), (left* : GGTATTCCTTGTCACGGTAGCGTCCGCGATGCATCAGGACTTA), (right : CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA), (right* : TAAGTCCTGATGCATCGCGGTAATGGAGGGGTGAAGTTGGTTG)}
                strands: {(sleft : TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC), (sright : CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA)}
                complexes: [ComplexResult {name: legs, sequence: [TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC, CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA], structure: Structure("(20.23+.23)20"), log_partition_function: 49.1968, defect: 7.55512, normalized_defect: 0.0878503}, ComplexResult {name: sleft, sequence: [TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC], structure: Structure(""), log_partition_function: 7.62985, defect: 0, normalized_defect: 0}, ComplexResult {name: sleft-sleft, sequence: [TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC, TAAGTCCTGATGCATCGCGGACGCTACCGTGACAAGGAATACC], structure: Structure(""), log_partition_function: 27.0179, defect: 0, normalized_defect: 0}, ComplexResult {name: sright, sequence: [CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA], structure: Structure(""), log_partition_function: 1.39703, defect: 0, normalized_defect: 0}, ComplexResult {name: sright-sright, sequence: [CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA, CAACCAACTTCACCCCTCCATTACCGCGATGCATCAGGACTTA], structure: Structure(""), log_partition_function: 18.3991, defect: 0, normalized_defect: 0}]
                tubes: [TubeResult {name: walker, nucleotide_concentration: 8.6e-05, defect: 7.55623e-06, normalized_defect: 0.0878631, complexes: [TubeComplex {name: legs, concentration: 9.99986e-07, target_concentration: 1e-06, defect: 7.55623e-06, structural_defect: 7.55502e-06, concentration_defect: 1.20775e-09, normalized_defect_contribution: 0.0878631}, TubeComplex {name: sleft, concentration: 1.40582e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: sleft-sleft, concentration: 4.58051e-19, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: sright, concentration: 1.40582e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: sright-sright, concentration: 2.14572e-17, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}]}]
                defects: []
                weighted_defects: []]
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: []}
        success: 1


# Example 6: Test tube ensemble defect. 

Calculate the test tube ensemble defect for a specified set of sequences and target test tube at default temperature 37 ◦C. The target test tube contains 1 on-target dimer (with a target structure and target concentration) and all off-target complexes of up to 2 strands (each with vanishing target concentration).

## Script file contents:

```python
# set properties
material = dna
# define 2 sequence domains
domain a = CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA
domain b = TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG
# define 2 strands
strand leg1 = a
strand leg2 = b
# define target structure for 1 on-target complex
structure legs = ((((((((((((((((((((.......................+.......................))))))))))))))))))))
# define strand ordering for 1 on-target complex
legs.seq = leg1 leg2
# define target test tube containing 1 on-target complex
tube walker = legs
# define target concentration for 1 on-target complex (molar)
# default:  1.0e-6
walker.legs.conc = 1.0e-6
# augment tube with all off-target complexes of up to 2 strands
# default:  0
walker.maxsize = 2
```

## Command: 

```bash
tubedefect $NUPACKHOME/doc/examples/tube-design/simple/input/walker-defect
```


```python
design = nupack.design.Design()
design.model = nupack.design.ModelSettings(material='DNA')

design.add_domain('a', 'CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA')
design.add_domain('b', 'TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG')

design.add_strand('leg1', ['a'])
design.add_strand('leg2', ['b'])
structure = '((((((((((((((((((((.......................+.......................))))))))))))))))))))'

design.add_complex('legs', ['leg1', 'leg2'], structure=structure)
design.add_tube('walker', {'legs': 1e-6})
design.add_off_targets('walker', maxsize=2)

print(design.evaluate())
```

    DesignResult
        model: ModelKey {parameters: ParameterFile {material: DNA, dG: dna1998.dG, dH: dna1998.dH}, dangle_type: none, conditions: ModelConditions {temperature: 310.15, na_molarity: 1, mg_molarity: 0}}
        parameters: DesignParameters {rng_seed: 1202698735, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        stats: DesignStats {num_leaf_evaluations: 0, num_reseeds: 0, num_redecompositions: [], offtargets_added_per_refocus: [], design_time: 0, analysis_time: 0.0136458, final_Psi: EnsemblePartition {mask: [], deflate: 6.93377e-310}}
        objectives: []
        results: [SingleResult
                domains: {(a : CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA), (a* : TAGGTTTTTTGTGTGGGGTTGGTCGACCACGCCGATGTTCACG), (b : TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG), (b* : CGTGAACATCGGCGTGGTCGGGAGTGTAGAAATATAGAGGGAA)}
                strands: {(leg1 : CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA), (leg2 : TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG)}
                complexes: [ComplexResult {name: legs, sequence: [CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA, TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG], structure: Structure("(20.23+.23)20"), log_partition_function: 50.6034, defect: 0.791492, normalized_defect: 0.00920339}, ComplexResult {name: leg1, sequence: [CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA], structure: Structure(""), log_partition_function: 4.22828, defect: 0, normalized_defect: 0}, ComplexResult {name: leg1-leg1, sequence: [CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA, CGTGAACATCGGCGTGGTCGACCAACCCCACACAAAAAACCTA], structure: Structure(""), log_partition_function: 26.8881, defect: 0, normalized_defect: 0}, ComplexResult {name: leg2, sequence: [TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG], structure: Structure(""), log_partition_function: 1.57656, defect: 0, normalized_defect: 0}, ComplexResult {name: leg2-leg2, sequence: [TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG, TTCCCTCTATATTTCTACACTCCCGACCACGCCGATGTTCACG], structure: Structure(""), log_partition_function: 10.0175, defect: 0, normalized_defect: 0}]
                tubes: [TubeResult {name: walker, nucleotide_concentration: 8.6e-05, defect: 7.9161e-07, normalized_defect: 0.00920476, complexes: [TubeComplex {name: legs, concentration: 9.99999e-07, target_concentration: 1e-06, defect: 7.9161e-07, structural_defect: 7.9149e-07, concentration_defect: 1.19179e-10, normalized_defect_contribution: 0.00920476}, TubeComplex {name: leg1, concentration: 1.38944e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: leg1-leg1, concentration: 3.53957e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: leg2, concentration: 1.38945e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}, TubeComplex {name: leg2-leg2, concentration: 3.35262e-23, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}]}]
                defects: []
                weighted_defects: []]
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: []}
        success: 1



```python

```
