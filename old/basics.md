



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

<hr> </hr>




<hr> </hr>

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

You can print a `PairList` to view its raw data:

```python
s = PairList('(...)')

s          # --> PairList([4, 1, 2, 3, 0])
print(s)   # --> [4 1 2 3 0]
```

Or you can access its data and calculating its corresponding structure matrix:

```python
s.array()  # --> array([4, 1, 2, 3, 0], dtype=int32)

s.structure_matrix() # --> array([[0, 0, 0, 0, 1],
                     #            [0, 1, 0, 0, 0],
                     #            [0, 0, 1, 0, 0],
                     #            [0, 0, 0, 1, 0],
                     #            [1, 0, 0, 0, 0]], dtype=int32)
```

<hr> </hr>

### Structure

You might notice that the pair list specification does not include any information on structure nicks.
This can be inconvenient when printing a `PairList`.
As a result, NUPACK provides a `Structure` class, which simply contains a `PairList` and list of nicks as the following member:

1. `pairs`: a `PairList` of the base pairs in a given structure such that `pairs[i] == j` if the bases of zero-based index `i` and `j` are paired, and `pairs[i] == i` if the base of index `i` is unpaired.

2. `nicks`: a list of indices where each integer is the (zero-based) index of a base after a strand break

```python
s = Structure('(((+)))')
s                      # --> Structure('(((+)))')
print(s)               # --> (((+)))
print(s.pairs.array()) # --> [5 4 3 2 1 0]
```



<hr> </hr>

## Named objects

The remaining core objects accept a first argument of `name` to be specified by the user.

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
    In general, you should make every user-specified name unique. Uniqueness should hold across different classes of objects (`Domain`, `Strand`, etc.).

<hr> </hr>

### Domain

A domain is a fixed-length sequence of nucleotides, primarily useful in a design context. It reflects a shared sequence that may appear multiple times in different strands. A domain may be created from a name and `Sequence` (or sequence string).

```python
a = Domain('a', 'ATCGTAGCTA')
b = Domain('b', 'ATATSSSKKN') # Wildcards are permitted
```

You can access the reverse complement of a `Domain` as you would a `Sequence`, e.g. as `~a`. In design, the invariant is maintained that the currently specified sequence of `a` is reverse complement to that of `~a`.

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

<hr> </hr>

<hr> </hr>

## Using the model

Typically a `Model` will be used as an input to dynamic programming algorithms (see [Analysis](analysis.md) and [Design](design.md)).
However, a `Model` also contains a few useful methods (below) to analyze individual secondary structures.

First, one can calculate the free energy of a single loop defined by an ordered list of bounding sequences `sequences`. To specify an exterior loop, specify `nick` as the zero-based index of the strand that follows the strand break:

```python
energy1 = model.loop_energy(['AA', 'TT']) # stack energy
energy2 = model.loop_energy(['AA', 'TT'], nick=1) # energy of stack with an intervening strand break
energy3 = model.loop_energy(['AATT'], nick=0) # energy of unpaired AATT strand
```

One may also calculate the free energy of a complex of ordered strands in a secondary structure structure:

```python
energy = model.structure_energy(['AAAA', 'TTTT'], '((((+))))')
```


## References
