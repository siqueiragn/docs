#!/bin/bash

#Script Geração e Exportação do EXPDP de todos os PDBs na máquina, só mexer nos valores até a linha 40
#Necessário ter instalado o jq (sudo yum install jq - CentOS)
#Necessário ter o crontab instalado (pra agendar a rotina)
#   				1) nano /etc/crontab
#   				2) configurar o período de tempo que vai rodar esse export
#Necessário criar uma pasta no /var/www/html/dlogs com permissão de escrita
#Necessário ssmtp configurado (sudo yum install ssmtp - CentOS)
#Necessário pro EXPDP funcionar
ORACLE_HOME="/u01/app/oracle/product/19.0.0.0/dbhome_1"
export ORACLE_HOME

EMAIL_DESTINO=""

#Pasta genérica criada dentro do ORACLE_HOME pra exportação e manipulação de arquivos sem riscos
PATH_TO_ORCL="${ORACLE_HOME}/elo_dump"

# [STRING DE CONEXÃO]
ORCL_STRING[0]="elo/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"



# [NOME DOS ARQUIVO]
ORCL_NM[0]="NOME_DO_ARQUIVO"


#Obs: O dropbox vai procurar uma pasta com esse nome pra salvar os arquivos gerados dentro

# [DROPBOX - Configurações]
#Esse token é obtido através da geração offline do dropbox, tem que ser enviado pra validar um novo token a cada 4h
#Ver esse request pra entender como obter: https://www.dropbox.com/developers/documentation/http/documentation#oauth2-token
TMP_REFRESH_TOKEN=""

#Obtidos no painel de desenvolvimento do dropbox, é único por app/conta
API_KEY=""
API_SECRET_KEY=""


#=========================================================
for (( i=0; i<${#ORCL_STRING[@]}; i++ ));
do
	FL_SIZE=0

	${ORACLE_HOME}/bin/expdp ${ORCL_STRING[$i]} dumpfile=${ORCL_NM[$i]}.dmp directory=ELO_DUMP_DIR logfile=${ORCL_NM[$i]}.log schemas=elo content=all

	FILE_NM="${ORCL_NM[$i]}"_$(date +%d-%m-%y-%h-%m-%s)
	zip ${PATH_TO_ORCL}/backup/${FILE_NM}.zip ${PATH_TO_ORCL}/${ORCL_NM[$i]}.dmp ${PATH_TO_ORCL}/${ORCL_NM[$i]}.log
	rm  ${PATH_TO_ORCL}/${ORCL_NM[$i]}.dmp
	rm  ${PATH_TO_ORCL}/${ORCL_NM[$i]}.log

    split -b100M ${PATH_TO_ORCL}/backup/${FILE_NM}.zip ${PATH_TO_ORCL}/backup/bckp_a
    ARQUIVOS=($(find ${PATH_TO_ORCL}/backup/ -maxdepth 1 -name "*bckp_a*" | sort -d))
	
	#Dropbox-API Requer auth2, então esse token foi previamente autorizado usando outro endpoint e agora tem que ser reenviado pra gerar um novo, expira a cada 4h
	
	TMP_BEARER_TOKEN=$(/usr/bin/curl "https://api.dropbox.com/oauth2/token" -d grant_type="refresh_token" -d refresh_token="${TMP_REFRESH_TOKEN}" -u "${API_KEY}:${API_SECRET_KEY}" | jq -r '.access_token')


	if (( ${#ARQUIVOS[@]} > 1 ))
	then

		for (( arqIndx=0; arqIndx<${#ARQUIVOS[@]}; arqIndx++ ));
		do
			if (( arqIndx==0 ))
			then
				CURL_SESSION_ID=$(/usr/bin/curl -X POST https://content.dropboxapi.com/2/files/upload_session/start \
				--header "Authorization: Bearer ${TMP_BEARER_TOKEN}" \
				--header "Dropbox-API-Arg: {\"close\":false}" \
				--header "Content-Type: application/octet-stream" \
				--data-binary @${ARQUIVOS[$arqIndx]} | jq -r '.session_id')
 
                FL_SIZE=$(stat -c%s "${ARQUIVOS[$arqIndx]}")

			elif (( arqIndx+1 == ${#ARQUIVOS[@]} )) 
			then	
			
				/usr/bin/curl -X POST https://content.dropboxapi.com/2/files/upload_session/finish >> "/var/www/html/dlogs/daily_log_${FILE_NM}.txt" \
				--header "Authorization: Bearer ${TMP_BEARER_TOKEN}" \
 				--header "Dropbox-API-Arg: {\"commit\":{\"autorename\":true,\"mode\":\"add\",\"mute\":false,\"path\":\"/backup/${ORCL_NM[$i]}/${FILE_NM}.zip\",\"strict_conflict\":false},\"cursor\":{\"offset\":${FL_SIZE},\"session_id\":\"${CURL_SESSION_ID}\"}}" \

				--header "Content-Type: application/octet-stream" \
				--data-binary @${ARQUIVOS[$arqIndx]}
  			
			else 
				/usr/bin/curl -X POST https://content.dropboxapi.com/2/files/upload_session/append_v2 >> "/var/www/html/dlogs/daily_log_${FILE_NM}.txt" \
				--header "Authorization: Bearer ${TMP_BEARER_TOKEN}" \
 			    --header "Dropbox-API-Arg: {\"close\":false,\"cursor\":{\"offset\":${FL_SIZE},\"session_id\":\"${CURL_SESSION_ID}\"}}" \
				--header "Content-Type: application/octet-stream" \
				--data-binary @${ARQUIVOS[$arqIndx]}
				
				((FL_SIZE+=$(stat -c%s "${ARQUIVOS[$arqIndx]}")))
			fi
			rm ${ARQUIVOS[$arqIndx]}
		done 

	else
	
		/usr/bin/curl -X POST https://content.dropboxapi.com/2/files/upload -o "/var/www/html/dlogs/daily_log_${FILE_NM}.txt" \
			--header "Authorization: Bearer ${TMP_BEARER_TOKEN}" \
			--header "Dropbox-API-Arg: {\"path\": \"/backup/${ORCL_NM[$i]}/${FILE_NM}.zip\", \"autorename\": true}" \
			--header "Content-Type: application/octet-stream" \
			--data-binary @${PATH_TO_ORCL}/backup/${FILE_NM}.zip
			
		rm ${ARQUIVOS[0]}

 	fi
	$(echo -e "Subject: Rotina de Backup (${ORCL_NM[$i]})\n\nO backup ${FILE_NM}.zip foi gerado com sucesso." | ssmtp ${EMAIL_DESTINO})
done

cp  ${PATH_TO_ORCL}/backup/*.zip /tmp