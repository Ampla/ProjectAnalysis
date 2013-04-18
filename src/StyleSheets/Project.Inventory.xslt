<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>

  <xsl:variable name="wc-input" 			select="//Item[@type='Citect.Ampla.Isa95.InputWorkCenter']"/>
  <xsl:variable name="wc-output" 			select="//Item[@type='Citect.Ampla.Isa95.OutputWorkCenter']"/>
  <xsl:variable name="wc-processcell" 		select="//Item[@type='Citect.Ampla.Isa95.ProcessCell']"/>
  <xsl:variable name="wc-storagezone" 		select="//Item[@type='Citect.Ampla.Isa95.StorageZone']"/>
  <xsl:variable name="wc-productionunit" 	select="//Item[@type='Citect.Ampla.Isa95.ProductionUnit']"/>
  <xsl:variable name="wc-productionline" 	select="//Item[@type='Citect.Ampla.Isa95.ProductionLine']"/>
  <xsl:variable name="work-centres" 		select="$wc-input | $wc-output | $wc-processcell | $wc-storagezone | $wc-productionunit | $wc-productionline" />

  <xsl:template match="/">
    <xsl:element name="Inventory">
		<xsl:element name="Hierarchy">
			<xsl:call-template name="build-hierarchy">
				<xsl:with-param name="context" select="/Project/Item"/>
				<xsl:with-param name="children" select="$work-centres"/>
			</xsl:call-template>
		</xsl:element>	
		<xsl:element name="Movements">
			<xsl:apply-templates select="//Item[@type='Citect.Ampla.Isa95.MaterialMovementItem']"/>
		</xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="build-hierarchy">
	<xsl:param name="context"/>
	<xsl:param name="children"/>
	<xsl:variable name="selected" select="$children/ancestor-or-self::Item"/>
	<xsl:for-each select="$context">
		<xsl:variable name="item" select="."/>
		<xsl:variable name="hash" select="@hash"/>
		<xsl:choose>
			<xsl:when test="$selected[@hash = $hash]">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates select="Property[@name='AllowedMaterials']"/>
					<xsl:call-template name="build-hierarchy">
						<xsl:with-param name="context" select="$item/Item"/>
						<xsl:with-param name="children" select="$children"/>
					</xsl:call-template>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Not required: '<xsl:value-of select="@fullName"/></xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
  </xsl:template>
  
  <xsl:template match="Property[@name='AllowedMaterials']">
	<xsl:element name='Materials'>
		<xsl:apply-templates select="key('items-by-id', linkFrom/link/@id)"/>
	</xsl:element>
  </xsl:template>
  
  <xsl:template match="Item[@type='Citect.Ampla.Isa95.MaterialItem']">
	<xsl:element name="Material">
		<xsl:apply-templates select="@*"/>
	</xsl:element>
  </xsl:template>
  
  <xsl:template match="Item[@type='Citect.Ampla.Isa95.MaterialMovementItem']">
	<xsl:element name="Movement">
		<xsl:apply-templates select="@*"/>
		<xsl:element name="MovementDirection">
			<xsl:value-of select="Property[@name='MovementDirection']"/>
		</xsl:element>
		<xsl:element name="Source">
			<xsl:element name="WorkCenter">
				<xsl:apply-templates select="key('items-by-id', Property[@name='SourceWorkCenter']/linkFrom/link/@id)/@*"/>
			</xsl:element>
			<xsl:element name="Material">
				<xsl:apply-templates select="key('items-by-id', Property[@name='SourceMaterial']/linkFrom/link/@id)/@*"/>
			</xsl:element>
		</xsl:element>
		<xsl:element name="Destination">
			<xsl:element name="WorkCenter">
				<xsl:apply-templates select="key('items-by-id', Property[@name='DestinationWorkCenter']/linkFrom/link/@id)/@*"/>
			</xsl:element>
			<xsl:element name="Material">
				<xsl:apply-templates select="key('items-by-id', Property[@name='DestinationMaterial']/linkFrom/link/@id)/@*"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
