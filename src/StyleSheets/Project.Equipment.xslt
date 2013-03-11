<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="Project">
    <xsl:copy>
      <xsl:apply-templates select="Item"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item[@id]/Property">
    <xsl:copy>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="@name"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:comment>
      <xsl:text>Item : name = '</xsl:text>
      <xsl:value-of select="@name"/><xsl:text>' </xsl:text>
      <xsl:if test="Item">
        <xsl:text>Count = </xsl:text>
        <xsl:value-of select="count(Item[@id])"/>
        <xsl:text> Total = </xsl:text>
        <xsl:value-of select="count(descendant::Item[@id])"/>
      </xsl:if>
    </xsl:comment>
    <xsl:if test="descendant-or-self::Item[@type='Citect.Ampla.General.Server.ApplicationsFolder']">
      <xsl:element name="Item">
        <xsl:apply-templates select="@id"/>
        <xsl:apply-templates select="@name"/>
        <xsl:apply-templates select="@type"/>
        <xsl:apply-templates select="@fullName"/>
        <xsl:element name="Properties">
          <xsl:apply-templates select="Property"/>
        </xsl:element>
        <xsl:apply-templates select="Item"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>    
  </xsl:template>
  
  <xsl:template name="getItemFullName">
    <xsl:for-each select="ancestor-or-self::Item[@id]">
      <xsl:if test="position()>1">
        <xsl:text>.</xsl:text>
      </xsl:if>              
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
