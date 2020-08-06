FROM alpine:latest
RUN apk add --update bash python3 py3-pip build-base python3-dev tini
RUN pip install --upgrade pip
RUN pip install -q mkdocs pydoc-markdown pymdown-extensions mkdocs-material
COPY . /root/
WORKDIR /root/mdx_bib
RUN python3 setup.py install
WORKDIR /root
COPY ./mkdocs.yml /root/
COPY ./sources /root/sources
EXPOSE 8080
ENTRYPOINT [ "tini", "--", "mkdocs", "serve", "-a", "0.0.0.0:8080" ]

