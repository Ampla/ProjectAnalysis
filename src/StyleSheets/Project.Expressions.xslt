<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>
  <xsl:key name="dependency-by-target-id" match="Dependency" use="ItemPropertyLink/ItemLink/@targetID"/>
  <xsl:key name="type-by-full-name" match="Type" use="@fullName"/>
  
  <xsl:variable name="all-dependencies" select="//Dependency"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Project">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="source-items" select="key('items-by-id', $all-dependencies/ItemPropertyLink/ItemLink/@targetID)"/>
      <xsl:variable name="expression-items" select="key('items-by-id', $all-dependencies/ancestor::Property/parent::Item/@id)"/>
        <xsl:apply-templates select="Item" mode="create-tree">
          <xsl:with-param name="items" select="$source-items | $expression-items"/>
        </xsl:apply-templates>
<!--
      <SourceItems count="{count($source-items)}">
        <xsl:apply-templates select="$source-items" mode="source">
          <xsl:sort select="@fullName"/>
        </xsl:apply-templates>
      </SourceItems>
      <ExpressionItems count="{count($expression-items)}">
        <xsl:apply-templates select="$expression-items" mode="expression">
          <xsl:sort select="@fullName"/>
        </xsl:apply-templates>
      </ExpressionItems>
-->
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item" mode="create-tree">
    <xsl:param name="items" select="/Item"/>
    <xsl:variable name="this-id" select="@id"/>
    <xsl:variable name="current" select="$items[@id=$this-id]"/>
    <xsl:variable name="ancestor-of" select="$items/ancestor::Item[@id=$this-id]"/>
    <xsl:choose>
      <xsl:when test="$current">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="." mode="stream"/>
          <xsl:apply-templates select="Property"/>
          <xsl:apply-templates select="Item" mode="create-tree">
            <xsl:with-param name="items" select="$items" />
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$ancestor-of">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="Item" mode="create-tree">
            <xsl:with-param name="items" select="$items" />
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment><xsl:value-of select="@name"/></xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Item" mode="stream">
    <xsl:variable name="source-id" select="@id"/>
    <xsl:variable name="dep-refs" select="key('dependency-by-target-id', @id)"/>
    <xsl:variable name="stream-name" select="$dep-refs/ItemPropertyLink/@propertyName"/>
    <xsl:variable name="streams" select="key('type-by-full-name', @type)/Stream[@name=$stream-name]"/>
    <xsl:for-each select="$streams">
      <Stream name="{@name}" type="{@dataType}">
        <xsl:variable name="link-property" select="$dep-refs/ancestor::Property"/>
        <xsl:for-each select="$link-property">
          <xsl:variable name="dependencyType" select="./descendant::Dependency/ItemPropertyLink/ItemLink[@targetID=$source-id]/../../@dependencyType"/>
          <PropertyLink propertyName="{@name}" id="{../@id}" type="{../@type}" fullName="{../@fullName}" dependencyType="{$dependencyType}"/>
        </xsl:for-each>
      </Stream>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Property[@name='CauseLocations']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment>
        <xsl:value-of select="count(property-value/ItemLocations/ItemLink)"/>
        <xsl:text> Locations</xsl:text>
      </xsl:comment>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
