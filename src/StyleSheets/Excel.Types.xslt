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

  <xsl:variable name="selected-types" select="/Project/Reference/Type"/>
  
  <xsl:key name="items-by-type" match="Item[@type]" use="@type"/>
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
          <Column ss:Width='300'/>
          <Column ss:AutoFitWidth="1" />
          <Column ss:Width='100'/>
          <Row>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Types</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Count</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:for-each select="$selected-types">
            <xsl:sort select="@fullName" data-type="text" order ="ascending"/>
            <xsl:variable name="items" select="key('items-by-type', @fullName)"/>
            <Row>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="@fullName"/>
              </xsl:call-template>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="count($items)"/>
              </xsl:call-template>
              <xsl:call-template name="hyperlink-cell">
                <xsl:with-param name="text">Details</xsl:with-param>
                <xsl:with-param name="sheet-ref" select="concat('Sheet', position())"/>
                <xsl:with-param name="cell-ref">A1</xsl:with-param>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <xsl:for-each select="$selected-types">
        <xsl:sort select="@fullName" data-type="text" order ="ascending"/>
        <xsl:variable name="type" select="@fullName"/>
        <xsl:variable name="items" select="//Item[@type=$type]"/>
        <Worksheet ss:Name="Sheet{position()}">
          <Table>
            <Column ss:Width='400'/>
            <Row>
              <xsl:call-template name="header-cell">
                <xsl:with-param name="text" select="$type"/>
                <xsl:with-param name="merge-across">2</xsl:with-param>
                <xsl:with-param name="comment" select="concat(count($items), ' items')"/>
              </xsl:call-template>
              <xsl:call-template name="hyperlink-cell">
                <xsl:with-param name="text">Back</xsl:with-param>
                <xsl:with-param name="sheet-ref">Summary</xsl:with-param>
                <xsl:with-param name="cell-ref" select="concat('C', position() + 1)"/>
              </xsl:call-template>
            </Row>
            <Row/>
            <xsl:call-template name='property-table-rows'>
              <xsl:with-param name='items' select="$items"/>
              <xsl:with-param name="index-include">1</xsl:with-param>
              <xsl:with-param name="fullname-include">1</xsl:with-param>
              <xsl:with-param name="parent-include">0</xsl:with-param>
              <xsl:with-param name="parent-level">0</xsl:with-param>
              <xsl:with-param name="name-include">1</xsl:with-param>
            </xsl:call-template>
          </Table>
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
