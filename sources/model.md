


## Model settings

NUPACK algorithms use a **secondary structure model** to predict the free energy of any single secondary structure. The first step to using NUPACK will usually be to specify the secondary structure model that you want to use. For example, a model could be created via the following syntax:

```python
model = nupack.Model(ensemble='stacking', T=310.15, na=1.0, mg=0.0, parameters='RNA')
```

There are several options to customize this model, which we will outline below.

### Coaxial stacking and dangle contributions

The way in which dangle energies are incorporated is specified by `ensemble`, which may have the following values:

- `'stacking'`: (default) Structure free energies fully incorporate all possible dangle and coaxial stacking states.
- `'nostacking'`: No dangle or stacking energies are incorporated.
- `'none'`: No dangle or stacking energies are incorporated.
- `'min'`: A dangle energy is incorporated for each unpaired base flanking a duplex (a base flanking two duplexes contributes only the minimum of the two possible dangle energies).
- `'all'`: A dangle energy is incorporated for each base flanking a duplex regardless of whether it is paired.

### Wobble pairs

G$\cdot$U RNA wobble pairs are enabled by default. G$\cdot$T DNA wobble pairs are disabled by default. Wobble pairs may be manually enabled or disabled using the additional `wobble` parameter during model construction (e.g. `Model(..., wobble=True)`). In the historical ensembles, a duplex terminated by a wobble pair is forbidden.

### Temperature

Temperature is specified by the `T` parameter in Kelvin (default: 310.15). (Note that the temperature units have been changed from NUPACK 3, which used Celsius.) Free energy parameters are usually specified in NUPACK via enthalpy ($\Delta H$) and entropy terms ($\Delta S$). Parameters are adjusted for a given temperature using the formula $\Delta G = \Delta H - T \Delta S$.

### Salt concentrations

<!-- Salt corrections are only applied when the material is `DNA`.  -->
Salt corrections are applied simply as a flat bonus for each base pair in a secondary structure.

- **Sodium:** The Na$^+$ concentration of the solution is specified by the keyword `na` in units of molar (default: 1.0, range: \[0.05,1.1\]) is specified by @SantaLucia04.

- **Magnesium:** The Mg$^{++}$ concentration of the solution is specified by the keyword `mg` in units of molar (default: 0.0, range: \[0.0,0.2\]) is specified by @Koehler05.


## Model parameters

The parameter files defining the nucleic acid material may be specified via the argument `parameters`, which represents a shorthand key for an included parameter set. Available parameter set keys currently include:

 - `'rna95'` based on @Serra95 with additional parameters [@Zuker03] including coaxial stacking [@Mathews99;@Turner10] and dangle stacking [@Serra95;@Zuker03;@Turner10] in 1M Na$^+$.
- `'dna04'` based on @SantaLucia98 and @SantaLucia04 with additional parameters [@Zuker03] including coaxial stacking [@Peyret00] and dangle stacking [@Bommarito00;@Zuker03] in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@SantaLucia98;@Peyret00;@SantaLucia04].
- `'rna06'` based on @Mathews99 and @Lu06 with additional parameters [@Xia98;@Zuker03] including coaxial stacking [@Mathews99;@Turner10] and dangle stacking [@Serra95;@Zuker03;@Turner10] in 1M Na$^+$.

The shorthands `'RNA'` and `'DNA'` redirect to `'rna06'` and `'dna04'`, respectively. DNA/RNA hybrids are not currently allowed.

### Custom parameters

Parameters are now stored in the JSON format. A parameter file contains both $\Delta G$ and (optionally) $\Delta H$ parameters. You may specify a specific parameter JSON file as in the following example:

```python
model = nupack.Model(parameters='path/to/my/custom-parameters.json')
```

## Using the model

Typically a `Model` will be used as an input to thermodynamic analysis via dynamic programming algorithms. However, a `Model` also contains a few useful methods (below) to analyze individual secondary structures.

### Calculate the free energy of a nucleic acid loop

```python
energy = model.loop_energy(sequences=['AA', 'TT'], nick=None)
```

**Description:** Calculate the free energy of a loop defined by an ordered list of bounding sequences `sequences`. To specify an exterior loop, specify `nick` as the zero-based index of the strand that follows the strand break.

### Calculate the free energy of a secondary structure

```python
energy = model.structure_energy(strands=['AAAA', 'TTTT'], structure='((((+))))')
```

**Description:** Calculate the free energy of a complex `strands` in a secondary structure `structure`.

## Citations
