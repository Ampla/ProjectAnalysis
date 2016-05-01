<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

  <xsl:output method="xml" indent="yes"/>

	<xsl:key name="items-by-id" match="Item" use="@id"/> 	  
	
  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
  <xsl:variable name="quote">'</xsl:variable>
  <xsl:variable name="dquote">"</xsl:variable>

  <xsl:include href='Include.Graphs.Colours.xslt'/>

  <xsl:variable name="source-items" select="//Item[Stream/PropertyLink]"/>
  <xsl:variable name="destination-items" select="key('items-by-id', $source-items/Stream/PropertyLink/@id)"/>
  
  <xsl:template match="/">
    <dotml:graph file-name="expression-graph" label="Expressions Graph" rankdir="LR" fontname="{$fontname}" fontcolor="{$focus-color}" fontsize="{$font-size-h1}" labelloc='t'>
      <xsl:apply-templates select="Project" mode="node"/>
      <xsl:apply-templates select="Project" mode="edge"/>
      <!--
      <xsl:apply-templates select="$source-items | $destination-items" mode="node"/>
      <xsl:apply-templates select="$source-items" mode="link"/>
      -->
    </dotml:graph>
	
  </xsl:template>
  
  <xsl:template match="comment()" mode="node"/>

  <xsl:template match="Project" mode="node">
    <xsl:apply-templates mode="node"/>
  </xsl:template>

  <xsl:template match="Project" mode="edge">
    <xsl:apply-templates select="$source-items" mode="edge"/>
  </xsl:template>

  <xsl:template match="Item" mode="edge">
    <xsl:apply-templates select="Stream" mode="edge"/>
  </xsl:template>

  <xsl:template match="Stream" mode="edge">
    <xsl:variable name="from" select="concat(../@hash, '_', @name)"/>
    <xsl:for-each select="PropertyLink">
      <xsl:variable name="to" select="key('items-by-id', @id)/@hash"/>
      <dotml:edge from="{$from}" to="{$to}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Item" mode="node">
    <xsl:variable name="properties" select="Property"/>
    <xsl:variable name="streams" select="Stream"/>
    <xsl:variable name="items" select="Item"/>
    <xsl:variable name="parent" select=".."/>
    <xsl:variable name="hierarchy" select="ancestor::Item"/>
    <xsl:variable name="ancestor-nodes" select="$hierarchy[Property|Stream]"/>
    <xsl:variable name="next-nodes" select="Item[Property|Stream]"/>
    
    <xsl:choose>
      <xsl:when test="$items and not($properties) and not($streams)">
        <xsl:choose>
          <xsl:when test="not($ancestor-nodes) and not($next-nodes)">
            <xsl:comment>
<xsl:value-of select="@fullName"/></xsl:comment>
            <xsl:apply-templates select="$items" mode="node"/>
          </xsl:when>
          <xsl:when test="not($ancestor-nodes) and $next-nodes">
            <dotml:cluster id="c_{@hash}" label="{@fullName}" clusterrank="none">
              <xsl:apply-templates select="$items" mode="node"/>
            </dotml:cluster>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>Cluster: <xsl:value-of select="@fullName"/>
</xsl:comment>
            <dotml:cluster id="c_{@hash}" label="{@fullName}" >
              <xsl:apply-templates select="$items" mode="node"/>
            </dotml:cluster>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$items and $properties and not($streams)">
        <dotml:cluster id="c_{@hash}" label="{@name}" >
          <xsl:apply-templates select="$items" mode="node"/>
        </dotml:cluster>
      </xsl:when>
      <xsl:when test="not($items) and $properties and not($streams)">
        <xsl:comment>Item: </xsl:comment>
        <dotml:node id="{@hash}" label="{@name}" shape='box' style='filled' fillcolor='{$focus-color}'
				fontname="{$fontname}" fontcolor="{$focus-text-color}" fontsize="{$font-size-h2}"/>
      </xsl:when>

      <xsl:when test="not($items) and $streams">

        <dotml:record style="filled" fillcolor="{$material-color}">
          <dotml:node id="{@hash}" label="{@name}"/>
          <xsl:apply-templates select="Stream" mode="node"/>
        </dotml:record>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Stream" mode="node">
    <dotml:node id="{../@hash}_{@name}" label="{@name}"/>
  </xsl:template>
  
  <!--
  <xsl:template match="Item" mode="node">
    <dotml:node id="{@hash}" label="{@name}"  />
  </xsl:template>

  <xsl:template match="Item" mode="link">
    <xsl:variable name="from" select="@hash"/>
    <xsl:for-each select="Stream/PropertyLink">
      <xsl:variable name="item" select="key('items-by-id', @id)"/>
      <xsl:variable name="to" select="$item/@hash"/>
      <dotml:edge from="{$from}" to="{$to}" />
    </xsl:for-each>
  </xsl:template>
  -->
  
  <!--
  <xsl:template match="Item[Item]">
	<dotml:cluster id="{@hash}" label="{@name}" style="dotted">
		<xsl:apply-templates select="Item">
			<xsl:sort select="count(descendant::*)"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="key('movements-by-location', @fullName)"/>
	</dotml:cluster>
  </xsl:template>
  

  <xsl:template match="Item[Materials/Material]">
	<dotml:cluster id="{@hash}" label="{@name}" style="filled" fillcolor="{$workcenter-color}">
		<dotml:record style="filled" fillcolor="{$material-color}">
			<xsl:apply-templates select="Materials/Material">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</dotml:record>
		<xsl:apply-templates select="key('movements-by-location', @fullName)"/>
	</dotml:cluster>
  </xsl:template>

    <xsl:template match="Material">
		<xsl:variable name="material-hash">
			<xsl:call-template name='material-hash'/>
		</xsl:variable>
	<dotml:node id="{$material-hash}" label="{@name}"  fontsize="10.0"/>
  </xsl:template>
  
	<xsl:template name="material-hash">
		<xsl:param name="wc-hash" select="../../@hash"/>
		<xsl:param name="mat-hash" select="@hash"/>
		<xsl:choose>
			<xsl:when test='$wc-hash'>
				<xsl:choose>
					<xsl:when test='$mat-hash'>
						<xsl:value-of select="concat($wc-hash, '_', $mat-hash)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$wc-hash"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'error'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
  <xsl:template match="Item[not(Item) and not(Materials/Material)]">
	<dotml:node id="{@hash}" label="{@name}" style="filled" fillcolor="{$workcenter-color}"/>
  </xsl:template>
  
  <xsl:template match="Movement">
	<xsl:variable name="source-hash">
		<xsl:call-template name="material-hash">
			<xsl:with-param name="wc-hash" select="Source/WorkCenter/@hash"/>
			<xsl:with-param name="mat-hash" select="Source/Material/@hash"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="destination-hash">
		<xsl:call-template name="material-hash">
			<xsl:with-param name="wc-hash" select="Destination/WorkCenter/@hash"/>
			<xsl:with-param name="mat-hash" select="Destination/Material/@hash"/>
		</xsl:call-template>
	</xsl:variable>
	<dotml:edge from="{$source-hash}" to="{$destination-hash}" />
  </xsl:template>
    -->
</xsl:stylesheet>
