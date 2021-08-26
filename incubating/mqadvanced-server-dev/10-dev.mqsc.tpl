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
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT') REPLACE
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_FB') REPLACE
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_RESP') REPLACE
DEFINE QLOCAL('FWAAS.DEV.WIRE_IN') REPLACE
* FWAAS DLQ
DEFINE QLOCAL('FWAAS.DEV.WIRE_OUT_DLQ') REPLACE
DEFINE QLOCAL('FWAAS.DEV.WIRE_IN_DLQ') REPLACE

DEFINE QLOCAL('FWAAS.DEV.FED_OUTBOUND') REPLACE
DEFINE QLOCAL('FWAAS.DEV.FED_INBOUND') REPLACE


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

* The orifinal file tries to start the AMQP service here 
* but it is already started
* START SERVICE(SYSTEM.AMQP.SERVICE)

* Start the channel
START CHANNEL(SYSTEM.DEF.AMQP)

* just in case... if it errors, it's the last line
START SERVICE(SYSTEM.AMQP.SERVICE)
