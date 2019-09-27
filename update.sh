git submodule add -b mkdocs https://github.com/mfornace/nupack.git
rm -rf 22442bb9aba38be019268cfdd1e26d30ab22d9a2
cp -r nupack 22442bb9aba38be019268cfdd1e26d30ab22d9a2
rm -rf 22442bb9aba38be019268cfdd1e26d30ab22d9a2/.git
git rm -r --force nupack
rm -rf .git/modules/nupack/
git add 22442bb9aba38be019268cfdd1e26d30ab22d9a2
git commit -m "Update upstream branch"
# git branch -D gh-pages
# git push origin --delete gh-pages
