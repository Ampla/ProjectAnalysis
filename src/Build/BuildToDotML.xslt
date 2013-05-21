<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dotml="http://www.martin-loetzsch.de/DOTML"
    >
    <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="input-color">#C4014B</xsl:variable>
  <xsl:variable name="output-bgcolor">#EEEEEE</xsl:variable>
  <xsl:variable name="output-color">#222222</xsl:variable>
  <xsl:variable name="xslt-color">#0000FF</xsl:variable>
  <xsl:variable name="working-color">#00FFFF</xsl:variable>
  <xsl:variable name="graph-color">#00FF00</xsl:variable>
  <xsl:variable name="other-color">#333333</xsl:variable>

  <xsl:variable name="cluster">false</xsl:variable>

  <xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
  <xsl:variable name="quote">'</xsl:variable>
  <xsl:variable name="dquote">"</xsl:variable>
  <xsl:key name="nodes-by-id" match="*[@id]" use="@id"/>

  <xsl:template name="dotml-structure">
    <dotml:graph rankdir="LR" >
      <dotml:cluster id="cluster-1">
        <dotml:node id="node-1" label="label" shape="parallelogram"/>
        <dotml:edge from="" to=""/>
      </dotml:cluster>
    </dotml:graph>
  </xsl:template>
  
  <xsl:template match="/">
    <dotml:graph file-name="Build.dot" rankdir="LR">
      <dotml:cluster id="Legend" label="Legend" style="dotted" color="{$other-color}">
        <dotml:node id="input_file" label="Input File" shape="box" color="{$input-color}" fontcolor="{$input-color}"/>
        <dotml:node id="stylesheet_file" label="Stylesheet File" shape="box" color="{$xslt-color}" fontcolor="{$xslt-color}"/>
        <dotml:node id="working_file" label="Working File" shape="box" color="{$working-color}" fontcolor="{$working-color}"/>
        <dotml:node id="output_file" label="Output File" shape="box" style="filled" fillcolor="{$output-bgcolor}"  color="{$output-color}" fontcolor="{$output-color}"/>
        <dotml:edge from="input_file" to="working_file"/>
        <dotml:edge from="stylesheet_file" to="working_file"/>
        <dotml:edge from="working_file" to="output_file"/>
      </dotml:cluster>

      <xsl:choose>
        <xsl:when test="$cluster='true'">
          <dotml:cluster id="files" label="Input files">
            <xsl:apply-templates select="/Project/Inputs/File"/>
          </dotml:cluster>
          <dotml:cluster id="stylesheets" label="Stylesheets">
            <xsl:apply-templates select="/Project/Stylesheets/File"/>
          </dotml:cluster>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/Project/Inputs/File"/>
          <xsl:apply-templates select="/Project/Stylesheets/File"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="/Project/Section"/>

    </dotml:graph>   
  </xsl:template>

  <xsl:template match="File">
    <xsl:variable name="id">
      <xsl:call-template name="escape-id">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="name(..)='Inputs'"><xsl:value-of select="$input-color"/></xsl:when>
        <xsl:when test="name(..)='Stylesheets'"><xsl:value-of select="$xslt-color"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$other-color"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <dotml:node id="{$id}" label="{@name}" shape="box" color="{$color}" fontcolor="{$color}"/>
  </xsl:template>

  <xsl:template match="Transform">
    <xsl:variable name="id">
      <xsl:call-template name="escape-id">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@directory='Output'">
        <dotml:node id="{$id}" label="{@name}" shape="box" style="filled" fillcolor="{$output-bgcolor}"  color="{$output-color}" fontcolor="{$output-color}"/>
      </xsl:when>
      <xsl:when test="@directory='Working'">
        <dotml:node id="{$id}" label="{@name}" shape="box" color="{$working-color}" fontcolor="{$working-color}"/>
      </xsl:when>
      <xsl:otherwise>
        <dotml:node id="{$id}" label="{@name}" shape="box" color="{$graph-color}" fontcolor="{$graph-color}"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="*[@id-ref]">
      <xsl:variable name="id-ref">
        <xsl:call-template name="escape-id">
          <xsl:with-param name="id" select="@id-ref"/>
        </xsl:call-template>
      </xsl:variable>
      <dotml:edge from="{$id-ref}" to="{$id}"/>
    </xsl:for-each>
    <xsl:apply-templates select="Output"/>
  </xsl:template>

  <xsl:template match="Output">
    <xsl:variable name="id">
      <xsl:call-template name="escape-id">
        <xsl:with-param name="id" select="@id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@directory='Output'">
        <dotml:node id="{$id}" label="{@name}" shape="box" style="filled" fillcolor="{$output-bgcolor}"  color="{$output-color}" fontcolor="{$output-color}"/>
      </xsl:when>
      <xsl:when test="@directory='Working'">
        <dotml:node id="{$id}" label="{@name}" shape="box" color="{$working-color}" fontcolor="{$working-color}"/>
      </xsl:when>
      <xsl:when test="@directory='Graph'">
        <dotml:node id="{$id}" label="{@name}" shape="box" color="{$graph-color}" fontcolor="{$graph-color}"/>
      </xsl:when>
      <xsl:otherwise>
        <dotml:node id="{$id}" label="{@name}" shape="box" color="{$other-color}" fontcolor="{$other-color}"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="id-ref">
      <xsl:call-template name="escape-id">
        <xsl:with-param name="id" select="../@id"/>
      </xsl:call-template>
    </xsl:variable>
    <dotml:edge from="{$id-ref}" to="{$id}"/>
  </xsl:template>

  <xsl:template match="Section">
    <xsl:choose>
      <xsl:when test="$cluster='true'">
        
    <dotml:cluster id="{concat('section_', position())}" label="{@name}" style="dotted" color="{$other-color}">
      <xsl:apply-templates select="Transform"/>
    </dotml:cluster>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="Transform"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='escape-id'>
    <xsl:param name='id'/>
    <xsl:value-of select="translate($id, concat('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.', $quote, $dquote), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_')"/>
  </xsl:template>

</xsl:stylesheet>
