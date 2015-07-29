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

  <xsl:key name="none" match="None" use="@none"/>
  <xsl:key name="cause-by-id" match="Cause" use="@cause"/>
  <xsl:key name="classification-by-id" match="Classification" use="@classification" />
  <xsl:key name="effect-by-id" match="Effect" use="@effect" />

  <xsl:key name="matrix-by-cause" match="Matrix" use="@cause"/>
  <xsl:key name="matrix-by-classification" match="Matrix" use="@classification"/>
  <xsl:key name="matrix-by-effect" match="Matrix" use="@effect"/>
  <xsl:key name="locations-by-fullname" match="Location" use="@fullName"/>

  <xsl:variable name="causes" select="/Project/Causes/Cause"/>
  <xsl:variable name="classifications" select="/Project/Classifications/Classification"/>
  <xsl:variable name="effects" select="/Project/Effects/Effect"/>
  <xsl:variable name="equipmentTypes" select="/Project/EquipmentTypes/EquipmentType"/>
  <xsl:variable name="relationshipMatrixs" select="/Project/EquipmentTypes/EquipmentType/RelationshipMatrix/Matrix"/>
  <xsl:variable name="applicationFolders" select="/Project/EquipmentTypes/EquipmentType/Locations/Location[generate-id() = generate-id(key('locations-by-fullname', @fullName)[1])]"/>

  <xsl:template match="/Project">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name='Causes'>
        <Table>
          <xsl:call-template name='header-row-2-columns'>
            <xsl:with-param name='column-1'>Cause ID</xsl:with-param>
            <xsl:with-param name='column-2'>Cause</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$causes'>
            <xsl:call-template name='data-row-2-columns'>
              <xsl:with-param name='column-1' select='@cause'/>
              <xsl:with-param name='column-2' select='@name'/>
            </xsl:call-template>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Classifications'>
        <Table>
          <xsl:call-template name='header-row-2-columns'>
            <xsl:with-param name='column-1'>Classification ID</xsl:with-param>
            <xsl:with-param name='column-2'>Classification</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select='$classifications'>
            <xsl:call-template name='data-row-2-columns'>
              <xsl:with-param name='column-1' select='@classification'/>
              <xsl:with-param name='column-2' select='@name'/>
            </xsl:call-template>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name="Equipment Types">
        <Table>
          <xsl:call-template name='header-row-4-columns'>
            <xsl:with-param name='column-1'>Equipment Type</xsl:with-param>
            <xsl:with-param name='column-2'>Classification</xsl:with-param>
            <xsl:with-param name='column-3'>Cause</xsl:with-param>
            <xsl:with-param name='column-4'>Effect</xsl:with-param>
          </xsl:call-template>

          <xsl:for-each select="$equipmentTypes">
            <xsl:sort select="@fullName"/>
              <xsl:variable name="eqType" select="."/>
              <xsl:for-each select="$relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name]">
                <xsl:variable name="matrixRow" select="."/>

                <xsl:call-template name='data-row-4-columns'>
                  <xsl:with-param name='column-1' select='$eqType/@name'/>
                  <xsl:with-param name='column-2' select='$classifications[@classification = $matrixRow/@classification]/@name'/>
                  <xsl:with-param name='column-3' select='$causes[@cause = $matrixRow/@cause]/@name'/>
                  <xsl:with-param name='column-4' select='$effects[@effect = $matrixRow/@effect]/@name'/>
                </xsl:call-template>

              </xsl:for-each>
            </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name="Downtime">
        <Table>
          <xsl:call-template name='header-row-5-columns'>
            <xsl:with-param name='column-1'>Application Folder</xsl:with-param>
            <xsl:with-param name='column-2'>Equipment Type</xsl:with-param>
            <xsl:with-param name='column-3'>Classification</xsl:with-param>
            <xsl:with-param name='column-4'>Cause</xsl:with-param>
            <xsl:with-param name='column-5'>Effect</xsl:with-param>
          </xsl:call-template>

          <xsl:for-each select="$applicationFolders">
            <xsl:sort select="@fullName"/>
            <xsl:variable name="appFolder" select="."/>
            <xsl:variable name="parentTypes" select="//EquipmentType[Locations/Location/@fullName=$appFolder/@fullName]"/>
            <xsl:for-each select="$parentTypes">
              <xsl:variable name="eqType" select="."/>
              <xsl:for-each select="$relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name]">
                <xsl:variable name="matrixRow" select="."/>

                <xsl:call-template name='data-row-5-columns'>
                  <xsl:with-param name='column-1' select='$appFolder/@fullName'/>
                  <xsl:with-param name='column-2' select='$eqType/@name'/>
                  <xsl:with-param name='column-3' select='$classifications[@classification = $matrixRow/@classification]/@name'/>
                  <xsl:with-param name='column-4' select='$causes[@cause = $matrixRow/@cause]/@name'/>
                  <xsl:with-param name='column-5' select='$effects[@effect = $matrixRow/@effect]/@name'/>
                </xsl:call-template>

              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>

        </Table>
      </Worksheet>
    </Workbook>
  </xsl:template>

</xsl:stylesheet>
