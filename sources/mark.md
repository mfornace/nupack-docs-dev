# Mark sandbox

## Rewrite Niles material

Prefix

```python
from nupack import *
```

### Analysis

```python
from nupack import *

A = Strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
B = Strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
C = Strand('c','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

c1 = Complex('c1', [A]),
c2 = Complex('c2', [A, B, B, C]),
c3 = Complex('c3', [A, A])

tubes = [
    Tube('t1', strands={A: 1e-6, B: 1e-8}, maxsize=3, exclude=[c1])
    Tube('t2', strands={A: 1e-6, B: 1e-8, C: 1e-12}, maxsize=3, explicit=[c2], exclude=[c1])
]

my_results = tube_analysis(tubes=tubes, compute=['pairs', 'mfe']) # calculate pfuncs and concentrations


my_complexes = complex_analysis(strands={A, B},   # calculate pfuncs
    maxsize=3, explicit=complexes[2], exclude=c1, compute=['pairs', 'mfe'])


my_conc = tube_concentrations(strands={A: 1e-6, B: 1e-8}, my_complexes) #calculate concentrations
```

### Utilities

```python
my_pfunc = c1.pfunc(my_model) # pfunc(c1, my_model)
my_pairs = c2.pairs(my_model)
my_mfe = c1.mfe(my_model)

my_energy = c1.energy(structure='.(((........))).........')
my_prob = c1.prob(structure='.1(3.8)3.9')

my_count = c1.count()
my_subopt = c1.subopt(energy_gap=1.2)
my_samples = c1.sample(num_sample=100)
```

### Design

```python
a = Domain('a', 'AAAA')
b = Domain('b', 'A4') # equivalent sequence specification

c = Domain('c', 'NNNNNNNNNN')
d = Domain('d', 'N10') # equivalent sequence specification

e = Domain('e', 'RRSSAAACCA')
f = Domain('f', 'R2 S2 A3 C2 A') # equivalent sequence specification

A = Strand('A', a, b, 'N10')
B = Strand('B', d, Complement(e))
C = Strand('C', e, a, f)
D = Strand('D', d, d, d)

# Either [] or variadic arguments works ... can be decided on?

c1 = TargetComplex('c1', [A], structure='.(((........))).........')
c2 = TargetComplex('c2', [A, B, B, C], structure='.1(3.8)3.9')
c3 = TargetComplex('c3', [A, A], structure='U1 D3 U8 U9')

# define target test tubes
t1 = TargetTube('t1', on={C1: 1e-8, C2: 1e-8}, maxsize=3, include=[c2], exclude=[c1])
t2 = TargetTube('t2', on={c1: 1e-8, c2: 1e-8}, maxsize=3, include=[c2], exclude=[c1])

# define hard constraints

toeholds = ['CTAGCTAC', 'TACGTAGCAT']

constraints = {
    Match([c], [b, complement(e)]),
    Match([a, b], [d, d, e]),
    Complementarity(allow_wobble=True), # global flag (?)
    Complementarity([a, b], [c, d, e], allow_wobble=True), # local flag (?)
    Similarity(b, 'S20', range=[0.45, 0.55]),
    Library(a, toeholds),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6']),
    Diversity(word=4, diversity=2),
    Diversity(word=6, diversity=3),
    Diversity(word=10, diversity=4, where=[a, B])
}

penalties = [
    Pattern(['A4', 'U4'], where=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity(b, 'S20', range=[0.45, 0.55], weight=0.25),
    SSM([C, D], word=4, weight=0.15),
    EnergyDiff([a, b]), # min energy diff to median
    EnergyDiff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference
]

weights = Weights()
weights[:, :, :, a] *= 2
weights[dict(strand=a)] *= 2 # also allow?
weights[{'strand': a}] *= 2 # also allow?

weights[:, s3] = 4
weights[t2] *= 2
weights[t1, s1] *= 5,
weights[:, :, A, b] = 0.75
weights[t2, s3, D, a] = 0.5
print(weights)

# weights for nonadjacent granularity levels
weights[t2, :, :, d] = 3
weights[t2, : c] = 3
weights[:, :, s4, b] /= 10

constraints.add(Match([c], [b, complement(e)]))
constraints.add(Match([a, b], [d, d, e]))

#match constraints
constraints.add(Match([c], [b, complement(e)]))
constraints.add(Match([c], [b, complement(e)]))
constraints.add(Match([a, b], [d, d, e]))

#complementarity constraints
constraints.add(Complementarity([a, b], [c, d, e], allow_wobble=True)) # or should flag be global?
constraints.add(Complementarity([a, b], [c, d, e], allow_wobble=True)) # or should flag be global?

#force wobble pairs
e = Domain(e, s2)
f = Domain(f, s2)

# similarity constraint (enforce 45-55% GC content)
constraints.add(Similarity(b, 'S20', range=[0.45, 0.55]))

# window constraint
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

constraint.window([a, complement(b)], source=gfp)

# library constraint
toeholds = ['CAGUGG', 'AGCUCG', 'CAGGGC']
constraints.add(Library(a, toeholds)) #hmmm...naming issue
constraint.add(Library(b, toeholds + [a])) #hmmm...naming issue

# pattern prevention constraints
constraints.add(Pattern(['A4', 'U4'], where=a))
constraints.add(Pattern(['A4', 'U4'], where=B))
constraints.add(Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]))
constraints.add(Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'])) #global constraint

# diversity constraint
constraints.add(Diversity(word = 4, diversity = 2)) #global
constraints.add(Diversity(word=6, diversity=3))
constraints.add(Diversity(word=10, diversity=4, where=[a, B]))

# Define soft constraints

penalties = [
    Pattern(['A4', 'U4'], where=a}, weight=1),
    Pattern(['A4', 'U4'], where=B}, weight=1),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b], weight=2),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5), # specify weight

    Similarity(b, 'S20', range=[0.45, 0.55], weight=0.25),
    SSMPenalty([C, D], word=4, weight=0.15),
    SSMPenalty([C, D], word=5, weight=0.15),
    SSMPenalty([C, D], word=6, weight=0.15), # can SSM penalties be applied to strands, or globally?

    EnergyDifference([a, b]), # min energy diff to median
    EnergyDifference([a, b], energy_ref = -17, weight=0.5) # energy diff to reference
]

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
# `min_ppair = 1e-05`:
# `slowdown = 0`:
# `log = None`:
# `decomposition_log = None`:
# `thermo_log = None`:
# `time_analysis = 1`:

tubes.append(crosstalk)

parameters = {'stop': 0.01, 'seed': 1, 'trials': 10}

# run the job
results = tube_design(tubes=tubes,
    constraints=constraints, penalties=penalties,
    weights=weights, parameters=parameters)

results.defect(t1) # tube 1 defect
results.tube(t1) # gives analysis tube?
results.complex(c1) # gives equivalent specified complex?
results.domain(d1) # gives specified sequence?
```

## Design start

```python
from nupack import *
register_namespace(globals())

a = Domain('AAAA')
b = Domain('A4') # equivalent sequence specification

c = Domain('NNNNNNNNNN')
d = Domain('N10') # equivalent sequence specification

e = Domain('RRSSAAACCA')
f = Domain('R2 S2 A3 C2 A') # equivalent sequence specification

A = Strand([a, b, 'N10'])
B = Strand((d, ~e)) # either ~ or + or .complement()
C = Strand([e, a, f])
D = Strand([d, d, d])

C1 = Complex([A])
C2 = Complex([A, B, B, C])
C3 = Complex([A, A])

S1 = Structure('.(((........))).........')
S2 = Structure('.1(3.8)3.9')
S3 = Structure('U1 D3 U8 U9')
```

## Design

```python
from nupack import *
register_namespace(globals())

a = Domain('AAAA')
b = Domain('A4') # equivalent sequence specification

c = Domain('NNNNNNNNNN')
d = Domain('N10') # equivalent sequence specification

e = Domain('RRSSAAACCA')
f = Domain('R2 S2 A3 C2 A') # equivalent sequence specification

A = Strand([a, b, 'N10'])
B = Strand((d, ~e)) # either ~ or + or .complement()
C = Strand([e, a, f])
D = Strand([d, d, d])

C1 = Complex([A])
C2 = Complex([A, B, B, C])
C3 = Complex([A, A])

S1 = Structure('.(((........))).........')
S2 = Structure('.1(3.8)3.9')
S3 = Structure('U1 D3 U8 U9')

# define target test tubes
t1 = Tube(on={c1: 1e-8, c2: 1e-8},
          off=dict(maxsize=3, include=[c2], exclude=[c1]))

# define hard constraints
constraints = ConstraintSet()

#match constraints
constraints.match([c], [b, ~e]))
constraints.match([a, b], [d, d, e]))

#complementarity constraints
constraints.complement([a, b], [c, d, e], allow_wobble=True)) # or should flag be global?

# similarity constraint (enforce 45-55% GC content)
constraints.similarity(b, 'S20', range=[0.45, 0.55]))

# window constraint

gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

constraints.window([a, ~b], gfp))

# library constraint
constraints.library(a, ['CAGUGG', 'AGCUCG', 'CAGGGC']) #hmmm...naming issue

# pattern prevention constraints
constraints.pattern(['AAAA', 'UUUU'], scope=A))
constraints.pattern(['AAAA', 'UUUU'], scope=b))
constraints.pattern(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], scope=[A, b]))
constraints.pattern(['AAAA', 'CCCC', 'GGGG', 'UUUU', 'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'])) #global constraint

# diversity constraint
constraints.diversity(word=4, diversity=2) #global
constraints.diversity(word=6, diversity=3)
constraints.diversity(word=10, diversity=4, scope=[a, B])

# Define soft constraints
penalty = SoftConstraints()
penalty.pattern(['AAAA', 'UUUU'], scope=a)
penalty.pattern(['AAAA', 'UUUU'], scope=B)
penalty.pattern(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], scope=[A, b])
penalty.pattern(['AAAA', 'CCCC', 'GGGG', 'UUUU', 'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'], weight=0.5) # specify weight

penalty.similarity(b, 'S'*20, [0.45, 0.55], weight=0.25)

penalty.ssm([C, D], word=4, weight=0.15)
penalty.ssm([C, D], word=5, weight=0.15)
penalty.ssm([C, D], word=6, weight=0.15) # can SSM penalties be applied to strands, or globally?

penalty.energy_diff([a, b]) # min energy diff to median
penalty.energy_diff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference


weights = Weights()
# Define defect weights
# weights specified for a single granularity level
weights.set(2, domain=a)
weights.set(4, complex=s3)
weights.set(2, tube=t2)

# weights for combinations of adjacent granularity levels
weights.set(5, tube=t1, complex=s1) # how to denote intersection
weights.set(0.75, strand=a, domain=b)
weights.set(0.5, tube=t2, complex=s4, strand=d, domain=a)

# weights for nonadjacent granularity levels
weights.set(3, tube=t2, domain=d1)
weights.set(3, tube=t2, strand=c)
weights.set(0.1, complex=s4, domain=b)

params = dict(stop=0.01, seed=1, trials=10)

# run the job
myresults = tube_design(tubes=[t1, t2, crosstalk],
    constraints=constraints, penalties=penalties,
    weights=weights, parameters=parameters)
```

## Avoiding double names


```python
from nupack import *
register_namespace(globals())

domains = [
    a = Domain('AAAA')
    b = Domain('A4') # equivalent sequence specification
    c = Domain('NNNNNNNNNN')
    d = Domain('N10') # equivalent sequence specification
    e = Domain('RRSSAAACCA')
    f = Domain('R2 S2 A3 C2 A') # equivalent sequence specification
]

strands = [
    A = Strand([a, b, 'N10'])
    B = Strand((d, ~e)) # either ~ or + or .complement()
    C = Strand([e, a, f])
    D = Strand([d, d, d])
]

complexes = [
    C1 = Complex([A])
    C2 = Complex([A, B, B, C])
    C3 = Complex([A, A])
]

structures = [
    S1 = Structure('.(((........))).........')
    S2 = Structure('.1(3.8)3.9')
    S3 = Structure('U1 D3 U8 U9')
]

# define target test tubes
t1 = Tube(on={c1: 1e-8, c2: 1e-8},
          off=dict(maxsize=3, include=[c2], exclude=[c1]))

# define hard constraints
constraints = ConstraintSet()

#match constraints
constraints.match([c], [b, ~e]))
constraints.match([a, b], [d, d, e]))

#complementarity constraints
constraints.complement([a, b], [c, d, e], allow_wobble=True)) # or should flag be global?

# similarity constraint (enforce 45-55% GC content)
constraints.similarity(b, 'S20', range=[0.45, 0.55]))

# window constraint

gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

constraints.window([a, ~b], gfp))

# library constraint
constraints.library(a, ['CAGUGG', 'AGCUCG', 'CAGGGC']) #hmmm...naming issue

# pattern prevention constraints
constraints.pattern(['AAAA', 'UUUU'], scope=A))
constraints.pattern(['AAAA', 'UUUU'], scope=b))
constraints.pattern(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], scope=[A, b]))
constraints.pattern(['AAAA', 'CCCC', 'GGGG', 'UUUU', 'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'])) #global constraint

# diversity constraint
constraints.diversity(word=4, diversity=2) #global
constraints.diversity(word=6, diversity=3)
constraints.diversity(word=10, diversity=4, scope=[a, B])

# Define soft constraints
penalty = SoftConstraints()
penalty.pattern(['AAAA', 'UUUU'], scope=a)
penalty.pattern(['AAAA', 'UUUU'], scope=B)
penalty.pattern(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], scope=[A, b])
penalty.pattern(['AAAA', 'CCCC', 'GGGG', 'UUUU', 'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'], weight=0.5) # specify weight

penalty.similarity(b, 'S'*20, [0.45, 0.55], weight=0.25)

penalty.ssm([C, D], word=4, weight=0.15)
penalty.ssm([C, D], word=5, weight=0.15)
penalty.ssm([C, D], word=6, weight=0.15) # can SSM penalties be applied to strands, or globally?

penalty.energy_diff([a, b]) # min energy diff to median
penalty.energy_diff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference


weights = Weights()
# Define defect weights
# weights specified for a single granularity level
weights.set(2, domain=a)
weights.set(4, complex=s3)
weights.set(2, tube=t2)

# weights for combinations of adjacent granularity levels
weights.set(5, tube=t1, complex=s1) # how to denote intersection
weights.set(0.75, strand=a, domain=b)
weights.set(0.5, tube=t2, complex=s4, strand=d, domain=a)

# weights for nonadjacent granularity levels
weights.set(3, tube=t2, domain=d1)
weights.set(3, tube=t2, strand=c)
weights.set(0.1, complex=s4, domain=b)

params = dict(stop=0.01, seed=1, trials=10)

# run the job
myresults = tube_design(tubes=[t1, t2, crosstalk],
    constraints=constraints, penalties=penalties,
    weights=weights, parameters=parameters)
```