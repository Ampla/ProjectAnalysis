<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:element name="OleDb">
      <xsl:element name="DataSources">
        <xsl:for-each select="//Item[@type='Citect.Ampla.Connectors.OleDbConnector.OleDbDataSource']">
          <xsl:sort data-type="text" select="@fullName"/>
          <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
          <xsl:sort data-type="text" select="@name"/>
          <xsl:element name="DataSource">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="Property">
              <xsl:sort data-type="text" select="@name"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="Item[@type='Citect.Ampla.Connectors.OleDbConnector.OleDbConnection']">
              <xsl:sort data-type="text" select="@name"/>
            </xsl:apply-templates>
            <xsl:element name="Variables">
              <xsl:apply-templates select="Item[@type='Citect.Ampla.Connectors.OleDbConnector.OleDbVariable']">
                <xsl:sort data-type="text" select="@name"/>
              </xsl:apply-templates>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Connectors.OleDbConnector.OleDbConnection']">
    <xsl:element name="Connection">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="Property">
        <xsl:sort data-type="text" select="@name"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Connectors.OleDbConnector.OleDbVariable']">
    <xsl:element name="Variable">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="Property">
        <xsl:sort data-type="text" select="@name"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>


  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
