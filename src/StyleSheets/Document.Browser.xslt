<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"  />

  <xsl:key name="items-by-id" match="Item" use="@id"/>
  <xsl:key name="items-by-fullName" match="Item"  use="@fullName"/>
  <xsl:key name="items-by-type" match="Item"  use="@type"/>

  <xsl:variable name="outputAllProperties">true</xsl:variable>
  <xsl:variable name="showCodeSource">false</xsl:variable>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <title>Ampla Project Browser</title>

          <link rel="stylesheet" type="text/css" href="css/jquery.treeview.css" media="screen,projector"/>
          <link rel="stylesheet" type="text/css" href="css/smoothness/jquery-ui-1.7.2.custom.css"/>
          <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>

          <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
          <script type="text/javascript" src="lib/jquery-ui-all.js"></script>
          <script type="text/javascript" src="lib/jquery.treeview.js"></script>
          <script type="text/javascript" src="lib/jquery.layout.js"></script>
          <script type="text/javascript" src="lib/chili/jquery.chili-2.2.js"></script>
          <script type="text/javascript" src="lib/highlightFade.js"></script>
          <script type="text/javascript" src="lib/browser.js"></script>

          <link rel="stylesheet" type="text/css" href="css/jquery.layout.css"/>

        </meta>
      </head>
      <body>
        <div id="pageBody">
          <div class="ui-layout-north">
            <!-- <div id="header">  -->
            Ampla Project Analysis
            <!-- </div>   -->
          </div>
          <div class="ui-layout-west">
            <div id="nav">
              <!-- 
            <div class="loading">
              <div>Loading...</div>
            </div>
            -->

              <div class="navsub waitLoaded" id="navItems">
                <div class="treecontrol">
                  <a class="nav-command" href="#">Collapse All</a>
                  <a class="nav-command" href="#">Expand All</a>
                  <a class="nav-command" href="#">Toggle All</a>
                </div>
                <br/>
                <ul id="item-treeview" class="item-tree">
                  <li>
                    <span class="item-node open">
                      <a class="item-href" href="#project">
                        <xsl:text>(Project)</xsl:text>
                      </a>
                    </span>
                  </li>
                  <xsl:apply-templates select="/Project/Item[@id]" mode="buildTree"/>
                </ul>
              </div>
              <script type="text/javascript">
                $("#navItems>ul").treeview({
                control: "#navItems div.treecontrol",
                collapsed: true
                });
              </script>
            </div>
          </div>
          <div class="ui-layout-center content">
            <div id="content">
              <div id="docs">
                <ul class="waitLoaded">
                  <xsl:apply-templates select="/Project"/>
                  <xsl:apply-templates select="/Project/Item[@id]"/>
                </ul>
              </div>
            </div>
          </div>
          <div class="ui-layout-east">
            <div class="navsub waitLoaded" id="navTypes">
              <div class="treecontrol">
                <a class="nav-command" href="#">Collapse All</a>
                <a class="nav-command" href="#">Expand All</a>
                <a class="nav-command" href="#">Toggle All</a>
              </div>
              <br/>
              <ul id="type-treeview" class="type-tree">
                <xsl:call-template name="addReferences"/>
              </ul>
            </div>
          </div>
          <!-- <div class="ui-layout-south">South</div> -->
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Project">
    <li id="project">
      <span class="item-header">
        <a class="name item-href" href="#{@id}">
          <xsl:text>(Project)</xsl:text>
        </a>
      </span>
      <br/>
      <div class="section">Properties</div>
      <table class="propertyTable">
        <tr>
          <th>Name</th>
          <th>Value</th>
        </tr>
        <xsl:for-each select="Properties/ProjectProperty">
          <tr>
            <xsl:if test="position() mod 2 = 1">
              <xsl:attribute name="class">tr-alt</xsl:attribute>
            </xsl:if>
            <td class="pName">
              <xsl:value-of select="@name"/>
            </td>
            <td class="pValue">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <xsl:if test="Item">
        <div class="section">Root Items</div>
        <xsl:call-template name="listChildItems"/>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template name="listChildItems">
    <xsl:for-each select="Item[@id]">
      <div class="child">
        <xsl:value-of select="position()"/>
        <xsl:text> - </xsl:text>
        <a class="item-href" href="#{@id}">
          <xsl:value-of select="@name"/>
        </a>
        <xsl:call-template name="itemCount">
          <xsl:with-param name="numItems" select="count(descendant::Item[@id])"/>
        </xsl:call-template>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ProjectProperty[@name='CodeReferences']/text()">
    <pre>
      <xsl:value-of select="."/>
    </pre>
  </xsl:template>

  <xsl:template match="Item[@id]" mode="buildTree">
    <li>
      <span class="item-node">
        <a class="item-href" href="#{@id}">
          <xsl:value-of select="@name"/>
        </a>
        <xsl:call-template name="itemCount">
          <xsl:with-param name="numItems" select="count(descendant::Item[@id])"/>
        </xsl:call-template>
      </span>
      <xsl:if test="Item[@id]">
        <ul>
          <xsl:apply-templates select="Item[@id]" mode="buildTree"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="Item[@id]">
    <xsl:variable name="linksTo" select="linkTo/link"/>
    <xsl:variable name="linksFrom" select="Property/linkFrom/link"/>
    <li id="{@id}">
      <span class="item-header">
        <xsl:variable name="parent" select="ancestor::Item[@id]"/>
        <xsl:if test="$parent">
          <xsl:for-each select="ancestor::Item[@id]">
            <a class="name item-href" href="#{@id}">
              <xsl:value-of select="@name"/>
            </a>
            <xsl:text>.</xsl:text>
          </xsl:for-each>
        </xsl:if>
        <a class="name item-href" href="#{@id}">
          <xsl:value-of select="@name"/>
        </a>
      </span>
      <br/>
      <div class="section">Properties</div>
      <table class="propertyTable">
        <tr>
          <th>Name</th>
          <th>Value</th>
        </tr>
        <tr class="tr-alt">
          <td class="pName">Type</td>
          <td class="pValue">
            <xsl:value-of select="@type"/>
          </td>
        </tr>
        <xsl:for-each select="Property">
          <tr>
            <xsl:if test="position() mod 2 = 0">
              <xsl:attribute name="class">tr-alt</xsl:attribute>
            </xsl:if>
            <td class="pName">
              <xsl:value-of select="@name"/>
            </td>
            <td class="pValue">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <xsl:if test="count($linksTo)">
        <div class="section">Links</div>
        <xsl:for-each select="$linksTo">
          <div class="link">
            <xsl:value-of select="position()"/>
            <xsl:text> - </xsl:text>
            <xsl:variable name="item" select="key('items-by-id', @id)"/>
            <a class="links-to item-href" href="#{$item/@id}">
              <xsl:value-of select="$item/@fullName"/>
            </a>
            <xsl:text> - (</xsl:text>
            <xsl:value-of select="@property"/>
            <xsl:text>)</xsl:text>
          </div>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="Item">
        <div class="section">Children</div>
        <xsl:call-template name="listChildItems"/>
      </xsl:if>
    </li>
    <xsl:apply-templates select="Item[@id]"/>
  </xsl:template>

  <xsl:template name="itemCount">
    <xsl:param name="numItems">0</xsl:param>
    <xsl:choose>
      <xsl:when test="$numItems= 0"></xsl:when>
      <xsl:when test="$numItems= 1">
        <span class="item-count"> - (1 Item)</span>
      </xsl:when>
      <xsl:otherwise>
        <span class="item-count">
          <xsl:text> - (</xsl:text>
          <xsl:value-of select="$numItems"/>
          <xsl:text> Items)</xsl:text>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="addReferences">
    <xsl:for-each select="/Project/Reference">
      <xsl:sort select="@name"/>
      <li>
        <span class="ref-node">
          <xsl:value-of select="@name"/>
        </span>
        <ul>
          <xsl:for-each select="Type">
            <xsl:sort select="@name"/>
            <xsl:variable name="type" select="@fullName"/>
            <xsl:variable name="items" select="key('items-by-type', $type)"/>
            <li>
              <span class="type-node">
                <xsl:value-of select="@name"/>
                <xsl:call-template name="itemCount">
                  <xsl:with-param name="numItems" select="count($items)"/>
                </xsl:call-template>
              </span>
              <ul>
                <xsl:for-each select="$items">
                  <xsl:sort select="@fullName"/>
                  <li>
                    <span class="item-node">
                      <a class="item-href" href="#{@id}">
                        <xsl:value-of select="@fullName"/>
                      </a>
                    </span>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:for-each>
        </ul>
      </li>
      <!--
      <xsl:variable name="types" select="//Item[@id and @reference=$reference and count(. | key('items-by-type', @type)[1]) = 1]"/>
      <xsl:variable name="items" select="key('items-by-type', @type)"/>
      <xsl:variable name="format">
        <xsl:choose>
          <xsl:when test="count($items) > 9999">00000</xsl:when>
          <xsl:when test="count($items) > 999">0000</xsl:when>
          <xsl:when test="count($items) > 99">000</xsl:when>
          <xsl:when test="count($items) > 9">00</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      -->
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Item[@type='Citect.Ampla.StandardItems.Code']/Property[@name='Source']">
    <code class="csharp">
      <xsl:value-of select="text()"/>
    </code>
  </xsl:template>

  <xsl:template match="Item[@id]/Property[contains(@name, 'CompileAction')]">
    <xsl:choose>
      <xsl:when test=". = 'None'">
        <span class="warning">
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="HistoricalExpressionConfig">
    <xsl:text>Expression: </xsl:text>
    <code class="csharp">
      <xsl:value-of select="ExpressionConfig/@format"/>
    </code>
    <xsl:for-each select="ExpressionConfig/ItemLinkCollection/ItemLink">
      <br/>
      <xsl:text>#ItemReference</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
      <a class="links-from item-href" href="#{$item/@id}">
        <xsl:value-of select="@absolutePath"/>
      </a>
    </xsl:for-each>
    <xsl:apply-templates select="DependencyCollection"/>
    <xsl:apply-templates select="ExpressionConfig/@compileAction"/>
  </xsl:template>

  <xsl:template match="property-value/HistoricalExpressionConfig">
    <xsl:text>Expression: </xsl:text>
    <code class="csharp">
      <xsl:value-of select="ExpressionConfig/@format"/>
    </code>
    <xsl:for-each select="ExpressionConfig/ItemLinkCollection/ItemLink">
      <br/>
      <xsl:text>#ItemReference</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
      <a class="links-from item-href" href="#{$item/@id}">
        <xsl:value-of select="@absolutePath"/>
      </a>
    </xsl:for-each>
    <xsl:apply-templates select="DependencyCollection"/>
    <xsl:apply-templates select="ExpressionConfig/@compileAction"/>
  </xsl:template>

  <xsl:template match="@compileAction">
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test=". = 'None'">
          <xsl:text>warning</xsl:text>
        </xsl:when>
        <xsl:otherwise>default</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <br/>
    <span class="{$class}">
      <xsl:text>CompileAction = </xsl:text>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- 
        <ItemLink relativePath="Hour" absolutePath="System Configuration.Periods.Hour" targetID="6a0aa9ac-8024-4dfd-8e33-106b7d002a3e"/>
  -->
  <xsl:template match="property-value/ItemLink[@targetID]">
    <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
    <a class="links-from item-href" href="#{$item/@id}">
      <xsl:value-of select="@absolutePath"/>
    </a>
  </xsl:template>

  <xsl:template match="property-value/ItemLink[@type]">
    <xsl:variable name="item" select="key('items-by-fullName', @absolutePath)"/>
    <br/>
    <a class="links-from item-href" href="#{$item/@id}">
      <xsl:value-of select="@absolutePath"/>
    </a>
  </xsl:template>

  <!-- 
                  <DependencyCollection>
                    <Dependency dependencyType="Trigger">
                      <ItemPropertyLink propertyName="Samples">
                        <ItemLink relativePath="Parent.Parent.Parent.Create New Pallet Record" absolutePath="UTC.WAH.Snacks.1 Line 1.Create New Pallet Record" targetID="49127807-664a-4366-afa8-219736d5149e" resolveMode="Smart">
                        </ItemLink>
                      </ItemPropertyLink>
                    </Dependency>
                  </DependencyCollection>
  -->
  <xsl:template match="DependencyCollection">
    <xsl:for-each select="Dependency/ItemPropertyLink/ItemLink">
      <br/>
      <xsl:text>#Dependency</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
      <a class="links-from item-href" href="#{$item/@id}">
        <xsl:value-of select="@absolutePath"/>
      </a>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="../@propertyName"/>
    </xsl:for-each>

  </xsl:template>

  <!-- 
  <FunctionConfig format="EOM.ProcessHeldRecords(project,&quot;UTC.WAH.Snacks.2 Line 2.Production&quot;);" compileAction="Compile">
  </FunctionConfig>
  -->

  <xsl:template match="FunctionConfig">
    <xsl:text>Function: </xsl:text>
    <code class="csharp">
      <xsl:value-of select="@format"/>
    </code>
    <xsl:for-each select="ItemLinkCollection/ItemLink">
      <br/>
      <xsl:text>#ItemReference</xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text># = </xsl:text>
      <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
      <a class="links-from item-href" href="#{$item/@id}">
        <xsl:value-of select="@absolutePath"/>
      </a>
    </xsl:for-each>
    <xsl:apply-templates select="@compileAction"/>
  </xsl:template>

  <!--
  <Property name="SourceData">
    <linkFrom>
      <link id="799a82e1-d3f2-8849-fb94-3d5e4141d098" fullName="Impala.BMR.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121"></link>
    </linkFrom>
    <property-value>
      <ItemLocations>
        <ItemLink relativePath="Parent.Parent.Parent.Parent.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121" absolutePath="Impala.BMR.Laboratory.Daily.Leach B 1st Stage Thickeners Solids Analysis 2121" targetID="799a82e1-d3f2-8849-fb94-3d5e4141d098" resolveMode="Smart">
        </ItemLink>
      </ItemLocations>
    </property-value>
  </Property>
  -->
  <xsl:template match="property-value/ItemLocations">
    <xsl:for-each select="ItemLink">
      <xsl:variable name="item" select="key('items-by-id', @targetID)"/>
      <div>
        <a class="links-from item-href" href="#{$item/@id}">
          <xsl:value-of select="@absolutePath"/>
        </a>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="property-value[text()]">
    <xsl:variable name="item" select="key('items-by-fullName', text())"/>
    <xsl:choose>
      <xsl:when test="$item">
        <a class="links-from item-href" href="#{$item/@id}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getItemFullName">
    <xsl:for-each select="ancestor-or-self::Item[@id]">
      <xsl:if test="position()>1">
        <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:value-of select="@name"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
