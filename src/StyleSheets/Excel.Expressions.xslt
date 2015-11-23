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

  <xsl:key name="items-by-id" match="Item[@id]" use="@id"/>
  <xsl:key name="item-link-by-position" match="HistoricalExpressionConfig/ExpressionConfig/ItemLinkCollection" use="count(ItemLink)"/>

  <xsl:variable name="source-items" select="//Item[Stream/PropertyLink]"/>
  <xsl:variable name="destination-items" select="key('items-by-id', $source-items/Stream/PropertyLink/@id)"/>

  <xsl:template match="/">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name='Expressions'>
        <Table>
          <xsl:call-template name='expression-header'/>
          <xsl:for-each select='$destination-items'>
            <xsl:variable name='item' select='.'/>
            <xsl:comment>
              <xsl:value-of select='$item/@fullName'/>: <xsl:value-of select='count($item/Property)'/>
            </xsl:comment>
            <xsl:for-each select='$item/Property[property-value/HistoricalExpressionConfig]'>
              <xsl:variable name='property' select='.'/>
              <xsl:call-template name='expression-row'>
                <xsl:with-param name='item' select='$item'/>
                <xsl:with-param name='property' select='$property'/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Streams'>
        <Table>
          <xsl:call-template name='stream-header'/>
          <xsl:for-each select='$destination-items'>
            <xsl:variable name='item' select='.'/>
            <xsl:comment>
              <xsl:value-of select='$item/@fullName'/>: <xsl:value-of select='count($item/Property)'/>
            </xsl:comment>
            <xsl:for-each select='$item/Property[property-value/HistoricalExpressionConfig]'>
              <xsl:variable name='property' select='.'/>
              <xsl:call-template name='stream-row'>
                <xsl:with-param name='item' select='$item'/>
                <xsl:with-param name='property' select='$property'/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>
    </Workbook>
  </xsl:template>

  <xsl:template name='expression-header'>
    <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Parent</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Name</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Type</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Property</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Expression.Text</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Expression.Format</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>#ItemReference0#</xsl:with-param>
      </xsl:call-template>
      <xsl:if test="key('item-link-by-position', 1)">
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 2)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference1#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 3)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference2#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 4)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference3#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 5)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference4#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 6)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference5#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 7)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference6#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="key('item-link-by-position', 8)">
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>#ItemReference7#</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </Row>
  </xsl:template>

  <xsl:template name='expression-row'>
    <xsl:param name='item'/>
    <xsl:param name='property'/>
    <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$item/../@fullName'/>
      </xsl:call-template>
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$item/@name'/>
      </xsl:call-template>
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$item/@type'/>
      </xsl:call-template>
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$property/@name'/>
      </xsl:call-template>
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@text'/>
      </xsl:call-template>
      <xsl:call-template name='text-cell'>
        <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@format'/>
      </xsl:call-template>
      <xsl:for-each select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/ItemLinkCollection/ItemLink'>
        <xsl:variable name='link' select="concat('#ItemReference', position()-1, '#')"/>
        <xsl:call-template name='text-cell'>
          <xsl:with-param name='text' select='@absolutePath'/>
        </xsl:call-template>
      </xsl:for-each>
    </Row>
  </xsl:template>

  <xsl:template name='stream-header'>
    <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Parent</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Name</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Type</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Property</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Expression.Text</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Expression.Format</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Expression.DataType</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Index</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>ItemReference</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Stream</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name='header-cell'>
        <xsl:with-param name='text'>Stream.DataType</xsl:with-param>
      </xsl:call-template>
    </Row>
  </xsl:template>

  <xsl:template name='stream-row'>
    <xsl:param name='item'/>
    <xsl:param name='property'/>
    <xsl:variable name='dependencies' select='$property/property-value/HistoricalExpressionConfig/DependencyCollection/Dependency'/>
    <xsl:choose>
      <xsl:when test='$dependencies'>
        <xsl:for-each select='$dependencies'>
          <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$item/../@fullName'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$item/@name'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$item/@type'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$property/@name'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@text'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@format'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text'>
                <xsl:apply-templates select='$item' mode='data-type'/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='position()'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='ItemPropertyLink/ItemLink/@absolutePath'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='ItemPropertyLink/@propertyName'/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text'>
                <xsl:apply-templates select="key('items-by-id', ItemPropertyLink/ItemLink/@targetID)" mode='data-type'/>
              </xsl:with-param>
            </xsl:call-template>
          </Row>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$item/../@fullName'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$item/@name'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$item/@type'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$property/@name'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@text'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text' select='$property/property-value/HistoricalExpressionConfig/ExpressionConfig/@format'/>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text'>-</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text'>-</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='text-cell'>
            <xsl:with-param name='text'>-</xsl:with-param>
          </xsl:call-template>
        </Row>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='Item' mode='data-type'>
    <xsl:choose>
      <xsl:when test="Property[@name='SampleTypeCode']">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
          <xsl:with-param name="default">Single</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains(@type,'Variable')">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
          <xsl:with-param name="default">Single</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@type='Citect.Ampla.General.Server.AccumulatorVariable'">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">SampleTypeCode</xsl:with-param>
          <xsl:with-param name="default">Single</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@type='Citect.Ampla.Downtime.Server.VirtualDowntime'">Double</xsl:when>
      <xsl:when test="contains(@type, 'FieldDefinition')">
        <xsl:call-template name="get-Property">
          <xsl:with-param name="property">DataType</xsl:with-param>
          <xsl:with-param name="default">Integer</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@type='Citect.Ampla.General.Server.ExpressionCaptureCondition'">Boolean</xsl:when>
      <xsl:when test="@type='Citect.Ampla.Downtime.Server.DowntimeExpressionCaptureCondition'">Boolean</xsl:when>
      <xsl:when test="count(Stream)=1">
        <xsl:value-of select="Stream/@type"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
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
