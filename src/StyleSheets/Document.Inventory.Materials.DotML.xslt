<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="record-color">#EEEEEE</xsl:variable>
	<xsl:variable name="border-color">#AAAAAA</xsl:variable>
	<xsl:variable name="background-color">#FFFFFF</xsl:variable>
	<xsl:variable name="material-color">#87D200</xsl:variable>
	<xsl:variable name="material-other">#CCCCCC</xsl:variable>
	<xsl:variable name="workcenter-color">#2FB4E9</xsl:variable>
  
  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
  <xsl:variable name="quote">'</xsl:variable>
  <xsl:variable name="dquote">"</xsl:variable>

	<xsl:key name="materials-by-hash" match="Material" use="@hash"/>
	<xsl:key name="movements-by-location" match="Movement" use="Location"/> 	  
	<xsl:key name="movements-by-source-material" match="Movement" use="Source/Material/@hash"/> 	  
	<xsl:key name="movements-by-destination-material" match="Movement" use="Destination/Material/@hash"/> 	  

	<xsl:key name="items-by-hash" match="Item" use="@hash"/>
	
  	<xsl:variable name="workcentres" select="/Inventory/Hierarchy/descendant::Item[not(Item)]"/>
    <xsl:variable name="clusters" select="/Inventory/Hierarchy/descendant::Item[Item]"/>
	<xsl:variable name="materials" select="//Material[generate-id() = generate-id(key('materials-by-hash', @hash)[1])]"/>
  
	<xsl:template match="/">
		<dotml:graph file-name="inventory-graph" label="Inventory Materials" rankdir="LR" fontname="Arial" fontsize="14.0">
			<xsl:for-each select="$materials">
				<xsl:sort select="@name"/>
				<xsl:variable name="material-hash" select="@hash"/>
				<dotml:cluster id="{concat($material-hash, '_cluster')}" label="{@name}" style="solid" bgcolor="{$material-color}" labelloc="t">
					<xsl:variable name='material' select="key('materials-by-hash', @hash)"/>
					<xsl:variable name='source-movements' select="key('movements-by-source-material', @hash)"/>
					<xsl:variable name='destination-movements' select="key('movements-by-destination-material', @hash)"/>
					<xsl:variable name='workcenter-hashs' 
										select="	  $source-movements/Source/WorkCenter/@hash 
													| $source-movements/Destination/WorkCenter/@hash
													| $destination-movements/Source/WorkCenter/@hash 
													| $destination-movements/Destination/WorkCenter/@hash"/>
					<xsl:variable name="workcenters" select="key('items-by-hash', $workcenter-hashs)"/>
					
					<xsl:variable name="other-materials" select="$source-movements/Destination/Material | $destination-movements/Source/Material"/>
					
					<xsl:call-template name="build-sub-hierarchy">
						<xsl:with-param name='context' select='/Inventory/Hierarchy/Item'/>
						<xsl:with-param name='children' select='$material | $workcenters | $other-materials'/>
						<xsl:with-param name='material-hash' select='@hash'/>
					</xsl:call-template>
				</dotml:cluster>
				
			</xsl:for-each>
			<!-- <dotml:node id="error" label="Error" /> -->
			<!--
			<xsl:apply-templates select="/Inventory/Hierarchy/Item"/>
			<xsl:apply-templates select="/Inventory/Movements/Movement"/>
			-->
		</dotml:graph>
	</xsl:template>
	  
	<xsl:template name="build-sub-hierarchy">
		<xsl:param name="context"/>
		<xsl:param name="children"/>
		<xsl:param name="material-hash"/>
		<xsl:variable name="selected" select="$children/ancestor-or-self::Item"/>
		<xsl:for-each select="$context">
			<xsl:sort select="@name"/>
			<xsl:variable name="item" select="."/>
			<xsl:variable name="hash" select="@hash"/>
			<xsl:choose>
				<xsl:when test="$selected[@hash = $hash]">
					<dotml:cluster id="{concat($material-hash, '_', @hash)}" label="{@name}" style="solid" bgcolor="{$background-color}" color="{$border-color}" fontsize="12.0"> 
						<xsl:call-template name="build-sub-hierarchy">
							<xsl:with-param name="context" select="$item/Item"/>
							<xsl:with-param name="children" select="$children"/>
							<xsl:with-param name="material-hash" select="$material-hash"/>
						</xsl:call-template>
						<xsl:if test="Materials/Material">
							<dotml:cluster id="{concat($material-hash, '_', @hash, '_cluster')}" style="filled" color="{$record-color}">
								<xsl:for-each select="Materials/Material">
									<xsl:variable name="color">
										<xsl:choose>
											<xsl:when test="@hash = $material-hash">
												<xsl:value-of select="$material-color"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$material-other"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<dotml:node id="{concat($material-hash, '_', $item/@hash, '_', @hash)}" label="{@name}" shape="box" style="filled" color="{$color}" fontsize="10.0"/>
								</xsl:for-each>
							</dotml:cluster>
						</xsl:if>
						<xsl:apply-templates select="key('movements-by-location', $item/@fullName)">
							<xsl:with-param name="material-hash" select="$material-hash"/>
						</xsl:apply-templates>
					</dotml:cluster>  
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
  
	<xsl:template name="material-hash">
		<xsl:param name="prefix"></xsl:param>
		<xsl:param name="wc-hash" select="../../@hash"/>
		<xsl:param name="mat-hash" select="@hash"/>
		<xsl:choose>
			<xsl:when test='$wc-hash'>
				<xsl:choose>
					<xsl:when test='$mat-hash'>
						<xsl:value-of select="concat($prefix, $wc-hash, '_', $mat-hash)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($prefix, $wc-hash)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'error'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template match="Movement">
		<xsl:param name='material-hash'/>
		<xsl:choose>
			<xsl:when test="(Source/Material[@hash = $material-hash]) or (Destination/Material[@hash=$material-hash])">
				<xsl:variable name="source-hash">
					<xsl:call-template name="material-hash">
						<xsl:with-param name='prefix' select="concat($material-hash, '_')"/>
						<xsl:with-param name="wc-hash" select="Source/WorkCenter/@hash"/>
						<xsl:with-param name="mat-hash" select="Source/Material/@hash"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="destination-hash">
					<xsl:call-template name="material-hash">
						<xsl:with-param name='prefix' select="concat($material-hash, '_')"/>
						<xsl:with-param name="wc-hash" select="Destination/WorkCenter/@hash"/>
						<xsl:with-param name="mat-hash" select="Destination/Material/@hash"/>
					</xsl:call-template>
				</xsl:variable>
				<dotml:edge from="{$source-hash}" to="{$destination-hash}" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
  
</xsl:stylesheet>
