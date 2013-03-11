<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />
   
  <xsl:include href="Document.Properties.Common.xslt"/> 
  <xsl:include href="Document.Properties.ExtraInfo.xslt"/>

  <xsl:variable name="outputAllProperties">true</xsl:variable>
  <xsl:variable name="showCodeSource">false</xsl:variable>


  <xsl:template match="/">
    <html>
      <head>
        <title>Ampla Project Browser</title>

        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>

        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="lib/jquery-ui-all.js"></script>
        <script type="text/javascript" src="lib/chili/jquery.chili-2.2.js"></script>
        <script type="text/javascript" src="lib/browser.js"></script>
      </head>
      <body>
        <div id="content">
          <div id="docs">
            <ul>
              <xsl:apply-templates select="/Project"/>
              <xsl:apply-templates select="/Project/Item[@id]">
                <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
                <xsl:sort select="@name"/>
              </xsl:apply-templates>
            </ul>
          </div>
        </div>
      </body>

    </html>
  </xsl:template>

  <xsl:template match="Project">
    <li id="project">
      <span class="i-head">
        <xsl:call-template name="item-href">
          <xsl:with-param name="hash">#project</xsl:with-param>
          <xsl:with-param name="name">(Project)</xsl:with-param>
          <xsl:with-param name="site"></xsl:with-param>
        </xsl:call-template>
      </span>
      <br/>
      <div class="i-sect">Properties</div>
      <table class="p-tab">
        <tr>
          <th>Name</th>
          <th>Value</th>
        </tr>
        <xsl:for-each select="Properties/ProjectProperty">
          <tr>
            <xsl:if test="position() mod 2 = 1">
              <xsl:attribute name="class">tr-alt</xsl:attribute>
            </xsl:if>
            <td class="p-key">
              <xsl:value-of select="@name"/>
            </td>
            <td class="p-val">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <xsl:if test="$includeChildItems = 'true' and Item">
        <div class="i-sect">Root Items</div>
        <xsl:call-template name="listChildItems"/>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="Item[@id]">

    <xsl:variable name="hash">
      <xsl:call-template name="get-hash"/>
    </xsl:variable>

    <xsl:variable name="sect">
      <xsl:choose>
        <xsl:when test="@class">c-sect</xsl:when>
        <xsl:otherwise>i-sect</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <li id="{$hash}">
      
      <xsl:call-template name="outputItemHeader"/>

      <xsl:call-template name="outputItemProperties">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>

      <xsl:call-template name="outputItemLinks">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>

      <xsl:call-template name="outputItemChildren">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>

      <xsl:apply-templates mode="extra-info" select="."/>
      
    </li>
    <xsl:apply-templates select="Item[@id]"/>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.General.Server.DecisionMatrix']">

    <xsl:variable name="hash">
      <xsl:call-template name="get-hash"/>
    </xsl:variable>

    <xsl:variable name="sect">
      <xsl:choose>
        <xsl:when test="@class">c-sect</xsl:when>
        <xsl:otherwise>i-sect</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <li id="{$hash}">

      <xsl:call-template name="outputItemHeader"/>

      <xsl:call-template name="outputItemProperties">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>
      
      <!-- Insert Decision Matrix output here...-->
      <xsl:if test="Input">
        <xsl:variable name="inputs" select="Input"/>
        <xsl:variable name="rules" select="Item[@type='Citect.Ampla.General.Server.DecisionMatrixRule']"/>
        <xsl:variable name="matrix" select="."/>
        <div class="i-sect">Rules</div>
        <table class="p-tab">
          <tr>
            <th>#</th>
            <th>Rule</th>
            <xsl:for-each select="$inputs">
              <xsl:sort data-type="number" select="@displayOrder"/>
              <xsl:sort select="@name"/>
              <xsl:variable name="name" select="@name"/>
              <xsl:variable name="item" select="$matrix/Item[@name=$name]"/>
              <th>
                <xsl:call-template name="link-to-fullpath">
                  <xsl:with-param name="item" select="$item"/>
                  <xsl:with-param name="name" select="$name"/>
                  <xsl:with-param name="translation" select="$item/@translation"/>
                </xsl:call-template>
              </th>
            </xsl:for-each>
          </tr>
          <xsl:for-each select="$rules">
            <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
            <xsl:sort select="@name"/>
            <xsl:variable name="rule" select="."/>
            <tr>
              <td>
                <xsl:value-of select="position()"/>
              </td>
              <xsl:if test="position() mod 2 = 1">
                <xsl:attribute name="class">tr-alt</xsl:attribute>
              </xsl:if>
              <td>
                <xsl:call-template name="link-to-fullpath">
                  <xsl:with-param name="item" select="$rule"/>
                  <xsl:with-param name="name" select="$rule/@name"/>
                  <xsl:with-param name="translation" select="$rule/@translation"/>
                </xsl:call-template>
              </td>
              <xsl:for-each select="$inputs">
                <xsl:sort data-type="number" select="@displayOrder"/>
                <xsl:sort select="@name"/>
                <xsl:variable name="input" select="@name"/>
                <xsl:variable name="inputValue" select="$rule/Property[@name=$input]"/>
                <td class="{$inputValue}">
                  <xsl:choose>
                    <xsl:when test="$inputValue">
                      <xsl:value-of select="$inputValue"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>Ignore</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:if>
      
      <xsl:call-template name="outputItemLinks">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>

      <xsl:call-template name="outputItemChildren">
        <xsl:with-param name="sect" select="$sect"/>
      </xsl:call-template>

    </li>
    <xsl:apply-templates select="Item[@id]"/>
  </xsl:template>


</xsl:stylesheet>
