<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

  <xsl:key name="sources-by-module" match="Resolver/Source" use="@module"/>
  <xsl:key name="sources-by-fullname" match="Resolver/Source" use="@fullName"/>
  <xsl:key name="sources-by-module-fullname-name" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', @name)"/>
  <xsl:key name="sources-by-module-fullname" match="Resolver/Source" use="concat(@module, '-', @fullName)"/>
  <xsl:key name="sources-by-module-fullname-sql" match="Resolver/Source" use="concat(@module, '-', @fullName, '-', Sql)"/>

  <xsl:template match="/">
  	<dotml:graph file-name="metrics-graph" label="Metrics Model" rankdir="TB">
		<xsl:apply-templates select="/Project/Metrics"/>
	</dotml:graph>
  </xsl:template>
	
  <xsl:template match="Metrics">
	<dotml:node id="{@hash}" label="{@name}"/>
  </xsl:template>


  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
