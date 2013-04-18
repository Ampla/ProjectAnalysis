<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
  <xsl:variable name="quote">'</xsl:variable>
  <xsl:variable name="dquote">"</xsl:variable>
  
  <xsl:variable name="workcentres" select="/Inventory/Hierarchy/descendant::Item[not(Item)]"/>
  <xsl:variable name="clusters" select="/Inventory/Hierarchy/descendant::Item[Item]"/>
  
  <xsl:template match="/">
  	<dotml:graph file-name="inventory-graph" label="Inventory Model" rankdir="TB">
		<dotml:node id="error" label="Error" />
		<xsl:apply-templates select="/Inventory/Hierarchy/Item"/>
		<xsl:apply-templates select="/Inventory/Movements/Movement"/>
	</dotml:graph>
	
  </xsl:template>
  
  <xsl:template match="Item[Item]">
	<dotml:cluster id="{@hash}" label="{@name}" style="dotted">
		<xsl:apply-templates select="Item">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>
	</dotml:cluster>
  </xsl:template>
  
  <xsl:template match="Item[Materials/Material]">
	<dotml:cluster id="{@hash}" label="{@name}">
		<dotml:record>
			<xsl:apply-templates select="Materials/Material">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</dotml:record>
	</dotml:cluster>
  </xsl:template>

    <xsl:template match="Material">
		<xsl:variable name="material-hash">
			<xsl:call-template name='material-hash'/>
		</xsl:variable>
	<dotml:node id="{$material-hash}" label="{@name}" style="dashed" fontsize="11.0"/>
  </xsl:template>
  
	<xsl:template name="material-hash">
		<xsl:param name="wc-hash" select="../../@hash"/>
		<xsl:param name="mat-hash" select="@hash"/>
		<xsl:choose>
			<xsl:when test='$wc-hash'>
				<xsl:choose>
					<xsl:when test='$mat-hash'>
						<xsl:value-of select="concat($wc-hash, '_', $mat-hash)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$wc-hash"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'error'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
  <xsl:template match="Item[not(Item) and not(Materials/Material)]">
	<dotml:node id="{@hash}" label="{@name}"/>
  </xsl:template>
  
  <xsl:template match="Movement">
	<xsl:variable name="source-hash">
		<xsl:call-template name="material-hash">
			<xsl:with-param name="wc-hash" select="Source/WorkCenter/@hash"/>
			<xsl:with-param name="mat-hash" select="Source/Material/@hash"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="destination-hash">
		<xsl:call-template name="material-hash">
			<xsl:with-param name="wc-hash" select="Destination/WorkCenter/@hash"/>
			<xsl:with-param name="mat-hash" select="Destination/Material/@hash"/>
		</xsl:call-template>
	</xsl:variable>
	<dotml:edge from="{$source-hash}" to="{$destination-hash}" label='{@name}'/>
  </xsl:template>
  
</xsl:stylesheet>
