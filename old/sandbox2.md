# Niles sandbox 2

## Tinker with Mark's sandbox

Prefix

```python
from nupack import *
```

### Analysis

```python
from nupack import *

A = Strand('Strand A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('Strand B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('Strand C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

c1 = Complex('Complex 1', [A])
c2 = Complex('Complex 2', [A, B, B, C])
c3 = Complex('Complex 3', [A, A])

t1 = Tube('Tube 1', strands={A: 1e-6, B: 1e-8}, complexes = {maxsize=3, exclude=[c1]})
t2 = Tube('Tube 2', strands={A: 1e-6, B: 1e-8, C: 1e-12}, complexes = {maxsize=3, explicit=[c2], exclude=[c1]})

tube_results = analyze_tube(tubes=[t1, t2], model=mymodel, compute=['pairs', 'mfe']) # calculate pfuncs and concentrations

tube_results[t1]
tube_results[t1].conc
tube_results[t1].epairs
tube_results[t1][c1].ppairs

complex_results = analyze_complexes(strands={A, B},   # calculate pfuncs
    complexes = {maxsize=3, explicit=[c2], exclude=[c1]},
    compute=['pairs', 'mfe'])
    # alternatively provide tubes = [t1 t2] instead of strands and complexes

complex_results
complex_results.mfe # set of mfes for all complexes
complex_results.ppairs # ppairs matrix for all complexes
complex_results[c1] # all results for complex c1
complex_results[c1].pfunc # pfunc for complex c1
complex_results[c1].mfe # mfe for complex c1
complex_results[c1].ppairs # ppairs matrix for complex c1

conc_results = analyze_concentrations(tubes = [t1 t2]}, precompute = complexresults) #calculate concentrations

# conc_results.t1
# conc_results.t1.conc
# conc_results.t1.epairs # tube epairs matrix
# conc_results.t1.ppairs # set of ppairs matrices
# conc_results.t1.c1.ppairs # single ppairs matrix

```


### Utilities

```python

my_pfunc = pfunc(c1,model = my_model) # pfunc(c1, my_model)
my_pairs = pairs(c1,model = my_model)
my_mfe = mfe(c1,model = my_model)

s1 = structure('Structure 1','.1(3.8)3.9')
my_energy = energy(c1, structure = '.(((........))).........')
my_prob = prob(c1, structure = s1)

my_count = count(c1, model = my_model)
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

A = Strand('Strand A', a, b, 'N10')
B = Strand('Strand B', d, ~e)
C = Strand('Strand C', e, a, f)
D = Strand('Strand D', d, d, d)

# Either [] or variadic arguments works ... can be decided on?

c1 = TargetComplex('Complex c1', [A], structure='.(((........))).........')
c2 = TargetComplex('Complex c2', [A, B, B, C], structure='.1(3.8)3.9')
c3 = TargetComplex('Complex c3', [A, A], structure='U1 D3 U8 U9')

# define target test tubes
t1 = TargetTube('Tube t1', on={c1: 1e-8, c2: 1e-8},
    off = ComplexSet(maxsize=3, include=[c2], exclude=[c1]))

t2 = TargetTube('Tube t2', on={c1: 1e-8, c2: 1e-8},
    off = ComplexSet{maxsize=3, include=[c2], exclude=[c1]))

crosstalk = TargetTube('crosstalk tube', on={c1: 1e-8, c2: 1e-8},
    off = ComplexSet{maxsize=2))

targettubes = [t1, t2, crosstalk]

# define hard constraints
toeholds = ['CTAGCTAC', 'TACGTAGCAT']
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

hardconstraints = [
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

hardconstraints += [             #add another constraint to the constrain set
    Complementarity([e],[f],allow_wobble=True) # force wobble pair
]

# define penalties for soft constraints
softconstraints = [
    Pattern(['A4', 'U4'], where=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity(b, 'S20', range=[0.45, 0.55], weight=0.25),
    SSM([C, D], word=4, weight=0.15),
    EnergyMatch([a, b]), # min energy diff to median
    EnergyMatch([a, b], energy_ref=-17, weight=0.5) # energy diff to reference
]

# define defect weights to prioritize design effort
myweights = Weights()
myweights[:, :, :, a] *= 2
#weights[dict(strand=a)] = 2 # also allow?
#weights[{'strand': a}] = 2 # also allow?

myweights[:, s3] = 4
myweights[t2] = 2
myweights[t1, c1] = 5,
myweights[:, :, A, b] = 0.75
myweights[t2, c3, D, a] = 0.5
myweights[t2, :, :, d] = 3

print(myweight[t1])
print(myweight[t1][c2])
print(myweight[t1][c2][A])
print(myweight[t1][c2][A][d])






## Specifying algorithm parameters
# `seed = 0`: random number generation seed
# `stop = 0.02`:  stop condition
# 'trials = 1': number of independent design trials
# `f_passive = 0.01`:
# `H_split = 2`:
# `N_split = 12`:
# `f_split = 0.99 `:
# `f_stringent = 0.99`:
# `dG_clamp = -20`:
# `M_bad = 300`: number of bad
# `M_reseed = 50`:
# `M_reopt = 3`:
# `f_redecomp = 0.03`:
# `f_refocus = 0.03`:
# `cache_bytes_of_RAM = 0`:
# `f_sparse = 1e-05`:
# `slowdown = 0`:
# `log = None`:
# `decomposition_log = None`:
# `thermo_log = None`:
# `time_analysis = 1`:

tubes.append(crosstalk)

parameters = Parameters(stop=0.01, seed=1, trials=10)

# run the job
results = tube_design(targettubes=targettubes,
    hardconstraints=hardconstraints, softconstraints=softconstraints,
    weights=weights, parameters=parameters)

results.defect
results[t1].defect # tube 1 defect
results[t1].tube # gives analysis tube?
results[c1].complex # gives equivalent specified complex?
results.domain(d1) # gives specified sequence?
```
