<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns="urn:schemas-microsoft-com:office:spreadsheet" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >
  <!-- 
  
  This XSL transforms Production data into an Office XML 2003 file.
  https://msdn.microsoft.com/en-us/library/aa140066(v=office.10).aspx
  -->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='Excel.Property.Tables.xslt' />
  
  <xsl:key name="items-by-full-name" match="Item" use="@fullName"/>
  <xsl:key name="type-properties-by-name" match="Type/Property[@name]" use="@name"/>
  <xsl:key name="item-properties-by-name" match="Item/Property[@name]" use="@name"/>
  <xsl:key name="types-by-name" match="Reference/Type" use="@fullName"/>

  <xsl:template match="/Project">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name='ReportingPoints'>

        <xsl:call-template name='property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Quality.Server.QualityReportingPoint']"/>
          <xsl:with-param name="index-include">1</xsl:with-param>
          <xsl:with-param name="fullname-include">1</xsl:with-param>
          <xsl:with-param name="parent-include">1</xsl:with-param>
          <xsl:with-param name="parent-level">-1</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
        </xsl:call-template>
       
      </Worksheet>

      <Worksheet ss:Name='Conditions'>
        <xsl:call-template name='item-property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Quality.Server.QualityReportingPoint']"/>
          <xsl:with-param name="select-child">Conditions</xsl:with-param>
          <xsl:with-param name="include-index">1</xsl:with-param>
          <xsl:with-param name="select-child-items">1</xsl:with-param>
        </xsl:call-template>
      </Worksheet>

      <Worksheet ss:Name='Fields'>
        <xsl:call-template name='property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Quality.Server.QualityReportingPoint']/Item[@name='Fields']/Item"/>
          <xsl:with-param name="fullname-include">0</xsl:with-param>
          <xsl:with-param name="parent-include">1</xsl:with-param>
          <xsl:with-param name="parent-header">ReportingPoint</xsl:with-param>
          <xsl:with-param name="parent-level">-2</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
        </xsl:call-template>
      </Worksheet>

      <Worksheet ss:Name='Standard Fields'>
        <xsl:variable name='fields' select="//Item[@type='Citect.Ampla.Quality.Server.QualityReportingPoint']/Item[@name='Fields']/Item"/>
        <xsl:variable name="prod-fields" select="key('items-by-full-name', $fields/@definition)"/>
        <xsl:variable name="general-fields" select="key('items-by-full-name', $prod-fields/@definition)"/>
        <xsl:variable name="items" select="$prod-fields | $general-fields"/>

        <xsl:call-template name="property-table">
          <xsl:with-param name="items" select="$items"/>
          <xsl:with-param name="parent-include">0</xsl:with-param>
          <xsl:with-param name="name-include">0</xsl:with-param>
        </xsl:call-template>
      </Worksheet>
    </Workbook>
  </xsl:template>


</xsl:stylesheet>
