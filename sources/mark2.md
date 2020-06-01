# Niles sandbox (based on Mark Sandbox)

Prefix

```python
from nupack import *
```

## Analysis

### Definitions

#### Domain

A domain may be created from a single sequence. For analysis, this sequence must not contain nucleotide wildcards.

```python
a = Domain('Domain a', 'ATCGTAGCTA')
b = Domain('Domain b', 'ATATSSSKKN') # Wildcards are permitted
```

A domain only compares equal to another one if they are the same Python object:

```python
a1 = Domain('Domain a', 'ATCGTAGCTA')
a2 = Domain('Domain a', 'ATCGTAGCTA')

a1 == a2 # --> False
a1 == a1 # --> True
```


```python
reverse_complement(A)
~A # shorthand
```

#### Strand

A strand may be initialized either from a single sequence or from a list of domains.

```python
A = Strand('Strand A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('Strand B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('Strand C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

a1 = Domain('Domain a1', 'AGTCTAGGATTCGGCGT')
a2 = Domain('Domain a2', 'GGGTTAA')
A = Strand('Strand A', [a1, a2]) # equivalent, but usually only useful for design.
```

A strand only compares equal to another one if they are the same Python object

```python
A1 = Strand('Strand A','AGTCTAGGATTCGGCGTGGGTTAA')
A2 = Strand('Strand A','AGTCTAGGATTCGGCGTGGGTTAA')

A1 == A2 # --> False
A1 == A1 # --> True
```

#### Complex

A complex may be created from a list of strands.

```python
c1 = Complex('Complex 1', [A])
c2 = Complex('Complex 2', [A, B, B, C])
c3 = Complex('Complex 3', [A, A])
```

Complexes are compared based on the lowest rotational order of the contained strands:

```python
c1a = Complex('Complex 1', [A])
c1b = Complex('Complex 2', [A])

c1a == c1b # --> True
c1a == c1a # --> True
```

#### Tube

A tube may be created from a set of strands with specified concentrations:

```python
t1 = Tube('Tube 1', strands={A: 1e-6, B: 1e-8}, maxsize=3, exclude=[c1])
t2 = Tube('Tube 2', strands={A: 1e-6, B: 1e-8, C: 1e-12}, include=[c2], maxsize=3, exclude=[c1])
```

For convenience, the concentrations may be defaulted, in which case the strands may be given without concentrations:

```python
# Allow tube with undefined concentrations?
t3 = Tube('Tube 3', strands=[A, B], include=[c2], maxsize=3, exclude=[c1])
```

A tube only compares equal to itself if it is the same Python object

```python
t1a = Tube('Tube 1', strands={A: 1e-6, B: 1e-8}, maxsize=3, exclude=[c1])
t1b = Tube('Tube 1', strands={A: 1e-6, B: 1e-8}, maxsize=3, exclude=[c1])

t1a == t1b # --> False
t1a == t1a # --> True
```

#### Tube analysis

A set of tubes may be analyzed together to solve for their complex and tube ensemble properties.

```python
# Solve for the partition function, MFE structure, and Boltzmann sampled structures of all of the species in the specified tubes
# Furthermore, also solve for the equilibrium concentrations of complexes in each tube
tube_results = tube_analysis(tubes=[t1, t2], compute=['pairs', 'mfe', 'sample'], model=model, options={'num_sample': 100})

# The results are held as a dict indexable via input tube:
print(tube_results[t1]) # --> TubeResult

print(tube_results[t1].concentrations) # --> 1.5e-10
print(tube_results[t1].ensemble_pairs) # --> [[1.0, 0.0], [0.0, 1.0]]

# You may index a tube result by a specified complex to get its complex ensemble results
print(tube_results[t1][c1].pair_probability) # --> [[1.0, 0.0], [0.0, 1.0]]
```

#### Complex analysis

Sometimes it is unnecessary to compute equilibrium concentrations, and you just want complex ensemble information.

```python
# Here t1 and t2 don't need concentration
complex_results = complex_analysis(tubes=[t1, t2], compute=['pairs', 'mfe'])

# Make a tube to look at specific complexes. (Provide a shorthand version like Ji said?)
complex_results = complex_analysis(tubes=[Tube('My tube', strands=[A, B], include=[c1, c2, c3])], compute=['pairs', 'mfe'])
```

The results may be indexed by complex, similar to `TubeResult` above.

```python
print(complex_results[c1])
print(complex_results[c1].partition_function) # pfunc for complex c1
print(complex_results[c1].mfe) # mfe for complex c1
print(complex_results[c1].pair_probability) # ppairs matrix for complex c1
```

After running `complex_concentrations`, you may solve for the equilibrium concentrations separately. This is done one tube at a time since no savings can be made by doing them together.

```python
t1_result = complex_concentrations(complex_results, t1, {A: 1e-8, B: 1e-9}) # use manually specified concentrations
t2_result = complex_concentrations(complex_results, t2) # use concentration from t2

print(t1_result.conc) # result concentrations

print({k: v.mfe for k, v in complex_results.items()}) # set of mfes for all complexes
print({k: v.ppairs for k, v in complex_results.items()}) # set of ppairs for all complexes
```

### Utilities

```python
my_pfunc = pfunc(c1, model=model) # pfunc(c1, model)
my_pairs = pairs(c1, model=model)
my_mfe = mfe(c1, model=model)

s1 = Structure('.1(3.8)3.9') # Is there a use for named structures?
my_energy = energy(c1, structure='.(((........))).........')
my_prob = prob(c1, structure=s1) # 0.12385347

my_count = count(c1, model=model)
my_subopt = subopt(c1, energy_gap=1.2)
my_samples = sample(c1, num_sample=100)
```

### Design

```python
a = Domain('Domain a', 'AAAA')
b = Domain('Domain b', 'A4') # equivalent sequence specification
c = Domain('Domain c', 'NNNNNNNNNN')
d = Domain('Domain d', 'N10') # equivalent sequence specification
e = Domain('Domain e', 'RRSSAAACCA')
f = Domain('Domain f', 'R2 S2 A3 C2 A') # equivalent sequence specification
g = Domain('Domain g', 'N10')

# Domains should not be specified inline
A = Strand('Strand A', [a, b, g])
B = Strand('Strand B', [d, ~e])
C = Strand('Strand C', [e, a, f])
D = Strand('Strand D', [d, d, d])
```

#### Complexes

A `TargetComplex` is like a `Complex` but contains an on-target structure:

```python
c1 = TargetComplex('Complex c1', [A], structure='.(((........))).........')
c2 = TargetComplex('Complex c2', [A, B, B, C], structure='.1(3.8)3.9')
c3 = TargetComplex('Complex c3', [A, A], structure='U1 D3 U8 U9')
```

#### Tubes

A `TargetTube` is like a `Tube` but is specified by its on-target complex concentrations:

```python
# define target test tubes

t1 = TargetTube('Tube t1', on={c1: 1e-8, c2: 1e-8}, include=[c3], maxsize=3, exclude=[c1])
t2 = TargetTube('Tube t2', on={c1: 1e-8, c2: 1e-8}, include=[c3], maxsize=3, exclude=[c1]),
crosstalk = TargetTube('crosstalk tube', ...)
```

#### Hard constraints

```python
# define hard constraints
toeholds = ['CTAGCTAC', 'TACGTAGCAT']
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

hard = [
    Match([c], [b, complement(e)]),
    Match([a, b], [d, d, e]),
    Complementarity(allow_wobble=True), # global flag (?)
    Complementarity([a, b], [c, d, e], allow_wobble=True), # local flag (?)
    Similarity(b, 'S20', range=[0.45, 0.55]), # GC content
    Library(a, catalog = toeholds),
    Window([a, complement(b)], source = gfp)
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6']),
    Diversity(word=4, diversity=2),
    Diversity(word=6, diversity=3),
    Diversity(word=10, diversity=4, where=[a, B])
]

e = Domain('e','S2')
f = Domain('f','S2')

#add another constraint to the constrain set
hard += [Complementarity([e],[f], allow_wobble=True)]
hard.append(Complementarity([e],[f], allow_wobble=True)) # same thing
```

#### Soft constraints

```python
# define soft for soft constraints
soft = [
    Pattern(['A4', 'U4'], where=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]), # default weight 1
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity(b, 'S20', range=[0.45, 0.55], weight=0.25),
    SSM([C, D], word=4, weight=0.15),
    EnergyDiff([a, b]), # min energy diff to median
    EnergyDiff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference
]
```

#### Weights

```python
# define defect weights to prioritize design effort
weights = Weights() # All initialized to 1
weights[:, :, :, a] *= 2

weights[:, :, s3] = 4
weights[t2] = 2
weights[t1, c1] = 5,
weights[:, :, A, b] = 0.75
weights[t2, c3, D, a] = 0.5
weights[t2, :, :, d] = 3

print(weights[t1].t1)
print(weights[t1, c2])
print(weights[t1, c2, A])
print(weights[t1, c2, A, d])
```

#### Algorithm parameters

Specify any non-defaults.

```python
parameters = DesignParameters(
    seed=0,     # random number generation seed
    stop=0.02,  # stop condition
    trials=1, # number of independent design trials
    f_passive=0.01,
    H_split=2,
    N_split=12,
    f_split=0.99,
    f_stringent=0.99,
    dG_clamp=-20,
    M_bad=300, # number of bad
    M_reseed=50,
    M_reopt=3,
    f_redecomp=0.03,
    f_refocus=0.03,
    cache_bytes_of_RAM=0,
    min_ppair=1e-05,
    slowdown=0,
    log=None,
    decomposition_log=None,
    thermo_log=None,
    time_analysis=1
)
```

#### Complex design

```python
# equivalent for complex design just makes a tube for each complex
results = complex_design(complexes=[c1, c2],
    hardconstraints=hardconstraints, softconstraints=softconstraints,
    defectweights=weights, parameters=parameters)
```

#### Complex design results

#### Tube design

```python
# run the job
results = tube_design(tubes=tubes,
    hard_constraints=hard, soft_constraints=soft,
    defectweights=weights, parameters=parameters)
```

#### Tube design results

```python
# The result contains fully specified tubes, complexes, strands, domains

results.defect # give overall defect
results.defects # give table of defects

print(results[t1])        # --> TubeResult
print(results[t1].defect) # --> 0.15
print(results[t1][c1])    # --> ComplexResult

# Not sure about this part...:
c1_result = results[c1]
A_result = results[A]   # --> Strand
d1_result = results[d1] # --> Domain
```

#### Going to analysis

```python
# reanalyze, incurring any additional analysis cost (maybe with different model)
tube_results = tube_analysis(tubes=results, pairs=True, mfe=True)

# reanalyze concentrations with designed strands
t2_result = complex_concentrations(results[t2], t2, {results[A]: 1e-8, results[B]: 1e-8})
```
