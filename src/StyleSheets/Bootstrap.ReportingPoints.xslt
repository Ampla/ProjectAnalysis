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
  
  <xsl:key name="items-by-type" match="Item"  use="@type"/>

  <xsl:variable name="root-items" select="/Project/Item"/>
  
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

          /* Special grid styles
          -------------------------------------------------- */

          .show-grid {
          margin-top: 10px;
          margin-bottom: 20px;
          }
          .show-grid [class*="span"] {
          background-color: #eee;
          text-align: center;
          -webkit-border-radius: 3px;
          -moz-border-radius: 3px;
          border-radius: 3px;
          min-height: 40px;
          line-height: 40px;
          }
          .show-grid [class*="span"]:hover {
          background-color: #ddd;
          }
          .show-grid .show-grid {
          margin-top: 0;
          margin-bottom: 0;
          }
          .show-grid .show-grid [class*="span"] {
          margin-top: 5px;
          }
          .show-grid [class*="span"] [class*="span"] {
          background-color: #ccc;
          }
          .show-grid [class*="span"] [class*="span"] [class*="span"] {
          background-color: #999;
          }

          .item
          {
          border: 1px solid #009530;
          vertical-align: top;
          padding-left: 10px;
          padding-top: 2px;
          padding-right: 10px;
          padding-bottom: 2px;
          background-color: #eee;
          }

          .item:hover {
          background-color: #ccc;
          }

        </style>
      </head>
      <body>
        <xsl:call-template name="build-menu">
          <xsl:with-param name="tab">Modules</xsl:with-param>
        </xsl:call-template>

        <div class="container">
          <div class="tabbable">
            <ul class="nav nav-tabs" id="module_tabs">
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Downtime</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Production</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Metrics</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Energy</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Quality</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Maintenance</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Knowledge</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Planning</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-tab">
                <xsl:with-param name="module">Cost</xsl:with-param>
              </xsl:call-template>
            </ul>

            <div class="tab-content">
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Downtime</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Production</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Metrics</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Energy</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Quality</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Maintenance</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Knowledge</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Planning</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="module-summary">
                <xsl:with-param name="module">Cost</xsl:with-param>
              </xsl:call-template>
            </div>

          </div>
        </div>

        <script src="jquery/jquery.js"/>
        <script src="bootstrap/js/bootstrap.js"/>
        <!--
        <script>
          $('#module_tabs a').click(function (e) {
          e.preventDefault();
          $(this).tab('show');
          })

          $(function () {
          $('#module_tabs a:first').tab('show');
          })
        </script>
-->
      </body>
    </html>
  </xsl:template>

  <xsl:template name="module-summary">
    <xsl:param name="module"></xsl:param>
    <xsl:variable name="reportingPoint" select="concat('Citect.Ampla.', $module, '.Server.', $module, 'ReportingPoint')"/>
    <xsl:variable name="items" select="key('items-by-type', $reportingPoint)"/>
    <xsl:if test="count($items) > 0">
      <div class="tab-pane fade" id="{$module}">
        <h4>
          <img class="icon" alt="{$module}" src="images/{$module}.png" />
          <xsl:text> </xsl:text><xsl:value-of select="$module"/>
        </h4>
        <!--
        <table class="table table-bordered">
          <tbody>
            <tr>
              <td>
                <xsl:apply-templates select="$root-items[descendant::Item[@id=$items/@id]]" mode="summary-table">
                  <xsl:with-param name="show-items" select="$items"/>
                </xsl:apply-templates>
              </td>
            </tr>
          </tbody>
        </table>

        -->
        <xsl:for-each select="$items">
            <div id="{@hash}" data-toggle="collapse" data-target="{concat('#', @hash, '_data')}">
              <xsl:text> </xsl:text>
              <span class="badge">
                <xsl:value-of select="$module"/>
              </span>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@fullName"/>
            </div>

            <div id="{concat(@hash, '_data')}" class="collapse" >
              <h5 data-toggle="collapse" data-target="{concat('#', @hash, '_data')}">
                <img class="icon" alt="{$module}" src="images/{$module}.png" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="@fullName"/>
              </h5>
              <xsl:if test="count(Item/Item) > 0">
                <ul class="breadcrumb">
                  <xsl:for-each select="Item">
                    <xsl:choose>
                      <xsl:when test="count(Item) > 0">
                        <li>
                          <span data-toggle="collapse" data-target="{concat('#', @hash, '_data')}">
                            <a href="#">
                              <xsl:value-of select="@name"/>
                            </a>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="item-badge">
                              <xsl:with-param name="text" select="count(Item)"/>
                            </xsl:call-template>
                          </span>
                        </li>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                </ul>
                <xsl:for-each select="Item">
                  <div id="{concat(@hash, '_data')}" class="collapse">
                    <table class="table table-condensed">
                      <thead>
                        <tr>
                          <th>#</th>
                          <th>Name</th>
                        </tr>
                      </thead>
                      <tbody>
                        <xsl:for-each select="Item">
                          <tr>
                            <td>
                              <xsl:value-of select="position()"/>
                            </td>
                            <td>
                              <xsl:value-of select="@name"/>
                            </td>
                          </tr>
                        </xsl:for-each>
                      </tbody>
                    </table>
                  </div>
                </xsl:for-each>
              </xsl:if>
            </div>
          </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="module-tab">
    <xsl:param name="module"></xsl:param>
    <xsl:param name="reportingPoint" select="concat('Citect.Ampla.', $module, '.Server.', $module, 'ReportingPoint')"/>
    <xsl:variable name="items" select="key('items-by-type', $reportingPoint)"/>
    <xsl:if test="count($items) > 0">
      <li>
        <a href="{concat('#', $module)}" data-toggle="tab">
          <img class="icon" alt="{$module}" src="images/16/{$module}.png" />
          <xsl:text> </xsl:text>
          <xsl:value-of select="$module"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="item-badge">
            <xsl:with-param name="text" select="count($items)"/>
          </xsl:call-template>
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Item" mode="summary-table">
    <xsl:param name="show-items"/>
    <xsl:param name="depth">1</xsl:param>
    <xsl:variable name="items" select="Item[descendant::Item[@id = $show-items/@id]]"/>
    <xsl:variable name="desc-items" select="descendant::Item[@id = $show-items/@id]"/>
    <xsl:variable name="points" select="Item[@id = $show-items/@id]"/>
    <span class="item" title="{@fullName}">
      <xsl:value-of select="@name"/>
    </span>
    <!--
    <xsl:choose>
      <xsl:when test="(count($items) + count($desc-items)) > 0">
        <span class="item" title="{@fullName}">
          <xsl:value-of select="@name"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>
          <xsl:value-of select="@fullName"/>
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
    -->
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
              <xsl:when test="contains(@type,'Lot')">inventory</xsl:when>
              <xsl:otherwise>folder</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <div title="{@fullName}">
            <img class="icon" alt="{$module}" src="images/16/{$module}.png" />
            <span class="item point">
              <xsl:value-of select="@name"/>
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
        <table class="">
          <tbody>
            <tr>
              <xsl:for-each select="$items">
                <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
                <xsl:sort data-type="text" select="@name"/>
                <td>
                  <xsl:apply-templates select="Item" mode="summary-table">
                    <xsl:with-param name="show-items" select="$show-items"/>
                    <xsl:with-param name="depth" select="$depth + 1"/>
                  </xsl:apply-templates>
                </td>
              </xsl:for-each>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <span class="layout-down"/>
        <table class="table table-bordered">
          <tbody>
            <xsl:for-each select="$items">
              <xsl:sort data-type="number" select="Property[@name='DisplayOrder']"/>
              <xsl:sort data-type="text" select="@name"/>
              <tr>
                <td>
                  <xsl:apply-templates select="Item" mode="summary-table">
                    <xsl:with-param name="show-items" select="$show-items"/>
                    <xsl:with-param name="depth" select="$depth + 1"/>
                  </xsl:apply-templates>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="build-tree">
    <table class="table table-bordered">
      <tbody>
        <tr>
          <td>
            <span data-toggle="collapse" data-target="#fp">
              <i class="icon-plus" ></i><xsl:text> </xsl:text><span>Schneider Coal</span>.<span>Yellow Rock Mine</span>.<span>Fixed Plant</span>
            </span>
            <xsl:text> </xsl:text>
            <button type="button" class="btn btn-mini" data-toggle="collapse" data-target="#fp">
              <xsl:call-template name="item-badge">
                <xsl:with-param name="text">4</xsl:with-param>
              </xsl:call-template>
            </button>
            <xsl:text> </xsl:text>
            <div id="fp" class="collapse in">

               <table class="table table-bordered">
                <tbody>
                  <tr>
                    <td>
                      <div>CHPP Red</div>
                      <xsl:text> </xsl:text>
                      <div title="Schneider Coal.Yellow Rokc Mine.Fixed Plant.CHPP Red.Downtime">
                        <img class="icon" alt="Downtime" src="images/16/downtime.png" />
                        <xsl:text> Downtime</xsl:text>
                      </div>
                    </td>
                    <td>
                      <div>CHPP Blue</div>
                      <div title="Schneider Coal.Yellow Rokc Mine.Fixed Plant.CHPP Blue.Downtime">
                        <img class="icon" alt="Downtime" src="images/16/downtime.png" />
                        <xsl:text> Downtime</xsl:text>
                      </div>
                    </td>
                    <td>

                      <xsl:text> </xsl:text>
                      <span data-toggle="collapse" data-target="#pc">
                        <i class="icon-plus" ></i> Product Coal

                        <!--  <xsl:text> </xsl:text> <button type="button" class="btn btn-mini" data-toggle="collapse" data-target="#pc">
                                <xsl:call-template name="item-badge">
                                  <xsl:with-param name="text">1</xsl:with-param>
                                </xsl:call-template>
                              </button> <xsl:text> </xsl:text>-->

                      </span>
                      <div id="pc" class="collapse in">
                        <table class="table table-bordered ">
                          <tbody>
                            <tr>
                              <td>
                                <div>Conv 101</div>
                                <xsl:text> </xsl:text>
                                <span class="badge">Downtime</span>
                                <xsl:text> </xsl:text>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </td>
                    <td>
                      <div>Train Loadout</div>
                      <xsl:text> </xsl:text>
                      <span class="badge">Downtime</span>
                      <xsl:text> </xsl:text>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </td>
        </tr>
      </tbody>
    </table>

  </xsl:template>
    
</xsl:stylesheet>
