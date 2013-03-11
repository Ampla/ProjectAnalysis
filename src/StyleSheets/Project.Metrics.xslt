<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>
  <xsl:key name="items-by-fullname" match="Item" use="@fullName"/>
  <xsl:key name="resolvers-by-kpi" match="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']" use="Property[@name='KPIItem']"/>
  <xsl:key name="resolvers-by-variable" match="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']" use="Property[@name='VariableItem']"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Project">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="//Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']">
        <xsl:sort select="@fullName"/>
      </xsl:apply-templates>
      <xsl:variable name="all-resolvers" select="//Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
      <xsl:variable name="all-sources" select="key('items-by-fullname', $all-resolvers/Property[@name='SourceLocations']/linkFrom/link/@fullName)"/>
      <xsl:for-each select="$all-sources">
        <xsl:element name="Location">
          <xsl:apply-templates select="@*"/>
        </xsl:element>
      </xsl:for-each>
<!--
      <xsl:element name="Resolvers">
        <xsl:apply-templates select="//Item[@id and @type='Citect.Ampla.Metrics.Server.Resolvers.Resolver' and Property[@name='Action' and text()='Module']]">
          <xsl:sort select="@fullName"/>
        </xsl:apply-templates>
      </xsl:element>
-->
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.MetricsReportingPoint']">
    <xsl:element name="Metrics">
      <xsl:apply-templates select="@*"/>
      <!--  <xsl:apply-templates select="Property"/> -->
      <xsl:apply-templates select="Item[@name='Fields']/Item[@type='Citect.Ampla.Metrics.Server.KPI']">
        <xsl:sort select="@fullName"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']">
    <xsl:element name="Kpi">
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="formula" select="key('items-by-fullname', Property[@name='Formula'])"/>
      <xsl:if test="$formula">
        <xsl:element name="Formula">
          <xsl:apply-templates select="$formula/@name"/>
          <xsl:value-of select="$formula/Property[@name='Expression']"/>
        </xsl:element>
      </xsl:if>
      <!--  <xsl:apply-templates select="Property"/> -->
      <xsl:apply-templates select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']">
    <xsl:element name="Resolver">
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="resolver" select="."/>
      <xsl:choose>
        <xsl:when test="Property[@name='Action' and text()='Module']">
          <!-- Module -->
          <xsl:for-each select="Property[@name='SourceLocations']/linkFrom/link">
            <xsl:element name="Source">
              <xsl:attribute name="id">
                <xsl:value-of select="concat($resolver/@hash, @id)"/>
              </xsl:attribute>
              <xsl:apply-templates select="@hash" />
              <xsl:apply-templates select="@fullName"/>
              <!--              <xsl:apply-templates select="@*"/> -->
              <xsl:attribute name="name">
                <xsl:value-of select="$resolver/Property[@name='ResolverName']"/>
              </xsl:attribute>
              <xsl:attribute name="module">
                <xsl:value-of select="$resolver/Property[@name='Module']"/>
              </xsl:attribute>
              <xsl:element name="Sql">
                <xsl:element name="line">
                  <xsl:text>SELECT </xsl:text>
                  <xsl:element name="operation">
                    <xsl:value-of select="$resolver/Property[@name='ResolverOperation']"/>
                  </xsl:element>
                  <xsl:text>(</xsl:text>
                  <xsl:element name="field">
                    <xsl:value-of select="$resolver/Property[@name='SourceFieldName']"/>
                  </xsl:element>
                  <xsl:text>)</xsl:text>
                </xsl:element>
                <xsl:element name="line">
                  <xsl:text>FROM </xsl:text>
                  <xsl:text>{</xsl:text>
                  <xsl:value-of select="$resolver/Property[@name='Module']"/>
                  <xsl:text>}</xsl:text>
                </xsl:element>
                <xsl:choose>
                  <xsl:when test="$resolver/Property[@name='WhereCondition']">
                    <xsl:element name="line">
                      <xsl:element name="where">
                        <xsl:text>WHERE </xsl:text>
                        <xsl:value-of select="$resolver/Property[@name='WhereCondition']"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:when>
                </xsl:choose>
              </xsl:element>
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="Property[@name='Action' and text()='KPI']">
          <xsl:element name="KpiLink">
            <xsl:apply-templates select="$resolver/Property[@name='KpiItem']/linkFrom/link/@*"/>
            <xsl:attribute name="name">
              <xsl:value-of select="$resolver/Property[@name='ResolverName']"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:when test="Property[@name='Action' and text()='Resolver']">
          <xsl:element name="ResolverLink">
            <xsl:apply-templates select="$resolver/Property[@name='ResolverItem']/linkFrom/link/@*"/>
            <xsl:attribute name="name">
              <xsl:value-of select="$resolver/Property[@name='ResolverName']"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:when test="Property[@name='Action' and text()='Constant']">
          <xsl:element name="Constant">
            <xsl:value-of select="$resolver/Property[@name='ConstantItem']"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="Property[@name='Action' and text()='Variable']">
          <xsl:element name="Variable">
            <xsl:value-of select="$resolver/Property[@name='VariableItem']"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="Property[@name='Action']">
          <xsl:comment>
            <xsl:for-each select="$resolver/Property">
              <xsl:text>
</xsl:text>
              <xsl:value-of select="@name"/>
              <xsl:text> := </xsl:text>
              <xsl:value-of select="."/>
            </xsl:for-each>
          </xsl:comment>
        </xsl:when>                  
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
