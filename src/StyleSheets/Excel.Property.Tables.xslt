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
  
  This XSL transforms AmplaProject properties data into an Office XML 2003 file.
  https://msdn.microsoft.com/en-us/library/aa140066(v=office.10).aspx
  -->

  <xsl:include href='Excel.Common.xslt' />

  <xsl:variable name='quote'>'</xsl:variable>
  <xsl:variable name="cr" select="'&#xD;'"/>
  
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

  <xsl:template name="item-property-table-by-type">
    <xsl:param name='items' select="Item"/>
    <xsl:param name="fullname-header">FullName</xsl:param>
    <xsl:param name="select-child-type"></xsl:param>
    <xsl:param name="definition-include">1</xsl:param>
    <xsl:param name="index-include">1</xsl:param>
    <xsl:param name="type-include">1</xsl:param>
    <xsl:param name="select-child-items">1</xsl:param>

    <xsl:variable name="all-items" select="$items/Item[@type=$select-child-type]/descendant::Item"/>
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
        <xsl:variable name="select-child" select="@name"/>
        <xsl:variable name="children" select="$item/Item[@type=$select-child-type]"/>
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
                <xsl:choose>
                  <!-- for items that have fullname property-->
                  <xsl:when test="substring-after($child/@fullName, $relative-prefix)>''">
                    <xsl:call-template name="text-cell">
                      <xsl:with-param name="text" select="substring-after($child/@fullName, $relative-prefix)"/>
                    </xsl:call-template>
                  </xsl:when>
                  <!-- otherwise use name property-->
                  <xsl:otherwise>
                    <xsl:call-template name="text-cell">
                      <xsl:with-param name="text" select="$child/@name"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
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
  
  <xsl:template name="property-table-rows">
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

      <xsl:call-template name='property-table-rows'>
        <xsl:with-param name="items" select="$items"/>
        <xsl:with-param name="index-include" select="$index-include"/>
        <xsl:with-param name="fullname-include" select="$fullname-include"/>
        <xsl:with-param name="definition-include" select="$definition-include"/>
        <xsl:with-param name="parent-include" select="$parent-include"/>
        <xsl:with-param name="parent-level" select="$parent-level"/>
        <xsl:with-param name="parent-header" select="$parent-header"/>
        <xsl:with-param name="name-include" select="$name-include"/>
        <xsl:with-param name="name-header" select="$name-header"/>
        <xsl:with-param name="type-include" select="$type-include"/>
      </xsl:call-template>
      
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
          <xsl:with-param name="comment">
            <xsl:apply-templates select="$item/Property[@name=$property]" mode="comment"/>
          </xsl:with-param>
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
          <xsl:with-param name="comment">
            <xsl:apply-templates select="$item/Property[@name=$property]" mode="comment"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="no-value">
          <xsl:with-param name="merge-down" select="$merge-down"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Property" mode="cell">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Property" mode="comment"/>

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

  <xsl:template name="count-lines">
    <xsl:param name="text" select="."/>
    <xsl:param name="counter">0</xsl:param>
    <xsl:choose>
      <xsl:when test="contains($text, $cr)">
        <xsl:call-template name="count-lines">
          <xsl:with-param name="text" select="substring-after($text, $cr)"/>
          <xsl:with-param name="counter" select="$counter + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string-length($text) > 0">
        <xsl:value-of select="$counter + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$counter"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="relative-item">
    <xsl:param name="current" select="."/>
    <xsl:param name="item"/>
    <xsl:param name="item-full-name"></xsl:param>
    <xsl:param name="prefix"></xsl:param>
    <xsl:variable name="current-full-name" select="$current/@fullName"/>
    <xsl:choose>
      <xsl:when test="$item">
        <xsl:variable name="item-root" select="($item/ancestor-or-self::Item)[1]"/>
        <xsl:variable name="current-root" select="($current/ancestor-or-self::Item)[1]"/>
        <xsl:choose>
          <!-- same tree -->
          <xsl:when test="$item-root/@id = $current-root/@id">
            <xsl:call-template name="relative-item">
              <xsl:with-param name="current" select="$current"/>
              <xsl:with-param name="item-full-name" select="$item/@fullName"/>
              <xsl:with-param name="prefix" select="$prefix"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$item/@fullName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="not($current-full-name)">
        <xsl:value-of select="$item-full-name"/>
      </xsl:when>
      <xsl:when test="starts-with($item-full-name, $current-full-name)">
        <xsl:value-of select="concat('...', $current/@name, substring-after($item-full-name, $current-full-name))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="relative-item">
          <xsl:with-param name="current" select="$current/parent::Item"/>
          <xsl:with-param name="item-full-name" select="$item-full-name"/>
          <xsl:with-param name="prefix" select="concat('.', $prefix)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="Property[property-value[not(*) and text()] and linkFrom/link/@fullName]" mode="cell">
    <xsl:variable name="current" select="parent::Item"/>
    <xsl:variable name="items" select="key('items-by-full-name', linkFrom/link/@fullName)"/>
    <xsl:for-each select="$items">
      <xsl:variable name="item" select="."/>
      <xsl:if test="position() > 1">,</xsl:if>
      <xsl:call-template name="relative-item">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="item" select="$item"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Property[property-value[not(*) and text()] and linkFrom/link/@fullName]" mode="comment">
    <xsl:variable name="current" select="parent::Item"/>
    <xsl:variable name="items" select="key('items-by-full-name', linkFrom/link/@fullName)"/>
    <xsl:for-each select="$items">
      <xsl:variable name="item" select="."/>
      <xsl:if test="position() > 1">,</xsl:if>
      <xsl:value-of select="$item/@fullName"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Property[property-value/ItemLocations and linkFrom/link/@fullName]" mode="cell">
    <xsl:variable name="current" select="parent::Item"/>
    <xsl:variable name="items" select="key('items-by-full-name', linkFrom/link/@fullName)"/>
    <xsl:for-each select="$items">
      <xsl:variable name="item" select="."/>
      <xsl:if test="position() > 1">,</xsl:if>
      <xsl:call-template name="relative-item">
        <xsl:with-param name="current" select="$current"/>
        <xsl:with-param name="item" select="$item"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Property[property-value/ItemLocations and linkFrom/link/@fullName]" mode="comment">
    <xsl:variable name="current" select="parent::Item"/>
    <xsl:variable name="items" select="key('items-by-full-name', linkFrom/link/@fullName)"/>
    <xsl:for-each select="$items">
      <xsl:variable name="item" select="."/>
      <xsl:if test="position() > 1">,</xsl:if>
      <xsl:value-of select="$item/@fullName"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Property[@name='CalculationType']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='Action']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='AuthenticationMode']" mode="cell">
    <xsl:call-template name="display-enum"/>
  </xsl:template>

  <xsl:template match="Property[@name='Source']" mode="cell">
    <xsl:variable name="lines">
      <xsl:call-template name="count-lines">
        <xsl:with-param name="text" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat('{', $lines, ' lines}')"/>
  </xsl:template>

</xsl:stylesheet>
