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
	
	<xsl:variable name="code-items" select="//Item[@type = 'Citect.Ampla.StandardItems.Code']"/>
	<xsl:variable name="action-items" select="//Item[@type = 'Citect.Ampla.StandardItems.Action']"/>
  
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
          <xsl:with-param name="tab">Code Items</xsl:with-param>
        </xsl:call-template>
        
        <div class="container">
          <div class="tabbable">
            <ul class="nav nav-tabs" id="tabs">
              <xsl:if test="count($code-items) > 0">
                <li>
                  <a href="#code" data-toggle="tab">
                    <i class="icon-list"/>
                    <xsl:text> Code items </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($code-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="count($action-items) > 0">
                <li>
                  <a href="#actions" data-toggle="tab">
                    <i class=" icon-asterisk"/>
                    <xsl:text> Action items </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($action-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
            </ul>
            <div class="tab-content">
              <div class="tab-pane fade" id="code">
                <xsl:call-template name="list-item-with-details-collapsed">
                  <xsl:with-param name="items" select="$code-items"/>
                </xsl:call-template>
              </div>
              <div class="tab-pane fade" id="actions">
                <xsl:call-template name="list-item-with-details-collapsed">
                  <xsl:with-param name="items" select="$action-items"/>
                </xsl:call-template>
<!--
                <xsl:call-template name="list-items">
                  <xsl:with-param name="items" select="$action-items"/>
                </xsl:call-template>
                <xsl:apply-templates select="$action-items">
                  <xsl:sort select="@fullName"/>
                </xsl:apply-templates>
                -->
              </div>
            </div>
          </div>
        </div>
        <script src="jquery/jquery.js"/>
        <script src="bootstrap/js/bootstrap.js"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Code']" mode="collapse-details">
    <div class="pull-right">
      <xsl:choose>
        <xsl:when test="Property[@name='CompileAction']">
          <xsl:call-template name="item-badge">
            <xsl:with-param name="text">Not Compiled</xsl:with-param>
            <xsl:with-param name="color">red</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="item-badge">
            <xsl:with-param name="text">Compiled</xsl:with-param>
            <xsl:with-param name="color">green</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <pre class="prettyprint">
      <xsl:value-of select="Property[@name='Source']"/>
    </pre>
  </xsl:template>

  <xsl:template match="Item[@type = 'Citect.Ampla.StandardItems.Code']" mode="badge">
    <xsl:variable name="count">
      <xsl:call-template name="count-lines">
        <xsl:with-param name="text" select="Property[@name='Source']" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="item-badge">
      <xsl:with-param name="text" select="concat($count, ' lines')"/>
      <xsl:with-param name="color">grey</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
