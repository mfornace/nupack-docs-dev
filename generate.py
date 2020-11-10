from pathlib import Path
import json, os
from textwrap import dedent
from tempfile import TemporaryDirectory

glob = (Path(__file__).parent/'sources').glob('*.md')
out = Path(__file__).parent/'snippets'
out.mkdir(exist_ok=True)


template = lambda: {
    "cells": [],
    "metadata": {},
    "nbformat": 4,
    "nbformat_minor": 4
}

block = lambda s: {
   "cell_type": "code",
   "execution_count": 0,
   "metadata": {},
   "outputs": [],
   "source": [s]
}

def run_notebook(path):
    import nbformat
    from nbconvert.preprocessors import ExecutePreprocessor

    with path.open('r') as f:
        nb = nbformat.read(f, as_version=4)
    with TemporaryDirectory() as tmp:
        os.chdir(tmp)
        ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
        ep.preprocess(nb)


for p in glob:
    matches = [m.split('```')[0] for m in p.read_text().split('```python')[1:]]
    if not matches:
        continue
    print('Processing', p)
    t = template()
    t['cells'].append(block("from nupack import *"))
    for m in matches:
        t['cells'].append(block(dedent(m).strip()))
    q = out/(p.stem + '.ipynb')
    q.write_text(json.dumps(t))
    #run_notebook(q)
