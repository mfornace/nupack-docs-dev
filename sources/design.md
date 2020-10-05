

# Design Jobs
To enable **reaction pathway engineering** of dynamic hybridization cascades (e.g., shape and sequence transduction using small conditional RNAs [@Hochrein13,@Hanewich-Hollatz19]) or large-scale **structural engineering including pseudoknots** (e.g., RNA origamis [@Geary14]), NUPACK sequence design operates on multistate ensembles:

-  **Multi-complex ensemble:** the ensemble of an arbitrary number of strand species interacting to form an arbitrary number of complex species.
-  **Multi-tube ensemble:** the ensemble of an arbitrary number of test tubes containing different subsets of an arbitrary number of strand species introduced at user-specified concentrations.

We recommend using the [multi-tube design ensemble](definitions.md#multi-tube-design), as it captures concentration and crosstalk effects that are critical in most experimental settings (see the example below regarding the advantages of test tube design over complex design). Note that the multi-tube ensemble encompases the complex ensemble, test tube ensemble, and multi-complex ensemble as subsidiary special cases [@Wolfe17]. 

!!! Example
    <p align="center">
    <img src="/figs/complex-vs-tube-design.png" alt="Benefits of test tube design over complex design" width="700"/>
    </p>
    **Figure: The advantages of test tube design over complex design.** **Top: Complex design.** Sequence design formulated in the context of a complex (left) ensures that at equilibrium the target structure dominates the structural ensemble of the complex (center). Unfortunately, subsequent test tube analysis reveals that the desired on-target complex occurs at negligible concentration relative to other undesired off-target complexes (right). With complex design, neither the concentration of the desired on-target complex, nor the concentrations of undesired off-target complexes are considered. As a result, sequences that are successfully optimized to predominantly adopt a target secondary structure in the context of an on-target complex, may nonetheless fail to ensure that this complex forms at appreciable concentration when the strands are introduced into a test tube. 
    **Bottom: Test tube design.** Sequence design formulated in the context of a test tube (left) ensures that at equilibrium the desired on-target complex is dominated by its target structure and forms at approximately its target concentration, and that undesired off-target complexes form at negligible concentrations (center).    Subsequent test tube analysis (right) provides no 
    new information and no unpleasant surprises since the design and analysis ensembles are identical. 

For reaction pathway engineering, sequence design is formulated as a multistate optimization problem using a set of target test tubes to represent reactant, intermediate, and product states of the system, as well as to model crosstalk between components. Note that we achieve *kinetic design* of a test tube ensemble by performing *equilibrium optimization* of a multi-tube ensemble: each target test tube isolates different subsets of components in local equilibrium, enabling optimization of kinetically significant states that would appear insignificant if all components were allowed to interact in a single ensemble.
For large-scale structural engineering including the possibility of pseudoknots, each target test tube is unpseudoknotted, but by imposing sequence constraints between tubes, it is possible to collectively impose pseudoknotted design requirements.


In a [multi-tube design ensemble](definitions.md#multi-tube-design-ensemble), each target test tube contains a set of desired "on-target" complexes, each with a target
secondary structure and target concentration, and a set of undesired "off-target" complexes, each with vanishing target concentration. Optimization of the [multi-tube ensemble defect](definitions.md#test-tube-ensemble-defect)
implements both a positive design paradigm, explicitly designing for on-pathway elementary steps, and a negative design paradigm, explicitly designing against off-pathway crosstalk. [Defect weights](definitions.md#defect-weights) can be specified to prioritize or de-priotize design quality for different portions of the design ensemble. Sequence design is performed subject to user-specified [hard constraints](definitions.md#hard-constraints) (e.g., sequence constraints imposed by the reaction pathway or biological sequences) and [soft constraints](definitions.md#soft-constraints) (e.g., design a set of toeholds to have comparable binding strength). 



  



## Specify a domain
A `domain` is a set of consecutive nucleotides that appear as a subsequence of one or more strands in a design. A domain is specified as a sequence (specified 5$'$ to 3$'$ using [IUPAC degenerate nucleotide codes](definitions.md#IUPAC-degenerate-nucleotide-codes)) and a domain name (keyword `name`). Consecutive repeats of a single nucleotide code can be represented by the nucleotide code followed by the total number of repeats: 

```python
a = Domain('AAAA',       name='a')
b = Domain('A4',         name='b') # equivalent sequence specification
c = Domain('NNNNNNNNNN', name='c')
d = Domain('N10',        name='d') # equivalent sequence specification
e = Domain('RRSSAAACCA', name='e')
f = Domain('R2S2A3C2A',  name='f') # equivalent sequence specification
g = Domain('N10',        name='g')
```

---

## Specify a target strand
A `TargetStrand` is a single RNA or DNA molecule specified as a sequence (specified 5$'$ to 3$'$ in terms of defined domains) and a target strand name (keyword `name`): 
```python
A = TargetStrand([a, b, g], name='Strand A')
B = TargetStrand([d, ~e],   name='Strand B')  # ~e denotes the reverse complement of e
C = TargetStrand([e, a, f], name='Strand C')
D = TargetStrand([d, d, d], name='Strand D')
```
The reverse complement of domain `a` is denoted `~a`. 

!!! Note
    Note that starting with NUPACK 4 and the all-new NUPACK Python module, we no longer denote the reverse complement of domain `a` as `a*` because that would not be valid Python syntax. 
---

## Specify a target complex
A `TargetComplex` is an on-target complex specified as an ordered list of strands (i.e., an ordering of strands around a circle in a [polymer graph](definitions.md#secondary-structure)), an on-target [secondary structure](definitions.md#secondary-structure) (specified in dot-parens-plus, run-length encoded dot-parens-plus notation, or DU+ notation), and an on-target complex name (keyword `name`):

<!-- ```python
# dot-parens-plus notation
c1 = TargetComplex([A], structure='........(........)', name='c1')  

# run-length-encoded dot-parens-plus notation
c2 = TargetComplex([A, B, B, C], structure='.17(+).18(+).18(+).23', name='c2') 
# DU+ notation
c3 = TargetComplex([A, A], structure='U8 D10 + U8', name='c3')  
``` -->


```python
# dot-parens-plus notation
C1 = TargetComplex([A, B, C], '........((((((((((+))))))))))\   # continue on new line
    ((((((((((+))))))))))..............', name='C1')

# DU+ notation
C2 = TargetComplex([D, D], 'D30 +', name='C2')
C3 = TargetComplex([B, B, B], 'D10(D10 + D10 +)', name='C3')
C4 = TargetComplex([B, A, B], 'D8(U12 +) D10(+) U10', name='C4')

# run-length encoded dot-parens-plus notation
C5 = TargetComplex([B, C], '.10(10+)10.14', name='C5')
```

In certain cases, it may be desirable to adjust the free energy of an on-target complex (for example, if a protein is known to stabilize the complex). For such cases, the optional keyword `bonus` can be used to specify an additional free energy in kcal/mol (default: 0; negative value is stabilizing, postive value is destabilizing): 

```python
# destabilize C6 by 1 kcal/mol
C6 = TargetComplex([B, C], '.10(10+)10.14', name='C6', bonus=+1.0) 

# stabilize C7 by 10 kcal/mol
C7 = TargetComplex([B, C], '.10(10+)10.14', name='C7', bonus=-10.0) 
```

!!! note
    Note that a bonus applied to the complex free energy is equivalent to the same bonus applied to every secondary structrue in the complex ensemble. The bonus will alter the free energy of the complex in solution, but will not alter the equilibrium pair probabilities within the complex ensemble. 

!!! warning
    The bonus will change the MFE free energy. 
---

## Specify a target tube
A `TargetTube` is specified as a tube name (keyword `name`) and a set of on-target complexes each with a target concentration (keyword `targets`; units of `M`). Off-target complexes can be specified in any of three ways: 1) combinatorially using keyword `max_size` to automatically generate the set of all complexes up to a specified number of strands (default: `max_size=1`); 2) using keyword `include` to include an explicitly specified set of complexes (default: `None`); 3) using keyword `exclude` to exclude an explicitly specified set of complexes (default: `None`):

```python
# specify target tube
t1 = TargetTube(targets={C1: 1e-8, C2: 1e-8}, 
    max_size=3, include=[C3, [B, B, B, B]], exclude=[C4], name='t1')
```

!!! note
    Note that `include` and `exclude` accept both target complex identifiers (e.g., `C3`) and strand orderings (e.g., `[B, B, B, B]`). 

    Note that for an off-target specified using a target complex identifier (e.g., `C3`), the target structure is ignored since by definition, there is no target structure for an off-target complex. 

    Note that any complex included as an on-target complex will not be included as an off-target complex when processing `max_size` and `include`. 

## Run a test tube design job

The `Design` class is offered to create a complete multitube design.

```python
my_model = Model()
my_tubes = [t1]
my_design = Design(tubes=my_tubes,
    hard_constraints=[], soft_constraints=[],
    weights=None, options=options, model=my_model)
```

A `Design` possesses three main methods: `optimize()`, `evaluate()`, and `launch()`.

```python
# run a single design and return the final result
result = my_design.optimize()
# evaluate a design with pre-determined sequences
result = my_design.evaluate()
# launch a number of independenet trials of the design in the background
optimization = my_design.launch(2, directory='design-checkpoints')
```

!!!warning
    evaluate() doesn't work here, the input domains are not designed yet

See the below sections for more information on inputs and results.

---

## Run a complex design job

For convenience, the `complex_design` function is provided to give a simple complex design. It simply makes a tube for each complex and returns a `Design` object.

```python
my_design = complex_design(complexes=[c1, c2],
    hard_constraints=[], soft_constraints=[],
    weights=None, options=options, model=my_model)

result = my_design.optimize()
```

---

## Specify hard constraints

Hard constraints are most easily kept track of as a Python `list`. See below for an example:

```python
# define hard constraints

gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

hard = [
    Match([a], [b]),
    Match([a, b, f, f], [d, a, d, a]),
    Complementarity([a, b, f, a, a, b], [c, d, e], allow_wobble=True),
    Similarity(c, 'S10', limits=[0.45, 0.55]), # GC content
    Library([a], catalog = ['CTAC', 'TAAT']),
    Window([a, ~b], source = gfp),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6']),
    Diversity(word=4, diversity=2),
    Diversity(word=6, diversity=3),
    Diversity(word=10, diversity=4, where=[a, B])
]

e = Domain('S2', name='e')
f = Domain('S2', name='f')

#add another constraint to the constrain set
hard += [Complementarity([e],[f], allow_wobble=True)]
hard.append(Complementarity([e],[f], allow_wobble=True)) # same thing
```

See the below subsections for more information about each kind of constraint.

---

### Match

Match constraints are used to constrain concatenations of domains to be identical to each other. They are specified by providing the ```add_match_constraint``` with two lists of domains. The sum of the lengths of the domains in each list must be the same.

```python
a = Domain('N10', name='a')
b = Domain('N4', name='b')
c = Domain('H6', name='c')
d = Domain('N6', name='d')
e = Domain('S2', name='e')

match1 = Match([c], [b, ~e])
match2 = Match([a, b], [d, d, e])
```

---

### Complementarity

Complementarity constraints are used to constraint the concatenation of one list of domains to be the reverse complement of the concatenation of another list of domains. Therefore, the sum of the lenghts of the domains in each list must be the same.

Currently only Watson-Crick complementarity constraints are allowed.

In addition to explicit domain list based specification of complementarity constraints, nucleotides that are base paired in the target structure of an on-target complex will have a complementarity constraint applied automatically once user specification is finished and the design algorithm begins.


```python
comp = Complementarity([a, b], [c, d, e])
```

---

### Similarity

A similarity constraint forces either a domain or strand to match a reference sequence of the same length at a number of positions that falls in a specified range. As such, the constraint is specified using

* the name of the domain or strand
* a reference sequence of the same length as the domain or strand
* a fractional range, $[l, u]$, where $0 \leq l < u \leq 1$

A common use case of the similarity constraint is to constrain a domain or strand to have GC content in a certain range. In this case, the reference sequence is just the degenerate base code ```S``` repeated for the length of the domain / strand.


```python
a = Domain('N10', name='a')
sim1 = Similarity(a, 'S5K5', limits=[0.25, 0.75])

# "composition constraint" special case: enforce 45-55% GC content
b = Domain('N20', name='b')
sim2 = Similarity(b, 'S20', limits=[0.45, 0.55])
```

---

### Window

A window constraint is used to constrain a concatenation of domains to have a sequence that is a substring of a given source sequence.
It is specified in two steps.
First, the source is defined by a name and a sequence.
Then, the constraint itself is specified by giving the list of domains to concatenate and the name of the source sequence.
The constraint can also allow the concatenated domains to have a sequence that is any window from several source sequences by giving a list of their names, instead of just one.


```python
a = Domain('N10', name='a')
b = Domain('N10', name='b')
c = Domain('N10', name='c')
e = Domain('N10', name='e')

gfp = 'AUGGUGAGCAAGGGCGAGGAGCUGUUCACCGGGGUGGUGCCCAUCCUGGUCGAGCUGGACGGCGACGUAAACGGCCACAAGUUCAGCGUGUCCGGCGAGGGCGAGGGCGAUGCCACCUACGGCAAGCUGACCCUGAAGUUCAUCUGCACCACCGGCAAGCUGCCCGUGCCCUGGCCCACCCUCGUGACCACCCUGACCUACGGCGUGCAGUGCUUCAGCCGCUACCCCGACCACAUGAAGCAGCACGACUUCUUCAAGUCCGCCAUGCCCGAAGGCUACGUCCAGGAGCGCACCAUCUUCUUCAAGGACGACGGCAACUACAAG'

rfp = 'CCUGCAGGACGGCGAGUUCAUCUACAAGGUGAAGCUGCGCGGCACCAACUUCCCCUCCGACGGCCCCGUAAUGCAGAAGAAGACCAUGGGCUGGGAGGCCUCCUCCGAGCGGAUGUACCCCGAGGACGGCGCCCUGAAGGGCGAGAUCAAGCAGAGGCUGAAGCUGAAGGACGGCGGCCACUACGACGCUGAGGUCAAGACCACCUACAAGGCCAAGAAGCCCGUGCAGCUGCCCGGCGCCUACAACGUCAACAUCAAGUUGGACAUCACCUCCCACAACGAGGACUACACCAUCGUGGAACAGUACGAACGCGCCGAGGGCCGCCACUCCACCGGCGGCAUGGACGAGCUGUACAAGUAA'

# constrain window to be drawn from source
window1 = Window([a, ~b], [gfp])
# OR constrain window to be drawn from more than once source
window2 = Window([~c, e], [gfp, rfp])
```

---

### Library

A library constraint forces a domain, or concatenated list of domains, to have its sequence come from a fixed set of enumerated sequences of the same length. The constraint is specified in two steps. First, one or more libraries are defined by giving them a name and a list of sequences, all of the same length for a given library. Then, the constraint itself is specified by giving a domain or list of domains and a library or list of libraries. The sum of the lengths of the domains must equal the sum of the library lengths. The library length is the length of any of its sequences.

```python
a = Domain('N6', name='a')
b = Domain('N12', name='b')

# define a library of sequences
toeholds = ['CAGUGG', 'AGCUCG', 'CAGGGC']

# define a library of codons for each amino acid
aaI = ['AUU', 'AUC', 'AUA']
aaL = ['CUU', 'CUC', 'CUA', 'CUG', 'UUA', 'UUG']
aaV = ['GUU', 'GUC', 'GUA', 'GUG']
aaF = ['UUU', 'UUC']
aaM = ['AUG']
aaC = ['UGU', 'UGC']
aaA = ['GCU', 'GCC', 'GCA', 'GCG']
aaG = ['GGU', 'GGC', 'GGA', 'GGG']
aaP = ['CCU', 'CCC', 'CCA', 'CCG']
aaT = ['ACU', 'ACC', 'ACA', 'ACG']
aaS = ['UCU', 'UCC', 'UCA', 'UCG', 'AGU', 'AGC']
aaY = ['UAU', 'UAC']
aaW = ['UGG']
aaQ = ['CAA', 'CAG']
aaN = ['AAU', 'AAC']
aaH = ['CAU', 'CAC']
aaE = ['GAA', 'GAG']
aaD = ['GAU', 'GAC']
aaK = ['AAA', 'AAG']
aaR = ['CGU', 'CGC', 'CGA', 'CGG', 'AGA', 'AGG']
aaSTOP = ['UAA', 'UAG', 'UGA']

# domain a is drawn from the `toeholds' library
lib1 = Library([a], toeholds)

# domain b is drawn from a concatenation of library sequences representing codons
lib2 = Library([b], aaI + aaM + aaC + aaG)
```

---

### Pattern prevention

Pattern prevention constraints are used to prevent any subsequences of a given strand or domain from containing some fixed pattern sequence. This pattern sequence can be specified using degenerate base codes.

Because this constraint is frequently applied with many patterns to many elements of the design, and possibly all strands with in a design, the method ```add_pattern_constraints``` allows specifying multiple pattern constraints simultaneously. The first (required) argument is a single pattern or list of patterns to be prevented. The second (keyword) argument, ```names```, has three valid specifications:

* ```None``` or unspecified: the patterns are prevented in all strands in the design
* a single domain or strand name: the patterns are prevented in only this domain or strand.
* a list of domain or strand names: the patterns are prevented in every named domain or strand.


```python
a = Domain('N12', name='a')
b = Domain('N12', name='b')
A = TargetStrand([a, ~a], name='A')
B = TargetStrand([b, ~b], name='B')

# pattern prevention for a domain
pat1 = Pattern(['A4', 'U4'], where=[a])

# pattern prevention for a strand
pat2 = Pattern(['A4', 'U4'], where=[B])

# preventing the same patterns for strand `A' and domain `b'
pat3 = Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b])

# global pattern prevention
pat4 = Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'])
```

---

### Diversity

New to NUPACK 4.0, diversity constraints represent a more efficient alternative to using pattern prevention constraints to ensure sequence diversity.
For instance, specifying the constraints that no AAAA, CCCC, GGGG, or UUUU should appear in a strand is equivalent to specifying the constraint that every length 4 window of the strand must have at least 2 nucleotide constraints within. When specified as a diversity constraint, both the intention is more clear and the CSP solver is able to more rapidly make sequence mutations.

Diversity constraints are specified by two numbers:

* The first is the window length to consider for the strand(s)/domain(s).
* The second is the minimum number of nucleotide types that must appear in every window of the above length

Following are the two method calls necessary to reproduce the global pattern prevention above.

```python
div1 = Diversity(4, 2)
div2 = Diversity(6, 3)
```

In the above examples, these diversity constraints are applied to all strands in the design.
Just like with pattern prevention constraints, diversity constraints can also be applied with one function call to a user-specified subset of domains or strands by adding a list of them with the keyword `where`.


```python
div3 = Diversity(10, 4, where=[a, B])
```


---

## Specify soft constraints

```python
# define soft for soft constraints
soft = [
    Pattern(['A4', 'U4'], where=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], where=[A, b]), # default weight 1
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity(b, 'S12', limits=[0.45, 0.55], weight=0.25),
    SSM([C, D], word=4, weight=0.15),
    EnergyDiff([a, b]), # min energy diff to median
    EnergyDiff([a, b], energy_ref=-17, weight=0.5) # energy diff to reference
]
```


---

### Pattern prevention

Pattern prevention soft constraints are specified in nearly the same way as pattern prevention hard constraints.
The primary difference is that a weight can be supplied to control the relative design effort spent on the soft constraint.


```python
pat = Pattern(patterns=['A4', 'C4', 'G4', 'U4', 'M6',
    'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5)
```

---

### Similarity

Similarity soft constraints are specified in nearly the same way as similarity hard constraints.
The primary difference is that a weight can be supplied to control the relative design effort spent on the soft constraint.

```python
a = Domain('N10', name='a')
b = Domain('N20', name='b')

# explicitly specify weight
sim = Similarity(b, 'S20', limits=[0.45, 0.55], weight=0.25)
```

---

### Sequence symmetry

Sequence symmetry soft constraints are specified with a list of complex names (or single complex name) to consider simultaneously.
This will penalize windows (i.e. n-grams, critons) that repeat spuriously (not explicitly constrained to be identical) and reverse complement windows that are not in full duplex regions.
Multiple sequence symmetry constraints with different window sizes can be specified for the same sets of complexes, as shown below.

```python
a = Domain('N12', name='a')
b = Domain('N12', name='b')
A = TargetStrand([a, ~a], name='A')
B = TargetStrand([b, ~b], name='B')

C = TargetComplex([A], "(10.4)10", name='C')
D = TargetComplex([A, A], "D24 +", name='D')

ssm1 = SSM([C, D], word=4, weight=0.15)

# the same complexes with larger windows weighted higher
ssm2 = SSM([C, D], word=5, weight=0.25)
ssm3 = SSM([C, D], word=6, weight=0.45)
```

---

### Duplex structure energy equalization

Currently, the only structural motif that can be equalized is a perfect duplex. This is specified by giving a list of domain names.
The soft constraint will then bias search toward sequences that for each domain `a`, the duplex with complementary domain `a*` will approach the median of all the constrained duplexes. A fixed reference energy can also be supplied through the ```energy_ref``` keyword argument, which will try to force the duplex free energies to match that reference energy instead.

```python
# equalize to median value
diff1 = EnergyDiff([a, b])

# equalize to reference value, with explicit weight
diff2 = EnergyDiff([a, b], energy_ref=-17, weight=0.5)
```

---

## Specify defect weights

The user may wish to alter the relative weighting of defect contributions within the design objective function, $\mathcal{M}$, to prioritize or deprioritize design quality for a portion of the design ensemble. Custom defect weights can be defined for any level within the design ensemble (tube, complex, strand, domain), or for any combination of levels (specified coarser to finer with a period separating each level). Each weight takes a value in the interval $[0,\infty)$. By default, all weights are unity. Increasing the weight for a tube, complex, strand or domain will lead to a corresponding increase in the allocation of effort to designing this entity, typically leading to a corresponding reduction in the defect contribution of the entity. Likewise, decreasing the weight for a tube, complex, strand or domain will lead to a corresponding decrease in the allocation of effort to designing this entity, typically leading to a corresponding increase in the defect contribution of the entity. Weights specified at multiple levels within the ensemble are multiplicative (see Supplementary Information of the [multistate design paper](https://pubs.acs.org/doi/10.1021/jacs.6b12693) for details). With the default value of unity for all weights, $\mathcal{M}$ reduces to the multistate test tube ensemble defect, representing the average equilibrium fraction of incorrectly paired nucleotides over the design ensemble. With custom weights, the physical meaning of the objective function is distorted in the service of adjusting design priorities. The following script illustrates assignment of defect weights at different levels within the design ensemble:


You can define custom weights by constructing a `Weights` object from the set of `TargetTube`s that will be designed.

```python
weights = Weights(my_tubes) # All weights are initialized to 1
```

Weights may be freely accessed manipulated by slicing on a subset of 4 axes (in this order):

1. Tube
2. Complex
3. Strand
4. Domain

For instance:

```python
weights[:, :, :, a] *= 2
weights[:, :, A] = 4
weights[t2] = 2
weights[t1, c1] = 5,
weights[:, :, A, b] = 0.75
weights[t2, c3, D, a] = 0.5
weights[t2, :, :, d] = 3
```

!!!warning
    fix the weights, some tubes etc dont belong

Weights may be printed or displayed by similar slicing:

```python
weights
```

> <img src="/figs/weights-output.png" alt="Weights output" title="Example weights output" width="300" />

```python
print(weights[t1])
print(weights[t1, c2])
print(weights[t1, c2, A])
print(weights[t1, c2, :, d])
```

For experienced Python users, a `Weights` object contains a `pandas.DataFrame` as a single member `.frame`.

<!--
!!!example
    ```python

    # domains
    Domain('a', 'N'*10)
    Domain('b', 'N'*10)
    Domain('c', 'N'*10)
    Domain('d', 'N'*10)

    # strands
    Strand('A', ('a', 'b'))
    Strand('B', ('b', 'c'))
    Strand('C', ('c', 'd'))
    Strand('D', ('d', 'a'))

    # complexes
    TargetComplex('S1', ('A', 'B'), 'D20 +')
    TargetComplex('S2', ('B', 'C'), 'D10 (U10+U10)')
    TargetComplex('S3', ('C', 'D'), 'D20 +')
    TargetComplex('S4', ('D', 'A'), 'D5 (U10 D5 + U10)')

    # tubes
    design.add_tube('T1', {'S1': 1.0e-9, 'S2': 1.0e-9})
    design.add_tube('T2', {'S3': 1.0e-9, 'S4': 1.0e-9})

    design.add_off_targets('T1', max_size=2)
    design.add_off_targets('T2', max_size=2)

    # weights specified for a single granularity level
    design.add_weight(2, domain='a')
    design.add_weight(4, complex='S3')
    design.add_weight(0.5, tube='T2')

    # weights for combinations of adjacent granularity levels
    design.add_weight(5, tube='T1', complex='S1')
    design.add_weight(0.75, strand='A', domain='b')
    design.add_weight(0.5, tube='T2', complex='S4', strand='D', domain='a')

    # weights for nonadjacent granularity levels
    design.add_weight(3, tube='T2', domain='d')
    design.add_weight(3, tube='T2', strand='C')
    design.add_weight(0.1, complex='S4', domain='b')

    # objectives are weighted when they are created
    design.add_global_objective(weight=2)
    ``` -->

---

## Job options

Specify any non-defaults. Change `f_stop` to set the defect tolerance on the test tube ensemble defect $\mathcal{M}$.

```python
options = DesignOptions(
    seed=0,     # random number generation seed
    f_stop=0.02,  # stop condition
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

In addition to the multistate test tube design algorithm options, a few others are included in the `DesignOptions` object:

* ```seed```: The seed for the random number generator allowing reproducible design runs
* ```cache_bytes_of_RAM```: The number of bytes of RAM to set as a maximum cache size for thermodynamic block caching
* ```min_ppair```: The minimum pair probability used as a threshhold for converting dense pair probability matrices into sparse representation for efficiency
* ```slowdown```: For development purposes. Runs all thermodynamics calls ```slowdown``` times instead of once.
* ```time_analysis```: A boolean that determines whether the full ensemble is reevaluated at the end to get an accurate timing of the cost of analysis. Can be set to ```False``` to speed up design output.

The remaining log options are all strings and can have four different states:

* ```""```: The empty string (default). If empty, no logging of this type occurs.
* ```"stdout"```: The log is written to the standard output stream.
* ```"stderr"```: The log is written to the standard error stream.
* any other string: The string is treated as a relative path specification where intermediate folders must exist and the log is written to the file at that path.

The information logged for each of these given a non-empty string is as follows:

* ```log```: After every major algorithm component finishes, time since design start, sequence, defect (estimate), algorithm position, decomposition tree position, and active/passive ensemble breakdown are logged.
* ```decomposition_log```: After each time a complex (on- or off-target) is decomposed (or redecomposed), a JSON representation of the decomposition tree is logged.
* ```thermo_log```: Primarily for debugging/development purposes. After every thermodynamic evaluation, the type of calculation (pair probability, bonused pair probability, partition function), number of nucleotides evaluated, and duration of the calculation are logged.


---

## Job results

Both `complex_design` and `tube_design` return a `DesignResult` object which may be introspected by the user. A `DesignResult` contains the following fields:

- `.mapping`: a `dict`-like class from the undesigned domains, strands, complexes, and tubes to their designed equivalents.
- `.defects`: a report of the different types of defects at each level, held internally as `pandas.DataFrame`s.
- `.analysis`: an `AnalysisResult` for thermodynamic results computed on the designed complexes and tubes.
- `.stats`: a rundown of the statistics and timings for the design that took place.

As an example, consider the following design result:

```python
a = Domain('N20', name='a')

A = TargetStrand([a], name='A')
B = TargetStrand([~a], name='B')

C = TargetComplex([A, B], '(20+)20', name='C')

tube = TargetTube({C: 1e-6}, max_size=2, name='tube1')

my_design = Design([tube], model=Model())
result = my_design.optimize()
```

---

### Textual display

The quickest way to look at your results is to use the built-in notebook output function by just running a cell containing the following line:

```python
result
```

This displays the result object as something like the following:

> <img src="/figs/design-output.png" alt="Design output" title="Example design output" width="750" />

You may also use the `print` function, for output in a raw ASCII form:

```python
print(result)
```

Output:

> ```c++
> Results:
> Results:
>   name                 value
> 0    a  GGGCGTCTAGCATAAAGCAC
> 1   a*  GTGCTTTATGCTAGACGCCC
> 2    A  GGGCGTCTAGCATAAAGCAC
> 3    B  GTGCTTTATGCTAGACGCCC
> Ensemble defect: 0.0097
> Objectives:
>     defect  weighted
> 0  0.00971   0.00971
> Tubes:
>   tube_name   defect  normalized
> 0     tube1 3.88e-07     0.00971
> Complexes:
>   complex_name    defect  normalized
> 0            C  0.388416     0.00971
> 1            A  0.000000     0.00000
> 2            B  0.000000     0.00000
> Complexes in tubes:
>   tube_name complex_name   defect  normalized concentration structural actual_concentration target_concentration
> 0     tube1            C 3.88e-07     0.00971      6.77e-14   3.88e-07                1e-06                1e-06
> 1     tube1            A        0     0.00000             0          0             1.72e-15                    0
> 2     tube1            B        0     0.00000             0          0             1.72e-15                    0
> ```

---

### Introspection

You can also interface with the `DesignResult` within Python.


1. For instance, you can look up the designed equivalent of any tube, complex, strand, or domain that was in your design like this:

```python
print(result.mapping[tube])
print(result.mapping[C])
print(result.mapping[A])
print(result.mapping[a])
```

2. You can look at the different defects by looking at the `defects` field, which contains the

```python
print(result.defects.ensemble_defect)
print(result.defects.tubes)
print(result.defects.complexes)
print(result.defects.tube_complexes)
```

The subfields `tubes`, `complexes`, and `tube_complexes` are `pandas.DataFrame`s. These tables contain columns `tube` and `complex` containing the corresponding Python objects. For convenience, these tables also include `tube_name` and `complex_name` corresponding to the `str` names of those objects.

3. You can re-analyze your designed complexes and tubes via the `analysis` field:

```python
t1_designed = result.mapping[tube]

# Compute the MFEs of the designed complexes that were in t1
tube_results = tube_analysis(tubes=[t1_designed], compute=['mfe'], model=my_model)

# Compute complex concentrations with a different set of strand concentrations
conc_results = complex_concentrations(t1_designed, result.analysis,
    concentrations={result.mapping[A]: 1e-8, result.mapping[B]: 1e-9})
```

---

## Saving, checkpointing, and restarting

---

### Saving results to a text file

Any design result can be saved to a text file for later use as follows. However, the result may not be loaded in programmatically; for that purpose, save a binary file instead.

```python
result.save_text('design-result.txt')
```

### Saving and loading results to a binary file

Saving a `DesignResult` as a binary file is simple. Under the hood it just uses the Python's builtin `pickle` module. Just specify the file name like the following example:

```python
result.save('design-result.o')
```

Later, you can load the result back into your Python session with the following class method syntax:

```python
result = DesignResult.load('design-result.o')
```

---

### Running from a prior design result

The following lines of code will run a design using the final output as a checkpoint file. The argument restart must be a python design `DesignResult` object.

```python
newer_result = my_design.optimize(restart=result)
```

---

### Saving checkpoint files automatically

When "calling" the design to start the optimization process, two additional arguments must be added for checkpointing to work, `checkpoint_condition` and `checkpoint_handler`.

`checkpoint_condition` is a binary function that receives the stats and timer object from the running design optimization. The logic in `checkpoint_condition` then uses this information to determine whether a checkpoint should be made, in which case it returns True. In the call below, it is set to an object of an included class, `TimeInterval`. If `checkpoint_condition` is set to an object `TimeInterval(n)`, then a checkpoint will be emitted roughly every `n` seconds.

`checkpoint_handler` is the function which actually does something given that `checkpoint_condition` returns `True`. `checkpoint_handler` takes one argument, a `DesignResult` object, and decides how it will use this information. In the call below, it is set to an object of the included class, `WriteToFileCheckpoint`. This type of `checkpoint_handler` object is instantiated with a filename prefix (`"design-checkpoint"` below) and will convert the design result object into JSON and serialize it to a file with the given prefix and a time stamp, e.g. design_test-2020-01-27T00:16:52.170292.out.

```python
from nupack.design import TimeInterval, WriteToFileCheckpoint

result = my_design.optimize(checkpoint_condition=TimeInterval(1), checkpoint_handler=WriteToFileCheckpoint("design-checkpoint"))
```

---

