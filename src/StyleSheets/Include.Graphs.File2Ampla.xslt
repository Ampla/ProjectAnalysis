<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

	<xsl:key name='source-fields-by-name' match="Property[@name='SourceFields']/Property/Item" use="Property[@name='Name']"/>
	<xsl:key name='destination-fields-by-name' match="Property[@name='DestinationFields']/Property/Item" use="Property[@name='Name']"/>
		
	<xsl:template match="Item[@type='Citect.Ampla.Plant2Business.Server.File2AmplaIntegration']" mode='include'>
		<xsl:text>Yes</xsl:text>
	</xsl:template>
	
	<xsl:template match="Item[@type='Citect.Ampla.Plant2Business.Server.File2AmplaIntegration']" mode='graph'>
		<xsl:param name="filename"><xsl:call-template name='get-dotml-filename'/></xsl:param>
				
				
				<!-- Property name="SourceDirectory">
                  <HistoricalExpressionConfig>
                    <ExpressionConfig format-->
					
		
		<xsl:variable name="source-dir">
			<xsl:call-template name="escape-label">
				<xsl:with-param name='label' select="Property[@name='SourceDirectory']/HistoricalExpressionConfig/ExpressionConfig/@format"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="destination" select="Property[@name='Location']/linkFrom/link/@fullName"/>
		<dotml:graph file-name="{$filename}" label="File2Ampla: {@fullName}" rankdir="LR" fontname="Arial" fontsize="12.0" labelloc='t' size="8,8">
			<dotml:cluster id="{concat(@hash, '_source')}" label="{concat('Source\n', $source-dir)}" style="solid" labelloc="t" >
				<dotml:record>
					<xsl:apply-templates select="Property[@name='SourceFields']/Property/Item"/>
				</dotml:record>
			</dotml:cluster>
			<dotml:cluster id="{concat(@hash, '_destination')}" label="{concat('Destination\n', $destination)}" style="solid" labelloc="t">
				<dotml:record>
					<xsl:apply-templates select="Property[@name='DestinationFields']/Property/Item" />
				</dotml:record>
			</dotml:cluster>
			<xsl:apply-templates select="Property[@name='FieldMappings']/Property/Item"/>
		</dotml:graph>
		
	</xsl:template>
	
	<xsl:template match="Property/Property/Item[@type='Citect.Ampla.Plant2Business.Mapping.AdapterField,Citect.Ampla.Plant2Business.Mapping']">
		<xsl:variable name="id" select="generate-id(.)"/>
		<xsl:variable name="label">
			<xsl:value-of select="Property[@name='Name']"/>
			<xsl:text> (</xsl:text>
				<xsl:value-of select="Property[@name='DataType']"/>
				<xsl:choose>
					<xsl:when test="Property[@name='DataType'] = 'DateTime'">
						<xsl:text> - </xsl:text>
						<xsl:value-of select="Property[@name='DateTimeMode']"/>
					</xsl:when>
				</xsl:choose>
			<xsl:text>) </xsl:text>
		</xsl:variable>
		<dotml:node id="{$id}" label="{$label}" shape='box'/>
	</xsl:template>
	
	<xsl:template match="Property/Property/Item[@type='Citect.Ampla.Plant2Business.Mapping.FieldMapping,Citect.Ampla.Plant2Business.Mapping']">
		<xsl:param name='parent' select='../../..'/>
		<xsl:variable name='source'>
			<xsl:value-of select="Property[@name='Source']"/>
		</xsl:variable>
		<xsl:variable name='target'>
			<xsl:value-of select="Property[@name='Target']"/>
		</xsl:variable>
		<xsl:variable name='from' select="generate-id($parent/Property[@name='SourceFields']/Property/Item[Property[@name='Name']=$source])"/>
		<xsl:variable name='to' select="generate-id($parent/Property[@name='DestinationFields']/Property/Item[Property[@name='Name']=$target])"/>
		<xsl:choose>
			<xsl:when test='$from and $to'>
				<dotml:edge from="{$from}" to="{$to}" />
			</xsl:when>
			<xsl:when test='$from'>
				<xsl:variable name='node' select="concat('error_', generate-id(.))" />
				<dotml:node id='{$node}' label="{Property[@name='Target']}" shape='box' color='{$red-color}' fontcolor='{$red-color}'/>
				<dotml:edge from="{$from}" to="{$node}"/>
			</xsl:when>
			<xsl:when test='$to'>
				<xsl:variable name='node' select="concat('error_', generate-id(.))" />
				<dotml:node id='{$node}' label="{Property[@name='Source']}" shape='box' color='{$red-color}' fontcolor='{$red-color}'/>
				<dotml:edge from="{$node}" to="{$to}" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name='source-node' select="concat('source_', generate-id(.))" />
				<xsl:variable name='target-node' select="concat('target_', generate-id(.))" />

				<dotml:node id='{$source-node}' label="{Property[@name='Source']}" shape='box' color='{$red-color}' fontcolor='{$red-color}'/>
				<dotml:node id='{$target-node}' label="{Property[@name='Target']}" shape='box' color='{$red-color}' fontcolor='{$red-color}'/>
				<dotml:edge from="{$source-node}" to="{$target-node}" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
