# Niles sandbox (based on Mark Sandbox)

Prefix

```python
from nupack import *
```

## Analysis

### Definitions

```python
A = Strand('Strand A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('Strand B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('Strand C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

c1 = Complex('Complex 1', [A])
c2 = Complex('Complex 2', [A, B, B, C])
c3 = Complex('Complex 3', [A, A])

t1 = Tube('Tube 1', strands={A: 1e-6, B: 1e-8}, maxsize=3, exclude=[c1])
t2 = Tube('Tube 2', strands={A: 1e-6, B: 1e-8, C: 1e-12}, include=[c2], maxsize=3, exclude=[c1])

# Allow tube with undefined concentrations?
t3 = Tube('Tube 3', strands=[A, B], include=[c2], maxsize=3, exclude=[c1])
```

### Tube analysis

```python
tube_results = tube_analysis(tubes=[t1, t2], compute=['pairs', 'mfe']) # calculate pfuncs and concentrations
print(type(tube_results)) # --> dict?

t1_result = tube_results[t1]
print(type(t1_result)) # --> EvaluatedTube

print(tube_results[t1].conc) # --> 1.5e-10
print(tube_results[t1].epairs) # --> [[1.0, 0.0], [0.0, 1.0]]
print(tube_results[t1][c1].ppairs) # --> [[1.0, 0.0], [0.0, 1.0]]

print(t1_result.conc)
print(t1_result.epairs)
print(t1_result[c1].ppairs)
```

```python
# Needs concentrations
tube_results = tube_analysis(tubes=[t1, t2], compute=['pairs', 'mfe'])
print(tube_results[t1])

# Here t1 and t2 don't need concentration
complex_results = complex_analysis(tubes=[t1, t2], compute=['pairs', 'mfe'])

# Make a tube to look at specific complexes. (Provide a shorthand version like Ji said?)
complex_results = complex_analysis(tubes=[Tube('My tube', strands=[A, B], include=[c1, c2, c3])], compute=['pairs', 'mfe'])
print(type(complex_results)) # --> dict (map from Complex to AnalyzedComplex)
print(complex_results[c1])

print(complex_results) # set or results for all complexes
print(complex_results[c1]) # all results for complex c1
print(complex_results[c1].pfunc) # pfunc for complex c1
print(complex_results[c1].mfe) # mfe for complex c1
print(complex_results[c1].ppairs) # ppairs matrix for complex c1

# Here t1 and t2 don't need concentration if they are specified separately:
t1_result = complex_concentrations(complex_results, t1, {A: 1e-8, B: 1e-9}) # use manually specified concentrations
t2_result = complex_concentrations(complex_results, t2) # use concentration from t2

print({k: v.mfe for k, v in complex_results.items()}) # set of mfes for all complexes
print({k: v.ppairs for k, v in complex_results.items()}) # set of ppairs for all complexes

t1_result
t1_result.conc
t1_result.epairs # tube epairs matrix
t1_result.ppairs # set of ppairs matrices
t1_result[c1].ppairs # single ppairs matrix
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

WC complements:

```python
complement(A)
~A # shorthand
```

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

c1 = TargetComplex('Complex c1', [A], structure='.(((........))).........')
c2 = TargetComplex('Complex c2', [A, B, B, C], structure='.1(3.8)3.9')
c3 = TargetComplex('Complex c3', [A, A], structure='U1 D3 U8 U9')

# define target test tubes

t1 = TargetTube('Tube t1', on={c1: 1e-8, c2: 1e-8}, include=[c3], maxsize=3, exclude=[c1])
t2 = TargetTube('Tube t2', on={c1: 1e-8, c2: 1e-8}, include=[c3], maxsize=3, exclude=[c1]),
crosstalk = TargetTube('crosstalk tube', ...)

# define hard constraints
toeholds = ['CTAGCTAC', 'TACGTAGCAT']
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

constraints = [
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
constraints += [Complementarity([e],[f], allow_wobble=True)]
constraints.append(Complementarity([e],[f], allow_wobble=True)) # same thing

# define penalties for soft constraints
penalties = [
    Pattern(['A4', 'U4'], where=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]), # default weight 1
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity(b, 'S20', range=[0.45, 0.55], weight=0.25),
    SSM([C, D], word=4, weight=0.15),
    EnergyDiff([a, b]), # min energy diff to median
    EnergyDiff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference
]

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

# Specifying algorithm parameters. Specify any non-defaults
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

# run the job
results = tube_design(tubes=tubes,
    hardconstraints=hardconstraints, softconstraints=softconstraints,
    defectweights=weights, parameters=parameters)

# equivalent for complex design just makes a tube for each complex
results = complex_design(complexes=[c1, c2],
    hardconstraints=hardconstraints, softconstraints=softconstraints,
    defectweights=weights, parameters=parameters)

# The result contains fully specified tubes, complexes, strands, domains

results.defect # give overall defect
results.defects # give table of defects

t1_result = results[t1]
print(type(t1_result))  # --> AnalyzedTube
print(t1_result.defect) # --> 0.15
print(t1_result[c1])    # --> AnalyzedComplex

c1_result = results[c1]
A_result = results[A]   # --> Strand
d1_result = results[d1] # --> Domain

# reanalyze, incurring analysis cost (maybe with different model)
tube_results = tube_analysis(tubes=[results[t1], results[t2]], pairs=True, mfe=True)

# only analyze concentrations (complex stuff already computed)
conc_results = results.analyze_concentrations(tubes=[t1, t2]})
```
