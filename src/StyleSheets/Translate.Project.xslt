<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  >
  
  <xsl:output method="xml" indent="yes" />
  
  <xsl:param name="language"/>
<!--   <xsl:variable name="translations" select="document($language)/Names/Name"/> -->
  <xsl:variable name="translations" select="document($language)/html/body/div[@id]"/>

  <xsl:variable name="displayNameTypes" select="//Reference/Type[Property[@name='DisplayName']]"/>
  
  <xsl:template match="/">
    <xsl:comment>
      Translations = '<xsl:value-of select="count($translations)"/>
    </xsl:comment>
    <xsl:apply-templates />
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

  <xsl:template match="Item">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="translateItem">
        <xsl:with-param name="name" select="@name"/>
      </xsl:call-template>                
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="translateItem">
    <xsl:param name="name" select="@name"/>
    <xsl:variable name="type" select="@type"/>
    <xsl:variable name="translation">
      <xsl:call-template name="getTranslation">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($translation) > 0">
        <xsl:choose>
          <xsl:when test="Property[@name='DisplayName']">
            <xsl:comment>
              <xsl:value-of select="$translation"/>
            </xsl:comment>
          </xsl:when>
          <xsl:when test="count($displayNameTypes[@name=$type]) = 0">
            <xsl:comment>
              <xsl:text>
No DisplayName property : </xsl:text>
              <xsl:value-of select="$translation"/>
            </xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="Property">
              <xsl:attribute name="name">DisplayName</xsl:attribute>
              <xsl:value-of select="$translation"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!--
        <xsl:comment> 
          No translation for <xsl:value-of select="$name"/>
      </xsl:comment>
        -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getTranslation">
    <xsl:param name="name" select="@name"/>
<!--    <xsl:variable name="lookup" select="$translations[@name=$name]"/> -->
    <xsl:variable name="lookup" select="normalize-space($translations[@id=$name])"/>
    <xsl:choose>
      <xsl:when test="$name=$lookup">
        <!-- return no difference to the translation -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lookup"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
