# Physical Model

## Defining a model

NUPACK 4 analysis and design jobs are run based on a physical model created using the `Model` class:

```python
model = Model(ensemble='stacking', material='rna',
              celsius=37, sodium=1.0, magnesium=0.0)
```

NUPACK uses kcal/mol across the board for energy units.
Any unspecified properties take on their default values (which happen to be the ones specified for `model` above). The valid options for each property are described below.


!!!old
    NUPACK algorithms use a **secondary structure model** to predict the free energy of any single secondary structure. The first step to using NUPACK will usually be to specify the secondary structure model that you want to use. For example, a model could be created via the following syntax:

    ```python
    model = Model(ensemble='stacking', celsius=37, na=1.0, mg=0.0, parameters='RNA')
    ```

    There are several options to customize this model, which we will outline below.

!!!example "Old example?"
    - Define a model for DNA calculations at 20 $^\circ$C in $[{\rm Na}^{+}]= 0.0$ M and $[{\rm Mg}^{++}]= 0.01$ M:

    ```python
    model2 = Model(material='dna', celsius=20, sodium=0.0, magnesium=0.01)
    ```
    Note that `ensemble` is unspecified so it defaults to `ensemble='stacking'`.

    - Define a model using custom parameters at 45 $^\circ$C without coaxial and dangle stacking:

    ```python
    model3 = Model(ensemble='nostacking', material='path/to/my/custom-parameters.json', celsius=45)
    ```
    Note that the `sodium` and `magnesium` are unspecified so they take on their default values.



### Ensemble

NUPACK 4 algorithms perform calculations on the following complex ensembles specified by the keyword `ensemble` (default: `ensemble='stacking'`):

- `stacking`
Complex ensemble with coaxial and dangle stacking (ensemble $\overline\Gamma^\shortparallel(\phi)$).

- `nostacking`
Complex ensemble without coaxial and dangle stacking (ensemble $\overline\Gamma(\phi)$).




### Material and parameters

NUPACK 4 algorithms use the following temperature-dependent RNA and DNA free energy parameter sets specified by the keyword `material` (default: `material='rna'`):

- `rna95`
Based on [@Serra95] with additional parameters [@Zuker03] including coaxial stacking [@Mathews99,@Turner10] and dangle stacking [@Serra95,@Zuker03,@Turner10] in 1M Na$^+$.

- `dna04` (shorthand: `dna`)
Based on [@Santalucia98] and [@Santalucia04] with additional parameters [@Zuker03]
including coaxial stacking [@Peyret00] and dangle stacking [@Bommarito00,@Zuker03]
in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@Santalucia98,@Peyret00,@Santalucia04].

- `rna06` (shorthand: `rna`)
Based on [@Mathews99] and [@Lu06] with additional parameters [@Xia98,@Zuker03] including coaxial stacking [@Mathews99,@Turner10] and dangle stacking [@Serra95,@Zuker03,@Turner10] in 1M Na$^+$.

- `custom-parameters`
Custom parameters provided in a JSON file (e.g., `custom-parameters.json`) using the same format as the provided parameter files. Provide $\Delta G_{37}(\mathrm{loop})$ and $\Delta H(\mathrm{loop})$ values to allow calculations at different temperatures or only $\Delta G(\mathrm{loop})$ values to allow calculations at one temperature. Place the JSON file in the same directory as the default parameter files (specify `material = 'custom-parameters'`) or specify the full path to the file (`material = 'path/to/my/custom-parameters.json'`).

!!!note
    Address the "same directory" comment above -- not so easy now.

Base pairs are either Watson-Crick pairs (`G`$\cdot$`C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA). Note that for DNA, `G` and `T` form a mismatch and not a wobble pair [@Santalucia04].

DNA/RNA hybrids are not allowed.


!!!old

    - `'rna95'` based on @Serra95 with additional parameters [@Zuker03] including coaxial stacking [@Mathews99;@Turner10] and dangle stacking [@Serra95;@Zuker03;@Turner10] in 1M Na$^+$.
    - `'rna99'` based on @Mathews99 with additional parameters [@Xia98] including coaxial stacking [@Mathews99] and dangle stacking [@Serra95] in 1M Na$^+$. This parameter set may only be used at 37&deg; C.
    - `'rna06'` based on @Mathews99 and @Lu06 with additional parameters [@Xia98;@Zuker03] including coaxial stacking [@Mathews99;@Turner10] and dangle stacking [@Serra95;@Zuker03;@Turner10] in 1M Na$^+$.
    - `'dna04'` based on @SantaLucia98 and @SantaLucia04 with additional parameters [@Zuker03] including coaxial stacking [@Peyret00] and dangle stacking [@Bommarito00;@Zuker03] in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@SantaLucia98;@Peyret00;@SantaLucia04].

    The shorthands `'RNA'` and `'DNA'` redirect to `'rna06'` and `'dna04'`, respectively. (These are the most up to date parameter sets.) DNA/RNA hybrids are not currently allowed.


!!!old
    Parameters are now stored in the JSON format. A parameter file contains both $\Delta G$ and (optionally) $\Delta H$ parameters. You may specify a specific parameter JSON file as in the following example:

    ```python
    model = Model(parameters='path/to/my/custom-parameters.json')
    ```





### Temperature

- `celsius`
Temperature is specified by the keyword `celsius` in $^\circ$C (default: `celsius=37`).
If desired, the temperature may also be specified via the keyword `kelvin`; this overrides the `celsius` value.

!!!old
    Free energy parameters are usually specified in NUPACK via enthalpy ($\Delta H$) and entropy terms ($\Delta S$). Parameters are adjusted for a given temperature using the formula $\Delta G = \Delta H - T \Delta S$.


### Salt concentrations

The default salt conditions for RNA and DNA parameter sets are $[\mathrm{Na}^+] = 1 {\rm M}$. Only the default salt conditions are supported for RNA. Salt corrections are available for DNA parameters to permit calculations in user-specified sodium, potassium, ammonium, and magnesium ion concentrations.

- `sodium`
Based on [@Santalucia98,@SantaLucia04] the sum of the concentrations of (monovalent) sodium, potassium, and ammonium ions, $[{\rm Na}^+] + [\mathrm{K}^+] + [\mathrm{NH}_4^+]$, is specified in units of molar (default: 1.0, range: \[0.05,1.1\]) using the keyword `sodium`.

- `magnesium`
Based on [@Peyret00,@Koehler05] the concentration of (divalent) magnesium ions, $[{\rm Mg}^{++}]$, is specified in units of molar (default: 0.0, range: \[0.0,0.2\]) using the keyword `magnesium`.


!!!old
    Salt corrections are only applied when the material is `DNA`.
    Salt corrections are applied simply as a flat bonus for each base pair in a secondary structure.

    - **Sodium:** The Na$^+$ concentration of the solution is specified by the keyword `na` in units of molar (default: 1.0, range: \[0.05,1.1\]) is specified by @SantaLucia04.

    - **Magnesium:** The Mg$^{++}$ concentration of the solution is specified by the keyword `mg` in units of molar (default: 0.0, range: \[0.0,0.2\]) is specified by @Koehler05.


### Wobble pairs

G$\cdot$U RNA wobble pairs are enabled by default in the provided RNA parameter sets.
G$\cdot$T DNA wobble pairs are disabled by default in the provided DNA parameter set.
However, wobble pairs may be manually enabled or disabled using the additional `wobble` parameter during model construction (e.g. `Model(..., wobble=True)`).
In the historical ensembles, a duplex terminated by a wobble pair is forbidden.


### Historical options


For backwards compatibility with NUPACK 3, the following historical complex ensembles without coaxial stacking and with approximate dangle stacking are supported:

- `none-nupack3`
No dangle stacking and no coaxial stacking (dangles `none` option for NUPACK 3)

- `some-nupack3`
Some dangle stacking and no coaxial stacking (dangles `some` option for NUPACK 3). A dangle energy is incorporated for each unpaired base flanking a duplex (a base flanking two duplexes contributes only the minimum of the two possible dangle energies).

- `all-nupack3`
All dangle stacking and no coaxial stacking (dangles `all` option for NUPACK 3). A dangle energy is incorporated for each base flanking a duplex regardless of whether it is paired.

For these historical ensembles, base pairs are either Watson-Crick pairs (`G`$\cdot$`C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA; `G`$\cdot$`T` for DNA). Note that for the historical ensembles, `G`$\cdot$`T` is classified as a DNA wobble pair and not as a mismatch. The historical ensembles prohibit a wobble pair (`G`$\cdot$`U` or `G`$\cdot$`T`) as a terminal base pair in an exterior loop or a multiloop. As a result, an attempt to evaluate a free energy for a sequence $\phi$ and secondary structure $s$ that place a wobble pair as a terminal base pair in an exterior loop or multiloop will return $\overline{\Delta G}(\phi,s)=\Delta G(\phi,s) = \infty$. These historical ensembles can be used for calculations in combination with the following historical DNA and RNA parameter sets:

- `rna95-nupack3`
Same as `rna95` except that terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies.

- `dna04-nupack3`
Same as `dna04` except that G$\cdot$T was treated as a wobble pair (analogous to a `G`$\cdot$`U` RNA wobble pair) instead of classifying `G` and `T` as a mismatch. Note that while terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies, this is the same treatment as in `dna04`, as terminal mismatch parameters are not public for DNA [@Santalucia04].

- `rna99-nupack3`
Same as `rna06` except that terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies and parameters are provided only for 37 $^\circ$C.





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

## Citations
