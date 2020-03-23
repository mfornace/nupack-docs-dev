# Preliminaries

This notebook will show how to create, define, and run a ```Design``` object to perform sequence design of nucleic acids.

Following a generic introduction, example designs will

## Importing the necessary classes

The ```Design``` class must be imported to build up a design:


```python
from nupack import Design
```

To change physical parameters from their defaults, the ```ModelSettings``` class must be imported:


```python
from nupack.design import ModelSettings
```

## Creating a design

The first step is creating a new design object:


```python
design = Design()
```

The following instruction will assume that a design object called ```design``` has already been created.

# Specifying a design

## Physical parameters

A ```Design``` object has a property called model that can be overwritten with a new ```ModelSettings``` object to change the material, dangles/coaxial stacking model, temperature, and sodium and magnesium concentrations.

```temperature``` is specified in Kelvin (K), and ion concentrations are specified in Molar (M).

Options for ```ensemble``` are:
* "nostacking": No dangle and coaxial stacking states in the expanded energy model are considered.
* "stacking" (the default): All dangle and coaxial stacking states in the expanded energy model are considered.
* "none": No dangle interactions are considered.
* "min": Unpaired nucleotides adjacent to base pairs always dangle stack. In cases were an unpaired nucleotide can dangle on either of two adjacent base pairs, the lower energy contribution is added
* "all": Unpaired nucleotides adjacent to base pairs always dangle stack. In cases were an unpaired nucleotide can dangle on either of two adjacent base pairs, the sum of the two contributions is added.


```python
design.model = ModelSettings(material='RNA', temperature=310.15, sodium=1.0, magnesium=0.0, ensemble='stacking')
```

Additionally, custom parameter files can be specified as arguments to the ```ModelSettings``` constructor. For instance, to use use the RNA 2006 parameter set, the following line would suffice:


```python
design.model = ModelSettings(material='rna06')
```

## Specifying a domain

A domain is a set of consecutive nucleotides that appear as a subsequence of one or more strands in the design. Each domain is given a string name to allow reference to it when specifying strands. The method ```add_domain``` is used to define the domain in the design in terms of a string of [degenerate nucleotides codes](https://www.bioinformatics.org/sms/iupac.html). These strings are just Python strings, and as such can be constructed using string multiplication and concatenation, as shown in the following examples.


```python
design.add_domain('a', 'AAAA')
design.add_domain('b', 'A'*4) # equivalent sequence specification

design.add_domain('c', 'NNNNNNNNNN')
design.add_domain('d', 'N'*10) # equivalent sequence specification

design.add_domain('e', 'RRSSAAACCA')
design.add_domain('f', 'R'*2 + 'S'*2 + 'A'*3 + 'C'*2 + 'A') # equivalent sequence specification
```

Note: when a domain ```x``` is added, the reverese complement domain ```x*``` is added as well, with a sequence of N's of the same length as ```x```. Despite this seeming like ```x*``` is free to be any nucleotide, complementarity constraints are added during design initialization to ensure that whatever sequence ```x``` takes, ```x*``` will be its reverse complement. However, A more specific sequence for ```x*``` can be defined as in the following example.


```python
design.add_domain('a*', "TTTT")
```

## Specifying a strand

Strands are contiguous (no nicks along the phosphate backbone) concatenations of domains; domains may appear in multiple strands or multiple times in the same strand. The method ```add_strand``` is used to define a strand by its name and a tuple/list of domain names.


```python
design.add_strand('A', ['a', 'b', 'c'])
design.add_strand('B', ('d', 'e*'))
design.add_strand('C', ('e', 'a', 'f'))
design.add_strand('D', ('d', 'd', 'd'))
```

## Specifying an on-target complex

On-target complexes are specified via a single command, ```add_complex```. Complexes are specified by a name, a tuple/list of strands, and a string representing the target structure. The target structure is specified from $5^\prime$ to $3^\prime$ starting from the $5^\prime{-}$end of the first strand and ending at the $3^\prime{-}$end of the last strand.

Structure strings can be specified using one of three notations, with examples shown below:
* dot-parens-plus notation
* DU+ notation
* run-length encoded dot-parens-plus notation


```python
# dot-parens-plus notation
design.add_complex('C1', ('A', 'B', 'C'), '........((((((((((+))))))))))((((((((((+))))))))))..............')

# DU+ notation
design.add_complex('C2', ('D', 'D'), 'D30 +')
design.add_complex('C3', ('B', 'B', 'B'), 'D10(D10 + D10 +)')
design.add_complex('C4', ('B', 'A', 'B'), 'D8(U12 +) D10(+) U10')

# run-length encoded dot-parens-plus notation
design.add_complex('C5', ('B', 'C'), '.10(10+)10.10')
```

## Specifying a test tube

A test tube ensemble is defined in two steps. First, the ```add_tube``` method is used to add a new tube to the design with a given name and a dictionary mapping the names of on-target complexes ($\Psi^\text{on}$) in the tube to their concentrations. Concentrations are always in units of Molar (M). Second, the method ```add_off_targets``` specifies the set of off-target complexes ($\Psi^\text{off}$) in the tube through three keywords, which can be combined arbitrarily:

* ```maxsize```, integer in $[0,\infty]$, default=0: Adds all complexes of up to ```maxsize``` composed of the strands of complexes in $\Psi^\text{on}$ to $\Psi^\text{off}$ such that $\Psi^\text{off} \cap \Psi^\text{on} = \varnothing$.
* ```explicit```, list of strings or iterables of strings, default=```None```: Each item in ```explicit``` is either a name of a complex, name of single strand, or iterable of names of strands.
The implied complexes are added to $\Psi^\text{off}$, provided they are not already in $\Psi^\text{on}$.
* ```exclude```, list of strings or iterables of strings, default=```None```: Each item in ```exclude``` is either a name of a complex, name of single strand, or iterable of names of strands.
The implied complexes are prevented from being added to $\Psi^\text{off}$ when processing ```maxsize``` and ```explicit```.


```python
# specify tubes by their names and on-target complexes with on-target concentrations
design.add_tube('T1', {'C1': 1e-6})
design.add_tube('T2', {'C2': 1e-6})
design.add_tube('T3', {'C1': 0.000001, 'C2': 1e-3})
design.add_tube('T4', {'C1': 2e-4, 'C3': 3e-5})
design.add_tube('T5', {'C4': 4e-6, 'C5': 5e-7})
design.add_tube('T6', {'C5': 6e-8})


# specify named off-target complexes in tube
design.add_off_targets('T1', explicit=['C4', 'C5'])

# specify unnamed off-targets each denoted by a strand ordering
design.add_off_targets('T2', explicit=[('D', 'D', 'D'), ('D', 'D', 'D', 'D')])

# specify combination of named and unnamed off-targets
design.add_off_targets('T3', explicit=['C3', ('A', 'A', 'B', 'B'), 'C', ('D', 'D', 'D', 'D')])

# specify off-targets combinatorially:
# all complexes of up to 2 strands that are not on-targets in tube `T4'
design.add_off_targets('T4', maxsize=2)

# specify off-targets as the sum of sets
design.add_off_targets('T5', maxsize=2, explicit=['C3', ('B', 'B', 'B', 'B')] )

# specify off-targets as the difference of sets
design.add_off_targets('T6', maxsize=3, exclude=['C3', ('B', 'B')])
```

## Specifying sequence constraints

### Match constraint

Match constraints are used to constrain concatenations of domains to be identical to each other. They are specified by providing the ```add_match_constraint``` with two lists of domains. The sum of the lengths of the domains in each list must be the same.


```python
design = Design()

design.add_domain('a','N'*10)
design.add_domain('b','N'*4)
design.add_domain('c','H'*6)
design.add_domain('d','N'*6)
design.add_domain('e','S'*2)

design.add_match_constraint(['c'], ['b', 'e*'])
design.add_match_constraint(['a', 'b'], ['d', 'd', 'e'])
```

### Complementarity constraint

Complementarity constraints are used to constraint the concatenation of one list of domains to be the reverse complement of the concatenation of another list of domains. Therefore, the sum of the lenghts of the domains in each list must be the same.

Currently only Watson-Crick complementarity constraints are allowed.

In addition to explicit domain list based specification of complementarity constraints, nucleotides that are base paired in the target structure of an on-target complex will have a complementarity constraint applied automatically once user specification is finished and the design algorithm begins.



```python
design.add_complementarity_constraint(['a', 'b'], ['c', 'd', 'e'])
```

### Similarity constraint

A similarity constraint forces either a domain or strand to match a reference sequence of the same length at a number of positions that falls in a specified range. As such, the constraint is specified using

* the name of the domain or strand
* a reference sequence of the same length as the domain or strand
* a fractional range, $[l, u]$, where $0 \leq l < u \leq 1$

A common use case of the similarity constraint is to constrain a domain or strand to have GC content in a certain range. In this case, the reference sequence is just the degenerate base code ```S``` repeated for the length of the domain / strand.


```python
design = Design()

design.add_domain('a','N'*10)
design.add_similarity_constraint('a', 'S'*5 + 'K'*5, [0.25, 0.75])


# "composition constraint" special case: enforce 45-55% GC content
design.add_domain('b','N'*20)
design.add_similarity_constraint('b', 'S'*20, [0.45, 0.55])
```

### Window constraint

A window constraint is used to constrain a concatenation of domains to have a sequence that is a substring of a given source sequence.
It is specified in two steps.
First, the source is defined by a name and a sequence.
Then, the constraint itself is specified by giving the list of domains to concatenate and the name of the source sequence.
The constraint can also allow the concatenated domains to have a sequence that is any window from several source sequences by giving a list of their names, instead of just one.


```python
design = Design()

design.add_domain('a', 'N'*10)
design.add_domain('b', 'N'*10)
design.add_domain('c', 'N'*10)
design.add_domain('e', 'N'*10)

design.add_source('GFP',
('auggugagcaagggcgaggagcuguucaccgggguggugcccauccuggu'
'cgagcuggacggcgacguaaacggccacaaguucagcguguccggcgagg'
'gcgagggcgaugccaccuacggcaagcugacccugaaguucaucugcacc'
'accggcaagcugcccgugcccuggcccacccucgugaccacccugaccua'
'cggcgugcagugcuucagccgcuaccccgaccacaugaagcagcacgacu'
'ucuucaaguccgccaugcccgaaggcuacguccaggagcgcaccaucuuc'
'uucaaggacgacggcaacuacaag').upper())

design.add_source('RFP',
('ccugcaggacggcgaguucaucuacaaggugaagcugcgcggcaccaacu'
'uccccuccgacggccccguaaugcagaagaagaccaugggcugggaggcc'
'uccuccgagcggauguaccccgaggacggcgcccugaagggcgagaucaa'
'gcagaggcugaagcugaaggacggcggccacuacgacgcugaggucaaga'
'ccaccuacaaggccaagaagcccgugcagcugcccggcgccuacaacguc'
'aacaucaaguuggacaucaccucccacaacgaggacuacaccaucgugga'
'acaguacgaacgcgccgagggccgccacuccaccggcggcauggacgagc'
'uguacaaguaa').upper())

# constrain window to be drawn from source
design.add_window_constraint(['a', 'b*'], 'GFP')
# OR constrain window to be drawn from more than once source
design.add_window_constraint(['c*', "e"], ['GFP', 'RFP'])
```

### Library constraint

A library constraint forces a domain, or concatenated list of domains, to have its sequence come from a fixed set of enumerated sequences of the same length. The constraint is specified in two steps. First, one or more libraries are defined by giving them a name and a list of sequences, all of the same length for a given library. Then, the constraint itself is specified by giving a domain or list of domains and a library or list of libraries. The sum of the lengths of the domains must equal the sum of the library lengths. The library length is the length of any of its sequences.


```python
design = Design()

design.add_domain('a', 'N'*6)
design.add_domain('b', 'N'*12)

# define a library of sequences
design.add_library('toeholds', ['CAGUGG', 'AGCUCG', 'CAGGGC'])

# define a library of codons for each amino acid
design.add_library('aaI', ['AUU', 'AUC', 'AUA'])
design.add_library('aaL', ['CUU', 'CUC', 'CUA', 'CUG', 'UUA', 'UUG'])
design.add_library('aaV', ['GUU', 'GUC', 'GUA', 'GUG'])
design.add_library('aaF', ['UUU', 'UUC'])
design.add_library('aaM', ['AUG'])
design.add_library('aaC', ['UGU', 'UGC'])
design.add_library('aaA', ['GCU', 'GCC', 'GCA', 'GCG'])
design.add_library('aaG', ['GGU', 'GGC', 'GGA', 'GGG'])
design.add_library('aaP', ['CCU', 'CCC', 'CCA', 'CCG'])
design.add_library('aaT', ['ACU', 'ACC', 'ACA', 'ACG'])
design.add_library('aaS', ['UCU', 'UCC', 'UCA', 'UCG', 'AGU', 'AGC'])
design.add_library('aaY', ['UAU', 'UAC'])
design.add_library('aaW', ['UGG'])
design.add_library('aaQ', ['CAA', 'CAG'])
design.add_library('aaN', ['AAU', 'AAC'])
design.add_library('aaH', ['CAU', 'CAC'])
design.add_library('aaE', ['GAA', 'GAG'])
design.add_library('aaD', ['GAU', 'GAC'])
design.add_library('aaK', ['AAA', 'AAG'])
design.add_library('aaR', ['CGU', 'CGC', 'CGA', 'CGG', 'AGA', 'AGG'])
design.add_library('aaSTOP', ['UAA', 'UAG', 'UGA'])


# domain a is drawn from the `toeholds' library
design.add_library_constraint('a', 'toeholds')

# domain b is drawn from a concatenation of library sequences representing codons
design.add_library_constraint(['b'], ['aaI', 'aaM', 'aaC', 'aaG'])
```

### Pattern prevention constraint

Pattern prevention constraints are used to prevent any subsequences of a given strand or domain from containing some fixed pattern sequence. This pattern sequence can be specified using degenerate base codes.

Because this constraint is frequently applied with many patterns to many elements of the design, and possibly all strands with in a design, the method ```add_pattern_constraints``` allows specifying multiple pattern constraints simultaneously. The first (required) argument is a single pattern or list of patterns to be prevented. The second (keyword) argument, ```names```, has three valid specifications:

* ```None``` or unspecified: the patterns are prevented in all strands in the design
* a single domain or strand name: the patterns are prevented in only this domain or strand.
* a list of domain or strand names: the patterns are prevented in every named domain or strand.


```python
design = Design()

design.add_domain('a', 'N'*12)
design.add_domain('b', 'N'*12)
design.add_strand('A', ['a', 'a*'])
design.add_strand('B', ['b', 'b*'])

# pattern prevention for a domain
design.add_pattern_constraints(['AAAA', 'UUUU'], names='a')

# pattern prevention for a strand
design.add_pattern_constraints(['AAAA', 'UUUU'], names='B')

# preventing the same patterns for strand `A' and domain `b'
design.add_pattern_constraints(['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], names=['A', 'b'])

# global pattern prevention
design.add_pattern_constraints(['AAAA', 'CCCC', 'GGGG', 'UUUU',
        'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'])
```

### Diversity constraint

New to NUPACK 4.0, diversity constraints represent a more efficient alternative to using pattern prevention constraints to ensure sequence diversity.
For instance, specifying the constraints that no AAAA, CCCC, GGGG, or UUUU should appear in a strand is equivalent to specifying the constraint that every length 4 window of the strand must have at least 2 nucleotide constraints within. When specified as a diversity constraint, both the intention is more clear and the CSP solver is able to more rapidly make sequence mutations.

Diversity constraints are specified by two numbers:

* The first is the window length to consider for the strand(s)/domain(s).
* The second is the minimum number of nucleotide types that must appear in every window of the above length

Following are the two method calls necessary to reproduce the global pattern prevention above.


```python
design.add_diversity_constraints(4, 2)
design.add_diversity_constraints(6, 3)
```

In the above examples, these diversity constraints are applied to all strands in the design.
Just like with pattern prevention constraints, diversity constraints can also be applied with one function call to a user-specified subset of domains or strands by adding a list of their names with the keyword ```names```.


```python
design.add_diversity_constraints(10, 4, names=['a', 'B'])
```


## Specifying objectives (including soft constraints)

### Multistate test tube ensemble defect

Design is accomplished primarily by minimizing the multistate test tube ensemble defect, $\mathcal{M}$. The code for adding this objective with a given stop condition follows.


```python
design.add_global_objective()
design.parameters.f_stop = 0.01 # always a number in (0,1)
```

If no objectives have been specified by the time running the design is requested, the design will add the multistate test tube ensemble defect automatically. The stop condition must still be set manually.

### Specifying pattern prevention soft constraint

Pattern prevention soft constraints are specified in nearly the same way as pattern prevention hard constraints.
The primary difference is that a weight can be supplied to control the relative design effort spent on the soft constraint.


```python
# pattern prevention for a domain
design.add_pattern_objective(patterns=['AAAA', 'UUUU'], names='a')

# pattern prevention for a strand
design.add_pattern_objective(patterns=['AAAA', 'UUUU'], names='B')

# preventing the same patterns for strand `A' and domain `b'
design.add_pattern_objective(patterns=['AAAAA', 'CCCCC', 'GGGGG', 'UUUUU'], names=['A', 'b'])

# global pattern prevention
# explicitly specify weight
design.add_pattern_objective(patterns=['AAAA', 'CCCC', 'GGGG', 'UUUU',
        'MMMMMM', 'KKKKKK', 'WWWWWW', 'SSSSSS', 'RRRRRR', 'YYYYYY'], weight=0.5)
```

### Specifying a similarity soft constraint

Similarity soft constraints are specified in nearly the same way as similarity hard constraints.
The primary difference is that a weight can be supplied to control the relative design effort spent on the soft constraint.


```python
design = Design()

design.add_domain('a','N'*10)
design.add_domain('b','N'*20)

design.add_similarity_objective('a', 'S'*5 + 'K'*5, [0.25, 0.75])

# explicitly specify weight
design.add_similarity_objective('b', 'S'*20, [0.45, 0.55], weight=0.25)
```

### Specifying a sequence symmetry soft constraint

Sequence symmetry soft constraints are specified with a list of complex names (or single complex name) to consider simultaneously.
This will penalize windows (i.e. n-grams, critons) that repeat spuriously (not explicitly constrained to be identical) and reverse complement windows that are not in full duplex regions.
Multiple sequence symmetry constraints with different window sizes can be specified for the same sets of complexes, as shown below.


```python
design = Design()

design.add_domain('a', 'N'*12)
design.add_domain('b', 'N'*12)
design.add_strand('A', ['a', 'a*'])
design.add_strand('B', ['b', 'b*'])

design.add_complex('C', ['A'], "(10.4)10")
design.add_complex('D', ['A', 'A'], "D12 +")

design.add_SSM_objective(['C', 'D'], 4, weight=0.15)

# the same complexes with larger windows weighted higher
design.add_SSM_objective(['C', 'D'], 5, weight=0.25)
design.add_SSM_objective(['C', 'D'], 6, weight=0.45)
```

### Specifying a duplex structure energy equalization constraint

Currently, the only structural motif that can be equalized is a perfect duplex.
This is specified by giving a list of domain names.
The soft constraint will then bias search toward sequences that for each domain ```a```, the duplex with complementary domain ```a*``` will approach the median of all the constrained duplexes.
A fixed reference energy can also be supplied through the ```energy``` keyword argument, which will try to force the duplex free energies to match that reference energy instead.


```python
# equalize to median value
design.add_energy_equalization_objective(['a', 'b'])

# equalize to reference value, with explicit weight
design.add_energy_equalization_objective(['a', 'b'], energy=-17, weight=0.5)
```

## Specifying weights

The user may wish to alter the relative weighting of defect contributions within the design objective function, $\mathcal{M}$, to prioritize or deprioritize design quality for a portion of the design ensemble. Custom defect weights can be defined for any level within the design ensemble (tube, complex, strand, domain), or for any combination of levels (specified coarser to finer with a period separating each level). Each weight takes a value in the interval $[0,\infty)$. By default, all weights are unity. Increasing the weight for a tube, complex, strand or domain will lead to a corresponding increase in the allocation of effort to designing this entity, typically leading to a corresponding reduction in the defect contribution of the entity. Likewise, decreasing the weight for a tube, complex, strand or domain will lead to a corresponding decrease in the allocation of effort to designing this entity, typically leading to a corresponding increase in the defect contribution of the entity. Weights specified at multiple levels within the ensemble are multiplicative (see Supplementary Information of the [multistate design paper](https://pubs.acs.org/doi/10.1021/jacs.6b12693) for details). With the default value of unity for all weights, $\mathcal{M}$ reduces to the multistate test tube ensemble defect, representing the average equilibrium fraction of incorrectly paired nucleotides over the design ensemble. With custom weights, the physical meaning of the objective function is distorted in the service of adjusting design priorities. The following script illustrates assignment of defect weights at different levels within the design ensemble:



```python
design = Design()

# domains
design.add_domain('a', 'N'*10)
design.add_domain('b', 'N'*10)
design.add_domain('c', 'N'*10)
design.add_domain('d', 'N'*10)

# strands
design.add_strand('A', ('a', 'b'))
design.add_strand('B', ('b', 'c'))
design.add_strand('C', ('c', 'd'))
design.add_strand('D', ('d', 'a'))

# complexes
design.add_complex('S1', ('A', 'B'), 'D20 +')
design.add_complex('S2', ('B', 'C'), 'D10 (U10+U10)')
design.add_complex('S3', ('C', 'D'), 'D20 +')
design.add_complex('S4', ('D', 'A'), 'D5 (U10 D5 + U10)')

# tubes
design.add_tube('T1', {'S1': 1.0e-9, 'S2': 1.0e-9})
design.add_tube('T2', {'S3': 1.0e-9, 'S4': 1.0e-9})

design.add_off_targets('T1', maxsize=2)
design.add_off_targets('T2', maxsize=2)

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
```

## Specifying algorithm parameters

The default design parameters are shown below. **TODO fill out**

- `rng_seed = 0`: random number generation seed
- `f_stop = 0.02`:  stop condition
- `f_passive = 0.01`:
- `H_split = 2`:
- `N_split = 12`:
- `f_split = 0.99 `:
- `f_stringent = 0.99`:
- `dG_clamp = -20`:
- `M_bad = 300`: number of bad
- `M_reseed = 50`:
- `M_reopt = 3`:
- `f_redecomp = 0.03`:
- `f_refocus = 0.03`:
- `cache_bytes_of_RAM = 0`:
- `min_ppair = 1e-05`:
- `slowdown = 0`:
- `log = None`:
- `decomposition_log = None`:
- `thermo_log = None`:
- `time_analysis = 1`:

They can be changed by assigning the named attribute. For example:

```python
design = Design()
design.parameters.M_reopt = 1
```

In addition to the multistate test tube design algorithm parameters, a few others are included in the `DesignParameters` object:

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

## Running the design

Running a design is done by using the ```Design``` object's function call operator, e.g. ```design()```.

```python
design = Design()

design.add_domain('a', 'N'*20)

design.add_strand('A', ['a'])
design.add_strand('B', ['a*'])

design.add_complex('C', ['A', 'B'], '(20+)20')

design.add_tube('tube', {'C': 1})
design.add_off_targets('tube', maxsize=0)

design.add_global_objective()

finished = design()

print("design defect:", finished.results[0].defects[0])
```

This example prints out `design defect: 0.0195444017648697`, indicating that the stop condition of 0.02 was met.

# Examples
**TODO make sure this public?**

The following cell imports functions from packages necessary for bokeh visualization of design progress and design results. The function ```run_and_display``` runs the design in a separate thread to allow visualization of design progress in the notebook during design. The function ```notebook_results``` takes a ```DesignResult``` object, saves it to a file (temporary or user specified), and the loads this file into an interactive panel for exploring design defects.


```python
from nupack.visualize import run_and_display
from nupack.residuals import notebook_results
```

## Design Evaluation Example (Example 7 from NUPACK 3.2 User Guide)

```python
from nupack import *
# set physical parameters
design = Design()
design.model = ModelSettings(material='rna06', temperature=(37 + 273.15))
design.parameters.seed = 93 # set seed to make design repeatable

# define domains
design.add_domain('a', 'N'*6)
design.add_domain('c', 'N'*8)
design.add_domain('b', 'N'*4)
design.add_domain('w', 'N'*2)
design.add_domain('y', 'N'*4)
design.add_domain('x', 'N'*12)
design.add_domain('z', 'N'*3)
design.add_domain('s', 'N'*5)

# define strands from domains
design.add_strand('Cout_s', ('w', 'x', 'y', 's',))
design.add_strand('A_s', ('c*', 'b*', 'a*', 'z*', 'y*',))
design.add_strand('A_toe_s', ('c*',))
design.add_strand('C_s', ('w', 'x', 'y', 's', 'a*', 'z*', 'y*', 'x*', 'w*',))
design.add_strand('C_loop_s', ('s', 'a*', 'z*',))
design.add_strand('B_s', ('x', 'y', 'z', 'a', 'b', ))
design.add_strand('Xs_s', ('a', 'b', 'c',))

# define complexes composed of one or more strands in a given order AND
# define target structures for each complex
design.add_complex('C', ('C_s',), 'D2 D12 D4( U5 U6 U3 )')
design.add_complex('B', ('B_s',), 'U12 U4 U3 U6 U4')
design.add_complex('C_loop', ('C_loop_s',), 'U14')
design.add_complex('A_B', ('A_s', 'B_s'), 'U8 D4 D6 D3 D4(+ U12)')
design.add_complex('X', ('Xs_s',), 'U18')
design.add_complex('X_A', ('Xs_s', 'A_s'), 'D6 D4 D8(+) U3 U4')
design.add_complex('C_out', ('Cout_s',), 'U23')
design.add_complex('B_C', ('B_s', 'C_s'), 'D12 D4 D3 D6 (U4 + U2 U12 U4 U5) U2')
design.add_complex('A_toe', ('A_toe_s',), 'U8')

# on-target tubes
design.add_tube('Step_0', {'C': 1e-08, 'X': 1e-08, 'A_B': 1e-08})
design.add_off_targets('Step_0', maxsize=2, explicit=[['A_s'], ['B_s']], exclude=[['X_A']])

design.add_tube('Step_1', {'X_A': 1e-08, 'B': 1e-08})
design.add_off_targets('Step_1', maxsize=2, explicit=[['X'], ['A_B']])
# design.add_off_targets('Step_1', maxsize=2, explicit=[['X'], ['A_B'], ['C']])

design.add_tube('Step_2', {'B_C': 1e-08})
design.add_off_targets('Step_2', maxsize=2, explicit=[['B'], ['C']])

# global orthogonality tube
design.add_tube('Crosstalk', {
    'A_B': 1e-08,
    'C': 1e-08,
    'X': 1e-08,
    'B': 1e-08,
    'C_out': 1e-08,
    'C_loop': 1e-08,
    'A_toe': 1e-08,
})
design.add_off_targets('Crosstalk', maxsize=2, exclude=[['X_A'], ['B_C'], ['Xs_s', 'A_toe_s'], ['B_s', 'C_loop_s']])

# GC content constraints
design.add_similarity_constraint('Cout_s', 'S'*23, (0.45, 0.55))
design.add_similarity_constraint('A_s', 'S'*25, (0.45, 0.55))
design.add_similarity_constraint('C_s', 'S'*50, (0.45, 0.55))
design.add_similarity_constraint('C_loop_s', 'S'*14, (0.45, 0.55))
design.add_similarity_constraint('B_s', 'S'*29, (0.45, 0.55))
design.add_similarity_constraint('Xs_s', 'S'*18, (0.45, 0.55))

# sources lines
tpm3 = ('gaacactattagctatttgtagtactctaaagaggactgcagaacgcatcgcagtagtgg'
'tgaaaagccgtgcgtgcgcgtgaaacatctgatcctcacgttacttccactcgctctgcg'
'tttgacttgttggcggggcgttggtgccttggacttttttttcctccttctcttcttcgc'
'ggctcggtccactacgctgctcgagaggaatctgctttattcgaccacactactcctaaa'
'gtaacacattaaaatggccggatcaaacagcatcgatgcagttaagagaaaaatcaaagt'
'tttacaacagcaagcagatgaggcagaagaaagagccgagattttgcagagacaggtcga'
'ggaggagaagcgtgccagggagcaggctgaggcagaggtggcttctctgaacaggcgtat'
'ccagctggttgaggaggagttggatcgtgctcaggagagactggccacagccctgcaaaa'
'gctggaggaagccgagaaggccgcagatgagagcgagagagggatgaaggtgattgagaa'
'cagggctctgaaggatgaggagaagatggagctgcaggagatccagcttaaggaggccaa').upper()

design.add_source('tpm3', tpm3)
design.add_window_constraint(('a', 'b', 'c'), 'tpm3')

desm = ('catttacacagcgtacaaacccaacaggcccagtcatgagcacgaaatattcagcctccg'
'ccgagtcggcgtcctcttaccgccgcacctttggctcaggtttgggctcctctattttcg'
'ccggccacggttcctcaggttcctctggctcctcaagactgacctccagagtttacgagg'
'tgaccaagagctccgcttctccccatttttccagccaccgtgcgtccggctctttcggag'
'gtggctcggtggtccgttcctacgctggccttggtgagaagctggatttcaatctggctg'
'atgccataaaccaggacttcctcaacacgcgtactaatgagaaggccgagctccagcacc'
'tcaatgaccgcttcgccagctacatcgagaaggtgcgcttcctcgagcagcagaactctg'
'ccctgacggtggagattgagcgtctgcggggtcgcgagcccacccgtattgcagagctgt'
'acgaggaggagatgagagagctgcgcggacaggtggaggcactgaccaatcagagatccc'
'gtgtggagatcgagagggacaacctagtcgatgacctacagaaactaaagctcagacttc').upper()

design.add_source('desm', desm)
design.add_window_constraint(('w', 'x', 'y', 'z'), 'desm')

# Prevented patterns
design.add_pattern_constraints(['AAAA','CCCC','GGGG','UUUU'])

# Global stop condition
design.parameters.f_stop = 0.1

results = run_and_display(design)
```


```python
results.running()
```

    True

```python
res = results.result()
notebook_results(res)
```

## Design Evaluation Example (Example 8 from NUPACK 3.2 User Guide)


```python
design = Design()

# set physical properties
design.model = ModelSettings(material='RNA', temperature=(23+273.15))

# define domains
design.add_domain('a', 'ACCUCCAAGCACAACUGUGGCCCCAUA')
design.add_domain('b', 'GGGGCCGGAUUACAACUUUCCCUGUGAAC')
design.add_domain('c', 'AUCACAGACAGUUAACCACUUGAGG')
design.add_domain('d', 'AUCAAGUGGGCUUGGAGC')

# define strands from domains
design.add_strand('left', ('a',))
design.add_strand('top', ('b',))
design.add_strand('right', ('c',))
design.add_strand('bottom', ('d',))

# define complex compsed of strands in a given order AND
# Define target structure for complex
design.add_complex('stickfigure', ('left', 'top', 'right', 'bottom'),
        "U2D8(U2D6(D6(U3+)D3U9D6(U2+U1))U2D8(U2+U1))U1")

# define test tube
design.add_tube('figuretube', {'stickfigure': 1e-6})
design.add_off_targets('figuretube', maxsize=3)

# add objective to evaluate
design.add_global_objective()

# evaluate
result = design.evaluate()

# show multistate test tube ensemble defect
notebook_results(result)
```

# Saving and restarting a Design

When "calling" the design to start the optimization process, two additional arguments must be added for checkpointing to work, `checkpoint_condition` and `checkpoint_handler`.

`checkpoint_condition` is a binary function that receives the stats and timer object from the C++ `Designer` object after steps in the design. The logic in `checkpoint_condition` then uses this information to determine whether a checkpoint should be made, in which case it returns True. In the call below, it is set to an object of an included class, `TimeInterval`. If `checkpoint_condition` is set to an object `TimeInterval(n)`, then a checkpoint will be emitted roughly every n seconds.

`checkpoint_handler` is the function which actually does something given that `checkpoint_condition` returns `True`. `checkpoint_handler` takes one argument, a Result object, and decides how it will use this information. In the call below, it is set to an object of the included class, `WriteToFileCheckpoint`. This type of `checkpoint_handler` object is instantiated with a filename prefix ("design_test" below) and will convert the design Result object into JSON and serialize it to a file with the given prefix and a time stamp, e.g. design_test-2020-01-27T00:16:52.170292.out


```python
from nupack.design import TimeInterval, WriteToFileCheckpoint

result = design(checkpoint_condition=TimeInterval(1), checkpoint_handler=WriteToFileCheckpoint("design-checkpoint"))
print(result)
```

    DesignResult
        model: ModelKey {parameters: ParameterFile {path: rna95.json}, ensemble: stacking, conditions: ModelConditions {temperature: 296.15, na_molarity: 1, mg_molarity: 0}}
        parameters: DesignParameters {rng_seed: 841912177, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        stats: DesignStats {num_leaf_evaluations: 1, num_reseeds: 0, num_redecompositions: [], offtargets_added_per_refocus: [], design_time: 0.924277, analysis_time: 0.807128, final_Psi: EnsemblePartition {mask: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], deflate: 0.0002}}
        objectives: [Objective {variant: MultitubeObjective()}]
        results: [SingleResult
                domains: {(a : ACCTCCAAGCACAACTGTGGCCCCATA), (a* : TATGGGGCCACAGTTGTGCTTGGAGGT), (b : GGGGCCGGATTACAACTTTCCCTGTGAAC), (b* : GTTCACAGGGAAAGTTGTAATCCGGCCCC), (c : ATCACAGACAGTTAACCACTTGAGG), (c* : CCTCAAGTGGTTAACTGTCTGTGAT), (d : ATCAAGTGGGCTTGGAGC), (d* : GCTCCAAGCCCACTTGAT)}
                strands: {(bottom : ATCAAGTGGGCTTGGAGC), (left : ACCTCCAAGCACAACTGTGGCCCCATA), (right : ATCACAGACAGTTAACCACTTGAGG), (top : GGGGCCGGATTACAACTTTCCCTGTGAAC)}
                complexes: [ComplexResult
                        name: stickfigure
                        sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG, ATCAAGTGGGCTTGGAGC]
                        structure: Structure(".2(8.2(12.3+)6(3.9)3(6.2+.)12.2(8.2+.)16.")
                        log_partition_function: 129.151
                        defect: 0.652198
                        normalized_defect: 0.00658786,
                    ComplexResult {name: bottom, sequence: [ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 8.71314, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 30.7563, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-bottom, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 48.0926, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-left, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 66.5632, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 59.227, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-top, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 52.2993, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 46.5626, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-left, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 67.6208, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-right, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 75.0568, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-top, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 82.4741, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 39.3921, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-left, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 58.8139, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 55.6661, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-top, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 55.3148, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 32.1384, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-left, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 65.7289, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-right, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 68.1066, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-top, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 58.2446, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 9.23003, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 27.609, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 45.8795, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 53.9845, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 65.7507, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 31.2484, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 50.2585, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 57.7334, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 48.3159, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 85.177, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 71.143, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right, sequence: [ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 6.57108, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 26.0572, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right-right, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 42.6987, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 54.1083, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 35.525, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-top-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 64.0134, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 13.5486, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top-top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 40.0906, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top-top-top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 62.0574, defect: 0, normalized_defect: 0}]
                tubes: [TubeResult
                        name: figuretube
                        nucleotide_concentration: 9.9e-05
                        defect: 6.8218e-07
                        normalized_defect: 0.00689071
                        complexes: [TubeComplex {name: stickfigure, concentration: 9.99695e-07, target_concentration: 1e-06, defect: 6.8218e-07, structural_defect: 6.51999e-07, concentration_defect: 3.0181e-08, normalized_defect_contribution: 0.00689071},
                            TubeComplex {name: bottom, concentration: 1.67614e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom, concentration: 3.13566e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-bottom, concentration: 5.29885e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-left, concentration: 2.9797e-17, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-right, concentration: 2.43844e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-top, concentration: 2.3401e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left, concentration: 1.22811e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-left, concentration: 4.5896e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-right, concentration: 9.77726e-13, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-top, concentration: 1.59333e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right, concentration: 1.1862e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-left, concentration: 8.63038e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-right, concentration: 4.65574e-19, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-top, concentration: 3.20779e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top, concentration: 8.21711e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-left, concentration: 8.51105e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-right, concentration: 1.1524e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-top, concentration: 5.8804e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left, concentration: 1.50351e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left, concentration: 3.85581e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-left, concentration: 8.87101e-29, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-right, concentration: 3.68937e-23, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-top, concentration: 4.6533e-21, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right, concentration: 1.84373e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right-right, concentration: 1.11636e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right-top, concentration: 1.92702e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top, concentration: 4.6644e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top-right, concentration: 1.59777e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top-top, concentration: 1.25726e-19, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right, concentration: 1.3224e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right, concentration: 1.28881e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right-right, concentration: 7.30523e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right-top, concentration: 6.45021e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-top, concentration: 1.63237e-15, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-top-top, concentration: 1.26505e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top, concentration: 1.38822e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top-top, concentration: 1.53616e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top-top-top, concentration: 1.75159e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}]]
                defects: [0.00689071]
                weighted_defects: [0.00689071]]
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: [1]}
        success: 1


## Saving the final design outputs in a text file


```python
with open('design-output.json', 'w') as f:
    f.write(result.to_json(indent=4))
```

## Running from a checkpoint file
The following lines of code will run a design using the final output as a checkpoint file. The argument restart must be a python design `Result` object, in this case loaded from a file containing a valid JSON representation of a `Result` object.


```python
from nupack.design import Result
newer_result = design(restart=Result(json_file="design-output.json"))
```


```python

```
