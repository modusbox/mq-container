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
