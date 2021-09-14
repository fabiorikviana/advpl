#Include 'Totvs.ch'

/*/{Protheus.doc} EXECPROG
Função criada para executar programas
@type function
@author Fábio Viana (fabio@vianati.com.br)
@since 09/07/2021
/*/
User Function EXECPROG()

Local lRet := .F.

While !lRet

	cRetorno := FWInputBox("Informe a Função", "")
	lRet := Findfunction(cRetorno)

	If lRet
		MSAguarde({||&cRetorno},"Executando rotina")
	Else
		MsgAlert("Função inexistente!")
	EndIf

EndDo

Return
