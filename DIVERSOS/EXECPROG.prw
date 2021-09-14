#Include 'Totvs.ch'

/*/{Protheus.doc} EXECPROG
Fun��o criada para executar programas
@type function
@author F�bio Viana (fabio@vianati.com.br)
@since 09/07/2021
/*/
User Function EXECPROG()

Local lRet := .F.

While !lRet

	cRetorno := FWInputBox("Informe a Fun��o", "")
	lRet := Findfunction(cRetorno)

	If lRet
		MSAguarde({||&cRetorno},"Executando rotina")
	Else
		MsgAlert("Fun��o inexistente!")
	EndIf

EndDo

Return
