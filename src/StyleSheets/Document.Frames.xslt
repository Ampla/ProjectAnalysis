<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

  <xsl:output method="html"
   doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
   doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
   indent="yes"
  />

  <xsl:include href="Document.Common.xslt"/>
  
  <xsl:variable name="outputAllProperties">true</xsl:variable>
  <xsl:variable name="showCodeSource">false</xsl:variable>

  <xsl:template match="/">
    <html>
      <head>
        <title>Ampla Project</title>

        <link rel="stylesheet" type="text/css" href="css/smoothness/jquery-ui-1.7.2.custom.css"/>
        <link rel="stylesheet" type="text/css" href="css/screen.css" media="screen,projector"/>
        <link rel="stylesheet" type="text/css" href="css/jquery.layout.css"/>

        <script type="text/javascript" src="lib/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="lib/jquery-ui-all.js"></script>
        <script type="text/javascript" src="lib/jquery.layout.js"></script>
        <script type="text/javascript" src="lib/browser.js"></script>

      </head>
      <body>
        <div class="ui-layout-north">
          <span>Ampla Project Analysis</span>
          <span class="version smalltext">
            <xsl:text>Version: </xsl:text>
            <xsl:value-of select="/Project/Properties/ProjectProperty[@name='Applications.Version']"/>
          </span>
        </div>
        <div class="ui-layout-west">
            <iframe
                class="ui-layout-west"
                id="itemFrame"
                name="itemFrame"
                width="99%"  
                height="99%" 
                frameborder="0" 
                scrolling="auto" 
                src="{$hierarchy-page}"
                style="overflow:auto;"
             /> 
        </div>
        <div class="ui-layout-center content">
          <iframe
                class="ui-layout-center"
                id="content"
                name="{$item-target}"
                width="99%"
                height="99%"
                frameborder="0"
                scrolling="auto"
                src="{$default-page}"
                style="overflow:auto;"
             />
          <!--<div id="content">
            
            <div id="docs">
              <ul>
                <xsl:apply-templates select="/Project"/>
                <xsl:apply-templates select="/Project/Item[@id]">
                  <xsl:sort select="Property[@name='DisplayOrder']" data-type="number"/>
                  <xsl:sort select="@name"/>
                </xsl:apply-templates>
              </ul>
            </div>
          </div>-->
        </div>
        <div class="ui-layout-east">
          <iframe 
              class="ui-layout-east" 
              id="typeFrame" 
              name="typeFrame" 
              width="99%" 
              height="99%" 
              frameborder="0" 
              scrolling="auto" 
              src="{$types-page}"
              style="overflow:auto;"
           /> 
        </div>
        <!-- <div class="ui-layout-south">South</div> -->
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
