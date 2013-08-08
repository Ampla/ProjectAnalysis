<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:variable name="cr" select="'&#xD;'"/>

  <xsl:key name="all-items-by-type" match="Item[@type]" use="@type"/>

  <xsl:template name="build-menu">
    <xsl:param name="tab"></xsl:param>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="brand" href="#">Ampla Project Analysis</a>
          <div class="nav-collapse collapse">
            <!--            
  <p class="navbar-text pull-right">Logged in as <a href="#" class="navbar-link">Username</a></p>
-->
            <ul class="nav">
              <li >
                <a href="#">Home</a>
              </li>
              <li>
                <xsl:if test="$tab='Modules'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Bootstrap.Modules.html">Modules</a>
              </li>
              <li>
                <xsl:if test="$tab='Code Items'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Bootstrap.CodeItems.html">Code Items</a>
              </li>
              <li>
                <xsl:if test="$tab='Metrics'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Project.Metrics.html">Metrics</a>
              </li>
              <li>
                <xsl:if test="$tab='Downtime Relationship'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Project.Downtime.html">Downtime Relationship</a>
              </li>
              <xsl:variable name='planning' select="key('all-items-by-type', 'Citect.Ampla.Planning.Server.PlanningReportingPoint')"/>
              <xsl:variable name='product-recipe' select="key('all-items-by-type', 'Citect.Ampla.Planning.Recipe.Server.ProductRecipe')"/>
              <xsl:variable name='machine-recipe' select="key('all-items-by-type', 'Citect.Ampla.Planning.Recipe.Server.MachineRecipe')"/>
              <xsl:variable name='schema' select="key('all-items-by-type', 'Citect.Ampla.Planning.Recipe.Server.RecipeSchema')"/>
              <xsl:if test="(count($planning) + count($product-recipe) + count($machine-recipe) + count($schema)) > 0">
                <li>
                  <xsl:if test="$tab='Planning'">
                    <xsl:attribute name="class">active</xsl:attribute>
                  </xsl:if>
                  <a href="Bootstrap.Planning.html">Planning</a>
                </li>
              </xsl:if>
              <li>
                <xsl:if test="$tab='Interfaces'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Project.Interfaces.html">Interfaces</a>
              </li>
              <li>
                <xsl:if test="$tab='Security'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a href="Project.Security.html">Security</a>
              </li>
            </ul>
          </div>
          <!--/.nav-collapse -->
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*" mode="badge">
    <!-- default badge template is none -->
  </xsl:template>

  <xsl:template name="item-badge">
    <xsl:param name="text">0</xsl:param>
    <xsl:param name="color">green</xsl:param>
    <xsl:variable name="badge-class">
      <xsl:choose>
        <xsl:when test="$color = 'grey'"></xsl:when>
        <xsl:when test="$color = 'gray'"></xsl:when>
        <xsl:when test="$color = 'green'">badge-success</xsl:when>
        <xsl:when test="$color = 'red'">badge-warning</xsl:when>
        <xsl:when test="$color = 'blue'">badge-info</xsl:when>
        <xsl:otherwise>badge-success</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>badge </xsl:text>
        <xsl:value-of select="$badge-class"/>
      </xsl:attribute>
      <xsl:value-of select="$text"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Item[@fullName]" mode="list-item">
    <i class="icon-plus"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@fullName"/>
    <xsl:text> </xsl:text>
    <span class="pull-right">
      <xsl:apply-templates mode="badge" select="."/>
    </span>
  </xsl:template>

  <xsl:template match="Item[@fullName]" mode="collapse-details">
    <xsl:variable name="properties" select="Property"/>
    <xsl:variable name="items" select="Item"/>

    <xsl:choose>
      <xsl:when test="count($items) > 0">
        <table>
          <tbody>
            <tr>
              <td>
                <xsl:call-template name="list-item-with-details-collapsed">
                  <xsl:with-param name="items" select="Item"/>
                </xsl:call-template>
              </td>
            </tr>
          </tbody>
        </table>
      </xsl:when>
      <xsl:when test="count($properties) > 0">
        <table class="table table-bordered table-hover">
          <tbody>
            <xsl:for-each select="$properties">
              <tr>
                <th>
                  <xsl:value-of select="@name"/>
                </th>
                <td>
                  <xsl:apply-templates select="." />
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>

      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>

  <xsl:template name="list-item-with-details-collapsed">
    <xsl:param name="items"/>
    <xsl:param name="prefix"></xsl:param>

    <xsl:for-each select="$items">
      <xsl:sort select="@fullName"/>
      <xsl:variable name="div-id" select="concat($prefix, @hash, '_data')"/>
      <div id="{concat($prefix, @hash)}" data-toggle="collapse" data-target="{concat('#', $div-id)}">
        <xsl:apply-templates select="." mode="list-item"/>
      </div>
      <div id="{$div-id}" class="collapse">
        <xsl:apply-templates select="." mode="collapse-details">
          <xsl:with-param name="data-target" select="$div-id"/>
        </xsl:apply-templates>
      </div>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="count-lines">
    <xsl:param name="text" select="."/>
    <xsl:param name="counter">0</xsl:param>
    <xsl:choose>
      <xsl:when test="contains($text, $cr)">
        <xsl:call-template name="count-lines">
          <xsl:with-param name="text" select="substring-after($text, $cr)"/>
          <xsl:with-param name="counter" select="$counter + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string-length($text) > 0">
        <xsl:value-of select="$counter + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$counter"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
