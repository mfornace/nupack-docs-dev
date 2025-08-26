git pull && cd sources && zip -r examples.zip examples && cd .. && mkdocs gh-deploy -r deploy -b main

# development: 
# mike deploy 4.1 -r dev -b main --push
# mike list -r dev -b main # to list the tags
# mike serve -r dev -b main