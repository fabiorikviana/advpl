#Include 'Totvs.ch'

/*/{Protheus.doc} ImpCT2
Programa criado para importar lançamentos pelo excel em formato csv
@type function
@author fabio
@since 03/09/2021
/*/
User Function ImpCT2()


	Local cFile := ""
	Local cLinha := ""
	Local lPrim := .T.
	Local aCampos := {}
	Local aDados := {}
	LOCAL nCont := 0
	Local aCab := {}
	Local aItens := {}
	Local nX := 1 /// Insira esta linha.


	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private CTF_LOCK := 0
	Private lSubLote := .T.

	cFile := cGetFile("*.csv","Todos os Arquivos",1,"C:\",.T.,GETF_LOCALHARD,.T.,.T.)

	If !File(cFile)
		MsgInfo("Arquivo não encontrado.")
		Return()
	EndIf


	If !File(cFile)
		MsgStop("O arquivo " +cFile + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf

	FT_FUSE(cFile)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))


			nCont++


		EndIf

		FT_FSKIP()
	EndDo

//******************INCIO


	For nX := 1 To nCont

		cDoc        := "000001"
		cLote       := "122020"
		cSubLote    := "001"
		cData       := "20201231"

		If nX == 1 // Fazer somente para a primeira linha
			aAdd(aCab, {'DDATALANC'     , STOD(cData)   ,NIL} )
			aAdd(aCab, {'CLOTE'         , cLote         ,NIL} )
			aAdd(aCab, {'CSUBLOTE'      , cSubLote      ,NIL} )
			aAdd(aCab, {'CDOC'          , cDoc          ,NIL} )
			aAdd(aCab, {'CPADRAO'       , ''            ,NIL} )
			aAdd(aCab, {'NTOTINF'       , 0             ,NIL} )
			aAdd(aCab, {'NTOTINFLOT'    , 0             ,NIL} )
		Endif

		dbSelectArea("CT2")
		dbSetOrder(1)



		cConta      := aDados[nx,1]
		cTipo       := aDados[nx,2]
		If cTipo == 'D'
			cTipo := '1'
		Else
			cTipo := '2'
		EndIf

//		nValor	:= Val(StrTran(aDados[nX,3],",","."))

		nValor := Val(StrTran(StrTran(aDados[nX,3],".",""),",","."))

		cItem       := aDados[nx,4]
		cCcusto     := aDados[nx,5]
		nLinha      := StrZero(nX,3)
		cOrigem     := "CTBA102"
		cHist := "IMPLANTACAO SALDO INICIAL"

		aAdd(aItens,{;
			{'CT2_FILIAL' 	,xFilial("CT2") 			, NIL},;
			{'CT2_FILORI' 	,cFilAnt 					, NIL},;
			{'CT2_LINHA' 	, nLinha	 				, NIL},;
			{'CT2_MOEDLC' 	,'01' 						, NIL},;
			{'CT2_DC' 		,cTipo		 				, NIL},;
			{'CT2_DEBITO' 	,If(cTipo="1",cConta,'')	, NIL},;
			{'CT2_CREDIT' 	,If(cTipo="2",cConta,'')	, NIL},;
			{'CT2_VALOR' 	,nValor						, NIL},;
			{'CT2_ORIGEM' 	,cOrigem 					, NIL},;
			{'CT2_HP' 		,'' 						, NIL},;
			{'CT2_HIST' 	,cHist		 				, NIL},;
			{'CT2_CCD' 		,If(cTipo="1",cCcusto,'')	, NIL},;
			{'CT2_CCC' 		,If(cTipo="2",cCcusto,'')	, NIL},;
			{'CT2_ITEMD' 	,If(cTipo="1",cItem,'')		, NIL},;
			{'CT2_ITEMC'	,If(cTipo="2",cItem,'')		, NIL},;
			{'CT2_TPSALD' 	,"9"			 			, NIL}})

	Next nX

	SetModulo("SIGACTB", "CTB")
	MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

	If lMsErroAuto
		lMsErroAuto := .F.
		MostraErro()
		MsgAlert("ERRO Lançamento" , "Teste Carga CT2")
		lRet := .F.
	Endif


	FT_FUSE()

	ApMsgInfo("Importação concluí­da!")

Return
