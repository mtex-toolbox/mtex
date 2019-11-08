<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  


  
<xsl:template name="createseealso">
  <xsl:param name="string"/>
  <xsl:choose>
    <xsl:when test="contains($string,' ')">
      <xsl:call-template name="makeseealsolink">
        <xsl:with-param name="ref" select="substring-before($string,' ')"/>
      </xsl:call-template><xsl:text>, </xsl:text>        
      <xsl:call-template name="createseealso">
        <xsl:with-param name="string" select="substring-after($string,' ')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="makeseealsolink">
        <xsl:with-param name="ref" select="$string"/>
      </xsl:call-template>     
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<xsl:template name="hreftransform">
  <xsl:param name="href"/>
  <xsl:param name="text"/>  
  <!--  <xsl:text>\hyperref[</xsl:text>
 <xsl:call-template name="backreplace"><xsl:with-param name="string">
      <xsl:choose>
        <xsl:when test="contains($href,'.html')">
          <xsl:value-of select="substring-before($href,'.html')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$href"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:with-param></xsl:call-template>
  <xsl:text>]{</xsl:text><xsl:value-of select="$text"/><xsl:text>}</xsl:text>-->
  <!--  <xsl:value-of select="$href"/>-->
  
  <!--<xsl:text>&lt;a href="</xsl:text><xsl:value-of select="$href"/><xsl:text>"&gt;</xsl:text><xsl:value-of select="$text"/><xsl:text>&lt;/a&gt;</xsl:text>
-->
  <a><xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
  <xsl:value-of select="$text"/></a>
</xsl:template>


<xsl:template name="makeseealsolink">
  <xsl:param name="ref"/>
  
  <xsl:variable name="refpage">
    <xsl:choose>
      <xsl:when test="contains($ref,'/')">
        <xsl:value-of select="concat(substring-before($ref,'/'),'.',substring-after($ref,'/'))"/>
      </xsl:when>    
      <xsl:otherwise>
        <xsl:value-of select="$ref"/>
      </xsl:otherwise>
    </xsl:choose><xsl:text>.html</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="refname">
    <!--<xsl:choose>
      <xsl:when test="contains($ref,'_index')">
        <xsl:value-of select="substring-before($ref,'_index')"/>
      </xsl:when>    
      <xsl:otherwise>-->
    <!--<xsl:call-template name="replace">-->
    <xsl:value-of select="$ref"/>
    <!-- </xsl:call-template>-->
    <!--      </xsl:otherwise>
    </xsl:choose>-->
  </xsl:variable>
  
  <!-- <xsl:value-of select="$ref"/>-->
  <xsl:call-template name="hreftransform">
    <xsl:with-param name="href" select="$refpage"/>
    <xsl:with-param name="text" select="$refname"/>  
  </xsl:call-template>
</xsl:template>


<xsl:template name="backreplace">
  <xsl:param name="string"/>  
  <xsl:choose>
    <xsl:when test="contains($string, '\')">
      <xsl:value-of select="substring-before($string, '\')"/>
      <xsl:call-template name="backreplace"><xsl:with-param name="string" select="substring-after($string, '\')"/></xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="backreplacelink">
  <xsl:param name="string"/>
  
  
  <xsl:choose>
    <xsl:when test="contains($string, 'script_')">
      <xsl:call-template name="backreplacelink"><xsl:with-param name="string" select="substring-after($string, 'script_')"/></xsl:call-template>
    </xsl:when>    
    <xsl:when test="contains($string, '__')">
      <xsl:value-of select="substring-before($string, '__')"/><xsl:text>/</xsl:text>
      <xsl:call-template name="backreplacelink">        
        <xsl:with-param name="string" select="substring-after($string, '__')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="backreplacelinkdot">
  <xsl:param name="string"/>
  
  
  <xsl:choose>
    <xsl:when test="contains($string, 'script_')">
      <xsl:call-template name="backreplacelinkdot"><xsl:with-param name="string" select="substring-after($string, 'script_')"/></xsl:call-template>
    </xsl:when>    
    <xsl:when test="contains($string, '__')">
      <xsl:value-of select="substring-before($string, '__')"/><xsl:text>.</xsl:text>
      <xsl:call-template name="backreplacelinkdot">       
        <xsl:with-param name="string" select="substring-after($string, '__')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="labelreplace">
  <xsl:param name="string"/>
  <xsl:choose>
    <xsl:when test="contains($string, '.')">
      <xsl:value-of select="substring-before($string, '.')"/><xsl:text>_</xsl:text>
      <xsl:call-template name="backreplace"><xsl:with-param name="string" select="substring-after($string, '.')"/></xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="makelink">
  <xsl:param name="string"/>  
  <!--<xsl:text>\emph{</xsl:text><xsl:value-of select="substring-after($string,',')"/><xsl:text>}</xsl:text>-->
  <xsl:call-template name="hreftransform">
    <xsl:with-param name="href" select="substring-before($string,',')"/>
    <xsl:with-param name="text" select="substring-after($string,',')"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="transformlink">
  <xsl:param name="string"/> 
  
  <xsl:choose>
    <xsl:when test="contains($string,'[[')">
      <xsl:value-of select="substring-before($string,'[[')"  disable-output-escaping="yes"/>
      <xsl:call-template name="makelink">
        <xsl:with-param name="string" select="substring-before(substring-after($string,'[['),']]')"/>
      </xsl:call-template>
      <xsl:call-template name="transformlink"><xsl:with-param name="string" select="substring-after($string,']]')"/></xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"  disable-output-escaping="yes"/>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>


</xsl:stylesheet>