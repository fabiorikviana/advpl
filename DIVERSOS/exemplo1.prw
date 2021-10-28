#include 'Totvs.ch'

/*/{Protheus.doc} exemplo1
Teste da função parambox
@type function
@author Fábio Viana (www.vianati.com.br - fabio@vianati.com.br)
@since 01/10/2021
/*/
User Function exemplo1()

Local aRet := {}
Local aPergs := {}

    aAdd(aPergs,{9,"Este é um exemplo da função PARAMBOX()."            ,150 , 07,.T.})
	aAdd(aPergs, {1, "Documento  "	, Space(TamSx3("CT2_DOC")[1])		, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "Lote "		, Space(TamSx3("CT2_LOTE")[1])		, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "SubLote "	, Space(TamSx3("CT2_SBLOTE")[1])	, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs, {1, "Data "		,CToD("  /  /  ")	, "", "", ""	, ".T.", 50, .T.})
	aAdd(aPergs,{6,"Buscar arquivo",Space(50),"","","",75,.F.,"Arquivos permitidos (*.csv) |*.csv"})
	aAdd(aPergs,{3,"A primeira linha é cabeçalho",1,{"Sim","Não"},50,"",.F.})

	IF !ParamBox(aPergs, "FUNÇÃO PARAMBOX", aRet,,,,,,,, .F., .F.)
		MsgInfo("Operação cancelada pelo usuário!")
	EndIF

    MsgInfo("Aqui desenvolve-se o programa!")

Return
