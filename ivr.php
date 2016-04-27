[macro-mysql-connect]
exten => s,1,MYSQL(Connect connid localhost ring Dpyvp9X8vDLwAYVA ring_codigo)

[macro-mysql-disconnect]
exten => s,1,MYSQL(Connect connid localhost ring Dpyvp9X8vDLwAYVA ring_codigo)

[IVR] 
extn => _XXXXXX#,1,MYSQL(Connect connid localhost payment-gateway tMZ8xVPjDTWyEtAJ payment-gateway)
exten => _XXXXXX#,2,MYSQL(Query resultid ${connid} UPDATe control SET CedIdentd=${EXTEN:0:6} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXX#,3,MYSQL(Disconnect ${connid})
exten => _XXXXXX#,4,goto(codigo,s,1)bar]
exten => _XXXXXXX#,1,MYSQL(Connect connid localhost payment-gateway tMZ8xVPjDTWyEtAJ payment-gateway)
exten => _XXXXXXX#,2,MYSQL(Query resultid ${connid} UPDATe control SET CedIdentd=${EXTEN:0:7} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXXX#,3,MYSQL(Disconnect ${connid})
exten => _XXXXXXX#,4,goto(codigo,s,1)bar]
exten => _XXXXXXXX#,1,MYSQL(Connect connid localhost payment-gateway tMZ8xVPjDTWyEtAJ payment-gateway)
exten => _XXXXXXXX#,2,MYSQL(Query resultid ${connid} UPDATe control SET CedIdentd=${EXTEN:0:8} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXXXX#,3,MYSQL(Disconnect ${connid})
exten => _XXXXXXXX#,4,goto(codigo,s,1)bar]


exten => s,1,Wait(3)
exten => s,2,BackGround(custom/identificador)
exten => s,2,Macro(mysql-connect)
exten => s,3,MYSQL(Query resultid ${connid} UPDATE operaciones SET Estats=2 WHERE Extens = '${MYVAR}' AND Estats=0)
exten => s,4,Macro(mysql-disconnect)
exten => s,5,goto(tarjeta,s,1) 

[tarjeta]
exten => s,1,Set(TIMEOUT(digit)=25)
exten => s,n,Set(TIMEOUT(response)=25) 
exten => s,n,BackGround(custom/tarjeta)
exten => s,n,WaitExten(15)

exten => s,2,Macro(mysql-connect)
exten => _XXXXXXXXXXXXXXXX#,1,MYSQL(Query resultid ${connid} UPDATE control SET NumTarjet=${EXTEN:0:16} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXXXXXXXXXXXXX#,1,MYSQL(Query resultid ${connid} UPDATE control SET NumTarjet=${EXTEN:0:16} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXXXXXXXXXXXXXX#,1,MYSQL(Query resultid ${connid} UPDATE control SET NumTarjet=${EXTEN:0:16} WHERE Extens = '${MYVAR}' AND Estats = 1)
exten => _XXXXXXXXXXXXXXXXXXX#,1,MYSQL(Connect connid localhost payment-gateway tMZ8xVPjDTWyEtAJ payment-gateway)
exten => _XXXXXXXXXXXXXXXXXXX#,1,Macro(mysql-disconnect)

exten => h,1,goto(estatus,s,1)
exten => t,1,goto(tarjeta,s,1)
exten => i,1,goto(tarjeta,s,1)