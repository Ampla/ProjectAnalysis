<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"  />

  <xsl:template match="/">
    <html>
      <head>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8">
          <title>Project Analysis - Hierarchy</title>
          <link rel="stylesheet" type="text/css" href="display.css" />
          <script type="text/javascript" src="jquery.js"></script>
          <script type="text/javascript" src="navigate.js"></script>
        </META>
      </head>
      <body>
        <table width="100%">
          <tr>
            <td class="header">
              <h1>Project Analysis - Code Items</h1>
              <br/>
              <table class="menu">
                <tr>
                  <td class="menu-text">Menu: </td>
                  <td class="menu-text">
                    <a href="Hierarchy.html">Hierarchy</a>
                  </td>
                  <td class="menu-selected">
                    <a href="CodeItems.html">Code Items</a>
                  </td>
                  <td class="menu-text">
                    <a href="ItemTypes.html">Item Types</a>
                  </td>
                  <td class="menu-text">
                    <a href="Warnings.html">Warnings</a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td class="section">
              <a id="collapseAll" href="#">Collapse All</a>
              <a id="expandAll" href="#">Expand All</a>
              <a id="defaultView" href="#">Default View</a>
              <br/>

              <hr/>
              <hr/>
              <xsl:call-template name="codeItemsContent"/>

            </td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="codeItemsContent">
    <ul>
      <xsl:for-each select="//Item[@type = 'Citect.Ampla.StandardItems.Code']">
        <xsl:sort select="@fullName"/>
        <li>
          <a href="#{@id}">
            <xsl:call-template name="getItemFullName"/>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    <xsl:apply-templates select="//Item[@type = 'Citect.Ampla.StandardItems.Code']"/>
  </xsl:template>

  <xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Code']">
    <a name="{@id}"/>
    <table>
      <tr>
        <th>
          <xsl:call-template name="getItemFullName"/>
          <span title="View in hiearchy...">
            <xsl:text> [ </xsl:text>
            <a href="Hierarchy.html#{@id}">...</a>
            <xsl:text> ] </xsl:text>
          </span>
        </th>
      </tr>
      <tr>
        <td>
          <pre>
            <xsl:value-of select="Property[@name='Source']"/>
          </pre>
        </td>
      </tr>
    </table>
    <hr/>
  </xsl:template>

  <xsl:template name="getItemFullName">
    <xsl:for-each select="ancestor-or-self::Item[@id]">
      <xsl:if test="position()>1">
        <xsl:text>.</xsl:text>
      </xsl:if>              
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
