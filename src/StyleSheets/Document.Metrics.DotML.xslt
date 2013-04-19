<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

  <xsl:key name="sources-by-module" match="Resolver/Source" use="@module"/>
  <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
  <xsl:key name="sources-by-module-fullname-name" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', @name)"/>
  <xsl:key name="sources-by-module-fullname" match="Resolver/Source" use="concat(@module, '-', @fullName)"/>
  <xsl:key name="sources-by-module-fullname-sql" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', Sql)"/>
  <xsl:key name="kpis-by-id" match="Metrics/Kpi" use="@id"/>
  <xsl:key name="resolvers-by-id" match="Resolver" use="@id"/>
  
  <xsl:template match="/">
  	<dotml:graph file-name="metrics-graph" label="Metrics Model" rankdir="LR"  >
		<dotml:node id="metrics" label="Metrics Module"/>
		<xsl:apply-templates select="/Project/Metrics"/>
	</dotml:graph>
  </xsl:template>
	
  <xsl:template match="Metrics">
	<!-- <dotml:cluster id="cl_{@hash}" label="{@fullName}" style="dotted"> -->
		<dotml:node id="{@hash}" label="{@fullName}"/>
		<dotml:edge from="metrics" to="{@hash}"/>
		<xsl:apply-templates select="Kpi"/>
	<!-- </dotml:cluster> -->
  </xsl:template>
  
  <xsl:template match="Kpi">
	<xsl:variable name="kpi-hash" select="@hash"/>
    <dotml:cluster id="cl_{@kpi-hash}" style="dotted"> 
	<dotml:node id="{$kpi-hash}" label="{@name}" style="filled" fillcolor="#87D200"/>
	<dotml:record> 
		<xsl:for-each select="Resolver">
			<dotml:node id="{@hash}" label="{@name}" style="filled" fillcolor="#2FB4E9"/>
		</xsl:for-each>
	 </dotml:record>	
	 </dotml:cluster>
	<dotml:edge from="{../@hash}" to="{$kpi-hash}"/>
	<xsl:for-each select="Resolver">
		<dotml:edge from="{$kpi-hash}" to="{@hash}" style="dotted"/>
		<xsl:apply-templates select="KpiLink"/>
		<xsl:apply-templates select="ResolverLink"/>
	</xsl:for-each>
  </xsl:template>

  <xsl:template match="KpiLink">
	<xsl:variable name="parent" select=".."/>
	<xsl:variable name="kpi" select="key('kpis-by-id', @id)"/>
	<xsl:if test="$parent and $kpi">
		<dotml:edge from="{$parent/@hash}" to="{$kpi/@hash}" color="#2FB4E9"/>  
	</xsl:if>
  </xsl:template>

  <xsl:template match="ResolverLink">
	<xsl:variable name="parent" select=".."/>
	<xsl:variable name="resolver" select="key('resolvers-by-id', @id)"/>
	<xsl:if test="$parent and $resolver">
		<dotml:edge from="{$parent/@hash}" to="{$resolver/@hash}" color="#87D200"/>
	</xsl:if>
  </xsl:template>
  
  <!--
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  -->
</xsl:stylesheet>
