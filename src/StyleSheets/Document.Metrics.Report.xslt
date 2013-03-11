<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    indent="no"
              />

  <xsl:param name="lang">en</xsl:param>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>

  <xsl:key name="sources-by-module" match="Resolver/Source" use="@module"/>
  <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
  <xsl:key name="sources-by-module-fullname-name" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', @name)"/>
  <xsl:key name="sources-by-module-fullname" match="Resolver/Source" use="concat(@module, '-', @fullName)"/>
  <xsl:key name="sources-by-module-fullname-sql" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', Sql)"/>
  <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
  <xsl:key name="locations-by-fullname" match="Location" use="@fullName"/>
  <xsl:key name="kpi-by-fullname" match="Kpi" use="@fullName"/>
  <xsl:key name="resolver-by-fullname" match="Resolver" use="@fullName"/>
  <xsl:key name="kpiLink-by-fullname" match="KpiLink" use="@fullName"/>
  <xsl:key name="resolverLink-by-fullname" match="ResolverLink" use="@fullName"/>

  <xsl:variable name="all-modules" select="//Source[generate-id() = generate-id(key('sources-by-module', @module)[1])]/@module"/>
  
  <xsl:template match="/">
    <html>
      <xsl:if test="$lang">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
      <head>
        <title lang="en">Ampla Project - Metrics Summary</title>
        <link rel="stylesheet" type="text/css" href="css/metrics.css" media="screen,projector"/>
        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"/>
        <script type="text/javascript" src="lib/metrics.js"/>
      </head>
      <body>
        <a name="top"/>
        <h1 class="text">Ampla Project - Metrics Summary</h1>
        
        <xsl:for-each select="$all-modules">
          <xsl:sort select="count(key('sources-by-module', .))" data-type="number" order="descending"/>
          <xsl:call-template name="buildSourcesTree">
            <xsl:with-param name="module" select="."/>
          </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="buildMetricsTree"/>
        <hr/>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="buildSourcesTree">
    <xsl:param name="module"></xsl:param>
    <hr/>
    <a name="{$module}"/>

    <xsl:variable name="module-locations" select="key('locations-by-fullname', key('sources-by-module', $module)/@fullName)"/>
    <xsl:variable name="module-kpis" select="key('sources-by-module', $module)/ancestor::Kpi"/>
    <xsl:variable name="module-metrics" select="key('sources-by-module', $module)/ancestor::Metrics"/>

    <div class="summary">
      <div class="heading">
        <xsl:value-of select="$module"/>
      </div>
      <span>
        <xsl:value-of select="concat(count($module-locations), ' ', $module, ' location(s) provide data for ', count($module-kpis), ' KPI(s) in ', count($module-metrics), ' metrics point(s).')"/>
      </span>
    </div>
    <div class="details">
      <table>
        <tbody>
          <xsl:for-each select="$module-locations">
            <xsl:sort select="@fullName" data-type="text" order="ascending" />
            <xsl:variable name="location" select="@fullName"/>
            <xsl:variable name="sources" select="key('sources-by-fullname', $location)"/>
            <xsl:variable name="source-kpis" select="$sources/ancestor::Kpi"/>
            <xsl:variable name="source-metrics" select="$sources/ancestor::Metrics"/>
            <tr>
              <td>
                <div>
                  <a name="{@hash}"></a>
                  <div class="summary">
                    <xsl:apply-templates select="." mode="icon">
                      <xsl:with-param name="add-position">false</xsl:with-param>
                      <xsl:with-param name="position" select="position()"/>
                    </xsl:apply-templates>
                    <span class="sub">
                      <xsl:value-of select="concat('Provides data for ', count($source-kpis), ' KPI(s) in ', count($source-metrics), ' metrics point(s).')"/>
                    </span>
                  </div>
                  <div class="details sub">
                    <xsl:for-each select="$sources/ancestor::Metrics">
                      <xsl:variable name="metric" select="."/>
                      <xsl:apply-templates select="." mode="icon">
                        <xsl:with-param name="anchor">true</xsl:with-param>
                        <xsl:with-param name="element">div</xsl:with-param>
                      </xsl:apply-templates>
                      <div class="sub">
                        <xsl:call-template name="listItems">
                          <xsl:with-param name="items" select="$metric/descendant::Source[@fullName=$location]/ancestor::Kpi"/>
                          <xsl:with-param name="mode">ul</xsl:with-param>
                          <xsl:with-param name="show">name</xsl:with-param>
                          <xsl:with-param name="summaryText">KPI(s)</xsl:with-param>
                        </xsl:call-template>
                      </div>
                    </xsl:for-each>
                  </div>
                </div>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template name="buildMetricsTree">
    <hr/>
    <xsl:variable name="all-kpis" select="//Kpi"/>
    <xsl:variable name="all-metrics" select="//Metrics"/>
    <xsl:variable name="full-metrics" select="$all-kpis/ancestor::Metrics"/>
    <a name="Metrics"/>
    <div class="summary">
      <div class="heading">Metrics</div>
      <span>
        <xsl:value-of select="concat('Metrics has ', count($all-kpis), ' kpi(s) configured under ', count($full-metrics), ' metrics point(s).')"/>
      </span>
    </div>
    <div class="details">
      <table>
        <tbody>

          <xsl:for-each select="/Project/Metrics">
            <xsl:sort select="@fullName" data-type="text"/>
            <xsl:variable name="metric" select="."/>
            <xsl:variable name="kpis" select="Kpi"/>
            <xsl:variable name="sources" select="$metric/descendant::Source"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:variable name="locations" select="key('locations-by-fullname', $sources/@fullName)"/>
                <xsl:variable name="kpiSources" select="key('kpi-by-fullname', $kpis/descendant::KpiLink/@fullName)"/>
                <xsl:variable name="resolverSources" select="key('resolver-by-fullname', $kpis/descendant::ResolverLink/@fullName)"/>
                <xsl:variable name="metricsSources" select="($kpiSources | $resolverSources)/ancestor::Metrics[not(@fullName = $metric/@fullName)]"/>
                <xsl:variable name="all-locations" select="$locations | $metricsSources"/>
                <span>
                  <span class="summary">
                    <xsl:apply-templates select="." mode="icon"/>
                    <span class="sub">
                      <xsl:value-of select="concat(count($kpis), ' KPI(s) sourced from ', count($all-locations), ' location(s)')"/>
                    </span>
                  </span>
                  <div class="details sub">
                    <xsl:if test="count($all-locations) > 0">
                      <div class="collapsed sub">
                        <xsl:value-of select="concat(count($all-locations), ' source location(s)')"/>
                      </div>
                      <div>
                        <xsl:for-each select="$all-locations">
                          <xsl:sort select="@fullName"/>
                          <xsl:variable name="location" select="@fullName"/>
                          <xsl:apply-templates select="." mode="icon">
                            <xsl:with-param name="anchor">true</xsl:with-param>
                            <xsl:with-param name="element">div</xsl:with-param>
                          </xsl:apply-templates>
                          <div class="sub">
                            <xsl:call-template name="listItems">
                              <xsl:with-param name="items" select="$metric/descendant::Source[@fullName=$location]/ancestor::Kpi"/>
                              <xsl:with-param name="mode">ul</xsl:with-param>
                              <xsl:with-param name="show">name</xsl:with-param>
                              <xsl:with-param name="summaryText">KPI(s)</xsl:with-param>
                            </xsl:call-template>
                          </div>
                        </xsl:for-each>
                      </div>
                    </xsl:if>
                    <xsl:if test="count($kpis) > 0">
                      <div class="collapsed sub">
                        <xsl:value-of select="concat(count($kpis), ' KPI(s)')"/>
                      </div>
                      <div>
                        <table>
                          <tbody>
                            <xsl:for-each select="$kpis">
                              <tr>
                                <td>
                                  <a name="{@hash}"/>
                                  <xsl:apply-templates select="." mode="details">
                                    <xsl:sort select="@name"/>
                                  </xsl:apply-templates>
                                </td>
                              </tr>
                            </xsl:for-each>
                          </tbody>
                        </table>
                      </div>
                    </xsl:if>
                    <xsl:variable name="source-kpiLinks" select="key('kpiLink-by-fullname', $metric/descendant::Kpi/@fullName)"/>
                    <xsl:variable name="source-resolvers" select="key('resolverLink-by-fullname', $metric/descendant::Resolver/@fullName)"/>
                    <xsl:variable name="source-metrics" select="($source-kpiLinks | $source-resolvers)/ancestor::Metrics[not(@fullName = $metric/@fullName)]"/>
                    <xsl:variable name="source-kpis" select="($source-kpiLinks | $source-resolvers)[ancestor::Metrics[not(@fullName=$metric/@fullName)]]/ancestor-or-self::Kpi"/>
                    <xsl:if test="count($source-metrics) > 0">
                      <div class="collapsed sub">
                        <xsl:value-of select="concat('Provides data for ', count($source-kpis), ' KPI(s) in ', count($source-metrics), ' metrics point(s)')"/>
                      </div>
                      <div>
                        <xsl:for-each select="$source-metrics">
                          <xsl:sort select="@fullName"/>
                          <xsl:variable name="fullName" select="@fullName"/>
                          <xsl:apply-templates select="." mode="icon">
                            <xsl:with-param name="add-position">false</xsl:with-param>
                            <xsl:with-param name="anchor">true</xsl:with-param>
                          </xsl:apply-templates>
                          <div class="sub">
                            <xsl:call-template name="listItems">
                              <xsl:with-param name="items" select="($source-kpis)[ancestor::Metrics[@fullName=$fullName]]/ancestor-or-self::Kpi"/>
                              <xsl:with-param name="mode">ul</xsl:with-param>
                              <xsl:with-param name="summaryText">KPI(s)</xsl:with-param>
                              <xsl:with-param name="show">name</xsl:with-param>
                            </xsl:call-template>
                          </div>
                        </xsl:for-each>
                      </div>
                    </xsl:if>                    
                  </div>
                </span>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="Location|Metrics" mode="icon">
    <xsl:param name="add-position">false</xsl:param>
    <xsl:param name="position" select="position()"/>
    <xsl:param name="anchor">false</xsl:param>
    <xsl:param name="element">div</xsl:param>
    <xsl:variable name="module">
      <xsl:choose>
        <xsl:when test="contains(@type,'Downtime')">downtime</xsl:when>
        <xsl:when test="contains(@type,'Production')">production</xsl:when>
        <xsl:when test="contains(@type,'Quality')">quality</xsl:when>
        <xsl:when test="contains(@type,'Metrics')">metrics</xsl:when>
        <xsl:when test="contains(@type,'Energy')">energy</xsl:when>
        <xsl:when test="contains(@type,'Maintenance')">maintenance</xsl:when>
        <xsl:when test="contains(@type,'Knowledge')">knowledge</xsl:when>
        <xsl:when test="contains(@type,'Planning')">planning</xsl:when>
        <xsl:when test="contains(@type,'Cost')">cost</xsl:when>
        <xsl:when test="contains(@type,'View')">view</xsl:when>
        <xsl:otherwise>folder</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <xsl:if test="$add-position = 'true'">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$position"/>
        <xsl:text> - </xsl:text>
      </xsl:if>
      <img class="icon" alt="{$module}" src="images/16/{$module}.png" />
      <xsl:choose>
        <xsl:when test="$anchor='true'">
          <span class="item point">
            <a href="#{@hash}">
              <xsl:value-of select="@fullName"/>
            </a>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <span class="item point">
            <xsl:value-of select="@fullName"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Kpi" mode="details">
    <span class="kpi collapsed" title="Kpi">
      <xsl:value-of select="@name"/>
    </span>
    <xsl:variable name="formula" select="Formula"/>
    <div>
      <xsl:apply-templates select="$formula" mode="details"/>
      <table>
        <tbody>
          <tr>
            <xsl:apply-templates select="Resolver" mode="details">
              <xsl:sort select="string-length(substring-before($formula, @name))" order="ascending" data-type="number"/>
            </xsl:apply-templates>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template match="Formula" mode="details">
    <div class="formula" title="Formula">
      <xsl:text>Formula: </xsl:text>
      <xsl:value-of select="@name" />
      <xsl:text> = </xsl:text>
      <xsl:value-of select="."/>
    </div>
  </xsl:template>

  <xsl:template match="Resolver" mode="details">
    <td>
      <div class="resolver" title="Resolver">
        <span class="collapsed">
          <xsl:value-of select="@name"/>
        </span>
        <div>
        <xsl:apply-templates mode="details"/>
        </div>
      </div>
    </td>
  </xsl:template>

  <xsl:template match="KpiLink" mode="details">
    <xsl:variable name="kpi" select="key('kpi-by-fullname', @fullName)"/>
    <xsl:variable name="my-metrics" select="ancestor::Metrics"/>
    <xsl:choose>
      <xsl:when test="$my-metrics/@hash = $kpi/ancestor::Metrics/@hash">
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$kpi"/>
          <xsl:with-param name="mode">ul</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$kpi/ancestor::Metrics" mode="icon">
          <xsl:with-param name="anchor">true</xsl:with-param>
          <xsl:with-param name="element">div</xsl:with-param>
        </xsl:apply-templates>
        <div class="sub">
          <xsl:call-template name="listItems">
            <xsl:with-param name="items" select="$kpi"/>
            <xsl:with-param name="mode">ul</xsl:with-param>
          </xsl:call-template>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ResolverLink" mode="details">
    <xsl:variable name="resolver" select="key('resolver-by-fullname', @fullName)"/>
    <xsl:variable name="my-metrics" select="ancestor::Metrics"/>
    <xsl:choose>
      <xsl:when test="$my-metrics/@hash = $resolver/ancestor::Metrics/@hash">
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$resolver"/>
          <xsl:with-param name="mode">ul</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$resolver/ancestor::Metrics" mode="icon">
          <xsl:with-param name="anchor">true</xsl:with-param>
          <xsl:with-param name="element">li</xsl:with-param>
        </xsl:apply-templates>
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$resolver"/>
          <xsl:with-param name="mode">ul</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Constant" mode="details">
    <pre title="Constant"><xsl:value-of select="."/></pre>
  </xsl:template>

  <xsl:template match="Source" mode="details">
    <div title="{@fullName}">
      <xsl:apply-templates mode="details"/>
    </div>
  </xsl:template>

  <xsl:template match="Sql" mode="details">
    <xsl:element name="pre">
      <xsl:apply-templates/>
      <xsl:choose>
        <xsl:when test="where">
          <xsl:value-of select="$crlf"/>
          <xsl:text>and Location = </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>WHERE Location = </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>'</xsl:text>
      <xsl:value-of select="../@fullName"/>
      <xsl:text>'</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Sql/field" mode="details">
    <span class="field"><xsl:value-of select="."/></span>
  </xsl:template>

  <xsl:template name="showAll">
    <a href="#" class="summary show-all">Show All</a>
  </xsl:template>
  
  <xsl:template name="listItems">
    <xsl:param name="items"/>
    <!-- possible options include : 'csv', 'ul', 'div'-->
    <xsl:param name="mode">csv</xsl:param>
    <xsl:param name="summaryText"></xsl:param>
    <xsl:param name="show">name</xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($summaryText) > 0">
        <div class="summary">
          <xsl:value-of select="count($items)"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$summaryText"/>
        </div>
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$items"/>
          <xsl:with-param name="mode" select="$mode"/>
          <xsl:with-param name="class">details</xsl:with-param>
          <xsl:with-param name="show" select="$show"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$items"/>
          <xsl:with-param name="mode" select="$mode"/>
          <xsl:with-param name="show" select="$show"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="list">
    <xsl:param name="items"/>
    <!-- possible options include : 'csv', 'ul', 'div'-->
    <xsl:param name="mode">csv</xsl:param>
    <xsl:param name="class"></xsl:param>
    <!-- possible options include name, fullname-->
    <xsl:param name="show"></xsl:param>
    <xsl:choose>
      <xsl:when test="$mode='ul'">
        <ul>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="$show='fullName'">
                  <xsl:value-of select="@fullName"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <li>
              <a href="#{@hash}" title="{name()}">
                <xsl:value-of select="$text"/>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:when test="$mode='div'">
        <span>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="$show='fullName'">
                  <xsl:value-of select="@fullName"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <div>
              <a href="#{@hash}" title="{name()}">
                <xsl:value-of select="$text"/>
              </a>
            </div>
          </xsl:for-each>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="$show='fullName'">
                  <xsl:value-of select="@fullName"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="position() > 1">, </xsl:if>
            <a href="#{@hash}" title="{name()}">
              <xsl:value-of select="$text"/>
            </a>
          </xsl:for-each>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
