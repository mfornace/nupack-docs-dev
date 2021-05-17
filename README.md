
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

### Downloading this repository

In Terminal, download the current git repository:

```bash
cd ~/where/you/want/the/repo
git clone https://github.com/Piercelab-Caltech/nupack-documentation -b docs --recurse-submodules
```

### Building the documentation locally

First, open a Terminal (any directory) and install the prerequisite packages: `mkdocs` and `pydoc-markdown`:

```bash
pip install -U mkdocs pydoc-markdown pymdown-extensions mkdocs-material markdown-include
```

Next, navigate to the top-level directory of this repository (`mkdocs.yml` should be visible if you run `ls`). Install the bibliography package like this:

```bash
pip install mdx-bib
```

The rest is pretty simple:

1. Run `mkdocs serve` to host the server locally.
2. Navigate to the URL that is printed in the terminal window.
3. Edit the markdown files as desired, for example `sources/index.md`. As you edit, the website should update automatically. For editing, I use Visual Studio Code, but emacs, vim, or any other plain text editor will work.
4. `CTRL-C` or close the Terminal window when you're done.

### Committing and syncing changes with GitHub

After your current round of edits are finished, open a Terminal window in the working repository:

```bash
cd /path/to/my/docs
ls # should show mkdocs.yml and other top-level files
```

Next, look at the status of the repository by running `git status`. This should tell you which files you've added or modified.

For each file or folder that you want to commit your changes, run the `git add` command:

```bash
git add sources/index.md # example
git add sources # example to add a whole folder
```

Now your changes are staged locally. You can run `git status` again to look at the repository status. Now commit all of these staged changes, which is most easily done like this:

```bash
git commit -m "my message describing the work that was done"
```

Now your local branch is up to date, and you need to sync it with GitHub. First, you can make sure you haven't missed someone else's changes by running:

```bash
git pull
```

Normally this should just work, but if it shows any errors, you may need to run `git merge-tool` before continuing (this is a little tricky, see [here](https://stackoverflow.com/questions/13719122/how-to-use-opendiff-as-default-mergetool) to use the opendiff GUI). Assuming things are merged and `git status` looks OK, run the following to upload your changes to GitHub:

```bash
git push
```

### Deploying the documentation online

Run this **once** in the current repository:

```bash
git remote add deploy https://github.com/Piercelab-Caltech/nupack-docs.git
```

Then, each time, after your edits are finished:

1. Within this branch (`master`) commit the changes.
2. To be safe, do `git pull && git submodule update --init`.
3. Run `bash deploy.sh`.

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
