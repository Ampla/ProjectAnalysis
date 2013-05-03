<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
				xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
				xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"				
				>

	<xsl:output method="xml" indent="yes"/>
	
	<xsl:variable name="path-nxslt"    >..\..\Library\nxslt\nxslt.exe </xsl:variable>
	<xsl:variable name="path-graphviz" >..\..\Library\GraphViz-2.30.1\bin\</xsl:variable>
	<xsl:variable name="graphviz-options"> -Tpng </xsl:variable>
	<xsl:variable name="path-dotml"    >..\..\Library\dotml-1.4\dotml2dot.xsl </xsl:variable>
	<xsl:variable name="path-png"		>..\..\Output\Graphs\</xsl:variable>

	<xsl:include href='Include.Graphs.Colours.xslt'/>
	<xsl:include href='Include.Graphs.Defaults.xslt'/>
	
	<!-- specific templates for graphs -->
	<xsl:include href='Include.Graphs.File2Ampla.xslt'/>	
	<xsl:include href='Include.Graphs.ReportingPoint.xslt'/>	
	<xsl:include href='Include.Graphs.Project.xslt'/>	

	<!-- 
	
	<xsl:include href='Include.Graphs.<Type>.xslt'/>
	
	<xsl:template match="Item[@type='<Type>']" mode='include'>Yes</xsl:template>
	
	<xsl:template match="Item[@type='<Type>']" mode="graph">
		<dotml:graph>
			...
		</dotml:graph>
	</xsl:template>		
	-->
	
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
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
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
		<xsl:variable name="graphviz-command">
			<xsl:value-of select='$path-graphviz' />
			<xsl:apply-templates select='.' mode='graph-type'/><xsl:text>.exe</xsl:text>
			<xsl:value-of select='$graphviz-options'/><xsl:text> </xsl:text>
			<xsl:apply-templates select='.' mode='graph-options'/>
		</xsl:variable>
		<xsl:variable name='command'>
			<xsl:text>REM Convert "</xsl:text><xsl:value-of select="$dotml-filename"/>" to "<xsl:value-of select="concat($path-png, $png-filename)"/><xsl:text>"</xsl:text>
			<xsl:value-of select="concat($crlf, $path-nxslt, $dotml-filename, ' ', $path-dotml, ' -o ', $gv-filename)" /> 
			<xsl:value-of select="concat($crlf, $graphviz-command, $gv-filename, ' ', ' -o ', $dquote, $path-png, $png-filename, $dquote)" /> 
		</xsl:variable>
		<exsl:document href="{concat('Graphs\', $cmd-filename)}" method="text" >
			<xsl:value-of select='$command'/>
		</exsl:document>
		<Graph input='{$dotml-filename}' output='{concat($path-png, $png-filename)}'>
			<xsl:value-of select='$command'/>
		</Graph>
	</xsl:template>
	
	<xsl:template name='escape-label'>
		<xsl:param name='label'/>
		<xsl:value-of select="translate($label, concat('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _\', $quote, $dquote), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _/')"/>
	</xsl:template>
		
</xsl:stylesheet>
