* Added by ramiro. Running this image and trying to connect from a Quarkus app using JMS/qpid gave an error on the Java app:
* Caused by: org.apache.qpid.jms.provider.exceptions.ProviderConnectionSecurityException: 
* AMQXR0100E: A connection from 172.18.0.1 was not authorized. [condition = amqp:unauthorized-access]
*
* Looking at the trace details ( on the trace file ( like /mnt/mqm/data/trace/amqp_218.trc  - see below how to get the current one ) shows:
*
* [com.ibm.mq.MQXRService.MQInvocationException: CallType 0, MQCC 0, MQRC 0 MQRC_NONE] 
* [c.i.mq.MQXRService.MQConnection@a02b143c] 
* [class com.ibm.mq.MQXRService.MQInvocationException] 
* [com.ibm.mq.jmqi.JmqiException: CC=2;RC=2330;AMQ6047: Conversion not supported. [1=1200 (UCS2),2=367(US-ASCII) 
* Unmappable Action: REPORT, Unmappable Replacement: 63, spaceByte: 32]] <null>
* 
* You can enable trace by running
* strmqtrc -t all -t detail
* Then run strmqtrc -s
* and
* runmqsc
* > DISPLAY SVSTATUS(SYSTEM.AMQP.SERVICE)
* to get more details
* 
* See https://www.ibm.com/support/pages/apar/IT27637

ALTER QMGR CCSID(819)
* END patch




* © Copyright IBM Corporation 2017, 2019
*
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.

* Developer queues
DEFINE QLOCAL('DEV.QUEUE.1') REPLACE
DEFINE QLOCAL('DEV.QUEUE.2') REPLACE
DEFINE QLOCAL('DEV.QUEUE.3') REPLACE
DEFINE QLOCAL('DEV.DEAD.LETTER.QUEUE') REPLACE

* FWAAS

* *************** DEV *****************

* REQUEST queue
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT') REPLACE
* FEEDBACK queue ( not mapped to a FED queue )
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_FB') REPLACE
* Inbound / Notification / ADVICE queue
DEFINE QLOCAL('FWAAS.DEV.WIRE_IN') REPLACE
* ACK/RESPONSES queue
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_RESP') REPLACE
* Broadcast
DEFINE QLOCAL('FWAAS.DEV.BROADCAST') REPLACE
* Statement
DEFINE QLOCAL('FWAAS.DEV.STATEMENT') REPLACE

* FWAAS DLQ
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_DLQ') REPLACE
DEFINE QLOCAL('FWAAS.DEV.WIRE_IN_DLQ') REPLACE

* FED
DEFINE QLOCAL('FWAAS.DEV.FED_OUTBOUND') REPLACE
DEFINE QLOCAL('FWAAS.DEV.FED_INBOUND') REPLACE

* *************** END DEV *****************

* *************** STG *****************

* REQUEST queue
DEFINE QLOCAL('FWAAS.STG.WIRE_OUT') REPLACE
* FEEDBACK queue ( not mapped to a FED queue )
DEFINE QLOCAL('FWAAS.STG.WIRE_OUT_FB') REPLACE
* Inbound / Notification / ADVICE queue
DEFINE QLOCAL('FWAAS.STG.WIRE_IN') REPLACE
* ACK/RESPONSES queue
DEFINE QLOCAL('FWAAS.STG.WIRE_OUT_RESP') REPLACE
* Broadcast
DEFINE QLOCAL('FWAAS.STG.BROADCAST') REPLACE
* Statement
DEFINE QLOCAL('FWAAS.STG.STATEMENT') REPLACE

* FWAAS DLQ
DEFINE QLOCAL('FWAAS.STG.WIRE_OUT_DLQ') REPLACE
DEFINE QLOCAL('FWAAS.STG.WIRE_IN_DLQ') REPLACE

* FED
DEFINE QLOCAL('FWAAS.STG.FED_OUTBOUND') REPLACE
DEFINE QLOCAL('FWAAS.STG.FED_INBOUND') REPLACE

* *************** END STG *****************

* *************** PLAIN *****************

* REQUEST queue
DEFINE QLOCAL('FWAAS.WIRE_OUT') REPLACE
* FEEDBACK queue ( not mapped to a FED queue )
DEFINE QLOCAL('FWAAS.WIRE_OUT_FB') REPLACE
* Inbound / Notification / ADVICE queue
DEFINE QLOCAL('FWAAS.WIRE_IN') REPLACE
* ACK/RESPONSES queue
DEFINE QLOCAL('FWAAS.WIRE_OUT_RESP') REPLACE
* Broadcast
DEFINE QLOCAL('FWAAS.BROADCAST') REPLACE
* Statement
DEFINE QLOCAL('FWAAS.STATEMENT') REPLACE

* FWAAS DLQ
DEFINE QLOCAL('FWAAS.WIRE_OUT_DLQ') REPLACE
DEFINE QLOCAL('FWAAS.WIRE_IN_DLQ') REPLACE

* *************** END PLAIN *****************



***************  BEGIN FED QUEUES


***************************************************
* Creates QLOCAL queues for 091311229 that are NOT
* connected to a XMITQ, so they can be used for local testing
* 
* Creates FNPR ( production ) and FNCR ( contingency ) queues 
***************************************************

***************************************************
*   Application puts request messages into this
*   queue.
***************************************************

DEFINE QLOCAL ('FNPR.FROMDI.091311229.A1') +
       DESCR('Remote CI MQ  q FNCR.FROMDI.091311229.A1') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCR.FROMDI.091311229.A1') +
       DESCR('Remote CI MQ  q FNCR.FROMDI.091311229.A1') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE


***************************************************
*   Local queue where acknowledgement messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPA.TODI.091311229.A1') +
       DESCR('CI MQ local queue acknowledgement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCA.TODI.091311229.A1') +
       DESCR('CI MQ local queue acknowledgement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where notification messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPN.TODI.091311229.A1') +
       DESCR('CI MQ local queue notification message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCN.TODI.091311229.A1') +
       DESCR('CI MQ local queue notification message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where broadcast messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPB.TODI.091311229.A1') +
       DESCR('CI MQ local broadcast message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCB.TODI.091311229.A1') +
       DESCR('CI MQ local broadcast message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where statement messages return
*   from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPS.TODI.091311229.A1') +
       DESCR('CI MQ queue statement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCS.TODI.091311229.A1') +
       DESCR('CI MQ queue statement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE


***************************************************
* Creates QLOCAL queues for 725160131 that are NOT
* connected to a XMITQ, so they can be used for local testing
* 
* Creates FNPR ( production ) and FNCR ( contingency ) queues 
***************************************************

***************************************************
*   Application puts request messages into this
*   queue.
***************************************************

DEFINE QLOCAL ('FNPR.FROMDI.725160131.A1') +
       DESCR('Remote CI MQ  q FNCR.FROMDI.725160131.A1') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCR.FROMDI.725160131.A1') +
       DESCR('Remote CI MQ  q FNCR.FROMDI.725160131.A1') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE


***************************************************
*   Local queue where acknowledgement messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPA.TODI.725160131.A1') +
       DESCR('CI MQ local queue acknowledgement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCA.TODI.725160131.A1') +
       DESCR('CI MQ local queue acknowledgement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where notification messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPN.TODI.725160131.A1') +
       DESCR('CI MQ local queue notification message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCN.TODI.725160131.A1') +
       DESCR('CI MQ local queue notification message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where broadcast messages
*   return from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPB.TODI.725160131.A1') +
       DESCR('CI MQ local broadcast message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCB.TODI.725160131.A1') +
       DESCR('CI MQ local broadcast message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

***************************************************
*   Local queue where statement messages return
*   from the Federal Reserve.
***************************************************

DEFINE QLOCAL ('FNPS.TODI.725160131.A1') +
       DESCR('CI MQ queue statement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE

DEFINE QLOCAL ('FNCS.TODI.725160131.A1') +
       DESCR('CI MQ queue statement message') +
       PUT(ENABLED) +
       GET(ENABLED) +
       DEFPRTY(0) +
       DEFPSIST(YES) +
       SCOPE(QMGR) +
       CLUSTER(' ') +
       CLUSNL(' ') +
       DEFBIND(OPEN) +
       REPLACE





***************  END FED QUEUES



* Use a different dead letter queue, for undeliverable messages
ALTER QMGR DEADQ('DEV.DEAD.LETTER.QUEUE')

* Developer topics
DEFINE TOPIC('DEV.BASE.TOPIC') TOPICSTR('dev/') REPLACE

* Developer connection authentication
DEFINE AUTHINFO('DEV.AUTHINFO') AUTHTYPE(IDPWOS) CHCKCLNT(REQDADM) CHCKLOCL(OPTIONAL) ADOPTCTX(YES) REPLACE
ALTER QMGR CONNAUTH('DEV.AUTHINFO')
REFRESH SECURITY(*) TYPE(CONNAUTH)

* Developer channels (Application + Admin)
DEFINE CHANNEL('DEV.ADMIN.SVRCONN') CHLTYPE(SVRCONN) REPLACE
DEFINE CHANNEL('DEV.APP.SVRCONN') CHLTYPE(SVRCONN) MCAUSER('app') REPLACE

* Developer channel authentication rules
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS) DESCR('Back-stop rule - Blocks everyone') ACTION(REPLACE)
* The following line is processed by mq-container/cmd/runmqdevserver/mqsc.go, replacing {{ .ChckClnt }} with either REQUIRED or ASKMGR
SET CHLAUTH('DEV.APP.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT({{ .ChckClnt }}) DESCR('Allows connection via APP channel') ACTION(REPLACE)
SET CHLAUTH('DEV.ADMIN.SVRCONN') TYPE(BLOCKUSER) USERLIST('nobody') DESCR('Allows admins on ADMIN channel') ACTION(REPLACE)
SET CHLAUTH('DEV.ADMIN.SVRCONN') TYPE(USERMAP) CLNTUSER('admin') USERSRC(CHANNEL) DESCR('Allows admin user to connect via ADMIN channel') ACTION(REPLACE)
SET CHLAUTH('DEV.ADMIN.SVRCONN') TYPE(USERMAP) CLNTUSER('admin') USERSRC(MAP) MCAUSER ('mqm') DESCR ('Allow admin as MQ-admin') ACTION(REPLACE)

* Developer authority records
SET AUTHREC PRINCIPAL('app') OBJTYPE(QMGR) AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE('DEV.**') PRINCIPAL('app') OBJTYPE(QUEUE) AUTHADD(BROWSE,GET,INQ,PUT)
SET AUTHREC PROFILE('DEV.**') PRINCIPAL('app') OBJTYPE(TOPIC) AUTHADD(PUB,SUB)

* FWAAS
SET AUTHREC PROFILE('FWAAS.**') PRINCIPAL('app') OBJTYPE(QUEUE) AUTHADD(BROWSE,GET,INQ,PUT)



* FROM https://raw.githubusercontent.com/ibm-messaging/mq-dev-patterns/master/amqp-qpid/add-dev.mqsc.tpl
* © Copyright IBM Corporation 2020
*
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.

* These are additional MQSC Settings for AMQP
* defining developer channel authentication rules for AMQP

* Developer authority records
* Modification of an existing container setting
* to switch on ALTUSR for GET on Queues to work
SET AUTHREC PRINCIPAL('app') OBJTYPE(QMGR) AUTHADD(CONNECT,INQ,ALTUSR)

SET CHLAUTH('SYSTEM.DEF.AMQP') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT({{ .ChckClnt }}) DESCR('Allows connection via APP channel') ACTION(REPLACE)

SET AUTHREC PROFILE('SYSTEM.BASE.TOPIC') PRINCIPAL('app') OBJTYPE(TOPIC) AUTHADD(PUB,SUB)
* WAS just PUT,DSP
SET AUTHREC PROFILE('SYSTEM.DEFAULT.MODEL.QUEUE') PRINCIPAL('app') OBJTYPE(QUEUE) AUTHADD(BROWSE,GET,INQ,PUT,DSP)

ALTER CHANNEL(SYSTEM.DEF.AMQP) CHLTYPE(AMQP) MCAUSER('app')

* The original file tries to start the AMQP service here 
* but it is already started
* START SERVICE(SYSTEM.AMQP.SERVICE)

* Start the channel
START CHANNEL(SYSTEM.DEF.AMQP)

* just in case... if it errors, it's the last line
START SERVICE(SYSTEM.AMQP.SERVICE)
