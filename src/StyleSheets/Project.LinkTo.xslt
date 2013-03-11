<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" >
  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="linkToName">linkTo</xsl:variable>
  <xsl:variable name="linkFromName">linkFrom</xsl:variable>

  <xsl:key name="link-from-by-linkid" match="linkFrom" use="link/@id"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="linksTo" select="key('link-from-by-linkid', @id)"/>
      <xsl:if test="count($linksTo) > 0">
        <xsl:element name="{$linkToName}">
          <xsl:for-each select="$linksTo">
            <xsl:element name="link">
              <xsl:attribute name="property">
                <xsl:value-of select="../@name"/>
              </xsl:attribute>
              <xsl:attribute name="id">
                <xsl:value-of select="../../@id"/>
              </xsl:attribute>
              <xsl:attribute name="fullName">
                <xsl:value-of select="../../@fullName"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="linkFrom">
    <xsl:if test="link">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy/>    
  </xsl:template>
  
</xsl:stylesheet>
