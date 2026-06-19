FROM docker.io/library/httpd:2.4-alpine

COPY httpd-csp.conf /usr/local/apache2/conf/extra/httpd-csp.conf
RUN echo "Include conf/extra/httpd-csp.conf" >> /usr/local/apache2/conf/httpd.conf

COPY index.html /usr/local/apache2/htdocs/
