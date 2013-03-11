<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    indent="no"
  />

  <xsl:include href="Document.Common.xslt"/>

  <xsl:key name="items-by-type" match="Item"  use="@type"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Ampla Project - Item Types</title>
        <link rel="stylesheet" type="text/css" href="css/jquery.treeview.css" media="screen,projector"/>
        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>
        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="lib/jquery.treeview.js"></script>
      </head>
      <body>
        <div id="nav">
          <div class="type-tree" id="navTypes">
            <div class="treecontrol">
              <a class="nav-command" href="#">Collapse All</a>
              <a class="nav-command" href="#">Expand All</a>
              <a class="nav-command" href="#">Toggle All</a>
            </div>
            <br/>
            <ul>
              <xsl:for-each select="/Project/Reference">
                <xsl:sort select="@name" />
                <li>
                  <span>
                    <xsl:value-of select="@name"/>
                  </span>
                  <ul>
                    <xsl:apply-templates select="Type">
                      <xsl:sort select="@name"/>
                    </xsl:apply-templates>
                  </ul>
                </li>
              </xsl:for-each>
            </ul>
          </div>
        </div>
        <hr/>
        <div id="lic">
          <div>Modules</div>
          <div class="type-tree" id="licenses">
            <ul>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Downtime</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Production</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Metrics</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Energy</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Quality</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Maintenance</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Knowledge</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Planning</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="getLicenses">
                <xsl:with-param name="module">Cost</xsl:with-param>
              </xsl:call-template>
            </ul>
          </div>
        </div>
        <script type="text/javascript">
          $("#navTypes>ul").treeview({
          control: "#navTypes div.treecontrol",
          collapsed: true
          });
          $("#licenses>ul").treeview({
          collapsed: true
          });
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="getLicenses">
    <xsl:param name="module"></xsl:param>
    <xsl:param name="reportingPoint" select="concat('Citect.Ampla.', $module, '.Server.', $module, 'ReportingPoint')"/>
    <xsl:variable name="items" select="key('items-by-type', $reportingPoint)"/>
    <xsl:if test="count($items) > 0">
        <li>
          <span>
            <xsl:value-of select="$module"/>
            <xsl:call-template name="itemCount">
              <xsl:with-param name="numItems" select="count($items)"/>
            </xsl:call-template>
          </span>
          <ul>
            <xsl:for-each select="$items">
              <xsl:sort select="@fullName"/>
              <li>
                <xsl:call-template name="item-href">
                  <xsl:with-param name="name" select="@fullName"/>
                  <xsl:with-param name="translation">
                    <xsl:call-template name="getTranslatedFullName">
                      <xsl:with-param name="item" select="."/>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="outputLinks">
                  <xsl:with-param name="links" select="linkTo/link"/>
                </xsl:call-template>
              </li>
            </xsl:for-each>
          </ul>
        </li>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="Type">
    <xsl:variable name="type" select="@fullName"/>
    <xsl:variable name="items" select="key('items-by-type', $type)"/>
    <li>
      <span>
        <xsl:value-of select="@name"/>
        <xsl:call-template name="itemCount">
          <xsl:with-param name="numItems" select="count($items)"/>
        </xsl:call-template>
      </span>
      <ul>
        <xsl:for-each select="$items">
          <xsl:sort select="@fullName"/>
          <li>
            <xsl:call-template name="item-href">
              <xsl:with-param name="name" select="@fullName"/>
              <xsl:with-param name="translation">
                <xsl:call-template name="getTranslatedFullName">
                  <xsl:with-param name="item" select="."/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="outputLinks">
              <xsl:with-param name="links" select="linkTo/link"/>
            </xsl:call-template>
          </li>
        </xsl:for-each>
      </ul>
    </li>
  </xsl:template>

</xsl:stylesheet>
