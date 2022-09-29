ARG JULIA_VERSION=1
FROM julia:${JULIA_VERSION}

ADD . /SymbolServer

RUN julia -e 'using Pkg; Pkg.update()'
