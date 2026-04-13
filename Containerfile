FROM docker.io/library/httpd:2.4

RUN rm -f /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/extra/*.conf

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY conf/extra /usr/local/apache2/conf/extra

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]