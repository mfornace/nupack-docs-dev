FROM nginx as final
COPY ./_build/site /usr/share/nginx/html
