<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>

  <xsl:key name="sources-by-module" match="Resolver/Source" use="@module"/>
  <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
  <xsl:key name="sources-by-module-fullname-name" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', @name)"/>
  <xsl:key name="sources-by-module-fullname" match="Resolver/Source" use="concat(@module, '-', @fullName)"/>
  <xsl:key name="sources-by-module-fullname-sql" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', Sql)"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Project">
    <xsl:element name="map">
      <xsl:attribute name="version">0.8.1</xsl:attribute>
      <xsl:comment>To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net</xsl:comment>
      <xsl:element name="node">
 <!--       <xsl:attribute name="CREATED">1258698778972</xsl:attribute> -->
        <xsl:attribute name="ID">
          <xsl:value-of select="Project"/>
        </xsl:attribute>
<!--        <xsl:attribute name="MODIFIED">1258698778972</xsl:attribute> -->
        <xsl:attribute name="TEXT">Metrics</xsl:attribute>

        <xsl:call-template name="addMetricsSources"/>
        <xsl:call-template name="addMetricsData"/>
      </xsl:element>
    </xsl:element>
    <!--
    
    <map version="0.8.1">
    <node CREATED="1258698778972" ID="Freemind_Link_1641322232" MODIFIED="1258698790263" TEXT="Ampla Project">
      <node CREATED="1258698797603" ID="_" MODIFIED="1258698799720" POSITION="right" TEXT="Enterprise">
        <node CREATED="1258698800577" ID="Freemind_Link_1584846096" MODIFIED="1258698802000" TEXT="Site">
          <node CREATED="1258698803120" ID="Freemind_Link_715358323" MODIFIED="1258698804034" TEXT="Area">
            <node CREATED="1258698807846" ID="Freemind_Link_317860623" MODIFIED="1258698809695" TEXT="Downtime"/>
            <node CREATED="1258698812829" ID="Freemind_Link_274599653" MODIFIED="1258698816215" TEXT="Metrics"/>
          </node>
        </node>
      </node>
    </node>
    </map>
    -->
  </xsl:template>

  <xsl:template name="addMetricsSources">
    <xsl:element name="node">
      <xsl:attribute name="ID">metrics_sources</xsl:attribute>
      <xsl:attribute name="FOLDED">true</xsl:attribute>
      <xsl:attribute name="TEXT">Sources</xsl:attribute>
      <xsl:variable name="modules" select="//Source[generate-id() = generate-id(key('sources-by-module', @module)[1])]"/>
      <xsl:for-each select="$modules">
        <xsl:sort select="@module"/>
        <xsl:variable name="module" select="@module"/>
        <xsl:element name="node">
          <xsl:attribute name="ID">
            <xsl:value-of select="$module"/>
          </xsl:attribute>
<!--      
          <xsl:attribute name="FOLDED">true</xsl:attribute> 
-->
          <xsl:attribute name="TEXT">
            <xsl:value-of select="$module"/>
          </xsl:attribute>
          <xsl:call-template name="addModule">
            <xsl:with-param name="module" select="$module"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="addModule">
    <xsl:param name="module"></xsl:param>
    <xsl:variable name="locations" select="key('sources-by-module', $module)[generate-id()=generate-id(key('sources-by-module-fullname', concat(@module, '-', @fullName))[1])]"/>
    <xsl:comment>Locations = <xsl:value-of select="count($locations)"/>
  </xsl:comment>
    <xsl:for-each select="$locations">
      <xsl:sort select="@fullName"/>
      <xsl:element name="node">
        <xsl:attribute name="ID">
          <xsl:value-of select="concat($module,'_', @id)"/>
        </xsl:attribute>
<!--      
        <xsl:attribute name="FOLDED">true</xsl:attribute> 
-->
        <xsl:attribute name="TEXT">
          <xsl:value-of select="@fullName"/>
        </xsl:attribute>
        <xsl:call-template name="addSources">
          <xsl:with-param name="module" select="$module"/>
          <xsl:with-param name="location" select="@fullName"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="addSources">
    <xsl:param name="module"></xsl:param>
    <xsl:param name="location"></xsl:param>
    <xsl:variable name="names" select="key('sources-by-module-fullname', concat($module, '-', $location))[generate-id()=generate-id(key('sources-by-module-fullname-name', concat(@module, '-', @fullName, '-', @name))[1])]"/>
    <xsl:for-each select="$names">
      <xsl:sort select="@name"/>
      <xsl:element name="node">
        <xsl:attribute name="ID">
          <xsl:value-of select="concat('name', generate-id())"/>
        </xsl:attribute>
        <xsl:attribute name="FOLDED">true</xsl:attribute>
        <xsl:attribute name="TEXT">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:variable name="sources" select="key('sources-by-module-fullname-name', concat(@module, '-', @fullName, '-', @name))"/>
        <xsl:for-each select="$sources">
          <xsl:sort select="Sql"/>
          <xsl:element name="node">
            <xsl:attribute name="ID">
              <xsl:value-of select="concat('source_', @id)"/>
            </xsl:attribute>
            <xsl:attribute name="FOLDED">true</xsl:attribute>
            <xsl:attribute name="TEXT">
              <xsl:value-of select="Sql"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="addMetricsData">
    <xsl:element name="node">
      <xsl:attribute name="ID">metrics_data</xsl:attribute>
      <xsl:attribute name="FOLDED">true</xsl:attribute>
      <xsl:attribute name="TEXT">Metrics</xsl:attribute>
      <xsl:for-each select="//Metrics">
        <xsl:sort select="@fullName"/>
        <xsl:element name="node">
          <xsl:attribute name="ID">
            <xsl:value-of select="@hash"/>
          </xsl:attribute>
          <xsl:attribute name="FOLDED">true</xsl:attribute>
          <xsl:attribute name="TEXT">
            <xsl:value-of select="@fullName"/>
          </xsl:attribute>
          <xsl:apply-templates select="Kpi">
            <xsl:sort select="@fullName"/>
          </xsl:apply-templates>
        </xsl:element>
    </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Kpi">
    <xsl:element name="node">
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('kpi_',@id)"/>
      </xsl:attribute>
      <xsl:attribute name="FOLDED">true</xsl:attribute>
      <xsl:attribute name="TEXT">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:apply-templates select="Formula"/>
      <xsl:apply-templates select="Resolver"/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="Formula">
    <xsl:element name="node">
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('formula_',../@hash)"/>
      </xsl:attribute>
      <xsl:attribute name="TEXT">
        <xsl:value-of select="concat('{', @name, '}', $crlf, .)"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Resolver">
    <xsl:element name="node">
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('resolver_', @id)"/>
      </xsl:attribute>
      <xsl:attribute name="TEXT">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:apply-templates select="KpiLink"/>
      <xsl:apply-templates select="ResolverLink"/>
      <xsl:apply-templates select="Source"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="KpiLink">
    <!-- 
    <arrowlink COLOR="#3333ff" DESTINATION="Freemind_Link_436868227" ENDARROW="Default" ENDINCLINATION="215;0;" ID="Freemind_Arrow_Link_1144787000" STARTARROW="None" STARTINCLINATION="215;0;"/>

    -->
    <xsl:element name="arrowlink">
      <xsl:attribute name="COLOR">#3333ff</xsl:attribute>
      <xsl:attribute name="DESTINATION">
        <xsl:value-of select="concat('kpi_',@id)"/>
      </xsl:attribute>
      <xsl:attribute name="ENDARROW">Default</xsl:attribute>
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('k_', @id)"/>
      </xsl:attribute>
      <xsl:attribute name="STARTARROW">None</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ResolverLink">
    <!-- 
    <arrowlink COLOR="#3333ff" DESTINATION="Freemind_Link_436868227" ENDARROW="Default" ENDINCLINATION="215;0;" ID="Freemind_Arrow_Link_1144787000" STARTARROW="None" STARTINCLINATION="215;0;"/>

    -->
    <xsl:element name="arrowlink">
      <xsl:attribute name="COLOR">#ff3333</xsl:attribute>
      <xsl:attribute name="DESTINATION">
        <xsl:value-of select="concat('resolver_',@id)"/>
      </xsl:attribute>
      <xsl:attribute name="ENDARROW">Default</xsl:attribute>
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('r_', @id)"/>
      </xsl:attribute>
      <xsl:attribute name="STARTARROW">None</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Source">
    <!-- 
    <arrowlink COLOR="#3333ff" DESTINATION="Freemind_Link_436868227" ENDARROW="Default" ENDINCLINATION="215;0;" ID="Freemind_Arrow_Link_1144787000" STARTARROW="None" STARTINCLINATION="215;0;"/>

    -->
    <xsl:element name="arrowlink">
      <xsl:attribute name="COLOR">#33ff33</xsl:attribute>
      <xsl:attribute name="DESTINATION">
        <xsl:value-of select="concat('source_',@id)"/>
      </xsl:attribute>
      <xsl:attribute name="ENDARROW">Default</xsl:attribute>
      <xsl:attribute name="ID">
        <xsl:value-of select="concat('slink_', @id)"/>
      </xsl:attribute>
      <xsl:attribute name="STARTARROW">None</xsl:attribute>
    </xsl:element>
  </xsl:template>



  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
