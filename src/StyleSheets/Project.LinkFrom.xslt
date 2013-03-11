<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>
  <xsl:key name="items-by-fullName" match="Item"  use="@fullName"/>

  <xsl:variable name="linkToName">linkTo</xsl:variable>
  <xsl:variable name="linkFromName">linkFrom</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Item[@id]/Property">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="count(descendant-or-self::*) > 1">
          <xsl:call-template name="addPropertyLinks"/>
        </xsl:when>
        <!-- 
          Special case for Impala's project.  
          They had a folder called 'Constants' which tries to link to enum values 'Constants'     
          
         -->
        <xsl:when test="@name='DeriveSpecificationFrom'">
          <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="tryFullName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="ItemLink">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@targetID">
        <xsl:if test="not(key('items-by-id', @targetID))">
          <xsl:attribute name="broken-targetID">true</xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@absolutePath">
        <xsl:if test="not(key('items-by-fullName', @absolutePath))">
          <xsl:attribute name="broken-absolutePath">true</xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@relativePath">
        <xsl:variable name="item-id">
          <xsl:call-template name="findRelativeId">
            <xsl:with-param name="path" select="@relativePath"/>
            <xsl:with-param name="parents" select="ancestor-or-self::Item[@id]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length($item-id) = 0">
          <xsl:attribute name="broken-relativePath">true</xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Finds the id of the item using the relative path-->
  <xsl:template name="findRelativeId">
    <xsl:param name="path"/>
    <xsl:param name="parents"/>
    <xsl:param name="index" select="count($parents)"/>
    <xsl:choose>
      <xsl:when test="$index &lt; 0">
        <!-- index is less than zero... couldn't find item-->
      </xsl:when>
      <xsl:when test="$index > count($parents)">
        <!-- index is greater than parent list... couldn't find item-->
      </xsl:when>
      <xsl:when test="starts-with($path, 'Parent.')">
        <!-- Need to keep moving up the parent chain -->
        <xsl:call-template name="findRelativeId">
          <xsl:with-param name="path" select="substring-after($path, 'Parent.')"/>
          <xsl:with-param name="parents" select="$parents"/>
          <xsl:with-param name="index" select="$index - 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$path = 'this'">
        <!-- The item link is to itself-->
        <xsl:value-of select="$parents[position()=$index]/@id"/>
      </xsl:when>
      <xsl:when test="$path = 'Parent'">
        <!-- The relative name is this item's direct parent -->
        <xsl:value-of select="$parents[position()=($index - 1)]/@id"/>
      </xsl:when>
      <xsl:when test="($index &lt;= 0) and not(starts-with($path, 'Parent.'))">
        <!-- The relative path has moved to the root node -->
        <xsl:value-of select="key('items-by-fullName', $path)/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No more parents, so path is a sub-child of the current item  -->
        <xsl:variable name="item" select="$parents[position()=$index]"/>
        <xsl:variable name="fullPath" select="concat($item/@fullName, '.', $path)"/>
        <xsl:value-of select="key('items-by-fullName', $fullPath)/@id"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template name="tryFullName">
    <xsl:variable name="value" select="."/>
    <xsl:variable name="propertyName" select="@name"/>
    <xsl:variable name="links" select="key('items-by-fullName', $value)"/>
    <xsl:choose>
      <xsl:when test="count($links) > 0">
        <xsl:element name="{$linkFromName}">
          <xsl:for-each select="$links">
            <xsl:element name="link">
              <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
              </xsl:attribute>
              <xsl:attribute name="fullName">
                <xsl:value-of select="@fullName"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
        <xsl:element name="property-value">
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="addPropertyLinks">
    <xsl:variable name="propertyName" select="@name"/>
    <xsl:variable name="links" select="descendant::ItemLink"/>
    <xsl:choose>
      <xsl:when test="count($links) > 0">
        <xsl:for-each select="$links">
          <xsl:element name="{$linkFromName}">
            <xsl:element name="link">
              <xsl:choose>
                <xsl:when test="@targetId">
                  <xsl:attribute name="id">
                    <xsl:value-of select="@targetID"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="item" select="key('items-by-fullName', @absolutePath)"/>
                  <xsl:if test="$item">
                    <xsl:attribute name="id">
                      <xsl:value-of select="$item/@id"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:attribute name="fullName">
                <xsl:value-of select="@absolutePath"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:element name="property-value">
          <xsl:apply-templates select="node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy/>    
  </xsl:template>
  
</xsl:stylesheet>
