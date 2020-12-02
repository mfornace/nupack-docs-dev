* ```slowdown```: For development purposes. Runs all thermodynamics calls ```slowdown``` times instead of once.
* ```time_analysis```: A boolean that determines whether the full ensemble is reevaluated at the end to get an accurate timing of the cost of analysis. Can be set to ```False``` to speed up design output.

The remaining log options are all strings and can have four different states:

* ```""```: The empty string (default). If empty, no logging of this type occurs.
* ```"stdout"```: The log is written to the standard output stream.
* ```"stderr"```: The log is written to the standard error stream.
* any other string: The string is treated as a relative path specification where intermediate folders must exist and the log is written to the file at that path.

The information logged for each of these given a non-empty string is as follows:

* ```log```: After every major algorithm component finishes, time since design start, sequence, defect (estimate), algorithm position, decomposition tree position, and active/passive ensemble breakdown are logged.
* ```decomposition_log```: After each time a complex (on- or off-target) is decomposed (or redecomposed), a JSON representation of the decomposition tree is logged.
* ```thermo_log```: Primarily for debugging/development purposes. After every thermodynamic evaluation, the type of calculation (pair probability, bonused pair probability, partition function), number of nucleotides evaluated, and duration of the calculation are logged.



### Saving checkpoint files automatically

When "calling" the design to start the optimization process, two additional arguments must be added for checkpointing to work, `checkpoint_condition` and `checkpoint_handler`.

`checkpoint_condition` is a binary function that receives the stats and timer object from the running design optimization. The logic in `checkpoint_condition` then uses this information to determine whether a checkpoint should be made, in which case it returns True. In the call below, it is set to an object of an included class, `TimeInterval`. If `checkpoint_condition` is set to an object `TimeInterval(n)`, then a checkpoint will be emitted roughly every `n` seconds.

`checkpoint_handler` is the function which actually does something given that `checkpoint_condition` returns `True`. `checkpoint_handler` takes one argument, a `DesignResult` object, and decides how it will use this information. In the call below, it is set to an object of the included class, `WriteToFileCheckpoint`. This type of `checkpoint_handler` object is instantiated with a filename prefix (`"design-checkpoint"` below) and will convert the design result object into JSON and serialize it to a file with the given prefix and a time stamp, e.g. design_test-2020-01-27T00:16:52.170292.out.

```python
from nupack.design import TimeInterval, WriteToFileCheckpoint

result = my_design.run(trials=1, checkpoint_condition=[TimeInterval(1)], checkpoint_handler=[WriteToFileCheckpoint("design-checkpoint")])
```
