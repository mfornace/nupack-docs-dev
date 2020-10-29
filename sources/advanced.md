# Advanced

## Parallelism

By default, NUPACK 4 uses a single CPU core for each [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs). For example, a call to `tube_analysis` will use 1 core, whereas a call to `tube_design` with `trials=4` will use 4 cores (up to the number of logical cores on the machine). Additional parallelism may be enabled using the `config.parallelism` flag (default `False`):

```python
from nupack import *
config.parallelism = True
```

If this flag is set to `True`, then NUPACK jobs will be permitted to use all available cores on your machine. This type of parallelism enables:

- **Block-level parallelism**. Subcomplex blocks in the dynamic program will be calculated in parallel (e.g., triangular blocks `A`, `B`, `C`, and rectangular blocks `AB`, `BC`, and `ABC` for complex `ABC`; see Figure 8 of [@Fornace20]). This mode of parallelism will be enabled for all complexes in a multi-tube ensemble.

- **Element-level parallelism**. Subsequence elements will be calculated in parallel within a subcomplex block. This mode of parallelism will only be employed for subcomplex blocks containing at least 128 nt.


## Caching

NUPACK 4 introduces subcomplex block caching to achieve dramatic speedups by avoiding recalculation of subcomplex intermediates for a multi-tube ensemble (see Figure 8 of [@Fornace20]). The `config.cache` flag (GB; default 2.0) controls the gigabytes of memory that *each* [analysis job](analysis.md#analysis-jobs), [design trial](design.md#design-jobs), or [utilities job](utilities.md#utilities-jobs) can use.

```python
from nupack import *
config.cache = 8.0 # GB
```

This flag may be set to `0.0` to disable caching if your hardware has very little memory.


## Object naming

Objects of type `Domain`, `Strand`, `TargetStrand`, `TargetComplex`, `Tube`, and `TargetTube` all accept a keyword argument of `name` to be specified by the user.

!!!note "Note"
    The name may specified as a `tuple` or `list` instead of a `str`, in which case a `'[]'` based string will be automatically generated. This is specifically useful for repeated definitions:

    ```python
    domains = [Domain('N6', name=['a', i]) for i in range(4)]
    print([d.name for d in domains]) # --> ['a[0]', 'a[1]', 'a[2]', 'a[3]']
    ```

Note that for text formatting, the following behavior has been implemented on the following objects:

- `str()` prints the value of the object
- `repr()` prints a `<...>` expression similar to other standard python classes

For example:

```python
s = Domain('N6', name='a')
print(str(s)) # --> NNNNNN
print(repr(s)) # --> <Domain a>
```

!!! note
    In general, you should make every user-specified name unique. Uniqueness should hold across different classes of objects (`Domain`, `Strand`, etc.).

## Multi-system designs

!!! warn
    Elaborate more

In this section we walk through a simplified multitube design for two Dicer scRNA systems as described in [@Hochrein13]. First, we can initialize global parameters for the design:

```python
# Specify source RNA for window constraints
my_model = Model(material='rna', celsius=37) # set physical parameters
crosstalkTargets = {} # empty crosstalk tube targets
crosstalkExcludes = [] # empty crosstalk tube excludes
tubes = [] # empty set of tubes
systems = 2 #set number of systems
```

Next, we can iterate through each of the systems to define its components:

```python
for i in range(systems):

    # define domains
    a = Domain('N6', name=['a', i])
    c = Domain('N8', name=['c', i])
    b = Domain('N4', name=['b', i])
    w = Domain('N2', name=['w', i])
    y = Domain('N4', name=['y', i])
    x = Domain('N12',name=['x', i])
    z = Domain('N3', name=['z', i])
    s = Domain('N5', name=['s', i])

    # define strands from domains
    Cout_s   = TargetStrand([w, x, y, s], name=['Cout_s', i])
    A_s      = TargetStrand([~c, ~b, ~a, ~z, ~y], name=['A_s', i])
    A_toe_s  = TargetStrand([~c], name=['A_toe_s', i])
    C_s      = TargetStrand([w, x, y, s, ~a, ~z, ~y, ~x, ~w], name=['C_s', i])
    C_loop_s = TargetStrand([s, ~a, ~z], name=['C_loop_s', i])
    B_s      = TargetStrand([x, y, z, a, b], name=['B_s', i])
    Xs_s     = TargetStrand([a, b, c], name=['Xs_s', i])

    # define complexes composed of one or more strands in a given order AND
    # define target structures for each complex
    C      = TargetComplex([C_s],       'D2 D12 D4( U5 U6 U3 )', name=['C', i])
    B      = TargetComplex([B_s],       'U12 U4 U3 U6 U4', name=['B', i])
    C_loop = TargetComplex([C_loop_s],  'U14', name=['C_loop', i])
    A_B    = TargetComplex([A_s, B_s],  'U8 D4 D6 D3 D4(+ U12)', name=['A_B', i])
    X      = TargetComplex([Xs_s],      'U18', name=['X', i])
    X_A    = TargetComplex([Xs_s, A_s], 'D6 D4 D8(+) U3 U4', name=['X_A', i])
    C_out  = TargetComplex([Cout_s],    'U23', name=['C_out', i])
    B_C    = TargetComplex([B_s, C_s],  'D12 D4 D3 D6 (U4 + U2 U12 U4 U5) U2', name=['B_C', i])
    A_toe  = TargetComplex([A_toe_s],   'U8', name=['A_toe', i])

    # on-target tubes
    Step_0 = TargetTube({C: 1e-08, X: 1e-08, A_B: 1e-08}, max_size=2, include=[[A_s], [B_s]], exclude=[X_A], name=['Step_0', i])

    Step_1 = TargetTube({X_A: 1e-08, B: 1e-08}, max_size=2, include=[X, A_B], name=['Step_1', i])

    Step_2 = TargetTube({B_C: 1e-08}, max_size=2, include=[B, C], name=['Step_2', i])

    # Crosstalk tube elements
    crosstalkTargets.update({
        A_B: 1e-08,
        C: 1e-08,
        X: 1e-08,
        B: 1e-08,
        C_out: 1e-08,
        C_loop: 1e-08,
        A_toe: 1e-08,
    })

    crosstalkExcludes += [X_A, B_C, [Xs_s, A_toe_s], [B_s, C_loop_s]]

    # Add tubes
    tubes += [Step_0, Step_1, Step_2]

crosstalk = TargetTube(crosstalkTargets, max_size=2, exclude=crosstalkExcludes, name='crosstalk')
```

Finally, we can create a design containing all of the reaction pathway tubes:

```python
my_design = tube_design(tubes + [crosstalk], model=my_model)
```

The design may be run as described in the [design documentation](design.md#run-a-test-tube-design-job). See the example notebook `multisystem-design-dicer.ipynb` for a complete example.
