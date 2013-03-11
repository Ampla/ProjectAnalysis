<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />

  <!-- <xsl:include href="Document.Properties.Common.xslt"/> -->

  <xsl:key name="items-by-name" match="Item" use="@name"/>

  <xsl:variable name="item-weight">4</xsl:variable>
  <xsl:variable name="link-weight">1</xsl:variable>
  <xsl:variable name="child-weight">2</xsl:variable>

  <xsl:param name="showAll">false</xsl:param>

  <xsl:template match="/">

    <xsl:variable name="translated" select="//Item[@hash = key('items-by-name', @name)[1]/@hash][@translation]"/>
    <xsl:variable name="not-translated" select="//Item[@hash = key('items-by-name', @name)[1]/@hash][not (@translation)]"/>
    <html>
      <head>
        <title>Ampla Project - Translations</title>

        <link rel="stylesheet" type="text/css" href="css/translate.css" media="screen,projector"/>
      </head>
      <body>
        <table>
          <tbody>
            <tr>
              <xsl:if test="count($translated) > 0">
                <th>Translated</th>
              </xsl:if>
              <xsl:if test="count($not-translated) > 0">
                <th width="50px"></th>
                <th>Not translated</th>
              </xsl:if>
            </tr>
            <tr>
              <xsl:if test="count($translated) > 0">
                <td class="align-top">
                  <xsl:call-template name="translationTable">
                    <xsl:with-param name="items" select="$translated"/>
                    <xsl:with-param name="include-translation">true</xsl:with-param>
                  </xsl:call-template>
                </td>
              </xsl:if>
              <xsl:if test="count($not-translated) > 0">
                <td width="50px"></td>
                <td class="align-top">
                  <xsl:call-template name="translationTable">
                    <xsl:with-param name="items" select="$not-translated"/>
                    <xsl:with-param name="include-translation">false</xsl:with-param>
                  </xsl:call-template>
                </td>
              </xsl:if>
            </tr>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="translationTable">
    <xsl:param name="items"/>
    <xsl:param name="include-translation"/>
    <table>
      <tbody>
        <tr>
          <th>Name</th>
          <xsl:if test="$include-translation = 'true'">
            <th>Translation</th>
          </xsl:if>
        </tr>
        <xsl:for-each select="$items">
<!--          <xsl:sort data-type="number"
                    select="($child-weight * count(key('items-by-name', @name)/descendant::Item[@id])) 
                              + ($item-weight * count(key('items-by-name', @name))) 
                              + ($link-weight * count(key('items-by-name', @name)/linkTo/link))"
                    order="descending"/>
-->
          <xsl:sort data-type="text" select="@name"/>
          <tr>
            <xsl:if test="position() mod 2 = 1">
              <xsl:attribute name="class">tr-alt</xsl:attribute>
            </xsl:if>
            <td>
              <xsl:value-of select="@name"/>
            </td>
            <xsl:if test="$include-translation = 'true'">
              <td>
                <xsl:choose>
                  <xsl:when test="@translation">
                    <span class="i-trans">
                      <xsl:value-of select="@translation"/>
                    </span>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </xsl:if>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

</xsl:stylesheet>
