#include 'Totvs.ch'

/*/{Protheus.doc} exemplo1
Teste da fun��o parambox
@type function
@author F�bio Viana (www.vianati.com.br - fabio@vianati.com.br)
@since 01/10/2021
/*/
User Function exemplo1()

Local aRet := {}
Local aPergs := {}

    aAdd(aPergs,{9,"Este � um exemplo da fun��o PARAMBOX()."            ,150 , 07,.T.})
	aAdd(aPergs, {1, "Documento  "	, Space(TamSx3("CT2_DOC")[1])		, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "Lote "		, Space(TamSx3("CT2_LOTE")[1])		, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "SubLote "	, Space(TamSx3("CT2_SBLOTE")[1])	, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "Data "		,CToD("  /  /  ")	, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs,{6,"Buscar arquivo",Space(50),"","","",75,.F.,"Arquivos permitidos (*.csv) |*.csv"})
	aAdd(aPergs,{3,"A primeira linha � cabe�alho",1,{"Sim","N�o"},50,"",.F.})

	IF !ParamBox(aPergs, "FUN��O PARAMBOX", aRet,,,,,,,, .F., .F.)
		MsgInfo("Opera��o cancelada pelo usu�rio!")
	EndIF

    MsgInfo("Aqui desenvolve-se o programa!")

Return
