<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >
  <!-- This XSL transforms downtime data into an Office XML 2003 file.
     Unlike other reports, it is application folder center, to easily review per equipment data with customers.
     
     Output will be :
     Application Folder Fullname | Equipment type | Classification | Cause | Effect
-->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='Excel.Common.xslt' />

  <xsl:variable name='quote'>'</xsl:variable>

  <xsl:key name="none" match="None" use="@none"/>
  <xsl:key name="cause-by-id" match="Cause" use="@cause"/>
  <xsl:key name="classification-by-id" match="Classification" use="@classification" />
  <xsl:key name="effect-by-id" match="Effect" use="@effect" />

  <xsl:key name="matrix-by-cause" match="Matrix" use="@cause"/>
  <xsl:key name="matrix-by-classification" match="Matrix" use="@classification"/>
  <xsl:key name="matrix-by-effect" match="Matrix" use="@effect"/>
  <xsl:key name="locations-by-fullname" match="Location" use="@fullName"/>
  <xsl:key name="cause-location-by-fullname" match="CauseLocation" use="@fullName"/>
  <xsl:key name="downtimes-by-cause-location" match="DowntimeReportingPoint" use="CauseLocations/CauseLocation/@fullName" />

  <xsl:variable name="causes" select="/Project/Causes/Cause"/>
  <xsl:variable name="classifications" select="/Project/Classifications/Classification"/>
  <xsl:variable name="effects" select="/Project/Effects/Effect"/>
  <xsl:variable name="equipmentTypes" select="/Project/EquipmentTypes/EquipmentType"/>
  <xsl:variable name="relationshipMatrixs" select="/Project/EquipmentTypes/EquipmentType/RelationshipMatrix/Matrix"/>
  <xsl:variable name="applicationFolders" select="/Project/EquipmentTypes/EquipmentType/Locations/Location[generate-id() = generate-id(key('locations-by-fullname', @fullName)[1])]"/>
  <xsl:variable name="downtimeReportingPoints" select="/Project/DowntimeReportingPoints/DowntimeReportingPoint"/>

  <xsl:variable name="usedLocations" select="/Project/EquipmentTypes/EquipmentType/Locations/Location"/>
  <xsl:variable name="missingLocations" select="/Project/Locations/Location"/>
  <xsl:variable name="all-locations" select="$usedLocations | $missingLocations"/>

  <xsl:template match="/Project">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name="Downtime">
        <Table>
          <xsl:call-template name='header-row-5-columns'>
            <xsl:with-param name='column-1'>Application Folder</xsl:with-param>
            <xsl:with-param name='column-2'>Classification</xsl:with-param>
            <xsl:with-param name='column-3'>Cause</xsl:with-param>
            <xsl:with-param name='column-4'>Effect</xsl:with-param>
            <xsl:with-param name='column-5'>Equipment Type</xsl:with-param>
          </xsl:call-template>

          <xsl:for-each select="$applicationFolders">
            <xsl:sort select="@fullName"/>
            <xsl:variable name="appFolder" select="."/>
            <xsl:variable name="parentTypes" select="//EquipmentType[Locations/Location/@fullName=$appFolder/@fullName]"/>
            <xsl:for-each select="$parentTypes">
              <xsl:variable name="eqType" select="."/>
              <xsl:for-each select="$relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name]">
                <xsl:sort select="$classifications[@classification = ./@classification]/@name" data-type="text"/>
                <xsl:sort select="$causes[@cause = ./@cause]/@name" data-type="text"/>
                <xsl:sort select="$effects[@effect = ./@effect]/@name" data-type="text" />
                <xsl:variable name="matrixRow" select="."/>
                <xsl:call-template name='data-row-5-columns'>
                  <xsl:with-param name='column-1' select='$appFolder/@fullName'/>
                  <xsl:with-param name='column-2' select='$classifications[@classification = $matrixRow/@classification]/@name'/>
                  <xsl:with-param name='column-3' select='$causes[@cause = $matrixRow/@cause]/@name'/>
                  <xsl:with-param name='column-4' select='$effects[@effect = $matrixRow/@effect]/@name'/>
                  <xsl:with-param name='column-5' select='$eqType/@name'/>
                </xsl:call-template>

              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>

        </Table>
      </Worksheet>

      <Worksheet ss:Name='Classifications'>
        <Table>
          <xsl:call-template name='header-row-3-columns'>
            <xsl:with-param name='column-1'>Classification ID</xsl:with-param>
            <xsl:with-param name='column-2'>Classification</xsl:with-param>
            <xsl:with-param name='column-3'>Reference count</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$classifications'>
            <xsl:sort select="@classification" data-type="number"/>
            <xsl:variable name="current" select="." />
            <Row>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="@classification" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="@name" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="count($relationshipMatrixs[@module='Downtime' and @classification = $current/@classification])" ></xsl:with-param>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Causes'>
        <Table>
          <xsl:call-template name='header-row-3-columns'>
            <xsl:with-param name='column-1'>Cause ID</xsl:with-param>
            <xsl:with-param name='column-2'>Cause</xsl:with-param>
            <xsl:with-param name='column-3'>Reference count</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$causes'>
            <xsl:sort select="@name" data-type="text"/>
            <xsl:variable name="current" select="." />
            <Row>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="@cause" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="@name" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="count($relationshipMatrixs[@module='Downtime' and @cause = $current/@cause])" ></xsl:with-param>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Effects'>
        <Table>
          <xsl:call-template name='header-row-3-columns'>
            <xsl:with-param name='column-1'>Effect ID</xsl:with-param>
            <xsl:with-param name='column-2'>Effect</xsl:with-param>
            <xsl:with-param name='column-3'>Reference count</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$effects'>
            <xsl:sort select="@name" data-type="text"/>
            <xsl:variable name="current" select="." />
            <Row>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="@effect" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="@name" ></xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="number-cell">
                <xsl:with-param name="value" select="count($relationshipMatrixs[@module='Downtime' and @effect = $current/@effect])" ></xsl:with-param>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name="Equipment Types">
        <Table>
          <xsl:call-template name='header-row-5-columns'>
            <xsl:with-param name='column-1'>Equipment Type</xsl:with-param>
            <xsl:with-param name='column-2'>Classification</xsl:with-param>
            <xsl:with-param name='column-3'>Cause</xsl:with-param>
            <xsl:with-param name='column-4'>Effect</xsl:with-param>
            <xsl:with-param name='column-5'>Matrix rowcout</xsl:with-param>
          </xsl:call-template>

          <xsl:for-each select="$equipmentTypes">
            <xsl:sort select="@fullName"/>
            <xsl:variable name="eqType" select="."/>
            <xsl:variable name="matrixRowCount" select="count($relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name])"/>

            <!-- Output EquipmentTypes not referred in any matrix as empty rows with 0 count -->
            <xsl:if test="$matrixRowCount=0" >
              <Row>
                <xsl:call-template name='text-cell' />
                <xsl:call-template name='text-cell' />
                <xsl:call-template name='text-cell' />
                <xsl:call-template name='text-cell' />
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="$matrixRowCount" />
                </xsl:call-template>
              </Row>
            </xsl:if>

            <!-- Output EquipmentType relationship matrix -->
            <xsl:for-each select="$relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name]">
              <xsl:variable name="matrixRow" select="."/>
              <Row>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$eqType/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$classifications[@classification = $matrixRow/@classification]/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$causes[@cause = $matrixRow/@cause]/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$effects[@effect = $matrixRow/@effect]/@name'/>
                </xsl:call-template>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="$matrixRowCount" />
                </xsl:call-template>
              </Row>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='DowntimeCauseLocations'>
        <Table>
          <xsl:call-template name='header-row-4-columns'>
            <xsl:with-param name='column-1'>DowntimeReportingPoint</xsl:with-param>
            <xsl:with-param name='column-2'>CauseLocation</xsl:with-param>
            <xsl:with-param name='column-3'>EquipmentType</xsl:with-param>
            <xsl:with-param name='column-4'>Messages</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$downtimeReportingPoints'>
            <xsl:variable name='point' select='.'/>
            <xsl:choose>
              <xsl:when test='count($point/CauseLocations/CauseLocation) = 0'>
                <xsl:call-template name='data-row-3-columns'>
                  <xsl:with-param name='column-1' select='$point/@fullName'/>
                  <xsl:with-param name='column-2'>{all}</xsl:with-param>
                  <xsl:with-param name='column-3'>{na}</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select='$point/CauseLocations/CauseLocation'>
                  <xsl:variable name='location' select='key("locations-by-fullname", @fullName)'/>
                  <xsl:variable name='equipmentType' select='$location/ancestor::EquipmentType'/>
                  <xsl:variable name='eqType'>
                    <xsl:choose>
                      <xsl:when test='not($equipmentType)'></xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select='$equipmentType/@name'/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name='message'>
                    <xsl:choose>
                      <xsl:when test='@message'>
                        <xsl:value-of select='@message'/>
                      </xsl:when>
                      <xsl:when test='not($equipmentType)'>No EquipmentType specified</xsl:when>
                      <xsl:when test='count($equipmentType/RelationshipMatrix/Matrix) = 0'>
                        <xsl:value-of select='$eqType'/> is empty
                      </xsl:when>
                      <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:call-template name='data-row-4-columns'>
                    <xsl:with-param name='column-1' select='$point/@fullName'/>
                    <xsl:with-param name='column-2' select='@fullName'/>
                    <xsl:with-param name='column-3' select='$eqType'/>
                    <xsl:with-param name='column-4' select='$message'/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Locations'>
        <Table>
          <xsl:call-template name='header-row-5-columns'>
            <xsl:with-param name='column-1'>Location</xsl:with-param>
            <xsl:with-param name='column-2'>EquipmentType</xsl:with-param>
            <xsl:with-param name='column-3'>RelationshipMatrix</xsl:with-param>
            <xsl:with-param name='column-4'>Downtime</xsl:with-param>
            <xsl:with-param name='column-5'>Messages</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$all-locations'>
            <xsl:sort select="@fullName"/>
            <xsl:variable name="equipmentType" select="ancestor::EquipmentType"/>
            <xsl:variable name="matrix" select="$equipmentType/RelationshipMatrix/Matrix"/>
            <xsl:variable name="c" select="key('cause-by-id', $matrix/@cause)"/>
            <xsl:variable name="cl" select="key('classification-by-id', $matrix/@classification)"/>
            <xsl:variable name="ef" select="key('effect-by-id', $matrix/@effect)"/>
            <xsl:variable name="downtimes" select="key('downtimes-by-cause-location', @fullName)"/>

            <xsl:call-template name='data-row-5-columns'>
              <xsl:with-param name='column-1' select='@fullName'/>
              <xsl:with-param name='column-2'>
                <xsl:choose>
                  <xsl:when test="not($equipmentType)"></xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$equipmentType/@name"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name='column-3'>
                <xsl:choose>
                  <xsl:when test='$equipmentType'>
                    <xsl:value-of select="concat(count($c), ' causes')"/>
                    <xsl:value-of select="concat(' / ', count($cl), ' classifications')"/>
                    <xsl:if test="count($effects) > 0">
                      <xsl:value-of select="concat(' / ', count($ef), ' effects')"/>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>n/a</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name='column-4'>
                <xsl:choose>
                  <xsl:when test='count($downtimes) = 1'>1 Downtime</xsl:when>
                  <xsl:when test='count($downtimes) > 1'>
                    <xsl:value-of select='count($downtimes)'/> Downtimes
                  </xsl:when>
                  <xsl:otherwise>None</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name='column-5' >
                <xsl:choose>
                  <xsl:when test='$downtimes and $equipmentType and $matrix'>
                    <!-- downtime with equipment type with values -->
                  </xsl:when>
                  <xsl:when test='$downtimes and $equipmentType and not($matrix)'>
                    <xsl:value-of select="concat('Location is a valid Cause Location but its equipment type ', $quote, $equipmentType/@name, $quote, ' is empty.')"/>
                  </xsl:when>
                  <xsl:when test='$downtimes and not($equipmentType)'>
                    <xsl:text>Location is a valid Cause Location but has no equipment type specified.</xsl:text>
                  </xsl:when>
                  <xsl:when test='not($downtimes) and $equipmentType'>
                    <xsl:text>Location has Equipment type but is not listed as a valid Cause Location.</xsl:text>
                  </xsl:when>
                  <xsl:when test='not($downtimes) and not($equipmentType)'>
                    <xsl:text>Location is not used for downtime.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <text></text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>

          </xsl:for-each>
        </Table>
      </Worksheet>

    </Workbook>
  </xsl:template>

</xsl:stylesheet>
