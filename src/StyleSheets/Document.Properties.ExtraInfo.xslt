<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <!--
    <xsl:include href="Document.Common.xslt"/> 
    <xsl:include href="Document.Properties.Common.xslt"/> 
  -->

  <xsl:param name="includeExtraInfo">true</xsl:param>

  <xsl:key name="field-properties-by-name" match="Item[@id]/Item[@name='Fields']/Item[@id]/Property[@name]" use="concat(../../../@id, '-', @name)"/>
   
  <xsl:key name="properties-by-name" match="Item[@id]/Item[@id]/Property[@name]" use="concat(../../@id, '-', @name)"/>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>

  <xsl:variable name="defaultDisplayOrder">
    <xsl:variable name="platformVersion" select="/Project/Properties/ProjectProperty[@name='Platform.Version']"/>
    <xsl:variable name="majorVersion" select="substring-before($platformVersion, '.')"/>
    <xsl:variable name="minorVersion" select="substring-before(substring-after($platformVersion, '.'), '.')"/>
    <xsl:choose>
      <xsl:when test="($majorVersion > 4)">50000</xsl:when>
      <xsl:when test="($majorVersion = 4) and ($minorVersion >= 2)">50000</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="Item[@id]" mode="extra-info">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.LookupLists.CauseLookupListItem']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Cause Codes</xsl:with-param>
      <xsl:with-param name="items" select="//Item[@type='Citect.Ampla.General.Server.CauseCode']"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.LookupLists.ClassificationLookupListItem']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Classifications</xsl:with-param>
      <xsl:with-param name="items" select="//Item[@type='Citect.Ampla.General.Server.Classification']"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.LookupLists.EffectLookupListItem']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Effects</xsl:with-param>
      <xsl:with-param name="items" select="//Item[@type='Citect.Ampla.General.Server.Effect']"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode="extra-info">
    <xsl:variable name="resolvers" select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
    <xsl:variable name="metricsFullname" select="concat(../../@fullName, '.')"/>
    <table class="p-tab">
      <tbody>
        <tr>
          <th colspan="{count($resolvers)}">
            <xsl:text>KPI: </xsl:text>
            <xsl:call-template name="link-to-fullpath">
              <xsl:with-param name="item" select="."/>
              <xsl:with-param name="name" select="@name"/>
            </xsl:call-template>
          </th>
        </tr>
        <tr class="tr-alt">
          <td colspan="{count($resolvers)}" class="p-val">
            <xsl:variable name="formula" select="key('items-by-id', Property[@name='Formula']/linkFrom/link/@id)"/>
            <pre class="formula">
              <xsl:value-of select="$formula/@name"/>
              <xsl:text> = </xsl:text>
              <!-- <xsl:value-of select="$crlf"/> -->
              <xsl:value-of select="$formula/Property[@name='Expression']/text()"/>
            </pre>
          </td>
        </tr>
        <tr>
          <xsl:for-each select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']">
            <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
            <xsl:sort select="@name"/>
            <td class="p-val">
              <xsl:text>Resolver: </xsl:text>
              <xsl:call-template name="link-to-fullpath">
                <xsl:with-param name="item" select="."/>
                <xsl:with-param name="name" select="@name"/>
              </xsl:call-template>
              <!--            </td>
          </xsl:for-each>
        </tr>
        <tr>
          <xsl:for-each select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']">
-->
              <xsl:variable name="action" select="Property[@name='Action']"/>
              <xsl:choose>
                <xsl:when test="$action='KPI'">
                  <xsl:variable name="kpi" select="key('items-by-id', Property[@name='KpiItem']/linkFrom/link/@id)"/>
                  <!--                            <td class="p-val"> -->
                  <br/>
                  <xsl:text> -> KPI:</xsl:text>
                  <xsl:call-template name="link-to-fullpath">
                    <xsl:with-param name="item" select="$kpi"/>
                    <xsl:with-param name="name">
                      <xsl:call-template name="getRelative">
                        <xsl:with-param name="fullName" select="$kpi/@fullName"/>
                        <xsl:with-param name="relativeName" select="$metricsFullname"/>
                      </xsl:call-template>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:apply-templates select="$kpi" mode="extra-info"/>
                  <!--                </td> -->
                </xsl:when>
                <xsl:when test="$action='Module'">
                  <!--                            <td class="p-val"> -->
                  <xsl:element name="pre">
                    <xsl:attribute name="class">sql</xsl:attribute>
                    <xsl:text>SELECT </xsl:text>
                    <xsl:value-of select="Property[@name='ResolverOperation']"/>
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="Property[@name='SourceFieldName']"/>
                    <xsl:text>)</xsl:text>
                    <xsl:value-of select="$crlf"/>
                    <!-- <br/> -->
                    <xsl:text>FROM {</xsl:text>
                    <xsl:value-of select="Property[@name='Module']"/>
                    <xsl:text>}</xsl:text>
                    <xsl:value-of select="$crlf"/>
                    <!-- <br/> -->
                    <xsl:text>WHERE Location='</xsl:text>
                    <xsl:variable name="location">
                      <xsl:choose>
                        <xsl:when test="Property[@name='SourceLocations']/linkFrom/link/@fullName">
                          <xsl:value-of select="Property[@name='SourceLocations']/linkFrom/link/@fullName"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="Property[@name='SourceLocations']"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="shortName">
                      <xsl:choose>
                        <xsl:when test="string-length($location)>20">
                          <xsl:text>...</xsl:text><xsl:value-of select="substring($location, string-length($location)-20)"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="$location"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="span">
                      <xsl:attribute name="title">
                        <xsl:value-of select="$location"/>
                      </xsl:attribute>
                      <xsl:value-of select="$shortName"/>
                    </xsl:element>
                    <!-- <xsl:apply-templates select="Property[@name='SourceLocations']"/> -->
                    <xsl:text>'</xsl:text>
                    <xsl:if test="Property[@name='WhereCondition']">
                      <xsl:value-of select="$crlf"/>
                      <!-- <br/> -->
                      <xsl:text>AND </xsl:text>
                      <xsl:apply-templates select="Property[@name='WhereCondition']"/>
                    </xsl:if>
                  </xsl:element>
                  <!--                </td> -->
                </xsl:when>
                <xsl:otherwise>
                  <!--              <td class="p-val"> -->
                  <xsl:apply-templates select="$action"/>
                  <!--                </td> -->
                </xsl:otherwise>
              </xsl:choose>
            </td>              
          </xsl:for-each>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="getRelative">
    <xsl:param name="fullName" select="./@fullName"/>
    <xsl:param name="relativeName"/>
    <xsl:choose>
      <xsl:when test="starts-with($fullName, $relativeName)">
        <xsl:text>...</xsl:text>
        <xsl:value-of select="substring-after($fullName, $relativeName)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fullName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<xsl:template match="Item[@type='Citect.Ampla.Plant2Business.Server.File2AmplaIntegration']" mode="extra-info">
		<div><img src="{concat('Graphs\', @hash, '.png')}" alt="{concat('File2Ampla image for ', @fullName)}"/></div>
	</xsl:template>
  
  <xsl:template match="Item[@type='Citect.Ampla.Production.Server.ProductionReportingPoint']" mode="extra-info">
    <xsl:call-template name="outputFieldsTable"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Downtime.Server.DowntimeReportingPoint']" mode="extra-info">
    <xsl:call-template name="outputFieldsTable"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']" mode="extra-info">
    <xsl:call-template name="outputFieldsTable"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Planning.Server.PlanningReportingPoint']" mode="extra-info">
    <xsl:call-template name="outputFieldsTable"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Planning.Server.TagDownloadAction']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">
        <xsl:value-of select="@name"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

   <xsl:template match="Item[@type='Citect.Ampla.Planning.Recipe.Server.RecipeParameterGroup']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading" select='@name'/>
	  <xsl:with-param name="includeType">false</xsl:with-param>
	  <xsl:with-param name="namePrefix" select="concat(@name, '.')"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="Item[@type='Citect.Ampla.Connectors.Simulation.SimulationGroup']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Variables</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Connectors.OpcHdaConnector.OpcHdaGroup']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Variables</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Connectors.ScadaConnector.ScadaDataSource']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Connector Details</xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.FormulasFolder']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Formulas</xsl:with-param>
      <xsl:with-param name="includeType">false</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.UserGroup']" mode="extra-info">
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Users</xsl:with-param>
      <xsl:with-param name="includeType">false</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="outputFieldsTable">
    <xsl:variable name="id" select="@id"/>
    <xsl:call-template name="outputPropertyTable">
      <xsl:with-param name="heading">Fields Table</xsl:with-param>
      <xsl:with-param name="items" select="Item[@name='Fields']/Item[@id]"/>
      <xsl:with-param name="properties" select="Item[@name='Fields']/Item[@id]/Property[generate-id()= generate-id(key('field-properties-by-name', concat($id, '-', @name))[1])]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Property" mode="property-table">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="Property[HistoricalExpressionConfig]" mode="property-table">
    <xsl:apply-templates select="HistoricalExpressionConfig/ExpressionConfig/@text"/>
  </xsl:template>

  <xsl:template match="Property[property-value/HistoricalExpressionConfig]" mode="property-table">
    <xsl:apply-templates select="property-value/HistoricalExpressionConfig/ExpressionConfig/@text"/>
  </xsl:template>

  <xsl:template match="Property[@name='DisplayOrder']" mode="property-table">
    <xsl:choose>
      <xsl:when test="$defaultDisplayOrder = 50000">
        <xsl:variable name="displayOrder" select="."/>
        <xsl:variable name="displayOrderGroup" select="floor($displayOrder div 10000)"/>
        <xsl:variable name="displayOrderIndex" select="$displayOrder mod 10000"/>
        <xsl:value-of select="$displayOrderGroup"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$displayOrderIndex"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="outputPropertyTable">
    <xsl:param name="heading">Items Table</xsl:param>
    <xsl:param name="items" select="Item[@id]"/>
    <xsl:param name="item-id" select="@id"/>
    <xsl:param name="properties" select="Item[@id]/Property[generate-id()= generate-id(key('properties-by-name', concat($item-id, '-', @name))[1])]"/>
    <xsl:param name="includeType">true</xsl:param>
	<xsl:param name="namePrefix"></xsl:param>

    <xsl:if test="($includeExtraInfo='true') and (count($items)>0)">
      <xsl:variable name="includeChildren" select="count($items/Item[@id])>0"/>
      <xsl:variable name="includeLinks" select="count($items/linkTo/link)>0"/>

      <div class="i-sect">
        <xsl:value-of select="$heading"/>
      </div>
      <table class="p-tab">
        <tbody>
          <tr>
            <th>#</th>
            <th>Name</th>
            <xsl:if test="$includeLinks">
              <th>Links</th>
            </xsl:if>
            <xsl:if test="$includeChildren">
              <th>Children</th>
            </xsl:if>
            <xsl:for-each select="$properties">
              <xsl:sort select="count($items/Property[@name=current()/@name])" data-type="number" order="descending"/>
              <xsl:sort select="@name"/>
              <th>
                <xsl:value-of select="@name"/>
              </th>
            </xsl:for-each>
            <xsl:if test="$includeType='true'">
              <th>Type</th>
            </xsl:if>
          </tr>
          <xsl:for-each select="$items">
            <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
            <xsl:sort select="@name"/>
            <xsl:variable name="item" select="current()"/>
            <tr>
              <xsl:if test="position() mod 2 = 1">
                <xsl:attribute name="class">tr-alt</xsl:attribute>
              </xsl:if>
              <td class="p-key">
                <xsl:value-of select="position()"/>
              </td>
              <td class="p-val">
                <xsl:call-template name="item-href">
                  <xsl:with-param name="name" select="concat($namePrefix, @name)"/>
                  <xsl:with-param name="site"></xsl:with-param>
                </xsl:call-template>
              </td>
              <xsl:if test="$includeLinks">
                <td class="p-val">
                  <xsl:call-template name="outputLinks">
                    <xsl:with-param name="links" select="linkTo/link"/>
                    <xsl:with-param name="includeSpacer">false</xsl:with-param>
                    <xsl:with-param name="includeText">true</xsl:with-param>
                  </xsl:call-template>
                </td>
              </xsl:if>
              <xsl:if test="$includeChildren">
                <td class="p-val">
                  <xsl:call-template name="itemCount">
                    <xsl:with-param name="numItems" select="count(descendant::Item[@id])"/>
                    <xsl:with-param name="includeSpacer">false</xsl:with-param>
                    <xsl:with-param name="includeText">true</xsl:with-param>
                  </xsl:call-template>
                </td>
              </xsl:if>
              <xsl:for-each select="$properties">
                <xsl:sort select="count($items/Property[@name=current()/@name])" data-type="number" order="descending"/>
                <xsl:sort select="@name"/>
                <xsl:variable name="prop-name" select="@name"/>
                <xsl:variable name="property" select="$item/Property[@name=$prop-name]"/>
                <xsl:choose>
                  <xsl:when test="$property">
                    <td class="p-val">
                      <xsl:apply-templates select="$property" mode="property-table"/>
                    </td>
                  </xsl:when>
                  <xsl:otherwise>
                    <td class="p-dflt"></td>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:if test="$includeType='true'">
                <td class="p-val">
                  <xsl:value-of select="@type"/>
                </td>
              </xsl:if>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
