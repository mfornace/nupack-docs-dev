
# NUPACK web documentation

## Editing the documentation

### Editing the layout

See the [MkDocs](https://www.mkdocs.org) site for help on configuration.

The relevant configuration is in `mkdocs.yml` as a relatively readable YAML format. You can change the page layout there as desired. You can edit this file from within GitHub or offline using any plain text editor.

### Editing the contents

See the following links for help on Markdown:

- [Cheat sheet](https://www.markdownguide.org/cheat-sheet/)
- [Table generator for convenience](https://www.tablesgenerator.com/markdown_tables)

You can edit each `.md` file in the `sources` directory by:

- editing them directly from GitHub in your browser with the pencil button (click `Commit changes` once done)
- editing them offline by cloning the repository and using any plain text editor (requires basic git know-how).

## Deploying the documentation

### Prerequisites for deploying documentation

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

### Building the documentation locally

1. Navigate to the directory containing `mkdocs.yml`.
2. Run `mkdocs serve` to host the server locally.
3. Navigate to the URL that is printed in the terminal window.
4. Edit the markdown files as desired, for example `sources/index.md`. As you edit, the website should update automatically.

### Deploying the documentation online

After your edits are finished:

1. Within this branch (`docs`) commit the changes
2. Run `mkdocs gh-deploy -b build`. 
3. Assuming that's successful, run `git push` with your changes.
4. Checkout the `master` branch.
5. Run `bash update.sh`
6. Assuming that's successful, run `git push`.

## Other tips

### Generate markdown files from Jupyter notebooks

1. Run the desired notebook to get all the output.
2. Click `File->Save as->Markdown`.
3. Move the output file or decompressed folder into `$BUILD_DIR/docs/sources`.

### Generate automatic Python API

The relevant configuration is in `pydocmd.yml` in the NUPACK master branch.

1. Build Python targets `ninja mkdocs copy_python`.
2. Run `cd $BUILD_DIR/docs/`
3. Run `pydocmd generate`

### Copy the documentation directory

You can use this `rsync` command to copy the folder to an output location:

```bash
rsync --copy-links --exclude '_build/' -r docs/ output/
```

### Generate Doxygen HTML API reference

Doxygen documentation may be built from the NUPACK build directory using `cmake --build . --target docs`.
