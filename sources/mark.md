# Mark sandbox

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
