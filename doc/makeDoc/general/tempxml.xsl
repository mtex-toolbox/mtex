<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into HTML.
Use the XSLT command to perform the conversion.

-->

<!DOCTYPE xsl:stylesheet [  ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd">
  <xsl:output method="xml"
              indent="no"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>
  <xsl:strip-space elements="mwsh:code"/>
  
  <xsl:template match="mscript">
    <mscript><xsl:apply-templates select="cell"/></mscript>
  </xsl:template>
  
  <xsl:template match="cell">
   <text><xsl:apply-templates select="text"/></text>
  </xsl:template>
  
  <xsl:template match="text//*">
    <xsl:choose>      
      <xsl:when test="name() = 'p' and html">
        <xsl:value-of select="." disable-output-escaping="yes"/> 
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
