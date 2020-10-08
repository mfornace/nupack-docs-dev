FROM alpine:latest as builder
RUN apk add --update bash python3 py3-pip build-base python3-dev tini
RUN pip install --upgrade pip

RUN pip install -q mkdocs==1.1.2 \
    mkdocs-material-extensions==1.0 \
    mkdocs-material==5.5.7 \
    pymdown-extensions==8.0 \
    markdown-include==0.6.0 \
    markdown-katex==201908.9b0 \
    pydoc-markdown==3.3.0

COPY . /root/
WORKDIR /root/mdx_bib
RUN python3 setup.py install
WORKDIR /root
COPY ./mkdocs.yml /root/
COPY ./sources /root/sources
RUN mkdocs build

FROM nginx as final
COPY --from=builder /root/_build/site /usr/share/nginx/html
