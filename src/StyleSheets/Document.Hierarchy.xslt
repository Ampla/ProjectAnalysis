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
  
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>Ampla Project - Hierarchy</title>

        <link rel="stylesheet" type="text/css" href="css/jquery.treeview.css" media="screen,projector"/>
        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>

        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="lib/jquery.treeview.js"></script>
        <!-- 
        <link rel="stylesheet" type="text/css" href="css/jquery.layout.css"/>
        <link rel="stylesheet" type="text/css" href="css/smoothness/jquery-ui-1.7.2.custom.css"/>
        <script type="text/javascript" src="lib/jquery-ui-all.js"></script>
        -->
      </head>
      <body>
        <div id="nav">
          <div class="item-tree" id="navItems">
            <div class="treecontrol">
              <a class="nav-command" href="#">Collapse All</a>
              <a class="nav-command" href="#">Expand All</a>
              <a class="nav-command" href="#">Toggle All</a>
            </div>
            <br/>
            <div>
              <xsl:call-template name="item-href">
                <xsl:with-param name="hash">project</xsl:with-param>
                <xsl:with-param name="name">(Project)</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="itemCount">
                <xsl:with-param name="numItems" select="count(//Item[@id])"/>
              </xsl:call-template>
            </div>
            <ul id="item-treeview" class="item-tree">
              <xsl:apply-templates select="/Project/Item[@id]" mode="buildTree">
                <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
                <xsl:sort select="@name"/>
              </xsl:apply-templates>
            </ul>
          </div>
        </div>
        <script type="text/javascript">
          $("#navItems>ul").treeview({
          control: "#navItems div.treecontrol",
          collapsed: true
          });
        </script>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="buildTree">
    <xsl:variable name="items" select="Item[@id]"/>
    <xsl:variable name="links" select="linkTo/link"/>
    <li>
      <xsl:choose>
        <xsl:when test="(count($items) + count($links)) = 0">
          <xsl:call-template name="item-href">
            <xsl:with-param name="hash" select="@hash"/>
            <xsl:with-param name="name" select="@name"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <span>
            <xsl:call-template name="item-href">
              <xsl:with-param name="hash" select="@hash"/>
              <xsl:with-param name="name" select="@name"/>
            </xsl:call-template>
            <xsl:call-template name="itemCount">
              <xsl:with-param name="numItems" select="count(descendant::Item[@id])"/>
            </xsl:call-template>
            <xsl:call-template name="outputLinks">
              <xsl:with-param name="links" select="$links"/>
            </xsl:call-template>
          </span>
          <xsl:if test="$items">
            <ul>
              <xsl:apply-templates select="$items" mode="buildTree">
                <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
                <xsl:sort select="@name"/>
              </xsl:apply-templates>
            </ul>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

</xsl:stylesheet>
