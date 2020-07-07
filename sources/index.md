# Overview

## About
NUPACK is a growing software suite for the analysis and design of nucleic acid structures, devices, and systems serving the needs of researchers in the fields of nucleic acid nanotechnology, molecular programming, synthetic biology, and across the life sciences more broadly. Much of this software can be conveniently run using the NUPACK web application at [nupack.org](http://www.nupack.org) [@Zadeh11a]. This User Guide provides documentation for the NUPACK Source Code.

When finishing a project that has benefited from NUPACK calculations, please remember to [cite](index.md#citation) the NUPACK web application and algorithms appropriately; citations are an important component in helping to secure funding for NUPACK development and maintenance. Please email us with questions, comments, feature requests, and bug reports at <support@nupack.org>.

— The NUPACK Team

<hr> 


## Problem Categories
NUPACK algorithms address two fundamental classes of problems:

- **Sequence analysis:** given a set of DNA or RNA strands, analyze the equilibrium base-pairing properties over a specified ensemble.
- **Sequence design:** given a set of desired equilibrium base-pairing properties, design the sequences of a set of DNA or RNA strands over a specified ensemble. Sequence design is performed subject to diverse user-specified sequence constraints including composition constraints, complementarity constraints, pattern prevention constraints, and biological constraints.

<img src="/figs/NUPACK.png" alt="NUPACK Analysis and Design" title="NUPACK Analysis and Design" width="700"/>
**Figure:** Sequence analysis and design using NUPACK.

NUPACK algorithms operate over two fundamental ensembles:

- **Complex ensemble:** the ensemble of all (unpseudoknotted connected) secondary structures for an arbitrary number of interacting RNA or DNA strands.
- **Test tube ensemble:** the ensemble of a dilute solution containing an arbitrary number of RNA or DNA strand species (introduced at user-specified concentrations) interacting to form an arbitrary number of complex species.

Furthermore, to enable reaction pathway engineering of dynamic hybridization cascades or large-scale structural engineering including pseudoknots, NUPACK generalizes sequence analysis and design to multi-complex and multi-tube ensembles [@Wolfe17].

NUPACK capabilities are presented in three categories: 

- **Analysis:** Analyze the equilibrium base-pairing properties one or more test tube ensembles (or one or more complex ensembles). These are the all-purpose sequence analysis tools.
- **Design:** Design the the sequences for one or more test tube ensembles (or one or more complex ensembles). These are the all-purpose sequence design tools. 
- **Utilities:** Analyze or design a single complex ensemble. These are quick tools applicable when your ensemble is a single complex. 

<hr> 

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
### Secondary Structure

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

### Complex Ensemble
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
### Test Tube Ensemble
A **test tube ensemble** is a dilute solution containing a set of strand species, $\Psi^0$, introduced at user-specified concentrations, that interact to form a set of complex species, $\Psi$, each corresponding to a different strand ordering treating strands with the same sequence as indistinguishable [@Dirks07,@Fornace20].
For $L$ strands, there are $(L-1)!$ strand orderings if all strands are different species (e.g., complexes $\pi$ = ABC and $\pi$ = ACB for $L=3$ and strands A, B, C), but fewer than $(L-1)!$ strand orderings if some strands are of the same species (e.g., complex $\pi$ = AAA for $L=3$ with three A strands). By the Representation Theorem [@Dirks07], a secondary structure in the complex ensemble for one strand ordering does not appear in the complex ensemble for any other strand ordering, averting redundancy.
It is often convenient to define $\Psi$ to contain all complex species of up to $L_\mathrm{max}$ strands, although $\Psi$ can be defined to contain arbitrary complex species formed from the strand species in $\Psi^0$.

<img src="/figs/tube.png" alt="Test tube" title="Example test tube" width="190" />

**Figure:** A test tube ensemble containing strain species $\Psi^0 = \{$A,B,C$\}$ interacting to form all complex species $\Psi$ of up to $L_{\rm max} = 3$ strands.

### Free Energy Model
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

#### Coaxial and Dangle Stacking
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

#### Symmetry Correction
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




<hr> 


## Citation

For citation, please select from the list below as appropriate for your application: 



**NUPACK Web Application**

- Run jobs online at [nupack.org](http://www.nupack.org)  
	- J. N. Zadeh, C. D. Steenberg, J. S. Bois, B. R. Wolfe, M. B. Pierce, A. R. Khan, R. M. Dirks, N. A. Pierce. NUPACK: analysis and design of nucleic acid systems. [*J Comput Chem*](http://onlinelibrary.wiley.com/doi/10.1002/jcc.21596/abstract), 32:170–173, 2011. ([pdf](http://www.nupack.org/download- s/serve_public_file/jcc11a.pdf?type=pdf))

**NUPACK Analysis Algorithms**  

- Complex analysis and test tube analysis
	- M.E. Fornace, N.J. Porubsky, and N.A. Pierce (2020). A unified dynamic programming framework for the analysis of interacting nucleic acid strands: enhanced models, scalability, and speed. In revision. 
	- R. M. Dirks, J. S. Bois, J. M. Schaeffer, E. Winfree, and N. A. Pierce. Thermodynamic analysis of interacting nucleic acid strands. [*SIAM Rev*](http://epubs.siam.org/doi/abs/10.1137/060651100), 49:65-88, 2007. ([pdf](http://www.nupack.org/downloads/serve_public_file/sirev07.pdf?type=pdf))  

- Pseudoknot analysis  
	- R. M. Dirks and N. A. Pierce. An algorithm for computing nucleic acid base-pairing probabilities including pseudoknots. [*J Comput Chem*](http://onlinelibrary.wiley.com/doi/10.1002/jcc.10296/abstract), 25:1295-1304, 2004. ([pdf](http://www.nupack.org/downloads/serve_public_file/jcc04.pdf?type=pdf))
	- R. M. Dirks and N. A. Pierce. A partition function algorithm for nucleic acid secondary structure including pseudoknots. [*J Comput Chem*](http://onlinelibrary.wiley.com/doi/10.1002/jcc.20057/abstract), 24:1664-1677, 2003. ([pdf](http://www.nupack.org/downloads/serve_public_file/jcc03.pdf?type=pdf), [supp info](http://www.nupack.org/downloads/serve_public_file/jcc03_supp.pdf?type=pdf))

**NUPACK Design Algorithms**

- Multi-tube design
	- B. R. Wolfe, N. J. Porubsky, J. N. Zadeh, R. M. Dirks, and N. A. Pierce. Constrained multistate sequence design for nucleic acid reaction pathway engineering. [*J Am Chem Soc*](http://pubs.acs.org/doi/abs/10.1021/jacs.6b12693), 139:3134-3144, 2017. ([pdf](), [supp info]())

- Test tube design
	- B. R. Wolfe and N. A. Pierce. Sequence design for a test tube of interacting nucleic acid strands. [*ACS Synth Biol*](http://pubs.acs.org/doi/abs/10.1021/sb5002196), 4:1086-1100, 2015. ([pdf](), [supp info](), [supp tests]())

- Complex design
	- J. N. Zadeh, B. R. Wolfe, and N. A. Pierce. Nucleic acid sequence design via efficient ensemble defect optimization. [*J Comput Chem*](http://onlinelibrary.wiley.com/doi/10.1002/jcc.21633/abstract), 32:439–452, 2011. ([pdf](), [supp info](), [supp tests]())

- Design paradigms
	- R. M. Dirks, M. Lin, E. Winfree, and N. A. Pierce. Paradigms for computational nucleic acid design. [*Nucl Acids Res*](https://academic.oup.com/nar/article/32/4/1392/1038453), 32:1392-1403, 2004. ([pdf](), [supp info](), [supp seqs]())




## Acknowledgments
We thank all the NUPACK users that have helped out as beta testers over the years, as well as the many NUPACK users that have emailed \texttt{support@nupack.org} to request features or report bugs. 
NUPACK is supported by the National Science Foundation (NSF-OAC-1835414) and by the Beckman Institute at Caltech (PMTC)
NUPACK has previously been supported by the National Science Foundation 
(NSF-CCF-1317694, NSF-CCF-0832824, NSF-CHE-0533064, NSF-DMS-0506468, NSF-CAREER-0448835), 
by the Gordon and Betty Moore Foundation (GBMF2809), by the John Simon Guggenheim Memorial Foundation, 
by the National Institutes of Health (P50 HG004071), by the Ralph M. Parsons Foundation, and by the Charles Lee Powell Foundation.



<!-- A **test tube** may contain an arbitrary number of strand species interacting to form an arbitrary number of complex species in a dilute solution. Let $\Psi^0$ denote the set of strand species that interact in a test tube to form the set of complex species $\Psi$. It is often convenient to define $\Psi$ to contain all complexes of up to some size $L_{\rm max}$.

Each complex $j\in\Psi$ corresponds to a distinct strand ordering $\pi_j$ of $L$ strands for $L\in\{1,\dots,L_{\rm max}\}$. $L$ distinct strands can be ordered around a circle in $(L-1)!$ distinct ways (e.g., strands $A$, $B$, and $C$ can be ordered $ABC$ and $ACB$). If some of the $L$ strands are of the same species, there will be fewer than $(L-1)!$ distinct strand orderings (e.g., strands $A$, $A$, and $B$ can only be ordered $AAB$). For a given set of $L$ strands, each unpseudoknotted connected secondary structure is found in the structural ensemble, $\Gamma_j$, corresponding to exactly one strand ordering, $\pi_j$ (i.e., exactly one complex $j\in\Psi$) [@Dirks07].

 -->

<!-- For sequence $\phi$ and secondary structure, $s$, the **free energy**, $\Delta G(\phi,s)$, is calculated using nearest-neighbor empirical parameters for RNA [@Serra95; @Mathews99; @Zuker03] in 1M Na$^+$ or for DNA [@SantaLucia98; @Zuker03] in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@SantaLucia04; @Koehler05]. The zero free energy reference state for all calculations is a system where all relevant strands are present with no base pairs [@Dirks07]. -->

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


## Versions

- **NUPACK 3.0**
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
- **NUPACK 3.1**
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

- **NUPACK 3.2**
    - New features:
	    - constrained multistate test tube design [@Wolfe17]
    - New executables:
		- `multitubedesign` and  `multitubedefect`
		    - These executables read `*.np` script files written in v2 of the NUPACK scripting language.
			- In `*.np` script files, a comment begins with `#` and continues for the rest of the line; blank lines are permitted.
		- Terminology and notation:
	        - details in Section 1.1 of NUPACK 3.2 User Guide

- **NUPACK 4.0**
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


