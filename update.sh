git submodule add -b build --name build https://github.com/mfornace/nupack-documentation.git tmp && \
rm -rf 22442bb9aba38be019268cfdd1e26d30ab22d9a2 && \
cp -r tmp 22442bb9aba38be019268cfdd1e26d30ab22d9a2 && \
rm -rf 22442bb9aba38be019268cfdd1e26d30ab22d9a2/.git && \
git rm -r --force tmp && \
rm -rf .git/modules/build/ && \
git add 22442bb9aba38be019268cfdd1e26d30ab22d9a2 && \
git commit -m "Update upstream branch"
# git branch -D gh-pages
# git push origin --delete gh-pages
