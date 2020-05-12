# Overview

NUPACK is a growing software suite for the analysis and design of nucleic acid structures, devices, and systems serving the needs of researchers in the fields of nucleic acid nanotechnology, molecular programming, synthetic biology, and across the life sciences more broadly. All of this software can be conveniently run using the NUPACK web application at [nupack.org](http://www.nupack.org) [@Zadeh11a]. This User Guide provides documentation for the NUPACK Source Code. 

When finishing a project that has benefited from NUPACK calculations, please remember to cite the NUPACK web application and algorithms appropriately; citations are an important component in helping to secure funding for NUPACK development and maintenance. Please email us with questions, comments, feature requests, and bug reports at <support@nupack.org>.

— The NUPACK Team

## Overview

NUPACK algorithms address two fundamental classes of problems: 

- **Sequence analysis:** given a set of DNA or RNA strands, analyze the equilibrium base-pairing properties over a specified ensemble.
- **Sequence design:** given a set of desired equilibrium base-pairing properties, design the sequences of a set of DNA or RNA strands over a specified ensemble. Sequence design is performed subject to diverse user-specified sequence constraints including composition constraints, complementarity constraints, pattern prevention constraints, and biological constraints.  

<img src="/figs/NUPACK.png" alt="NUPACK Analysis and Design" title="NUPACK Analysis and Design" width="700"/>  
**Figure:** Sequence analysis and design using NUPACK.

NUPACK algorithms operate over two fundamental ensembles:

- **Complex ensemble:** The ensemble of all (unpseudoknotted connected) secondary structures for an arbitrary number of interacting RNA or DNA strands.
- **Test tube ensemble:** The ensemble of a dilute solution containing an arbitrary number of RNA or DNA strand species (introduced at user-specified concentrations) interacting to form an arbitrary number of complex species.

Furthermore, to enable reaction pathway engineering of dynamic hybridization cascades or large-scale structural engineering including pseudoknots, NUPACK generalizes sequence analysis and design to multi-complex and multi-tube ensembles [@Wolfe17].





## Terminology
- The **sequence**, $\phi$, of one or more interacting RNA strands is specified as a list of bases $\phi^a\in\{$A,C,G,U$\}$ for $a=1,\dots,|\phi|$. For DNA, $\phi^a\in\{$A,C,G,T$\}$.
- A **secondary structure**, $s$, of one or more interacting RNA strands is defined by a set of base pairs, each a Watson--Crick pair \[A$\cdot$U or C$\cdot$G\] or a wobble pair \[G$\cdot$U\]). For DNA, the corresponding Watson--Crick pairs are A$\cdot$T or C$\cdot$G and there are no wobble pairs. 
- A **polymer graph** representation of a secondary structure is constructed by ordering the strands around a circle, drawing the backbones in succession from 5$'$ to 3$'$ around the circumference with a *nick* between each strand, and drawing straight lines connecting paired bases.
- A secondary structure is **unpseudoknotted** if there exists a strand ordering for which the polymer graph has no crossing lines, or **pseudoknotted** if all strand orderings contain crossing lines. In NUPACK 4, pseudoknots are excluded from the structural ensemble. 
- A secondary structure is **connected** if no subset of the strands is free of the others.

## Complex Ensemble
Consider a complex of $L$ distinct strands (e.g., each with a unique identifier in $\{1,\dots,L\}$) corresponding to strand ordering $\pi$. The **complex ensemble** $\overline\Gamma(\phi)$ contains all connected polymer graphs with no crossing lines for sequence $\phi$ and strand ordering $\pi$ (i.e., all unpseudoknotted secondary structures) [@Dirks07]. (We dispense with our prior convention [@Dirks07,@Zadeh11a,@Zadeh11b] of calling this entity an ''ordered complex''.)

<!-- A **complex** of $L$ interacting strands with strand ordering, $\pi$, has a **structural ensemble** containing all connected polymer graphs with no crossing lines [@Dirks07]. (We dispense with our prior convention [@Dirks07; @Zadeh11a; @Zadeh11b] of calling this entity an **ordered complex**.)
 -->
<!-- ![Complex](/figs/complex.png)   -->
<img src="/figs/complex.png" alt="Complex" title="Example complex" width="360" />  
**Figure:** A complex of 3 strands with strand ordering $\pi$ = ABC.

As a matter of algorithmic necessity, all of the dynamic programs in NUPACK operate on complex ensemble $\overline\Gamma(\phi)$ treating all strands as distinct. However, in the laboratory, strands with the same sequence are typically indistinguishable with respect to experimental observables. For comparison to experimental data, physical quantities calculated over ensemble $\overline\Gamma(\phi)$ are post-processed
to obtain the corresponding quantities calculated over **complex ensemble** $\Gamma(\phi)$ in which strands with the same sequence are treated as indistinguishable [@Fornace20]. The ensemble $\Gamma(\phi)\subseteq\overline\Gamma(\phi)$ is a maximal subset of distinct secondary structures for strand ordering $\pi$. Two secondary structures are indistinguishable if their polymer graphs can be rotated so that all strands are mapped onto indistinguishable strands, all base pairs are mapped onto base pairs, and all unpaired bases are mapped onto unpaired bases;
otherwise the structures are distinct [@Dirks07].



<!-- If a complex contains multiple strands with the same sequence, subtleties arise in the definition of the structural ensemble and in the calculation of experimental observables [@Dirks07,@Fornace20]. Let $\overline\Gamma(\phi)$ denote the structural ensemble in which each strand is treated as distinct (i.e., each strand has a unique identifier in $\{1,\dots,L\}$) and let $\Gamma(\phi)$ denote the ensemble in which strands with the same sequence are treated as indistinguishable. Two secondary structures are indistinguishable if their polymer graphs can be rotated so that all strands are mapped onto indistinguishable strands, all base pairs are mapped onto base pairs, and all unpaired bases are mapped onto unpaired bases; otherwise the structures are distinct [@Dirks07]. The ensemble $\Gamma(\phi)\subseteq\overline\Gamma(\phi)$ is a maximal subset of distinct secondary structures for strand ordering $\pi$.

Consider a complex of $L$ distinct strands (e.g., each with a unique identifier in $\{1,\dots,L\}$) corresponding to strand ordering $\pi$. The **complex ensemble** $\overline\Gamma(\phi)$ contains all connected polymer graphs with no crossing lines for sequence $\phi$ and strand ordering $\pi$ (i.e., all unpseudoknotted secondary structures) [@Dirks07]. (We dispense with our prior convention [\cite{@Dirks07,@Zadeh11a,@Zadeh11b] of calling this entity an **ordered complex**.) -->

## Test Tube Ensemble

A **test tube ensemble** is a dilute solution containing a set of strand species, $\Psi^0$, introduced at user-specified concentrations, that interact to form a set of complex species, $\Psi$, each corresponding to a different strand ordering treating strands with the same sequence as indistinguishable [@Dirks07,@Fornace20].
For $L$ strands, there are $(L-1)!$ strand orderings if all strands are different species (e.g., complexes $\pi$ = ABC and $\pi$ = ACB for $L=3$ and strands A, B, C), but fewer than $(L-1)!$ strand orderings if some strands are of the same species (e.g., complex $\pi$ = AAA for $L=3$ with three A strands). By the Representation Theorem [@Dirks07], a secondary structure in the complex ensemble for one strand ordering does not appear in the complex ensemble for any other strand ordering, averting redundancy.
It is often convenient to define $\Psi$ to contain all complex species of up to $L_\mathrm{max}$ strands, although $\Psi$ can be defined to contain arbitrary complex species formed from the strand species in $\Psi^0$.

<img src="/figs/tube.png" alt="Test tube" title="Example test tube" width="190" />  
**Figure:** A test tube ensemble containing strain species $\Psi^0 = \{$A,B,C$\}$ interacting to form all complex species $\Psi$ of up to $L_{\rm max} = 3$ strands.

<!-- A **test tube** may contain an arbitrary number of strand species interacting to form an arbitrary number of complex species in a dilute solution. Let $\Psi^0$ denote the set of strand species that interact in a test tube to form the set of complex species $\Psi$. It is often convenient to define $\Psi$ to contain all complexes of up to some size $L_{\rm max}$. 

Each complex $j\in\Psi$ corresponds to a distinct strand ordering $\pi_j$ of $L$ strands for $L\in\{1,\dots,L_{\rm max}\}$. $L$ distinct strands can be ordered around a circle in $(L-1)!$ distinct ways (e.g., strands $A$, $B$, and $C$ can be ordered $ABC$ and $ACB$). If some of the $L$ strands are of the same species, there will be fewer than $(L-1)!$ distinct strand orderings (e.g., strands $A$, $A$, and $B$ can only be ordered $AAB$). For a given set of $L$ strands, each unpseudoknotted connected secondary structure is found in the structural ensemble, $\Gamma_j$, corresponding to exactly one strand ordering, $\pi_j$ (i.e., exactly one complex $j\in\Psi$) [@Dirks07].

 -->
<!-- ## Loop Free Energies
For each (unpseudoknotted connected) secondary structure $s\in\overline{\Gamma}(\phi)$, the free energy,
$\overline{\Delta G}(\phi,s)$, is estimated as the sum of the empirically determined free energies of the
constituent loops [@Santalucia98,@Xia98,@Mathews99,@Zuker03,@Lu06,@Turner10] plus a strand association penalty [@Bloomfield00], $\Delta
G^\textrm{assoc}$, applied $L-1$ times for a
complex of $L$ strands:
\begin{align}
\overline{\Delta G}(\phi,s) = (L-1)\,\Delta G^\textrm{assoc}\, + \sum_{\mathrm{loop} \in s} \Delta G(\mathrm{loop}). \label{eq:dGbar}
\end{align}

The different loop types are modeled as follows: 

- A **hairpin loop** is closed by a single base-pair $i\cdot j$. The loop free energy, $\Delta G^\mathrm{hairpin}_{i,j}$, depends on sequence and loop size.
- An **interior loop** is closed by two base pairs ($i\cdot j$ and $d\cdot e$ with $i<d<e<j$). The loop free energy, $\Delta G^\mathrm{interior}_{i,d,e,j}$ depends on sequence, loop size, and loop asymmetry. **Bulge loops** (where either $d=i+1$ or $e=j-1$) and **stacked pairs** (where both $d=i+1$ and $e=j-1$) are treated as special cases of interior loops.
- A **multiloop** is closed by three or more base pairs.
The loop free energy is modeled as the sum of three sequence-independent penalties:
$\Delta G^\mathrm{multi}_\mathrm{init}$ for formation of a multiloop, $\Delta G^\mathrm{multi}_\mathrm{bp}$ for each closing base pair, $\Delta G^\mathrm{multi}_\mathrm{nt}$ for each unpaired nucleotide inside the multiloop,
plus a sequence-dependent penalty: $\Delta G^\mathrm{terminalbp}_{i, j}$ for each closing pair $i\cdot j$.
- An **exterior loop** contains a nick between strands and any number of closing base pairs.
The exterior loop free energy is the sum of $\Delta G^\mathrm{terminalbp}_{i, j}$ over all closing base pairs $i\cdot j$. Hence,  an unpaired strand has a free energy of zero, corresponding to the reference state [@Dirks07].

<img src="/figs/looptypes.png" alt="Loop Types" title="Loop Types" width="450" />  
**Figure:** Loop-based free energy model: canonical loop types for a complex with strand ordering $\pi$ = ABC.

## Coaxial and Dangle Stacking
Within a multiloop or an exterior loop, there is a subensemble of coaxial stacking states between adjacent closing base pairs and dangle stacking states between
closing base pairs and adjacent unpaired bases. 
Within a multiloop or exterior loop, a base pair can
form one **coaxial stack** with an adjacent base pair, or can form a **dangle stack** with at most two adjacent unpaired bases; unpaired bases can either form no stack, or can form a dangle stack with at most one adjacent base pair.

<img src="/figs/multiloopstacking.png" alt="Coaxial and dangle stacking states for a multiloop" title="Coaxial and dangle stacking states for a multiloop" width="850" />  
**Figure:** Coaxial and dangle stacking states for a multiloop.

<img src="/figs/exteriorloopstacking.png" alt="Coaxial and dangle stacking states for two exterior loops" title="Coaxial and dangle stacking states for two exterior loops" width="500" />  
**Figure:** Coaxial and dangle stacking states for two exterior loops.



For a given multiloop or exterior loop, the energetic contributions of all possible coaxial and dangle stacking states are enumerated so as to calculate the free energy:
\begin{align}
\Delta G^\mathrm{stacking} = - k T \log \sum_{\omega\in\mathrm{loop}} \prod_\mathrm{x\in\omega} e^{-\Delta G_x/k T}\label{eq:stack}
\end{align}
where $\omega$ indexes the possible stacking states within the loop and $x$ indexes the individual stacks (coaxial or dangle) within a stacking state.
The free energy of a multiloop or exterior loop is augmented by the corresponding $\Delta G^\mathrm{stacking}$ bonus.
Hence, a secondary structure $s$ continues to be defined as a set of base pairs, and the stacking states within a given multiloop or exterior loop are treated as a structural subensemble that contributes in a Boltzmann-weighted fashion to the free energy model for the loop.
Let $s^\shortparallel\in s$ denote a stacking state of the paired and unpaired bases in $s$. We may equivalently define the free energy of secondary structure $s$ in terms of the
free energies for all stacking states $s^\shortparallel\in s$:
\begin{align}
\overline{\Delta G}(\phi,s) = -kT \log \sum_{s^\shortparallel\in s}e^{-\overline{\Delta G}(\phi,s^\shortparallel)/kT} \label{eq:stacksum}
\end{align}
Let $\overline\Gamma^\shortparallel(\phi)$ denote the ensemble of stacking states corresponding to the complex ensemble of secondary structures $\overline\Gamma(\phi)$.

## Symmetry Correction
For a secondary structure $s\in\Gamma(\phi)$ with an $R$-fold rotational symmetry there is in $R$-fold reduction in distinguishable conformational space, so the free energy $\overline{\Delta G}(\phi,s)$ must be adjusted [@Dirks07] by a symmetry correction:
\begin{align}
\Delta G(\phi,s)
&=   \overline{\Delta G}(\phi,s) + \Delta G^\mathrm{sym}(\phi,s). \label{eq:dGcorrected}
\end{align}
where
\begin{align}
\Delta G^\mathrm{sym}(\phi,s) = kT\log R(\phi,s). \label{eq:dGsym}
\end{align}
Because the symmetry factor $R(\phi,s)$ is a global property of each secondary structure $s\in\Gamma(\phi)$, it is not suitable for use with dynamic programs that treat multiple subproblems simultaneously without access to global structural information. As a result, dynamic programs operate on ensemble $\overline\Gamma(\phi)$ using physical model $\overline{\Delta G}(\phi,s)$ and then the Distinguishability Correction Theorem [@Dirks07] enables exact conversion of physical quantities to ensemble $\Gamma(\phi)$ using physical model $\Delta G(\phi,s)$.
Interestingly, ensembles $\overline\Gamma(\phi)$ and $\Gamma(\phi)$ both have utility when examining the physical properties of a complex as they provide related but different perspectives,
akin to complementary thought experiments [@Fornace20].


## Free Energy Parameters
For RNA, we employ temperature-dependent parameters [@Serra95,@Xia98,@Mathews99,@Zuker03,@Lu06,@Turner10]
including coaxial [@Mathews99,@Turner10] and dangle [@Serra95,@Zuker03,@Turner10] parameters
in 1M Na$^+$. For DNA,
we employ temperature-dependent parameters [@Santalucia98,@Zuker03,@Santalucia04]
including coaxial [@Peyret00] and dangle [@Bommarito00,@Zuker03] parameters
in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@Santalucia98,@Peyret00,@Santalucia04]. See [@Fornace20] for details.  -->

<!-- For sequence $\phi$ and secondary structure, $s$, the **free energy**, $\Delta G(\phi,s)$, is calculated using nearest-neighbor empirical parameters for RNA [@Serra95; @Mathews99; @Zuker03] in 1M Na$^+$ or for DNA [@SantaLucia98; @Zuker03] in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@SantaLucia04; @Koehler05]. The zero free energy reference state for all calculations is a system where all relevant strands are present with no base pairs [@Dirks07]. -->

## Conventions

Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1.

Nucleic acid sequences are listed $5'$ to $3'$. The bases in a complex are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand. For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39.

Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.

Secondary structures are specified in one of three ways:

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



<!-- ## Outline -->

<!-- See the following pages for help on installing and using NUPACK.

1. The [Installation](installation.md) page describes how to install NUPACK 4.
2. The [Conventions](basics.md) page describes the common conventions that NUPACK 4 uses.
3. The [Model](model.md) page describes how to create a secondary structure free energy model.
4. The [Analysis](analysis.md) page describes how to perform thermodynamic analysis.
5. The [Design](design.md) page describes how to perform thermodynamic design. (currently the same as the example design page).

The [Examples](examples.md) page links to example Jupyter notebooks that are bundled with NUPACK 4. You may also view these notebooks on [nbviewer](https://nbviewer.jupyter.org/github/mfornace/nupack-nbviewer/tree/master/) or [GitHub](https://github.com/mfornace/nupack-nbviewer/). (These notebooks are not hosted online yet, see files provided to you.) -->

<!-- Finally, you may look through these main parts of the NUPACK Python API.

1. [Model](api/model.md)
2. [Analysis](api/analysis.md)
3. [Design](api/design.md)
4. [Concentrations](api/concentration.md)
5. [Drawing](api/drawing.md) -->

# Physical Model

## Define a model
NUPACK 4 analysis and design jobs are run based on a physical model created using the `model` command to specify properties as follows: 

```python
my-model1 = model(ensemble='stacking', material='rna', temperature=37, sodium=1.0, magnesium=0.0)
```
Any unspecified properties take on their default values (which happen to be the ones specified for `mymodel1` above). The valid options for each property are described below. 

## Parameter sets

NUPACK 4 algorithms use the following temperature-dependent RNA and DNA free energy parameter sets specified by the keyword `material` (default: `material = 'rna'`):

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

Base pairs are either Watson-Crick pairs (`G`$\cdot$`C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA). Note that for DNA, `G` and `T` form a mismatch and not a wobble pair [@Santalucia04].

DNA/RNA hybrids are not allowed.

NUPACK 4 algorithms perform calculations on the following complex ensembles specified by the keyword `ensemble` (default: `ensemble = 'stacking'`):

- `stacking`  
Complex ensemble with coaxial and dangle stacking (ensemble $\overline\Gamma^\shortparallel(\phi)$).

- `nostacking`  
Complex ensemble without coaxial and dangle stacking (ensemble $\overline\Gamma(\phi)$).
 


## Historical parameter sets
For backwards compatibility with NUPACK 3, the following historical complex ensembles without coaxial stacking and with approximate dangle stacking are supported:

- `none-nupack3`  
No dangle stacking and no coaxial stacking (dangles `none` option for NUPACK 3)

- `some-nupack3`  
Some dangle stacking and no coaxial stacking (dangles `some` option for NUPACK 3)

- `all-nupack3`  
All dangle stacking and no coaxial stacking (dangles `all` option for NUPACK 3)

For these historical ensembles, base pairs are either Watson-Crick pairs (`G`$\cdot$`C` and `A`$\cdot$`U` for RNA; `G`$\cdot$`C` and `A`$\cdot$`T` for DNA) or wobble pairs (`G`$\cdot$`U` for RNA; `G`$\cdot$`T` for DNA). Note that for the historical ensembles, `G`$\cdot$`T` is classified as a DNA wobble pair and not as a mismatch. The historical ensembles prohibit a wobble pair (`G`$\cdot$`U` or `G`$\cdot$`T`) as a terminal base pair in an exterior loop or a multiloop. As a result, an attempt to evaluate a free energy for a sequence $\phi$ and secondary structure $s$ that place a wobble pair as a terminal base pair in an exterior loop or multiloop will return $\overline{\Delta G}(\phi,s)=\Delta G(\phi,s) = \infty$. These historical ensembles can be used for calculations in combination with the following historical DNA and RNA parameter sets:

- `rna95-nupack3`  
Same as `rna95` except that terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies.

- `dna04-nupack3`  
Same as `dna04` except that G$\cdot$T was treated as a wobble pair (analogous to a `G`$\cdot$`U` RNA wobble pair) instead of classifying `G` and `T` as a mismatch. Note that while terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies, this is the same treatment as in `dna04`, as terminal mismatch parameters are not public for DNA [@Santalucia04].

- `rna99-nupack3`  
Same as `rna06` except that terminal mismatch free energies in exterior loops and multiloops are replaced by two dangle stacking free energies and parameters are provided only for 37 $^\circ$C.

## Temperature
- `temperature`  
Temperature is specified by the keyword `temperature` in $^\circ$C (default: `temperature=37`). 

## Salt concentrations
The default salt conditions for RNA and DNA parameter sets are $[\mathrm{Na}^+] = 1 {\rm M}$. Only the default salt conditions are supported for RNA. Salt corrections are available for DNA parameters to permit calculations in user-specified sodium, potassium, ammonium, and magnesium ion concentrations. 

- `sodium`  
Based on [@Santalucia98,@SantaLucia04] the sum of the concentrations of (monovalent) sodium, potassium, and ammonium ions, $[{\rm Na}^+] + [\mathrm{K}^+] + [\mathrm{NH}_4^+]$, is specified in units of molar (default: 1.0, range: \[0.05,1.1\]) using the keyword `sodium`. 

- `magnesium`  
Based on [@Peyret00,@Koehler05] the concentration of (divalent) magnesium ions, $[{\rm Mg}^{++}]$, is specified in units of molar (default: 0.0, range: \[0.0,0.2\]) using the keyword `magnesium`. 



## Example models

- Define a model for DNA calculations at 20 $^\circ$C in $[{\rm Na}^{+}]= 0.0$ M and $[{\rm Mg}^{++}]= 0.01$ M:
    
```python
my-model2 = model(material='dna', temperature=20, sodium=0.0, magnesium=0.01)
```
Note that `ensemble` is unspecified so it defaults to `ensemble = 'stacking'`.

- Define a model using custom parameters at 45 $^\circ$C without coaxial and dangle stacking:

```python
my-model3 = model(ensemble = 'nostacking', material='path/to/my/custom-parameters.json', temperature=45)
```
Note that the `sodium` and `magnesium` are unspecified so they take on their default values. 

# Analysis

Analyze the equilibrium properties over one of two ensembles: 

- **Complex Analysis:** analyze the equilibrium base-pairing properties of a complex of interacting nucleic acid strands [@Dirks07,@Fornace20].

- **Test Tube Analysis:** analyze the equilibrium concentrations and base-pairing properties for a test tube of interacting nucleic acid strands [@Dirks07,@Fornace20].

Note that a complex ensemble is subsidiary to a test tube ensemble, so complex analysis is inherent in test tube analysis (but not vice versa), and complex design is inherent in test tube design (but not vice versa). As it is typically infeasible to experimentally study a single complex in isolation, we recommend analyzing and designing nucleic acid strands in a test tube ensemble that contains the complex of interest as well as other competing complexes that might form in solution. For example, if one is experimentally studying strands A and B that are intended to predominantly form a secondary structure within the ensemble of complex A$\cdot$ B, one should not presuppose that the strands do indeed form A$\cdot$ B and simply analyze or design the base-pairing properties of that complex. Instead, it is more physically relevant to analyze a test tube ensemble containing strands A and B interacting to form multiple complex species (e.g., A, B, A$\cdot$ A, A$\cdot$ B, B$\cdot$ B) so as to capture both concentration information (how much A$\cdot$ B forms?) and structural information (what are the base-pairing properties of A$\cdot$ B when it does form?). 

## Test Tube Analysis

#### Define a strand

```python
strand('A','AGTCTAGGATTCGGCGTGGGTTAA')
strand('B','TTAACCCACGCCGAATCCTAGACTCAAAGTAGTCTAGGATTCGGCGTG')
strand('C','AGTCTAGGATTCGGCGTGGGTTAACACGCCGAATCCTAGACTACTTTG')
```

#### Define a complex

```python
complex('C1', ['A'])
complex('C2', ['A', 'B', 'B', 'C'])
complex('C3', ['A', 'A'])
```

#### Define a secondary structure

```python
structure('S1','.(((........))).........')
structure('S2','.1(3.8)3.9')
structure('S3','U1 D3 U8 U9')
```
#### Define a test tube analysis calculation

```python
#strand-set('myPsi0',{['A':1e-6],['B':1e-8]})
#complex-set('myPsi',{maxsize=3,explicit=['C2'],exclude=['C1']})  
tube('T1',strand-set={['A':1e-6],['B':1e-8]},complex-set={maxsize=3,explicit=['C2'],exclude=['C1']})
```

## Test Tube Design

#### Define a strand

```python
strand('A','N24')
strand('B','N48')
strand('C','N48')
```

#### Define a secondary structure

```python
structure('S1','.(((........))).........')
structure('S2','.1(3.8)3.9')
structure('S3','U1 D3 U8 U9')
```

#### Define a complex

```python
complex('C1', ['A'], 'S1')
complex('C2', ['A', 'B', 'B', 'C'],'.48')
complex('C3', ['A', 'A'],'U48')
```


#### Define a tube

```python
#strand-set('myPsi0',{['A':1e-6],['B':1e-8]})
#complex-set('myPsi',on-targets{['C1':1e-8,'S1'],['C2':1e-8,'S2']},off-targets{maxsize=3,explicit=['C2'],exclude=['C1']})  
tube('T1',
    on-targets{['C1':1e-8],['C2':1e-8]},
    off-targets{maxsize=3,include=['C2'],exclude=['C1']},constraints,weights)
tube('T1',
    on-targets = {['C1':1e-8],['C2':1e-8]},
    off-targets = {maxsize=3,include=['C2'],exclude=['C1']},constraints='T1constraints',weights='T1weights')
```

#### Run a design job
```python
myjob = design(tubes = ['T1','T2','crosstalk'], complexes = ['C1', 'C2'],  
    constraints='myconstraints', softconstraints='myobjectives', weights='myweights', trials = 5, stop = 0.01)
```

### Calculate physical quantities for a complex ensemble

#### `energy`: 

#### `pfunc` 
Calculate the complex partition function, $Q(\phi)$, and complex free energy $\Delta G(\phi) \equiv -k_{\rm B}T\log(Q(\phi))$, over ensemble $\Gamma(\phi)$. Here, $k_{\rm B}$ is the Boltzmann constant. 


```python
my-pfunc = pfunc('C2', model = 'mymodel1')  # use previously defined complex 'C1' and model 'mymodel1'
my-pfunc3 = pfunc(['A', 'B'])  # use previously defined strands 'A' and 'B', use default model
```
<!-- my-pfunc3 = pfunc(['AGTC', 'TTAACCC'])  # use newly defined strands, use default model -->

#### `prob`
Calculate the equilibrium probability, $p(\phi,s) = e^{-\Delta G(\phi,s)/k_{\rm B}T}/Q(\phi)$, of sequence $\phi$ adopting secondary structure $s\in\Gamma(\phi)$. 

```python
my-prob = pfunc(complex = 'C1', structure='S1')  # use previously defined complex 'C1' and structure 'S1'
```

#### `mfe`

#### `subopt`

#### `pairs`

#### `sample`

#### `count`






## Test Tube Analysis

# Design
To enable reaction pathway engineering of dynamic hybridization cascades (e.g., shape and sequence transduction using small conditional RNAs \cite{hochrein13}) or large-scale structural engineering including pseudoknots (e.g., RNA origamis \cite{geary14}), NUPACK generalizes these analysis and design capabilities to multistate ensembles: 
\blist
\item {\bf Multi-complex ensemble:} the ensemble of an arbitrary number of strand species interacting to form an arbitrary number of complex species. 
\item {\bf Multi-tube ensemble:} the ensemble of an arbitrary number of test tubes containing different subsets of an arbitrary number of strand species introduced at user-specified concentrations. 
\elist
We recommend using multi-tube sequence design, as it captures concentration and crosstalk effects that are critical in many design scenarios, and reduces to each of the other three design ensembles (complex, test tube, multi-complex) as special cases. 
For reaction pathway engineering, target test tubes are used to represent reactant, intermediate, and product states of the system, as well as to model crosstalk between components. Note that we achieve {\it kinetic design} of a test tube ensemble by performing {\it equilibrium optimization} of a multi-tube ensemble: each target test tube isolates different subsets of components in local equilibrium, enabling optimization of kinetically significant states that would appear insignificant if all components were allowed to interact in a single ensemble. 
For large-scale structure engineering including the possibility of pseudoknots, each target test tube is unpseudoknotted, but by imposing sequence constraints between tubes, it is possible to collectively impose pseudoknotted design requirements. 

## Complex Design
## Test Tube Design

# Getting Started
## Installation
## Examples

## Versions
- **NUPACK 3.0:** 
    - Features:
	    - complex analysis [@Dirks07]
	    - complex design [@Zadeh11b]
	    - test tube analysis [@Dirks07]
	- Executables:
        - `pfunc`,`pairs`, `mfe`, `subopt`, `count`, `energy`, `prob`, `pairs`, 
			`defect`, `complexes`, `concentrations`, `distributions`, `design` 
        - These executables read input files containing comment lines preceded by `%`; blank lines are not permitted.
	- Terminology and notation: 
        - details in @Dirks07  
- **NUPACK 3.1:**
    - New features:
	    - test tube design [@Wolfe15]
	- New executables: 
	    - `tubedesign` and `tubedefect`
		- These executables read `*.np` script files written in v1 of the NUPACK scripting language 
        <!-- (see ``Future Version: Script files'' below). -->
        - In `*.np` script files, a comment begins with `#` and continues for the rest of the line; blank lines are permitted. 
    - Changes to existing executables: 
	    - Name of executable `design` changed to `complexdesign`.
		- Name of executable `defect` changed to `complexdefect`.
		- Updates to the default options and 
				output file formats for executables `complexes`, 
				`concentrations`, and 
				`distributions`. Use option `-v3.0` to revert to NUPACK 3.0 behavior using NUPACK 3.1. 
    - Terminology and notation:
		- details in Section 1.1 of NUPACK 3.1 User Guide
		
- **NUPACK 3.2:** 
    - New features:
	    - constrained multistate test tube design [@Wolfe17]
    - New executables: 
		- `multitubedesign` and  `multitubedefect`
		    - These executables read `*.np` script files written in v2 of the NUPACK scripting language.
			- In `*.np` script files, a comment begins with `#` and continues for the rest of the line; blank lines are permitted. 
		- Terminology and notation:
	        - details in Section 1.1 of NUPACK 3.2 User Guide

- **NUPACK 4.0:** 
    - New features:
	    - unified dynamic programming framework [@Fornace20]
        - all-new code base 
        - Python module
    - Commands: 
		- `energy`, `pfunc`, `prob`, `mfe`, `subopt`, `pairs`, `sample`, `count`, `complex-analysis`, `complex-concentrations`, `tube-analysis`, `complex-defect`, `complex-design`, `tube-defect`, `tube-design`
		- Scripting is done in Python
        - Indices start at 0 (previous versions indexed starting at 1)
	- Terminology and notation:
	    - details in 


## License
**NUPACK Software License Agreement**  
Copyright &copy; 2020. California Institute of Technology. All rights reserved.

Use and redistribution in source form and/or binary form, with or without modification, are permitted for non-commercial academic purposes only, provided that the following conditions are met:

1. Redistributions in source form must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation provided with the distribution.
3. Web applications that use the software in source form or binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in online documentation provided with the web application.
4. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote derivative works without specific prior written permission.

**Disclaimer**  
*This software is provided by the copyright holders and contributors ``as is'' and any express or implied warranties, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. In no event shall the copyright holder or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this software, even if advised of the possibility of such damage.*


# References
