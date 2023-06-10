#!/bin/bash

#Este é o programa ScanNTP (scanntp.sh). 
#Desenvolvido pelo curso da Segurança da Informação, da Univesidade Vale do Rio dos Sinos (UNISINOS) pelo formando Fabrício Rauber. Ficam também créditos ao amigo Marcelo Gondim (gondim at gmail.com) por contribuir com partes deste código-fonte. 
#Autor: Fabricio Rauber - fabriciorauber95 at gmail.com
#Data: 09/06/2023
#Versao: 1.6
#
###############################################################################
# scanntp.sh is free software; you can redistribute it and/or modify ##########
# it under the terms of the GNU General Public License as published by#########
# the Free Software Foundation; either version 2 of the License, or ###########
# (at your option) any later version.##########################################
###############################################################################
# This program is distributed in the hope that it will be useful,##############
# but WITHOUT ANY WARRANTY; without even the implied warranty of ##############
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the ################
# GNU General Public License for more details. ################################
###############################################################################
# You should have received a copy of the GNU General Public License ###########
# along with this program; if not, write to the Free Software #################
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA ####
###############################################################################
#OBS- este script foi testado e executado pelo autor no Ubuntu 22.04.2 LTS e no Kali Linux 2023. Então, nesses sistemas o programa está validado!


#Antes de executar a primeira vez o script scanntp.sh, siga os passos abaixo:
####################################IMPORTANTE/IMPORTANTE/IMPORTANTE/IMPORTANTE/IMPORTANTE/########################################
###################################################################################################################################
####################################PARA RODAR ESSE SCRIPT EH NECESSARIO INSTALAR OS SEGUINTES PROGRAMAS: NMAP E DIALOG.###########
####################################NECESSARIO PERSMISSAO CHMOD 777 AO ARQUIVO TAMBEM.############################################
###############EM RESUMO ANTES DA PRIMIEIRA EXECUCAO, EXECUTE ESSES COMANDOS NO DIRETORIO QUE ESTA O scanntp.sh:
################sudo chmod 777 scanntp.sh
################sudo apt install nmap
################sudo apt install dialog
################sudo sed -i -e 's/\r$//' scanntp.sh

#PRONTO, BASTA EXECUTAR O ARQUVIO AGORA. :D
#./scanntp.sh

vermelho='\033[0;31m'
verde='\033[0;32m'
semcor='\033[0m'

programas=(
nmap
dialog
)

for programa in "${programas[@]}"
do
   if [ -z "`type $programa 2> /dev/null`" ]; then
      echo "Nao tem instalado o programa $programa!, instale e execute novamente o script"
      exit
   fi
done



pause(){
	read -p "Press [Enter] key to continue..." fackEnterKey
}


testeportantpredeCompleto(){
	echo -e "Esse teste salva(incrementa) todos os IPs com portas abertas no arquivo resulTesteCompleto.txt \n"
	echo -e "TESTE COMPLETO - Qual a rede IPv4 /24 que voce deseja consultar o servico NTP - UDP 123 - Formato IPv4 X.X.X.X/24 : \c" 
	read ipv4rede
	resultado1=$(echo $ipv4rede | awk -F'\.' '{if($1 >= '0' && $1 <= '255') {print $1} else {print "Esse IPv4 nao eh valido"}}')
	resultado2=$(echo $ipv4rede | awk -F'\.' '{if($2 >= '0' && $2 <= '255') {print $2} else {print "Esse IPv4 nao eh valido"}}')
	resultado3=$(echo $ipv4rede | awk -F'\.' '{if($3 >= '0' && $3 <= '255') {print $3} else {print "Esse IPv4 nao eh valido"}}')
	ipsemfinal=$(echo $resultado1"."$resultado2"."$resultado3".")
	for (( variavelI=0; variavelI<=255; variavelI++ ))
	do 
		ipformatado=$(echo $ipsemfinal$variavelI)
		echo -e "Testando NTP (123/udp) no IP $ipformatado ..."
		if [ "`nmap -sU -pU:123 -Pn -n $ipformatado | grep open | awk '{print $2}'`" == "open" ]; then  #`-sU - protocolo UDP` `-pU123 - porta` `-Pn desativa sondagens adicionais do nmap, como ping` `-n desativa resolucao de DNS` 
		echo -e "Teste de NTP (123/udp) no IP $ipformatado - Porta: ${vermelho}Aberta${semcor} \n"
		echo -e "Teste de NTP (123/udp) no IP $ipformatado - Porta: Aberta" >> resulTesteCompleto.txt
	else
   		echo -e "Teste de NTP (123/udp) no IP $ipformatado - Porta: ${verde}Fechada${semcor} \n"
	fi
	done
	pause
}

testeportantpredeRapido(){
	echo -e "Esse teste demora cerca de 50 segundos e os resultados serao salvos no arquivo resulTesteRapido.txt \n"
	echo -e "TESTE RAPIDO - Qual a rede IPv4 /24 que voce deseja consultar o servico NTP - UDP 123 - Formato IPv4 X.X.X.X/24 : \c" 
	read ipv4rederap
	resultadorapido=$(nmap -sU -pU:123 -Pn -n $ipv4rederap)
	echo $resultadorapido>resulTesteRapido.txt
	echo $resultadorapido
        pause
}

testaportantp(){
	echo -e "Qual o IP que voce deseja consultar o servico NTP - UDP 123 - Formato IPv4 X.X.X.X : \c" 
	read ipv4unico
	echo -e "Testando NTP (123/udp) no IP $ipv4unico - Porta: \c"
	if [ "`nmap -sU -pU:123 -Pn -n $ipv4unico | grep open | awk '{print $2}'`" == "open" ]; then  #`-sU - protocolo UDP` `-pU123 - porta` `-Pn desativa sondagens adicionais do nmap, como ping` `-n desativa resolucao de DNS` 
		echo -e "${vermelho}Aberta${semcor}"
	else
   		echo -e "${verde}Fechada${semcor}"
	fi
	pause
}

testaversao(){
	echo -e "Se a porta UDP 123 estiver ABERTA voce pode conseguir dados relevantes desse servidor NTP, caso o servidor esteja numa versao vuleravel.\n"
	echo -e "IMPORTANTE. SE o servidor ESTA numa versao vulneravel, serao retornados campos como Versao do Servidor NTP, Sistema Operacional, Jitter, OffSet e os Dados da Mensagem(valores de tempo). SE o servidor NAO ESTA numa versao vulneravel a este ataque, so retornara um valor com Dados de Mensagem(receive time stamp: ).\n"
	echo -e "Qual o IP que voce deseja consultar o servico NTP - UDP 123 ABERTA - Formato IPv4 X.X.X.X : \c" 
	read ipv4versao
	resultadoversao=$(nmap -sU -p 123 --script ntp-info $ipv4versao)
	echo $resultadoversao>resulTesteVersao.txt
	echo $resultadoversao
	pause
}	


trap '' SIGQUIT SIGTSTP
 

while true
do
 	menuOpc=$( dialog --stdout --title 'Programa ScanNTP - Script scanntp.sh - by: f16' --menu 'Selecione uma opcao:' 0 0 0 1 'Procure por uma rede /24 Vulneravel no NTP - TESTE COMPLETO' 2 'Procure por uma rede /24 Vulneravel no NTP - TESTE RAPIDO' 3 'Procure por um IPv4 com servico NTP aberto - Porta UDP 123' 4 'Procure por um IPv4 com versao NTP vulneravel ' 5 'Fechar programa'  )
	
	case $menuOpc in
		1) testeportantpredeCompleto ;;
		2) testeportantpredeRapido ;;
		3) testaportantp ;;
		4) testaversao ;;
		5) exit 0;;

	esac
done



