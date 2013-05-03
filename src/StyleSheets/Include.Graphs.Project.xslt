<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
	<xsl:key name='items-by-id' match="Item[@id]" use="@id"/>
	
	<xsl:template match="Item[@type='Citect.Ampla.General.Server.SystemConfiguration']" mode='include'>Yes</xsl:template>
	<xsl:template match="Item[@type='Citect.Ampla.General.Server.SystemConfiguration']" mode='graph-type'>sfdp</xsl:template>
	<xsl:template match="Item[@type='Citect.Ampla.General.Server.SystemConfiguration']" mode='graph-options'> -Goverlap=prism </xsl:template>

	<xsl:template match="Item[@type='Citect.Ampla.General.Server.SystemConfiguration']" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="Project diagram" rankdir="TB" fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h1}" labelloc='t' >
<!--
			<xsl:apply-templates select="/Project/Item[@hash]" mode='project-nodes'/>
			<xsl:apply-templates select="/Project/Item/Item[@hash]" mode='project-item-links'/>
		-->	
			
			<xsl:for-each select="key('items-by-id', //linkFrom/link/@id) | key('items-by-id', //linkTo/link/@id)">
				<xsl:variable name='item' select='.'/>
				<dotml:node id="{$item/@hash}" label="{$item/@name}" color='{$other-color}' shape="box" fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}"/>
			</xsl:for-each>
			
			<xsl:for-each select='//linkFrom/link'>
				<xsl:variable name='item' select='../../..'/>
				<xsl:variable name='to' select="key('items-by-id', @id)"/>
				<xsl:if test='string-length($item/@hash) > 0 and string-length($to/@hash)> 0'>
					<dotml:edge from="{$item/@hash}" to='{$to/@hash}' color='{$other-color}' />
				</xsl:if>
			</xsl:for-each>
			
<!--			<xsl:apply-templates select="//linkTo/link" mode='link-nodes'/>
			<xsl:apply-templates select="/Project/Item[@hash]" mode='project-nodes'/>
			<xsl:apply-templates select="/Project/Item/Item[@hash]" mode='project-item-links'/>
-->		
<!--		
			<xsl:for-each select='$input-links'>
				<xsl:variable name='item' select="key('items-by-id', @id)"/>
				<dotml:node id="{$item/@hash}" label="{$item/@fullName}" color='{$other-color}' style="solid" shape="box" fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}"/>
				<dotml:edge from="{$item/@hash}" to="{./ancestor::Property/@name}" />
			</xsl:for-each>
			
			<xsl:for-each select='$output-links'>
				<xsl:variable name='item' select="key('items-by-id', @id)"/>
				<dotml:node id="{$item/@hash}" label="{$item/@fullName}" color='{$other-color}' style="solid" shape="box" fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}"/>
				<dotml:edge from="{./@property}" to="{$item/@hash}" />
			</xsl:for-each>
-->			
		</dotml:graph>
	</xsl:template>

	<xsl:template match='linkTo/link' mode='link-nodes'>
		<dotml:node id="{@hash}" label="{@name}" color='{$other-color}' shape="point" />
	</xsl:template>

	
	<xsl:template match='Item[@id]' mode='project-nodes'>
		<dotml:node id="{@hash}" label="{@name}" color='{$other-color}' style="solid" shape="box" fontname="{$fontname}" fontcolor="{$other-color}" fontsize="{$font-size-h3}" />
		<xsl:apply-templates select="Item[@id]" mode='project-nodes'/>
	</xsl:template>

	<xsl:template match='Item/Item[@id]' mode='project-item-links'>
		<dotml:edge from="{../@hash}" to="{@hash}" color='{$other-color}' />
		<xsl:apply-templates select="Item[@id]" mode='project-item-links'/>
	</xsl:template>
	
</xsl:stylesheet>
