<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />

  <xsl:include href="Document.Properties.Common.xslt"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Ampla Project Warnings</title>

        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>

        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="lib/jquery-ui-all.js"></script>
        <script type="text/javascript" src="lib/chili/jquery.chili-2.2.js"></script>
        <script type="text/javascript" src="lib/browser.js"></script>
      </head>

      <body>
        <div id="content">
          <div id="docs">
            <h3>Ampla Project - Warnings</h3>

            <ul>
              <xsl:call-template name="warning-items"/>
            </ul>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="warning-items">
    <xsl:variable name="broken-by-id" select="//Item[Property/descendant::ItemLink[(@broken-targetID) and (string-length(@targetID) > 0)]]"/>
    <xsl:variable name="broken-by-fullName" select="//Item[(Property/descendant::ItemLink/@broken-absolutePath) and not(starts-with(@fullName, 'System Configuration.Templates'))]"/>
    <xsl:variable name="broken-by-relative" select="//Item[Property/descendant::ItemLink/@broken-relativePath]"/>
    <xsl:variable name="property-compileAction" select="//Item[Property[contains(@name, 'CompileAction') and text()='None']]"/>
    <xsl:variable name="expression-compileAction" select="//Item[Property/descendant-or-self::*[@compileAction='None'] and not(starts-with(@fullName, 'System Configuration.Templates'))]"/>
    <xsl:variable name="corrupt-favorites" select="//Item[Property/text/@isCorrupt]"/>
    <xsl:variable name="manualFieldWithNoExpression" select="//Item[Property/HistoricalExpressionConfig/ExpressionConfig/@message]"/>

    <xsl:variable name="broken-items" select="$broken-by-id | $broken-by-fullName | $broken-by-relative | $property-compileAction | $expression-compileAction | $corrupt-favorites | $manualFieldWithNoExpression"/>

    <xsl:choose>
      <xsl:when test="count($broken-items) > 0">
        <xsl:apply-templates select="$broken-items">
          <xsl:sort select="@fullName"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <li>No warnings or errors.</li>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:variable name="linksTo" select="linkTo/link"/>
    <xsl:variable name="linksFrom" select="Property/linkFrom/link"/>
    <xsl:variable name="fullname" select="concat(@fullName, '.')"/>
    <xsl:variable name="hash">
      <xsl:call-template name="get-hash">
        <xsl:with-param name="item" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="sect">
      <xsl:choose>
        <xsl:when test="@class">c-sect</xsl:when>
        <xsl:otherwise>i-sect</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <li>
<!--<li id="{$hash}"> -->
        <div class="i-head">
        <xsl:variable name="parent" select="ancestor::Item[@id]"/>
        <xsl:if test="$parent">
          <xsl:for-each select="$parent">
            <xsl:call-template name="item-href"/>
            <xsl:text>.</xsl:text>
          </xsl:for-each>
        </xsl:if>
        <xsl:call-template name="item-href"/>
      </div>
      <div class="{$sect}">Properties</div>
      <table class="p-tab">
        <tr>
          <th>Name</th>
          <th>Value</th>
        </tr>
        <tr class="tr-alt">
          <td class="pName">Type</td>
          <td class="pValue">
            <xsl:value-of select="@type"/>
          </td>
        </tr>
        <xsl:for-each select="Property">
          <tr>
            <xsl:if test="position() mod 2 = 0">
              <xsl:attribute name="class">tr-alt</xsl:attribute>
            </xsl:if>
            <td class="p-key">
              <xsl:value-of select="@name"/>
            </td>
            <td class="p-val">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <xsl:if test="count($linksTo)">
        <div class="{$sect}">Links</div>
        <xsl:for-each select="$linksTo">
          <xsl:sort select="@fullName"/>
          <div class="link">
            <xsl:value-of select="position()"/>
            <xsl:text> - </xsl:text>
            <xsl:variable name="item" select="key('items-by-id', @id)"/>
            <xsl:variable name="name">
              <xsl:choose>
                <xsl:when test="starts-with($item/@fullName, $fullname)">
                  <xsl:text>...</xsl:text>
                  <xsl:value-of select="substring($item/@fullName, string-length($fullname)+1)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$item/@fullName"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="link-to-fullpath">
              <xsl:with-param name="item" select="$item"/>
              <xsl:with-param name="name" select="$name"/>
            </xsl:call-template>
            <xsl:text> - (</xsl:text>
            <xsl:value-of select="@property"/>
            <xsl:text>)</xsl:text>
          </div>
        </xsl:for-each>
      </xsl:if>
    </li>
  </xsl:template>
  
</xsl:stylesheet>
