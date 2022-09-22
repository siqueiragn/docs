
-- Rodar como DBA/SYS/SYSDBA

-- JOIN NA SESSÃO + SQLs ativos, útil pra saber as últimas queries rodando 
SELECT DBMS_LOB.SUBSTR(SQL_FULLTEXT,4000, 1 ) SQL_PARTE1,
       --SQL_TEXT, -- CUIDADO COM OUTPUT >> CLOB
       OBJECT_STATUS,
       FIRST_LOAD_TIME, USERNAME, SID, SERIAL#,LOCKWAIT,TO_CHAR(LOGON_TIME,'HH24:MI'),
       'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''' IMMEDIATE;'
  FROM V$SESSION SES, V$SQL SQL
 WHERE SES.SQL_ID = SQL.SQL_ID


SELECT sid,
       to_char(START_TIME,'dd/mm/yyyy hh24:mi:ss') start_time,
       to_char(LAST_UPDATE_TIME,'dd/mm/yyyy hh24:mi:ss') LAST_UPDATE_TIME,     
       to_char(TIMESTAMP,'dd/mm/yyyy hh24:mi:ss') TIMESTAMP,
       opname,
       sofar,
       totalwork,
       units,
       elapsed_seconds,
       time_remaining
FROM v$session_longops
WHERE sofar != totalwork;


-- Este aqui mostra o SQL que está atualmente "ATIVO":
  SELECT S.USERNAME, S.SID, S.OSUSER, T.SQL_ID, SQL_TEXT
    FROM V$SQLTEXT_WITH_NEWLINES T,V$SESSION S
   WHERE T.ADDRESS =S.SQL_ADDRESS
     AND T.HASH_VALUE = S.SQL_HASH_VALUE
     AND S.STATUS = 'ACTIVE'
     AND S.USERNAME <> 'SYSTEM'
ORDER BY S.SID,T.PIECE

-- Avaliar tempo de processamento das queries (não representa tempo de execução da query e sim o tempo de alocação do processo no sistema operacional)
select S.USERNAME, s.sid, s.osuser, t.sql_id, (CPU_TIME / 1000000 ) as "cpu_time in seconds", sql_fulltext
from gv$sql t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid 

select
  object_name, 
  object_type, 
  session_id, 
  type,         -- Type or system/user lock
  lmode,        -- lock mode in which session holds lock
  request, 
  block, 
  ctime         -- Time since current mode was granted
from
  v$locked_object, all_objects, v$lock
where
  v$locked_object.object_id = all_objects.object_id AND
  v$lock.id1 = all_objects.object_id AND
  v$lock.sid = v$locked_object.session_id
order by
  session_id, ctime desc, object_name

--Este é bom para encontrar operações longas (por exemplo, varreduras de tabela completas). Se é por causa de muitas operações curtas, nada aparecerá.

COLUMN percent FORMAT 999.99 

SELECT sid, to_char(start_time,'hh24:mi:ss') stime, 
message,( sofar/totalwork)* 100 percent 
FROM v$session_longops
WHERE sofar/totalwork < 1


select cpu_time,(CPU_TIME / 1000000 ) as "cpu_time in seconds", elapsed_time, ( elapsed_time / 1000000 ) as "elapsed_time in seconds", to_char(last_active_time, 'DD/MM/YYYY HH24:MI:SS'), sql_fulltext from gv$sql
where parsing_schema_name='ELO'
and last_active_time like '17/09/21'
and (elapsed_time /  1000000 ) >= 1
order by last_active_time DESC 


select a.sql_fulltext from gv$sql a, gv$session b
where a.sql_id=b.sql_id
and b.paddr=(select addr from gv$process where spid=&proc and inst_id=&inst);


select p.spid, b.status, (CPU_TIME / 1000000 ) as "cpu_time in seconds", a.sql_fulltext from gv$sql a
inner join gv$session b
on a.sql_id=b.sql_id
inner join gv$process p
on p.addr = b.paddr
order by  b.status, (cpu_time / 1000000 ) desc

-- Verificar processos em execução, já devolve formatado para todar task kill em sistemas rhel/deb  
select ‘kill -9 ‘ || p.spid, s.inst_id, s.username from gv$process p, gv$session s
 where s.inst_id = p.inst_id
   and s.paddr = p.addr
   AND S.SID IN (select a.SID
                   from gv$access a,
                        gv$session s
                  where object = ‘NOME_TABELA‘
                    and s.inst_id = a.inst_id
                    and s.sid = a.sid);