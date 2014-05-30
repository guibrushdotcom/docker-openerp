FROM ubuntu

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8

# Launch the app
# ENTRYPOINT ["/etc/init.d/openerp start", "/etc/init.d/postgresql start"]
CMD "/etc/init.d/openerp start && /etc/init.d/postgresql start"

RUN locale-gen en_US.UTF-8

RUN echo 'deb http://nightly.openerp.com/7.0/nightly/deb/ ./' >> /etc/apt/sources.list \
&& apt-get update \
&& apt-get install -y --force-yes openerp

# Set the password for the user postgres
RUN echo "postgres:postgres" | chpasswd \
&& usermod -a -G staff postgres

USER postgres

RUN /etc/init.d/postgresql start \
&& pg_dropcluster --stop 9.3 main \
&& pg_createcluster --locale en_US.UTF-8 --start 9.3 main

# Create a user openerp
# RUN useradd openerp 
# && echo "openerp:openerp" | chpasswd \
# && usermod -a -G staff openerp

# Create the database
RUN /etc/init.d/postgresql start \
# && psql --dbname postgres --command "update pg_database set datallowconn = TRUE where datname = 'template0';" \
# && psql --dbname template0 --command "update pg_database set datistemplate = FALSE where datname = 'template1';" \
# && psql --dbname template0 --command "drop database template1;" \
# && psql --dbname template0 --command "create database template1 with template = template0 encoding = 'UTF8';" \
# && psql --dbname template0 --command "update pg_database set datistemplate = TRUE where datname = 'template1';" \
# && psql --dbname template1 --command "update pg_database set datallowconn = FALSE where datname = 'template0';" \
# && /etc/init.d/postgresql reload \
&& psql --command "CREATE USER openerp;" \
&& psql --command "ALTER ROLE openerp WITH CREATEDB;" \
&& psql --command "CREATE DATABASE openerp OWNER openerp;" \
&& psql --command "ALTER USER openerp PASSWORD 'openerp';"

USER root

EXPOSE 8069
