# Versions

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

