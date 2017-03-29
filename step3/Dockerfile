FROM oracle-12c:created
MAINTAINER Wouter Scherphof <wouter.scherphof@gmail.com>

ENV ORACLE_BASE /u01/app/oracle
ENV CVUQDISK_GRP oinstall
ENV ORACLE_SID ORCL
ENV ORACLE_HOME $ORACLE_BASE/product/12.1.0/dbhome_1
ENV PATH $ORACLE_HOME/bin:$PATH

RUN rm /tmp/create

# Exposes the default TNS port, as well as the Enterprise Manager Express HTTP
# (8080) and HTTPS (5500) ports. 
EXPOSE 1521 5500 8080

ADD startdb.sql $ORACLE_HOME/config/scripts/startdb.sql
ADD start /tmp/start
CMD /tmp/start
