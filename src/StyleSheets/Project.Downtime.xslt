<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>

  <xsl:variable name="comma">,</xsl:variable>
  <xsl:variable name="semi-colon">;</xsl:variable>
  <xsl:variable name="no-effect">&lt;NULL&gt;</xsl:variable>

  <xsl:key name="causes-by-id" match="Item[@type='Citect.Ampla.General.Server.CauseCode']" use="Property[@name='CauseCodeID']"/>
  <xsl:key name="causes-by-name" match="Item[@type='Citect.Ampla.General.Server.CauseCode']" use="@name"/>

  <xsl:key name="classifications-by-id" match="Item[@type='Citect.Ampla.General.Server.Classification']" use="Property[@name='ClassificationID']"/>
  <xsl:key name="classifications-by-name" match="Item[@type='Citect.Ampla.General.Server.Classification']" use="@name"/>

  <xsl:key name="effects-by-id" match="Item[@type='Citect.Ampla.General.Server.Effect']" use="Property[@name='EffectID']"/>
  <xsl:key name="effects-by-name" match="Item[@type='Citect.Ampla.General.Server.Effect']" use="@name"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Project">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="buildCauseCodes"/>
      <xsl:call-template name="buildClassifications"/>
      <xsl:call-template name="buildEffects"/>
      <xsl:call-template name="buildEquipmentTypes"/>
      <xsl:call-template name="buildLocations"/>
      <xsl:call-template name="buildDowntimePoints"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="buildCauseCodes">
    <xsl:element name="Causes">
      <xsl:for-each select="//Item[@type='Citect.Ampla.General.Server.CauseCode']">
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
        <xsl:sort select="@name"/>
        <xsl:element name="Cause">
          <xsl:apply-templates select="@hash"/>
          <xsl:apply-templates select="@name"/>
          <xsl:apply-templates select="@translation"/>
          <xsl:apply-templates select="@fullName"/>
          <xsl:apply-templates select="@id"/>
          <xsl:attribute name="cause">
            <xsl:choose>
              <xsl:when test="Property[@name='CauseCodeID']">
                <xsl:value-of select="Property[@name='CauseCodeID']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>none</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="same-names" select="key('causes-by-name', @name)"/>
          <xsl:variable name="same-ids" select="key('causes-by-id', Property[@name='CauseCodeID'])"/>

          <xsl:if test="count($same-names) > 1">
            <xsl:element name="Message">
              <xsl:attribute name="text">
                <xsl:text>Duplicate cause: </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:value-of select="concat(' ', count($same-names), ' causes')"/>
              </xsl:attribute>
              <xsl:attribute name="level">error</xsl:attribute>
            </xsl:element>
          </xsl:if>

          <xsl:if test="count($same-ids) > 1">
            <xsl:element name="Message">
              <xsl:attribute name="text">
                <xsl:text>Duplicate Cause Code Id: </xsl:text>
                <xsl:value-of select="Property[@name='CauseCodeID']"/>
                <xsl:value-of select="concat(' ', count($same-ids), ' causes')"/>
              </xsl:attribute>
              <xsl:attribute name="level">error</xsl:attribute>
            </xsl:element>
          </xsl:if>

        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="buildClassifications">
    <xsl:element name="Classifications">
      <xsl:for-each select="//Item[@type='Citect.Ampla.General.Server.Classification']">
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
        <xsl:sort select="@name"/>
        <xsl:element name="Classification">
          <xsl:apply-templates select="@hash"/>
          <xsl:apply-templates select="@name"/>
          <xsl:apply-templates select="@translation"/>
          <xsl:apply-templates select="@fullName"/>
          <xsl:apply-templates select="@id"/>
          <xsl:attribute name="classification">
            <xsl:choose>
              <xsl:when test="Property[@name='ClassificationID']">
                <xsl:value-of select="Property[@name='ClassificationID']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>none</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="same-names" select="key('classifications-by-name', @name)"/>
          <xsl:variable name="same-ids" select="key('classifications-by-id', Property[@name='ClassificationID'])"/>

          <xsl:if test="count($same-names) > 1">
            <xsl:element name="Message">
              <xsl:attribute name="text">
                <xsl:text>Duplicate classification: </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:value-of select="concat(' ', count($same-names), ' classifications')"/>
              </xsl:attribute>
              <xsl:attribute name="level">error</xsl:attribute>
            </xsl:element>
          </xsl:if>

          <xsl:if test="count($same-ids) > 1">
            <xsl:element name="Message">
              <xsl:attribute name="text">
                <xsl:text>Duplicate Classification Id: </xsl:text>
                <xsl:value-of select="Property[@name='ClassificationID']"/>
                <xsl:value-of select="concat(' ', count($same-ids), ' classifications')"/>
              </xsl:attribute>
              <xsl:attribute name="level">error</xsl:attribute>
            </xsl:element>
          </xsl:if>
          
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="buildEffects">
    <xsl:element name="Effects">
      <xsl:for-each select="//Item[@type='Citect.Ampla.General.Server.Effect']">
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
        <xsl:sort select="@name"/>
        <xsl:element name="Effect">
          <xsl:apply-templates select="@hash"/>
          <xsl:apply-templates select="@name"/>
          <xsl:apply-templates select="@translation"/>
          <xsl:apply-templates select="@fullName"/>
          <xsl:apply-templates select="@id"/>
          <xsl:attribute name="effect">
            <xsl:choose>
              <xsl:when test="Property[@name='EffectID']">
                <xsl:value-of select="Property[@name='EffectID']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>none</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="Property[@name='EffectMask']">
            <xsl:attribute name="mask">
              <xsl:value-of select="Property[@name='EffectMask']"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!-- 
        <Item name="Pumps" id="37e7dc2e-4244-4aad-8629-b7d1369658d8" reference="Citect.Ampla.General.Server" type="Citect.Ampla.General.Server.EquipmentType">
        <Property name="DisplayOrder">-1000</Property>
        <Property name="DisplayOrderGroup">4</Property>
        <Property name="RelationshipMatrix">280,4,&lt;NULL&gt;;285,4,&lt;NULL&gt;;290,4,&lt;NULL&gt;;295,4,&lt;NULL&gt;;300,4,&lt;NULL&gt;;305,4,&lt;NULL&gt;;480,4,&lt;NULL&gt;;485,4,&lt;NULL&gt;;490,4,&lt;NULL&gt;;495,4,&lt;NULL&gt;;565,4,&lt;NULL&gt;</Property>
        <Property name="StartupMode">Manual</Property>
      </Item>
  -->
  <xsl:template name="buildEquipmentTypes">
    <xsl:element name="EquipmentTypes">
      <xsl:for-each select="//Item[@type='Citect.Ampla.General.Server.EquipmentType']">
        <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
        <xsl:sort select="@name"/>
        <xsl:element name="EquipmentType">
          <xsl:apply-templates select="@hash"/>
          <xsl:apply-templates select="@name"/>
          <xsl:apply-templates select="@translation"/>
          <xsl:apply-templates select="@fullName"/>
          <xsl:apply-templates select="@id"/>
          <xsl:element name="RelationshipMatrix">
            <xsl:call-template name="extractMatrix">
              <xsl:with-param name="matrix" select="Property[@name='RelationshipMatrix']"/>
            </xsl:call-template>
          </xsl:element>
          <xsl:element name="Locations">
            <xsl:for-each select="linkTo/link[@property='EquipmentTypes']">
              <xsl:element name="Location">
                <xsl:attribute name="fullName">
                  <xsl:value-of select="@fullName"/>
                </xsl:attribute>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="extractMatrix">
    <xsl:param name="matrix" select="Property[@name='RelationshipMatrix']"/>
    <xsl:choose>
      <xsl:when test="contains($matrix, $semi-colon)">
        <xsl:call-template name="createMatrix">
          <xsl:with-param name="matrix" select="substring-before($matrix, $semi-colon)"/>
        </xsl:call-template>
        <xsl:call-template name="extractMatrix">
          <xsl:with-param name="matrix" select="substring-after($matrix, $semi-colon)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="createMatrix">
          <xsl:with-param name="matrix" select="$matrix"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createMatrix">
    <xsl:param name="matrix"/>
    <xsl:param name="part">initial</xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($matrix) = 0"></xsl:when>
      <xsl:when test="$part='initial'">
        <xsl:element name="Matrix">
          <xsl:variable name="first" select="substring-before($matrix, $comma)"/>
          <xsl:choose>
            <xsl:when test="$first='Downtime'">
              <xsl:attribute name="module">Downtime</xsl:attribute>
              <xsl:call-template name="createMatrix">
                <xsl:with-param name="matrix" select="substring-after($matrix, $comma)"/>
                <xsl:with-param name="part">cause</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$first='Energy'">
              <xsl:attribute name="module">Energy</xsl:attribute>
              <xsl:call-template name="createMatrix">
                <xsl:with-param name="matrix" select="substring-after($matrix, $comma)"/>
                <xsl:with-param name="part">cause</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="createMatrix">
                <xsl:with-param name="matrix" select="$matrix"/>
                <xsl:with-param name="part">cause</xsl:with-param>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>            
        </xsl:element>
      </xsl:when>
      <xsl:when test="$part='cause'">
        <xsl:attribute name="cause">
          <xsl:value-of select="substring-before($matrix, $comma)"/>
        </xsl:attribute>
        <xsl:call-template name="createMatrix">
          <xsl:with-param name="matrix" select="substring-after($matrix, $comma)"/>
          <xsl:with-param name="part">classification</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$part='classification'">
        <xsl:attribute name="classification">
          <xsl:value-of select="substring-before($matrix, $comma)"/>
        </xsl:attribute>
        <xsl:call-template name="createMatrix">
          <xsl:with-param name="matrix" select="substring-after($matrix, $comma)"/>
          <xsl:with-param name="part">effect</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$part='effect'">
        <xsl:choose>
          <xsl:when test="$matrix = $no-effect"></xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="effect">
              <xsl:value-of select="$matrix"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="Unexpected">
          <xsl:attribute name="part">
            <xsl:value-of select="$part"/>
          </xsl:attribute>
          <xsl:value-of select="$matrix"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="buildLocations">
    <xsl:variable name="locations" select="//Item[@type='Citect.Ampla.General.Server.ApplicationsFolder']"/>
    <xsl:variable name="missingEquipmentTypes" select="$locations[not(Property[@name='EquipmentTypes']/linkFrom/link) and not(starts-with(@fullName, 'System Configuration.'))]"/>
    <xsl:if test="$missingEquipmentTypes">
      <xsl:element name="Locations">
        <xsl:attribute name="message">Missing EquipmentType</xsl:attribute>
        <xsl:for-each select="$missingEquipmentTypes">
          <xsl:sort select="@fullName"/>
          <xsl:element name="Location">
            <xsl:apply-templates select="@hash"/>
            <xsl:apply-templates select="@fullName"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="buildDowntimePoints">
    <xsl:variable name="downtimePoints" select="//Item[@type='Citect.Ampla.Downtime.Server.DowntimeReportingPoint']"/>
	<xsl:element name='DowntimeReportingPoints'>
		<xsl:for-each select="$downtimePoints">
			<xsl:element name='DowntimeReportingPoint'>
				<xsl:apply-templates select="@hash"/>
				<xsl:apply-templates select="@fullName"/>
				<xsl:variable name='causeLocations' select="./Property[@name='CauseLocations']"/>
				<xsl:element name='CauseLocations'>
					<xsl:for-each select='$causeLocations/linkFrom/link'>
						<xsl:element name='CauseLocation'>
							<xsl:apply-templates select="@fullName"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:element>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
