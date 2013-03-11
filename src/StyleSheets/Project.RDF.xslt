<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <!-- =================================================== -->
  <!-- Item Templates -->
  <!-- =================================================== -->

  <xsl:template match="/">
    <RDF>
      <xsl:apply-templates select="Ampla"/>
    </RDF>
  </xsl:template>

  <xsl:template match="Ampla">
      <xsl:call-template name="rdf">
        <xsl:with-param name="node">project--</xsl:with-param>
        <xsl:with-param name="subject" select="."/>
        <xsl:with-param name="predicate-uri">identity</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="@*">
        <xsl:sort data-type="text" select="name()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="Item[@id]">
        <xsl:sort select="@name" data-type="text"/>
      </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Ampla/@*">
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">proj-attr</xsl:with-param>
      <xsl:with-param name="subject" select=".."/>
      <xsl:with-param name="predicate" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@id]/@*">
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-attr</xsl:with-param>
      <xsl:with-param name="subject" select=".."/>
      <xsl:with-param name="predicate" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@id]/Property">
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-prop</xsl:with-param>
      <xsl:with-param name="subject" select=".."/>
      <xsl:with-param name="predicate" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="flat">
    <xsl:variable name="fullName">
      <xsl:call-template name="fullName"/>
    </xsl:variable>
    <xsl:comment><xsl:text>
Item : </xsl:text>
      <xsl:value-of select="$fullName"/>
      <xsl:text>
</xsl:text>
    </xsl:comment>
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-----</xsl:with-param>
      <xsl:with-param name="subject" select="."/>
      <xsl:with-param name="predicate-uri">identity</xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="@*">
      <xsl:sort data-type="text" select="name()"/>
    </xsl:apply-templates>
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-meta</xsl:with-param>
      <xsl:with-param name="subject" select="."/>
      <xsl:with-param name="predicate-uri">item-parent</xsl:with-param>
      <xsl:with-param name="value" select=".."/>
    </xsl:call-template>
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-meta</xsl:with-param>
      <xsl:with-param name="subject" select="."/>
      <xsl:with-param name="predicate-uri">item-fullname</xsl:with-param>
      <xsl:with-param name="value-string" select="$fullName"/>
    </xsl:call-template>
    <xsl:call-template name="rdf">
      <xsl:with-param name="node">item-meta</xsl:with-param>
      <xsl:with-param name="subject" select="."/>
      <xsl:with-param name="predicate-uri">item-depth</xsl:with-param>
      <xsl:with-param name="value-string" select="count(ancestor-or-self::Item)"/>
    </xsl:call-template>
    <xsl:apply-templates select="Property[@name]">
      <xsl:sort select="@name" data-type="text"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="Item[@id]">
      <xsl:sort select="@name" data-type="text"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:variable name="fullName">
      <xsl:call-template name="fullName"/>
    </xsl:variable>
    <xsl:comment>
      <xsl:text>
Item : </xsl:text>
      <xsl:value-of select="$fullName"/>
      <xsl:text>
</xsl:text>
    </xsl:comment>
    <xsl:element name="item">
      <xsl:attribute name="subject">
        <xsl:apply-templates select="." mode="uri"/>
      </xsl:attribute>
      <xsl:attribute name="depth">
        <xsl:value-of select="count(ancestor-or-self::Item)"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*">
        <xsl:sort data-type="text" select="name()"/>
      </xsl:apply-templates>
      <xsl:call-template name="rdf">
        <xsl:with-param name="node">item-meta</xsl:with-param>
        <xsl:with-param name="subject" select="."/>
        <xsl:with-param name="predicate-uri">item-parent</xsl:with-param>
        <xsl:with-param name="value" select=".."/>
      </xsl:call-template>
      <xsl:call-template name="rdf">
        <xsl:with-param name="node">item-meta</xsl:with-param>
        <xsl:with-param name="subject" select="."/>
        <xsl:with-param name="predicate-uri">item-fullname</xsl:with-param>
        <xsl:with-param name="value-string" select="$fullName"/>
      </xsl:call-template>
      <!--
      <xsl:call-template name="rdf">
        <xsl:with-param name="node">item-meta</xsl:with-param>
        <xsl:with-param name="subject" select="."/>
        <xsl:with-param name="predicate-uri">item-depth</xsl:with-param>
        <xsl:with-param name="value-string" select="count(ancestor-or-self::Item)"/>
      </xsl:call-template>
      -->
      <xsl:apply-templates select="Property[@name]">
        <xsl:sort select="@name" data-type="text"/>
      </xsl:apply-templates>
    </xsl:element>
    <xsl:apply-templates select="Item[@id]">
      <xsl:sort select="@name" data-type="text"/>
    </xsl:apply-templates>
  </xsl:template>


  <!-- =================================================== -->
  <!-- Value Templates -->
  <!-- =================================================== -->

  <xsl:template match="@*" mode="value">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="value">
    <xsl:apply-templates select="." mode="uri"/>
  </xsl:template>

  <xsl:template match="Item[@id]/Property" mode="value">
    <xsl:apply-templates mode="copy"/>
  </xsl:template>

  <xsl:template match="@*" mode="copy">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="*" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <!-- =================================================== -->
  <!-- URI resolution -->
  <!-- =================================================== -->

  <xsl:template match="Ampla" mode="value">
    <xsl:apply-templates select="." mode="uri"/>
  </xsl:template>

  <xsl:template match="Project" mode="value">
    <xsl:apply-templates select="." mode="uri"/>
  </xsl:template>

  <xsl:template match="Project" mode="uri">
    <xsl:text>ampla://project</xsl:text>
  </xsl:template>

  <xsl:template match="Ampla/@*" mode="uri">
    <xsl:text>project-</xsl:text>
    <xsl:value-of select="name()"/>
  </xsl:template>

  <xsl:template match="Ampla" mode="uri">
    <xsl:text>project://</xsl:text>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="uri">
    <xsl:text>item://</xsl:text>
    <xsl:value-of select="@id"/>
  </xsl:template>

  <xsl:template match="Item[@id]/@*" mode="uri">
    <xsl:text>item-</xsl:text>
    <xsl:value-of select="name()"/>
  </xsl:template>

  <xsl:template match="Item[@id]/Property" mode="uri">
    <xsl:value-of select="@name"/>
  </xsl:template>

  <!-- =================================================== -->
  <!-- RDF Templates -->
  <!-- =================================================== -->

  <xsl:template name="rdf">
    <xsl:param name="node">rdf</xsl:param>
    <xsl:param name="subject"/>
    <xsl:param name="predicate"/>
    <xsl:param name="predicate-uri">
      <xsl:apply-templates select="$predicate" mode="uri"/>
    </xsl:param>
    <xsl:param name="value" select="."/>
    <xsl:param name="value-string"/>
    <!--
    <xsl:element name="{$node}">
      <xsl:attribute name="sub">
        <xsl:apply-templates select="$subject" mode="uri"/>
      </xsl:attribute>
      <xsl:attribute name="pred">
        <xsl:value-of select="$predicate-uri"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$value-string">
          <xsl:value-of select="$value-string"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$value" mode="value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    -->
    <xsl:element name="{$predicate-uri}">
      <xsl:choose>
        <xsl:when test="$value-string">
          <xsl:value-of select="$value-string"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$value" mode="value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element> 
  </xsl:template>

  <xsl:template name="fullName">
    <xsl:for-each select="ancestor-or-self::Item">
      <xsl:if test="position() > 1">.</xsl:if>
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
