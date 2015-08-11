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
            <xsl:call-template name='header-row-2-columns'>
              <xsl:with-param name='column-1'>Full Name</xsl:with-param>
              <xsl:with-param name='column-2'>Data Type</xsl:with-param>
            </xsl:call-template>
            <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
            <xsl:for-each select="$items">
              <xsl:sort select="@fullName"/>
              <xsl:call-template name="data-row-2-columns">
                <xsl:with-param name="column-1" select="@fullName"/>
                <xsl:with-param name="column-2">
                  <xsl:call-template name="get-Property">
                    <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
                    <xsl:with-param name="default">Single</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:for-each>
          </Table>
        </Worksheet>
      </xsl:for-each>

    </Workbook>
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

</xsl:stylesheet>
