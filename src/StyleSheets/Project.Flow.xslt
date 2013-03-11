<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="items-by-id" match="Item" use="@id"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Project"/>
  </xsl:template>

  <xsl:template match="Project">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="//Item[@id and linkTo and not(Property/descendant::linkFrom)]">
        <xsl:sort select="@type"/>
        <xsl:sort select="@fullName"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:param name="visitedHashs"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="count(linkTo/link) > 0">
        <Links>
          <xsl:for-each select="linkTo/link">
            <xsl:variable name="item" select="key('items-by-id', @id)"/>
            <xsl:variable name="visited">
              <xsl:call-template name="alreadyVisited">
                <xsl:with-param name="current" select="$item/@hash"/>
                <xsl:with-param name="visitedHashs" select="$visitedHashs"/>
              </xsl:call-template>
            </xsl:variable>
            <link property="{@property}">
              <xsl:choose>
                <xsl:when test="$visited='true'">
                  <xsl:apply-templates select="$item" mode="norecurse"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="$item">
                    <xsl:with-param name="visitedHashs" select="concat($visitedHashs, '[',$item/@hash, ']')"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </link>
          </xsl:for-each>
        </Links>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="norecurse">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="alreadyVisited">
    <xsl:param name="hash" select="@hash"/>
    <xsl:param name="visitedHashs"/>
    <xsl:choose>
      <xsl:when test="contains($visitedHashs, $hash)">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
