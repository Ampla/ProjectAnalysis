<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"  />

	<xsl:include href="Document.Properties.Common.xslt"/> 
	
	<xsl:key name="documents-by-module" match="Item[@type = 'Citect.Ampla.General.Server.Document']" use="Property[@name='Module']"/>
	<xsl:variable name="dashboard-items" select="//Item[@type='Citect.Ampla.Metrics.Server.Dashboard']" />
	
	<xsl:variable name="document-items" select="//Item[@type = 'Citect.Ampla.General.Server.Document']"/>
	<xsl:variable name="modules" select="$document-items[generate-id() = generate-id(key('documents-by-module', Property[@name='Module'])[1])]/Property[@name='Module']" />

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
						<h2 class="text"><xsl:value-of select="$module"/> Documents (<xsl:value-of select="count($documents)"/>)</h2> 
						<xsl:call-template name="list-items">
							<xsl:with-param name="items" select="$documents"/>
						</xsl:call-template>	
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="count($dashboard-items) > 0">
					<h2 class="text">Metric Dashboards (<xsl:value-of select="count($dashboard-items)"/>)</h2>
					<xsl:call-template name="list-items">
						<xsl:with-param name="items" select="$dashboard-items"/>
					</xsl:call-template>	
				</xsl:if>
				<xsl:if test="count($document-items) > 0">
					<xsl:for-each select="$modules">
						<xsl:apply-templates select="key('documents-by-module', .)">
							<xsl:sort select="@fullName"/>
						</xsl:apply-templates>	
					</xsl:for-each>
				</xsl:if>

				<xsl:if test="count($dashboard-items) > 0">
					<xsl:apply-templates select="$dashboard-items">
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
				<xsl:apply-templates select="." mode="summary"/>
			  </a>
			</li>
		  </xsl:for-each>
		</ul>	
	</xsl:template>
 
	<xsl:template match="Item" mode='summary'>
		<span class='text'><xsl:call-template name="getItemFullName"/></span>
	</xsl:template>

	<!--
	<xsl:template match="Item[Property[@name='URL']]" mode='summary'>
		<div class='text'><xsl:call-template name="getItemFullName"/></div>
		
		<xsl:variable name="url" select="Property[@name='URL']"/>
		<ul><li><code><a href="{$url}"><xsl:value-of select="$url"/></a></code></li></ul>
	</xsl:template>
	-->
	<xsl:template match="Item">
		<hr/>
		<a name="{@hash}"/>
		<h3 class='text'><xsl:call-template name="getItemFullName"/></h3>
		<xsl:call-template name="outputItemProperties">
			<xsl:with-param name="sect">i-sect</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
