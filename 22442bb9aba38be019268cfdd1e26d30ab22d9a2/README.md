
# Building documentation

## Markdown introduction

- [Cheat sheet](https://www.markdownguide.org/cheat-sheet/)
- [Table generator for convenience](https://www.tablesgenerator.com/markdown_tables)

## Prerequisites

Install the prerequisite packages: `mkdocs` and `pydoc-markdown`:

```bash
pip install mkdocs pydoc-markdown pymdown-extensions
```

Install this bibliography package. It doesn't seem to be on pypi so you have to do this:

```bash
git clone https://github.com/darwindarak/mdx_bib
cd mdx_bib
python setup.py install
```

## Build documentation with mkdocs

The relevant configuration is in `mkdocs.yml`. You can change the page layout there as normal.

1. Navigate to the directory containing `mkdocs.yml`.
2. Run `mkdocs serve` to host the server locally.
3. Navigate to the URL that is printed in the terminal window.
4. Edit the markdown files as desired, for example `sources/index.md`. As you edit, the website should update automatically.
5. When your edits are finished, commit the changes and run `mkdocs gh-deploy -b mkdocs`.
6. Then, to deploy it online, run `bash update.sh` and then `git push` in the `nupack-documentation` repository.

The served website should change dynamically as text is changed.

## Generate markdown files from Jupyter notebooks

1. Run the desired notebook to get all the output.
2. Click `File->Save as->Markdown`.
3. Move the output file or decompressed folder into `$BUILD_DIR/docs/sources`.

## Generate automatic Python API

The relevant configuration is in `pydocmd.yml`.

1. Build Python targets `ninja mkdocs copy_python`.
2. Run `cd $BUILD_DIR/docs/`
3. Run `pydocmd generate`

## Copy the documentation directory

You can use this `rsync` command to copy the folder to an output location:

```bash
rsync --copy-links --exclude '_build/' -r docs/ output/
```

## Generate Doxygen HTML API reference

Doxygen documentation may be built from the build directory using `cmake --build . --target docs`.
