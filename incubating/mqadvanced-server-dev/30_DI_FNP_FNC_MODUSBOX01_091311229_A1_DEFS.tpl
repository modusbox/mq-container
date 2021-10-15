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
