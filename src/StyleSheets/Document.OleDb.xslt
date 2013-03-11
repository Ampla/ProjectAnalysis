<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />
                  
  <xsl:template match="/">

    <html>
      <head>
        <title>Ampla Project - OLEDB Items</title>

        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>
      </head>
      <body>
        <H1>Ampla Project - OleDb DataSources</H1>
        <a name="top"/>
          <table>
            <tr>
              <th>DataSource</th>
              <th>Database</th>
              <th>Variables</th>
            </tr>

          <xsl:for-each select="/OleDb/DataSources/DataSource">
            <xsl:sort data-type="text" select="@fullName"/>
            <tr>
              <td>
                <a href="#{@hash}">
                  <xsl:value-of select="@fullName"/>
                </a>
              </td>
              <td>
                <a href="#{Connection/@hash}">
                  <xsl:value-of select="Connection/Property[@name='InitialCatalog']"/>
                </a>
              </td>
              <td>
                <xsl:value-of select="count(Variables/Variable)"/> Variable(s)
              </td>
            </tr>
          </xsl:for-each>
          </table>
        <xsl:apply-templates select="/OleDb/DataSources/DataSource">
          <xsl:sort data-type="text" select="@fullName"/>
        </xsl:apply-templates>
        <hr/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="DataSource">
    <hr/>
    <a name="{@hash}"/>
    <a href="#top">[top]</a>
    <h2>
      <xsl:value-of select="@fullName"/>
    </h2>
    <xsl:call-template name="property-table"/>
    <xsl:apply-templates select="Connection"/>
    <xsl:apply-templates select="Variables"/>
  </xsl:template>

  <xsl:template match="Connection">
    <div>
      <a name="{@hash}"/>
      <xsl:value-of select="@name"/>
    </div>
    <xsl:call-template name="property-table"/>
  </xsl:template>

  <xsl:template match="Variables">
    <table>
      <tbody>
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Data Type</th>
          <th>Sql</th>
          <xsl:for-each select="Variable">
            <tr>
              <td>
                <xsl:value-of select="position()"/>
              </td>
              <td>                                                 
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:value-of select="Property[@name='SampleTypeCode']"/>
              </td>
              <td>
                <xsl:element name="pre"><xsl:value-of select="Property[@name='Address']"/></xsl:element>
              </td>
            </tr>
          </xsl:for-each>
        </tr>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="property-table">
    <xsl:param name="properties" select="Property"/>
    <xsl:if test="$properties">
      <table>
        <tbody>
          <tr>
            <xsl:for-each select="$properties">
              <xsl:sort data-type="text" select="@name"/>
              <th>
                <xsl:value-of select="@name"/>
              </th>
            </xsl:for-each>
          </tr>
          <tr>
            <xsl:for-each select="$properties">
              <xsl:sort data-type="text" select="@name"/>
              <td>
                <xsl:value-of select="."/>
              </td>
            </xsl:for-each>
          </tr>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
