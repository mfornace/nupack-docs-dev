# Conventions

## Common notation

NUPACK algorithms are formulated in terms of nucleic acid secondary structure. In NUPACK 4, pseudoknots are always excluded from the structural ensemble.

- The **sequence**, $\phi$, of one or more interacting RNA strands is specified as a list of bases $\phi^a\in\{$A,C,G,U$\}$ for $a=1,\dots,|\phi|$ (T replaces U for DNA).
- A **secondary structure**, $s$, of one or more interacting RNA strands is defined by a set of base pairs (each a Watson--Crick pair \[A$\cdot$U or C$\cdot$G\] or a wobble pair \[G$\cdot$U\]).
- A **polymer graph** representation of a secondary structure is constructed by ordering the strands around a circle, drawing the backbones in succession from 5$'$ to 3$'$ around the circumference with a *nick* between each strand, and drawing straight lines connecting paired bases.
- A secondary structure is *unpseudoknotted* if there exists a strand ordering for which the polymer graph has no crossing lines. A secondary structure is *connected* if no subset of the strands is free of the others.
- A **complex** of $L$ interacting strands with strand ordering, $\pi$, has a **structural ensemble** containing all connected polymer graphs with no crossing lines [@Dirks07]. (We dispense with our prior convention [@Dirks07; @Zadeh11a; @Zadeh11b] of calling this entity an **ordered complex**.)

If a complex contains multiple strands with the same sequence, subtleties arise in the definition of the structural ensemble and in the calculation of experimental observables [@Dirks07]. Let $\Gamma$ denote the structural ensemble in which each strand is treated as distinct (i.e., each strand has a unique identifier in $\{1,\dots,L\}$) and let $\Gamma'$ denote the ensemble in which strands with the same sequence are treated as indistinguishable. Two secondary structures are indistinguishable if their polymer graphs can be rotated so that all strands are mapped onto indistinguishable strands, all base pairs are mapped onto base pairs, and all unpaired bases are mapped onto unpaired bases; otherwise the structures are distinct [@Dirks07]. The ensemble $\Gamma'\subseteq\Gamma$ is a maximal subset of distinct secondary structures for strand ordering $\pi$.

A **test tube** may contain an arbitrary number of strand species interacting to form an arbitrary number of complex species in a dilute solution. Let $\Psi^0$ denote the set of strand species that interact in a test tube to form the set of complex species $\Psi$. It is often convenient to define $\Psi$ to contain all complexes of up to some size $L_{\rm max}$. Each complex $j\in\Psi$ corresponds to a distinct strand ordering $\pi_j$ of $L$ strands for $L\in\{1,\dots,L_{\rm max}\}$. $L$ distinct strands can be ordered around a circle in $(L-1)!$ distinct ways (e.g., strands $A$, $B$, and $C$ can be ordered $ABC$ and $ACB$). If some of the $L$ strands are of the same species, there will be fewer than $(L-1)!$ distinct strand orderings (e.g., strands $A$, $A$, and $B$ can only be ordered $AAB$). For a given set of $L$ strands, each unpseudoknotted connected secondary structure is found in the structural ensemble, $\Gamma_j$, corresponding to exactly one strand ordering, $\pi_j$ (i.e., exactly one complex $j\in\Psi$) [@Dirks07].

For sequence $\phi$ and secondary structure, $s$, the **free energy**, $\Delta G(\phi,s)$, is calculated using nearest-neighbor empirical parameters for RNA [@Serra95; @Mathews99; @Zuker03] in 1M Na$^+$ or for DNA [@SantaLucia98; @Zuker03] in user-specified concentrations of Na$^+$ and Mg$^{++}$ [@SantaLucia04; @Koehler05]. The zero free energy reference state for all calculations is a system where all relevant strands are present with no base pairs [@Dirks07].

## Conventions

Unlike NUPACK 3, NUPACK 4 uses zero-based indices exclusively. The first index of any sequence is 0, not 1.

Nucleic acid sequences are listed $5'$ to $3'$. The bases in a complex are indexed starting with 0 at the $5'$-most base of the first strand and ending at the $3'$-most base of the last strand. For example, if a complex has three strands of length 15, 20, and 13, respectively, the fifth base of the third strand has index 39.

Valid bases are `A`, `C`, `G`, `T`, and `U`. For RNA calculations, `T` is automatically converted to `U`, and vice versa for DNA calculations.

Secondary structures are specified in one of four ways:

1. **dot-parens-plus**: Each unpaired base is represented by a dot, each base pair by matching parentheses, and each nick between strands by a plus [@Zadeh11a]. For example, `((...))` specifies that bases 0 and 1 are paired to bases 6 and 5, respectively, while bases 2, 3, and 4 are unpaired. `((+...))` specifies that bases 0 and 1 of strand 0 are paired to bases 4 and 3 of strand 1.

2. **run-length encoded dot-parens-plus**: As a shorthand for dot-parens-plus, any sequence of consecutive characters in dot-parens-plus may be replaced by the character followed by a number. For instance, `(((((+...........)))))`  may be written as `(5+.11)5`.

3. **DU+**: Using DU+ notation, a duplex is represented by `D` and an unpaired region of length nucleotides is represented by `U` [@Zadeh10c]. Each duplex is followed immediately by the substructure (specified in DU+ notation) that is 'enclosed' by the duplex. If this substructure includes more than one element, parentheses are used to denote scope. A nick between strands is specified by a '+'. See the table below for examples.

4. **pair list**: A list of zero-based indices $p$ such that if $p_i = j$, bases $i$ and $j$ are paired, and if $p_i = i$, base $i$ is unpaired. Any secondary structure, including highly-nested pseudoknots, may be specified in this way.

| Dot-parens-plus                       | DU+ notation | Run-length encoded  |
| ------------------------------------- |  ---------   | -----------         |
| `((((((((((((..........))))))))))))`  | `D12U10`     | `(12.10)12`         |
| `((((((((((((+))))))))))))..........` | `D12+U10`    | `(12+)12.10`        |
| `((((((((((((+..........))))))))))))` | `D12(+U10)`  | `(12+.10)12`        |

## Citations



