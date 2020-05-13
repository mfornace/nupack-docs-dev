# Sandbox

## Proposed imperative approach

Prefix

```python
from nupack import *

strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
strand('C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')

complex('C1', ['A'])
complex('C2', ['A', 'B', 'B', 'C'])
complex('C3', ['A', 'A'])

tube('T1', strands={'A': 1e-6, 'B': 1e-8},  
    complexes=[maxsize=3, exclude='C1'])
tube('T2', strands={'A': 1e-6, 'B': 1e-8, 'C': 1e-12},  
    complexes = [maxsize=3, explicit='C2', exclude='C1'])

my_results = tube_analysis(tubes = ['T1', 'T2'], compute = [pairs,mfe]) # calculate pfuncs and concentrations



#strand-set('myPsi0',{['A':1e-6],['B':1e-8]})
#complex-set('myPsi',{maxsize=3,explicit=['C2'],exclude=['C1']})

# calculate pfuncs and concentrations in separate steps 
# (as a result, don't define "tube")

my_complexes = complex_analysis(strands={'A', 'B'},   # calculate pfuncs 
    complexes=[maxsize=3, explicit='C2', exclude='C1'],
    compute = [pairs,mfe])

my_conc = tube_concentrations(strands={'A': 1e-6, 'B': 1e-8}, my_complexes) #calculate concentrations

```

## Utilities

```python
structure('S1','.(((........))).........')
structure('S2','.1(3.8)3.9')
structure('S3','U1 D3 U8 U9')

my_pfunc = pfunc(complex = 'C1', model = my_model)
my_pairs = pairs(complex = 'C2')
my_mfe = mfe(complex = 'C1')
print(my_mfe)

my_energy = energy(complex = 'C1', structure = 'S1')
my_prob = prob(complex = 'C1', strucdture = 'S1')

my_count = count(complex = 'C1')
my_subopt = subopt(complex = 'C1', energy_gap=1.2)
my_samples = sample(complex = 'C1', num_sample = 100)
```

## Design


```python
domain('a', 'AAAA')
domain('b', 'A4') # equivalent sequence specification

domain('c', 'NNNNNNNNNN')
domain('d', 'N10') # equivalent sequence specification

domain('e', 'RRSSAAACCA')
domain('f', 'R2 S2 A3 C2 A') # equivalent sequence specification

strand('A', ['a', 'b', 'N10'])
strand('B', ('d', 'e*'))
strand('C', ('e', 'a', 'f'))
strand('D', ('d', 'd', 'd'))

complex('C1', ['A'])
complex('C2', ['A', 'B', 'B', 'C'])
complex('C3', ['A', 'A'])

structure('S1','.(((........))).........')
structure('S2','.1(3.8)3.9')
structure('S3','U1 D3 U8 U9')

# define target test tubes
t1 = Tube('t1', on={'C1': ['S1', 1e-8], 'C2': ['S2', 1e-8]},
          off={maxsize=3, include=['C2'], exclude=['C1']},
        constraints = myconstraints, weights = myweights, params = myparams, model = mymodel)

t2 = Tube('t2', on={c1: 1e-8, c2: 1e-8},
    off=dict(maxsize=3, include=[c2], exclude=[c1]),
    constraints=[PatternConstraint('...')],
    weights={c1: 0.5})

# define hard constraints

#match constraints
match(['c'], ['b', 'e*'])
match(['a', 'b'], ['d', 'd', 'e'])

#complementarity constraints
complement(['a', 'b'], ['c', 'd', 'e'])

#allow designer to use G.U wobble pairs for RNA
allow_wobble = true

#force wobble pairs
domain('e',S2)
domain('f',S2)
allow_wobble = true
complement('e','f')

# similarity constraint (enforce 45-55% GC content)
similarity('b', 'S20', [0.45, 0.55])

# window constraint

source('GFP',
('auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggu'
'cgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagg'
'gcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcacc'
'accggcaagcugcccgugcccuggcccacccucgugaccacccugaccua'
'cggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacu'
'ucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuuc'
'uucaaggacgacggcaacuacaag') # do we have to split sequence into separate strings like this?

window(['a', 'b*'], 'GFP')

# library constraint
catalog('toeholds', ['CAGUGG', 'AGCUCG', 'CAGGGC'])
library('a', 'toeholds') #hmmm...naming issue

# pattern prevention constraints
pattern(['AAAA', 'UUUU'], names='a')
pattern(['AAAA', 'UUUU'], names='B')
pattern(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], names=['A', 'b'])
pattern(['AAAA', 'CCCC', 'GGGG', 'UUUU',
        'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY']) #global constraint

# diversity constraint
diversity(word=4, diversity=2) #global
diversity(word=6, diversity=3)
diversity_constraints(word = 10, diversity = 4, names=['a', 'B'])


# run the job
myresults = design(tubes=[t1, t2, crosstalk], complexes = [c1, c2],
    hard_constraints=[GCContent(0.4, 0.6)], soft_constraints=[SSMConstraint()],
    defect_weights={t1: 0.5}, trials=5, stop=0.05)
```


```


# constraint list
# passing jobs between analysis, design, utilities 

## Alternative analysis

```python
from nupack import *

A = 'AGTCTAGGATTCGGCGTGGGTTAA'
B = 'TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG'
C = 'AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG'

C1 = Complex([A])
C2 = Complex([A, B, B, C])
C3 = Complex([A, A])

S1 = Structure('.(((........))).........')
S2 = Structure('.1(3.8)3.9')
S3 = Structure('U1 D3 U8 U9')

T1 = Tube(strands={A: 1e-6, B: 1e-8}, max_size=3, explicit=[C2], exclude=[C1])

results = T1.analyze()  # analyze one tube
results = analyze([T1, T2]) # analyze multiple tubes
print(results)
```

## Design

A design which doesn't use named variables. The downside is that the output will be hard to parse by a human.

```python
d1 = Domain('N12')

a = Strand([d1, 'N24']) # or D1 + 'N24'
b = Strand('N48')
c = Strand('N48')

s1 = Structure('.(((........))).........')
s2 = Structure('.1(3.8)3.9')
s3 = Structure('U1 D3 U8 U9')

c1 = Complex([a], 'S1')
c2 = Complex([a, b, b, c], '.48')
c3 = Complex([a, a], 'U48')

t1 = Tube(on={c1: 1e-8, c2: 1e-8},
          off=dict(maxsize=3,include=[c2],exclude=[c1]),
        constraints, weights)


t2 = Tube(on={c1: 1e-8, c2: 1e-8},
    off={maxsize=3, include=[c2], exclude=[c1]},
    constraints=[PatternConstraint('...'), ...],
    weights={c1: 0.5})

# run the job
results = design(tubes = [t1, t2, crosstalk], complexes = [c1, c2],
    constraints=[GCContent(0.4, 0.6)], soft_constraints=[SSMConstraint()],
    weights={t1: 0.5}, trials=5, stop=0.01)
```

## Named design

I've seen this sort of solution multiple times in other Python packages.
The good part is that it's programmatic and can be used without names.
The downside is that there's often repetition when defining an entity.

The following assumes the name is the first argument, but the optional
approach is probably cleaner.

```python
d1 = Domain('d1', 'N12')

a = Strand('a', [d1, 'N24']) # or D1 + 'N24'
b = Strand('b', 'N48')
c = Strand('c', 'N48')

s1 = Structure('s1', '.(((........))).........')
s2 = Structure('s2', '.1(3.8)3.9')
s3 = Structure('s3', 'U1 D3 U8 U9')

c1 = Complex('s1', [a], 'S1')
c2 = Complex('s2', [a, b, b, c], '.48')
c3 = Complex('s3', [a, a], 'U48')

t1 = Tube('t1', on={c1: 1e-8, c2: 1e-8},
          off=dict(maxsize=3, include=[c2], exclude=[c1]),
        constraints, weights)

t2 = Tube('t2', on={c1: 1e-8, c2: 1e-8},
    off=dict(maxsize=3, include=[c2], exclude=[c1]),
    constraints=[PatternConstraint('...')],
    weights={c1: 0.5})

# run the job
results = design(tubes=[t1, t2, crosstalk], complexes = [c1, c2],
    constraints=[GCContent(0.4, 0.6)], soft_constraints=[SSMConstraint()],
    weights={t1: 0.5}, trials=5, stop=0.01)
```


## Optionally named design

This is the same as above, but the name is specified as a keyword argument.
This means that it could be optional, when you want an autogenerated name or don't
care what something is called in the output.

```python
d1 = Domain('N12', name='d1')

a = Strand([d1, 'N24'], name='a') # or D1 + 'N24'
b = Strand('N48', name='b')
c = Strand('N48', name='c')

s1 = Structure('.(((........))).........', name='s1')
s2 = Structure('.1(3.8)3.9', name='s2')
s3 = Structure('U1 D3 U8 U9', name='s3')

c1 = Complex([a], 'S1', name='s1')
c2 = Complex([a, b, b, c], '.48', name='s2')
c3 = Complex([a, a], 'U48', name='s3')

t1 = Tube(name='t1', on={c1: 1e-8, c2: 1e-8},
          off=dict(maxsize=3,include=[c2],exclude=[c1]),
          constraints=None, weights=None)

t2 = Tube(name='t2', on={c1: 1e-8, c2: 1e-8},
    off=dict(maxsize=3, include=[c2], exclude=[c1]),
    constraints=[PatternConstraint('...')],
    weights={c1: 0.5})

# run the job
results = design(tubes=[t1, t2, crosstalk], complexes = [c1, c2],
    constraints=[GCContent(0.4, 0.6)], soft_constraints=[SSMConstraint()],
    weights={t1: 0.5}, trials=5, stop=0.01)
```