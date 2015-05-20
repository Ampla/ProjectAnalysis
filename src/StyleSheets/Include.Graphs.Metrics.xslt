<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
		
	<xsl:key name="items-by-id" match="Item[@id]" use="@id"/>
	<xsl:key name="links-to-by-fullname" match="linkTo/link" use="@fullName"/>
	<xsl:key name="linkto-by-id-property" match="linkTo/link" use="concat(@id, '-', @property)"/>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode='include'>Yes</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode='get-png-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat('k_', ../../@hash, '_', $name, '.png')"/>
	</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode='graph'>
		<xsl:param name="filename"/>
		
		<dotml:graph file-name="{$filename}" label="Metrics: {@fullName}" rankdir="TB" fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:call-template name='traverse-kpi'>
				<xsl:with-param name='current' select='.'/>
			</xsl:call-template>
		</dotml:graph>
		
	</xsl:template>
	
	<!-- draws the kpis -->
	<xsl:template name='draw-kpis'>
		<xsl:param name='kpis'/>
		<!-- add nodes -->
		<xsl:for-each select='$kpis'>
			<!-- add Kpi nodes -->
			<xsl:variable name='kpi' select="."/>
			<dotml:node id="{$kpi/@hash}" label="{$kpi/@name}" 
				shape='box' style='filled' fillcolor='{$focus-color}' 
				fontname="{$fontname}" fontcolor="{$focus-text-color}" fontsize="{$font-size-h2}" />
			
			<xsl:variable name='formula' select="key('items-by-id', $kpi/Property[@name='Formula']/linkFrom/link/@id)"/>
			<xsl:variable name='resolvers' select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>

			<!-- add Formula nodes -->		
			<dotml:node id="{$formula/@hash}" label="{$formula/Property[@name='Expression']}" 
					shape='box' style='filled' fillcolor='{$material-color}' 
					fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}" />
	
			<xsl:for-each select='$resolvers'>
				<xsl:variable name='r' select='.'/>
				<!-- add Resolver nodes -->
				<xsl:variable name='action' select="$r/Property[@name='Action']"/>
				<xsl:variable name='fill-color'>
					<xsl:choose>
						<xsl:when test="$action='Module'"><xsl:value-of select='$workcenter-color'/></xsl:when>
						<xsl:otherwise><xsl:value-of select='$record-color'/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<dotml:node id="{$r/@hash}" label="{$r/@name}\n{$action}" 
							shape='box' style='filled' fillcolor='{$fill-color}' 
							fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h2}" />
			</xsl:for-each>		
		</xsl:for-each>	
		
		<!-- add edges -->
		<xsl:for-each select='$kpis'>
			<xsl:variable name='kpi' select="."/>
			<xsl:variable name='formula' select="key('items-by-id', $kpi/Property[@name='Formula']/linkFrom/link/@id)"/>
			<xsl:variable name='resolvers' select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
			
			<!-- kpi to formula edge -->
			<dotml:edge from="{$kpi/@hash}" to="{$formula/@hash}" color="{$material-color}" label='{$formula/@name}' 
				fontname="{$fontname}" fontcolor="{$material-color}" fontsize="{$font-size-h3}" />
				
			<!-- add formula to resolver edges -->
			<xsl:for-each select='$resolvers'>
				<xsl:variable name='r' select='.'/>
				<xsl:variable name='resolver-name' select="$r/Property[@name='ResolverName']"/>
				
				<!-- formula to resolver edge -->
				<dotml:edge from="{$formula/@hash}" to="{$r/@hash}" color="{$focus-color}" label="{$resolver-name}" 
							fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}" />
							
				<!-- find kpis that are referenced by the resolver -->
				<xsl:variable name='kpi-items' select="key('items-by-id', $r/Property[@name='KpiItem']/linkFrom/link/@id)"/>
				<xsl:variable name='resolver-kpis' select='$kpis[@id=$kpi-items/@id]'/>
											
				<xsl:for-each select='$resolver-kpis'>
					<xsl:variable name='k' select='.'/>
					<!-- add resolver to kpi edges -->
					<dotml:edge from="{$r/@hash}" to="{$k/@hash}" color="{$focus-color}" label="{$resolver-name}" 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}" />
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name='traverse-kpi'>
		<xsl:param name='kpis' select='/empty-node-set'/> <!-- A dummy empty node set-->
		<xsl:param name='current'/>
		<xsl:param name='depth'>0</xsl:param>
		
		<xsl:comment> Depth: <xsl:value-of select='$depth'/> adding : (<xsl:value-of select='count($current)'/>)
		<xsl:for-each select='$current'>
			<xsl:value-of select='@name'/><xsl:text>,</xsl:text>
		</xsl:for-each></xsl:comment>
		<xsl:choose>
			<xsl:when test='not($current)'>
				<!-- no more kpis to traverse so draw them -->
				<xsl:call-template name='draw-kpis'>
					<xsl:with-param name='kpis' select='$kpis'/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='$depth > 20'>
				<!-- stop if it goes too deep -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name='resolvers' select="$current/Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']"/>
				<xsl:variable name='resolver-kpis' select="key('items-by-id', $resolvers/Property[@name='KpiItem']/linkFrom/link/@id)"/>
				<xsl:call-template name='traverse-kpi'>
					<xsl:with-param name='kpis' select='$kpis | $current'/>
					<xsl:with-param name='current' select='$resolver-kpis'/>
					<xsl:with-param name='depth' select='$depth + 1'/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>	

	</xsl:template>
	

</xsl:stylesheet>
