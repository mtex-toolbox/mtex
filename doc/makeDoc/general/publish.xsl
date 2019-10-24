<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into HTML.
Use the XSLT command to perform the conversion.

-->

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> <!ENTITY reg "&#174;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd">
  <xsl:output method="html"
              indent="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>
  <xsl:strip-space elements="mwsh:code"/>
  
  <xsl:variable name="toolbox" select="document('toolbox.xml')/mytoolbox"/>
  
  <xsl:include href="makelink.xsl"/>
  

    
  <xsl:template match="mscript">
    <html>
      <!-- head -->      
      <xsl:variable name="title">
      <xsl:variable name="dTitle" select="//steptitle[@style='document']"/>
        <xsl:apply-templates select="$dTitle"/> (<xsl:apply-templates select="$toolbox/name"/> Toolbox)
      </xsl:variable>  
      <xsl:variable name="docname">
        <xsl:call-template name="backreplacelinkdot"><xsl:with-param name="string" select="m-file"/></xsl:call-template>
      </xsl:variable>
  
      <head><title><xsl:value-of select="$title"/></title><xsl:text>
        </xsl:text><xsl:value-of select="'&lt;!-- DOCNAME: '" disable-output-escaping="yes"/><xsl:value-of select="$toolbox/name" disable-output-escaping="yes"/><xsl:value-of select="' Toolbox --&gt;'" disable-output-escaping="yes"/>
        <meta name="chunktype" content="refpage"/><xsl:text>
        </xsl:text><xsl:value-of select="'&lt;!-- CHUNKNAME: '" disable-output-escaping="yes"/><xsl:value-of select="$docname"/><xsl:value-of select="' --&gt;'" disable-output-escaping="yes"/><xsl:text>
        </xsl:text><xsl:value-of select="'&lt;!-- HEADSTUFF: '" disable-output-escaping="yes"/><xsl:value-of select="$docname"/><xsl:value-of select="' --&gt;'" disable-output-escaping="yes"/><xsl:text>
        </xsl:text><xsl:value-of select="'&lt;!-- HEADSTUFF --&gt;'" disable-output-escaping="yes"/>
        <meta name="refentity"><xsl:attribute name="content">method:<xsl:value-of select="$docname"/></xsl:attribute> </meta>
        <meta http-equiv="Content-Script-Type" content="text/javascript"/>
        <meta name="toctype" content="fcn"/>
        <link rel="stylesheet" href="style.css"/>
        <script language="JavaScript" src="docscripts.js"></script>
      </head>
      
      <body>        
        <a name="top_of_page"></a>
        <!--<p><xsl:attribute name="style">font-size:1px;</xsl:attribute></p>-->
      
        <xsl:variable name="body-cells" select="cell[not(@style = 'overview')]"/>
        
        <xsl:variable name="hasContents"> 
          <xsl:for-each select="$body-cells">
            <xsl:if test="steptitle = 'Contents'"><xsl:value-of select="position()"/></xsl:if>
          </xsl:for-each>
        </xsl:variable>
        
        
        <xsl:variable name="source">
          <xsl:if test="count(cell[steptitle = 'Open in Editor']) or count(cell[steptitle = 'View Code'])">
            <xsl:call-template name="backreplacelink">
              <xsl:with-param name="string" select="m-file"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:variable>
        
        <!-- make the header bar-->
        <xsl:choose>      
          <xsl:when test="count(cell[steptitle = 'Open in Editor'])">
            <xsl:call-template name="openheader"><xsl:with-param name="sourceref" select="$source"/></xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
           <xsl:call-template name="header"><xsl:with-param name="sourceref" select="$source"/></xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        
        <div class="content">
          
          <!-- Determine if the there should be an introduction section. -->
          <xsl:variable name="hasIntro" select="count(cell[@style = 'overview'])"/>        
          
          <!-- If there is an introduction, display it. -->
          <xsl:if test = "$hasIntro">
            <h1 class="refname"><xsl:apply-templates select="cell[1]/steptitle"/></h1>
            <div class="subheading"><xsl:apply-templates select="cell[1]/text"/></div>
          </xsl:if>
          
          <!-- Loop over each cell -->
          <xsl:for-each select="$body-cells">
            
            <xsl:choose>
              <xsl:when test="steptitle">
                <xsl:choose>
                  
                  <xsl:when test="steptitle = 'Contents'">
                    <xsl:call-template name="contents">
                      <xsl:with-param name="body-cells" select="$body-cells"/>
                    </xsl:call-template> 
                  </xsl:when>
                  
                  <!-- <xsl:when test="steptitle = 'HiddenCalculation'"/>-->
              
                  <xsl:when test="steptitle = 'Abstract'">
                    <xsl:call-template name="abstract">
                      <xsl:with-param name="body-cells" select="$body-cells"/>
                    </xsl:call-template>
                  </xsl:when> 
                  
                  <xsl:when test="steptitle = 'See also'">
                    <h3 class="seealso"><xsl:value-of select="steptitle"/></h3>
                    <p><xsl:call-template name="createseealso">
                        <xsl:with-param name="string" select="text"/>
                    </xsl:call-template></p>
                  </xsl:when>
                  
                  <xsl:when test="(steptitle = 'Open in Editor') or (steptitle = 'View Code')"></xsl:when>
                  
                  <xsl:otherwise>
                    
                    <xsl:if  test="position()-1 > $hasContents and string-length(steptitle)>0">
                      <xsl:call-template name="backtotop"/>
                    </xsl:if>                  
                    
                    <xsl:variable name="headinglevel">
                      <xsl:choose>
                        <xsl:when test="steptitle[@style = 'document']">h1</xsl:when>
                        <xsl:when test="substring(steptitle,1,4) = 'SUB:'">h3</xsl:when>
                        <xsl:otherwise>h2</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="{$headinglevel}">
                      <xsl:apply-templates select="steptitle"/>
                      <xsl:if test="not(steptitle[@style = 'document'])">
                        <a><xsl:attribute name="name"><xsl:value-of select="position()"/></xsl:attribute><xsl:text> </xsl:text></a>
                      </xsl:if>
                    </xsl:element>
                    
                    <xsl:apply-templates select="text"/>
                    <xsl:apply-templates select="mcode-xmlized"/>
                    <xsl:apply-templates select="mcodeoutput|img"/>
                  </xsl:otherwise>
                </xsl:choose>   
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="text"/>
                <xsl:apply-templates select="mcode-xmlized"/>
                <xsl:apply-templates select="mcodeoutput|img"/>                
              </xsl:otherwise>
            </xsl:choose>        
            
            
            <xsl:if test="section">
              <xsl:choose>
                <xsl:when test="section > 0"><xsl:call-template name="backtosec"/></xsl:when>
                <xsl:otherwise><xsl:call-template name="backtotop"/></xsl:otherwise>
              </xsl:choose>           
            </xsl:if>
            
          </xsl:for-each>
          
          <!-- Contents of each cell -->
          <xsl:if  test="$hasContents > 0">
            <xsl:call-template name="backtotop"/>
          </xsl:if>
          
          
          <xsl:call-template name="footer"/>
          
        </div>
        
        
      </body>
    </html>
  </xsl:template>
  
  <!-- Header -->
  <xsl:template name="header">   
    <xsl:param name="sourceref"/>
    <div>
      <table class="nav" summary="Navigation aid" border="0" width="100%" cellpadding="0" cellspacing="0">
        <tr><td valign="baseline"><xsl:value-of select="$toolbox/fullname" disable-output-escaping="yes"/></td>
          <xsl:if test="string-length($sourceref) > 0">
            <td valign="baseline" align="right">
              <a>
                <xsl:attribute name="href">matlab:edit <xsl:value-of select="$sourceref"/></xsl:attribute>
            View Code</a></td>
        </xsl:if></tr>
      </table>
      <p style="font-size:1px;"></p>
    </div>
  </xsl:template>
    
  
  <!-- Header for UsersGuide -->
  <xsl:template name="openheader">
    <xsl:param name="sourceref"/>
    <div class="myheader">
      <table border="0" width="100%" cellpadding="10" cellspacing="0">
        <tr>
          <td valign="baseline" align="left" style="color:white"><a style="color:white">
              <xsl:attribute name="href"><xsl:text>matlab:edit </xsl:text><xsl:value-of select="$sourceref"/></xsl:attribute>
          <xsl:text>Open Matlab File in the Editor</xsl:text></a></td>
          <td valign="baseline" align="right" style="color:white">
            <a style="color:white"><xsl:attribute name="href"><xsl:value-of select="$toolbox/procuctpage"/></xsl:attribute>
          <xsl:value-of select="$toolbox/name" disable-output-escaping="yes"/></a></td>
        </tr>
      </table>  
    </div>
  </xsl:template>
  
  <!-- Footer -->
  <xsl:template name="footer">
    <p style="font-size:1px;"> </p>
    <table class="footer" border="0" width="100%" cellpadding="0" cellspacing="0">
      <tr>
        <td valign="baseline" align="right"><xsl:value-of select="$toolbox/versionname" disable-output-escaping="yes"/></td>
      </tr>
    </table>  
  </xsl:template>
  
  
  
  <xsl:template name="backtotop">  
    <p class="pagenavlink"><script language="Javascript">addTopOfPageButtons();</script><a href="#top_of_page">Back to Top</a></p>
  </xsl:template>
  
  
  <xsl:template name="backtosec">
    <p class="pagenavlink">
      <script language="Javascript">updateSectionId("<xsl:value-of select="section"/>");</script>
      <script language="Javascript">addTopOfSectionButtons();</script>
    <a><xsl:attribute name="href">#<xsl:value-of select="section"/></xsl:attribute>Back to Top of Section</a></p>
  </xsl:template>
  
  
  <!-- Contents -->
  <xsl:template name="contents">
    <xsl:param name="body-cells"/>
    
    <div><table class="content">
        <tr ><td class="header">On this page ...</td></tr>  
        
        <xsl:for-each select="$body-cells">
          <xsl:if test="./steptitle">   
            <xsl:if test="not(steptitle = 'Contents' or steptitle = 'Abstract' or steptitle = 'See also' or steptitle = 'View Code' or steptitle = 'Open in Editor')"> 
              <xsl:choose>                
                <xsl:when test="substring(./steptitle,1,4)='SUB:'">
                  <tr><td>
                      <span class="subsection"><a><xsl:attribute name="href">#<xsl:value-of select="position()"/></xsl:attribute><xsl:apply-templates select="steptitle"/></a></span>
                  </td></tr>
                </xsl:when>
                <xsl:otherwise>
                  <tr><td>
                      <a><xsl:attribute name="href">#<xsl:value-of select="position()"/></xsl:attribute><xsl:apply-templates select="steptitle"/></a>
                  </td></tr> 
                </xsl:otherwise>
              </xsl:choose>                    
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
        
    </table></div>
    </xsl:template>
    
    <xsl:template name="abstract">    
      <xsl:param name="body-cells"/>    
      <abstract><div class="intro">
          <xsl:apply-templates select="text"/>       
      </div></abstract>    
    </xsl:template>
    
    

  
    <!-- HTML Tags in text sections -->
  
 <!-- <xsl:template match="text()"> 
 
    <xsl:call-template name="transformlink"><xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
  </xsl:template>
  -->
  <xsl:template match="p">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  <xsl:template match="ul">
    <div><ul type="square"><xsl:apply-templates/></ul></div>
  </xsl:template>
  <xsl:template match="ol">
    <div><ol><xsl:apply-templates/></ol></div>
  </xsl:template>
  <xsl:template match="li">
    <li><xsl:apply-templates/></li>
  </xsl:template>
  <xsl:template match="pre">
    <xsl:choose>
      <xsl:when test="@class='error'"><pre class="error"><xsl:apply-templates/></pre></xsl:when>
      <xsl:otherwise><pre><xsl:apply-templates/></pre></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="b">
    <b><xsl:apply-templates/></b>
  </xsl:template>
  <xsl:template match="i">
    <i><xsl:apply-templates/></i>
  </xsl:template>
  <xsl:template match="tt">
    <tt><xsl:apply-templates/></tt>
  </xsl:template>
  <xsl:template match="a">
    <a><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
    <xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template match="table">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="span">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="div">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="tr">
    <tr><xsl:apply-templates/></tr>
  </xsl:template>
  <xsl:template match="td">
    <td><xsl:apply-templates/></td>
  </xsl:template>
  
  
  
  
  <!-- global replacement of links -->  
  <xsl:template match="text//text()">
    <xsl:call-template name="transformlink">
      <xsl:with-param name="string">
        <xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>  
  
  <xsl:template match="steptitle//text()">
    <xsl:call-template name="transformlink">
      <xsl:with-param name="string">
        <xsl:choose>
          <xsl:when test="substring(.,1,4)='SUB:'">
            <xsl:value-of select="substring-after(.,'SUB:')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="html">
    <xsl:call-template name="transformlink">
      <xsl:with-param name="string">
        <xsl:value-of select="@text" disable-output-escaping="yes"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- Code input and output -->
  
  <xsl:template match="mcode-xmlized">
   <pre class="codeinput"><xsl:apply-templates/><xsl:text></xsl:text></pre>
  </xsl:template>
  
  <xsl:template match="mcodeoutput">
    <xsl:choose>
      <xsl:when test="substring(.,0,7)='&lt;html&gt;'">
      <xsl:value-of select="." disable-output-escaping="yes"/></xsl:when>
      <xsl:otherwise>
        <pre class="codeoutput"><xsl:apply-templates/></pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Figure and model snapshots -->
  
  <xsl:template match="img">
    <img> <!-- vspace="5" hspace="5">-->
      <xsl:attribute name="src">
        <xsl:call-template name="backreplacelinkdot"><xsl:with-param name="string" select="@src"/></xsl:call-template>
        <!--<xsl:value-of select="@src"/>-->
      </xsl:attribute><xsl:text> </xsl:text>
    </img>
  </xsl:template>
  
  <!-- Stash original code in HTML for easy slurping later. -->
  
  <xsl:template match="originalCode">
    <xsl:variable name="xcomment">
      <xsl:call-template name="globalReplace">
        <xsl:with-param name="outputString" select="."/>
        <xsl:with-param name="target" select="'--'"/>
        <xsl:with-param name="replacement" select="'REPLACE_WITH_DASH_DASH'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:comment>
      ##### SOURCE BEGIN #####
      <xsl:value-of select="$xcomment"/>
      ##### SOURCE END #####
    </xsl:comment>
  </xsl:template>
  
  <!-- Colors for syntax-highlighted input code -->
  
  <xsl:template match="mwsh:code">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="mwsh:keywords">
    <span class="keyword"><xsl:value-of select="."/></span>
  </xsl:template>
  <xsl:template match="mwsh:strings">
    <span class="string"><xsl:value-of select="."/></span>
  </xsl:template>
  <xsl:template match="mwsh:comments">
    <span class="comment"><xsl:value-of select="."/></span>
  </xsl:template>
  <xsl:template match="mwsh:unterminated_strings">
    <span class="untermstring"><xsl:value-of select="."/></span>
  </xsl:template>
  <xsl:template match="mwsh:system_commands">
    <span class="syscmd"><xsl:value-of select="."/></span>
  </xsl:template>
  
  
  <!-- Footer information -->
  
  <xsl:template match="copyright">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="revision">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- Search and replace  -->
  <!-- From http://www.xml.com/lpt/a/2002/06/05/transforming.html -->
  
  <xsl:template name="globalReplace">
    <xsl:param name="outputString"/>
    <xsl:param name="target"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($outputString,$target)">
        <xsl:value-of select=
                      "concat(substring-before($outputString,$target),$replacement)"/>
        <xsl:call-template name="globalReplace">
          <xsl:with-param name="outputString" 
                          select="substring-after($outputString,$target)"/>
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="replacement" 
                          select="$replacement"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$outputString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
