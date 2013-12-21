CompilerIf Defined(HTMLUtils, #PB_Module) = #False
    
    ;; HTML util functions
    DeclareModule HTMLUtils
        
        ;; Converts all newlines to breaks
        Declare.s nl2br(string$)
        
        ;; Escapes characters such as <, >, " and ' to html entites
        Declare.s htmlentities(string$)
        
    EndDeclareModule
    
    Module HTMLUtils
        
        Procedure.s nl2br(string$)
            string$ = ReplaceString(string$, #LFCR$, "<br>")
            string$ = ReplaceString(string$, #CRLF$, "<br>")
            string$ = ReplaceString(string$, #CR$, "<br>")
            string$ = ReplaceString(string$, #LF$, "<br>")
            
            ProcedureReturn string$
        EndProcedure
        
        Procedure.s htmlentities(string$)
            string$ = ReplaceString(string$, "<", "&lt;")
            string$ = ReplaceString(string$, ">", "&gt;")
            string$ = ReplaceString(string$, Chr(34), "&quot;")
            string$ = ReplaceString(string$, Chr(39), "&#39;")
            
            ProcedureReturn string$
        EndProcedure
        
    EndModule
    
CompilerEndIf
; IDE Options = PureBasic 5.21 LTS (Windows - x64)
; CursorPosition = 19
; Folding = -
; EnableXP