CompilerIf Defined(HTML5Generator, #PB_Module) = #False
    
    ;; Generates a HTML5 Document.
    ;; @author Markus Büttner
    ;; @version 1.0
    DeclareModule HTML5Generator
        
        Structure Element
            List childElementsAfterContent.Element()
            List childElementsBeforeContent.Element()
            Map Attributes.s()
            content$
            tag$
        EndStructure
        
        ;- Tags
        ;{
        #HTML_TAG_A = "a"
        #HTML_TAG_ABBR = "abbr"
        #HTML_TAG_ADDRESS = "address"
        #HTML_TAG_AREA = "area"
        #HTML_TAG_ARTICLE = "article"
        #HTML_TAG_ASIDE = "aside"
        #HTML_TAG_AUDIO = "audio"
        #HTML_TAG_B = "b"
        #HTML_TAG_BASE = "base"
        #HTML_TAG_BDI = "bdi"
        #HTML_TAG_BDO = "bdo"
        #HTML_TAG_BLOCKQUOTE = "blockquote"
        #HTML_TAG_BR = "br"
        #HTML_TAG_BUTTON = "button"
        #HTML_TAG_CANVAS = "canvas"
        #HTML_TAG_CAPTION = "caption"
        #HTML_TAG_CITE = "cite"
        #HTML_TAG_CODE = "code"
        #HTML_TAG_COL = "col"
        #HTML_TAG_COLGROUP = "colgroup"
        #HTML_TAG_COMMAND = "command"
        #HTML_TAG_DATALIST = "datalist"
        #HTML_TAG_DD = "dd"
        #HTML_TAG_DEL = "del"
        #HTML_TAG_DETAILS = "details"
        #HTML_TAG_DFN = "dfn"
        #HTML_TAG_DIALOG = "dialog"
        #HTML_TAG_DIV = "div"
        #HTML_TAG_DL = "dl"
        #HTML_TAG_DT = "dt"
        #HTML_TAG_EM = "em"
        #HTML_TAG_EMBED = "embed"
        #HTML_TAG_FIELDSET = "fieldset"
        #HTML_TAG_FIGCAPTION = "figcaption"
        #HTML_TAG_FIGURE = "figure"
        #HTML_TAG_FOOTER = "footer"
        #HTML_TAG_FORM = "form"
        #HTML_TAG_H = "h"
        #HTML_TAG_HEADER = "header"
        #HTML_TAG_HR = "hr"
        #HTML_TAG_I = "i"
        #HTML_TAG_IFRAME = "iframe"
        #HTML_TAG_IMG = "img"
        #HTML_TAG_INPUT = "input"
        #HTML_TAG_INS = "ins"
        #HTML_TAG_KBD = "kbd"
        #HTML_TAG_KEYGEN = "keygen"
        #HTML_TAG_LABEL = "label"
        #HTML_TAG_LEGEND = "legend"
        #HTML_TAG_LI = "li"
        #HTML_TAG_LINK = "link"
        #HTML_TAG_MAP = "map"
        #HTML_TAG_MARK = "mark"
        #HTML_TAG_MENU = "menu"
        #HTML_TAG_METER = "meter"
        #HTML_TAG_NAV = "nav"
        #HTML_TAG_NOSCRPIT = "noscript"
        #HTML_TAG_OBJECT = "object"
        #HTML_TAG_OL = "ol"
        #HTML_TAG_OPTGROUP = "optgroup"
        #HTML_TAG_OPTION = "option"
        #HTML_TAG_OUTPUT = "output"
        #HTML_TAG_P = "p"
        #HTML_TAG_PARAM = "param"
        #HTML_TAG_PRE = "pre"
        #HTML_TAG_PROGRESS = "progress"
        #HTML_TAG_Q = "q"
        #HTML_TAG_RP = "rp"
        #HTML_TAG_RT = "rt"
        #HTML_TAG_RUBY = "ruby"
        #HTML_TAG_S = "s"
        #HTML_TAG_SAMP = "samp"
        #HTML_TAG_SCRIPT = "script"
        #HTML_TAG_SECTION = "section"
        #HTML_TAG_SELECT = "select"
        #HTML_TAG_SMALL = "small"
        #HTML_TAG_SOURCE = "source"
        #HTML_TAG_SPAN = "span"
        #HTML_TAG_STRONG = "strong"
        #HTML_TAG_STYLE = "style"
        #HTML_TAG_SUB = "sub"
        #HTML_TAG_SUMMARY = "summary"
        #HTML_TAG_SUP = "sup"
        #HTML_TAG_TABLE = "table"
        #HTML_TAG_TBODY = "tbody"
        #HTML_TAG_TD = "td"
        #HTML_TAG_TEXTAREA = "textarea"
        #HTML_TAG_TFOOT = "tfoot"
        #HTML_TAG_TH = "th"
        #HTML_TAG_THEAD = "thead"
        #HTML_TAG_TIME = "time"
        #HTML_TAG_TITLE = "title"
        #HTML_TAG_TR = "tr"
        #HTML_TAG_TRACK = "track"
        #HTML_TAG_U = "u"
        #HTML_TAG_UL = "ul"
        #HTML_TAG_VAR = "var"
        #HTML_TAG_VIDEO = "video"
        #HTML_TAG_WBR = "wbr"
        ;} 
        
        ;; Cleans the current document.
        Declare clean()
        ;; Generates the HTML5 document and saves it in the specified file. Returnes an error message on error.
        Declare.s generate(file$)
        ;; Sets the title of the current document.
        Declare setTitle(title$)
        ;; Sets the charset of the current document.
        Declare setCharset(charset$)
        ;; Adds an element to the document
        Declare addHTMLElement(*HTMLElement.Element)
        ;; Adds an element without child elements to the document
        Declare addHTMLElementFast(element$, content$ = "")
        ;; Adds a javascript file to the document
        Declare addScript(path$)
        ;; Adds a css file to the document
        Declare addStylesheet(path$)
        ;; Adds an javscript function to the event for the body. jsfunction$ must include the brackets of the function!
        ;; Note: Eventhandlers will be overwritten!
        ;Declare addEventHandlerToBody(event$, jsfunction$)
        
    EndDeclareModule
    
    Module HTML5Generator
        
        Structure MetaTag
            http_equiv.s
            content.s
            name.s
        EndStructure
        
        Global NewList MetaTags.MetaTag(), NewList Elements.Element(), NewList Stylesheets.s(), NewList Scripts.s()
        Global NewMap bodyEventHandlers.s()
        Global documentCharset$, documentTitle$
        
        Declare.s ElementToString(*HTMLElement.Element)
        
        Procedure clean()
            ClearList(MetaTags())
            ClearList(Elements())
            documentCharset$ = ""
            documentTitle$ = ""
        EndProcedure
        
        Procedure.s generate(file$)
            Protected.l file = CreateFile(#PB_Any, file$)
            Protected html$
            
            If file
                html$ = "<!DOCTYPE html>"
                html$ + "<html>"
                html$ + "<head>"
                html$ + "<meta charset='" + documentCharset$ + "'>"
                
                ForEach MetaTags()
                    If MetaTags()\http_equiv = ""
                        html$ + "<meta name='" + MetaTags()\name + "' content='" + MetaTags()\content + "'>"
                    Else
                        html$ + "<meta http-equiv='" + MetaTags()\http_equiv + "' content='" + MetaTags()\content + "'>"
                    EndIf
                Next
                
                html$ + "<title>" + documentTitle$ + "</title>"
                
                ForEach Stylesheets()
                    html$ + "<link rel='stylesheet' type='text/css' href='" + Stylesheets() + "'>"
                Next
                ForEach Scripts()
                    html$ + "<script type='text/javascript' src='" + Scripts() + "'></script>"
                Next
                
                html$ + "</head>"
                html$ + "<body"
                
                ForEach bodyEventHandlers()
                    html$ + " " + MapKey(bodyEventHandlers()) + "='" + bodyEventHandlers() + ";'"
                Next
                
                html$ + ">"
                
                ForEach Elements()
                    html$ + ElementToString(Elements())
                Next
                
                html$ + "</body>"
                html$ + "</html>"
                
                WriteString(file, html$)
                CloseFile(file)
            Else
                ProcedureReturn "Failed to create file"
            EndIf
        EndProcedure
        
        Procedure setTitle(title$)
            documentTitle$ = title$
        EndProcedure
        
        Procedure setCharset(charset$)
            documentCharset$ = charset$
        EndProcedure
        
        Procedure addHTMLElement(*HTMLElement.Element)
            AddElement(Elements())
            CopyMap(*HTMLElement\Attributes(), Elements()\Attributes())
            CopyList(*HTMLElement\childElementsAfterContent(), Elements()\childElementsAfterContent())
            CopyList(*HTMLElement\childElementsBeforeContent(), Elements()\childElementsBeforeContent())
            Elements()\content$ = *HTMLElement\content$
            Elements()\tag$ = *HTMLElement\tag$
        EndProcedure
        
        Procedure addHTMLElementFast(element$, content$ = "")
            AddElement(Elements())
            Elements()\tag$ = element$
            Elements()\content$ = content$
        EndProcedure
        
        Procedure addScript(path$)
            AddElement(Scripts())
            Scripts() = path$
        EndProcedure
        
        Procedure addStylesheet(path$)
            AddElement(Stylesheets())
            Stylesheets() = path$
        EndProcedure
        
        Procedure.s ElementToString(*HTMLElement.Element)
            add$ = "<" + *HTMLElement\tag$
            
            If *HTMLElement\tag$ <> #HTML_TAG_HR And *HTMLElement\tag$ <> #HTML_TAG_IMG
                ForEach *HTMLElement\Attributes()
                    add$ + " " + MapKey(*HTMLElement\Attributes()) + "='" + *HTMLElement\Attributes() + "'"
                Next
            EndIf
            
            add$ + ">"
            
            If *HTMLElement\tag$ <> #HTML_TAG_HR And *HTMLElement\tag$ <> #HTML_TAG_IMG And *HTMLElement\tag$ <> #HTML_TAG_INPUT
                ForEach *HTMLElement\childElementsBeforeContent()
                    add$ + ElementToString(*HTMLElement\childElementsBeforeContent())
                Next
                
                add$ + *HTMLElement\content$
                
                ForEach *HTMLElement\childElementsAfterContent()
                    add$ + ElementToString(*HTMLElement\childElementsAfterContent())
                Next
                
                add$ + "</" + *HTMLElement\tag$ + ">"
            EndIf
            
            ProcedureReturn add$
        EndProcedure
        
    EndModule
    
CompilerEndIf

; IDE Options = PureBasic 5.21 LTS (Windows - x64)
; CursorPosition = 263
; FirstLine = 108
; Folding = Vk-
; EnableXP