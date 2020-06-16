# Sequences

Nucleic acid sequences are listed $5'$ to $3'$.
<!-- Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1. -->
Unlike NUPACK 3, bases in NUPACK 4 are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand.
For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39.

Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.
A sequence may also contain any of the [degenerate nucleotides codes](https://www.bioinformatics.org/sms/iupac.html): `R`, `M`, `S`, `W`, `K`, `Y`, `V`, `H`, `D`, `B`, or `N`. Such sequences are primarily useful in a design context, and any sequence used in analysis must be fully determined.

## Specifying a sequence

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