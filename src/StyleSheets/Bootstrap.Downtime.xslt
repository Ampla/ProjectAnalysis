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

  <xsl:key name="none" match="None" use="@none"/>
  <xsl:key name="cause-by-id" match="Cause" use="@cause"/>
  <xsl:key name="classification-by-id" match="Classification" use="@classification" />
  <xsl:key name="effect-by-id" match="Effect" use="@effect" />

  <xsl:key name="matrix-by-cause" match="Matrix" use="@cause"/>
  <xsl:key name="matrix-by-classification" match="Matrix" use="@classification"/>
  <xsl:key name="matrix-by-effect" match="Matrix" use="@effect"/>

  <xsl:key name="equipment-by-cause" match="EquipmentType" use="RelationshipMatrix/Matrix/@cause"/>
  <xsl:key name="equipment-by-classification" match="EquipmentType" use="RelationshipMatrix/Matrix/@classification"/>
  <xsl:key name="equipment-by-effect" match="EquipmentType" use="RelationshipMatrix/Matrix/@effect"/>

  <xsl:variable name="causes" select="/Project/Causes/Cause"/>
  <xsl:variable name="classifications" select="/Project/Classifications/Classification"/>
  <xsl:variable name="effects" select="/Project/Effects/Effect"/>
  <xsl:variable name="equipmentTypes" select="/Project/EquipmentTypes/EquipmentType"/>
  <xsl:variable name="relationshipMatrixs" select="/Project/EquipmentTypes/EquipmentType/RelationshipMatrix/Matrix"/>
  <xsl:variable name="usedLocations" select="/Project/EquipmentTypes/EquipmentType/Locations/Location"/>
  <xsl:variable name="missingLocations" select="/Project/Locations/Location"/>
  <xsl:variable name="all-locations" select="$usedLocations | $missingLocations"/>

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
          @media (max-width: 980px) {
          /* Enable use of floated navbar text */
          .navbar-text.pull-right {
          float: none;
          padding-left: 5px;
          padding-right: 5px;
          }
          }

          .inner { margin-bottom: 0px;}
          td ul { margin-bottom: 0px; }

          .c { color: #008;}
          .cl { color: #800; }
          .ef { color: #195f91; }
          .et { color: #080; }
          .loc { color: #48484c; }

          .summary {
            cursor: pointer; 
          }

          .details {
          display: none;
          }
        </style>
      </head>
      <body>
        <xsl:call-template name="build-menu">
          <xsl:with-param name="tab">Downtime Relationship</xsl:with-param>
        </xsl:call-template>

        <div id="main" class="container">
          <div class="tabbable">
            <ul class="nav nav-tabs" id="tabs">
              <li>
                <a href="#home" data-toggle="tab">
                  <i class="icon-home"/>
                </a>
              </li>
              <xsl:call-template name="build-tab">
                <xsl:with-param name="name">Cause</xsl:with-param>
                <xsl:with-param name="items" select="$causes"/>
                <xsl:with-param name="lookup">matrix-by-cause</xsl:with-param>
                <xsl:with-param name="attribute">cause</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="build-tab">
                <xsl:with-param name="name">Classification</xsl:with-param>
                <xsl:with-param name="items" select="$classifications"/>
                <xsl:with-param name="lookup">matrix-by-classification</xsl:with-param>
                <xsl:with-param name="attribute">classification</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="build-tab">
                <xsl:with-param name="name">Effect</xsl:with-param>
                <xsl:with-param name="items" select="$effects"/>
                <xsl:with-param name="lookup">matrix-by-effect</xsl:with-param>
                <xsl:with-param name="attribute">effect</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="build-tab">
                <xsl:with-param name="name">Equipment Types</xsl:with-param>
                <xsl:with-param name="items" select="$equipmentTypes"/>
                <xsl:with-param name="tab">equipment</xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="build-tab">
                <xsl:with-param name="name">Locations</xsl:with-param>
                <xsl:with-param name="items" select="$all-locations"/>
                <xsl:with-param name="tab">location</xsl:with-param>
              </xsl:call-template>
              <li title="Toggle wide screen" class="but-group pull-right">
                <button id="full-screen" class="btn btn-small" href="">
                  <i class="icon-fullscreen"/>
                </button>
              </li>
            </ul>

            <div class="tab-content">
              <div class="tab-pane fade" id="home">
                <xsl:call-template name="summary"/>
              </div>
                <xsl:call-template name="build-summary">
                  <xsl:with-param name="name">Cause</xsl:with-param>
                  <xsl:with-param name="items" select="$causes"/>
                  <xsl:with-param name="mode">table</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="build-summary">
                  <xsl:with-param name="name">Classification</xsl:with-param>
                  <xsl:with-param name="items" select="$classifications"/>
                  <xsl:with-param name="mode">table</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="build-summary">
                  <xsl:with-param name="name">Effect</xsl:with-param>
                  <xsl:with-param name="items" select="$effects"/>
                  <xsl:with-param name="mode">table</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="build-summary">
                  <xsl:with-param name="name">Equipment Types</xsl:with-param>
                  <xsl:with-param name="items" select="$equipmentTypes"/>
                  <xsl:with-param name="tab">equipment</xsl:with-param>
                  <xsl:with-param name="mode">table</xsl:with-param>
                </xsl:call-template>
              <xsl:call-template name="build-summary">
                <xsl:with-param name="name">Locations</xsl:with-param>
                <xsl:with-param name="items" select="$all-locations"/>
                <xsl:with-param name="tab">location</xsl:with-param>
                <xsl:with-param name="mode">table</xsl:with-param>
              </xsl:call-template>
            </div>

          </div>
        </div>

        <script src="jquery/jquery.js"/>
        <script src="bootstrap/js/bootstrap.js"/>
        
        <script>
          $('#tabs a:first').tab('show');
        </script>
        <script type="text/javascript" src="lib/downtime.js"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="build-tab">
    <xsl:param name="name"></xsl:param>
    <xsl:param name="items"/>
    <xsl:param name="tab" select="$name"/>
    <xsl:if test="count($items) > 0">
      <li>
        <a href="{concat('#', $tab)}" data-toggle="tab">
          <i class="icon-list"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$name"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="item-badge">
            <xsl:with-param name="text" select="count($items)"/>
          </xsl:call-template>
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-summary">
    <xsl:param name="name"/>
    <xsl:param name="items"/>
    <xsl:param name="tab" select="$name"/>
    <xsl:param name="mode"/>
    <xsl:if test="count($items) > 0">
      <div class="tab-pane fade" id="{$tab}">
        <h4>
          <i class="icon-list"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$name"/>
        </h4>
        <xsl:choose>
          <xsl:when test="$mode='table'">
            <table class="table table-hover table-condensed">
              <tbody>
                <xsl:apply-templates select="$items[1]/.." mode="header"/>
                <xsl:apply-templates select="$items" mode="details">
                  <xsl:sort select="@name"/>
                  <xsl:sort select="@fullName"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="$items[1]/.." mode="footer"/>
              </tbody>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$items" mode="details">
              <xsl:sort select="@name"/>
              <xsl:sort select="@fullName"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Causes" mode="header">
      <tr>
        <th>#</th>
        <th>Cause</th>
        <xsl:choose>
          <xsl:when test="count($effects) = 0">
            <th>Classifications / Equipment Types</th>
          </xsl:when>
          <xsl:otherwise>
            <th>Classifications / Effects / Equipment Types</th>
          </xsl:otherwise>
        </xsl:choose>
        <th title="Number of locations where the cause is used.">Locations</th>
      </tr>
  </xsl:template>

  <xsl:template match="Causes" mode="footer"/>
  
  <xsl:template match="Cause" mode="details">
    <xsl:variable name="equipment" select="key('equipment-by-cause', @cause)"/>
    <xsl:variable name="matrix" select="key('matrix-by-cause', @cause)"/>
    <xsl:variable name="locations" select="$equipment/Locations/Location"/>
    <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>

    <tr>
      <xsl:choose>
        <xsl:when test="count($equipment) = 0">
          <xsl:attribute name="class">warning</xsl:attribute>
        </xsl:when>
        <xsl:when test="count($locations) = 0">
          <xsl:attribute name="class">summary</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">summary success</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:value-of select="@cause"/>
      </td>
      <td>
        <xsl:call-template name="build-icon">
          <xsl:with-param name="equipment" select="$equipment"/>
          <xsl:with-param name="locations" select="$locations"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <span class="c">
          <xsl:value-of select="@name"/>
        </span>
      </td>
      <td>
        <span class="cl">
          <xsl:value-of select="count($classifications)"/>
          <xsl:text> Classifications</xsl:text>
        </span>
        <xsl:text> / </xsl:text>
        <xsl:if test="count($effects) > 0">
          <span class="ef">
            <xsl:value-of select="count($effects)"/>
            <xsl:text> Effects</xsl:text>
          </span>
          <xsl:text> / </xsl:text>
        </xsl:if>
        <span class="et">
          <xsl:value-of select="count($equipment)"/>
          <xsl:text> Equipment Types</xsl:text>
        </span>
      </td>
      <td>
        <xsl:call-template name="locations-label">
          <xsl:with-param name="locations" select="$locations" />
        </xsl:call-template>
      </td>
    </tr>
    <tr class="details info">
      <td/>
      <td colspan="3">
        <table class="table inner table-condensed table-bordered">
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Classifications</xsl:with-param>
            <xsl:with-param name="list" select="$classifications"/>
            <xsl:with-param name="row-class">cl</xsl:with-param>
          </xsl:call-template>
          <xsl:if test="count($effects) > 0">
            <xsl:call-template name="list-table-row">
              <xsl:with-param name="name">Effects</xsl:with-param>
              <xsl:with-param name="list" select="$effects"/>
              <xsl:with-param name="row-class">ef</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Equipment Types</xsl:with-param>
            <xsl:with-param name="list" select="$equipment"/>
            <xsl:with-param name="row-class">et</xsl:with-param>
          </xsl:call-template>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="list-table-row">
    <xsl:param name="name">Name</xsl:param>
    <xsl:param name="list" select="*"/>
    <xsl:param name="row-class"/>
    <xsl:param name="hide-results" select="count($list) > 25"/>
    <tr class="{$row-class}">
      <td>
        <xsl:value-of select="$name"/>
      </td>
      <td>
        <xsl:if test="$hide-results">
          <a class="summary">
            <xsl:value-of select="concat('Show ', count($list), ' ', $name)"/>
          </a>
        </xsl:if>
        <ul>
          <xsl:if test="$hide-results">
            <xsl:attribute name="class">details</xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$list">
            <li>
              <xsl:value-of select="@name"/>
            </li>
          </xsl:for-each>
        </ul>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="build-icon">
    <xsl:param name="equipment"/>
    <xsl:param name="locations"/>
    <xsl:choose>
      <xsl:when test="count($equipment) = 0">
        <span title="Not assigned and not used" class="label label-warning">
          <i class="icon-remove icon-white"/>
        </span>
      </xsl:when>
      <xsl:when test="count($locations) = 0">
        <span title="Assigned but not used" class="label">
          <i class="icon-minus icon-white"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="label label-success">
          <i class="icon-ok icon-white"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Classifications" mode="header">
    <tr>
      <th>#</th>
      <th>Classification</th>
      <xsl:choose>
        <xsl:when test="count($effects) = 0">
          <th>Causes / Equipment Types</th>
        </xsl:when>
        <xsl:otherwise>
          <th>Causes / Effects / Equipment Types</th>
        </xsl:otherwise>
      </xsl:choose>
      <th title="Number of locations where the classification is used.">Locations</th>
    </tr>
  </xsl:template>

  <xsl:template match="Classifications" mode="footer"/>

  <xsl:template match="Classification" mode="details">
    <xsl:variable name="equipment" select="key('equipment-by-classification', @classification)"/>
    <xsl:variable name="matrix" select="key('matrix-by-classification', @classification)"/>
    <xsl:variable name="locations" select="$equipment/Locations/Location"/>
    <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
    <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>

    <tr>
      <xsl:choose>
        <xsl:when test="count($equipment) = 0">
          <xsl:attribute name="class">warning</xsl:attribute>
        </xsl:when>
        <xsl:when test="count($locations) = 0">
          <xsl:attribute name="class">summary</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">summary success</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:value-of select="@classification"/>
      </td>
      <td>
        <xsl:call-template name="build-icon">
          <xsl:with-param name="equipment" select="$equipment"/>
          <xsl:with-param name="locations" select="$locations"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <span class="cl">
          <xsl:value-of select="@name"/>
        </span>
      </td>
      <td>
        <span class="c">
          <xsl:value-of select="count($causes)"/>
          <xsl:text> Causes</xsl:text>
        </span>
        <xsl:text> / </xsl:text>
        <xsl:if test="count($effects) > 0">
          <span class="ef">
            <xsl:value-of select="count($effects)"/>
            <xsl:text> Effects</xsl:text>
            <xsl:text> / </xsl:text>
          </span>
        </xsl:if>
        <span class="et">
          <xsl:value-of select="count($equipment)"/>
          <xsl:text> Equipment Types</xsl:text>
        </span>
      </td>
      <td>
        <xsl:call-template name="locations-label">
          <xsl:with-param name="locations" select="$locations" />
        </xsl:call-template>
      </td>
    </tr>
    <tr class="details info">
      <td/>
      <td colspan="3">
        <table class="table inner table-condensed table-bordered">
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Causes</xsl:with-param>
            <xsl:with-param name="list" select="$causes"/>
            <xsl:with-param name="row-class">c</xsl:with-param>
          </xsl:call-template>
          <xsl:if test="count($effects) > 0">
            <xsl:call-template name="list-table-row">
              <xsl:with-param name="name">Effects</xsl:with-param>
              <xsl:with-param name="list" select="$effects"/>
              <xsl:with-param name="row-class">ef</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Equipment Types</xsl:with-param>
            <xsl:with-param name="list" select="$equipment"/>
            <xsl:with-param name="row-class">et</xsl:with-param>
          </xsl:call-template>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="Effects" mode="header">
    <tr>
      <th>#</th>
      <th>Effect</th>
      <th>Causes / Classifications / Equipment Types</th>
      <th title="Number of locations where the effect is used.">Locations</th>
    </tr>
  </xsl:template>

  <xsl:template match="Effects" mode="footer"/>

  <xsl:template match="Effect" mode="details">
    <xsl:variable name="equipment" select="key('equipment-by-effect', @effect)"/>
    <xsl:variable name="matrix" select="key('matrix-by-effect', @effect)"/>
    <xsl:variable name="locations" select="$equipment/Locations/Location"/>
    <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>

    <tr>
      <xsl:choose>
        <xsl:when test="count($equipment) = 0">
          <xsl:attribute name="class">warning</xsl:attribute>
        </xsl:when>
        <xsl:when test="count($locations) = 0">
          <xsl:attribute name="class">summary</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">summary success</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:value-of select="@effect"/>
      </td>
      <td>
        <xsl:call-template name="build-icon">
          <xsl:with-param name="equipment" select="$equipment"/>
          <xsl:with-param name="locations" select="$locations"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <span class="ef">
          <xsl:value-of select="@name"/>
        </span>
      </td>
      <td>
        <span class="c">
          <xsl:value-of select="count($causes)"/>
          <xsl:text> Causes</xsl:text>
        </span>
        <xsl:text> / </xsl:text>
        <span class="cl">
          <xsl:value-of select="count($classifications)"/>
          <xsl:text> Classifications</xsl:text>
        </span>
        <xsl:text> / </xsl:text>
        <span class="et">
          <xsl:value-of select="count($equipment)"/>
          <xsl:text> Equipment Types</xsl:text>
        </span>
      </td>
      <td>
        <xsl:call-template name="locations-label">
          <xsl:with-param name="locations" select="$locations" />
        </xsl:call-template>
      </td>
    </tr>
    <tr class="details info">
      <td/>
      <td colspan="3">
        <table class="table inner table-condensed table-bordered">
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Causes</xsl:with-param>
            <xsl:with-param name="list" select="$causes"/>
            <xsl:with-param name="row-class">c</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Classifications</xsl:with-param>
            <xsl:with-param name="list" select="$classifications"/>
            <xsl:with-param name="row-class">cl</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="list-table-row">
            <xsl:with-param name="name">Equipment Types</xsl:with-param>
            <xsl:with-param name="list" select="$equipment"/>
            <xsl:with-param name="row-class">et</xsl:with-param>
          </xsl:call-template>
        </table>
      </td>
    </tr>

  </xsl:template>

  <xsl:template match="EquipmentTypes" mode="header">
    <tr>
      <th>Equipment Type</th>
      <xsl:choose>
        <xsl:when test="count($effects) = 0">
          <th>Causes / Classifications</th>
        </xsl:when>
        <xsl:otherwise>
          <th>Causes / Classifications / Effects</th>
        </xsl:otherwise>
      </xsl:choose>
      <th title="Number of locations where the Equipment Type is used.">Locations</th>
    </tr>
  </xsl:template>

  <xsl:template match="EquipmentTypes" mode="footer"/>

  <xsl:template match="EquipmentType" mode="details">
    <xsl:variable name="locations" select="Locations/Location"/>
    <xsl:variable name="matrix" select="RelationshipMatrix/Matrix"/>
    <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
    <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>
    <tr>
      <xsl:choose>
        <xsl:when test="count($matrix) = 0">
          <xsl:attribute name="class">summary warning</xsl:attribute>
        </xsl:when>
        <xsl:when test="count($locations) > 0">
          <xsl:attribute name="class">summary success</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">summary</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:call-template name="build-icon">
          <xsl:with-param name="equipment" select="$matrix"/>
          <xsl:with-param name="locations" select="$locations"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <span class="et">
          <xsl:value-of select="@name"/>
        </span>
      </td>
      <td>
        <span class="c">
          <xsl:value-of select="count($causes)"/>
          <xsl:text> Causes</xsl:text>
        </span>
        <xsl:text> / </xsl:text>
        <span class="cl">
          <xsl:value-of select="count($classifications)"/>
          <xsl:text> Classifications</xsl:text>
        </span>
          <xsl:if test="count($effects) > 0">
            <xsl:text> / </xsl:text>
            <span class="ef">
            <xsl:value-of select="count($effects)"/>
            <xsl:text> Effects</xsl:text>
            </span>
          </xsl:if>
      </td>
      <td>
        <xsl:call-template name="locations-label">
          <xsl:with-param name="locations" select="$locations" />
        </xsl:call-template>
      </td>
    </tr>
    <tr class="details info">
      <td colspan="3">
        <span style="font-size:80%">
          <table class="table table-condensed table-hover table-bordered inner">
            <tr>
              <th>Cause</th>
              <xsl:for-each select="$classifications">
                <th class="cl">
                  <xsl:value-of select="@name"/>
                </th>
              </xsl:for-each>
            </tr>
            <xsl:for-each select="$causes">
              <xsl:variable name="cause-id" select="@cause"/>
              <tr>
                <td class="c">
                  <xsl:value-of select="@name"/>
                </td>
                <xsl:for-each select="$classifications">
                  <xsl:variable name="classification-id" select="@classification"/>
                  <xsl:variable name="current-matrix" select="$matrix[@cause=$cause-id and @classification = $classification-id]"/>
                  <xsl:choose>
                    <xsl:when test="$current-matrix">
                      <xsl:variable name="current-effects" select="key('effect-by-id', $current-matrix/@effect)"/>
                      <xsl:choose>
                        <xsl:when test="count($current-effects) > 0">
                          <td>
                            <span class="label label-success">
                              <i class="icon-ok icon-white"/>
                            </span>
                            <xsl:for-each select="$current-effects">
                              <xsl:if test="position() > 1">, </xsl:if>
                              <span class="ef">
                                <xsl:value-of select="@name"/>
                              </span>
                            </xsl:for-each>
                          </td>
                        </xsl:when>
                        <xsl:otherwise>
                          <td>
                            <span class="label label-success">
                              <i class="icon-ok icon-white"/>
                            </span>
                          </td>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <td>
                        <xsl:call-template name="space"/>
                      </td>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
          </table>
          <xsl:if test="count($locations) > 0">
            <a class="summary">
              <xsl:value-of select="concat('Show ', count($locations), ' locations')"/>
            </a>
            <ul class="details loc">
              <xsl:for-each select="$locations">
                <li>
                  <xsl:value-of select="@fullName"/>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:if>
        </span>
      </td>
    </tr>

  </xsl:template>

  <xsl:template match="Locations" mode="header">
    <tr>
      <th>Location</th>
      <th title="The Equipment Type assigned to the location.">Equipment Type</th>
      <xsl:choose>
        <xsl:when test="count($effects) = 0">
          <th>Causes / Classifications</th>
        </xsl:when>
        <xsl:otherwise>
          <th>Causes / Classifications / Effects</th>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:template>
  

  <xsl:template match="Location" mode="details">
    <xsl:variable name="equipmentType" select="ancestor::EquipmentType"/>
    <xsl:variable name="matrix" select="$equipmentType/RelationshipMatrix/Matrix"/>
    <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
    <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>

    <tr>
      <xsl:if test="count($matrix) = 0">
        <xsl:attribute name="class">warning</xsl:attribute>
      </xsl:if>
      <td class="loc">
        <small>
          <xsl:value-of select="@fullName"/>
        </small>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="not($equipmentType)">
            <span class="label label-warning">(missing)</span>
          </xsl:when>
          <xsl:when test="count($matrix) > 0">
            <span class="label label-success">
              <xsl:value-of select="$equipmentType/@name"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="label">
              <xsl:value-of select="$equipmentType/@name"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <small>
          <span class="c">
            <xsl:value-of select="count($causes)"/>
            <xsl:text> Causes</xsl:text>
          </span>
          <xsl:text> / </xsl:text>
          <span class="cl">
            <xsl:value-of select="count($classifications)"/>
            <xsl:text> Classifications</xsl:text>
          </span>
          <xsl:if test="count($effects) > 0">
            <xsl:text> / </xsl:text>
            <span class="ef">
              <xsl:value-of select="count($effects)"/>
              <xsl:text> Effects</xsl:text>
            </span>
          </xsl:if>
        </small>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="summary">
    <xsl:variable name="matrix" select="$relationshipMatrixs"/>
    <xsl:variable name="equipment" select="$matrix/ancestor::EquipmentType"/>
    <xsl:variable name="cause" select="key('cause-by-id', $matrix/@cause)"/>
    <xsl:variable name="classification" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="effect" select="key('effect-by-id', $matrix/@effect)"/>
    <div class="row">
      <div class="span8">

        <table class="table table-condensed table-hover table-bordered">
          <tbody>
            <tr>
              <th>Dimension</th>
              <th>Total</th>
              <th>Used</th>
              <th>Not referenced</th>
              <th title="Average number of entries per dimension">Average</th>
              <th>Graph</th>
            </tr>
            <xsl:call-template name="table-progress">
              <xsl:with-param name="name">Causes</xsl:with-param>
              <xsl:with-param name="total" select="$causes"/>
              <xsl:with-param name="used" select="$cause"/>
              <xsl:with-param name="matrix" select="$matrix"/>
              <xsl:with-param name="class">c</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="table-progress">
              <xsl:with-param name="name">Classifications</xsl:with-param>
              <xsl:with-param name="total" select="$classifications"/>
              <xsl:with-param name="used" select="$classification"/>
              <xsl:with-param name="matrix" select="$matrix"/>
              <xsl:with-param name="class">cl</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="table-progress">
              <xsl:with-param name="name">Effects</xsl:with-param>
              <xsl:with-param name="total" select="$effects"/>
              <xsl:with-param name="used" select="$effect"/>
              <xsl:with-param name="matrix" select="$matrix"/>
              <xsl:with-param name="class">ef</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="table-progress">
              <xsl:with-param name="name">Equipment Types</xsl:with-param>
              <xsl:with-param name="total" select="$equipmentTypes"/>
              <xsl:with-param name="used" select="$equipmentTypes[Locations/Location]"/>
              <xsl:with-param name="matrix" select="$matrix"/>
              <xsl:with-param name="class">et</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="table-progress">
              <xsl:with-param name="name">Locations</xsl:with-param>
              <xsl:with-param name="total" select="$all-locations"/>
              <xsl:with-param name="used" select="$usedLocations"/>
              <xsl:with-param name="matrix" select="$matrix"/>
              <xsl:with-param name="class">loc</xsl:with-param>
            </xsl:call-template>
          </tbody>
        </table>
        <small class="muted">
          <xsl:text>Relationship Matrix contains </xsl:text>
          <xsl:value-of select="format-number(count($matrix), '#,##0')"/>
          <xsl:text> entries</xsl:text>
        </small>
      </div>
      
    </div>
  </xsl:template>

  <xsl:template name="table-progress">
    <xsl:param name="name"></xsl:param>
    <xsl:param name="total"/>
    <xsl:param name="used"/>
    <xsl:param name="matrix"/>
    <xsl:param name="class"/>
    <xsl:variable name="percent">
      <xsl:choose>
        <xsl:when test="count($total)=0">0</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count($used) div count($total)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="left" select="count($total) - count($used)"/>
    <tr>
      <td class="{$class}">
        <xsl:value-of select="$name"/>
      </td>
      <td>
        <span>
          <xsl:value-of select="format-number(count($total), '#,##0')"/>
        </span>
      </td>
      <td>
        <span class="text-success">
          <xsl:value-of select="format-number(count($used), '#,##0')"/>
        </span>
      </td>
      <td >
        <span class="text-warning">
          <xsl:value-of select="format-number($left, '#,##0')"/>
        </span>
      </td>
      <xsl:choose>
        <xsl:when test="count($used) > 0">
          <td title="{count($matrix)} entries / {count($used)} {$name}">
            <span>
              <xsl:value-of select="format-number(count($matrix) div count($used), '#.00')"/>
            </span>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td>
            <span class="muted">-</span>
          </td>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:choose>
          <xsl:when test="$percent > 0">
            <div class="progress" style="width: 200px; margin-bottom: 0px;">
              <div title="{count($used)} {$name}" class="bar bar-success" style="width: {$percent * 100}%;"></div>
              <div title="{count($total)-count($used)} {$name}" class="bar bar-warning" style="width: {(1-$percent) * 100}%;"></div>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div title="0 {$name}" class="progress" style="width: 200px; margin-bottom: 0px;"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="mini-graph">
    <xsl:param name="color"/>
    <xsl:param name="used">0</xsl:param>
    <xsl:param name="total">100</xsl:param>
    <xsl:param name="text" select="$used"/>
    <xsl:variable name="percent">
      <xsl:choose>
        <xsl:when test="$used = 0">0</xsl:when>
        <xsl:when test="$total = 0">0</xsl:when>
        <xsl:when test="$used div $total &lt; 0.01">0.01</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="format-number($used div $total, '0.0##')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="class-bar">
      <xsl:choose>
        <xsl:when test="$color='green'">bar-success</xsl:when>
        <xsl:when test="$color='orange'">bar-warning</xsl:when>
        <xsl:when test="$color='blue'">bar-info</xsl:when>
        <xsl:when test="$color='red'">bar-danger</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <div class="progress" title="{$text}" style="margin-bottom: 0px;">
      <div class="bar {$class-bar}" style="width:{100 * $percent}%"/>
    </div>
  </xsl:template>

  <xsl:template name="locations-label">
    <xsl:param name="locations"/>
    <span class="pull-right">
      <xsl:call-template name="color-label">
        <xsl:with-param name="color">
          <xsl:choose>
            <xsl:when test="count($locations) > 0">green</xsl:when>
            <xsl:otherwise>grey</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="text" select="format-number(count($locations), '#,##0')"/>
      </xsl:call-template>
    </span>
  </xsl:template>
  
</xsl:stylesheet>
