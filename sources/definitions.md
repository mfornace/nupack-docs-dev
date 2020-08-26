

## Definitions

### Sequence

The **sequence**, $\phi$, of one or more interacting RNA strands is specified as a list of bases $\phi^a\in\{\texttt{A},\texttt{C},\texttt{G},\texttt{U}\}$ for $a=1,\dots,|\phi|$. For DNA, $\phi^a\in\{\texttt{A},\texttt{C},\texttt{G},\texttt{T}\}$.
Nucleic acid sequences are listed $5'$ to $3'$.
<!-- Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1. -->
Unlike NUPACK 3, bases in NUPACK 4 are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand.
For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39. Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.
<!--
A sequence may also contain any of the [degenerate nucleotides codes](https://www.bioinformatics.org/sms/iupac.html): `R`, `M`, `S`, `W`, `K`, `Y`, `V`, `H`, `D`, `B`, or `N`. Such sequences are primarily useful in a design context, and any sequence used in analysis must be fully determined.-->

<hr>
### Secondary structure

A **secondary structure**, $s$, of one or more interacting RNA strands is defined by a set of base pairs, each a Watson--Crick pair \[A$\cdot$U or C$\cdot$G\] or a wobble pair \[G$\cdot$U\]). For DNA, the corresponding Watson--Crick pairs are A$\cdot$T or C$\cdot$G and there are no wobble pairs.
A **polymer graph** representation of a secondary structure is constructed by ordering the strands around a circle, drawing the backbones in succession from 5$'$ to 3$'$ around the circumference with a *nick* between each strand, and drawing straight lines connecting paired bases.
A secondary structure is **unpseudoknotted** if there exists a strand ordering for which the polymer graph has no crossing lines, or **pseudoknotted** if all strand orderings contain crossing lines. In NUPACK 4, pseudoknots are excluded from the structural ensemble.
A secondary structure is **connected** if no subset of the strands is free of the others.

Secondary structures may be specified one of three ways for NUPACK calculations:

- **dot-parens-plus notation**: Each unpaired base is represented by a dot, each base pair by matching parentheses, and each nick between strands by a plus [@Zadeh11a]. For example, `((...))` specifies that bases 0 and 1 are paired to bases 6 and 5, respectively, while bases 2, 3, and 4 are unpaired. `((+...))` specifies that bases 0 and 1 of strand 0 are paired to bases 4 and 3 of strand 1.

- **run-length encoded dot-parens-plus notation**: As a shorthand for dot-parens-plus, any sequence of consecutive characters in dot-parens-plus may be replaced by the character followed by a number. For instance, `(((((+...........)))))`  may be written as `(5+.11)5`.

- **DU+ notation**: Using DU+ notation, a duplex is represented by `D` and an unpaired region of length nucleotides is represented by `U` [@Zadeh10c]. Each duplex is followed immediately by the substructure (specified in DU+ notation) that is 'enclosed' by the duplex. If this substructure includes more than one element, parentheses are used to denote scope. A nick between strands is specified by a '+'. See the table below for examples.

In mathematical expressions, it is convenient to represent secondary structure $s$ using a **structure matrix** $S(s)$ with entries $S^{a,b}(s) = 1$ if structure $s$ contains base pair $a\cdot b$ and $S^{a,b}(s) = 0$ otherwise. Abusing notation, the entry $S^{a,a}(s) = 1$ if base $a$ is unpaired in structure $s$ and $0$ otherwise. Hence, $S(s)$ is a symmetric matrix with row and column sums of 1.


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

### Complex ensemble
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
### Test tube ensemble
A **test tube ensemble** is a dilute solution containing a set of strand species, $\Psi^0$, introduced at user-specified concentrations, that interact to form a set of complex species, $\Psi$, each corresponding to a different strand ordering treating strands with the same sequence as indistinguishable [@Dirks07,@Fornace20].
For $L$ strands, there are $(L-1)!$ strand orderings if all strands are different species (e.g., complexes $\pi$ = ABC and $\pi$ = ACB for $L=3$ and strands A, B, C), but fewer than $(L-1)!$ strand orderings if some strands are of the same species (e.g., complex $\pi$ = AAA for $L=3$ with three A strands). By the Representation Theorem [@Dirks07], a secondary structure in the complex ensemble for one strand ordering does not appear in the complex ensemble for any other strand ordering, averting redundancy.
It is often convenient to define $\Psi$ to contain all complex species of up to $L_\mathrm{max}$ strands, although $\Psi$ can be defined to contain arbitrary complex species formed from the strand species in $\Psi^0$.

<img src="/figs/tube.png" alt="Test tube" title="Example test tube" width="190" />

**Figure:** A test tube ensemble containing strain species $\Psi^0 = \{$A,B,C$\}$ interacting to form all complex species $\Psi$ of up to $L_{\rm max} = 3$ strands.

### Free energy model
For each (unpseudoknotted connected) secondary structure $s\in\overline{\Gamma}(\phi)$, the free energy,
$\overline{\Delta G}(\phi,s)$, is estimated as the sum of the empirically determined free energies of the
constituent loops [@Santalucia98,@Xia98,@Mathews99,@Zuker03,@Lu06,@Turner10] plus a strand association penalty [@Bloomfield00], $\Delta
G^\textrm{assoc}$, applied $L-1$ times for a
complex of $L$ strands:
\begin{align}
\overline{\Delta G}(\phi,s) = (L-1)\,\Delta G^\textrm{assoc}\, + \sum_{\mathrm{loop} \in s} \Delta G(\mathrm{loop}). \label{eq:dGbar}
\end{align}

#### Loop free energies
The loop free energy, $\Delta G(\mathrm{loop})$, is modeled for the different loop types as follows:

- A **hairpin loop** is closed by a single base-pair $a\cdot b$. The loop free energy, $\Delta G^\mathrm{hairpin}_{a,b}$, depends on sequence and loop size.
- An **interior loop** is closed by two base pairs ($a\cdot b$ and $d\cdot e$ with $a<d<e<b$). The loop free energy, $\Delta G^\mathrm{interior}_{a,d,e,b}$ depends on sequence, loop size, and loop asymmetry. **Bulge loops** (where either $d=a+1$ or $e=b-1$) and **stacked pairs** (where both $d=a+1$ and $e=b-1$) are treated as special cases of interior loops.
- A **multiloop** is closed by three or more base pairs.
The loop free energy is modeled as the sum of three sequence-independent penalties:
$\Delta G^\mathrm{multi}_\mathrm{init}$ for formation of a multiloop, $\Delta G^\mathrm{multi}_\mathrm{bp}$ for each closing base pair, $\Delta G^\mathrm{multi}_\mathrm{nt}$ for each unpaired nucleotide inside the multiloop,
plus a sequence-dependent penalty: $\Delta G^\mathrm{terminalbp}_{a, b}$ for each closing pair $a\cdot b$.
- An **exterior loop** contains a nick between strands and any number of closing base pairs.
The exterior loop free energy is the sum of $\Delta G^\mathrm{terminalbp}_{a, b}$ over all closing base pairs $a\cdot b$. Hence, an unpaired strand has a free energy of zero, corresponding to the reference state [@Dirks07].

<img src="/figs/looptypes.png" alt="Loop Types" width="450"/>
**Figure:** Canonical loop types for a complex with strand ordering $\pi$ = ABC.

#### Coaxial and dangle stacking
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
Let $s^\shortparallel\in s$ denote a stacking state of the paired and unpaired bases in $s$. We may equivalently define the free energy of secondary structure $s$ in terms of the **stacking state
free energies**
\begin{align}
\overline{\Delta G}(\phi,s^\shortparallel)
\end{align}
for all stacking states $s^\shortparallel\in s$:
\begin{align}
\overline{\Delta G}(\phi,s) = -kT \log \sum_{s^\shortparallel\in s}e^{-\overline{\Delta G}(\phi,s^\shortparallel)/kT} \label{eq:stacksum}
\end{align}
Let $\overline\Gamma^\shortparallel(\phi)$ denote the ensemble of stacking states corresponding to the complex ensemble of secondary structures $\overline\Gamma(\phi)$.

#### Symmetry correction
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


<!-- #### Free Energy Parameters
For RNA, we employ temperature-dependent parameters [@Serra95,@Xia98,@Mathews99,@Zuker03,@Lu06,@Turner10]
including coaxial [@Mathews99,@Turner10] and dangle [@Serra95,@Zuker03,@Turner10] parameters
in 1M Na$^+$. For DNA,
we employ temperature-dependent parameters [@Santalucia98,@Zuker03,@Santalucia04]
including coaxial [@Peyret00] and dangle [@Bommarito00,@Zuker03] parameters
in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@Santalucia98,@Peyret00,@Santalucia04]. See [@Fornace20] for details.
 -->

### Physical quantities
Consider a [test tube ensemble](definitions.md#test-tube-ensemble) containing an arbitrary set of strand species $\Psi^0$
interacting to form an arbitrary set of complex species $\Psi$. Let $j\in\Psi$ denote a complex with sequence $\phi_j$ and [complex ensembles](definitions.md#complex-ensemble)
$\overline\Gamma(\phi_j)$ (treating all strands as distinct) and $\Gamma(\phi_j)$ (treating strands with the same seqeuence as indistinguishable).
NUPACK calculates [@Dirks07,@Fornace20] a number of physical quantities over these ensembles.


#### Partition function
For complex $j$, the partition function evaluated over ensemble $\Gamma(\phi_j)$ treating
strands with the same sequence as indistinguishable is denoted

\begin{align}
Q(\phi_j) = \sum_{s\in\Gamma(\phi_j)}e^{-\Delta G(\phi_j,s)/kT}.
\end{align}

For complex $j$, the corresponding complex free energy is
\begin{align}
\Delta G(\phi_j) \equiv -kT \log(Q(\phi_j)).
\end{align}

#### Structure free energy
For complex $j$, the secondary structure free energy treating strands with the same sequence as indistinguishable is denoted
\begin{align}
\Delta G(\phi_j,s).
\end{align}
If the physical model includes [coaxial and dangle stacking](index.md#coaxial-and-dangle-stacking), the structure free energy will include stacking contributions $\Delta G^\textrm{stacking}$. If the secondary structure $s$ has a rotational symmetry, the structure free energy will include the [symmetry correction](index.md#symmetry-correction) $\Delta G^\textrm{sym}(\phi_j,s)$.


#### Equilibrium structure probability
For complex $j$, the equilibrium structure probability of any secondary structure $s\in\Gamma(\phi_j)$ treating
strands with the same sequence as indistinguishable is denoted
\begin{align}
p(\phi_j,s)= e^{-\Delta G(\phi_j,s)/kT}/Q(\phi_j).
\end{align}


#### Boltzmann-sampled structures
For complex $j$, a set of $J$ secondary structures Boltzmann-sampled from ensemble $\Gamma(\phi_j)$ treating strands with the same sequence as indistinguishable is denoted

\begin{align}
\Gamma_\mathrm{sample}(\phi,J) \in \Gamma(\phi)
\end{align}




#### Equilibrium base-pairing probabilities
For complex $j$, the base-pairing probability matrix $\overline P(\phi_j)$ has entries $\overline P^{a,b}(\phi_j)\in[0,1]$ corresponding to the probability

\begin{align}
\overline P^{a,b}(\phi_j) = \sum_{s\in\overline\Gamma(\phi_j)}\overline p(\phi,s)S^{a,b}(s)
\end{align}

that base pair $a\cdot b$ forms at equilibrium within ensemble $\overline\Gamma(\phi_j)$, treating all strands as distinct.
 Here, $S(s)$ is the [structure matrix](definitions.md#secondary-structure) and $\overline p(s)$ the equilibrium probability of structure $s\in\overline\Gamma(\phi_j)$, treating all strands as distinct. Abusing notation, the entry $\overline P^{i,i}(\phi) \in [0,1]$ denotes the equilibrium probability that base $i$ is unpaired over ensemble $\overline\Gamma(\phi)$. Hence $\overline P(\phi)$ is symmetric matrix with row and column sums of 1.


#### MFE proxy structure
For complex $j$, the free energy of the minimum free energy (MFE) stacking state
$s_\mathrm{MFE}^\shortparallel(\phi) \in\overline\Gamma^\shortparallel(\phi)$
treating all strands as distinct is denoted

\begin{align}
\overline{\Delta G}(\phi_j,s^\shortparallel_{\rm MFE}) \equiv \min_{s^\shortparallel\in\overline\Gamma^\shortparallel(\phi_j)} \overline{\Delta G}(\phi_j,s^\shortparallel).
\end{align}

The corresponding MFE proxy structure is

\begin{align}
s_\mathrm{MFE'} \equiv \{s\in\overline\Gamma(\phi_j) | s^\shortparallel_\mathrm{MFE}\!\in\! s, s^\shortparallel_\mathrm{MFE}(\phi_j) = \arg \min_{s^\shortparallel\in\overline\Gamma^\shortparallel(\phi_j)} \overline{\Delta G}(\phi_j,s^\shortparallel)\},
\end{align}

defined as the secondary structure containing the MFE stacking state within its subensemble.
The free energy of the MFE proxy structure is
\begin{align}
\overline{\Delta G}(\phi,s_\mathrm{MFE'}).
\end{align}
There may be more than one MFE stacking state, each corresponding to the same or different MFE proxy structures.



#### Suboptimal proxy structures
For complex $j$, the set of suboptimal proxy secondary structures with stacking states within a specified $\Delta G_\mathrm{gap}\ge 0$ of the MFE stacking state is denoted

\begin{align}
\overline\Gamma_{\rm subopt}(\phi_j,\Delta G_{\rm gap}) = \{s\in\overline\Gamma(\phi_j) | s^\shortparallel\!\in\! s, \overline{\Delta G}(\phi_j,s^\shortparallel) \le \overline{\Delta G}(\phi_j,s^\shortparallel_{\rm MFE}) + \Delta G_{\rm gap}\}.
\end{align}



#### Complex ensemble defect

For complex $j$ with target structure $s_j$, the dimensional complex ensemble defect
\begin{align}
    n(\phi_j,s_j) 	& = |\phi_j| - \sum_{\begin{array}{c}
                            1 \leq a \leq |\phi_j|,\\
                            1 \leq b \leq |\phi_j|
                            \end{array}}
                            \overline P^{a, b}(\phi_j) S^{a,b}(s_j),
\end{align}
quantifies the equilibrium number of incorrectly paired nucleotides over the ensemble $\overline\Gamma(\phi_j)$ relative to $s_j$ [@dirks04,@zadeh11b]. Here, $\overline P(\phi_j)$ is the equilibrium base-pairing probability
matrix and $S(s_j)$ is the [target structure matrix](definitions.md#secondary-structure) for $s_j$. The **normalized complex ensemble defect** is then denoted

\begin{align}
{\mathcal N}_j \equiv n(\phi_j,s_j)/|\phi_j| ~~~\in (0,1)
\end{align}

representing the equilibrium fraction of incorrectly paired nucleotides evaluated over the ensemble of complex $j$ relative to target structure $s_j$.

For a set of complexes $\Psi$, the normalized complex ensemble defect can be generalized to a multi-complex ensemble defect
\begin{align}
{{\mathcal N}} ~\equiv ~\frac{1}{|\Psi|}\sum_{j\in\Psi} {\mathcal N_j} ~~~\in(0,1)
\end{align}
quantifying the average equilibrium fraction of incorrectly paired nucleotides over the complexes $j\in\Psi$.
As ${\mathcal N}_j$ approaches zero, the complex $j$ is dominated by its target structure, $s_{j}$.


#### Complex ensemble size
For complex $j$, the number of secondary structures in the complex ensemble, treating all strands as distinct, is denoted:
\begin{align}
|\overline\Gamma(\phi_j)|.
\end{align}
The corresponding number of stacking states is denoted
\begin{align}
|\overline\Gamma^\shortparallel(\phi_j)|.
\end{align}



#### Equilibrium complex concentrations
For the set of complexes $\Psi$ in the test tube ensemble, the set of equilibrium complex concentrations is denoted

\begin{align}
x_\Psi \equiv x_j~~~~~~ \forall j\in\Psi,
\end{align}
These concentrations are the unique solution to the strictly convex optimization problem [@Dirks07]:

\begin{align}
& \min_{x_{\Psi}} \sum_{j\in\Psi} x_j(\log x_j - \log Q_j - 1) \\[6pt]
& \mathrm{subject~to~~~~} \sum_{j \in \Psi}A_{i,c} \,x_j = x_i^0 ~~~~~~ \forall i\in\Psi^0,
\end{align}

expressed in terms of the previously calculated set of partition functions $Q_\Psi$.
Here, the constraints impose conservation of mass: $A$ is the stoichiometry matrix such that $A_{i,j}$
is the number of strands of type $i$ in complex $j$,
and $x^0_i$ is the total concentration of strand $i$ present in the test tube. Based on dimensional analysis [@Dirks07], the convex optimization problem is formulated in terms of mole fractions, but for convenience, NUPACK accepts molar strand concentrations $[i]^0 = x_i^0 \rho_\mathrm{H_2O}$ as inputs and returns molar complex concentrations
$[j] = x_j\rho_\mathrm{H_2O}$ as outputs, where $\rho_\mathrm{H_2O}$ is the molarity of water.
Hence, the user specifies the set of molar strand concentrations $[i]^0~~\forall i\in\Psi^0$
and NUPACK calculates the set of molar complex concentrations $[j]~~ \forall j\in\Psi$.

#### Test tube ensemble pair fractions
For the test tube ensemble, the ensemble pair fraction

\begin{align}
f_A(a_A\cdot b_B)
\end{align}

denotes the fraction of A strands that form base pair $a_A\cdot b_B$. Correspondingly,

\begin{align}
f_B(a_A\cdot b_B)
\end{align}

denotes the fraction of B strands that form base pair $a_A\cdot b_B$.
These base-pairing observables depend on the set of equilibrium concentrations $x_\Psi$ and the set of base-pairing probability matrices $\overline P_\Psi$. The number of distinct bases in the test tube is:

\begin{align}
N_{\rm distinct}\equiv \sum_{i=1}^{|\Psi^0|} N_i
\end{align}

representing the total number of bases in all $|\Psi^0|$ strand species. Numbering the distinct bases from 1 to $N_{\rm distinct}$, the ensemble pair fractions, $f_A(a_A\cdot b_B)$, are then stored as an (asymmetric) $N_{\rm distinct}\times N_{\rm distinct}$ matrix. Abusing notation, the entry $f_A^{a_A,a_A} \in [0,1]$ denotes the equilibrium fraction of base $a$ on strand $A$ that is unpaired in the test tube ensemble. Hence, the matrix of test tube ensemble pair fractions is asymmetric with row and column sums of 1.



#### Test tube ensemble defect
Consider test tube $h$ containing a
set of desired **on-target complexes**, $\Psi_h^{\rm on}$,
and a set of undesired **off-target complexes**, $\Psi_h^{\rm off}$. The set of complexes in the test tube is then:

\begin{align}
\Psi_h = \Psi_h^{\rm on} \cup \Psi_h^{\rm off}.
\end{align}

Let each on-target complex, $j\in\Psi_h^{\rm on}$, have a target secondary structure,
$s_j$, and a target concentration, $y_{h,j}$. Let each off-target complex, $j\in\Psi_h^{\rm off}$, have a vanishing target concentration ($y_{h,j} = 0$)
and no target structure ($s_j = \emptyset$). The dimensional test tube ensemble defect,

\begin{align}
C(\phi_{\Psi_h}, s_{\Psi_h}, y_{h,\Psi_h}) = \sum_{j\in\Psi^{\rm on}_h} \Bigl[ n(\phi_{j},s_{j})\min (x_{h,j},y_{h,j}) + |\phi_{j}|\max(y_{h,j}-x_{h,j},0)\Bigr]
\end{align}

quantifies the equilibrium concentration of incorrectly paired nucleotides over the ensemble of test tube $h$ [@Wolfe15]. Here, $x_{h,j}$ is the equilibrium concentration of complex $j$
in tube $h$.
For each on-target complex, $j\in\Psi^{\rm on}_h$, the first term in the sum represents the **structural defect**,
quantifying the concentration of nucleotides that are in an incorrect base-pairing state
within the ensemble of complex $j$, and the second term in the sum represents the **concentration defect**,
quantifying the concentration
of nucleotides that are in an incorrect base-pairing state because
there is a deficiency in the concentration of complex $j$. For each off-target complex, $j\in\Psi^{\rm off}_h$,
the structural and concentration defects are identically zero, since $y_{h,j}=0$.
This does not mean that the defects associated with off-targets are ignored.
By conservation of mass, non-zero off-target concentrations imply
deficiencies in on-target concentrations, and these concentration defects are quantified by the equation above [@Wolfe15].
The **normalized test tube ensemble defect** is then denoted

\begin{align}
{\mathcal M}_h\equiv C_h/y^{\rm nt}_h \in (0,1)
\end{align}
representing the equilibrium fraction of incorrectly paired nucleotides in tube $h$.
Here,

\begin{align}
y^{\rm nt}_h \equiv \sum_{j\in\Psi^{\rm on}_h} |\phi_j|y_{h,j}
\end{align}

is the total concentration of nucleotides in tube $h$.
As ${\mathcal M}_h$ approaches zero, each on-target complex, $j\in \Psi^{\rm on}_h$, approaches its
target concentration, $y_{h,j}$, and is dominated by its target structure, $s_{j}$, and
each off-target complex, $j\in\Psi^{\rm off}_h$, forms with vanishing target concentration.

For a set of test tubes $\Omega$, the test tube ensemble defect can be generalized to a multi-tube ensemble defect

\begin{align}
   {\mathcal M} \equiv \frac{1}{\lvert \Omega \rvert} \sum_{h \in \Omega} {\mathcal M}_h ~~~\in (0,1)
\end{align}

quantifying the average equilibrium fraction of incorrectly paired nucleotides over the test tubes $h\in\Omega$.


