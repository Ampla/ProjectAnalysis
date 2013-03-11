<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  >
  
  <xsl:output method="text" indent="yes" />

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>

  <xsl:variable name="pipe">|</xsl:variable>

  <xsl:key name="items-by-reference" match="Item"  use="@reference"/>
  <xsl:key name="items-by-type" match="Item"  use="@type"/>

  <xsl:template match="/Project">
    <xsl:text>ItemId</xsl:text>
    <xsl:value-of select="$pipe"/>
    <xsl:text>Fullname</xsl:text>
    <xsl:value-of select="$pipe"/>
    <xsl:text>Type</xsl:text>
    <xsl:apply-templates select="Item[@id]"/>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:value-of select="$crlf"/>
    <xsl:value-of select="@id"/>
    <xsl:value-of select="$pipe"/>
    <xsl:value-of select="@fullName"/>
    <xsl:value-of select="$pipe"/>
    <xsl:value-of select="@type"/>
    <xsl:apply-templates select="Item[@id]"/>
  </xsl:template>

</xsl:stylesheet>
