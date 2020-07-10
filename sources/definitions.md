

# Definitions

## Sequence

The **sequence**, $\phi$, of one or more interacting RNA strands is specified as a list of bases $\phi^a\in\{\texttt{A},\texttt{C},\texttt{G},\texttt{U}\}$ for $a=1,\dots,|\phi|$. For DNA, $\phi^a\in\{\texttt{A},\texttt{C},\texttt{G},\texttt{T}\}$.
Nucleic acid sequences are listed $5'$ to $3'$.
<!-- Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1. -->
Unlike NUPACK 3, bases in NUPACK 4 are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand.
For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39. Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.
<!--
A sequence may also contain any of the [degenerate nucleotides codes](https://www.bioinformatics.org/sms/iupac.html): `R`, `M`, `S`, `W`, `K`, `Y`, `V`, `H`, `D`, `B`, or `N`. Such sequences are primarily useful in a design context, and any sequence used in analysis must be fully determined.-->

<hr> 
## Secondary Structure

A **secondary structure**, $s$, of one or more interacting RNA strands is defined by a set of base pairs, each a Watson--Crick pair \[A$\cdot$U or C$\cdot$G\] or a wobble pair \[G$\cdot$U\]). For DNA, the corresponding Watson--Crick pairs are A$\cdot$T or C$\cdot$G and there are no wobble pairs.
A **polymer graph** representation of a secondary structure is constructed by ordering the strands around a circle, drawing the backbones in succession from 5$'$ to 3$'$ around the circumference with a *nick* between each strand, and drawing straight lines connecting paired bases.
A secondary structure is **unpseudoknotted** if there exists a strand ordering for which the polymer graph has no crossing lines, or **pseudoknotted** if all strand orderings contain crossing lines. In NUPACK 4, pseudoknots are excluded from the structural ensemble.
A secondary structure is **connected** if no subset of the strands is free of the others. 

Secondary structures may be specified in one of three ways:

- **dot-parens-plus notation**: Each unpaired base is represented by a dot, each base pair by matching parentheses, and each nick between strands by a plus [@Zadeh11a]. For example, `((...))` specifies that bases 0 and 1 are paired to bases 6 and 5, respectively, while bases 2, 3, and 4 are unpaired. `((+...))` specifies that bases 0 and 1 of strand 0 are paired to bases 4 and 3 of strand 1.

- **run-length encoded dot-parens-plus notation**: As a shorthand for dot-parens-plus, any sequence of consecutive characters in dot-parens-plus may be replaced by the character followed by a number. For instance, `(((((+...........)))))`  may be written as `(5+.11)5`.

- **DU+ notation**: Using DU+ notation, a duplex is represented by `D` and an unpaired region of length nucleotides is represented by `U` [@Zadeh10c]. Each duplex is followed immediately by the substructure (specified in DU+ notation) that is 'enclosed' by the duplex. If this substructure includes more than one element, parentheses are used to denote scope. A nick between strands is specified by a '+'. See the table below for examples.

<!-- 4. **pair list notation**: A list of zero-based indices $p$ such that if $p_i = j$, bases $i$ and $j$ are paired, and if $p_i = i$, base $i$ is unpaired. Any secondary structure, including highly-nested pseudoknots, may be specified in this way. -->

| Dot-parens-plus                       | RLE dot-parens-plus  | DU+ notation |
| ------------------------------------- | -------------------  | ------------ |
| `((((((((((((..........))))))))))))`  |  `(12.10)12`         | `D12 U10`    |
| `((((((((((((+))))))))))))..........` |  `(12+)12.10`        | `D12 + U10`  |
| `((((((((((((+..........))))))))))))` |  `(12+.10)12`        |`D12 (+ U10)` |

**Table:** Examples of dot-parens-plus, run-length-encoded (RLE) dot-parens-plus, and DU+ notation

<img src="/figs/structure.png" alt="Secondary structure" title="Example secondary structure" width="650" />

**Figure:** Comparison of dot-parens-plus, run-length-encoded dot-parens-plus, and DU+ notation.

<hr>

## Complex Ensemble
Consider a complex of $L$ distinct strands (e.g., each with a unique identifier in $\{1,\dots,L\}$) corresponding to strand ordering $\pi$. The **complex ensemble** $\overline\Gamma(\phi)$ contains all connected polymer graphs with no crossing lines for sequence $\phi$ and strand ordering $\pi$ (i.e., all unpseudoknotted secondary structures) [@Dirks07]. (We dispense with our prior convention [@Dirks07,@Zadeh11a,@Zadeh11b] of calling this entity an ''ordered complex''.) As a matter of algorithmic necessity, all of the dynamic programs in NUPACK operate on complex ensemble $\overline\Gamma(\phi)$ treating all strands as distinct. However, in the laboratory, strands with the same sequence are typically indistinguishable with respect to experimental observables. For comparison to experimental data, physical quantities calculated over ensemble $\overline\Gamma(\phi)$ are post-processed
to obtain the corresponding quantities calculated over **complex ensemble** $\Gamma(\phi)$ in which strands with the same sequence are treated as indistinguishable [@Fornace20]. The ensemble $\Gamma(\phi)\subseteq\overline\Gamma(\phi)$ is a maximal subset of distinct secondary structures for strand ordering $\pi$. Two secondary structures are indistinguishable if their polymer graphs can be rotated so that all strands are mapped onto indistinguishable strands, all base pairs are mapped onto base pairs, and all unpaired bases are mapped onto unpaired bases;
otherwise the structures are distinct [@Dirks07].
<!-- A **complex** of $L$ interacting strands with strand ordering, $\pi$, has a **structural ensemble** containing all connected polymer graphs with no crossing lines [@Dirks07]. (We dispense with our prior convention [@Dirks07; @Zadeh11a; @Zadeh11b] of calling this entity an **ordered complex**.)
 -->

<img src="/figs/complex.png" alt="Example complex" width="360"/>

**Figure:** A complex of 3 strands with strand ordering $\pi$ = ABC.





<!-- If a complex contains multiple strands with the same sequence, subtleties arise in the definition of the structural ensemble and in the calculation of experimental observables [@Dirks07,@Fornace20]. Let $\overline\Gamma(\phi)$ denote the structural ensemble in which each strand is treated as distinct (i.e., each strand has a unique identifier in $\{1,\dots,L\}$) and let $\Gamma(\phi)$ denote the ensemble in which strands with the same sequence are treated as indistinguishable. Two secondary structures are indistinguishable if their polymer graphs can be rotated so that all strands are mapped onto indistinguishable strands, all base pairs are mapped onto base pairs, and all unpaired bases are mapped onto unpaired bases; otherwise the structures are distinct [@Dirks07]. The ensemble $\Gamma(\phi)\subseteq\overline\Gamma(\phi)$ is a maximal subset of distinct secondary structures for strand ordering $\pi$.

Consider a complex of $L$ distinct strands (e.g., each with a unique identifier in $\{1,\dots,L\}$) corresponding to strand ordering $\pi$. The **complex ensemble** $\overline\Gamma(\phi)$ contains all connected polymer graphs with no crossing lines for sequence $\phi$ and strand ordering $\pi$ (i.e., all unpseudoknotted secondary structures) [@Dirks07]. (We dispense with our prior convention [\cite{@Dirks07,@Zadeh11a,@Zadeh11b] of calling this entity an **ordered complex**.) -->
<hr>
## Test Tube Ensemble
A **test tube ensemble** is a dilute solution containing a set of strand species, $\Psi^0$, introduced at user-specified concentrations, that interact to form a set of complex species, $\Psi$, each corresponding to a different strand ordering treating strands with the same sequence as indistinguishable [@Dirks07,@Fornace20].
For $L$ strands, there are $(L-1)!$ strand orderings if all strands are different species (e.g., complexes $\pi$ = ABC and $\pi$ = ACB for $L=3$ and strands A, B, C), but fewer than $(L-1)!$ strand orderings if some strands are of the same species (e.g., complex $\pi$ = AAA for $L=3$ with three A strands). By the Representation Theorem [@Dirks07], a secondary structure in the complex ensemble for one strand ordering does not appear in the complex ensemble for any other strand ordering, averting redundancy.
It is often convenient to define $\Psi$ to contain all complex species of up to $L_\mathrm{max}$ strands, although $\Psi$ can be defined to contain arbitrary complex species formed from the strand species in $\Psi^0$.

<img src="/figs/tube.png" alt="Test tube" title="Example test tube" width="190" />

**Figure:** A test tube ensemble containing strain species $\Psi^0 = \{$A,B,C$\}$ interacting to form all complex species $\Psi$ of up to $L_{\rm max} = 3$ strands.

## Free Energy Model
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

<img src="/figs/looptypes.png" alt="Loop Types" width="450"/>  
**Figure:** Canonical loop types for a complex with strand ordering $\pi$ = ABC.

### Coaxial and Dangle Stacking
Within a multiloop or an exterior loop, there is a subensemble of coaxial stacking states between adjacent closing base pairs and dangle stacking states between
closing base pairs and adjacent unpaired bases.
Within a multiloop or exterior loop, a base pair can
form one **coaxial stack** with an adjacent base pair, or can form a **dangle stack** with at most two adjacent unpaired bases; unpaired bases can either form no stack, or can form a dangle stack with at most one adjacent base pair.

<img src="/figs/multiloopstacking.png" alt="Coaxial and dangle stacking states for a multiloop" width="850"/>
**Figure:** Coaxial and dangle stacking states for a multiloop.

<img src="/figs/exteriorloopstacking.png" alt="Coaxial and dangle stacking states for two exterior loops" width="500"/>  
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

### Symmetry Correction
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


<!-- ### Free Energy Parameters
For RNA, we employ temperature-dependent parameters [@Serra95,@Xia98,@Mathews99,@Zuker03,@Lu06,@Turner10]
including coaxial [@Mathews99,@Turner10] and dangle [@Serra95,@Zuker03,@Turner10] parameters
in 1M Na$^+$. For DNA,
we employ temperature-dependent parameters [@Santalucia98,@Zuker03,@Santalucia04]
including coaxial [@Peyret00] and dangle [@Bommarito00,@Zuker03] parameters
in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@Santalucia98,@Peyret00,@Santalucia04]. See [@Fornace20] for details.  
 -->

