

# Design Jobs
To enable **reaction pathway engineering** of dynamic hybridization cascades (e.g., shape and sequence transduction using small conditional RNAs [@Hochrein13,@HanewichHollatz19]) or large-scale **structural engineering including pseudoknots** (e.g., RNA origamis [@Geary14]), NUPACK sequence design operates on multistate ensembles:

-  **Multi-complex ensemble:** the ensemble of an arbitrary number of strand species interacting to form an arbitrary number of complex species.
-  **Multi-tube ensemble:** the ensemble of an arbitrary number of test tubes containing different subsets of an arbitrary number of strand species introduced at user-specified concentrations.

We [recommend](definitions.md#complex-design-vs-test-tube-design) using the [multi-tube design ensemble](definitions.md#multi-tube-design) as it captures concentration and crosstalk effects that are critical in most experimental settings.



For reaction pathway engineering, sequence design is formulated as a multistate optimization problem using a set of target test tubes to represent reactant, intermediate, and product states of the system, as well as to model crosstalk between components. Note that we achieve *kinetic design* of a test tube ensemble by performing *equilibrium optimization* of a multi-tube ensemble: each target test tube isolates different subsets of components in local equilibrium, enabling optimization of kinetically significant states that would appear insignificant if all components were allowed to interact in a single ensemble.
For large-scale structural engineering including the possibility of pseudoknots, each target test tube is unpseudoknotted, but by imposing sequence constraints between tubes, it is possible to collectively impose pseudoknotted design requirements.


In a [multi-tube design ensemble](definitions.md#multi-tube-design-ensemble), each target test tube contains a set of desired "on-target" complexes, each with a target
secondary structure and target concentration, and a set of undesired "off-target" complexes, each with vanishing target concentration. Optimization of the [multi-tube ensemble defect](definitions.md#test-tube-ensemble-defect)
implements both a positive design paradigm, explicitly designing for on-pathway elementary steps, and a negative design paradigm, explicitly designing against off-pathway crosstalk. [Defect weights](definitions.md#defect-weights) can be specified to prioritize or de-priotize design quality for different portions of the design ensemble. Sequence design is performed subject to user-specified [hard constraints](definitions.md#hard-constraints) (e.g., sequence constraints imposed by the reaction pathway or biological sequences) and [soft constraints](definitions.md#soft-constraints) (e.g., design a set of toeholds to have comparable binding strength).




---


## Specify a domain
A `domain` is a set of consecutive nucleotides that appear as a subsequence of one or more strands in a design. A domain is specified as a sequence (specified 5$'$ to 3$'$ using [degenerate nucleotide codes](definitions.md#degenerate-nucleotide-codes)) and a domain name (keyword `name`). Consecutive repeats of a single nucleotide code can be represented by the nucleotide code followed by the total number of repeats:

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
A `TargetStrand` is a single RNA or DNA molecule specified as a sequence (specified 5$'$ to 3$'$ in terms of previously defined domains) and a target strand name (keyword `name`):
```python
A = TargetStrand([a, b, g], name='Strand A')
B = TargetStrand([d, ~e],   name='Strand B')  # ~e denotes the reverse complement of e
C = TargetStrand([e, a, f], name='Strand C')
D = TargetStrand([d, d, d], name='Strand D')
```

The reverse complement of domain `a` is denoted `~a`. Complementarity refers to Watson-Crick complementarity if wobble mutations are prohibited (default) or includes the possibility of G$\cdot$U wobble pairs for RNA if wobble mutations are permitted (see [Job Options](design.md#job-options)).

!!! Note
    Note that starting with NUPACK 4 and the all-new NUPACK Python module, scripts no longer denote the reverse complement of domain `a` as `a*` because that would not be valid Python syntax.

---
## Specify a target complex
A `TargetComplex` is an on- and/or off-target complex specified as an ordered list of strands (i.e., an ordering of strands around a circle in a [polymer graph](definitions.md#secondary-structure)) and a complex name (keyword `name`). If the complex is to be used as an on-target complex in at least one target test tube, it is specified with an on-target [secondary structure](definitions.md#secondary-structure) (specified in dot-parens-plus, run-length encoded dot-parens-plus, or DU+ notation):

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
C1 = TargetComplex([A, B, C], '........((((((((((+))))))))))((((((((((+))))))))))..............', name='C1')

# run-length encoded dot-parens-plus notation
C2 = TargetComplex([B, C], '.10(10+)10.14', name='C2')

# DU+ notation
C3 = TargetComplex([D, D], 'D30 +', name='C3')
C4 = TargetComplex([B, B, B], 'D10(D10 + D10 +)', name='C4')
C5 = TargetComplex([B, A, B], 'D8(U12 +) D10(+) U10', name='C5')


```

!!! note
    The target structure will be used in all target test tubes in which a complex appears as an on-target complex and will be ignored in those target test tubes where a complex appears as an off-target complex.

In certain cases, it may be desirable to adjust the free energy of an on-target complex (for example, if a protein is known to stabilize the complex). For such cases, the optional keyword `bonus` can be used to specify an additional free energy in kcal/mol (default: 0; negative value is stabilizing, postive value is destabilizing):

```python
# destabilize C6 by 1 kcal/mol
C6 = TargetComplex([B, C], '.10(10+)10.14', name='C6', bonus=+1.0)

# stabilize C7 by 10 kcal/mol
C7 = TargetComplex([B, C], '.10(10+)10.14', name='C7', bonus=-10.0)
```

!!! note
    Note that a bonus applied to the [complex free energy](definitions.md#complex-free-energy) is equivalent to applying the bonus to every [structure free energy](definitions.md#structure-free-energy) in the complex ensemble. As a result, the bonus alters the [equilibrium complex concentration](definitions.md#equilibrium-complex-concentrations) within the [test tube ensemble](definitions.md#test-tube-ensemble), but does not alter the [equilibrium base-pairing probabilities](definitions.md#equilibrium-base-pairing-probabilities) within the [complex ensemble](definitions.md#complex-ensemble).

---
## Specify a target tube
A `TargetTube` is specified as a tube name (keyword `name`) and a set of on-target complexes each with a target concentration (keyword `targets`; units of `M`). Off-target complexes can be specified in any of three ways: 1) combinatorially using keyword `max_size` to automatically generate the set of all complexes up to a specified number of strands (default: `max_size=1`); 2) using keyword `include` to include an explicitly specified set of complexes (default: `None`); 3) using keyword `exclude` to exclude an explicitly specified set of complexes (default: `None`):

```python
t1 = TargetTube(targets={C1: 1e-8, C2: 1e-8},
    max_size=3, include=[[B, B, B, B]], exclude=[C4], name='t1')
```

!!! note
    Note that `include` and `exclude` accept both target complex identifiers (e.g., `C3`) and strand orderings (e.g., `[B, B, B, B]`).

    Note that for an off-target specified using a target complex identifier (e.g., `C3`), the target structure is ignored since by definition, there is no target structure for an off-target complex.

    Note that any complex included as an on-target complex will not be included as an off-target complex when processing `max_size` and `include`.

!!! note
    Note that used together, `max_size` and `exclude` provide a powerful combination for specifying [target test tubes](definitions.md#target-test-tubes). With `max_size` it is possible to specify a large set of off-target complexes formed from a set of system components. With `exclude` it is further possible to remove from this large set all of the cognate products that should form between these system components (so they appear as neither on-targets nor off-targets in the tube ensemble). For example, with this approach, the reactive species in a global crosstalk tube can be forced to either perform no reaction (remaining as desired on-targets) or to undergo a crosstalk reaction (forming undesired off-targets), enabling minimization of global crosstalk during sequence optimization.

    An ensemble that excludes cognate reaction products can never be studied in the lab but provides a powerful framework for computational sequence optimization.

## Run a test tube design job

The `tube_design` class performs [constrained multi-tube design](definitions.md#constrained-multitube-design-problem) for a specified set of target test tubes (keyword `tubes`) and a specified [physical model](model.md#model-specification) (keyword `model`). You may optionally: [specify hard constraints](design.md#specify-hard-constraints) (keyword `hard_constraints`), [specify soft constraints](design.md#specify-soft-constraints) (keyword `soft_constraints`), [specify defect weights](design.md#specify-defect-weights) (keyword `defect_weights`), and [specify job options](design.md#job-options) (keyword `options`):


```python
my_model = Model()
my_tubes = [t1]
my_design = tube_design(tubes=my_tubes,
    hard_constraints=[], soft_constraints=[],
    defect_weights=None, options=None, model=my_model)
```

A `tube_design` object supports two methods for performing sequence design:

- `run()`: [run multiple independent design trials in the foreground](design.md#run-a-single-design-trial-in-the-foreground).
- `launch()`: [launch multiple independent design trials in the background](design.md#launch-multiple-design-trials-in-the-background) and save design progress to checkpoint files.

Either method can be used to restart from a previous design result (keyword `restart`). See below for examples using `run()` and `launch()` for the above `tube_design` job.

!!! note
    `run()` is a blocking command that is convenient when you want to run a single quick design trial and wait for the results.`launch()` is a non-blocking command that offers the preferred mode of operation for large design jobs, enabling you to run long design trials in the background with built-in checkpointing.

---



### Run design trials in the foreground

Once a test tube design has been specified using `tube_design`, use `run()` to run a specified number of independent design trials (keyword `trials`) in parallel in the foreground and return a list of `DesignResult` objects:

```python
my_results = my_design.run(trials=2) # run 2 independent design trials
```

A `DesignResult` object can be viewed as a table in a Jupyter notebook, for example:

```python
my_results[0]  # display results table for first design trial
```

Output:

> <img src="/figs/optimization-output.png" alt="Optimization output" title="Example optimization output" width="620" />

Output table displays:

- Designed sequences for each domain and strand.
- Objective function components (weighted ensemble defect and weighted soft constraints (if applicable)).
- Ensemble defect (unweighted).
- Complex defect for each on-target in the ensemble (unweighted).
- Tube defect for each tube in the ensemble (unweighted).
- Structural defect, concentration defect, and total defect for each on-target complex in each tube (unweighted).
- Concentation and target concentration for each on-target complex in each tube.
- Significant off-target complex concentrations in each tube (those off-targets with concentration $\ge$ 1% the maximum complex concentration in the tube).


The keyword `restart` may be included to run a design by providing a list of `DesignResult` objects from a previous design job:


```python
new_results = my_design.run(trials=2, restart=my_results)
```
An error will be thrown if `trials` and `restart` specify different numbers of design trials and `DesignResult` objects.

### Launch design trials in the background

Once a test tube design has been specified using `tube_design`, use `launch()` to start a specified number of independent design trials (keyword `trials`) in parallel in the background. Intermediate results will be saved to a directory specified with keyword `checkpoint` at a regular interval specified with keyword `interval` (in seconds, default 600):

```python
# start 2 independent design trials
my_jobs = my_design.launch(trials=2, checkpoint='my_checkpoints', interval=600)
```

Whereas `run()` returns a list of `DesignResult` objects representing completed design trials, `launch()` returns a list of trial monitors. The design trials will continue in the background.

To examine current results based on the latest checkpoint file for each trial, use the `current_results()` method:

```python
my_current_results = my_jobs.current_results()
```

which returns a list with an entry for each trial that is either a `DesignResult` object (if a checkpoint file or final result is available) or `None` (otherwise). As illustrated above, a `DesignResult` object can be viewed as a table in a Jupyter notebook. For example if a checkpoint is available for the first trial, a table is generated by typing:

```python
my_current_results[0]  # display results table for first design trial
```

If only final results are of interest, use the `final_results()` method:

```python
my_final_results = my_jobs.final_results()
```

which returns a list with an entry for each trial that is either a `DesignResult` object (if a final result is available) or `None` (otherwise).


To lock up the interface and wait for all trials to finish, use the `wait()` method to return a list of `DesignResult` objects:

```python
my_final_results = my_jobs.wait()
```

To stop all trials, use the `stop()` method:

```python
my_jobs.stop()
```

To restart designs from previous results, use the `restart` keyword, providing either a list of `DesignResult` objects from a previous design, or a directory name containing checkpoint files:


```python
# restart from a list of DesignResult objects
my_jobs = my_design.launch(trials=2, checkpoint='new_checkpoints',
    restart=my_current_results)

# restart from a checkpoint directory
my_jobs = my_design.launch(trials=2, checkpoint='new_checkpoints',
    restart='my_checkpoints')
```
An error will be returned if `trials` and `restart` specify different numbers of design trials and `DesignResult` objects. However, if no results exist in the supplied `restart` directory, the design will be started afresh without any error messages. Hence, you can create a rerunnable design by supplying the same directory to `checkpoint` and `restart`:

```python
my_jobs = my_design.launch(trials=2, checkpoint='my_checkpoints',
    restart='my_checkpoints')
```

### Evaluate a design

The `evaluate()` method enables generation of a `DesignResult` object for a `tube_design` that has fully specified sequences (i.e., contains no [degenerate nucleotide codes](definitions.md#degenerate-nucleotide-codes)), for example:

```python
dl1 = Domain('GCACATTGAGCAGCAGACAGGTTTTGAGTTGGGGTGGTTGGTA', name='dl1')
dl2 = Domain('GTGGTGTTGATGGGAGTTTGTTGCTGTCTGCTGCTCAATGTGC', name='dl2')

sl1 = TargetStrand([dl1], name='sl1')
sl2 = TargetStrand([dl2], name='sl2')

dimer = TargetComplex([sl1, sl2], '(20.23+.23)20', name='dimer')

tube = TargetTube({dimer: 1e-06}, max_size=2, name='tube')

tube_des = tube_design([tube], model=Model(material='dna'))
my_evaluated_result = tube_des.evaluate()
```

An error will be returned if any domain contains nucleotides other than `ACGTU`. Just as for any `DesignResult` object, a convenient results table can be displayed in a Jupyter notebook:

```python
my_evaluated_result
```

Output:

> <img src="/figs/evaluation-output.png" alt="Evaluation output" title="Example evaluation output" width="650" />


---

## Run a complex design job

The `complex_design` class enables specification of a [constrained multi-complex design](definitions.md#constrained-multi-complex-design) for a specified set of target complexes (keyword `complexes`) and a specified [physical model](model.md#model-specification) (keyword `model`). You may optionally: [specify hard constraints](design.md#specify-hard-constraints) (keyword `hard_constraints`), [specify soft constraints](design.md#specify-soft-constraints) (keyword `soft_constraints`), [specify defect weights](design.md#specify-defect-weights) (keyword `defect_weights`), and [specify job options](design.md#job-options) (keyword `options`):


```python
my_model = Model()
my_complexes = [C1, C2]
my_design = complex_design(complexes=[C1, C2],
    hard_constraints=[], soft_constraints=[],
    defect_weights=None, options=None, model=my_model)

result = my_design.run(trials=2) # run 2 independent design trials in the foreground
result[0]
```

Output:

> <img src="/figs/complex-design-output.png" alt="Complex design output" title="Example complex design output" width="350" />

A `complex_design` object supports the `launch()`, `run()`, and `evaluate()` methods just as for a `tube_design` object (see above).

!!! note
    Note that a `complex_design` job is equivalent to a `tube_design` job with each on-target complex placed in a separate test tube containing no off-target complexes. For this reason, we strongly [recommend](definitions.md#complex-design-vs-test-tube-design) use of test tube design formulations over complex design formulations so that off-target complexes are present in the design ensemble and the design algorithm can actively design against their formation.

---

## Specify hard constraints

[Hard constraints](definitions.md#hard-constraints) for a design job are specified as a list, for example:

```python
# specify domains
a = Domain('N4', name='a')
b = Domain('N4', name='b')
c = Domain('N5', name='c')
d = Domain('N5', name='d')
e = Domain('N5', name='e')
f = Domain('N5', name='f')

A = TargetStrand([a, b, c], name='A')

# source sequence for window constraint
gfp = 'auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggucgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagggcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcaccaccggcaagcugcccgugcccuggcccacccucgugaccacccugaccuacggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacuucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuucuucaaggacgacggcaacuacaag'

# define list of hard constraints
my_hard_constraints = [
    Match([a], [b]),
    Match([a, b, f, f], [d, a, d, a]),
    Complementarity([a, b, f, a, a, b], [c, d, e, c, c], wobble_mutations=True),
    Similarity([c], 'S5', limits=[0.2, 0.8]), # GC content
    Library([a], catalog=[['CTAC', 'TAAT']]),
    Window([a, ~b], sources=[gfp]),
    Pattern(['A5', 'C5', 'G5', 'U5'], scope=A),
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6']),
    Diversity(word=4, diversity=2),
    Diversity(word=6, diversity=3),
    Diversity(word=10, diversity=4, scope=[a, b])
]

#two ways to add another constraint to the constraint set
my_hard_constraints += [Complementarity([e], [f], wobble_mutations=True)]
my_hard_constraints.append(Complementarity([e], [f], wobble_mutations=True))
```

See below for information about how to specify each type of hard constraint. Note that the specification of a domain (examples above) represents implicit specification of a sequence constraint using [degenerate nucleotide codes](definitions.md#degenerate-nucleotide-codes).

---

### Match

A [match constraint](definitions.md#hard-constraints) forces equal-length concatenations of one or more domains to be identical as follows:

```python
a = Domain('N10', name='a')
b = Domain('N4', name='b')
c = Domain('H6', name='c')
d = Domain('N6', name='d')
e = Domain('S2', name='e')
A = TargetStrand([a, b], name='Strand A')

match1 = Match([c], [b, ~e])  # ~e is the reverse complement of e
match2 = Match([a, b], [d, d, e])
```

!!! Note
    Constraints that expect a list of `Domain` objects for concatenation will alternatively accept a `TargetStrand`.

```python
A = TargetStrand([a, b], name='Strand A')

# specifying target strand A is equivalent to specifying list of domains [a, b]
match3 = Match(A, [d, d, e])
```

---

### Complementarity

A [complementarity constraint](definitions.md#hard-constraints) forces a concatenation of one list of domains to be the reverse complement of an equal-length concatenation of another list of domains:

```python

comp1 = Complementarity([a, b], [c, d, e])

# specifying target strand A is equivalent to specifying list of domains [a, b]
comp2 = Complementarity(A, [c, d, e])
```


!!! Note
    Nucleotides that are base-paired in the target structure of an on-target complex are automatically assigned to satisfy a complementarity constraint.

By default, complementary sequences are required to have Watson-Crick base-pairing (A$\cdot$U or C$\cdot$G for RNA, A$\cdot$T or C$\cdot$G for DNA). To permit wobble mutations for RNA (G$\cdot$U) globally throughout a design, use the `wobble_mutations` [job option](design.md#job-options). Alternatively, wobble mutations can be allowed for individual complementarity constraints (keyword `wobble_mutations`, default: `False`):

```python
comp2 = Complementarity([a, b], [c, d, e], wobble_mutations=True)
```

It is also possible to force base pairs to be wobble pairs:

```python
f = Domain('S2', name='f')
g = Domain('S2', name='g')
comp3 = Complementarity([f], [g], wobble_mutations=True)
```

---

### Similarity

A [similarity constraint](definitions.md#hard-constraints) forces a concatentation of domains to match a reference sequence of the same length to within a specified fractional range. A `Similarity` constraint is specified as:

- a list of domains to be concatenated; alternatively a target strand may be specified
- a reference sequence of the same length as the concatenated domains
- a fractional range, $[l, u]$, where $0 \leq l < u \leq 1$



```python
a = Domain('N10', name='a')
b = Domain('N20', name='b')
C = TargetStrand([a, b, a], name='Strand C')

# similarity constraint for a concatenation of domains
sim1 = Similarity([a, ~a, b], 'S5K35', limits=[0.25, 0.75])

# similarity constraint for a target strand
sim2 = Similarity(C, 'S30K10', limits=[0.25, 0.75]) # for a strand

# use similarity constraint to enforce 45-55% GC content
sim3 = Similarity([a, b], 'S30', limits=[0.45, 0.55])
```


!!! Note
    A similarity constraint can be used to constrain sequence composition (e.g., 45-55% GC content as in the example above).


---

### Window

A [window constraint](definitions.md#hard-constraints) forces a concatenation of domains to have a sequence that is a subsequence of a source sequence. More generally, a window can be drawn from any of multiple source sequences. A `Window` constraint is specified as:

- Define one or more source sequences as strings.
- Specify a list of domains for concatenation; alternatively, specify a target strand
- Specify a list of sources from which the window should be selected

```python
a = Domain('N10', name='a')
b = Domain('N10', name='b')
c = Domain('N10', name='c')
e = Domain('N10', name='e')
A = TargetStrand([a, ~b], name='Strand A')

gfp = 'AUGGUGAGCAAGGGCGAGGAGCUGUUCACCGGGGUGGUGCCCAUCCUGGUCGAGCUGGACGGCGACGUAAACGGCCACAAGUUCAGCGUGUCCGGCGAGGGCGAGGGCGAUGCCACCUACGGCAAGCUGACCCUGAAGUUCAUCUGCACCACCGGCAAGCUGCCCGUGCCCUGGCCCACCCUCGUGACCACCCUGACCUACGGCGUGCAGUGCUUCAGCCGCUACCCCGACCACAUGAAGCAGCACGACUUCUUCAAGUCCGCCAUGCCCGAAGGCUACGUCCAGGAGCGCACCAUCUUCUUCAAGGACGACGGCAACUACAAG'

rfp = 'CCUGCAGGACGGCGAGUUCAUCUACAAGGUGAAGCUGCGCGGCACCAACUUCCCCUCCGACGGCCCCGUAAUGCAGAAGAAGACCAUGGGCUGGGAGGCCUCCUCCGAGCGGAUGUACCCCGAGGACGGCGCCCUGAAGGGCGAGAUCAAGCAGAGGCUGAAGCUGAAGGACGGCGGCCACUACGACGCUGAGGUCAAGACCACCUACAAGGCCAAGAAGCCCGUGCAGCUGCCCGGCGCCUACAACGUCAACAUCAAGUUGGACAUCACCUCCCACAACGAGGACUACACCAUCGUGGAACAGUACGAACGCGCCGAGGGCCGCCACUCCACCGGCGGCAUGGACGAGCUGUACAAGUAA'

# constrain window to be drawn from a source
window1 = Window([a, ~b], sources=[gfp])

# window constraint for a target strand
window2 = Window(A, sources=[gfp])

# constrain window to be drawn from more either of two sources
window3 = Window([~c, e], sources=[gfp, rfp])
```

---

### Library

A [library constraint](definitions.md#hard-constraints) forces a concatenated list of domains to have sequences drawn from a concatenated list of libraries. Each library contains a set of alternative sequences of equal length. A `Library` constraint is specified as:

- Define one or more libraries of alternative sequences of uniform length.
- Specify a list of domains for concatentation; alternatively, specify a target strand
- Specify a list of libraries for concatenation

The sum of the length of the domains must equal the sum of the length of the libraries (where we define the length of a library to be the length of any of its elements).

```python
a = Domain('N6', name='a')
b = Domain('N10', name='b')
c = Domain('N2', name='c')
d = Domain('N3', name='d')
e = Domain('N3', name='e')
A = TargetStrand([d, e], name='Strand A')

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

# domain a is drawn from a toehold library
lib1 = Library([a], [toeholds])

# target strand A is drawn from a toehold library
lib1 = Library(A, [toeholds])

# concatenation [b, c] is drawn from a concatenation of 4 codon libraries
lib2 = Library([b, c], [aaI, aaM, aaC, aaG])
```

---

### Pattern Prevention

A [pattern prevention constraint](definitions.md#hard-constraints) prevents a list of patterns from appearing globally or in a concatenated list of domains. A `Pattern` constraint is specified as:

- a list of patterns to be prevented
- optionally a list of domains for concatenation (keyword `scope`) where the patterns should be prevented; alternatively, a target strand may be specified
- if the scope is unspecified (absence of keyword `scope`), the constraint is global

```python
a = Domain('N12', name='a')
b = Domain('N12', name='b')
A = TargetStrand([a, ~a], name='A')
B = TargetStrand([b, ~b], name='B')

# pattern prevention for concatenation [a, b]
pattern1 = Pattern(['A4', 'U4'], scope=[a, b])

# pattern prevention for target strand B
pattern2 = Pattern(['A4', 'U4'], scope=B)

# global pattern prevention
pattern3 = Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'])
```

---

### Diversity

A [diversity constraint](definitions.md#hard-constraints) forces every window of a specified length to contain a specified degree of sequence diversity, either globally or for a concatenated list of domains. A `Diversity` constraint is specified as:

- the window length in nucleotides
- the minimum number of nucleotide types that must appear in every window
- optionally a list of domains for concatenation (keyword `scope`) where the diversity should be imposed; alternatively, a target strand may be specified
- if the scope is unspecified (absence of keyword `scope`), the constraint is global


```python
a = Domain('N12', name='a')
b = Domain('N12', name='b')
A = TargetStrand([a, ~a], name='A')
C = TargetComplex([A, A], name='A+A')

# global constraints
div1 = Diversity(4, 2)
div2 = Diversity(6, 3)

# local constraint on concatenation [a, b]
div3 = Diversity(10, 4, scope=[a, b])

# local constraint on target strand A
div4 = Diversity(10, 4, scope=A)
```



!!! Note
    A diversity constraint that forces every window of length 4 to contain at least 2 nucleotide types is equivalent to a pattern prevention contraint that prevents patterns: AAAA, CCCC, GGGG, UUUU. Likewise, a diversity constraint that forces every window of length 6 to contain at least 3 nucleotide types is equivalent to a pattern prevention constraint that prevents: MMMMMM, KKKKKK, WWWWWW, SSSSSS, RRRRRR, YYYYYY.

    We recommend diversity constraints over pattern prevention constraints because they make it more efficient to solve the constraint satisfaction problem that identifies a new validate candidate mutation at every step during sequence optimization.

    The global constraints `div1` and `div2` reproduce the global pattern prevention constraint `pattern3`.

---

## Specify soft constraints

```python
# define soft for soft constraints
soft = [
    Pattern(['A4', 'U4'], scope=a),
    Pattern(['A5', 'C5', 'G5', 'U5'], scope=A), # default weight 1
    Pattern(['A4', 'C4', 'G4', 'U4', 'M6', 'K6', 'W6', 'S6', 'R6', 'Y6'], weight=0.5),
    Similarity([b], 'S12', limits=[0.45, 0.55], weight=0.25),
    SSM([C], word=4, weight=0.15),
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
sim = Similarity([b], 'S20', limits=[0.45, 0.55], weight=0.25)
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

[Defect weights](definitions.md#defect-weights) can be specified to reprioritize design effort at any subset of levels (tube, complex, strand, domain) within design ensemble. A `Weights` object is created for the set of `TargetTube` objects to be designed:

```python
a1 = Domain('N5', name='a1')
a2 = Domain('N5', name='a2')
b = Domain('N10', name='b')

A = TargetStrand([a1, a2], name='A')
B = TargetStrand([b], name='B')

AB = TargetComplex([A, B], structure='(10+)10', name='AB')
AA = TargetComplex([A, A], structure='(10+)10', name='AA')

t1 = TargetTube({AB: 1e-8}, name='t1')
t2 = TargetTube({AA: 1e-9, AB: 1e-10}, name='t2')

my_tubes = [t1, t2]
weights = Weights(my_tubes) # All weights are initialized to 1
```

The weights are initialized to 1, but can be customized to take any value in the interval $[0,\infty)$. Weights can be manipulated by slicing on any subset of 4 indices (in the following order: TargetTube, TargetComplex, TargetStrand, Domain). For example:

```python
weights[:, :, :, a1] *= 2
weights[:, :, A] = 4
weights[t2] = 2
weights[t1, AB] = 5
weights[:, :, A, a2] = 0.75
weights[t2, AA, :, a1] = 0.5
weights[t2, :, :, b] = 3
```

A `Weights` object may be displayed as a table in a Jupyter notebook, for example:

```python
weights
```

Output:

<img src="/figs/weights-output.png" alt="Weights output" title="Example weights output" width="300" />

Alternatively, you can view an ASCII representation of the same data by using the `print` function:

```python
print(weights)
```

Output:

```
Tube Complex Strand Domain  Weight
  t1      AB      A     a1    5.00
  t1      AB      A     a2    0.75
  t1      AB      B      b    5.00
  t2      AA      A     a1    0.50
  t2      AA      A     a2    0.75
  t2      AB      A     a1    2.00
  t2      AB      A     a2    0.75
  t2      AB      B      b    3.00
```

For experienced Python users, a `Weights` object contains a `pandas.DataFrame` as a single member `.table`.

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
)
```

In addition to the multistate test tube design algorithm options, a few others are included in the `DesignOptions` object:

* ```seed```: The seed for the random number generator allowing reproducible design runs
* ```cache_bytes_of_RAM```: The number of bytes of RAM to set as a maximum cache size for thermodynamic block caching
* ```min_ppair```: The minimum pair probability used as a threshhold for converting dense pair probability matrices into sparse representation for efficiency

---

## Job results

Both `.run()` and `.evaluate()` return a `DesignResult` object which may be introspected by the user. A `DesignResult` contains the following fields:

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

my_design = tube_design([tube], model=Model())
result = my_design.run(trials=1)[0]
```

---

### Textual display

The quickest way to look at your results is to use the built-in notebook output function by just running a cell containing the following line:

```python
result
```

This displays the result object as something like the following:

> <img src="/figs/design-output.png" alt="Design output" title="Example design output" width="600" />

You may also use the `print` function, for output in a raw ASCII form:

```python
print(result)
```

Output:

> ```
> Domain results:
> Domain              Sequence
>      a  GCATTGAGAAAACGCAAGAG
>
> Strand results:
> Strand              Sequence
>      A  GCATTGAGAAAACGCAAGAG
>      B  CTCTTGCGTTTTCTCAATGC
>
> Objective function:
>            Objective type  Value
>  Weighted ensemble defect 0.0112
>
> Ensemble defect: 0.0112
>
> Complex Complex defect (nt) Normalized complex defect
>       C               0.448                    0.0112
>
> On-target complex defects:
>   Tube Tube defect (M) Normalized tube defect
>  tube1        4.48e-07                 0.0112
>
> Tube defects:
>   Tube On-target complex Structural defect (M) Concentration defect (M) Total defect (M)
>  tube1                 C              4.48e-07                 1.71e-12         4.48e-07
>
> On-target complex concentrations:
>   Tube Complex Concentration (M) Target concentration (M)
>  tube1       C          1.00e-06                 1.00e-06
>
> Significant off-target complex concentrations (>= 1% max complex concentration in tube):
>   Tube Complex Concentration (M)
>  tube1       -                 -
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
