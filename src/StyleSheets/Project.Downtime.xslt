<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>

  <xsl:variable name="comma">,</xsl:variable>
  <xsl:variable name="semi-colon">;</xsl:variable>
  <xsl:variable name="no-effect">&lt;NULL&gt;</xsl:variable>

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
    </xsl:copy>
  </xsl:template>

  <xsl:template name="buildCauseCodes">
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
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="buildClassifications">
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
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="buildEffects">
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
      </xsl:element>
    </xsl:for-each>
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
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
