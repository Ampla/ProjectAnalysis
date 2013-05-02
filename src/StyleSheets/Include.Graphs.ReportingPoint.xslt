<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
		
	<xsl:key name="items-by-id" match="Item[@id]" use="@id"/>
	<xsl:key name="links-to-by-fullname" match="linkTo/link" use="@fullName"/>
	<xsl:key name="linkto-by-id-property" match="linkTo/link" use="concat(@id, '-', @property)"/>
	
	<xsl:template match="Item[@type='Citect.Ampla.Production.Server.ProductionReportingPoint']" mode='include'>Yes</xsl:template>

	<xsl:template match="Item[@type='Citect.Ampla.Production.Server.ProductionReportingPoint']" mode='graph'>
		<xsl:param name="filename"/>
		<xsl:variable name='full-name' select="@fullName"/>
		<xsl:variable name='rp' select="."/>
		<xsl:variable name='input-links' select="$rp/descendant::linkFrom/link[not(starts-with(@fullName, $full-name))]"/>
		<xsl:variable name='output-links' select="$rp/descendant::linkTo/link[not(starts-with(@fullName, $full-name))]"/>
		<xsl:variable name='inputs' select="key('items-by-id', $input-links/@id)"/>
		<xsl:variable name='outputs' select="key('items-by-id', $output-links/@id)"/>
		<dotml:graph file-name="{$filename}" label="Production: {@fullName}" rankdir="LR" fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h1}" labelloc='t' >
			
			<xsl:variable name='output-properties' select="$output-links[generate-id()=generate-id(key('linkto-by-id-property', concat(@id, '-', @property))[1])]"/>
			
			<xsl:call-template name='draw-focused-item'>
				<xsl:with-param name='item' select='.'/>
				<xsl:with-param name='input-properties' select='$input-links/ancestor::Property'/>
				<xsl:with-param name='output-properties' select="$output-properties"/>
			</xsl:call-template>
			
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
			
		</dotml:graph>
	</xsl:template>
		
	<xsl:template name='draw-focused-item'>
		<xsl:param name='item' select='.'/>
		<xsl:param name='input-properties' select="./Property"/>
		<xsl:param name='output-properties' select="./Property"/>
		<xsl:variable name='parent' select='$item/..'/>
		<dotml:cluster id='{$parent/@hash}' 
				label='{$parent/@fullName}' labeljust='l' labelloc="t" 
				style='filled' fillcolor='{$focus-bgcolor}' color="{$focus-color}" 
				fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h2}">
				
			<xsl:for-each select='$input-properties'>
				<dotml:node id='{@name}' shape="point" style='filled' fillcolor='{$focus-bgcolor}' color="{$focus-color}" />
			</xsl:for-each>
			
			<xsl:for-each select='$output-properties'>
				<dotml:node id='{@property}' shape="point" style='filled' fillcolor='{$focus-bgcolor}' color="{$focus-color}" />
			</xsl:for-each>
			
			<dotml:node id="{$item/@hash}" label="{$item/@name}" 
				shape='box' style='filled' fillcolor='{$focus-color}' 
				fontname="{$fontname}" fontcolor="{$focus-text-color}" fontsize="{$font-size-h2}" />
			
			<xsl:for-each select='$input-properties'>
				<dotml:edge from='{@name}' to="{$item/@hash}" dir='back' arrowtail="odot"  color="{$focus-color}" label='{@name}' 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}"/>
			</xsl:for-each>
			<xsl:for-each select='$output-properties'>
				<dotml:edge from="{$item/@hash}" to='{@property}'  arrowhead="odot"  color="{$focus-color}" label='{@property}' 
						fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h3}"/>
			</xsl:for-each>
		</dotml:cluster>
	</xsl:template>
	
</xsl:stylesheet>
