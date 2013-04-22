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

	<xsl:variable name="record-color">#EEEEEE</xsl:variable>
	<xsl:variable name="border-color">#AAAAAA</xsl:variable>
	<xsl:variable name="background-color">#FFFFFF</xsl:variable>
	<xsl:variable name="material-color">#87D200</xsl:variable>
	<xsl:variable name="material-other">#CCCCCC</xsl:variable>
	<xsl:variable name="workcenter-color">#2FB4E9</xsl:variable>
	
	<xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
	<xsl:variable name="quote">'</xsl:variable>
	<xsl:variable name="dquote">"</xsl:variable>

	<xsl:key name="materials-by-hash" match="Material" use="@hash"/>
	<xsl:key name="movements-by-location" match="Movement" use="Location"/> 	  
	<xsl:key name="movements-by-source-material" match="Movement" use="Source/Material/@hash"/> 	  
	<xsl:key name="movements-by-destination-material" match="Movement" use="Destination/Material/@hash"/> 	  

	<xsl:key name="items-by-hash" match="Item" use="@hash"/>
	
  	<xsl:variable name="workcentres" select="/Inventory/Hierarchy/descendant::Item[not(Item)]"/>
    <xsl:variable name="clusters" select="/Inventory/Hierarchy/descendant::Item[Item]"/>
	<xsl:variable name="materials" select="//Material[generate-id() = generate-id(key('materials-by-hash', @hash)[1])]"/>
  
	<xsl:template match="/">
		<xsl:element name="FileList">
			<xsl:for-each select="$materials">
				<xsl:sort select="@name"/>
				<xsl:variable name="material-hash" select="@hash"/>
				<xsl:variable name="dotml-filename" select="concat( @hash, '.dotml')"/>
				<xsl:variable name="gv-filename" select="concat(@hash, '.gv')"/>
				<xsl:variable name="png-filename" select="concat('..\..\Output\Graphs\Material.', @name, '.png')"/>
				<xsl:variable name="cmd-filename" select="concat('Graphs\', @hash, '.cmd')"/>
				
				<xsl:variable name="command">
					<xsl:call-template name="output-cmd">
						<xsl:with-param name="cmd-filename" select="$cmd-filename"/>
						<xsl:with-param name="dotml-filename" select="$dotml-filename"/>
						<xsl:with-param name="gv-filename" select="$gv-filename"/>
						<xsl:with-param name="png-filename" select="$png-filename"/>
					</xsl:call-template>
				</xsl:variable>
				
				<File name="{$dotml-filename}" type="dotml" material="{@name}">
					<xsl:value-of select='$command'/>
				</File>				
				<xsl:call-template name="output-dotml">
					<xsl:with-param name="material-hash" select="$material-hash"/>
					<xsl:with-param name="filename" select="concat('Graphs\', $dotml-filename)"/>
					<xsl:with-param name="material" select="@name"/>
				</xsl:call-template>	

				<exsl:document href="{$cmd-filename}" method="text" >
					<xsl:value-of select='$command'/>
				</exsl:document>

			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="output-dotml">
		<xsl:param name="material-hash"/>
		<xsl:param name="filename"/>
		<xsl:param name="material"/>
		<exsl:document href="{$filename}" method="xml" indent="yes">
			<dotml:graph file-name="{$filename}" label="Material usage: {@name}" rankdir="LR" fontname="Arial" fontsize="14.0">
				<dotml:cluster id="{concat($material-hash, '_cluster')}" label="{@name}" style="solid" bgcolor="{$material-color}" labelloc="t">
					<xsl:variable name='material' select="key('materials-by-hash', @hash)"/>
					<xsl:variable name='source-movements' select="key('movements-by-source-material', @hash)"/>
					<xsl:variable name='destination-movements' select="key('movements-by-destination-material', @hash)"/>
					<xsl:variable name='workcenter-hashs' 
										select="	  $source-movements/Source/WorkCenter/@hash 
													| $source-movements/Destination/WorkCenter/@hash
													| $destination-movements/Source/WorkCenter/@hash 
													| $destination-movements/Destination/WorkCenter/@hash"/>
					<xsl:variable name="workcenters" select="key('items-by-hash', $workcenter-hashs)"/>
					
					<xsl:variable name="other-materials" select="$source-movements/Destination/Material | $destination-movements/Source/Material"/>
					
					<xsl:call-template name="build-sub-hierarchy">
						<xsl:with-param name='context' select='/Inventory/Hierarchy/Item'/>
						<xsl:with-param name='children' select='$material | $workcenters | $other-materials'/>
						<xsl:with-param name='material-hash' select='@hash'/>
					</xsl:call-template>
				</dotml:cluster>
				
			</dotml:graph>
		</exsl:document>
	</xsl:template>

	<!--
		%nxslt% Working\metrics.dotml %dotml%\dotml2dot.xsl -o Working\metrics.gv
		%graphviz%\dot.exe -Tpng Working\metrics.gv -o Output\Project.Metrics.png
	-->
	<xsl:template name="output-cmd">
		<xsl:param name="cmd-filename"/>
		<xsl:param name="dotml-filename"/>
		<xsl:param name="gv-filename"/>
		<xsl:param name="png-filename"/>

		<xsl:text>REM Convert "</xsl:text><xsl:value-of select="$dotml-filename"/>" to "<xsl:value-of select="$png-filename"/><xsl:text>"</xsl:text>

		<xsl:value-of select="concat($crlf, $path-nxslt, $dotml-filename, ' ', $path-dotml, ' -o ', $gv-filename)" /> 
		<xsl:value-of select="concat($crlf, $path-graphviz, $gv-filename, ' ', ' -o ', $dquote, $png-filename, $dquote)" /> 
	</xsl:template>
		
	<xsl:template name="build-sub-hierarchy">
		<xsl:param name="context"/>
		<xsl:param name="children"/>
		<xsl:param name="material-hash"/>
		<xsl:variable name="selected" select="$children/ancestor-or-self::Item"/>
		<xsl:for-each select="$context">
			<xsl:sort select="@name"/>
			<xsl:variable name="item" select="."/>
			<xsl:variable name="hash" select="@hash"/>
			<xsl:choose>
				<xsl:when test="$selected[@hash = $hash]">
					<dotml:cluster id="{concat($material-hash, '_', @hash)}" label="{@name}" style="solid" bgcolor="{$background-color}" color="{$border-color}" fontsize="12.0"> 
						<xsl:call-template name="build-sub-hierarchy">
							<xsl:with-param name="context" select="$item/Item"/>
							<xsl:with-param name="children" select="$children"/>
							<xsl:with-param name="material-hash" select="$material-hash"/>
						</xsl:call-template>
						<xsl:if test="Materials/Material">
							<dotml:cluster id="{concat($material-hash, '_', @hash, '_cluster')}" style="filled" color="{$record-color}">
								<xsl:for-each select="Materials/Material">
									<xsl:variable name="color">
										<xsl:choose>
											<xsl:when test="@hash = $material-hash">
												<xsl:value-of select="$material-color"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$material-other"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<dotml:node id="{concat($material-hash, '_', $item/@hash, '_', @hash)}" label="{@name}" shape="box" style="filled" color="{$color}" fontsize="10.0"/>
								</xsl:for-each>
							</dotml:cluster>
						</xsl:if>
						<xsl:apply-templates select="key('movements-by-location', $item/@fullName)">
							<xsl:with-param name="material-hash" select="$material-hash"/>
						</xsl:apply-templates>
					</dotml:cluster>  
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
  
	<xsl:template name="material-hash">
		<xsl:param name="prefix"></xsl:param>
		<xsl:param name="wc-hash" select="../../@hash"/>
		<xsl:param name="mat-hash" select="@hash"/>
		<xsl:choose>
			<xsl:when test='$wc-hash'>
				<xsl:choose>
					<xsl:when test='$mat-hash'>
						<xsl:value-of select="concat($prefix, $wc-hash, '_', $mat-hash)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($prefix, $wc-hash)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'error'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template match="Movement">
		<xsl:param name='material-hash'/>
		<xsl:choose>
			<xsl:when test="(Source/Material[@hash = $material-hash]) or (Destination/Material[@hash=$material-hash])">
				<xsl:variable name="source-hash">
					<xsl:call-template name="material-hash">
						<xsl:with-param name='prefix' select="concat($material-hash, '_')"/>
						<xsl:with-param name="wc-hash" select="Source/WorkCenter/@hash"/>
						<xsl:with-param name="mat-hash" select="Source/Material/@hash"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="destination-hash">
					<xsl:call-template name="material-hash">
						<xsl:with-param name='prefix' select="concat($material-hash, '_')"/>
						<xsl:with-param name="wc-hash" select="Destination/WorkCenter/@hash"/>
						<xsl:with-param name="mat-hash" select="Destination/Material/@hash"/>
					</xsl:call-template>
				</xsl:variable>
				<dotml:edge from="{$source-hash}" to="{$destination-hash}" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
  
</xsl:stylesheet>
