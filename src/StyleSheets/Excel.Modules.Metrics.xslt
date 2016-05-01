<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns="urn:schemas-microsoft-com:office:spreadsheet" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" 
                xmlns:html="http://www.w3.org/TR/REC-html40"
                >
  <!-- 
    
  This XSL transforms Metrics configuration into an Office XML 2003 file.
  https://msdn.microsoft.com/en-us/library/aa140066(v=office.10).aspx
  -->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='Excel.Property.Tables.xslt' />
  
  <xsl:key name="items-by-full-name" match="Item" use="@fullName"/>
  <xsl:key name="type-properties-by-name" match="Type/Property[@name]" use="@name"/>
  <xsl:key name="item-properties-by-name" match="Item/Property[@name]" use="@name"/>
  <xsl:key name="types-by-name" match="Reference/Type" use="@fullName"/>

  <xsl:variable name="resolver-type-name">Citect.Ampla.Metrics.Server.Resolvers.Resolver</xsl:variable>
  <xsl:variable name="reportingpoint-type-name">Citect.Ampla.Metrics.Server.MetricsReportingPoint</xsl:variable>
  <xsl:variable name="kpi-type-name">Citect.Ampla.Metrics.Server.KPI</xsl:variable>

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
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']"/>
          <xsl:with-param name="index-include">1</xsl:with-param>
          <xsl:with-param name="fullname-include">1</xsl:with-param>
          <xsl:with-param name="parent-include">1</xsl:with-param>
          <xsl:with-param name="parent-level">-1</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
        </xsl:call-template>
       
      </Worksheet>

      <Worksheet ss:Name='Conditions'>
        <xsl:call-template name='item-property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']"/>
          <xsl:with-param name="select-child">Conditions</xsl:with-param>
          <xsl:with-param name="include-index">1</xsl:with-param>
          <xsl:with-param name="select-child-items">1</xsl:with-param>
        </xsl:call-template>
      </Worksheet>

      <Worksheet ss:Name='Formulas'>
        <xsl:call-template name='property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Metrics.Server.Formula']"/>
          <xsl:with-param name="index-include">1</xsl:with-param>
          <xsl:with-param name="fullname-include">1</xsl:with-param>
          <xsl:with-param name="parent-include">0</xsl:with-param>
          <xsl:with-param name="parent-level">0</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
        </xsl:call-template>
      </Worksheet>
      <Worksheet ss:Name='KPIs'>
        <xsl:call-template name='property-table'>
          <xsl:with-param name='items' select="//Item[@type=$kpi-type-name]"/>
          <xsl:with-param name="fullname-include">0</xsl:with-param>
          <xsl:with-param name="parent-header">ReportingPoint</xsl:with-param>
          <xsl:with-param name="parent-include">1</xsl:with-param>
          <xsl:with-param name="parent-level">-2</xsl:with-param>
          <xsl:with-param name="include-index">1</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
          <xsl:with-param name="select-child-items">0</xsl:with-param>
        </xsl:call-template>
      </Worksheet>
      <Worksheet ss:Name="Resolvers">
        <Table>
          <Column ss:Width='400'/>
          <Column ss:AutoFitWidth="1" />
          <Column ss:Width='100'/>
          <xsl:variable name="reporting-points" select="//Item[@type=$reportingpoint-type-name]"/>
          <Row>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">ReportingPoint</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Index</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">KPI</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Units</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Formula</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Formula.Expression</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Resolver</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">ResolverName</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Action</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">Module</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">ResolverOperation</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">SourceFieldName</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">SourceLocations</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">WhereCondition</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">KpiItem</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">ResolverItem</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">VariableItem</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">CalendarItem</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text">ConstantItem</xsl:with-param>
            </xsl:call-template>
			<xsl:call-template name="header-cell">
              <xsl:with-param name="text">ErrorValue</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:variable name="kpi-type" select="key('types-by-name', $kpi-type-name)"/>
          <xsl:variable name="resolver-type" select="key('types-by-name', $resolver-type-name)"/>
          <xsl:for-each select="$reporting-points">
            <xsl:variable name="point" select="."/>
            <xsl:variable name="point-position" select="position()"/>
            <!-- <xsl:comment>
              <xsl:value-of select="position()"/> Reporting Point: <xsl:value-of select="$point/@fullName"/>
            </xsl:comment>
            -->
            <xsl:variable name="kpis" select="$point/Item[@name='Fields']/Item[@type=$kpi-type-name]"/>
            <xsl:variable name="kpi-resolvers" select="$kpis/Item[@type=$resolver-type-name]"/>
            <xsl:variable name="kpi-no-resolver" select="$kpis[not(Item[@type=$resolver-type-name])]"/>
            <xsl:variable name="rows" select="$kpi-no-resolver | $kpi-resolvers"/>
            <xsl:for-each select="$kpis">
              <xsl:variable name="kpi" select="."/>
              <xsl:variable name="kpi-position" select="position()"/>
              <xsl:variable name="resolvers" select="$kpi/Item[@type=$resolver-type-name]"/>
              <!-- <xsl:comment>
                <xsl:value-of select="position()"/> KPI: <xsl:value-of select="$kpi/@name"/>
              </xsl:comment>
              -->
              <xsl:choose>
                <xsl:when test="$resolvers">

                  <xsl:for-each select="$resolvers">
                    <xsl:variable name="resolver" select="."/>
                    <xsl:variable name="resolver-position" select="position()"/>
                    <!-- <xsl:comment>
                  <xsl:value-of select="position()"/> Resolver: <xsl:value-of select="$resolver/@name"/>
                </xsl:comment> -->
                    <Row>
                      <xsl:call-template name="text-cell">
                        <xsl:with-param name="text" select="$point/@fullName"/>
                        <xsl:with-param name="style">
                          <xsl:choose>
                            <xsl:when test="($kpi-position = 1) and ($resolver-position = 1)">value</xsl:when>
                            <xsl:otherwise>default-value</xsl:otherwise>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                      <xsl:call-template name="number-cell">
                        <xsl:with-param name="value" select="concat( $point-position, '.', format-number($kpi-position, '00') )"/>
                        <xsl:with-param name="style">
                          <xsl:choose>
                            <xsl:when test="$resolver-position = 1">value</xsl:when>
                            <xsl:otherwise>default-value</xsl:otherwise>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                      <xsl:call-template name="kpi-cells">
                        <xsl:with-param name="kpi" select="$kpi"/>
                        <xsl:with-param name="type" select="$kpi-type"/>
                        <xsl:with-param name="highlight" select="$resolver-position = 1"/>
                      </xsl:call-template>
                      <xsl:call-template name="resolver-cells">
                        <xsl:with-param name="resolver" select="$resolver"/>
                        <xsl:with-param name="type" select="$resolver-type"/>
                      </xsl:call-template>
                    </Row>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <!-- no resolvers -->
                  <Row>
                    <xsl:call-template name="text-cell">
                      <xsl:with-param name="text" select="$point/@fullName"/>
                      <xsl:with-param name="style">
                        <xsl:choose>
                          <xsl:when test="($kpi-position = 1)">value</xsl:when>
                          <xsl:otherwise>default-value</xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="number-cell">
                      <xsl:with-param name="value" select="concat( $point-position, '.', format-number($kpi-position, '00') )"/>
                      <xsl:with-param name="style">value</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="kpi-cells">
                      <xsl:with-param name="kpi" select="$kpi"/>
                      <xsl:with-param name="type" select="$kpi-type"/>
                      <xsl:with-param name="highlight" select="1 = 1"/>
                    </xsl:call-template>
                    <xsl:call-template name="resolver-cells"/>
                  </Row>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>


          </xsl:for-each>
        </Table>
      </Worksheet>
      <!--
      <Worksheet ss:Name='Resolver 2'>
        <xsl:call-template name='property-table'>
          <xsl:with-param name='items' select="//Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
          <xsl:with-param name="index-include">1</xsl:with-param>
          <xsl:with-param name="fullname-include">1</xsl:with-param>
          <xsl:with-param name="parent-include">1</xsl:with-param>
          <xsl:with-param name="parent-level">-2</xsl:with-param>
          <xsl:with-param name="name-include">1</xsl:with-param>
        </xsl:call-template>
      </Worksheet>

      <Worksheet ss:Name='Standard Fields'>
        <xsl:variable name='fields' select="//Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']/Item[@name='Fields']/Item"/>
        <xsl:variable name="metrics-fields" select="key('items-by-full-name', $fields/@definition)"/>
        <xsl:variable name="general-fields" select="key('items-by-full-name', $metrics-fields/@definition)"/>
        <xsl:variable name="items" select="$metrics-fields | $general-fields"/>

        <xsl:call-template name="property-table">
          <xsl:with-param name="items" select="$items/descendant-or-self::Item"/>
          <xsl:with-param name="parent-include">0</xsl:with-param>
          <xsl:with-param name="name-include">0</xsl:with-param>
        </xsl:call-template>
      </Worksheet>
      -->
    </Workbook>
  </xsl:template>

  <xsl:template name="kpi-cells">
    <xsl:param name="kpi"/>
    <xsl:param name="type"/>
    <xsl:param name="highlight">0</xsl:param>
    <xsl:call-template name="merge-cell">
      <xsl:with-param name="text" select="$kpi/@name"/>
<!--      <xsl:with-param name="cell-index">2</xsl:with-param> --> 
      <xsl:with-param name="style">
        <xsl:choose>
          <xsl:when test="$highlight">value</xsl:when>
          <xsl:otherwise>default-value</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="property-cell">
      <xsl:with-param name="item" select="$kpi"/>
      <xsl:with-param name="property">Units</xsl:with-param>
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="style">
        <xsl:choose>
          <xsl:when test="$highlight">value</xsl:when>
          <xsl:otherwise>default-value</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="property-cell">
      <xsl:with-param name="item" select="$kpi"/>
      <xsl:with-param name="property">Formula</xsl:with-param>
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="style">
        <xsl:choose>
          <xsl:when test="$highlight">value</xsl:when>
          <xsl:otherwise>default-value</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="formula" select="key('items-by-full-name', $kpi/Property[@name='Formula'])"/>
    <xsl:call-template name="property-cell">
      <xsl:with-param name="item" select="$formula"/>
      <xsl:with-param name="property">Expression</xsl:with-param>
      <xsl:with-param name="type" select="$type"/>
      <xsl:with-param name="style">
        <xsl:choose>
          <xsl:when test="$highlight">value</xsl:when>
          <xsl:otherwise>default-value</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="resolver-cells">
    <xsl:param name="resolver"/>
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$resolver">
        <xsl:call-template name="text-cell">
          <xsl:with-param name="text" select="$resolver/@name"/>
          <xsl:with-param name="style">value</xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="resolver-name" select="$resolver/Property[@name='ResolverName']"/>
        <xsl:call-template name="text-cell">
          <xsl:with-param name="text" select="$resolver-name"/>
          <xsl:with-param name="style">
            <xsl:choose>
              <xsl:when test="$resolver/@name = $resolver-name">default-value</xsl:when>
              <xsl:otherwise>value</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="property-cell">
          <xsl:with-param name="item" select="$resolver"/>
          <xsl:with-param name="property">Action</xsl:with-param>
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
        <xsl:variable name="action" select="$resolver/Property[@name='Action']"/>
        <xsl:choose>
          <xsl:when test="$action = 'Module'">
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">Module</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ResolverOperation</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">SourceFieldName</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">SourceLocations</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">WhereCondition</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$action = 'KPI'">
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">KpiItem</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
		  </xsl:when>
          <xsl:when test="$action = 'Resolver'">
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ResolverItem</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
		  </xsl:when>
          <xsl:when test="$action = 'Variable'">
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">VariableItem</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
		  </xsl:when>
          <xsl:when test="$action = 'Calendar'">
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">CalendarItem</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="no-value"/>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
		  </xsl:when>
          <xsl:when test="$action = 'Constant'">
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="no-value"/>
            <xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ConstantItem</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
			<xsl:call-template name="property-cell">
              <xsl:with-param name="item" select="$resolver"/>
              <xsl:with-param name="property">ErrorValue</xsl:with-param>
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
		  </xsl:when>
 	    </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
        <xsl:call-template name="no-value"/>
      </xsl:otherwise>
      
    </xsl:choose>
  </xsl:template>
  
  <!--

  <xsl:template match="Property[@name='KpiItem']" mode="cell">
    <xsl:variable name="item-fullname" select="property-value"/>
    <xsl:value-of select="concat('(', $item-fullname, ')')"/>
    <xsl:call-template name="relative-item">
      <xsl:with-param name="current" select="../.."/>
      <xsl:with-param name="item" select="key('items-by-full-name', $item-fullname)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Property[@name='ResolverItem']" mode="cell">
    <xsl:variable name="item-fullname" select="property-value"/>
    <xsl:value-of select="concat('(', $item-fullname, ')')"/>
    <xsl:call-template name="relative-item">
      <xsl:with-param name="current" select=".."/>
      <xsl:with-param name="item" select="key('items-by-full-name', $item-fullname)"/>
    </xsl:call-template>
  </xsl:template>
  -->


  <xsl:template match="Property[@name='CalculationType']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='Action']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='Formula']" mode="cell">
    <xsl:variable name="value" select="."/>
    <xsl:choose>
      <xsl:when test="starts-with($value, 'System Configuration.Metrics.Formulas.')">
        <xsl:value-of select="substring-after($value, 'System Configuration.Metrics.Formulas.')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
