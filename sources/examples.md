## Jupyter notebooks

See the following usage examples derived from Jupyter notebooks that are bundled with NUPACK 4. You may also view these notebooks on [nbviewer](https://nbviewer.jupyter.org/github/mfornace/nupack-nbviewer/tree/master/) or [GitHub](https://github.com/mfornace/nupack-nbviewer/).

1. [Analysis](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/Analysis.ipynb)
2. [Design](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/Design.ipynb) (duplicate of the Design documentation page right now.)
3. [Conversion from NUPACK 3](https://github.com/mfornace/nupack-documentation/blob/docs/notebooks/Conversion-From-NUPACK3.ipynb)

## TODO: Other?

**TODO** Currently the above links are to github, but we can switch to nbviewer once they're public.



## Examples
**TODO make sure this public?**

The following cell imports functions from packages necessary for bokeh visualization of design progress and design results. The function ```run_and_display``` runs the design in a separate thread to allow visualization of design progress in the notebook during design. The function ```notebook_results``` takes a ```DesignResult``` object, saves it to a file (temporary or user specified), and the loads this file into an interactive panel for exploring design defects.


```python
from nupack.visualize import run_and_display
from nupack.residuals import notebook_results
```

### Design Evaluation Example (Example 7 from NUPACK 3.2 User Guide)

```python
from nupack import *
# set physical parameters
design.model = ModelSettings(material='rna06', temperature=(37 + 273.15))
design.parameters.seed = 93 # set seed to make design repeatable

# define domains
Domain('a', 'N'*6)
Domain('c', 'N'*8)
Domain('b', 'N'*4)
Domain('w', 'N'*2)
Domain('y', 'N'*4)
Domain('x', 'N'*12)
Domain('z', 'N'*3)
Domain('s', 'N'*5)

# define strands from domains
Strand('Cout_s', ('w', 'x', 'y', 's',))
Strand('A_s', ('c*', 'b*', 'a*', 'z*', 'y*',))
Strand('A_toe_s', ('c*',))
Strand('C_s', ('w', 'x', 'y', 's', 'a*', 'z*', 'y*', 'x*', 'w*',))
Strand('C_loop_s', ('s', 'a*', 'z*',))
Strand('B_s', ('x', 'y', 'z', 'a', 'b', ))
Strand('Xs_s', ('a', 'b', 'c',))

# define complexes composed of one or more strands in a given order AND
# define target structures for each complex
TargetComplex('C', ('C_s',), 'D2 D12 D4( U5 U6 U3 )')
TargetComplex('B', ('B_s',), 'U12 U4 U3 U6 U4')
TargetComplex('C_loop', ('C_loop_s',), 'U14')
TargetComplex('A_B', ('A_s', 'B_s'), 'U8 D4 D6 D3 D4(+ U12)')
TargetComplex('X', ('Xs_s',), 'U18')
TargetComplex('X_A', ('Xs_s', 'A_s'), 'D6 D4 D8(+) U3 U4')
TargetComplex('C_out', ('Cout_s',), 'U23')
TargetComplex('B_C', ('B_s', 'C_s'), 'D12 D4 D3 D6 (U4 + U2 U12 U4 U5) U2')
TargetComplex('A_toe', ('A_toe_s',), 'U8')

# on-target tubes
design.add_tube('Step_0', {'C': 1e-08, 'X': 1e-08, 'A_B': 1e-08})
design.add_off_targets('Step_0', maxsize=2, explicit=[['A_s'], ['B_s']], exclude=[['X_A']])

design.add_tube('Step_1', {'X_A': 1e-08, 'B': 1e-08})
design.add_off_targets('Step_1', maxsize=2, explicit=[['X'], ['A_B']])
# design.add_off_targets('Step_1', maxsize=2, explicit=[['X'], ['A_B'], ['C']])

design.add_tube('Step_2', {'B_C': 1e-08})
design.add_off_targets('Step_2', maxsize=2, explicit=[['B'], ['C']])

# global orthogonality tube
design.add_tube('Crosstalk', {
    'A_B': 1e-08,
    'C': 1e-08,
    'X': 1e-08,
    'B': 1e-08,
    'C_out': 1e-08,
    'C_loop': 1e-08,
    'A_toe': 1e-08,
})
design.add_off_targets('Crosstalk', maxsize=2, exclude=[['X_A'], ['B_C'], ['Xs_s', 'A_toe_s'], ['B_s', 'C_loop_s']])

# GC content constraints
Similarity('Cout_s', 'S'*23, (0.45, 0.55))
Similarity('A_s', 'S'*25, (0.45, 0.55))
Similarity('C_s', 'S'*50, (0.45, 0.55))
Similarity('C_loop_s', 'S'*14, (0.45, 0.55))
Similarity('B_s', 'S'*29, (0.45, 0.55))
Similarity('Xs_s', 'S'*18, (0.45, 0.55))

# sources lines
tpm3 = ('gaacactattagctatttgtagtactctaaagaggactgcagaacgcatcgcagtagtgg'
'tgaaaagccgtgcgtgcgcgtgaaacatctgatcctcacgttacttccactcgctctgcg'
'tttgacttgttggcggggcgttggtgccttggacttttttttcctccttctcttcttcgc'
'ggctcggtccactacgctgctcgagaggaatctgctttattcgaccacactactcctaaa'
'gtaacacattaaaatggccggatcaaacagcatcgatgcagttaagagaaaaatcaaagt'
'tttacaacagcaagcagatgaggcagaagaaagagccgagattttgcagagacaggtcga'
'ggaggagaagcgtgccagggagcaggctgaggcagaggtggcttctctgaacaggcgtat'
'ccagctggttgaggaggagttggatcgtgctcaggagagactggccacagccctgcaaaa'
'gctggaggaagccgagaaggccgcagatgagagcgagagagggatgaaggtgattgagaa'
'cagggctctgaaggatgaggagaagatggagctgcaggagatccagcttaaggaggccaa').upper()

design.add_source('tpm3', tpm3)
Window(('a', 'b', 'c'), 'tpm3')

desm = ('catttacacagcgtacaaacccaacaggcccagtcatgagcacgaaatattcagcctccg'
'ccgagtcggcgtcctcttaccgccgcacctttggctcaggtttgggctcctctattttcg'
'ccggccacggttcctcaggttcctctggctcctcaagactgacctccagagtttacgagg'
'tgaccaagagctccgcttctccccatttttccagccaccgtgcgtccggctctttcggag'
'gtggctcggtggtccgttcctacgctggccttggtgagaagctggatttcaatctggctg'
'atgccataaaccaggacttcctcaacacgcgtactaatgagaaggccgagctccagcacc'
'tcaatgaccgcttcgccagctacatcgagaaggtgcgcttcctcgagcagcagaactctg'
'ccctgacggtggagattgagcgtctgcggggtcgcgagcccacccgtattgcagagctgt'
'acgaggaggagatgagagagctgcgcggacaggtggaggcactgaccaatcagagatccc'
'gtgtggagatcgagagggacaacctagtcgatgacctacagaaactaaagctcagacttc').upper()

design.add_source('desm', desm)
Window(('w', 'x', 'y', 'z'), 'desm')

# Prevented patterns
Pattern(['AAAA','CCCC','GGGG','UUUU'])

# Global stop condition
design.parameters.f_stop = 0.1

results = run_and_display(design)
```


```python
results.running()
```

    True

```python
res = results.result()
notebook_results(res)
```

### Design Evaluation Example (Example 8 from NUPACK 3.2 User Guide)


```python

# set physical properties
design.model = ModelSettings(material='RNA', temperature=(23+273.15))

# define domains
Domain('a', 'ACCUCCAAGCACAACUGUGGCCCCAUA')
Domain('b', 'GGGGCCGGAUUACAACUUUCCCUGUGAAC')
Domain('c', 'AUCACAGACAGUUAACCACUUGAGG')
Domain('d', 'AUCAAGUGGGCUUGGAGC')

# define strands from domains
Strand('left', ('a',))
Strand('top', ('b',))
Strand('right', ('c',))
Strand('bottom', ('d',))

# define complex compsed of strands in a given order AND
# Define target structure for complex
TargetComplex('stickfigure', ('left', 'top', 'right', 'bottom'),
        "U2D8(U2D6(D6(U3+)D3U9D6(U2+U1))U2D8(U2+U1))U1")

# define test tube
design.add_tube('figuretube', {'stickfigure': 1e-6})
design.add_off_targets('figuretube', maxsize=3)

# add objective to evaluate
design.add_global_objective()

# evaluate
result = design.evaluate()

# show multistate test tube ensemble defect
notebook_results(result)
```

### Saving and restarting a Design

When "calling" the design to start the optimization process, two additional arguments must be added for checkpointing to work, `checkpoint_condition` and `checkpoint_handler`.

`checkpoint_condition` is a binary function that receives the stats and timer object from the C++ `Designer` object after steps in the design. The logic in `checkpoint_condition` then uses this information to determine whether a checkpoint should be made, in which case it returns True. In the call below, it is set to an object of an included class, `TimeInterval`. If `checkpoint_condition` is set to an object `TimeInterval(n)`, then a checkpoint will be emitted roughly every n seconds.

`checkpoint_handler` is the function which actually does something given that `checkpoint_condition` returns `True`. `checkpoint_handler` takes one argument, a Result object, and decides how it will use this information. In the call below, it is set to an object of the included class, `WriteToFileCheckpoint`. This type of `checkpoint_handler` object is instantiated with a filename prefix ("design_test" below) and will convert the design Result object into JSON and serialize it to a file with the given prefix and a time stamp, e.g. design_test-2020-01-27T00:16:52.170292.out


```python
from nupack.design import TimeInterval, WriteToFileCheckpoint

result = design(checkpoint_condition=TimeInterval(1), checkpoint_handler=WriteToFileCheckpoint("design-checkpoint"))
print(result)
```

    DesignResult
        model: ModelKey {parameters: ParameterFile {path: rna95.json}, ensemble: stacking, conditions: ModelConditions {temperature: 296.15, na_molarity: 1, mg_molarity: 0}}
        parameters: DesignParameters {rng_seed: 841912177, f_stop: 0.02, f_passive: 0.01, H_split: 2, N_split: 12, f_split: 0.99, f_stringent: 0.99, dG_clamp: -20, M_bad: 300, M_reseed: 50, M_reopt: 3, f_redecomp: 0.03, f_refocus: 0.03, cache_bytes_of_RAM: 0, min_ppair: 1e-05, slowdown: 0, log: , decomposition_log: , thermo_log: , time_analysis: 1}
        stats: DesignStats {num_leaf_evaluations: 1, num_reseeds: 0, num_redecompositions: [], offtargets_added_per_refocus: [], design_time: 0.924277, analysis_time: 0.807128, final_Psi: EnsemblePartition {mask: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], deflate: 0.0002}}
        objectives: [Objective {variant: MultitubeObjective()}]
        results: [SingleResult
                domains: {(a : ACCTCCAAGCACAACTGTGGCCCCATA), (a* : TATGGGGCCACAGTTGTGCTTGGAGGT), (b : GGGGCCGGATTACAACTTTCCCTGTGAAC), (b* : GTTCACAGGGAAAGTTGTAATCCGGCCCC), (c : ATCACAGACAGTTAACCACTTGAGG), (c* : CCTCAAGTGGTTAACTGTCTGTGAT), (d : ATCAAGTGGGCTTGGAGC), (d* : GCTCCAAGCCCACTTGAT)}
                strands: {(bottom : ATCAAGTGGGCTTGGAGC), (left : ACCTCCAAGCACAACTGTGGCCCCATA), (right : ATCACAGACAGTTAACCACTTGAGG), (top : GGGGCCGGATTACAACTTTCCCTGTGAAC)}
                complexes: [ComplexResult
                        name: stickfigure
                        sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG, ATCAAGTGGGCTTGGAGC]
                        structure: Structure(".2(8.2(12.3+)6(3.9)3(6.2+.)12.2(8.2+.)16.")
                        log_partition_function: 129.151
                        defect: 0.652198
                        normalized_defect: 0.00658786,
                    ComplexResult {name: bottom, sequence: [ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 8.71314, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 30.7563, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-bottom, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC], structure: Structure(""), log_partition_function: 48.0926, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-left, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 66.5632, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 59.227, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-bottom-top, sequence: [ATCAAGTGGGCTTGGAGC, ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 52.2993, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 46.5626, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-left, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 67.6208, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-right, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 75.0568, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-left-top, sequence: [ATCAAGTGGGCTTGGAGC, ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 82.4741, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 39.3921, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-left, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 58.8139, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-right, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 55.6661, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-right-top, sequence: [ATCAAGTGGGCTTGGAGC, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 55.3148, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 32.1384, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-left, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 65.7289, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-right, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 68.1066, defect: 0, normalized_defect: 0},
                    ComplexResult {name: bottom-top-top, sequence: [ATCAAGTGGGCTTGGAGC, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 58.2446, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 9.23003, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 27.609, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-left, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA], structure: Structure(""), log_partition_function: 45.8795, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 53.9845, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-left-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 65.7507, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 31.2484, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 50.2585, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-right-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 57.7334, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 48.3159, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top-right, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 85.177, defect: 0, normalized_defect: 0},
                    ComplexResult {name: left-top-top, sequence: [ACCTCCAAGCACAACTGTGGCCCCATA, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 71.143, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right, sequence: [ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 6.57108, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 26.0572, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right-right, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG], structure: Structure(""), log_partition_function: 42.6987, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-right-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 54.1083, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 35.525, defect: 0, normalized_defect: 0},
                    ComplexResult {name: right-top-top, sequence: [ATCACAGACAGTTAACCACTTGAGG, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 64.0134, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 13.5486, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top-top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 40.0906, defect: 0, normalized_defect: 0},
                    ComplexResult {name: top-top-top, sequence: [GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC, GGGGCCGGATTACAACTTTCCCTGTGAAC], structure: Structure(""), log_partition_function: 62.0574, defect: 0, normalized_defect: 0}]
                tubes: [TubeResult
                        name: figuretube
                        nucleotide_concentration: 9.9e-05
                        defect: 6.8218e-07
                        normalized_defect: 0.00689071
                        complexes: [TubeComplex {name: stickfigure, concentration: 9.99695e-07, target_concentration: 1e-06, defect: 6.8218e-07, structural_defect: 6.51999e-07, concentration_defect: 3.0181e-08, normalized_defect_contribution: 0.00689071},
                            TubeComplex {name: bottom, concentration: 1.67614e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom, concentration: 3.13566e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-bottom, concentration: 5.29885e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-left, concentration: 2.9797e-17, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-right, concentration: 2.43844e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-bottom-top, concentration: 2.3401e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left, concentration: 1.22811e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-left, concentration: 4.5896e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-right, concentration: 9.77726e-13, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-left-top, concentration: 1.59333e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right, concentration: 1.1862e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-left, concentration: 8.63038e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-right, concentration: 4.65574e-19, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-right-top, concentration: 3.20779e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top, concentration: 8.21711e-18, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-left, concentration: 8.51105e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-right, concentration: 1.1524e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: bottom-top-top, concentration: 5.8804e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left, concentration: 1.50351e-11, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left, concentration: 3.85581e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-left, concentration: 8.87101e-29, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-right, concentration: 3.68937e-23, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-left-top, concentration: 4.6533e-21, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right, concentration: 1.84373e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right-right, concentration: 1.11636e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-right-top, concentration: 1.92702e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top, concentration: 4.6644e-12, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top-right, concentration: 1.59777e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: left-top-top, concentration: 1.25726e-19, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right, concentration: 1.3224e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right, concentration: 1.28881e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right-right, concentration: 7.30523e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-right-top, concentration: 6.45021e-22, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-top, concentration: 1.63237e-15, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: right-top-top, concentration: 1.26505e-20, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top, concentration: 1.38822e-10, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top-top, concentration: 1.53616e-16, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0},
                            TubeComplex {name: top-top-top, concentration: 1.75159e-24, target_concentration: 0, defect: 0, structural_defect: 0, concentration_defect: 0, normalized_defect_contribution: 0}]]
                defects: [0.00689071]
                weighted_defects: [0.00689071]]
        weights: Weights {specifications: [], per_complex: {}, per_tube: {}, reversed_complexes: {}, objective_weights: [1]}
        success: 1


### Saving the final design outputs in a text file


```python
with open('design-output.json', 'w') as f:
    f.write(result.to_json(indent=4))
```

### Running from a checkpoint file
The following lines of code will run a design using the final output as a checkpoint file. The argument restart must be a python design `Result` object, in this case loaded from a file containing a valid JSON representation of a `Result` object.


```python
from nupack.design import Result
newer_result = design(restart=Result(json_file="design-output.json"))
```

