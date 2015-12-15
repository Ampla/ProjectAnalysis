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

  <xsl:include href='Excel.Common.xslt' />

  <xsl:variable name='quote'>'</xsl:variable>

  <xsl:variable name='overridden'>.Overridden</xsl:variable>
  
  <xsl:key name="items-by-full-name" match="Item" use="@fullName"/>
  <xsl:key name="type-properties-by-name" match="Type/Property[@name]" use="@name"/>
  <xsl:key name="item-properties-by-name" match="Item/Property[@name]" use="@name"/>
  <xsl:key name="types-by-name" match="Reference/Type" use="@fullName"/>

  <xsl:variable name="unique-properties" select="//Type/Property[generate-id() = generate-id(key('type-properties-by-name', @name)[1])]"/>

  <xsl:template name="item-property-table">
    <xsl:param name='items' select="Item"/>
    <xsl:param name="fullname-header">FullName</xsl:param>
    <xsl:param name="select-child"></xsl:param>
    <xsl:param name="definition-include">1</xsl:param>
    <xsl:param name="index-include">1</xsl:param>
    <xsl:param name="type-include">1</xsl:param>
    <xsl:param name="select-child-items">1</xsl:param>

    <xsl:variable name="all-items" select="$items/Item[@name=$select-child]/descendant::Item"/>
    <xsl:variable name="definitions" select="$all-items[@definition]"/>
    <xsl:variable name="types" select="key('types-by-name', $all-items/@type)"/>
    <xsl:variable name="properties" select="$unique-properties[@name=$types/Property/@name]"/>
    
    <Table>
      <Column ss:Width='400'/>
      <Column ss:AutoFitWidth="1" />
      <Column ss:Width='100'/>
      <Row>
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text' select='$fullname-header'/>
        </xsl:call-template>
        <xsl:if test='$index-include=1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Index</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name='header-cell'>
          <xsl:with-param name='text'>Name</xsl:with-param>
        </xsl:call-template>
        <xsl:if test="$definition-include = 1 and count($definitions) > 0">
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Definition</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:for-each select='$properties'>
          <xsl:sort select="@count" data-type="number" order="descending"/>
          <xsl:sort select="@name"/>
          <xsl:if test="not(contains(@name, $overridden))">
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text' select='@name'/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test='$type-include = 1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Type</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </Row>
      <xsl:for-each select='$items'>
        <xsl:sort select="../@fullName" />
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number" />
        <xsl:sort select="@name" />
        <xsl:variable name="item" select="."/>
        <xsl:variable name="children" select="$item/Item[@name=$select-child]"/>
        <xsl:choose>
          <xsl:when test="$children/descendant::Item">
            <xsl:variable name="relative-prefix" select="concat($item/@fullName, '.', $select-child, '.')"/>
            <xsl:for-each select="$children/descendant::Item">
              <xsl:variable name="child" select="."/>
              <xsl:variable name="type" select="key('types-by-name', $child/@type)"/>
              <Row>
                <xsl:call-template name="text-cell">
                  <xsl:with-param name="text" select="$item/@fullName"/>
                </xsl:call-template>
                <xsl:if test='$index-include=1'>
                  <xsl:call-template name="number-cell">
                    <xsl:with-param name="value" select="position()"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="text-cell">
                  <xsl:with-param name="text" select="substring-after($child/@fullName, $relative-prefix)"/>
                </xsl:call-template>
                <xsl:if test="$definition-include = 1 and count($definitions) > 0">
                  <xsl:call-template name="text-cell">
                    <xsl:with-param name="text" select="$child/@definition"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:for-each select="$properties">
                  <xsl:sort select="@count" data-type="number" order="descending"/>
                  <xsl:sort select="@name"/>
                  <xsl:if test="not(contains(@name, $overridden))">
                    <xsl:call-template name="property-cell">
                      <xsl:with-param name="item" select="$child"/>
                      <xsl:with-param name="property" select="@name"/>
                      <xsl:with-param name="type" select="$type" />
                    </xsl:call-template>
                  </xsl:if>
                </xsl:for-each>
                <xsl:if test='$type-include = 1'>
                  <xsl:call-template name="text-cell">
                    <xsl:with-param name="text" select="$child/@type"/>
                  </xsl:call-template>
                </xsl:if>
              </Row>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <Row>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="$item/@fullName"/>
              </xsl:call-template>
              <xsl:if test="$index-include = 1">
                <xsl:call-template name="no-value"/>
              </xsl:if>
              <xsl:call-template name="no-value"/>
              <xsl:for-each select="$properties">
                <xsl:sort select="@count" data-type="number" order="descending"/>
                <xsl:sort select="@name"/>
                <xsl:if test="not(contains(@name, $overridden))">
                  <xsl:call-template name="no-value"/>
                </xsl:if>
              </xsl:for-each>
              <xsl:if test='$type-include = 1'>
                <xsl:call-template name="no-value"/>
              </xsl:if>
            </Row>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </Table>
    
  </xsl:template>
  
  <xsl:template name="property-table">
    <xsl:param name="items" select="Item"/>
    <xsl:param name="index-include">1</xsl:param>
    <xsl:param name="fullname-include">1</xsl:param>
    <xsl:param name="definition-include">1</xsl:param>
    <xsl:param name="parent-include">0</xsl:param>
    <xsl:param name="parent-level">-1</xsl:param>
    <xsl:param name="parent-header">Parent</xsl:param>
    <xsl:param name="name-include">1</xsl:param>
    <xsl:param name="name-header">Name</xsl:param>
    <xsl:param name="type-include">1</xsl:param>

    <xsl:variable name="types" select="key('types-by-name', $items/@type)"/>
    <xsl:variable name="properties" select="$unique-properties[@name=$types/Property/@name]"/>
    
    <xsl:variable name="definitions" select="$items[@definition]"/>

    <Table>
      <xsl:if test="$fullname-include = 1">
        <Column ss:Width='400'/>
      </xsl:if>
      <xsl:if test='$parent-include = 1'>
        <Column ss:Width='200'/>
      </xsl:if>
      <xsl:if test='$name-include = 1'>
        <Column ss:Width='100'/>
      </xsl:if>
      <Row>
        <xsl:if test="$fullname-include = 1">
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>FullName</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test='$parent-include = 1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text' select='$parent-header'/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test='$name-include = 1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text' select='$name-header'/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$definition-include = 1 and count($definitions) > 0">
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Definition</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test='index-include=1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Index</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:for-each select='$properties'>
          <xsl:sort select="@count" data-type="number" order="descending"/>
          <xsl:sort select="@name"/>
          <xsl:if test="not(contains(@name, $overridden))">
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text' select='@name'/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test='$type-include = 1'>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Type</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </Row>
      <xsl:for-each select="$items">
        <xsl:sort select="../@fullName" />
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number" />
        <xsl:sort select="@name" />
        <xsl:variable name="item" select="."/>
        <xsl:variable name="type" select="key('types-by-name', $item/@type)"/>
        <Row>
          <xsl:if test="$fullname-include = 1">
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text" select="$item/@fullName"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="$parent-include = 1">
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text">
                <xsl:choose>
                  <xsl:when test="$parent-level = -2">
                    <xsl:value-of select="../../@fullName"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="../@fullName"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="$name-include = 1">
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text" select="$item/@name"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="$definition-include = 1 and count($definitions) > 0">
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text" select="$item/@definition"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test='index-include=1'>
            <xsl:call-template name="number-cell">
              <xsl:with-param name="value" select="position()"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:for-each select="$properties">
            <xsl:sort select="@count" data-type="number" order="descending"/>
            <xsl:sort select="@name"/>
            <xsl:if test="not(contains(@name, $overridden))">
              <xsl:call-template name="property-cell">
                <xsl:with-param name="item" select="$item"/>
                <xsl:with-param name="property" select="@name"/>
                <xsl:with-param name="type" select="$type" />
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
          <xsl:if test='$type-include = 1'>
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text" select="$item/@type"/>
            </xsl:call-template>
          </xsl:if>
        </Row>
      </xsl:for-each>
    </Table>
    
  </xsl:template>
  
  <xsl:template name="property-cell">
    <xsl:param name="item"/>
    <xsl:param name="property"></xsl:param>
    <xsl:param name="type" select="key('types-by-name', $item/@type)"/>
    <xsl:param name="style">value</xsl:param>
    <xsl:param name="merge-down">0</xsl:param>
    <xsl:variable name="property-overridden" select="concat($property, $overridden)"/>
    <xsl:variable name="is-overridden" select="$item/Property[@name=$property-overridden]"/>
    <xsl:choose>
      <xsl:when test="$item/Property[@name=$property]">
        <xsl:call-template name="style-cell">
          <xsl:with-param name="text">
            <xsl:apply-templates select="$item/Property[@name=$property]" mode="cell"/>
          </xsl:with-param>
          <xsl:with-param name="style" select="$style"/>
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not($type/Property[@name=$property])">
        <xsl:call-template name="no-value">
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$item/@definition">
        <xsl:call-template name="property-cell">
          <xsl:with-param name="item" select="key('items-by-full-name', $item/@definition)"/>
          <xsl:with-param name="property" select="$property"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="style">inherited-value</xsl:with-param>
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$type/Property[@name=$property]">
        <xsl:call-template name="style-cell">
          <xsl:with-param name="text">
            <xsl:apply-templates select="$type/Property[@name=$property]" mode="cell"/>
          </xsl:with-param>
          <xsl:with-param name="style">default-value</xsl:with-param>
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="no-value">
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
  <xsl:template name="get-property-value">
    <xsl:param name="item"/>
    <xsl:param name="property"></xsl:param>
    <xsl:choose>
      <xsl:when test="not($item)"/>
      <xsl:when test="$item/Property[@name=$property]">
        <xsl:apply-templates select="$item/Property[@name=$property]" mode="cell"/>
      </xsl:when>
      <xsl:when test="$item/@definition">
        <xsl:call-template name="get-property-value">
          <xsl:with-param name="item" select="key('items-by-full-name', $item/@definition)"/>
          <xsl:with-param name="property" select="$property"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template> 
-->
  <xsl:template match="Property" mode="cell">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Property[@name='DisplayIconBytes']" mode="cell">
    <xsl:text>{bytes}</xsl:text>
  </xsl:template>

  <xsl:template match="Property[property-value/HistoricalExpressionConfig]" mode="cell">
    <xsl:value-of select="property-value/HistoricalExpressionConfig/ExpressionConfig/@text"/>
  </xsl:template>

  <xsl:template match="Property[HistoricalExpressionConfig]" mode="cell">
    <xsl:value-of select="HistoricalExpressionConfig/ExpressionConfig/@text"/>
  </xsl:template>

  <xsl:template match="Property[property-value/EvaluationExpressionConfig]" mode="cell">
    <xsl:value-of select="property-value/EvaluationExpressionConfig/@format"/>
  </xsl:template>

  <xsl:template match="Property[property-value/FunctionConfig]" mode="cell">
    <xsl:value-of select="property-value/FunctionConfig/@format"/>
  </xsl:template>

  <xsl:template match="Property[FunctionConfig]" mode="cell">
    <xsl:value-of select="FunctionConfig/@format"/>
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
  
  <xsl:template match="Property[property-value/ItemLocations/ItemLink]" mode="cell">
    <xsl:for-each select="property-value/ItemLocations/ItemLink">
      <xsl:choose>
        <xsl:when test="starts-with(@relativePath, 'Parent.Parent.')">
          <xsl:value-of select="@absolutePath"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@relativePath"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="Property[@type='System.Boolean']" mode="cell">
    <xsl:choose>
      <xsl:when test="text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>False</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-enum">
    <xsl:param name="value" select="."/>
    <xsl:choose>
      <xsl:when test="contains($value, ':')">
        <xsl:value-of select="substring-after($value, ':')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="Property[@name='CalculationType']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='Action']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

</xsl:stylesheet>
