<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:include href="Document.Common.xslt"/>

  <xsl:param name="includeChildItems">true</xsl:param>
  <xsl:param name="suppressIdentity">true</xsl:param>

  <xsl:param name="use-chilli">false</xsl:param>
  
  <xsl:template match="ProjectProperty[@name='CodeReferences']/text()">
    <pre>
      <xsl:value-of select="."/>
    </pre>
  </xsl:template>

  <xsl:template name="format-code">
    <xsl:param name="text" select="text()"/>
    <xsl:choose>
      <xsl:when test="$use-chilli = 'true'">
        <code class="csharp">
          <xsl:value-of select="$text"/>
        </code>
      </xsl:when>
      <xsl:otherwise>
        <pre>
          <xsl:value-of select="$text"/>
        </pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
  ##############################
  # Format C# code using chili #
  ##############################
  -->
  <xsl:template match="Item[@type='Citect.Ampla.StandardItems.Code']/Property[@name='Source']">
    <xsl:call-template name="format-code"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.Xml.XmlUpload']/Property[@name='Transform']">
    <pre>
      <xsl:value-of select="text()"/>
    </pre>
  </xsl:template>
  
  <!-- 
  ends-with($value, $substr) = substring($value, (string-length($value) - string-length($substr)) + 1) = $substr
  -->
  <xsl:template match="Item[@id]/Property[starts-with(@name, 'Expression') and substring(@name, (string-length(@name) - 4) + 1) = 'Text']">
    <xsl:call-template name="format-code"/>
  </xsl:template>

  <xsl:template match="Property[@name='URL']">
	<xsl:element name="a">
		<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
		<xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
		<code><xsl:value-of select="."/></code>
	</xsl:element>
  </xsl:template>
  
  <xsl:template match="Property[@name='Identity']">
    <xsl:choose>
      <xsl:when test="($suppressIdentity='true') and (contains(text(), '|'))">
        <xsl:value-of select="substring-before(text(), '|')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Item[@id]/Property[@name='Address']">
    <xsl:variable name="item-name" select="../@name"/>
    <xsl:variable name="address" select="."/>
    <xsl:choose>
      <xsl:when test="$item-name=$address">
        <xsl:value-of select="$address"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="title">
          <xsl:text>Name = </xsl:text>
          <xsl:value-of select="$item-name"/>
          <xsl:text>
Address = </xsl:text><xsl:value-of select="$address"/>
        </xsl:variable>
        <span class="warning" title="{$title}">
          <xsl:value-of select="$address"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Property[@name='CalculationType']">
    <xsl:choose>
      <xsl:when test="contains(text(), ':')">
        <xsl:value-of select="substring-after(text(), ':')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Property[@name='TraceLevel']">
    <xsl:variable name="value" select="."/>
    <xsl:choose>
      <xsl:when test="$value='Verbose'">
        <span class="warning" title="TraceLevel = 'Verbose'">
          <xsl:value-of select="$value"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="Item[@id]/Property[contains(@name, 'CompileAction')]">
    <xsl:choose>
      <xsl:when test=". = 'None'">
        <span class="warning">
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="HistoricalExpressionConfig">
    <xsl:text>Expression: </xsl:text>
    <xsl:if test="ExpressionConfig/@message">
      <span class="warning">
        <xsl:value-of select="ExpressionConfig/@message"/>
      </span>
    </xsl:if>
    <xsl:call-template name="format-code">
      <xsl:with-param name="text" select="ExpressionConfig/@format"/>
    </xsl:call-template>
    <xsl:for-each select="ExpressionConfig/ItemLinkCollection/ItemLink">
      <br/>
      <xsl:text>#ItemReference</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:call-template name="resolve-item-link"/>
    </xsl:for-each>
    <xsl:apply-templates select="DependencyCollection"/>
    <xsl:apply-templates select="ExpressionConfig/@compileAction"/>
  </xsl:template>

  <xsl:template match="property-value/HistoricalExpressionConfig">
    <xsl:text>Expression: </xsl:text>
    <xsl:if test="ExpressionConfig/@message">
      <span class="warning">
        <xsl:value-of select="ExpressionConfig/@message"/>
      </span>
    </xsl:if>
    <xsl:call-template name="format-code">
      <xsl:with-param name="text" select="ExpressionConfig/@format"/>
    </xsl:call-template>
    <xsl:for-each select="ExpressionConfig/ItemLinkCollection/ItemLink">
      <br/>
      <xsl:text>#ItemReference</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:call-template name="resolve-item-link"/>
    </xsl:for-each>
    <xsl:apply-templates select="DependencyCollection"/>
    <xsl:apply-templates select="ExpressionConfig/@compileAction"/>
  </xsl:template>
<!--
  <Property name="MaterialConversionExpression">
    <ExpressionConfig format="sourceQuantity * 10" compileAction="Compile" filterValues="False" text="sourceQuantity * 10">
    </ExpressionConfig>
  </Property>
-->

  <xsl:template match="ExpressionConfig">
    <xsl:text>Expression: </xsl:text>
    <code class="csharp">
      <xsl:value-of select="@format"/>
    </code>
  </xsl:template>
  
  <xsl:template match="soap-property">
    <div>
      <xsl:value-of select="@name"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="."/>
    </div>    
  </xsl:template>
  
  <xsl:template match="@compileAction">
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test=". = 'None'">
          <xsl:text>warning</xsl:text>
        </xsl:when>
        <xsl:otherwise>default</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <br/>
    <span class="{$class}">
      <xsl:text>CompileAction = </xsl:text>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template name="outputItemHeader">
    <xsl:param name="site"/>
    <div class="i-head">
      <xsl:variable name="parent" select="ancestor::Item[@id]"/>
      <xsl:if test="$parent">
        <xsl:for-each select="$parent">
          <xsl:call-template name="item-href">
            <xsl:with-param name="site"></xsl:with-param>
          </xsl:call-template>
          <xsl:text>.</xsl:text>
        </xsl:for-each>
      </xsl:if>
      <xsl:call-template name="item-href">
        <xsl:with-param name="site" select="$site"/>
      </xsl:call-template>
    </div>
    <xsl:variable name="translation">
      <xsl:call-template name="getTranslatedFullName"/>
    </xsl:variable>
    <xsl:if test="string-length($translation)>0">
      <span class="i-trans">
        <xsl:value-of select="$translation"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="outputItemProperties">
    <xsl:param name="sect">i-sect</xsl:param>
    <div class="{$sect}">Properties</div>
    <table class="p-tab">
      <tr>
        <th>Name</th>
        <th>Value</th>
      </tr>
      <tr class="tr-alt">
        <td class="pName">Type</td>
        <td class="pValue">
          <xsl:value-of select="@type"/>
        </td>
      </tr>
      <xsl:for-each select="Property">
        <xsl:sort select="@name"/>
        <tr>
          <xsl:if test="position() mod 2 = 0">
            <xsl:attribute name="class">tr-alt</xsl:attribute>
          </xsl:if>
          <td class="p-key">
            <xsl:value-of select="@name"/>
          </td>
          <td class="p-val">
            <xsl:apply-templates select="."/>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xsl:template name="outputItemLinks">
    <xsl:param name="sect">i-sect</xsl:param>
    <xsl:variable name="linksTo" select="linkTo/link"/>
    <xsl:if test="count($linksTo)">
      <xsl:variable name="fullname_dot" select="concat(@fullName, '.')"/>
      <xsl:variable name="fullname" select="@fullName"/>
      <div class="{$sect}">Links</div>
      <xsl:for-each select="$linksTo">
        <xsl:sort select="@fullName"/>
        <div class="link">
          <xsl:value-of select="position()"/>
          <xsl:text> - </xsl:text>
          <xsl:variable name="item" select="key('items-by-id', @id)"/>
          <xsl:variable name="name">
            <xsl:choose>
              <xsl:when test="$item/@fullName = $fullname">
                <xsl:text>(this)</xsl:text>
              </xsl:when>
              <xsl:when test="starts-with($item/@fullName, $fullname_dot)">
                <xsl:text>...</xsl:text>
                <xsl:value-of select="substring($item/@fullName, string-length($fullname_dot)+1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$item/@fullName"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="link-to-fullpath">
            <xsl:with-param name="item" select="$item"/>
            <xsl:with-param name="name" select="$name"/>
          </xsl:call-template>
          <xsl:text> - (</xsl:text>
          <xsl:value-of select="@property"/>
          <xsl:text>)</xsl:text>
        </div>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="outputItemChildren">
    <xsl:param name="sect">i-sect</xsl:param>
    <xsl:if test="$includeChildItems='true' and Item">
      <div class="{$sect}">Children</div>
      <xsl:call-template name="listChildItems"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="listChildItems">
    <xsl:for-each select="Item[@id]">
      <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
      <xsl:sort select="@name"/>
      <div>
        <xsl:value-of select="position()"/>
        <xsl:text> - </xsl:text>
        <xsl:call-template name="item-href">
          <xsl:with-param name="name" select="@name"/>
          <xsl:with-param name="site"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="itemCount">
          <xsl:with-param name="numItems" select="count(descendant::Item[@id])"/>
        </xsl:call-template>
        <xsl:call-template name="outputLinks">
          <xsl:with-param name="links" select="linkTo/link"/>
          <xsl:with-param name="includeTooltip">false</xsl:with-param>
        </xsl:call-template>
      </div>
    </xsl:for-each>
  </xsl:template>



  <!--
  ##############################
  # Format Links to items      #
  ##############################
  --> 

  <!-- 
        <ItemLink relativePath="Hour" absolutePath="System Configuration.Periods.Hour" targetID="6a0aa9ac-8024-4dfd-8e33-106b7d002a3e"/>
  -->

  <xsl:template match="property-value/ItemLink">
    <div>
      <xsl:call-template name="resolve-item-link"/>
    </div>
  </xsl:template>
<!--
  <xsl:template match="property-value/ItemLink[@targetID]">
    <xsl:call-template name="resolve-item-link"/>
  </xsl:template>

  <xsl:template match="property-value/ItemLink[@type]">
    <br/>
    <xsl:call-template name="resolve-item-link"/>
  </xsl:template>

  <xsl:template match="property-value/ItemLink[@absolutePath]">
    <xsl:if test="position() > 1">
      <xsl:element name="br"/>
    </xsl:if>
    <xsl:call-template name="resolve-item-link"/>
  </xsl:template>
-->
  <!--
  <Property name="SourceData">
    <linkFrom>
      <link id="799a82e1-d3f2-8849-fb94-3d5e4141d098" fullName="Impala.BMR.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121"></link>
    </linkFrom>
    <property-value>
      <ItemLocations>
        <ItemLink relativePath="Parent.Parent.Parent.Parent.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121" absolutePath="Impala.BMR.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121" targetID="799a82e1-d3f2-8849-fb94-3d5e4141d098" resolveMode="Smart">
        </ItemLink>
      </ItemLocations>
    </property-value>
  </Property>
  -->
  <xsl:template match="property-value/ItemLocations">
    <xsl:for-each select="ItemLink">
      <div>
        <xsl:call-template name="resolve-item-link"/>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="property-value/ItemLink">
      <div>
        <xsl:call-template name="resolve-item-link"/>
      </div>
  </xsl:template>

  <!-- 
                  <DependencyCollection>
                    <Dependency dependencyType="Trigger">
                      <ItemPropertyLink propertyName="Samples">
                        <ItemLink relativePath="Parent.Parent.Parent.Create New Pallet Record" absolutePath="UTC.WAH.Snacks.1 Line 1.Create New Pallet Record" targetID="49127807-664a-4366-afa8-219736d5149e" resolveMode="Smart">
                        </ItemLink>
                      </ItemPropertyLink>
                    </Dependency>
                  </DependencyCollection>
  -->
  <xsl:template match="DependencyCollection">
    <xsl:for-each select="Dependency/ItemPropertyLink/ItemLink">
      <div>
        <xsl:text>#Dependency</xsl:text>
        <xsl:value-of select="position()-1"/>
        <xsl:text># = </xsl:text>
        <xsl:call-template name="resolve-item-link"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="../@propertyName"/>
      </div>
    </xsl:for-each>

  </xsl:template>

  <!-- 
  <FunctionConfig format="EOM.ProcessHeldRecords(project,&quot;UTC.WAH.Snacks.2 Line 2.Production&quot;);" compileAction="Compile">
  </FunctionConfig>
  -->

  <xsl:template match="FunctionConfig">
    <xsl:text>Function: </xsl:text>
    <code class="csharp">
      <xsl:value-of select="@format"/>
    </code>
    <xsl:for-each select="ItemLinkCollection/ItemLink">
      <div>
        <xsl:text>#ItemReference</xsl:text>
        <xsl:value-of select="position()-1"/>
        <xsl:text># = </xsl:text>
        <xsl:call-template name="resolve-item-link">
          <xsl:with-param name="id" select="@targetID"/>
          <xsl:with-param name="full-path" select="@absolutePath"/>
        </xsl:call-template>
      </div>
    </xsl:for-each>
    <xsl:apply-templates select="@compileAction"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.Views.CustomView']/Property[@name='Fields']">
    <pre>
      <xsl:value-of select="text()"/>
    </pre>
  </xsl:template>

  
  <!-- 
      <NamedInstance name="Jul-2003" startDateTimeUtc="2003-06-21T22:00:00" endDateTimeUtc="2003-07-22T21:59:59"/>
  -->
  <xsl:template match="NamedInstance">
    <div>
      <xsl:value-of select="@name"/>
      <xsl:text> ( </xsl:text>
      <xsl:value-of select="@startDateTimeUtc"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="@endDateTimeUtc"/>
      <xsl:text> )</xsl:text>
    </div>
  </xsl:template>

  <!-- 
  Plant2Business Adapter Fields
  
             <Property collection="true" type="Citect.Ampla.Plant2Business.Mapping.AdapterFieldCollection,Citect.Ampla.Plant2Business.Mapping">
              <Item type="Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping">
                <Property name="AllowNulls">False</Property>
                <Property name="DataType">String</Property>
                <Property name="DateTimeMode">Local</Property>
                <Property name="DefaultValue">(DBNull)</Property>
                <Property name="Name">State</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping">
                <Property name="AllowNulls">False</Property>
                <Property name="DataType">String</Property>
                <Property name="DateTimeMode">Local</Property>
                <Property name="DefaultValue">(DBNull)</Property>
                <Property name="Name">Mode</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping">
                <Property name="AllowNulls">False</Property>
                <Property name="DataType">DateTime</Property>
                <Property name="DateTimeMode">Local</Property>
                <Property name="DefaultValue">(DBNull)</Property>
                <Property name="Name">SampleDateTime</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping">
                <Property name="AllowNulls">False</Property>
                <Property name="DataType">String</Property>
                <Property name="DateTimeMode">Local</Property>
                <Property name="DefaultValue">(DBNull)</Property>
                <Property name="Name">Checksum</Property>
              </Item>
            </Property>
  -->

  <xsl:template match="Property[@type='Citect.Ampla.Plant2Business.Mapping.AdapterFieldCollection,Citect.Ampla.Plant2Business.Mapping']">
    <table>
      <tbody>
        <tr>
          <th>Name</th>
          <th>Data Type</th>
          <th>Default Value</th>
        </tr>
        <xsl:for-each select="Item[@type='Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping']">
          <tr>
            <td>
              <xsl:value-of select="Property[@name='Name']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='DataType']"/>
              <xsl:if test="Property[@name='DataType']/text() = 'DateTime'">
                <xsl:value-of select="concat(' (', Property[@name='DateTimeMode'],')')"/>
              </xsl:if>
            </td>
            <td>
              <xsl:value-of select="Property[@name='DefaultValue']"/>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
  <!-- 
  
             <Property collection="true" type="Citect.Ampla.Plant2Business.Mapping.FieldMappingCollection,Citect.Ampla.Plant2Business.Mapping">
              <Item type="Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping">
                <Property name="Source">State</Property>
                <Property name="Target">State</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping">
                <Property name="Source">Mode</Property>
                <Property name="Target">Mode</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping">
                <Property name="Source">SampleDateTime</Property>
                <Property name="Target">Sample Period</Property>
              </Item>
              <Item type="Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping">
                <Property name="Source">Checksum</Property>
                <Property name="Target">Checksum</Property>
              </Item>
            </Property>
  
  -->

  <xsl:template match="Property[@type='Citect.Ampla.Plant2Business.Mapping.FieldMappingCollection,Citect.Ampla.Plant2Business.Mapping']">
    <table>
      <tbody>
        <tr>
          <th>Source</th>
          <th>Target</th>
        </tr>
        <xsl:for-each select="Item[@type='Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping']">
          <tr>
            <td>
              <xsl:value-of select="Property[@name='Source']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='Target']"/>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="Property[@type='Citect.Ampla.General.Common.SpecificationDescriptorCollection,Citect.Ampla.General.Common']">
    <table>
      <tbody>
        <tr>
          <th>Name</th>
          <th>Colour</th>
        </tr>
        <xsl:for-each select="Item">
          <tr>
            <td>
              <xsl:value-of select="Property[@name='Name']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='Color']"/>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template match="property-value[text()]">
    <xsl:variable name="item" select="key('items-by-fullName', text())"/>
    <xsl:choose>
      <xsl:when test="$item">
        <xsl:call-template name="link-to-fullpath">
          <xsl:with-param name="item" select="$item"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text[@isCorrupt='true']">
    <span class="warning">
      <xsl:text> ( Corrupt )</xsl:text>
    </span>
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
