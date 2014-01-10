<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output
     method="html"
     doctype-system="about:legacy-compat"
     encoding="UTF-8"
     indent="yes" />

  <xsl:include href="Bootstrap.Common.xslt"/>

  <xsl:include href="Document.Properties.Common.xslt"/> 

  <xsl:variable name="variable-types" select="/Project/Reference/Type[contains(@name, 'Variable')]"/>
  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <title>Ampla Project Module Analysis</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link href="bootstrap/css/bootstrap.css" rel="stylesheet"/>
        <link href="bootstrap/css/bootstrap-responsive.css" rel="stylesheet"/>
        <style type="text/css">
          body {
          padding-top: 60px;
          padding-bottom: 40px;
          }
          .sidebar-nav {
          padding: 9px 0;
          }

          @media (max-width: 980px) {
          /* Enable use of floated navbar text */
          .navbar-text.pull-right {
          float: none;
          padding-left: 5px;
          padding-right: 5px;
          }
          }
        </style>
      </head>
      <body>
        <xsl:call-template name="build-menu">
          <xsl:with-param name="tab">Variables</xsl:with-param>
        </xsl:call-template>
        
        <div class="container">
          <div class="tabbable">
            <ul class="nav nav-tabs" id="tabs">
              <li>
                <a href="#home" data-toggle="tab">
                  <i class="icon-home"/>
                </a>
              </li>
              <xsl:for-each select="$variable-types">
                <li>
                  <a href="#{@name}" data-toggle="tab">
                    <i class="icon-tag"/>
                    <xsl:variable name="name">
                      <xsl:call-template name="use-short-name"/>
                    </xsl:variable>
                    <xsl:value-of select="concat(' ', $name, ' ')"/>
                    <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:for-each>
            </ul>
            <div class="tab-content">
              <div class="tab-pane fade" id="home">
                <p>Variables found in the project:</p>
                <ul>
                  <xsl:for-each select="$variable-types">
                    <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
                    <li>
                        <xsl:value-of select="@name"/>
                      <span class="muted">
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="count ($items)"/>
                        <xsl:text> item(s)</xsl:text>
                      </span>
                    </li>
                  </xsl:for-each>
                </ul>
              </div>
              <xsl:for-each select="$variable-types">
                <div class="tab-pane fade" id="{@name}">
                  <xsl:variable name="items" select="key('all-items-by-type', @fullName)"/>
                  <xsl:call-template name="list-item-with-details-collapsed">
                    <xsl:with-param name="items" select="$items"/>
                  </xsl:call-template>
                </div>
              </xsl:for-each>
            </div>
          </div>
        </div>
        <script src="jquery/jquery.js"/>
        <script src="bootstrap/js/bootstrap.js"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Item[contains(@type, 'Variable')]" mode="badge">
    <xsl:variable name="data-type">
      <xsl:choose>
        <xsl:when test="Property[@name='SampleTypeCode']">
          <xsl:value-of select="Property[@name='SampleTypeCode']"/>
        </xsl:when>
        <xsl:otherwise>Single</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="$data-type='Int32'">blue</xsl:when>
        <xsl:when test="$data-type='String'">green</xsl:when>
        <xsl:when test="$data-type='Single'">orange</xsl:when>
        <xsl:when test="$data-type='Double'">red</xsl:when>
        <xsl:when test="$data-type='Boolean'">black</xsl:when>
        <xsl:otherwise>grey</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:call-template name="item-label">
      <xsl:with-param name="text" select="$data-type"/>
      <xsl:with-param name="color" select="$color"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[contains(@type, 'Variable')]" mode="badge-position">
    <xsl:text>pull-right</xsl:text>
  </xsl:template>

  <xsl:template name="use-short-name">
    <xsl:param name="longname">
      <xsl:value-of select="@name"/>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$longname = 'OpcHdaVariable'">OPC-HDA</xsl:when>
      <xsl:when test="$longname = 'OpcDaVariable'">OPC-DA</xsl:when>
      <xsl:when test="$longname = 'ScadaVariable'">SCADA</xsl:when>
      <xsl:when test="$longname = 'OleDbVariable'">OleDB</xsl:when>
      <xsl:when test="$longname = 'StoredVariable'">Stored</xsl:when>
      <xsl:when test="$longname = 'CalculatedVariable'">Calculated</xsl:when>
      <xsl:when test="$longname = 'Database2AmplaRuntimeDataVariable'">DB to Runtime</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$longname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
