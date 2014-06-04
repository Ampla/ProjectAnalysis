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

  <xsl:key name="items-by-fullName" match="Item[@fullName]" use="@fullName"/>

  <xsl:variable name="enterprise-folder">Citect.Ampla.Isa95.EnterpriseFolder</xsl:variable>
  <xsl:variable name="apps-folder">Citect.Ampla.General.Server.ApplicationsFolder</xsl:variable>
  <xsl:variable name="site-folder">Citect.Ampla.Isa95.SiteFolder</xsl:variable>
  <xsl:variable name="area-folder">Citect.Ampla.Isa95.AreaFolder</xsl:variable>
  <xsl:variable name="process-cell">Citect.Ampla.Isa95.ProcessCell</xsl:variable>
  <xsl:variable name="production-line">Citect.Ampla.Isa95.ProductionLine</xsl:variable>
  <xsl:variable name="storage-zone">Citect.Ampla.Isa95.StorageZone</xsl:variable>

  <xsl:variable name="root-items" select="/Project/Item[@type=$enterprise-folder or @type=$apps-folder]"/>
  <xsl:variable name="folders" select="$root-items/descendant-or-self::Item[
                @type=$enterprise-folder or 
                @type=$apps-folder or 
                @type=$site-folder or
                @type=$area-folder or
                @type=$process-cell or
                @type=$production-line or
                @type=$storage-zone
                ]" />
  
  <xsl:variable name="folders-with-equip-id" select="$folders[Property[@name='EquipmentId']]"/>
  <xsl:variable name="folders-without-equip-id" select="$folders[not(Property[@name='EquipmentId'])]"/>

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
          <xsl:with-param name="tab">Equipment Id</xsl:with-param>
        </xsl:call-template>
        
        <div class="container">
          <xsl:call-template name="table-for-equipment-id">
            <xsl:with-param name="items" select="$folders"/>
          </xsl:call-template>
          <!--
          <div class="tabbable">
            <ul class="nav nav-tabs" id="tabs">
              <li>
                <a href="#specified" data-toggle="tab">
                  <i class=" icon-list"/>
                  <xsl:text> Assigned Equipment </xsl:text>
                  <xsl:call-template name="item-badge">
                    <xsl:with-param name="text" select="count($folders-with-equip-id)"/>
                  </xsl:call-template>
                </a>
              </li>
              <li>
                <a href="#missing" data-toggle="tab">
                  <i class=" icon-flag"/>
                  <xsl:text> Unassigned Equipment </xsl:text>
                  <xsl:call-template name="item-badge">
                    <xsl:with-param name="text" select="count($folders-without-equip-id)"/>
                  </xsl:call-template>
                </a>
              </li>
            </ul>
            <div class="tab-content">
              <div class="tab-pane fade" id="specified">
                <xsl:call-template name="table-for-equipment-id">
                  <xsl:with-param name="items" select="$folders-with-equip-id"/>
                </xsl:call-template>
              </div>
              <div class="tab-pane fade" id="missing">
                <xsl:call-template name="table-for-equipment-id">
                  <xsl:with-param name="items" select="$folders-without-equip-id"/>
                </xsl:call-template>
              </div>
            </div>
          </div>
          -->
        </div>
        <script src="jquery/jquery.js"/>
        <script src="bootstrap/js/bootstrap.js"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Planning.Recipe.Server.RecipeSchema']" mode="collapse-details">
    <xsl:variable name="parameter-groups" select="key('items-by-fullName', Property[@name='ParameterGroups']/property-value/ItemLink/@absolutePath)"/>
      <xsl:call-template name="list-item-with-details-collapsed">
        <xsl:with-param name="items" select="$parameter-groups"/>
      </xsl:call-template>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.Planning.Recipe.Server.RecipeParameterGroup']" mode="list-item">
    <i class="icon-asterisk"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@name"/>
  </xsl:template>

  <xsl:template name="table-for-equipment-id">
    <xsl:param name="items" select="."/>
    <table class="table table-condensed table-hover">
      <tbody>
        <tr>
          <th>Full Name</th>
          <th>Equipment Id</th>
        </tr>
        <xsl:for-each select="$items">
          <xsl:sort select="@fullName"/>
          <tr>
            <td>
              <xsl:value-of select="@fullName"/>
            </td>
            <td>
              <xsl:call-template name="item-label">
                <xsl:with-param name="text" select="Property[@name='EquipmentId']"/>
                <xsl:with-param name="color">blue</xsl:with-param>
              </xsl:call-template>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
  
</xsl:stylesheet>
