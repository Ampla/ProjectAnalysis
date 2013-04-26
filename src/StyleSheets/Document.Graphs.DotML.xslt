<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
				xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
				xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"				
				>

	<xsl:output method="xml" indent="yes"/>
	
	<xsl:param name="path-nxslt"   >..\..\Library\nxslt\nxslt.exe </xsl:param>
	<xsl:param name="path-graphviz">..\..\Library\GraphViz-2.30.1\bin\dot.exe -Tpng </xsl:param>
	<xsl:param name="path-dotml"   >..\..\Library\dotml-1.4\dotml2dot.xsl </xsl:param>

	<!-- default template to include files -->
	<xsl:template match='Item[@id]' mode='include'>
		<!-- Return 'Yes' to include this item as a graph --> 
	</xsl:template>

	<xsl:template match='Item[@id]' mode='graph'>
		<xsl:comment>
			<xsl:value-of select='@fullName'/> <xsl:text> doesn't have a dotml graph template</xsl:text>
		</xsl:comment>
	</xsl:template>
	
	<xsl:include href='Include.Graphs.Colours.xslt'/>
	<xsl:include href='Include.Graphs.File2Ampla.xslt'/>	
	
	<xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
	<xsl:variable name="quote">'</xsl:variable>
	<xsl:variable name="dquote">"</xsl:variable>

	
	<xsl:template match="/">
		<xsl:element name="Graphs">
			<xsl:for-each select="//Item[@id]">
				<xsl:variable name='include'>
					<xsl:apply-templates select='.' mode='include'/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$include = 'Yes'">
						<xsl:comment><xsl:value-of select='@fullName'/> is a match</xsl:comment>
						<xsl:variable name='filename'>
							<xsl:apply-templates select='.' mode='get-dotml-filename'/>
						</xsl:variable>
						<exsl:document href="{concat('Graphs\', $filename)}" method="xml" indent="yes">
							<xsl:apply-templates select='.' mode='graph'>
								<xsl:with-param name='filename' select='$filename'/>
							</xsl:apply-templates>
						</exsl:document>
						<xsl:call-template name='output-cmd'/>
					</xsl:when>
					<xsl:otherwise>
						<!--
							<xsl:comment><xsl:value-of select='@fullName'/> is not a match</xsl:comment>
						-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<!-- Default filenames -->
	<xsl:template match='Item[@id]' mode='get-dotml-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.dotml')"/>
	</xsl:template>

	<xsl:template match='Item[@id]' mode='get-gv-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.gv')"/>
	</xsl:template>

	<xsl:template match='Item[@id]' mode='get-png-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat('..\..\Output\Graphs\', $name, '.png')"/>
	</xsl:template>

	<xsl:template match='Item[@id]' mode='get-cmd-filename'>
		<xsl:param name='name' select='@hash'/>
		<xsl:value-of select="concat($name, '.cmd')"/>
	</xsl:template>
	
	<!--
		%nxslt% Working\metrics.dotml %dotml%\dotml2dot.xsl -o Working\metrics.gv
		%graphviz%\dot.exe -Tpng Working\metrics.gv -o Output\Project.Metrics.png
	-->
	<xsl:template name="output-cmd">
		<xsl:param name="dotml-filename"><xsl:apply-templates select='.' mode='get-dotml-filename'/></xsl:param>
		<xsl:param name="gv-filename"><xsl:apply-templates select='.' mode='get-gv-filename'/></xsl:param>
		<xsl:param name="png-filename"><xsl:apply-templates select='.' mode='get-png-filename'/></xsl:param>
		<xsl:param name="cmd-filename"><xsl:apply-templates select='.' mode='get-cmd-filename'/></xsl:param>
		<xsl:variable name='command'>
			<xsl:text>REM Convert "</xsl:text><xsl:value-of select="$dotml-filename"/>" to "<xsl:value-of select="$png-filename"/><xsl:text>"</xsl:text>
			<xsl:value-of select="concat($crlf, $path-nxslt, $dotml-filename, ' ', $path-dotml, ' -o ', $gv-filename)" /> 
			<xsl:value-of select="concat($crlf, $path-graphviz, $gv-filename, ' ', ' -o ', $dquote, $png-filename, $dquote)" /> 
		</xsl:variable>
		<exsl:document href="{concat('Graphs\', $cmd-filename)}" method="text" >
			<xsl:value-of select='$command'/>
		</exsl:document>
		<Graph input='{$dotml-filename}' output='{$png-filename}'>
			<xsl:value-of select='$command'/>
		</Graph>
	</xsl:template>
	
	<xsl:template name='escape-label'>
		<xsl:param name='label'/>
		<xsl:value-of select="translate($label, concat('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _\', $quote, $dquote), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _/')"/>
	</xsl:template>
		
</xsl:stylesheet>
