/**

   Autor: Israel Santana <isra@miscorreos.org>

   Licencia: GPL v2

   Valido para Elastix 2.4

   El motivo de este SQL es de disponer de una regla de iptables de forma nativa
   dentro de la interfaz web de elastix, para ejecutarlo sólo hay que hacer lo siguiente

   cat parche_dhcpd.sql | sqlite3 /var/www/db/iptables.db 

**/

-- Insertando la nueva linea para definicion de los puertos del dhcp
INSERT INTO port (name,protocol,details,comment) VALUES ('DHCPD', 'UDP', '67:68', '67:68');

-- Borrando las reglas necesarias para volver a crearlas en orden
DELETE FROM filter where id=9;
DELETE FROM filter where id=10;
DELETE FROM filter where id=11;
DELETE FROM filter where id=12;
DELETE FROM filter where id=13;
DELETE FROM filter where id=14;
DELETE FROM filter where id=15;
DELETE FROM filter where id=16;
DELETE FROM filter where id=17;
DELETE FROM filter where id=18;
DELETE FROM filter where id=19;
DELETE FROM filter where id=20;
DELETE FROM filter where id=21;
DELETE FROM filter where id=22;



-- Creacion de la regla de DHCP antes que la del TFTPBOOT (estan relacionadas) y luego el resto
INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'UDP', '18','18','ACCEPT',9,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'UDP', 'ANY','17','ACCEPT',10,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','5','ACCEPT',11,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','6','ACCEPT',12,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','1','ACCEPT',13,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','3','ACCEPT',14,1,'');


INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','10','ACCEPT',15,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','2','ACCEPT',16,1,'');


INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','4','ACCEPT',17,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','7','ACCEPT',18,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','8','ACCEPT',19,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'TCP', 'ANY','9','ACCEPT',20,1,'');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'STATE', '','','ACCEPT',21,1,'Established,Related');

INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('INPUT','ANY','','0.0.0.0/0','0.0.0.0/0', 'ALL', '','','REJECT',22,1,'');


INSERT INTO filter
 ('traffic','eth_in','eth_out','ip_source','ip_destiny','protocol','sport','dport','target','rule_order', 'activated','state')
VALUES
 ('FORWARD','ANY','ANY','0.0.0.0/0','0.0.0.0/0', 'ALL', '','','REJECT',23,1,'');
