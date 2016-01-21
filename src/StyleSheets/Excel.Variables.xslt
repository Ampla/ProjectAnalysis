<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >
  
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='Excel.Property.Tables.xslt' />

  <xsl:variable name="variable-types" select="/Project/Reference/Type[contains(@name, 'Variable')]"/>

  <xsl:key name="all-items-by-type" match="Item[@type]" use="@type"/>
  <xsl:key name="all-items-by-id" match="Item[@type]" use="@id"/>

  <xsl:template match="/Project">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name='Summary'>
        <Table>
          <xsl:call-template name='header-row-2-columns'>
            <xsl:with-param name='column-1'>Variable Type</xsl:with-param>
            <xsl:with-param name='column-2'>Count</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select="$variable-types">
            <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
            <xsl:call-template name="data-row-2-columns">
              <xsl:with-param name="column-1" select="@name" />
              <xsl:with-param name="column-2" select="count($items)"/>
            </xsl:call-template>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <xsl:for-each select="$variable-types">
        <xsl:variable name="type" select="@fullName"/>
        <Worksheet ss:Name="{@name}">
          <xsl:call-template name='property-table'>
            <xsl:with-param name='items' select="//Item[@type=$type]"/>
            <xsl:with-param name="index-include">1</xsl:with-param>
            <xsl:with-param name="fullname-include">1</xsl:with-param>
            <xsl:with-param name="parent-include">0</xsl:with-param>
            <xsl:with-param name="parent-level">0</xsl:with-param>
            <xsl:with-param name="name-include">1</xsl:with-param>
          </xsl:call-template>
        </Worksheet>
      </xsl:for-each>

    </Workbook>
  </xsl:template>

  <xsl:template match="Property[@name='RecallSample']" mode="cell">
    <xsl:call-template name="nth-string">
      <xsl:with-param name="value" select="."/>
      <xsl:with-param name="delim">|</xsl:with-param>
      <xsl:with-param name="nth" select="3"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Property[@name='RecallSample']" mode="comment">
    <xsl:value-of select="."/>
  </xsl:template>
  
  
  <xsl:template name="nth-string">
    <xsl:param name="value"></xsl:param>
    <xsl:param name="delim">|</xsl:param>
    <xsl:param name="nth">0</xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($value) = 0" />
      <xsl:when test="$nth &lt; 1">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:when test="$nth = 1">
        <xsl:choose>
          <xsl:when test="contains($value, $delim)">
            <xsl:value-of select="substring-before($value, $delim)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$nth > 1">
        <xsl:choose>
          <xsl:when test="contains($value, $delim)">
            <xsl:call-template name="nth-string">
              <xsl:with-param name="value" select="substring-after($value, $delim)"/>
              <xsl:with-param name="delim" select="$delim"/>
              <xsl:with-param name="nth" select="$nth - 1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
