# Basics

## Sequences

Nucleic acid sequences are listed $5'$ to $3'$.
<!-- Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1. -->
Unlike NUPACK 3, bases in NUPACK 4 are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand.
For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39.

Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.
A sequence may also contain any of the [degenerate nucleotides codes](https://www.bioinformatics.org/sms/iupac.html): `R`, `M`, `S`, `W`, `K`, `Y`, `V`, `H`, `D`, `B`, or `N`. Such sequences are primarily useful in a design context, and any sequence used in analysis must be fully determined.

### Specifying a sequence

A `Sequence` is specified by valid nucleotide letters, which can contain wildcards.  Run-length encoding may be used to specify repeats of a given nucleotide. For RNA, `'U'` is automatically replaced by `'T'` for printing purposes.

```python
s1 = Sequence('AAAAATTTTT')
s2 = Sequence('A5T5')
s3 = Sequence('A5U5')

s1 == s2 # --> True
s1 == s3 # --> True
s3 # --> Sequence('AAAAATTTTT')
```

You can access the reverse complement of a `Sequence` using the following syntaxes:

```python
reverse_complement(s1) # --> Sequence('TTTTTAAAAA')
~s1 # --> Sequence('TTTTTAAAAA')
```

The `~a` syntax is generally recommended for brevity. Thus `~a` corresponds to the usual complement specification `a*` (unfortunately, the latter is not valid Python).






## Secondary structures

### Conventions

Secondary structures may be specified in one of three ways:

1. **dot-parens-plus notation**: Each unpaired base is represented by a dot, each base pair by matching parentheses, and each nick between strands by a plus [@Zadeh11a]. For example, `((...))` specifies that bases 0 and 1 are paired to bases 6 and 5, respectively, while bases 2, 3, and 4 are unpaired. `((+...))` specifies that bases 0 and 1 of strand 0 are paired to bases 4 and 3 of strand 1.

2. **run-length encoded dot-parens-plus notation**: As a shorthand for dot-parens-plus, any sequence of consecutive characters in dot-parens-plus may be replaced by the character followed by a number. For instance, `(((((+...........)))))`  may be written as `(5+.11)5`.

3. **DU+ notation**: Using DU+ notation, a duplex is represented by `D` and an unpaired region of length nucleotides is represented by `U` [@Zadeh10c]. Each duplex is followed immediately by the substructure (specified in DU+ notation) that is 'enclosed' by the duplex. If this substructure includes more than one element, parentheses are used to denote scope. A nick between strands is specified by a '+'. See the table below for examples.

<!-- 4. **pair list notation**: A list of zero-based indices $p$ such that if $p_i = j$, bases $i$ and $j$ are paired, and if $p_i = i$, base $i$ is unpaired. Any secondary structure, including highly-nested pseudoknots, may be specified in this way. -->

| Dot-parens-plus                       | RLE dot-parens-plus  | DU+ notation |
| ------------------------------------- | -------------------  | ------------ |
| `((((((((((((..........))))))))))))`  |  `(12.10)12`         | `D12 U10`    |
| `((((((((((((+))))))))))))..........` |  `(12+)12.10`        | `D12 + U10`  |
| `((((((((((((+..........))))))))))))` |  `(12+.10)12`        |`D12 (+ U10)` |

**Table:** Examples of dot-parens-plus, run-length-encoded (RLE) dot-parens-plus, and DU+ notation

<img src="/figs/structure.png" alt="Secondary structure" title="Example secondary structure" width="650" />

**Figure:** Comparison of dot-parens-plus, run-length-encoded dot-parens-plus, and DU+ notation.


### PairList

Under the hood, secondary structures are stored in NUPACK using the `PairList` object.
A pair list contains a list of zero-based indices $p$ such that if $p_i = j$, bases $i$ and $j$ are paired, and if $p_i = i$, base $i$ is unpaired.
Any secondary structure, including highly-nested pseudoknots, may be specified in this way.
(However, NUPACK 4 currently includes no functionality for analyzing pseudoknots.)

A `PairList` may be created using the following syntaxes in Python:

```python
s1 = PairList('((((((((((((+..........))))))))))))')
s2 = PairList('(12+.10)12')
s3 = PairList('D12 (+ U10)')
```

### Structure

You might notice that the pair list specification does not include any information on structure nicks.
This can be inconvenient when printing a `PairList`.
As a result, NUPACK provides a `Structure` class, which simply contains a `PairList` and list of nicks as the following member:

1. `pairs`: a `PairList` of the base pairs in a given structure such that `pairs[i] == j` if the bases of zero-based index `i` and `j` are paired, and `pairs[i] == i` if the base of index `i` is unpaired.

2. `nicks`: a list of indices where each integer is the (zero-based) index of a base after a strand break

```python
s = Structure(PairList([5,4,3,2,1,0]), nicks=[3])
print(s.dp())          # --> (((+)))
print(s.pairs.array()) # --> [5 4 3 2 1 0]
```





## Named objects

The remaining objects accept a first argument of `name` to be specified by the user.

!!!note "Note"
    The name may specified as a `tuple` or `list` instead of a `str`, in which case a `'[]'` based string will be automatically generated. This is specifically useful for repeated definitions:

    ```python
    domains = [Domain(['a', i], 'N6') for i in range(4)]
    print([d.name for d in domains]) # --> ['a[0]', 'a[1]', 'a[2]', 'a[3]']
    ```

Note that for text formatting, the following behavior has been implemented on the following objects:

- `str()` prints the value of the object
- `repr()` prints an expression which is equivalent to the one used to construct the object

For example:

```python
s = Domain('a', 'N6')
print(s) # --> NNNNNN
print(repr(s)) # --> Domain('a', 'NNNNNN')
```

!!! note
    In general, you should make every user-specified name is required to be unique. Uniqueness should hold across different classes of objects (`Domain`, `Strand`, etc.).

### Domain

A domain is a fixed-length sequence of nucleotides, primarily useful in a design context. A domain may be created from a name and `Sequence` (or sequence string).

```python
a = Domain('a', 'ATCGTAGCTA')
b = Domain('b', 'ATATSSSKKN') # Wildcards are permitted
```

You can access the reverse complement of a `Domain` as you would a `Sequence`, e.g. as `~a`.

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

!!!todo
    Note: when a domain ```x``` is added, the reverese complement domain ```x*``` is added as well, with a sequence of N's of the same length as ```x```. Despite this seeming like ```x*``` is free to be any nucleotide, complementarity constraints are added during design initialization to ensure that whatever sequence ```x``` takes, ```x*``` will be its reverse complement. However, A more specific sequence for ```x*``` can be defined as in the following example.


### Strand

A strand representes a single physical strand of RNA or DNA. A strand may be initialized either from a single sequence or from a list of domains:

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

### Complex

A complex may be created from an ordered list of strands. Unlike the other named objects, the name for a `Complex` is optional and may be omitted:

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

### Tube

A `Tube` is a collection of interacting strands, each at a user-specified concentration. A `Tube` may be created from a set of strands with specified concentrations. Complexes may be explicitly included via the keyword `include`. All complexes of up to size `n` may be included by specifying `max_size=n` (`max_size` defaults to 1). Complexes may be specifically excluded from the automatically generated set via the `exclude` keyword.

```python
t1 = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8])
t2 = Tube('t2', strands=[A, B, C], concentrations=[1e-6, 1e-8, 1e-12], include=[c2], max_size=3, exclude=[c1])
```

For convenience, the concentrations may be left out, in which case the strands may be given without concentrations:

```python
t3 = Tube('t3', strands=[A, B], include=[c2], max_size=3, exclude=[c1])
```

A tube only compares equal to itself if it is the same Python object

```python
t1a = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])
t1b = Tube('t1', strands=[A, B], concentrations=[1e-6, 1e-8], max_size=3, exclude=[c1])

t1a == t1b # --> False
t1a == t1a # --> True
```

