<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"  />

	<xsl:include href="Document.Properties.Common.xslt"/> 
	
	<xsl:key name="documents-by-module" match="Item[@type = 'Citect.Ampla.General.Server.Document' or @type='Citect.Ampla.Metrics.Server.Dashboard']" use="Property[@name='Module']"/>
	
	<xsl:variable name="document-items" select="//Item[@type = 'Citect.Ampla.General.Server.Document' or @type='Citect.Ampla.Metrics.Server.Dashboard']"/>
	<xsl:variable name="modules" select="$document-items[generate-id() = generate-id(key('documents-by-module', Property[@name='Module'])[1])]/Property[@name='Module']" />

	<xsl:variable name="action-items" select="//Item[@type = 'Citect.Ampla.StandardItems.Action']"/>
  
	<xsl:template match="/">
    <html>
      <head>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8">
          <title>Project Analysis - Interfaces</title>
          <link rel="stylesheet" type="text/css" href="css/display.css" />
          <script type="text/javascript" src="jquery.js"></script>
        </META>
      </head>
      <body>
        <a name="top"/>
		<h1 class="text">Ampla Project - Interfaces</h1>
		<hr/>
		<xsl:if test="count($document-items) > 0">
			<h2 class="text">Documents (<xsl:value-of select="count($document-items)"/>)</h2>
			<xsl:for-each select="$modules">
				<xsl:variable name="module" select="."/>
				<xsl:variable name="documents" select="key('documents-by-module', $module)"/>
				<h3 class="text"><xsl:value-of select="$module"/> Documents (<xsl:value-of select="count($documents)"/>)</h3> 
				<xsl:call-template name="list-items">
					<xsl:with-param name="items" select="$documents"/>
				</xsl:call-template>	
			</xsl:for-each>
		</xsl:if>
		<!--
		<xsl:if test="count($action-items) > 0">
			<h2 class="text">Action Items (<xsl:value-of select="count($action-items)"/>)</h2>
            <xsl:call-template name="list-items">
				<xsl:with-param name="items" select="$action-items"/>
			</xsl:call-template>	
		</xsl:if>
		-->
		<xsl:if test="count($document-items) > 0">
			<xsl:apply-templates select="$document-items">
				<xsl:sort select="@fullName"/>
			</xsl:apply-templates>	
		</xsl:if>

		<!--
		<xsl:if test="count($action-items) > 0">
			<xsl:apply-templates select="$action-items">
				<xsl:sort select="@fullName"/>
			</xsl:apply-templates>	
		</xsl:if>
		-->
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

  <!--
  <xsl:template match="Item[@type = 'Citect.Ampla.General.Server.Document']">
	<hr/>
    <a name="{@hash}"/>
	<h2 class='text'><xsl:call-template name="getItemFullName"/></h2>
	<pre>
    <xsl:value-of select="Property[@name='Source']"/>
    </pre>
  </xsl:template>
  -->
 
	<xsl:template match="Item">
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
