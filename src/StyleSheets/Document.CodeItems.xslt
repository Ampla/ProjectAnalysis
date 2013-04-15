<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"  />

	<xsl:include href="Document.Properties.Common.xslt"/> 
	
	<xsl:variable name="code-items" select="//Item[@type = 'Citect.Ampla.StandardItems.Code']"/>
	<xsl:variable name="action-items" select="//Item[@type = 'Citect.Ampla.StandardItems.Action']"/>
  
	<xsl:template match="/">
    <html>
      <head>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8">
          <title>Project Analysis - Code and Action Items</title>
          <link rel="stylesheet" type="text/css" href="css/display.css" />
          <script type="text/javascript" src="jquery.js"></script>
        </META>
      </head>
      <body>
        <a name="top"/>
		<xsl:if test="count($code-items) > 0">
			<h1 class="text">Ampla Project - Code and Action items </h1>
            <hr/>
		</xsl:if>
		<xsl:if test="count($code-items) > 0">
			<h2 class="text">Code Items (<xsl:value-of select="count($code-items)"/>)</h2>
            <xsl:call-template name="list-items">
				<xsl:with-param name="items" select="$code-items"/>
			</xsl:call-template>	
		</xsl:if>
		<xsl:if test="count($action-items) > 0">
			<h2 class="text">Action Items (<xsl:value-of select="count($action-items)"/>)</h2>
            <xsl:call-template name="list-items">
				<xsl:with-param name="items" select="$action-items"/>
			</xsl:call-template>	
		</xsl:if>
		
		<xsl:if test="count($code-items) > 0">
			<xsl:apply-templates select="$code-items">
				<xsl:sort select="@fullName"/>
			</xsl:apply-templates>	
		</xsl:if>

		<xsl:if test="count($action-items) > 0">
			<xsl:apply-templates select="$action-items">
				<xsl:sort select="@fullName"/>
			</xsl:apply-templates>	
		</xsl:if>

      </body>
    </html>
  </xsl:template>

  <xsl:template name="list-items">
	<xsl:param name="items" select="."/>
    <ul>
      <xsl:for-each select="$items">
        <xsl:sort select="@fullName"/>
        <li>
          <a href="#{@hash}">
            <xsl:call-template name="getItemFullName"/>
          </a>
        </li>
      </xsl:for-each>
    </ul>	
  </xsl:template>

  <xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Code']">
	<hr/>
    <a name="{@hash}"/>
	<h2 class='text'><xsl:call-template name="getItemFullName"/></h2>
	<pre>
    <xsl:value-of select="Property[@name='Source']"/>
    </pre>
  </xsl:template>
  
 
	<xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Action']">
		<hr/>
		<a name="{@hash}"/>
		<h2 class='text'><xsl:call-template name="getItemFullName"/></h2>
		<xsl:call-template name="outputItemProperties">
			<xsl:with-param name="sect">i-sect</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


  <!--
  <xsl:template name="getItemFullName">
    <xsl:for-each select="ancestor-or-self::Item[@id]">
      <xsl:if test="position()>1">
        <xsl:text>.</xsl:text>
      </xsl:if>              
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>
  
  -->
</xsl:stylesheet>
