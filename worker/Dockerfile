FROM r-base:3.6.1
MAINTAINER Franco Bulgarelli

RUN apt-get update && \
    apt-get install libxml2 libxml2-dev && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('remotes'); \
          remotes::install_version('xml2', '1.2.2'); \
          remotes::install_version('testthat', '2.3.1')"


