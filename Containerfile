FROM docker.io/library/httpd:2.4

RUN rm /usr/local/apache2/conf/httpd.conf

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY conf/extra /usr/local/apache2/conf/extra

RUN touch /var/log/httpd/access_log /var/log/httpd/error_log

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]