<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" 
    exclude-result-prefixes="SOAP-ENV"
  >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    indent="yes"
              />

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
  <xsl:variable name="cr" select="'&#xD;'"/>

  <xsl:key name="items-by-name" match="Item"  use="@name"/>

  <xsl:variable name="item-weight">10</xsl:variable>
  <xsl:variable name="link-weight">20</xsl:variable>
  <xsl:variable name="child-weight">5</xsl:variable>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head></head>
      <body>
        <xsl:for-each select="//Item[@hash = key('items-by-name', @name)[1]/@hash]">
          <xsl:sort data-type="number" select="($item-weight * count(key('items-by-name', @name))) + ($link-weight * count(key('items-by-name', @name)/linkTo/link)) + ($child-weight * count(key('items-by-name', @name)/descendant::Item[@id]))" order="descending"/>
          <xsl:sort data-type="text" select="@name"/>
          <xsl:variable name="tooltip">
            <xsl:choose>
              <xsl:when test="@translation">
                <xsl:text>Name = </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:value-of select="$crlf"/>
                <xsl:text>Translation = </xsl:text>
                <xsl:value-of select="@translation"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="id">
              <xsl:value-of select="@name"/>
            </xsl:attribute>
<!--            <xsl:attribute name="title">
              <xsl:value-of select="$tooltip"/>
            </xsl:attribute>
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="string-length(@translation)>0">item-trans</xsl:when>
                <xsl:otherwise>item-name</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
-->            <xsl:choose>
              <xsl:when test="@translation">
                <xsl:value-of select="@translation"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
