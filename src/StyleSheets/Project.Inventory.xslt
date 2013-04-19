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

  <xsl:key name="movements-by-srce-wc" match="//Item[@type='Citect.Ampla.Isa95.MaterialMovementItem']" use="Property[@name='SourceWorkCenter']/linkFrom/link/@fullName" />
  <xsl:key name="movements-by-dest-wc" match="//Item[@type='Citect.Ampla.Isa95.MaterialMovementItem']" use="Property[@name='DestinationWorkCenter']/linkFrom/link/@fullName" />
  
  
  <xsl:template match="/">
    <xsl:element name="Inventory">
		<xsl:element name="Hierarchy">
			<xsl:call-template name="build-hierarchy">
				<xsl:with-param name="context" select="/Project/Item"/>
				<xsl:with-param name="children" select="$work-centres"/>
			</xsl:call-template>
		</xsl:element>	
		<xsl:element name="Movements">
			<xsl:apply-templates select="//Item[@type='Citect.Ampla.Isa95.MaterialMovementItem']"  />
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
		
		<xsl:variable name="source-wc" select="key('items-by-id', Property[@name='SourceWorkCenter']/linkFrom/link/@id)"/>
		<xsl:variable name="destination-wc" select="key('items-by-id', Property[@name='DestinationWorkCenter']/linkFrom/link/@id)"/>
		
		<xsl:element name="Location">
		
			<xsl:if test="$source-wc and $destination-wc">
				<xsl:call-template name="find-common-folder">
					<xsl:with-param name="a" select="$source-wc/ancestor-or-self::Item"/>
					<xsl:with-param name="b" select="$destination-wc/ancestor-or-self::Item"/>
				</xsl:call-template>
			</xsl:if>
		
		</xsl:element>
		
		<xsl:element name="Source">
			<xsl:element name="WorkCenter">
				<xsl:if test="$source-wc">
					<xsl:apply-templates select="$source-wc/@*"/>
				</xsl:if>
			</xsl:element>
			<xsl:element name="Material">
				<xsl:apply-templates select="key('items-by-id', Property[@name='SourceMaterial']/linkFrom/link/@id)/@*"/>
			</xsl:element>
		</xsl:element>
		<xsl:element name="Destination">
			<xsl:element name="WorkCenter">
				<xsl:if test="$destination-wc">
					<xsl:apply-templates select="$destination-wc/@*"/>
				</xsl:if>
			</xsl:element>
			<xsl:element name="Material">
				<xsl:apply-templates select="key('items-by-id', Property[@name='DestinationMaterial']/linkFrom/link/@id)/@*"/>
			</xsl:element>
		</xsl:element>
		
	</xsl:element>
  </xsl:template>
  
  
  <xsl:template name="find-common-folder">
	<xsl:param name="a"/>
	<xsl:param name="b"/>
	<xsl:param name="index">1</xsl:param>
	<xsl:choose>
		<xsl:when test="$index > count($a)"/>
		<xsl:when test="$index > count($b)"/>
		<xsl:when test="$a[$index] = $b[$index]">
			<xsl:if test="$index > 1">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:value-of select='$a[$index]/@name'/>
			<xsl:call-template name="find-common-folder">
				<xsl:with-param name="a" select="$a"/>
				<xsl:with-param name="b" select="$b"/>
				<xsl:with-param name="index" select="$index + 1"/>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
  </xsl:template>
 
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
