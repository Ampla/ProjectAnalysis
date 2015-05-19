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
		<xsl:value-of select="concat('k_', $name, '.png')"/>
	</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode='graph'>
		<xsl:param name="filename"/>
		
		<dotml:graph file-name="{$filename}" label="Metrics: {@fullName}" rankdir="TB" fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='.' mode='kpi'/>
		</dotml:graph>
		
	</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.KPI']" mode='kpi'>
		<xsl:param name='resolver'/>
		<xsl:param name='visited' select='/Project[1]'/>
		<xsl:variable name='kpi' select="."/>
		<xsl:variable name='rp' select="$kpi/../.."/>
		
		<xsl:variable name='already-visited'>
			<xsl:call-template name='calculate-visited'>
				<xsl:with-param name='visited' select='$visited'/>
				<xsl:with-param name='this' select='.'/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test='$already-visited = 1'/>
			<xsl:otherwise>
				<xsl:call-template name='item-node'>
					<xsl:with-param name='item' select='$kpi'/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test='$resolver'>
						<dotml:edge from="{$resolver/@hash}" to="{$kpi/@hash}" color="{$focus-color}" />
						<!--label="{$item/Property[@name='ResolverName']}" 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}" -->
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
				<xsl:apply-templates select="key('items-by-id', $kpi/Property[@name='Formula']/linkFrom/link/@id)" mode='kpi'>
					<xsl:with-param name='kpi' select='$kpi'/>
					<xsl:with-param name='visited' select='$visited | $kpi'/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']" mode='kpi'>
					<xsl:with-param name='kpi' select='$kpi'/>
					<xsl:with-param name='visited' select='$visited | $kpi'/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name='calculate-visited'>
		<xsl:param name='visited'/>
		<xsl:param name='this'/>
		<xsl:choose>
			<xsl:when test='not($visited)'>0</xsl:when>
			<xsl:when test="count($visited | $this) = count($visited)">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name='item-node'>
		<xsl:param name='item'/>
		<dotml:node id="{$item/@hash}" label="{$item/@name}" 
				shape='box' style='filled' fillcolor='{$focus-color}' 
				fontname="{$fontname}" fontcolor="{$focus-text-color}" fontsize="{$font-size-h2}" />
	</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.Resolvers.Resolver']" mode='kpi'>
		<xsl:param name='kpi'/>
		<xsl:param name='visited'/>
		
		<xsl:variable name='already-visited'>
			<xsl:call-template name='calculate-visited'>
				<xsl:with-param name='visited' select='$visited'/>
				<xsl:with-param name='this' select='.'/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test='$already-visited = 1'/>
			<xsl:otherwise>
				<xsl:variable name='item' select='.'/>
				<dotml:node id="{$item/@hash}" label="{$item/@name}\n{$item/Property[@name='Action']}" 
						shape='box' style='filled' fillcolor='{$record-color}' 
						fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h2}" />
				<xsl:choose>
					<xsl:when test='$kpi'>
						<dotml:edge from="{$kpi/@hash}" to="{$item/@hash}" color="{$focus-color}" label="{$item/Property[@name='ResolverName']}" 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}" />
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
				
				<xsl:apply-templates select="key('items-by-id', $item/Property[@name='KpiItem']/linkFrom/link/@id)" mode='kpi'>
					<xsl:with-param name='resolver' select='$item'/>
					<xsl:with-param name='visited' select='$visited | $item'/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="Item[@type='Citect.Ampla.Metrics.Server.Formula']" mode='kpi'>
		<xsl:param name='kpi'/>
		<xsl:param name='visited'/> 
				<xsl:variable name='already-visited'>
			<xsl:call-template name='calculate-visited'>
				<xsl:with-param name='visited' select='$visited'/>
				<xsl:with-param name='this' select='.'/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test='$already-visited = 1'/>
			<xsl:otherwise>
				<xsl:variable name='item' select='.'/>
				<dotml:node id="{$item/@hash}" label="{$item/@name}\n{$item/Property[@name='Expression']}" 
						shape='box' style='filled' fillcolor='{$material-color}' 
						fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}" />
				<xsl:choose>
					<xsl:when test='$kpi'>
						<dotml:edge from="{$kpi/@hash}" to="{$item/@hash}" color="{$material-color}" label='Formula' 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}" />
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
</xsl:stylesheet>
