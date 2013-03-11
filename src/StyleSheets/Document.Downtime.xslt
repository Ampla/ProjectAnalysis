<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                >

  <xsl:output method="html"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  
    indent="no"
              />

  <xsl:param name="lang">en</xsl:param>

  <xsl:key name="none" match="None" use="@none"/>
  <xsl:key name="cause-by-id" match="Cause" use="@cause"/>
  <xsl:key name="classification-by-id" match="Classification" use="@classification" />
  <xsl:key name="effect-by-id" match="Effect" use="@effect" />
  
  <xsl:key name="matrix-by-cause" match="Matrix" use="@cause"/>
  <xsl:key name="matrix-by-classification" match="Matrix" use="@classification"/>
  <xsl:key name="matrix-by-effect" match="Matrix" use="@effect"/>

  <xsl:variable name="causes" select="/Project/Cause"/>
  <xsl:variable name="classifications" select="/Project/Classification"/>
  <xsl:variable name="effects" select="/Project/Effect"/>
  <xsl:variable name="equipmentTypes" select="/Project/EquipmentType"/>
  <xsl:variable name="relationshipMatrixs" select="/Project/EquipmentType/RelationshipMatrix/Matrix"/>

  <xsl:template match="/Project">
      <html>
        <xsl:if test="$lang">
          <xsl:attribute name="lang">
            <xsl:value-of select="$lang"/>
          </xsl:attribute>
          <xsl:attribute name="xml:lang">
            <xsl:value-of select="$lang"/>
          </xsl:attribute>
        </xsl:if>
        <head>
          <title lang="en">Ampla Project - Relationship Matrix Summary</title>
          <link rel="stylesheet" type="text/css" href="css/downtime.css" media="screen,projector"/>
          <script type="text/javascript" src="lib/jquery-1.3.2.min.js"/>
          <script type="text/javascript" src="lib/downtime.js"/>
        </head>
        <body>
          <a name="top"/>
          <h1 class="text">Ampla Project - Relationship Matrix Summary</h1>
          <hr/>
          <xsl:call-template name="summary"/>
          <xsl:call-template name="equipmentMatrix"/>
          <xsl:choose>
            <xsl:when test="count($effects) > 0">
              <xsl:call-template name="equipmentTypes-witheffects"/>
              <xsl:call-template name="classifications-witheffects"/>
              <xsl:call-template name="causeCodes-witheffects"/>
              <xsl:call-template name="effects"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="equipmentTypes-noeffect"/>
              <xsl:call-template name="classifications-noeffect"/>
              <xsl:call-template name="causeCodes-noeffect"/>
              <xsl:call-template name="effects"/>
            </xsl:otherwise>
          </xsl:choose>
        </body>
      </html>
  </xsl:template>
  
  
  <xsl:template name="equipmentTypes-witheffects">
    <xsl:if test="count($equipmentTypes) > 0">
      <a name="equipment"/>
      <h3>Equipment Types</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>Equipment Type</th>
            <th>Classifications / Causes / Effects</th>
          </tr>
          <xsl:for-each select="$equipmentTypes">
            <xsl:sort select="@name"/>
            <xsl:sort select="@fullName"/>
            <xsl:variable name="equipment" select="."/>
            <tr>
              <td title="{@fullName}">
                <a name="{@hash}"/>
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="equipment-classifications" select="key('classification-by-id', RelationshipMatrix/Matrix/@classification)"/>
                <xsl:if test="count($equipment-classifications) > 0">
                  <xsl:variable name="matrix" select="RelationshipMatrix/Matrix"/>
                  <xsl:variable name="causes" select="key('cause-by-id', $equipment/RelationshipMatrix/Matrix/@cause)"/>
                  <xsl:variable name="classifications" select="key('classification-by-id', $equipment/RelationshipMatrix/Matrix/@classification)"/>
                  <xsl:variable name="effects" select="key('effect-by-id', $equipment/RelationshipMatrix/Matrix/@effect)"/>
                  <div class="summary">
                    <xsl:value-of select="concat (count($matrix), ' entries (', count($classifications), ' classifications, ', count($causes), ' causes, ', count($effects), ' effects, ')"/>
                  </div>
                  <table class="details">
                    <tbody>
                      <tr>
                        <xsl:for-each select="$equipment-classifications">
                          <xsl:sort select="@name"/>
                          <th>
                            <xsl:call-template name="listItems">
                              <xsl:with-param name="items" select="."/>
                            </xsl:call-template>
                          </th>
                        </xsl:for-each>
                      </tr>
                      <tr>
                        <xsl:for-each select="$equipment-classifications">
                          <xsl:sort select="@name"/>
                          <xsl:variable name="classificationId" select="@classification"/>
                          <td>
                            <xsl:call-template name="buildTable">
                              <xsl:with-param name="matrix" select="$equipment/RelationshipMatrix/Matrix[@classification=$classificationId]"/>
                              <xsl:with-param name="column">cause</xsl:with-param>
                              <xsl:with-param name="values">effect</xsl:with-param>
                            </xsl:call-template>
                          </td>
                        </xsl:for-each>
                      </tr>
                    </tbody>
                  </table>
                </xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="equipmentTypes-noeffect">
    <xsl:if test="count($equipmentTypes) > 0">
      <a name="equipment"/>
      <h3>Equipment Types</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>Equipment Type</th>
            <th>Classifications / Causes</th>
          </tr>
          <xsl:for-each select="$equipmentTypes">
            <xsl:sort select="@name"/>
            <xsl:variable name="equipment" select="."/>
            <tr>
              <td title="{@fullName}">
                <a name="{@hash}"/>
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="equipment-classifications" select="key('classification-by-id', RelationshipMatrix/Matrix/@classification)"/>
                <xsl:if test="count($equipment-classifications) > 0">
                  <xsl:variable name="matrix" select="RelationshipMatrix/Matrix"/>
                  <xsl:variable name="causes" select="key('cause-by-id', $equipment/RelationshipMatrix/Matrix/@cause)"/>
                  <xsl:variable name="classifications" select="key('classification-by-id', $equipment/RelationshipMatrix/Matrix/@classification)"/>
                  <div class="summary">
                    <xsl:value-of select="concat (count($matrix), ' entries (', count($classifications), ' classifications, ', count($causes), ' causes)')"/>
                  </div>
                  <xsl:call-template name="buildTable">
                    <xsl:with-param name="matrix" select="$equipment/RelationshipMatrix/Matrix"/>
                    <xsl:with-param name="column">classification</xsl:with-param>
                    <xsl:with-param name="values">cause</xsl:with-param>
                    <xsl:with-param name="class">details</xsl:with-param>
                  </xsl:call-template>
                </xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="causeCodes-noeffect">
    <xsl:if test="count($causes) > 0">
      <a name="cause"/>
      <h3>Cause Codes</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>#</th>
            <th>Cause</th>
            <th>Classifications / Equipment Types</th>
          </tr>
          <xsl:for-each select="$causes">
            <xsl:variable name="causeId" select="@cause"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:value-of select="@cause"/>
              </td>
              <td title="{@fullName}">
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="matrix" select="/Project/EquipmentType/RelationshipMatrix/Matrix[@cause=$causeId]"/>
                <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
                <xsl:variable name="equipmentTypes" select="$matrix/ancestor::EquipmentType"/>

                <div class="summary">
                  <xsl:value-of select="concat (count($matrix), ' entries (', count($classifications), ' Classifications, ', count($equipmentTypes), ' Equipment Types)')"/>
                </div>
                <xsl:call-template name="buildTable">
                  <xsl:with-param name="matrix" select="$matrix[@cause=$causeId]"/>
                  <xsl:with-param name="column">classification</xsl:with-param>
                  <xsl:with-param name="values">equipment</xsl:with-param>
                  <xsl:with-param name="class">details</xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="causeCodes-witheffects">
    <xsl:if test="count($causes) > 0">
      <a name="cause"/>
      <h3>Cause Codes</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>#</th>
            <th>Cause</th>
            <th>Classifications / Effect / Equipment Types</th>
          </tr>
          <xsl:for-each select="$causes">
            <xsl:variable name="causeId" select="@cause"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:value-of select="@cause"/>
              </td>
              <td title="{@fullName}">
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="matrix" select="key('matrix-by-cause', $causeId)"/>
                <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
                <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>
                <xsl:variable name="equipmentTypes" select="$matrix/ancestor::EquipmentType"/>

                <div class="summary">
                  <xsl:value-of select="concat (count($matrix), ' entries (', count($classifications), ' Classifications, ', count($effects), ' Effects, ', count($equipmentTypes), ' Equipment Types)')"/>
                </div>
                <table class="details">
                  <tbody>
                    <tr>
                      <xsl:for-each select="$classifications">
                        <th>
                          <xsl:call-template name="listItems">
                            <xsl:with-param name="items" select="."/>
                          </xsl:call-template>
                        </th>
                      </xsl:for-each>
                    </tr>
                    <tr>
                      <xsl:for-each select="$classifications">
                        <xsl:sort select="@name"/>
                        <xsl:variable name="classificationId" select="@classification"/>
                        <td>
                          <xsl:call-template name="buildTable">
                            <xsl:with-param name="matrix" select="$matrix[@classification=$classificationId]"/>
                            <xsl:with-param name="column">effect</xsl:with-param>
                            <xsl:with-param name="values">equipment</xsl:with-param>
                          </xsl:call-template>
                        </td>
                      </xsl:for-each>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="classifications-noeffect">
    <xsl:if test="count($classifications) > 0">
      <a name="classification"/>
      <h3>Classifications</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>#</th>
            <th>Classification</th>
            <th>Equipment Types / Causes</th>
          </tr>
          <xsl:for-each select="$classifications">
            <xsl:variable name="classificationId" select="@classification"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:value-of select="@classification"/>
              </td>
              <td title="{@fullName}">
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="matrix" select="/Project/EquipmentType/RelationshipMatrix/Matrix[@classification=$classificationId]"/>
                <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
                <xsl:variable name="equipmentTypes" select="$matrix/ancestor::EquipmentType"/>

                <div class="summary">
                  <xsl:value-of select="concat (count($matrix), ' entries (', count($equipmentTypes), ' Equipment Types, ', count($causes), ' causes)')"/>
                </div>
                <xsl:call-template name="buildTable">
                  <xsl:with-param name="matrix" select="$matrix"/>
                  
                  <!-- need to add the parent grouping -->
                  <xsl:with-param name="parent-group">classification</xsl:with-param>
                  <xsl:with-param name="parent-value" select="$classificationId"/>
                  
                  <xsl:with-param name="column">equipment</xsl:with-param>
                  <xsl:with-param name="values">cause</xsl:with-param>
                  <xsl:with-param name="class">details</xsl:with-param>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="classifications-witheffects">
    <xsl:if test="count($classifications) > 0">
      <a name="classification"/>
      <h3>Classifications</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>#</th>
            <th>Classification</th>
            <th>Causes / Effects / Equipment Types</th>
          </tr>
          <xsl:for-each select="$classifications">
            <xsl:variable name="classificationId" select="@classification"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:value-of select="@classification"/>
              </td>
              <td title="{@fullName}">
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="matrix" select="key('matrix-by-classification', $classificationId)"/>
                <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
                <xsl:variable name="effects" select="key('effect-by-id', $matrix/@effect)"/>
                <xsl:variable name="equipmentTypes" select="$matrix/ancestor::EquipmentType"/>

                <div class="summary">
                  <xsl:value-of select="concat (count($matrix), ' entries (', count($causes), ' Causes, ', count($effects), ' Effects, ', count($equipmentTypes), ' Equipment Types)')"/>
                </div>
                <table class="details">
                  <tbody>
                    <tr>
                      <xsl:for-each select="$causes">
                        <xsl:sort select="@name"/>
                        <th>
                          <xsl:call-template name="listItems">
                            <xsl:with-param name="items" select="."/>
                          </xsl:call-template>
                        </th>
                      </xsl:for-each>
                    </tr>
                    <tr>
                      <xsl:for-each select="$causes">
                        <xsl:sort select="@name"/>
                        <xsl:variable name="causeId" select="@cause"/>
                        <td>
                          <xsl:call-template name="buildTable">
                            <xsl:with-param name="matrix" select="$matrix[@cause=$causeId]"/>
                            <xsl:with-param name="column">effect</xsl:with-param>
                            <xsl:with-param name="values">equipment</xsl:with-param>
                          </xsl:call-template>
                        </td>
                      </xsl:for-each>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="effects">
    <xsl:if test="count($effects) > 0">
      <a name="effect"/>
      <h3>Effects</h3>
      <xsl:call-template name="showAll"/>
      <table>
        <tbody>
          <tr>
            <th>#</th>
            <th>Effect</th>
            <th>Classifications / Cause / Equipment Types</th>
          </tr>
          <xsl:for-each select="$effects">
            <xsl:variable name="effectId" select="@effect"/>
            <tr>
              <td>
                <a name="{@hash}"/>
                <xsl:value-of select="@effect"/>
              </td>
              <td title="{@fullName}">
                <xsl:value-of select="@name"/>
              </td>
              <td>
                <xsl:variable name="matrix" select="key('matrix-by-effect', $effectId)"/>
                <xsl:variable name="classifications" select="key('classification-by-id', $matrix/@classification)"/>
                <xsl:variable name="causes" select="key('cause-by-id', $matrix/@cause)"/>
                <xsl:variable name="equipmentTypes" select="$matrix/ancestor::EquipmentType"/>

                <div class="summary">
                  <xsl:value-of select="concat (count($matrix), ' entries (', count($classifications), ' Classifications, ', count($causes), ' Causes, ', count($equipmentTypes), ' Equipment Types)')"/>
                </div>
                <table class="details">
                  <tbody>
                    <tr>
                      <xsl:for-each select="$classifications">
                        <xsl:sort select="@name"/>
                        <th>
                          <xsl:call-template name="listItems">
                            <xsl:with-param name="items" select="."/>
                          </xsl:call-template>
                        </th>
                      </xsl:for-each>
                    </tr>
                    <tr>
                      <xsl:for-each select="$classifications">
                        <xsl:sort select="@name"/>
                        <xsl:variable name="classificationId" select="@classification"/>
                        <td>
                          <xsl:call-template name="buildTable">
                            <xsl:with-param name="matrix" select="$matrix[@classification=$classificationId]"/>
                            <xsl:with-param name="column">cause</xsl:with-param>
                            <xsl:with-param name="values">equipment</xsl:with-param>
                          </xsl:call-template>
                        </td>
                      </xsl:for-each>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <hr/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="buildTable">
    <xsl:param name="matrix"></xsl:param>
    <xsl:param name="column"></xsl:param>
    <xsl:param name="values"></xsl:param>
    <xsl:param name="class"></xsl:param>
    <xsl:param name="parent-group"></xsl:param>
    <xsl:param name="parent-value"></xsl:param>
    <xsl:variable name="parentName">
      <xsl:choose>
        <xsl:when test="$column='equipment'">EquipmentType</xsl:when>
        <xsl:otherwise>none</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="column-key">
      <xsl:choose>
        <xsl:when test="$column='cause'">cause-by-id</xsl:when>
        <xsl:when test="$column='classification'">classification-by-id</xsl:when>
        <xsl:when test="$column='effect'">effect-by-id</xsl:when>
        <xsl:otherwise>none</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="value-key">
      <xsl:choose>
        <xsl:when test="$values='cause'">cause-by-id</xsl:when>
        <xsl:when test="$values='classification'">classification-by-id</xsl:when>
        <xsl:when test="$values='effect'">effect-by-id</xsl:when>
        <xsl:otherwise>none</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="column-values" select="key($column-key, $matrix/@*[name()=$column]) | $matrix/ancestor::*[name() = $parentName]"/>
    <xsl:choose>
      <xsl:when test="count($matrix) > 0">
        <table>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <tbody>
            <tr>
              <xsl:for-each select="$column-values">
                <xsl:sort select="@name"/>
                <th>
                  <xsl:call-template name="listItems">
                    <xsl:with-param name="items" select="."/>
                  </xsl:call-template>
                </th>
              </xsl:for-each>
            </tr>
            <tr>
              <xsl:for-each select="$column-values">
                <xsl:sort select="@name"/>
                <xsl:variable name="current" select="."/>
                <xsl:variable name="columnId" select="@*[name()=$column]"/>
                <td>
                  <xsl:choose>
                    <xsl:when test="$column='equipment'">
                      <!-- need to apply the parent grouping when doing by equipment -->
                      <xsl:call-template name="listItems">
                        <xsl:with-param name="items" select="key($value-key, $current/RelationshipMatrix/Matrix[@*[name()=$parent-group]=$parent-value]/@*[name()=$values])"/>
                        <xsl:with-param name="mode">div</xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$values='equipment'">
                      <xsl:call-template name="listItems">
                        <xsl:with-param name="items" select="$matrix[@*[name()=$column]=$columnId]/ancestor::EquipmentType"/>
                        <xsl:with-param name="mode">div</xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="listItems">
                        <xsl:with-param name="items" select="key($value-key, $matrix[@*[name()=$column]=$columnId]/@*[name()=$values])"/>
                        <xsl:with-param name="mode">div</xsl:with-param>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </xsl:for-each>
            </tr>

          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <table>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <tbody>
            <tr>
              <th>N/A</th>
            </tr>
          </tbody>
        </table>        
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="listItems">
    <xsl:param name="items"/>
    <!-- possible options include : 'csv', 'ul', 'div'-->
    <xsl:param name="mode">csv</xsl:param>
    <xsl:param name="summaryText"></xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($summaryText) > 0">
        <div class="summary">
          <xsl:value-of select="count($items)"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$summaryText"/>
        </div>
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$items"/>
          <xsl:with-param name="mode" select="$mode"/>
          <xsl:with-param name="class">details</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="list">
          <xsl:with-param name="items" select="$items"/>
          <xsl:with-param name="mode" select="$mode"/>
        </xsl:call-template>
      </xsl:otherwise>      
    </xsl:choose>
  </xsl:template>

  <xsl:template name="list">
    <xsl:param name="items"/>
    <!-- possible options include : 'csv', 'ul', 'div'-->
    <xsl:param name="mode">csv</xsl:param>
    <xsl:param name="class"></xsl:param>
    <xsl:choose>
      <xsl:when test="$mode='ul'">
        <ul>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
            <li>
              <a href="#{@hash}" title="{name()}">
                <xsl:value-of select="@name"/>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:when test="$mode='div'">
        <span>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
          <div>
            <a href="#{@hash}" title="{name()}">
              <xsl:value-of select="@name"/>
            </a>
          </div>
        </xsl:for-each>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:if test="string-length($class) > 0">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="$items">
            <xsl:if test="position() > 1">, </xsl:if>
            <a href="#{@hash}" title="{name()}">
              <xsl:value-of select="@name"/>
            </a>
          </xsl:for-each>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="summary">
    <xsl:variable name="matrix" select="/Project/EquipmentType/RelationshipMatrix/Matrix"/>
    <xsl:variable name="equipment" select="$matrix/ancestor::EquipmentType"/>
    <xsl:variable name="cause" select="key('cause-by-id', $matrix/@cause)"/>
    <xsl:variable name="classification" select="key('classification-by-id', $matrix/@classification)"/>
    <xsl:variable name="effect" select="key('effect-by-id', $matrix/@effect)"/>

    <h3>Summary</h3>
    <table>
      <tr>
        <th>Dimension</th>
        <th>Count</th>
        <th title="Average number of entries per dimension">Average</th>
      </tr>
      <tr>
        <td title="Relationship Matrix Entries">
          <a href="#matrix">Relationship Matrix</a>
        </td>
        <td>
          <span title="{count($matrix)} entries">
            <xsl:value-of select="format-number(count($matrix), '#,##0')"/>
          </span>
        </td>
        <td>
          <span title="{count($matrix)} entries">-</span>
        </td>
      </tr>
      <tr>
        <td>
          <a href="#equipment">Equipment Types</a>
        </td>
        <td title="{count($equipment)} equipment types">
          <span>
            <xsl:value-of select="format-number(count($equipment), '#,##0')"/>
          </span>
        </td>
        <td title="{count($matrix)} entries / {count($equipment)} equipment types">
          <span>
            <xsl:value-of select="format-number(count($matrix) div count($equipment), '#.00')"/>
          </span>
        </td>
      </tr>
      <tr>
        <td>
          <a href="#classification">Classifications</a>
        </td>
        <td title="{count($classification)} classifications">
          <span>
            <xsl:value-of select="format-number(count($classification), '#,##0')"/>
          </span>
        </td>
        <td title="{count($matrix)} entries / {count($classification)} classifications">
          <span>
            <xsl:value-of select="format-number(count($matrix) div count($classification), '#.00')"/>
          </span>
        </td>
      </tr>
      <tr>
        <td>
          <a href="#cause">Causes</a>
        </td>
        <td title="{count($cause)} causes">
          <span>
            <xsl:value-of select="format-number(count($cause), '#,##0')"/>
          </span>
        </td>
        <td title="{count($matrix)} entries / {count($cause)} causes">
          <span>
            <xsl:value-of select="format-number(count($matrix) div count($cause), '#.00')"/>
          </span>
        </td>
      </tr>
      <tr>
        <td>
          <a href="#effect">Effects</a>
        </td>
        <td title="{count($effect)} effects">
          <span>
            <xsl:value-of select="format-number(count($effect), '#,##0')"/>
          </span>
        </td>
        <xsl:choose>
          <xsl:when test="count($effects) > 0">
            <td title="{count($matrix)} entries / {count($effect)} effects">
              <span>
                <xsl:value-of select="format-number(count($matrix) div count($effect), '#.00')"/>
              </span>
            </td>
          </xsl:when>
          <xsl:otherwise>
            <td title="{count($effect)} effects">
              <span>-</span>
            </td>
          </xsl:otherwise>
        </xsl:choose>
      </tr>
    </table>
    <hr/>
  </xsl:template>

  <xsl:template name="equipmentMatrix">
    <a name="matrix"/>
    <h3>Relationship Matrix</h3>
    <xsl:call-template name="showAll"/>
    <table class="details">
      <tbody>
        <tr>
          <th rowspan="2">Cause / Classifications</th>
          <th colspan="{count($equipmentTypes)}">Equipment Types</th>
        </tr>
        <tr>
          <xsl:for-each select="$equipmentTypes">
            <th>
              <xsl:call-template name="listItems">
                <xsl:with-param name="items" select="."/>
              </xsl:call-template>
            </th>
          </xsl:for-each>
        </tr>
        <xsl:for-each select="$causes">
          <tr>
            <th>
              <xsl:call-template name="listItems">
                <xsl:with-param name="items" select="."/>
              </xsl:call-template>
            </th>
            <xsl:variable name="causeId" select="@cause"/>
            <xsl:for-each select="$equipmentTypes">
              <xsl:variable name="equipment" select="."/>
              <td>
                <xsl:variable name="matrix" select="$equipment/RelationshipMatrix/Matrix[@cause=$causeId]"/>
                <xsl:choose>
                  <xsl:when test="not($matrix)">
                    <xsl:call-template name="space"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="listItems">
                      <xsl:with-param name="items" select="key('classification-by-id', $matrix/@classification)"/>
                      <xsl:with-param name="mode">div</xsl:with-param>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </xsl:for-each>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
    <hr/>
  </xsl:template>

  <xsl:template name="space">
    <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
  </xsl:template>

  <xsl:template name="showAll">
    <a href="#" class="summary show-all">Show All</a>
  </xsl:template>
  
</xsl:stylesheet>
