; ====================================
; = PureDocs by Markus Büttner, 2013 =
; =   Licensed under CC BY-SA 4.0    =
; ====================================

EnableExplicit

;- Modules
XIncludeFile "Modules/Module.HTMLUtils.pb"
XIncludeFile "Modules/Module.HTML5Generator.pb"

;- Structures
Structure MethodData
    doc.s
    hasReturnValue.b
    methodSignature.s
    returnValue.s
EndStructure

Structure ModuleData
    Map Methods.MethodData()
    moduleName.s
    doc.s
EndStructure

Structure SourceData
    Map Modules.ModuleData()
    Map Methods.MethodData()
EndStructure

;- Global variables and constants
Global argc.l = CountProgramParameters()
Global Dim files.s(argc)
Global NewMap Sourcefiles.SourceData()
Global NewMap Types.s()

;- Function declarations
Declare.s getMethodName(signature$)

;- Initialization code
Define fileHandle.l, line$, docComment$, i.l, regexMethodPattern, regexModuleEnd, directory.l
Define isModule.b, currentModule$, currentProcedure$, signature$, methodName$, returnValue.s, file$

regexMethodPattern = CreateRegularExpression(#PB_Any, "(?i)((?<!End)Procedure(?!Return)|(?<!End)Declare(Module)?|(?<!Declare|End)Module)")
regexModuleEnd = CreateRegularExpression(#PB_Any, "(?i)(End(?:Declare)?Module)")

;{ Types initialization
Types("a") = "Ascii"
Types("b") = "Byte"
Types("c") = "Character"
Types("d") = "Double"
Types("f") = "Float"
Types("i") = "Integer"
Types("l") = "Long"
Types("q") = "Quad"
Types("s") = "String"
Types("$") = "String"
Types("u") = "Unicode"
Types("w") = "Word"
;}

;- Program arguments
For i = 0 To argc
    files(i) = ProgramParameter()    
Next

;- Scan files
For i = 0 To argc
    If FileSize(files(i)) > 0 ; no need to scan empty files
        fileHandle = ReadFile(#PB_Any, files(i), #PB_File_SharedRead)
        If fileHandle
            While Eof(fileHandle) = #False
                line$ = Trim(ReadString(fileHandle))
                If FindString(line$, ";;") = 1
                    docComment$ + line$ + #LF$
                ElseIf MatchRegularExpression(regexMethodPattern, line$) And FindString(line$, "PB_Module", 1, #PB_String_NoCase) = #False
                    If FindString(line$, ";") = 1
                        docComment$ = ""
                    Else
                        isModule = Bool(FindString(line$, "Module", 1, #PB_String_NoCase) > 0)
                        signature$ = ReplaceRegularExpression(regexMethodPattern, line$, "")
                        
                        If isModule = #True
                            currentModule$ = Trim(signature$)
                            Sourcefiles(files(i))\Modules(currentModule$)\moduleName = Trim(signature$)
                            Sourcefiles(files(i))\Modules(currentModule$)\doc + docComment$
                        Else
                            methodName$ = getMethodName(signature$)
                            returnValue = Types(ReplaceString(StringField(signature$, 1, " "), ".", ""))
                            If returnValue = ""
                                returnValue = "Long"
                            EndIf
                            If currentModule$ <> ""
                                Sourcefiles(files(i))\Modules(currentModule$)\Methods(methodName$)\methodSignature = signature$
                                Sourcefiles(files(i))\Modules(currentModule$)\Methods(methodName$)\doc + docComment$
                                Sourcefiles(files(i))\Modules(currentModule$)\Methods(methodName$)\hasReturnValue = #False
                                Sourcefiles(files(i))\Modules(currentModule$)\Methods(methodName$)\returnValue = returnValue
                            Else
                                Sourcefiles(files(i))\Methods(methodName$)\methodSignature = signature$
                                Sourcefiles(files(i))\Methods(methodName$)\doc + docComment$
                                Sourcefiles(files(i))\Methods(methodName$)\hasReturnValue = #False
                                Sourcefiles(files(i))\Methods(methodName$)\returnValue = returnValue
                            EndIf
                        EndIf
                        docComment$ = ""
                    EndIf
                ElseIf MatchRegularExpression(regexModuleEnd, line$)
                    If FindString(line$, ";") <> 1
                        currentModule$ = ""
                        docComment$ = ""
                    EndIf
                ElseIf FindString(line$, "ProcedureReturn") And currentProcedure$ <> ""
                    If currentModule$ = ""
                        Sourcefiles(files(i))\Methods(currentProcedure$)\hasReturnValue = #True
                    Else
                        Sourcefiles(files(i))\Modules(currentModule$)\Methods(currentProcedure$)\hasReturnValue = #True
                    EndIf
                EndIf
            Wend
            CloseFile(fileHandle)
        EndIf
    ElseIf FileSize(files(i)) = -2
        If Right(files(i), 1) <> "/"
            files(i) + "/"
        EndIf
        directory = ExamineDirectory(#PB_Any, files(i), "*.pb")
        If directory
            While NextDirectoryEntry(directory)
                If DirectoryEntryType(directory) = #PB_DirectoryEntry_File
                    file$ = files(i) + DirectoryEntryName(directory)
                    fileHandle = ReadFile(#PB_Any, file$, #PB_File_SharedRead)
                    If fileHandle
                        While Eof(fileHandle) = #False
                            line$ = Trim(ReadString(fileHandle))
                            If FindString(line$, ";;") = 1
                                docComment$ + line$ + #LF$
                            ElseIf MatchRegularExpression(regexMethodPattern, line$) And FindString(line$, "PB_Module", 1, #PB_String_NoCase) = #False
                                If FindString(line$, ";") = 1
                                    docComment$ = ""
                                Else
                                    isModule = Bool(FindString(line$, "Module", 1, #PB_String_NoCase) > 0)
                                    signature$ = ReplaceRegularExpression(regexMethodPattern, line$, "")
                                    
                                    If isModule = #True
                                        currentModule$ = Trim(signature$)
                                        Sourcefiles(file$)\Modules(currentModule$)\moduleName = Trim(signature$)
                                        Sourcefiles(file$)\Modules(currentModule$)\doc + docComment$
                                    Else
                                        methodName$ = getMethodName(signature$)
                                        returnValue = Types(ReplaceString(StringField(signature$, 1, " "), ".", ""))
                                        If returnValue = ""
                                            returnValue = "Long"
                                        EndIf
                                        If currentModule$ <> ""
                                            Sourcefiles(file$)\Modules(currentModule$)\Methods(methodName$)\methodSignature = signature$
                                            Sourcefiles(file$)\Modules(currentModule$)\Methods(methodName$)\doc + docComment$
                                            Sourcefiles(file$)\Modules(currentModule$)\Methods(methodName$)\hasReturnValue = #False
                                            Sourcefiles(file$)\Modules(currentModule$)\Methods(methodName$)\returnValue = returnValue
                                        Else
                                            Sourcefiles(file$)\Methods(methodName$)\methodSignature = signature$
                                            Sourcefiles(file$)\Methods(methodName$)\doc + docComment$
                                            Sourcefiles(file$)\Methods(methodName$)\hasReturnValue = #False
                                            Sourcefiles(file$)\Methods(methodName$)\returnValue = returnValue
                                        EndIf
                                    EndIf
                                    docComment$ = ""
                                EndIf
                            ElseIf MatchRegularExpression(regexModuleEnd, line$)
                                If FindString(line$, ";") <> 1
                                    currentModule$ = ""
                                    docComment$ = ""
                                EndIf
                            ElseIf FindString(line$, "ProcedureReturn") And currentProcedure$ <> ""
                                If currentModule$ = ""
                                    Sourcefiles(file$)\Methods(currentProcedure$)\hasReturnValue = #True
                                Else
                                    Sourcefiles(file$)\Modules(currentModule$)\Methods(currentProcedure$)\hasReturnValue = #True
                                EndIf
                            EndIf
                        Wend
                        CloseFile(fileHandle)
                    EndIf
                EndIf
            Wend
            FinishDirectory(directory)
        EndIf   
    EndIf
Next

;- Generate files
Define.HTML5Generator::Element container, heading, paragraph, method_container, method_header, method_paragraph
heading\tag$ = HTML5Generator::#HTML_TAG_H + "1"
paragraph\tag$ = HTML5Generator::#HTML_TAG_P
method_header\tag$ = HTML5Generator::#HTML_TAG_H + "2"
method_paragraph\tag$ = HTML5Generator::#HTML_TAG_P

ForEach Sourcefiles()
    ClearStructure(@method_container, HTML5Generator::Element)
    InitializeStructure(@method_container, HTML5Generator::Element)
    method_container\tag$ = HTML5Generator::#HTML_TAG_DIV
    
    ClearStructure(@container, HTML5Generator::Element)
    InitializeStructure(@container, HTML5Generator::Element)
    container\tag$ = HTML5Generator::#HTML_TAG_DIV
    
    HTML5Generator::clean()
    HTML5Generator::setCharset("UTF-8")
    HTML5Generator::setTitle(GetFilePart(MapKey(Sourcefiles())))
    
    i = 0
    ForEach Sourcefiles()\Modules()
        If i <> 0
            HTML5Generator::addHTMLElementFast(HTML5Generator::#HTML_TAG_HR)
        EndIf
        heading\content$ = MapKey(Sourcefiles()\Modules())
        paragraph\content$ = HTMLUtils::htmlentities(Trim(ReplaceString(Sourcefiles()\Modules()\doc, ";", "")))
        paragraph\content$ = HTMLUtils::nl2br(paragraph\content$)
        
        AddElement(container\childElementsAfterContent())
        container\childElementsAfterContent() = heading 
        AddElement(container\childElementsAfterContent())
        container\childElementsAfterContent() = paragraph
        
        ForEach Sourcefiles()\Modules()\Methods()
            If Sourcefiles()\Modules()\Methods()\hasReturnValue
                method_header\content$ = Trim(Sourcefiles()\Modules()\Methods()\returnValue + " " + MapKey(Sourcefiles()\Modules()\Methods()))
            Else
                method_header\content$ = Trim(MapKey(Sourcefiles()\Modules()\Methods()))
            EndIf
            method_paragraph\content$ = HTMLUtils::htmlentities(Trim(ReplaceString(Sourcefiles()\Modules()\Methods()\doc, ";", "")))
            method_paragraph\content$ = HTMLUtils::nl2br(method_paragraph\content$)
            
            AddElement(method_container\childElementsAfterContent())
            method_container\childElementsAfterContent() = method_header
            AddElement(method_container\childElementsAfterContent())
            method_container\childElementsAfterContent() = method_paragraph
        Next
        
        AddElement(container\childElementsAfterContent())
        container\childElementsAfterContent() = method_container
        
        i + 1 
    Next
    HTML5Generator::addHTMLElement(container)
    
    ForEach Sourcefiles()\Methods()
        If i <> 0
            HTML5Generator::addHTMLElementFast(HTML5Generator::#HTML_TAG_HR)
        EndIf
        heading\content$ = MapKey(Sourcefiles()\Methods())
        paragraph\content$ = Trim(ReplaceString(HTMLUtils::nl2br(Sourcefiles()\Methods()\doc), ";", ""))
        
        AddElement(container\childElementsAfterContent())
        container\childElementsAfterContent() = heading 
        AddElement(container\childElementsAfterContent())
        container\childElementsAfterContent() = paragraph
        i + 1 
    Next
    
    HTML5Generator::generate(MapKey(Sourcefiles()) + ".html")
Next

End

Procedure.s getMethodName(signature$)
    Static regexMethodName
    Protected Dim groups$(0)
    
    If regexMethodName = 0
        regexMethodName = CreateRegularExpression(#PB_Any, " (\w+)\(")
    EndIf
    
    ExtractRegularExpression(regexMethodName, signature$, groups$())
    ProcedureReturn Trim(ReplaceString(groups$(0), "(", ""))
EndProcedure
; IDE Options = PureBasic 5.21 LTS (Windows - x64)
; CursorPosition = 215
; FirstLine = 203
; Folding = 0
; EnableXP