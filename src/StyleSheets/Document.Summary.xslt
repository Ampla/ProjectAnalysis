<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />

  <xsl:param name="translate">false</xsl:param>

  <xsl:param name="lang">en</xsl:param>
  
  <xsl:include href="Document.Properties.Common.xslt"/>

  <xsl:variable name="liteView">Citect.Ampla.General.Server.Views.LiteView</xsl:variable>
  <xsl:variable name="customView">Citect.Ampla.General.Server.Views.CustomView</xsl:variable>
  
  <xsl:template match="/Project">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <xsl:if test="$lang">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
      <head>
        <title lang="en">Ampla Project Summary</title>
        <link rel="stylesheet" type="text/css" href="css/summary.css" media="screen,projector"/>
        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"/>
        <script type="text/javascript" src="lib/summary-layout.js"/>
      </head>
      <body>
        <h1 lang="" class="text">Ampla Project Summary</h1>
        <div id="layout-menu">
          <span>|<a id="show-layouts" href="#">Layout</a>
            <a id="menu-hide" href="#">Hide</a>|
          </span>
        </div>
        <hr/>
        <table>
          <tbody>
            <tr>
              <td>
                <xsl:apply-templates select="Item[@id and descendant::Item[(contains(@type, 'ReportingPoint') or (@type=$liteView) or (@type=$customView)) and (contains(@fullName, 'System Configuration.Templates.') = false)]]">
                  <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
                  <xsl:sort data-type="text" select="@name"/>
                </xsl:apply-templates>
              </td>
            </tr>
          </tbody>
        </table>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <span class="item" title="{@fullName}">
      <xsl:value-of select="@name"/>
      <xsl:if test="$translate='true' and @translation">
        <br/>
        <span lang="en" class="i-trans">
          <xsl:value-of select="@translation"/>
        </span>
      </xsl:if>
    </span>
    <xsl:variable name="items" select="Item[@id and descendant::Item[contains(@type, 'ReportingPoint') or (@type=$liteView) or (@type=$customView)]]"/>
    <xsl:variable name="desc-items" select="descendant::Item[@id and descendant::Item[contains(@type, 'ReportingPoint') or (@type=$liteView) or (@type=$customView)]]"/>
    <xsl:variable name="points" select="Item[contains(@type, 'ReportingPoint') or (@type=$liteView) or (@type=$customView)]"/>
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="@type='Citect.Ampla.Isa95.EnterpriseFolder'">enterprise</xsl:when>
        <xsl:when test="@type='Citect.Ampla.Isa95.SiteFolder'">site</xsl:when>
        <xsl:when test="@type='Citect.Ampla.Isa95.AreaFolder'">area</xsl:when>
        <xsl:otherwise>white</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($points) > 0">
        <xsl:for-each select="$points">
          <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
          <xsl:sort data-type="text" select="@name"/>
          <xsl:variable name="module">
            <xsl:choose>
              <xsl:when test="contains(@type,'Downtime')">downtime</xsl:when>
              <xsl:when test="contains(@type,'Production')">production</xsl:when>
              <xsl:when test="contains(@type,'Quality')">quality</xsl:when>
              <xsl:when test="contains(@type,'Metrics')">metrics</xsl:when>
              <xsl:when test="contains(@type,'Energy')">energy</xsl:when>
              <xsl:when test="contains(@type,'Maintenance')">maintenance</xsl:when>
              <xsl:when test="contains(@type,'Knowledge')">knowledge</xsl:when>
              <xsl:when test="contains(@type,'Planning')">planning</xsl:when>
              <xsl:when test="contains(@type,'Cost')">cost</xsl:when>
              <xsl:when test="contains(@type,'View')">view</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <div title="{@fullName}">
            <img class="icon" alt="{$module}" src="images/16/{$module}.png" />
            <span class="item point">
              <xsl:value-of select="@name"/>
              <xsl:if test="$translate='true' and @translation">
                <span lang="en" class="i-trans">
                  <xsl:value-of select="@translation"/>
                </span>
              </xsl:if>
            </span>
          </div>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="count($items)=0">
        <!-- no child items-->
      </xsl:when>
      <xsl:when test="count($desc-items) &lt; 5">
        <xsl:if test="count($items) &gt; 1">
          <span class="layout-across"/>
        </xsl:if>
        <table class="{$class}">
          <tbody>
            <tr>
              <xsl:for-each select="$items">
                <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
                <xsl:sort data-type="text" select="@name"/>
                <td>
                  <xsl:apply-templates select="."/>
                </td>
              </xsl:for-each>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <span class="layout-down"/>
        <table>
          <tbody>
            <xsl:for-each select="$items">
              <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
              <xsl:sort data-type="text" select="@name"/>
              <tr>
                <td>
                  <xsl:apply-templates select="."/>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
