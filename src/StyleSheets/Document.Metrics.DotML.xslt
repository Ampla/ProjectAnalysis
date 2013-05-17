<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
				xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
				xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"				
				>
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

  <xsl:include href="Common.Graphs.DotML.xslt"/>
  
  	<!-- Default filenames -->
	<xsl:template match='Metrics[@hash]' mode='get-dotml-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.dotml')"/>
	</xsl:template>

	<xsl:template match='Metrics[@hash]' mode='get-gv-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.gv')"/>
	</xsl:template>

	<xsl:template match='Metrics[@hash]' mode='get-png-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.png')"/>
	</xsl:template>

	<xsl:template match='Metrics[@hash]' mode='get-cmd-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.cmd')"/>
	</xsl:template>

	<!-- default graph type-->
	<xsl:template match='Metrics[@hash]' mode='graph-type'>dot</xsl:template>
	<!-- default graph options-->
	<xsl:template match='Metrics[@hash]' mode='graph-options'></xsl:template>

	<xsl:key name="sources-by-module" match="Resolver/Source" use="@module"/>
    <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
	<xsl:key name="sources-by-module-fullname-name" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', @name)"/>
	<xsl:key name="sources-by-module-fullname" match="Resolver/Source" use="concat(@module, '-', @fullName)"/>
	<xsl:key name="sources-by-module-fullname-sql" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', Sql)"/>
	<xsl:key name="kpis-by-id" match="Metrics/Kpi" use="@id"/>
	<xsl:key name="resolvers-by-id" match="Resolver" use="@id"/>
  
  	<xsl:template match="/">
		<xsl:element name="Graphs">
			<xsl:for-each select="/Project/Metrics">
				<xsl:variable name='filename'>
					<xsl:apply-templates select='.' mode='get-dotml-filename'/>
				</xsl:variable>
				<xsl:comment><xsl:value-of select="concat($filename, ': ', @fullName)"/></xsl:comment>
				<exsl:document href="{concat('Graphs\', $filename)}" method="xml" indent="yes">
					<xsl:apply-templates select='.' mode='graph'>
						<xsl:with-param name='filename' select='$filename'/>
					</xsl:apply-templates>
				</exsl:document>
				<xsl:call-template name='output-cmd'/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match='Metrics' mode='include'><xsl:text>Yes</xsl:text></xsl:template>

	<xsl:template match="Metrics" mode='graph'>
		<xsl:param name="filename"/>
	
<!--	
		<xsl:variable name="source-dir">
			<xsl:call-template name="escape-label">
				<xsl:with-param name='label' select="Property[@name='SourceDirectory']/HistoricalExpressionConfig/ExpressionConfig/@format"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="destination" select="Property[@name='Location']/linkFrom/link/@fullName"/>
	-->
		<dotml:graph file-name="{$filename}" label="Metrics: {@fullName}" rankdir="LR" fontname="Arial" fontsize="12.0" labelloc='t' size="8,8">
			<dotml:node id="{@hash}" label="{@fullName}"/>
			
			<xsl:apply-templates select="Kpi"/>
			
		</dotml:graph>
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
