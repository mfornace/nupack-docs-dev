# Model Specification

<hr> 


## Specify a physical model

NUPACK 4 analysis and design jobs are run based on a physical model created using the `Model` class:

```python
model1 = Model(material='rna', ensemble='stacking', celsius=37, sodium=1.0, magnesium=0.0)
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
    - Define a model for DNA calculations at 23 $^\circ$C in $[{\rm Na}^{+}]= 0.0$ M and $[{\rm Mg}^{++}]= 0.01$ M:

    ```python
    model2 = Model(material='dna', celsius=23, sodium=0.0, magnesium=0.01)
    ```
    Note that `ensemble` is unspecified so it defaults to `ensemble='stacking'`.

    - Define a model using custom parameters at 45 $^\circ$C without coaxial and dangle stacking:

    ```python
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





