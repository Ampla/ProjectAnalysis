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

  <xsl:include href='Excel.Common.xslt' />

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
        <Worksheet ss:Name="{@name}">
          <Table>
            <xsl:apply-templates select="." mode="page-header"/>
            <xsl:apply-templates select="." mode="page-data"/>
          </Table>
        </Worksheet>
      </xsl:for-each>

    </Workbook>
  </xsl:template>

  <xsl:template match="Type" mode="page-header">
    <xsl:call-template name='header-row-2-columns'>
      <xsl:with-param name='column-1'>Full Name</xsl:with-param>
      <xsl:with-param name='column-2'>Data Type</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='Type' mode="page-data">
    <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
    <xsl:apply-templates select="$items" mode="row">
      <xsl:sort select="@fullName"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Item" mode="row">
    <xsl:call-template name="data-row-2-columns">
      <xsl:with-param name="column-1" select="@fullName"/>
      <xsl:with-param name="column-2">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
          <xsl:with-param name="default">Single</xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Type[@name='OpcHdaVariable']" mode="page-header">
    <xsl:call-template name='header-row-3-columns'>
      <xsl:with-param name='column-1'>Full Name</xsl:with-param>
      <xsl:with-param name='column-2'>Data Type</xsl:with-param>
      <xsl:with-param name='column-3'>OpcItemId</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Connectors.OpcHdaConnector.OpcHdaVariable']" mode="row">
    <xsl:call-template name="data-row-3-columns">
      <xsl:with-param name="column-1" select="@fullName"/>
      <xsl:with-param name="column-2">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
          <xsl:with-param name="default">Single</xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="column-3">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">OpcItemId</xsl:with-param>
          <xsl:with-param name="default"></xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Type[@name='CalculatedVariable' or @name='AccumulatorVariable']" mode="page-header">
    <xsl:call-template name='header-row-3-columns'>
      <xsl:with-param name='column-1'>Full Name</xsl:with-param>
      <xsl:with-param name='column-2'>Data Type</xsl:with-param>
      <xsl:with-param name='column-3'>HistoricalExpression</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.StandardItems.CalculatedVariable' or @type='Citect.Ampla.General.Server.AccumulatorVariable']" mode="row">
    <xsl:variable name="sample-type-code">
      <xsl:call-template name="get-Property">
        <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
        <xsl:with-param name="default">Single</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="expression-text" select="Property[@name='HistoricalExpression']/property-value/HistoricalExpressionConfig/ExpressionConfig/@text"/>
    <xsl:call-template name="data-row-3-columns">
      <xsl:with-param name="column-1" select="@fullName"/>
      <xsl:with-param name="column-2" select="$sample-type-code"/>
      <xsl:with-param name="column-3" select="$expression-text"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Type[@name='StoredVariable']" mode="page-header">
    <xsl:call-template name='header-row-4-columns'>
      <xsl:with-param name='column-1'>Full Name</xsl:with-param>
      <xsl:with-param name='column-2'>Data Type</xsl:with-param>
      <xsl:with-param name='column-3'>RecallSample</xsl:with-param>
      <xsl:with-param name='column-4'>RecallSample.Value</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.StandardItems.StoredVariable']" mode="row">
    <xsl:variable name="sample-type-code">
      <xsl:call-template name="get-Property">
        <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
        <xsl:with-param name="default">Single</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="recall-sample">
      <xsl:call-template name="get-Property">
        <xsl:with-param name="property">RecallSample</xsl:with-param>
        <xsl:with-param name="default">Single</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="recall-sample-value">
      <!-- <Property name="RecallSample">Double|635741974977460392|456|193</Property> -->
      <xsl:call-template name="nth-string">
        <xsl:with-param name="value" select="$recall-sample"/>
        <xsl:with-param name="delim">|</xsl:with-param>
        <xsl:with-param name="nth" select="3"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="data-row-4-columns">
      <xsl:with-param name="column-1" select="@fullName"/>
      <xsl:with-param name="column-2" select="$sample-type-code"/>
      <xsl:with-param name="column-3" select="$recall-sample"/>
      <xsl:with-param name="column-4" select="$recall-sample-value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="get-Property">
    <xsl:param name="property"></xsl:param>
    <xsl:param name="default"/>
    <xsl:choose>
      <xsl:when test="Property[@name=$property]">
        <xsl:value-of select="Property[@name=$property]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
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
