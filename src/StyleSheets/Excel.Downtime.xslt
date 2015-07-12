<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
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

  <xsl:key name="none" match="None" use="@none"/>
  <xsl:key name="cause-by-id" match="Cause" use="@cause"/>
  <xsl:key name="classification-by-id" match="Classification" use="@classification" />
  <xsl:key name="effect-by-id" match="Effect" use="@effect" />

  <xsl:key name="matrix-by-cause" match="Matrix" use="@cause"/>
  <xsl:key name="matrix-by-classification" match="Matrix" use="@classification"/>
  <xsl:key name="matrix-by-effect" match="Matrix" use="@effect"/>
  <xsl:key name="keyAppFolderName" match="//Location" use="@fullName"/>

  <xsl:variable name="causes" select="/Project/Causes/Cause"/>
  <xsl:variable name="classifications" select="/Project/Classifications/Classification"/>
  <xsl:variable name="effects" select="/Project/Effects/Effect"/>
  <xsl:variable name="equipmentTypes" select="/Project/EquipmentTypes/EquipmentType"/>
  <xsl:variable name="relationshipMatrixs" select="/Project/EquipmentTypes/EquipmentType/RelationshipMatrix/Matrix"/>
  <xsl:variable name="applicationFolders" select="/Project/EquipmentTypes/EquipmentType/Locations/Location[generate-id() = generate-id(key('keyAppFolderName', @fullName)[1])]"/>

  <xsl:template match="/Project">
    <xsl:processing-instruction name="mso-application">
      <xsl:text>progid="Excel.Sheet"</xsl:text>
    </xsl:processing-instruction>
    <xsl:call-template name="applicationFoldersTable"/>
  </xsl:template>

  <xsl:template name="applicationFoldersTable">
    <!-- EXCEL XML BEGINS -->
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:x="urn:schemas-microsoft-com:office:excel"
      xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:html="http://www.w3.org/TR/REC-html40">
      <Styles>
        <Style ss:ID="header" ss:Name="Normal">
          <Font ss:FontName="Verdana" ss:Bold="1" />
        </Style>
      </Styles>
      <Worksheet ss:Name="Downtime">
        <Table>
          <Row ss:Index="1">
            <Cell ss:Index="1" ss:StyleID="header">
              <Data ss:Type="String">Application Folder</Data>
            </Cell>
            <Cell ss:Index="2" ss:StyleID="header">
              <Data ss:Type="String">Equipment Type</Data>
            </Cell>
            <Cell ss:Index="3" ss:StyleID="header">
              <Data ss:Type="String">Classification</Data>
            </Cell>
            <Cell ss:Index="4" ss:StyleID="header">
              <Data ss:Type="String">Cause</Data>
            </Cell>
            <Cell ss:Index="5" ss:StyleID="header">
              <Data ss:Type="String">Effect</Data>
            </Cell>
          </Row>
          <!-- EXCEL XML ENDS -->
            
          <xsl:for-each select="$applicationFolders">
            <xsl:sort select="@fullName"/>
            <xsl:variable name="appFolder" select="."/>
            <xsl:variable name="parentTypes" select="//EquipmentType[Locations/Location/@fullName=$appFolder/@fullName]"/>
            <xsl:for-each select="$parentTypes">
              <xsl:variable name="eqType" select="."/>
              <xsl:for-each select="$relationshipMatrixs[@module='Downtime' and ../../@name = $eqType/@name]">
                <xsl:variable name="matrixRow" select="."/>
            
                <!-- EXCEL XML BEGINS -->
                <Row>
                  <Cell ss:Index="1">
                    <Data ss:Type="String">
                      <xsl:value-of select="$appFolder/@fullName"/>
                    </Data>
                  </Cell>
                  <Cell ss:Index="2">
                    <Data ss:Type="String">
                      <xsl:value-of select="$eqType/@name"/>
                    </Data>
                  </Cell>
                  <Cell ss:Index="3">
                    <Data ss:Type="String">
                      <xsl:value-of select="$classifications[@classification = $matrixRow/@classification]/@name"/>
                    </Data>
                  </Cell>
                  <Cell ss:Index="4">
                    <Data ss:Type="String">
                      <xsl:value-of select="$causes[@cause = $matrixRow/@cause]/@name"/>
                    </Data>
                  </Cell>
                  <Cell ss:Index="5">
                    <Data ss:Type="String">
                      <xsl:value-of select="$effects[@effect = $matrixRow/@effect]/@name"/>
                    </Data>
                  </Cell>
                </Row>
              <!-- EXCEL XML ENDS -->
              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>
    </Workbook>
  </xsl:template>
</xsl:stylesheet>
