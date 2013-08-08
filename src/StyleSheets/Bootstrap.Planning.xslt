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

  <xsl:key name="items-by-fullName" match="Item[@fullName]" use="@fullName"/>

  <xsl:variable name="planning-items" select="//Item[@type = 'Citect.Ampla.Planning.Server.PlanningReportingPoint']"/>
	<xsl:variable name="recipe-items" select="//Item[@type = 'Citect.Ampla.Planning.Recipe.Server.ProductRecipe']"/>
  <xsl:variable name="machine-items" select="//Item[@type = 'Citect.Ampla.Planning.Recipe.Server.MachineRecipe']"/>
  <xsl:variable name="schema-items" select="//Item[@type = 'Citect.Ampla.Planning.Recipe.Server.RecipeSchema']"/>

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
          <xsl:with-param name="tab">Planning</xsl:with-param>
        </xsl:call-template>
        
        <div class="container">
          <div class="tabbable">
            <ul class="nav nav-tabs" id="tabs">
              <xsl:if test="count($planning-items) > 0">
                <li>
                  <a href="#planning" data-toggle="tab">
                    <img class="icon" alt="Planning" src="images/16/planning.png" />
                    <xsl:text> Planning </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($planning-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="count($recipe-items) > 0">
                <li>
                  <a href="#recipe" data-toggle="tab">
                    <i class=" icon-asterisk"/>
                    <xsl:text> Product Recipes </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($recipe-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="count($machine-items) > 0">
                <li>
                  <a href="#machine" data-toggle="tab">
                    <i class=" icon-asterisk"/>
                    <xsl:text> Machine Recipes </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($machine-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
              <xsl:if test="count($schema-items) > 0">
                <li>
                  <a href="#schema" data-toggle="tab">
                    <i class=" icon-asterisk"/>
                    <xsl:text> Recipe Schemas </xsl:text>
                    <xsl:call-template name="item-badge">
                      <xsl:with-param name="text" select="count($schema-items)"/>
                    </xsl:call-template>
                  </a>
                </li>
              </xsl:if>
            </ul>
            <div class="tab-content">
              <xsl:if test="count($planning-items) > 0">
                <div class="tab-pane fade" id="planning">
                  <xsl:call-template name="list-item-with-details-collapsed">
                    <xsl:with-param name="items" select="$planning-items"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
              <xsl:if test="count($recipe-items) > 0">
                <div class="tab-pane fade" id="recipe">
                  <xsl:call-template name="list-item-with-details-collapsed">
                    <xsl:with-param name="items" select="$recipe-items"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
              <xsl:if test="count($machine-items) > 0">
                <div class="tab-pane fade" id="machine">
                  <xsl:call-template name="list-item-with-details-collapsed">
                    <xsl:with-param name="items" select="$machine-items"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
              <xsl:if test="count($schema-items) > 0">
                <div class="tab-pane fade" id="schema">
                  <xsl:call-template name="list-item-with-details-collapsed">
                    <xsl:with-param name="items" select="$schema-items"/>
                  </xsl:call-template>
                </div>
              </xsl:if>
            </div>
          </div>
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

  <xsl:template match="Item[@type='Citect.Ampla.Planning.Recipe.Server.RecipeParameterGroup']" mode="collapse-details">
    <table class="table table-condensed table-hover">
      <tbody>
        <tr>
          <th>Name</th>
          <th>Data Type</th>
          <th>Default Value</th>
          <th>Minimum</th>
          <th>Maximum</th>
          <th>Units</th>
          <th>Readonly</th>
          <th>Show in Details</th>
          <th>Edit Prior To Download</th>
          <th>Allowed Values</th>
          <th>Validation Type</th>
        </tr>
        <xsl:for-each select="Item">
          <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
          <xsl:sort select="@name" data-type="text"/>
          <tr>
            <td>
              <xsl:value-of select="@name"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='DataType']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='DefaultValue']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='Minimum']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='Maximum']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='Units']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='ReadOnly']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='ShowInDetails']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='EditPriorToDownload']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='AllowedValues']"/>
            </td>
            <td>
              <xsl:value-of select="Property[@name='ValidationType']"/>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
    <hr/>
  </xsl:template>

</xsl:stylesheet>
