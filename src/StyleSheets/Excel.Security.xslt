<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
				        xmlns="urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >

  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='Excel.Property.Tables.xslt' />

  <xsl:key name="users-by-user-id" match="Users/User" use="@id"/>
  <xsl:key name="scope-by-user-id" match="Scope[Role/Member/User]" use="Role/Member/User/@id"/>
  <xsl:key name="scopes-by-role-id" match="Scope[Role]" use="Role/@roleId"/>
  <xsl:key name="roles-by-role-id" match="RoleDefinition" use="@roleId"/>
  <xsl:key name="roles-by-user-id" match="Role" use="Member/User/@id"/>
  
  <!--
  <xsl:key name="items-by-id" match="Item[@id]" use="@id"/>
  <xsl:key name="item-link-by-position" match="HistoricalExpressionConfig/ExpressionConfig/ItemLinkCollection" use="count(ItemLink)"/>

  <xsl:variable name="source-items" select="//Item[Stream/PropertyLink]"/>
  <xsl:variable name="destination-items" select="key('items-by-id', $source-items/Stream/PropertyLink/@id)"/>
-->
  <xsl:template match="/">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
               >
      <!--			xmlns:html="http://www.w3.org/TR/REC-html40" -->
      

      <xsl:call-template name='workbook-styles' />

      <xsl:call-template name='build-security-matrix'/>
      
      <xsl:call-template name='build-role-summary'/>
      <xsl:call-template name='build-role-table'/>

      <xsl:call-template name='build-user-summary'/>

      <xsl:call-template name='build-location-summary'/>
      <xsl:call-template name='build-location-table'/>
    </Workbook>
  </xsl:template>

  <xsl:template name='build-security-matrix'>
    <xsl:variable name="roles" select="/Security/RoleDefinitions/RoleDefinition"/>
    <xsl:variable name="operations" select="/Security/Operations/Operation"/>
    <Worksheet ss:Name='Security Matrix'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Operation</xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select="$roles">
            <xsl:sort select="count(./descendant::Operation)" order="descending"/>
            <xsl:sort select="@name" order="ascending"/>
            <xsl:call-template name="header-cell">
              <xsl:with-param name="text" select="@name"/>
              <xsl:with-param name="comment" select="@description"/>
            </xsl:call-template>
          </xsl:for-each>
        </Row>
        <xsl:for-each select="$operations">
          <xsl:variable name="operation" select="@name"/>
          <Row>
            <xsl:call-template name="text-cell">
              <xsl:with-param name="text" select="@name"/>
              <xsl:with-param name="comment" select="@description"/>
            </xsl:call-template>
            <xsl:for-each select="$roles">
              <xsl:sort select="count(./descendant::Operation)" order="descending"/>
              <xsl:sort select="@name" order="ascending"/>
              <xsl:variable name="role" select="."/>
              <xsl:choose>
                <xsl:when test="$role/descendant::Operation[@name=$operation]">
                  <xsl:call-template name="text-cell">
                    <xsl:with-param name="text">Y</xsl:with-param>
                    <xsl:with-param name="style">value</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="text-cell">
                    <xsl:with-param name="text"/>
                    <xsl:with-param name="style">no-value</xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </Row>
        </xsl:for-each>
      </Table>
    </Worksheet>

  </xsl:template>

  <xsl:template name="build-role-summary">
    <xsl:variable name="roles" select="/Security/RoleDefinitions/RoleDefinition"/>
    <Worksheet ss:Name='Role Summary'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Role</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Description</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Location Count</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>User Count</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Users</xsl:with-param>
          </xsl:call-template>
        </Row>
        <xsl:for-each select='$roles'>
          <xsl:variable name='role' select='.'/>
          <xsl:variable name="scopes" select="key('scopes-by-role-id', $role/@roleId)"/>
          <Row>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='@name'/>
              <xsl:with-param name='style'>value</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='@description'/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="$scopes">
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($scopes)"/>
                </xsl:call-template>
                <xsl:variable name="user-roles" select="$scopes/Role[@roleId = $role/@roleId]/Member/User"/>
                <xsl:variable name="users" select="key('users-by-user-id', $user-roles/@id)"/>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($users)"/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>
                    <xsl:call-template name='first-n'>
                      <xsl:with-param name='items' select='$users'/>
                      <xsl:with-param name='count'>10</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
              </xsl:otherwise>
            </xsl:choose>
          </Row>
        </xsl:for-each>
      </Table>
    </Worksheet>
  </xsl:template>

  <xsl:template name='build-role-table'>
    <xsl:variable name="roles" select="/Security/RoleDefinitions/RoleDefinition"/>
    <xsl:variable name="operations" select="/Security/Operations/Operation"/>
    <Worksheet ss:Name='Role Details'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Role</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Operation</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Permitted</xsl:with-param>
          </xsl:call-template>
        </Row>
        <xsl:for-each select='$roles'>
          <xsl:variable name="role" select="."/>
          <xsl:for-each select='$operations'>
            <xsl:variable name="operation" select="@name"/>
            <Row>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="$role/@name"/>
              </xsl:call-template>
              <xsl:call-template name="text-cell">
                <xsl:with-param name="text" select="$operation"/>
              </xsl:call-template>
              <xsl:choose>
                <xsl:when test="$role/descendant::Operation[@name=$operation]">
                  <xsl:call-template name="number-cell">
                    <xsl:with-param name="value">1</xsl:with-param>
                    <xsl:with-param name="style">value</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="number-cell">
                    <xsl:with-param name="value">0</xsl:with-param>
                    <xsl:with-param name="style">default-value</xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </Row>
          </xsl:for-each>
        </xsl:for-each>
      </Table>
    </Worksheet>

  </xsl:template>

  <xsl:template name="build-user-summary">
    <xsl:variable name="users" select="/Security/Users/User"/>
    <Worksheet ss:Name='User Summary'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>User</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Authentication</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Ampla Security</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Windows Identity</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Allowed</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Denied</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Role Count</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Roles</xsl:with-param>
          </xsl:call-template>
        </Row>
        <xsl:for-each select='$users'>
          <xsl:variable name='user' select='.'/>
          <xsl:variable name='authentication' select="Property[@name='Authentication']"/>
          <Row>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='@name'/>
              <xsl:with-param name='style'>value</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select="$authentication"/>
            </xsl:call-template>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select="Property[@name='SecurityID']"/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="$authentication = 'Simple'">
                <xsl:call-template name="text-cell">
                  <xsl:with-param name="text"></xsl:with-param>
                  <xsl:with-param name="style">no-value</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select="Property[@name='Identity']/Identity/@name"/>
                  <xsl:with-param name='style'>value</xsl:with-param>
                  <xsl:with-param name='comment' select="Property[@name='Identity']/Identity"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="allowed-scopes" select="key('scope-by-user-id', $user/@id)[@valid]"/>
            <xsl:variable name="denied-scopes" select="/Security/Scopes/Scope[@valid][not(@scopeId = $allowed-scopes/@scopeId)]"/>
            <xsl:choose>
              <xsl:when test="$allowed-scopes">
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($allowed-scopes)"/>
                </xsl:call-template>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($denied-scopes)"/>
                </xsl:call-template>
                <xsl:variable name="user-roles" select="key('roles-by-user-id', $user/@id)"/>
                <xsl:variable name="role-defs" select="key('roles-by-role-id', $user-roles/@roleId)"/>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($role-defs)"/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>
                    <xsl:call-template name='first-n'>
                      <xsl:with-param name='items' select='$role-defs'/>
                      <xsl:with-param name='count'>3</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($denied-scopes)"/>
                </xsl:call-template>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
              </xsl:otherwise>
            </xsl:choose>
          </Row>
        </xsl:for-each>
      </Table>
    </Worksheet>
  </xsl:template>

  <xsl:template name="build-location-summary">
    <xsl:variable name="scopes" select="/Security/Scopes/Scope[@valid]"/>
    <Worksheet ss:Name='Location Summary'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Location</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Roles Count</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Roles</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Users Count</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Users</xsl:with-param>
          </xsl:call-template>
        </Row>
        <xsl:for-each select='$scopes'>
          <xsl:sort select='@name'/>
          <xsl:variable name='scope' select='.'/>
          <Row>
            <xsl:call-template name='text-cell'>
              <xsl:with-param name='text' select='@name'/>
              <xsl:with-param name='style'>value</xsl:with-param>
            </xsl:call-template>
            <xsl:variable name="role-defs" select="key('roles-by-role-id', $scope/Role/@roleId)"/>
            <xsl:choose>
              <xsl:when test="$role-defs">
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($role-defs)"/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>
                    <xsl:call-template name="first-n">
                      <xsl:with-param name="items" select="$role-defs"/>
                      <xsl:with-param name="count">10</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:variable name='users' select="key('users-by-user-id', $scope/Role/Member/User/@id)"/>
                <xsl:call-template name='number-cell'>
                  <xsl:with-param name='value' select="count($users)"/>
                </xsl:call-template>
                <xsl:call-template name="text-cell">
                  <xsl:with-param name="text">
                    <xsl:call-template name="first-n">
                      <xsl:with-param name="items" select="$users"/>
                      <xsl:with-param name="count">10</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
                <xsl:call-template name='no-value'/>
              </xsl:otherwise>
            </xsl:choose>

          </Row>
        </xsl:for-each>
      </Table>
    </Worksheet>
  </xsl:template>

  <xsl:template name="build-location-table">
    <xsl:variable name="scopes" select="/Security/Scopes/Scope[@valid]"/>
    <xsl:variable name="users" select="/Security/Users/User"/>
    <Worksheet ss:Name='Location Details'>
      <Table>
        <Row>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Location</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>User</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Role</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name='header-cell'>
            <xsl:with-param name='text'>Permission</xsl:with-param>
          </xsl:call-template>
        </Row>
        <xsl:for-each select='$scopes'>
          <xsl:sort select='@name'/>
          <xsl:variable name='scope' select='.'/>
          <xsl:for-each select='$users'>
            <xsl:variable name='user' select='.'/>
            <xsl:variable name='roles' select="$scope/Role[Member/User[@id = $user/@id]]"/>
            <xsl:choose>
              <xsl:when test="$roles">
                <xsl:for-each select="$roles">
                  <xsl:variable name="role" select="."/>
                  <Row>
                    <xsl:call-template name='text-cell'>
                      <xsl:with-param name='text' select='$scope/@name'/>
                      <xsl:with-param name='style'>value</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name='text-cell'>
                      <xsl:with-param name='text' select='$user/@name'/>
                      <xsl:with-param name='style'>value</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name='text-cell'>
                      <xsl:with-param name='text' select='$role/@name'/>
                      <xsl:with-param name='style'>value</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name='text-cell'>
                      <xsl:with-param name='text'>Allowed</xsl:with-param>
                      <xsl:with-param name='style'>inherited-value</xsl:with-param>
                    </xsl:call-template>
                  </Row>
                </xsl:for-each>

              </xsl:when>
              <xsl:otherwise>
                <Row>
                  <xsl:call-template name='text-cell'>
                    <xsl:with-param name='text' select='$scope/@name'/>
                    <xsl:with-param name='style'>value</xsl:with-param>
                  </xsl:call-template>
                  <xsl:call-template name='text-cell'>
                    <xsl:with-param name='text' select='$user/@name'/>
                    <xsl:with-param name='style'>value</xsl:with-param>
                  </xsl:call-template>
                  <xsl:call-template name='no-value'/>
                  <xsl:call-template name='text-cell'>
                    <xsl:with-param name='text'>Denied</xsl:with-param>
                    <xsl:with-param name='style'>default-value</xsl:with-param>
                  </xsl:call-template>
                </Row>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:for-each>
      </Table>
    </Worksheet>
  </xsl:template>

  <xsl:template name='first-n'>
    <xsl:param name='items' select='*[@name]'/>
    <xsl:param name='count'>10</xsl:param>
    <xsl:for-each select='$items'>
      <xsl:if test='position() &lt;= $count'>
        <xsl:if test='position() > 1'>, </xsl:if>
        <xsl:value-of select='@name'/>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test='count($items) > $count'> ...</xsl:if>
  </xsl:template>

</xsl:stylesheet>
