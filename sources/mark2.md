# Reworked API

The first step to using the API is to import the necessary classes and functions from `nupack`. In this documentation, we will assume that you've imported all public classes and functions via:

```python
from nupack import *
```

## Objects

### Sequence

A `Sequence` is specified by valid nucleotide letters, which can contain wildcards. For RNA, `'U'` is automatically replaced by `'T'`. Run-length encoding may be used to specify repeats of a given nucleotide.

```python
s1 = Sequence('AAAAATTTTT')
s2 = Sequence('A5T5')
s3 = Sequence('A5U5')

s1 == s2 # --> True
s1 == s3 # --> True
```

Any sequence used in analysis is expected to not contain wildcard bases.

### Naming

The remaining objects accept a first argument of `name` to be specified by the user.

The name may specified as a `tuple` or `list` instead of a `str`, in which case a `'[]'` based string will be automatically generated. This is specifically useful for repeated definitions:

```python
domains = [Domain(['a', i], 'N6') for i in range(4)]
print([d.name for d in domains]) # --> ['a[0]', 'a[1]', 'a[2]', 'a[3]']
```

Note that for text formatting, the following behavior has been implemented on the following objects:

- `str()` prints the value of the object
- `repr()` prints an expression which is equivalent to the one used to construct the object
- `{:n}` prints the name of the object

For example:

```python
s = Domain('a', 'N6')
print(s) # --> NNNNNN
print('{:n}'.format(s)) # --> a
print(repr(s)) # --> Domain('a', 'NNNNNN')
```

!!! note
    In general, you should make every user-specified name is required to be unique. Uniqueness should hold across different classes of objects (`Domain`, `Strand`, etc.).

### Domain

A domain may be created from a name and `Sequence` (or sequence string).

```python
a = Domain('a', 'ATCGTAGCTA')
b = Domain('b', 'ATATSSSKKN') # Wildcards are permitted
```

You can access the reverse complement of a `Domain` using the following syntaxes:

```python
reverse_complement(a)
~a # shorthand
```

You may access the sequence of a `Domain` via the `.sequence` member:

```python
print(a.sequence) # --> 'ATCGTAGCTA'
```

A domain only compares equal to another one if they are the same Python object:

```python
a1 = Domain('a', 'ATCGTAGCTA')
a2 = Domain('a', 'ATCGTAGCTA')

a1 == a2 # --> False
a1 == a1 # --> True
```

#### Strand

A strand may be initialized either from a single sequence or from a list of domains.

```python
A = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

a1 = Domain('a1', 'AGTCTAGGATTCGGCGT')
a2 = Domain('a2', 'GGGTTAA')
D = Strand('D', [a1, a2]) # mostly useful in a design context
```

A strand only compares equal to another one if they are the same Python object.

```python
A1 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
A2 = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')

A1 == A2 # --> False
A1 == A1 # --> True
```

#### Complex

A complex may be created from an ordered list of strands.

```python
c1 = Complex([A])
c2 = Complex([A, B, B, C])
c3 = Complex([A, A])
```

In general, anytime a `Complex` is expected, a list of strands may be used instead. Optionally, a complex may be given a name by specifying it first:

```python
c4 = Complex('A+B+C', [A, B, C])
```

Complexes are compared based on the lowest rotational order of the contained strands:

```python
c1a = Complex('A-B', [A, B])
c1b = Complex('B-A', [B, A])

c1a == c1b # --> True
c1a == c1a # --> True
```

#### Tube

A tube may be created from a set of strands with specified concentrations. Complexes may be explicitly included via the keyword `include`. All complexes of up to size `n` may be included by specifying `max_size=n` (`max_size` defaults to 1). Complexes may be specifically excluded from the automatically generated set via the `exclude` keyword.

```python
t1 = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8])
t2 = Tube('t2', strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12], include=[c2], max_size=3, exclude=[c1])
```

For convenience, the concentrations may be left out, in which case the strands may be given without concentrations:

```python
# Allow tube with undefined concentrations?
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```

A tube only compares equal to itself if it is the same Python object

```python
t1a = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])
t1b = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])

t1a == t1b # --> False
t1a == t1a # --> True
```

## Analysis

### Tube analysis

A set of tubes may be analyzed together to solve for their complex and tube ensemble properties.
The following example computes the partition function, MFE structure, and 100 Boltzmann sampled structures of each complex in the specified tubes, as well as the equilibrium concentrations of complexes in each tube.

```python
result = tube_analysis(tubes=[t1, t2],
    compute=['pairs', 'mfe', 'sample'], model=model,
    options={'num_sample': 100})
```

The full list of possible computations and options is:

- `'pfunc'`: compute partition function and free energy.
- `'mfe'`: compute MFE energy and structure(s).
- `'pairs'`: compute pair probability. `'sparsity': f` may be specified to return a sparse matrix of only the highest `f * n` pair probabilities for a given base, where `n` is the total number of bases in the complex. `f=1` (the default) returns the full pair probability matrix.
- `'sample'`: compute Boltzmann sampled keywords. `'num_sample': n` returns `n` sampled structures. `'n'` defaults to 1.
- `'subopt'`: compute suboptimal structures. `'energy_gap: e'` computes all structures within `e` kcal/mol of the MFE. `e` defaults to 0.
- `'structure_count'`: compute number of possible secondary structures.
- `'stack_count'`: compute number of possible stacking states.
- `'prob'`: compute probability of a secondary structure. Structures must be specified via `prob_structures` as a list of structures.

The result of `tube_analysis` is an `AnalysisResult` with fields `.complexes` and `.tubes`. For convenience, you may index into the result via either a `Tube` or `Complex`:

!!! note
    I'm not sure this indexing is a good idea. Maybe better to just use the `complexes` and `tubes` fields separately.

```python
print(result[t1]) # --> TubeResult

print(result[t1].complex_concentrations) # --> [1.5e-10]
print(result[t1].strand_pair_probability) # --> [[1.0, 0.0], [0.0, 1.0]]
```

You may index a tube result by a specified complex to get its complex ensemble results

```python
print(result[c1].pair_probability) # --> [[1.0, 0.0], [0.0, 1.0]]
```

### Complex analysis

Sometimes it is unnecessary to compute equilibrium concentrations, and you just want complex ensemble information. You can compute the results by specifying a tube as follows:

```python
t1 = Tube('t1', strands=[A, B], include=[c1, c2, c3])
result = complex_analysis(tubes=[t1], compute=['pairs', 'mfe'])
```

The results may be indexed by complex, similar to `TubeResult` above.

```python
print(result[c1])
print(result[c1].partition_function) # pfunc for complex c1
print(result[c1].min_free_energy) # mfe for complex c1
print(result[c1].mfe_structure) # mfe structure for complex c1
print(result[c1].pair_probability) # ppairs matrix for complex c1

print({k: v.mfe for k, v in result.complexes.items()}) # set of mfes for all complexes
print({k: v.ppairs for k, v in result.complexes.items()}) # set of ppairs for all complexes
```

### Concentration analysis

After running complex analysis, you may solve for the equilibrium concentrations separately. This is done one tube at a time since no savings can be made by computing them together.

```python
t1_result = complex_concentrations(result, t1, concentrations=[1e-8, 1e-9]) # use manually specified concentrations if desired
t2_result = complex_concentrations(result, t2) # use concentration from t2

print(t1_result.complex_concentrations) # result concentrations
```

## Utilities

!!! note
    Seems less error-prone to just insist on specified model, especially for utilities?

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

## Design

```python
a = Domain('Domain a', 'AAAA')
b = Domain('Domain b', 'A4') # equivalent sequence specification
c = Domain('Domain c', 'NNNNNNNNNN')
d = Domain('Domain d', 'N10') # equivalent sequence specification
e = Domain('Domain e', 'RRSSAAACCA')
f = Domain('Domain f', 'R2S2A3C2A') # equivalent sequence specification
g = Domain('Domain g', 'N10')

# Domains should not be specified inline
A = Strand('Strand A', [a, b, g])
B = Strand('Strand B', [d, ~e])
C = Strand('Strand C', [e, a, f])
D = Strand('Strand D', [d, d, d])
```

### TargetComplex

A `TargetComplex` is like a `Complex` but contains an on-target structure. It must be manually named.

```python
c1 = TargetComplex('Complex c1', [A], structure='.(((........))).........')
c2 = TargetComplex('Complex c2', [A, B, B, C], structure='.1(3.8)3.9')
c3 = TargetComplex('Complex c3', [A, A], structure='U1 D3 U8 U9')
```

### TargetTube

A `TargetTube` is like a `Tube` but is specified by its on-target complex concentrations:

```python
# define target test tubes

t1 = TargetTube('Tube t1', targets={c1: 1e-8, c2: 1e-8}, include=[c3], max_size=3, exclude=[c1])
t2 = TargetTube('Tube t2', targets={c1: 1e-8, c2: 1e-8}, include=[c3], max_size=3, exclude=[c1])
crosstalk = TargetTube('crosstalk tube', ...)
```

### Hard constraints

```python
# define hard constraints
toeholds = ['CTAGCTAC', 'TACGTAGCAT']
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

hard = [
    Match([c], [b, ~e]),
    Match([a, b], [d, d, e]),
    Complementarity(allow_wobble=True), # global flag (?)
    Complementarity([a, b], [c, d, e], allow_wobble=True), # local flag (?)
    Similarity(b, 'S20', range=[0.45, 0.55]), # GC content
    Library(a, catalog = toeholds),
    Window([a, ~b], source = gfp)
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

### Soft constraints

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

### Weights

You can define custom weights by constructing a `Weights` object from the set of `TargetTube`s that will be designed.

```python
weights = Weights(tubes) # All weights are initialized to 1
weights[:, :, :, a] *= 2

weights[:, :, s3] = 4
weights[t2] = 2
weights[t1, c1] = 5,
weights[:, :, A, b] = 0.75
weights[t2, c3, D, a] = 0.5
weights[t2, :, :, d] = 3
```

Weights may be printed or displayed by similar slicing:

```python
print(weights[t1])
print(weights[t1, c2])
print(weights[t1, c2, A])
print(weights[t1, c2, :, d])
```

For experienced Python users, a `Weights` object contains a `pandas.DataFrame` as a single member `.frame`.

### Algorithm parameters

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

### Complex design

For convenience, the `complex_design` function is provided to achieve simple complex design. It simply makes a tube for each complex and executes `tube_design`.

```python
results = complex_design(complexes=[c1, c2],
    hard_constraints=hard, soft_constraints=soft,
    weights=weights, parameters=parameters)
```

### Tube design

```python
# run the job
result = tube_design(tubes=tubes,
    hard_constraints=hard, soft_constraints=soft,
    weights=weights, parameters=parameters)
```

### Results

Both `complex_design` and `tube_design` return a `DesignResult` object which may be introspected by the user. A `DesignResult` contains the following fields:

- `.mapping`: a dict from the undesigned domains, strands, complexes, and tubes to their designed equivalents.
- `.defects`: a report of the different types of defects at each level, held internally as a `pandas.DataFrame`.
- `.analysis`: an `AnalysisResult` for thermodynamic results computed on the designed complexes and tubes.
- `.stats`: a rundown of the statistics and timings for the design that took place.

You can look up the designed equivalent of any tube, complex, strand, or domain that was in your design like this:

```python
print(result.mapping[t1])
print(result.mapping[c1])
print(result.mapping[A])
print(result.mapping[a])
```

You can look at the different defects by indexing into the `defects` field:

```python
print(result.defects.tubes[t1])

print(result.defects.tubes[t1].complexes[c1])
```

!!! todo
    Figure out defect display

You can re-analyze your designed complexes and tubes via the `analysis` field:

```python
t1_designed = result.mapping[t1]

# Compute the MFEs of the designed complexes that were in t1
tube_results = tube_analysis(tubes=[t1_designed], compute=['mfe'], model=model, result=result.analysis)

# Compute complex concentrations with a different set of strand concentrations
conc_results = complex_concentrations(result.analysis, t1_designed, concenrations=[1e-8, 1e-9])
```

!!! todo
    Stats

!!! todo
    Graphics
