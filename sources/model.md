# Model Specification

<hr>


## Specify a physical model

NUPACK 4 analysis and design jobs are run based on a physical model created using the `Model` class:

```python
model1 = Model(material='rna', ensemble='stacking', celsius=37,
    sodium=1.0, magnesium=0.0)
```


Any unspecified properties take on their default values (which happen to be the ones specified for `model1` above).



<hr>




## Model options
The valid options for each property are described below.

### Material

NUPACK 4 algorithms use the following temperature-dependent RNA and DNA free energy parameter sets specified by the keyword `material` (default: `material='rna'`):

- `rna06` (shorthand: `rna`)
Based on [@Mathews99] and [@Lu06] with additional parameters [@Xia98,@Zuker03] including coaxial stacking [@Mathews99,@Turner10] and dangle stacking [@Serra95,@Zuker03,@Turner10] in 1M Na$^+$.

- `rna95`
Based on [@Serra95] with additional parameters [@Zuker03] including coaxial stacking [@Mathews99,@Turner10] and dangle stacking [@Serra95,@Zuker03,@Turner10] in 1M Na$^+$.

- `dna04` (shorthand: `dna`)
Based on [@Santalucia98] and [@Santalucia04] with additional parameters [@Zuker03]
including coaxial stacking [@Peyret00] and dangle stacking [@Bommarito00,@Zuker03]
in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@Santalucia98,@Peyret00,@Santalucia04].

- `custom-parameters`
Custom parameters provided in a JSON file (e.g., `custom-parameters.json`) using the same format as the provided parameter files. Provide $\Delta G_{37}(\mathrm{loop})$ and $\Delta H(\mathrm{loop})$ values to allow calculations at different temperatures or only $\Delta G(\mathrm{loop})$ values to allow calculations at one temperature. Place the JSON file in the same directory as the default parameter files (specify `material = 'custom-parameters'`) or specify the full path to the file (`material = 'path/to/my/custom-parameters.json'`).

Free energies are expressed in kcal/mol. Base pairs are either Watson-Crick pairs (`G`$\cdot$ `C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA). Note that for DNA, `G` and `T` form a mismatch and not a wobble pair [@Santalucia04].

DNA/RNA hybrids are not allowed.

<hr>


### Stacking

NUPACK 4 algorithms perform calculations on the following complex ensembles specified by the keyword `ensemble` (default: `ensemble='stacking'`):

- `stacking`
Complex ensemble with coaxial and dangle stacking (ensemble $\overline\Gamma^\shortparallel(\phi)$).

- `nostacking`
Complex ensemble without coaxial and dangle stacking (ensemble $\overline\Gamma(\phi)$).



<hr>

### Temperature

- `celsius`
Temperature is specified in $^\circ$C using the keyword `celsius` (default: `celsius=37`).
- `kelvin`
Alternatively, the temperature can be specified in K using the keyword `kelvin`.

<hr>

### Salt

The default salt conditions for RNA and DNA parameter sets are $[\mathrm{Na}^+] = 1 {\rm M}$; these are the only salt conditions for RNA. Salt corrections are available for DNA parameters to permit calculations in user-specified sodium, potassium, ammonium, and magnesium ion concentrations.

- `sodium`
Based on [@Santalucia98,@SantaLucia04] the sum of the concentrations of (monovalent) sodium, potassium, and ammonium ions, $[{\rm Na}^+] + [\mathrm{K}^+] + [\mathrm{NH}_4^+]$, is specified in units of molar (default: 1.0, range: \[0.05,1.1\]) using the keyword `sodium`.

- `magnesium`
Based on [@Peyret00,@Koehler05] the concentration of (divalent) magnesium ions, $[{\rm Mg}^{++}]$, is specified in units of molar (default: 0.0, range: \[0.0,0.2\]) using the keyword `magnesium`.

<hr>

<!-- ### Wobble pairs

G$\cdot$U RNA wobble pairs are enabled by default in the provided RNA parameter sets.
G$\cdot$T DNA wobble pairs are disabled by default in the provided DNA parameter set.
However, wobble pairs may be manually enabled or disabled using the additional `wobble` parameter during model construction (e.g. `Model(..., wobble=True)`).
In the historical ensembles, a duplex terminated by a wobble pair is forbidden.


<hr>  -->




!!!example "Examples"
    - Define a model for DNA calculations at 23 $^\circ$C in $[{\rm Na}^{+}]= 0.5$ M and $[{\rm Mg}^{++}]= 0.01$ M:

    ```python
    model2 = Model(material='dna', celsius=23, sodium=0.5, magnesium=0.01)
    ```
    Note that `ensemble` is unspecified so it defaults to `ensemble='stacking'`.

    - Define a model using custom parameters at 45 $^\circ$C without coaxial and dangle stacking:

    ``` python
    model3 = Model(material='path/to/my/custom-parameters.json',
        ensemble='nostacking', celsius=45)
    ```


### Historical options


For backwards compatibility with NUPACK 3, the following historical complex ensembles without coaxial stacking and with approximate dangle stacking are supported:

- `none-nupack3`
No dangle stacking and no coaxial stacking (dangles `none` option for NUPACK 3)

- `some-nupack3`
Some dangle stacking and no coaxial stacking (dangles `some` option for NUPACK 3). A dangle energy is incorporated for each unpaired base flanking a duplex (a base flanking two duplexes contributes only the minimum of the two possible dangle energies).

- `all-nupack3`
All dangle stacking and no coaxial stacking (dangles `all` option for NUPACK 3). A dangle energy is incorporated for each unpaired base flanking a duplex (a base flanking two duplexes contributes both possible dangle energies).

For these historical ensembles, base pairs are either Watson-Crick pairs (`G`$\cdot$`C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA; `G`$\cdot$`T` for DNA). Note that for the historical ensembles, `G`$\cdot$`T` is classified as a DNA wobble pair and not as a mismatch. The historical ensembles prohibit a wobble pair (`G`$\cdot$`U` or `G`$\cdot$`T`) as a terminal base pair in an exterior loop or a multiloop. As a result, an attempt to evaluate a free energy for a sequence $\phi$ and secondary structure $s$ that place a wobble pair as a terminal base pair in an exterior loop or multiloop will return $\overline{\Delta G}(\phi,s)=\Delta G(\phi,s) = \infty$. These historical ensembles can be used for calculations in combination with the following historical DNA and RNA parameter sets:

- `rna95-nupack3`
Same as `rna95` except that terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies.

- `dna04-nupack3`
Same as `dna04` except that G$\cdot$T was treated as a wobble pair (analogous to a `G`$\cdot$`U` RNA wobble pair) instead of classifying `G` and `T` as a mismatch. Note that while terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies, this is the same treatment as in `dna04`, as terminal mismatch parameters are not public for DNA [@Santalucia04].

- `rna99-nupack3`
Parameters from [@Mathews99] with terminal mismatch free energies in exterior loops and multiloops replaced by two dangle stacking free energies. Parameters are provided only for 37 $^\circ$C.


## Compute loop free energy
The `loop_energy` method operates on a `Model` object to calculate the [loop free energy](definitions.md#loop-free-energies) in kcal/mol. The loop sequence is specified with keyword `loop` and the loop structure is specified with keyword `structure`. For example:

```python
my_model = Model(material='RNA', ensemble='stacking')

#Calculate the free energy of an unstructured strand
dGloop2 = my_model.loop_energy(loop='AAUU', structure='....')
print(dGloop2)
# --> 0.0

#Calculate the free energy of a hairpin loop
dGloop3 = my_model.loop_energy(loop='AACCCUU', structure='(.....)')
print(dGloop3)
# --> 5.15

#Calculate the free energy of an exterior loop
dGloop4 = my_model.loop_energy(loop='AA+UU', structure='((+))')
print(dGloop4)
# --> -0.9

#Calculate the free energy of a multiloop
dGloop5 = my_model.loop_energy(loop='AAU+ACU+AGU', structure='(.(+).(+).)')
print(dGloop5)
# --> 9.355
```

## Compute stacking state free energies

The `stack_energies` method operates on a `Model` object to calculate the [stacking state free energies](definitions.md#loop-free-energies) for the subensemble of stacking states in a single loop. The loop sequence is specified with keyword `loop` and the loop structure is specified with keyword `structure`. The algorithm returns a list of stacking states and the free energy for each in kcal/mol.

For a loop defined as a list of N snippets, a stacking state is specified as a string composed of one letter per snippet. For each snippet, the returned letter is:

- `'s'` if the snippet contains only 2 nucleotides, each base-paired to a nucleotide in the adjacent snippet, with the two base pairs coaxially stacked on each other
- `'b'` if  both the 5$'$ and 3$'$ unpaired nucleotides are dangle stacking on adjacent base pairs
- `'5'` if only the 5$'$-most unpaired base is dangle stacking on its adjacent base pair
- `'3'` if only the 3$'$-most unpaired base is dangle stacking its adjacent base pair
- `'n'` if none of the above apply (i.e., the snippet does not have a dangle at either the 5$'$ or 3$'$ end nor does it contain only 2 adjacent nucleotides participating in a coaxial stack)

For example, the following figures illustrate snippet annotations for coaxial and dangle stacking states in representative multiloops and exterior loops:

> <img src="../figs/stackingnotation.png" alt="Stacking notation" title="Stacking notation" width="600" />

For a specified multiloop or exterior loop sequence and structure, the `stack_energies` method returns a set of stacking state strings each with a corresponding stacking state free energy (kcal/mol):

```python
# Calculate the dangle stacking state free energies for an exterior loop
my_model.stack_energies(loop='CA+UC', structure='.(+).')
# --> {'35': -0.15, '3n': 0.15, 'n5': 0.35, 'nn': 0.45}

# Calculate the coaxial stacking state free energies for an exterior loop
my_model.stack_energies(loop='AA+U+U', structure='((+)+)')
# --> {'nnn': 0.9, 'snn': 0.0}

# Calculate the coxial stacking state free energies for a multiloop
my_model.stack_energies(loop='AU+AU+AU', structure='((+)(+))')
# --> {'nnn': 11.9725, 'nns': 10.8725, 'nsn': 10.8725, 'snn': 10.8725}
```

For loops that are not multiloops or exterior loops, the loop free energy is returned with a string indicating that there is no stacking state. For example, for a hairpin loop:

```python
my_model.stack_energies(loop='AAAAU', structure='(...)')
# --> {'n': 5.85}
```
