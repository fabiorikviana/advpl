#Include 'Totvs.ch'
/*/{Protheus.doc} TrocaRPO
Programa que realiza a troca do RPO a quente
@type function
@author Fábio Viana (fabio@vianati.com.br)
@since 25/10/2021
/*/
User Function TrocaRPO()

	Local aRet := {}
	Local aPergs := {}
	local aButtons := {}
	Local nQtde := 0
	Local nX,nY := 0
	Local cDirRPO := ""
	Local aINI := {}
	Private cCONF := "trocarpo.conf"
	Private cCONT := "controle.conf"
	Private cPathConf := "\trocarpo\"
	Private cNomeRPO := ""
	Private cArquivos := ""

	If cReleaserpo > "12.1.025"
		cNomeRPO := "custom.rpo"
	Else
		cNomeRPO := "tttp"+cVersao+".rpo"
	EndIf

	aAdd(aPergs,{6,"RPO Homologado"		,PADR("",150),"",,"",85 ,.T.,"Arquivo RPO|*.RPO","",GETF_LOCALHARD})
	aAdd(aPergs,{6,"Caminho dos Repositórios"	,PADR("",150),"",,"",85 ,.T.,"","",GETF_LOCALHARD+GETF_RETDIRECTORY})
	aAdd(aPergs,{1,"Nome para o RPO"    ,Space(15),"@!",'.T.',,'.T.',40,.F.})
	aAdd(aPergs,{1,"Qtde a controlar", nQtde, "@E 99", "Positivo()", "", ".T.", 80, .F.})

	AAdd(aButtons, {05, {|| TROCARPOA()   }, 'Arquivo de configuração'}) // botão Parametros

	IF !ParamBox(aPergs, "MANUTENÇÃO DE REPOSITÓRIO", aRet,,aButtons,,,,,, .T., .T.)
		//If !ParamBox(aPergs ,"MANUTENÇÃO DE REPOSITÓRIO", aRet,{|| bOKaRet(aRet)},aButtons,,,,,,,)
		MsgInfo("Operação cancelada pelo usuário!")
		Return
	EndIF


	If (Substr(AllTrim(MV_PAR02),Len(AllTrim(MV_PAR02)),1)) != "\"
		MsgStop("Deve informar uma barra invertida '\' no final do caminho do RPO")
		Return
	EndIf

// Abrir o arquivo de controle de repositório.
	oFileCONT := FWFileReader():New(cPathConf+cCONT)

	If !oFileCONT:Open()

		oFileCONT:Close()

		If !ExistDir(cPathConf)
			MakeDir(cPathConf)
		EndIf

		GrvArq(cPathConf+cCONT,{"1"}) // Controle do número de rpo.
		oFileCONT := FWFileReader():New(cPathConf+cCONT)
		If !oFileCONT:Open()
			oFileCONT:Close()
			MsgInfo("Não foi possível abrir o arquivo de controle de repositório!")
			Return
		EndIf

	Endif

	aCont := oFileCONT:getAllLines()

	oFileCONT:Close()

	If !Empty(aCont[1])

		If Val(aCont[1]) <= MV_PAR04

			If Val(aCont[1]) == MV_PAR04 // Se já for a última pasta de rpo.

				GrvArq(cPathConf+cCONT,{"1"}) // Controle do número de rpo.
				cDiretorio := AllTrim(MV_PAR02) +  AllTrim(MV_PAR03) + StrZero(Val(aCont[1]),2)

				If !ExistDir(cDiretorio)
					MakeDir(cDiretorio)
				EndIf

				cDirRPO := AllTrim(MV_PAR03) + StrZero(Val(aCont[1]),2)
				__CopyFile(AllTrim(MV_PAR01) , AllTrim(MV_PAR02) + cDirRPO+"\"+cNomeRPO)

			Else
				cDiretorio := AllTrim(MV_PAR02) +  AllTrim(MV_PAR03) + StrZero(Val(aCont[1]),2)
				If !ExistDir(cDiretorio)
					MakeDir(cDiretorio)
				EndIf

				cDirRPO := AllTrim(MV_PAR03) + StrZero(Val(aCont[1]),2)
				__CopyFile(AllTrim(MV_PAR01) , AllTrim(MV_PAR02) + cDirRPO+"\"+cNomeRPO)
				GrvArq(cPathConf+cCONT,{ Soma1(aCont[1]) } ) // Controle do número de rpo.

			EndIf

		Else

			GrvArq(cPathConf+cCONT,"1") // Controle do número de rpo.
			cDiretorio := AllTrim(MV_PAR02) +  AllTrim(MV_PAR03) + StrZero(1,2)

			If !ExistDir(cDiretorio)
				MakeDir(cDiretorio)
			EndIf

			cDirRPO := AllTrim(MV_PAR03) + StrZero(1,2)
			__CopyFile(AllTrim(MV_PAR01) , AllTrim(MV_PAR02) + cDirRPO+"\"+cNomeRPO)
			GrvArq(cPathConf+cCONT,{ Soma1(aCont[1]) } ) // Controle do número de rpo.

		EndIf

	Else
		MsgStop( "Sequencia não encontrada em: " + cPathConf + cCont, 'ERRO' )
		oFileCONT:Close()
		Return
	EndIf

// Atualiza os arquivos de configuração dos appserver

	oFileINI := FWFileReader():New(cPathConf + cConf)
	If !oFileINI:Open()
		oFileINI:Close()
		MsgStop( "Problema em abrir o arquivo: " + cPathConf + cConf, 'ERRO' )
		Return .F.
	Endif

	aINI := oFileINI:getAllLines()
	nX := 0
	For nX := 1 To Len(aINI)
		cTMP := AllTrim(aINI[nX])

		nHandle := FT_FUse(cTMP)

		If nHandle == -1
			MsgStop('Erro de abertura : FERROR ' + Str(fError(), 4), 'ERRO' )
			FT_FUse()
			Return .F.
		Else
			aLine := {}
			FSeek(nHandle, 0,)
			FT_FGoTop()

			// Retorna o número de linhas do arquivo
			nLast := FT_FLastRec()

			While !FT_FEOF()
				Aadd(aLine,FT_FReadLn())
				// Pula para próxima linha
				FT_FSKIP()
			EndDo

			FT_FUse()

			nY := 0
			For nY := 1 To Len(aLine)

				iF Substr(aLine[nY],1,10) == "SourcePath"
					aLine[nY] := "SourcePath=" + AllTrim(MV_PAR02) + cDirRPO + "\"
				EndIf

			Next nY


			oFileINI := FWFileWriter():New(cTMP)
			If !oFileINI:create()
				oFileINI:Close()
				MsgStop( "Problema em abrir o arquivo: " + cTMP, 'ERRO' )
			Endif

			cLine := ""

			nY := 0
			For nY := 1 To Len(aLine)
				cLine += aLine[nY] + CRLF
			Next nY

			oFileINI:Write(cLine)

			oFileINI:Close()

		Endif

	Next nX


	MsgInfo("O repositório atual é: " + cDirRPO )

Return

/*/{Protheus.doc} TROCARPOA
Função do botão de configurações
@type function
@author Fábio Viana (fabio@vianati.com.br)
@since 26/10/2021
/*/
Static Function TROCARPOA()

	Local aRet		 := {}
	Local aPergs 	:= {}
	Local lOK 		:= .T.
	Local aTexto 	:= {}

	cMV2 := MV_PAR02
	aAdd( aPergs ,{9,"Adicione os arquivos de inicialização que deseja controlar:",200, 40,.T.})
	aAdd(aPergs,{6,"Selecione o INI"		,PADR("",150),"",,"",85 ,.T.,"Arquivo INI *.INI","",GETF_LOCALHARD})

	IF ParamBox(aPergs, "Adicione um arquivo", aRet,,,,,,,, .F., .F.)

		Aadd(aTexto,AllTrim(MV_PAR02))

		While lOK
			IF ParamBox(aPergs, "Adicione um arquivo", aRet,,,,,,,, .F., .F.)
				lOk := .T.
				Aadd(aTexto,AllTrim(MV_PAR02))
			Else
				lOk := .F.

			EndIf
		EndDo
	EndIF
	If !Empty(aTexto)
		If !ExistDir(cPathConf)
			MakeDir(cPathConf)
		EndIf
		GrvArq(cPathConf+cCONF,aTexto) // configurações do appserver
	EndIf

	MV_PAR02 := cMV2
Return

/*/{Protheus.doc} GrvArq
Função que gravar arquivo texto.
@type function
@author fabio
@since 26/10/2021
/*/
Static Function GrvArq(cArq,aTexto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nHandle := FCreate(cArq)
	Local nX := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHandle < 0
		MsgAlert("Erro durante criação do arquivo.")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nX := 1 To Len(aTexto)
			FWrite(nHandle, aTexto[nX] + CRLF)
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FClose(nHandle)
	EndIf

Return
