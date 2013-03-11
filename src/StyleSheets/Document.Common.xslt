<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:variable name="item-target">all</xsl:variable>
  <xsl:variable name="default-page">all.html</xsl:variable>
  <xsl:variable name="hierarchy-page">hierarchy.html</xsl:variable>
  <xsl:variable name="types-page">types.html</xsl:variable>
  <xsl:variable name="index">index.html</xsl:variable>

  <xsl:key name="items-by-id" match="Item" use="@id"/>
  <xsl:key name="items-by-fullName" match="Item"  use="@fullName"/>

  <xsl:template name="get-hash">
    <xsl:param name="item" select="."/>
    <xsl:choose>
      <xsl:when test="$item/@hash">
        <xsl:value-of select="$item/@hash"/>
      </xsl:when>
      <xsl:when test="$item/@id">
        <xsl:value-of select="$item/@id"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-item-link">
    <xsl:param name="item-link" select="."/>
    <xsl:param name="full-path" select="$item-link/@absolutePath"/>
    <xsl:param name="use">fullname</xsl:param>
    <xsl:variable name="id" select="$item-link/@targetID"/>
    <xsl:variable name="item-using-id" select="key('items-by-id', $id)"/>
    <xsl:variable name="item-using-full-path" select="key('items-by-fullName', $full-path)"/>
    <xsl:variable name="isBroken" select="$item-link/@*[starts-with(name(), 'broken')]"/>
    <xsl:variable name="parentFullname" select="ancestor::Item[@id][position()=last()]/@fullName"/>
    <xsl:choose>
      <xsl:when test="$item-using-id">
        <xsl:call-template name="link-to-fullpath">
          <xsl:with-param name="item" select="$item-using-id"/>
          <xsl:with-param name="name">
            <xsl:choose>
              <xsl:when test="$parentFullname = $item-using-id/@fullName">
                <xsl:text>{this}</xsl:text>
              </xsl:when>
              <xsl:when test="$use='fullname'">
                <xsl:value-of select="$item-using-id/@fullName"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$item-using-id/@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>        
      </xsl:when>
      <xsl:when test="$item-using-full-path">
        <xsl:call-template name="link-to-fullpath">
          <xsl:with-param name="item" select="$item-using-full-path"/>
          <xsl:with-param name="name">
            <xsl:choose>
              <xsl:when test="$use='fullname'">
                <xsl:value-of select="$item-using-full-path/@fullName"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$item-using-full-path/@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="title">
          <xsl:text>Fullname = </xsl:text>
          <xsl:value-of select="$full-path"/>
          <xsl:text>
</xsl:text>
          <xsl:text>Id = </xsl:text>
          <xsl:value-of select="$id"/>
        </xsl:variable>
        <span class="broken" title="{$title}">{Broken Item Link}</span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="link-to-fullpath">
    <xsl:param name="item"/>
    <!-- optional -->
    <xsl:param name="name" select="$item/@fullName"/>
    <xsl:param name="translation">
      <xsl:call-template name="getTranslatedFullName">
        <xsl:with-param name="item" select="$item"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:call-template name="item-href">
      <xsl:with-param name="hash" select="$item/@hash"/>
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="isClass" select="$item/@class"/>
      <xsl:with-param name="translation" select="$translation"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="item-href">
    <xsl:param name="name" select="@name"/>
    <xsl:param name="hash" select="@hash"/>
    <xsl:param name="site" select="$default-page"/>
    <xsl:param name="isClass" select="@class"/>
    <xsl:param name="translation" select="@translation"/>
    <xsl:param name="class"/>
    <xsl:variable name="a-class">
      <xsl:choose>
        <xsl:when test="$isClass">c-ref</xsl:when>
        <xsl:otherwise>i-ref</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$class">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$class"/>
      </xsl:if>
    </xsl:variable>
    <a class="{$a-class}" href="{$site}#{$hash}" target="{$item-target}">
      <xsl:if test="$translation">
        <xsl:attribute name="title">
          <xsl:value-of select="$translation"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$name"/>
    </a>
  </xsl:template>
  
  <xsl:template name="itemCount">
    <xsl:param name="numItems">0</xsl:param>
    <xsl:param name="includeSpacer">true</xsl:param>
    <xsl:param name="includeText">true</xsl:param>
    <xsl:choose>
      <xsl:when test="$numItems= 0"></xsl:when>
      <xsl:when test="$numItems= 1">
        <span class="i-no">
          <xsl:if test="$includeSpacer='true'">
            <xsl:text> - </xsl:text>
          </xsl:if>
          <xsl:text>(1</xsl:text>
          <xsl:if test="$includeText='true'">
            <xsl:text> item</xsl:text>
          </xsl:if>
          <xsl:text>)</xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="i-no">
          <xsl:if test="$includeSpacer='true'">
            <xsl:text> - </xsl:text>
          </xsl:if>
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$numItems"/>
          <xsl:if test="$includeText='true'">
            <xsl:text> items</xsl:text>
          </xsl:if>
          <xsl:text>)</xsl:text>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="outputLinks">
    <xsl:param name="links"></xsl:param>
    <xsl:param name="includeSpacer">true</xsl:param>
    <xsl:param name="includeTooltip">false</xsl:param>
    <xsl:variable name="fullName" select="concat(@fullName, '.')"/>
    <xsl:variable name="numLinks" select="count($links)"/>
    <xsl:if test="$numLinks > 0">
      <xsl:variable name="insideLinks" select="$links[starts-with(@fullName, $fullName)]"/>
      <xsl:variable name="outsideLinks" select="$links[not(starts-with(@fullName, $fullName))]"/>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="count($outsideLinks)>0">i-ex</xsl:when>
          <xsl:otherwise>i-in</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="text">
        <xsl:choose>
          <xsl:when test="$numLinks= 1">
            <xsl:if test="$includeSpacer='true'">
              <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:text>(1 link)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$includeSpacer='true'">
              <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="$numLinks"/>
            <xsl:text> links)</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <span class="{$class}">
        <xsl:value-of select="$text"/>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getItemFullName">
    <xsl:for-each select="ancestor-or-self::Item[@id]">
      <xsl:if test="position()>1">
        <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getTranslatedFullName">
    <xsl:param name="item" select="."/>
    <xsl:if test="$item/ancestor-or-self::Item[@translation]">
      <xsl:for-each select="$item/ancestor-or-self::Item[@id]">
        <xsl:if test="position()>1">
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@translation">
            <xsl:value-of select="@translation"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@name"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
