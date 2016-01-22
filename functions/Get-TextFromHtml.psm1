<# 
 Utility to convert HTML to text since it seems that the snippet display in ISE cannot handle
 HTML, and Sample Exchange uses HTML for the description.  This code was taken from 
 http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/ 
 #>
function Get-TextFromHtml { 
     param([System.String] $html) 
 
     # remove line breaks, replace with spaces 
     $html = $html -replace "(`r|`n|`t)", " " 
     # write-verbose "removed line breaks: `n`n$html`n" 
 
     # remove invisible content 
     @('head', 'style', 'script', 'object', 'embed', 'applet', 'noframes', 'noscript', 'noembed') | % { 
      $html = $html -replace "<$_[^>]*?>.*?</$_>", "" 
     } 
     # write-verbose "removed invisible blocks: `n`n$html`n" 
 
     # Condense extra whitespace 
     $html = $html -replace "( )+", " " 
     # write-verbose "condensed whitespace: `n`n$html`n" 
 
     # Add line breaks 
     @('div','p','blockquote','h[1-9]') | % { $html = $html -replace "</?$_[^>]*?>.*?</$_>", ("`n" + '$0' )}  
     # Add line breaks for self-closing tags 
     @('div','p','blockquote','h[1-9]','br') | % { $html = $html -replace "<$_[^>]*?/>", ('$0' + "`n")}  
     # write-verbose "added line breaks: `n`n$html`n" 
 
     #strip tags  
     $html = $html -replace "<[^>]*?>", "" 
     # write-verbose "removed tags: `n`n$html`n" 
   
     # replace common entities 
     @(  
      @("&amp;bull;", " * "), 
      @("&amp;lsaquo;", "<"), 
      @("&amp;rsaquo;", ">"), 
      @("&amp;(rsquo|lsquo);", "'"), 
      @("&amp;(quot|ldquo|rdquo);", '"'), 
      @("&amp;trade;", "(tm)"), 
      @("&amp;frasl;", "/"), 
      @("&amp;(quot|#34|#034|#x22);", '"'), 
      @('&amp;(amp|#38|#038|#x26);', "&amp;"), 
      @("&amp;(lt|#60|#060|#x3c);", "<"), 
      @("&amp;(gt|#62|#062|#x3e);", ">"), 
      @('&amp;(copy|#169);', "(c)"), 
      @("&amp;(reg|#174);", "(r)"), 
      @("&amp;nbsp;", " "), 
      @("&amp;(.{2,6});", "") 
     ) | % { $html = $html -replace $_[0], $_[1] } 
     # write-verbose "replaced entities: `n`n$html`n" 
 
     return $html  
}