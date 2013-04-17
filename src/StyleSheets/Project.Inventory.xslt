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
  
  <xsl:template name="workcentres">
	<work-centres>
		<xsl:for-each select="$work-centres">
			<xsl:sort select="@fullName"/>
			<xsl:element name="workcentre">
				<xsl:apply-templates select="@*"/>
				<xsl:attribute name='group'><xsl:value-of select="../@fullName"/></xsl:attribute>
			</xsl:element>
		</xsl:for-each>
	</work-centres>

 </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
