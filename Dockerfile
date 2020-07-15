# Dockerfile
FROM rocker/r-ver:4.0.2

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    xtail \
    wget


# Download and install shiny server
RUN wget --no-verbose --no-check-certificate https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose --no-check-certificate "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e ".libPaths('/usr/local/lib/R/site-library/'); install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

COPY dockerr.dashboard_0.0.0.9000.tar.gz ./
RUN mkdir /pkgs && tar -C /pkgs/ -zxvf dockerr.dashboard_0.0.0.9000.tar.gz
RUN . /etc/environment && R -e ".libPaths('/usr/local/lib/R/site-library/');install.packages(c('desc', 'glue'), repos='https://cloud.r-project.org/');"
RUN . /etc/environment && R -e ".libPaths('/usr/local/lib/R/site-library/'); \
library(desc); \
library(glue); \
pkg <- desc::desc_get_deps('/pkgs/dockerr.dashboard')\$package; \
ver <- desc::desc_get_deps('/pkgs/dockerr.dashboard')\$version; \
print(pkg); \
print(ver);\
for (i in 1:length(pkg)){ \
    if (ver[i] != '*'){ \
        ver_parsed <- strsplit(ver[i], ' ')[[1]][2]; \
        pkgver <- glue::glue(pkg[i],'@',ver_parsed); \
        install.packages(pkgver, repos='https://cloud.r-project.org/'); \
    }; \
    if (ver[i] == '*'){ \
        pkgver <- glue::glue(pkg[i]); \
        install.packages(pkgver, repos='https://cloud.r-project.org/'); \
    }; \
};"
RUN R CMD INSTALL --library=/usr/local/lib/R/site-library/ /pkgs/dockerr.dashboard

COPY app.R /srv/shiny-server/app.R
CMD ["/usr/bin/shiny-server.sh"]
