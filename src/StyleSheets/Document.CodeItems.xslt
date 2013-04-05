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
          <link rel="stylesheet" type="text/css" href="css/display.css" />
          <script type="text/javascript" src="jquery.js"></script>
        </META>
      </head>
      <body>
        <a name="top"/>
        <h1 class="text">Ampla Project - Code Items</h1>
              <hr/>
              <xsl:call-template name="codeItemsContent"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="codeItemsContent">
    <ul>
      <xsl:for-each select="//Item[@type = 'Citect.Ampla.StandardItems.Code']">
        <xsl:sort select="@fullName"/>
        <li>
          <a href="#{@hash}">
            <xsl:call-template name="getItemFullName"/>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    <xsl:apply-templates select="//Item[@type = 'Citect.Ampla.StandardItems.Code']"/>
  </xsl:template>

  <xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Code']">
	<hr/>
    <a name="{@hash}"/>
	<h2 class='text'><xsl:call-template name="getItemFullName"/></h2>
	<pre>
    <xsl:value-of select="Property[@name='Source']"/>
    </pre>
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
