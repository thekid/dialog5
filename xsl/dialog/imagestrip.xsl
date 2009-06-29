<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Stylesheet for image strips
 !
 ! $Id$
 !-->
<xsl:stylesheet
 version="1.0"
 xmlns:exsl="http://exslt.org/common"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:func="http://exslt.org/functions"
 xmlns:php="http://php.net/xsl"
 extension-element-prefixes="func"
 exclude-result-prefixes="exsl func php"
>
  <xsl:import href="layout.xsl"/>
  
  <!--
   ! Template for page title
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-title">
    <xsl:value-of select="concat(
      /formresult/imagestrip/@title, ' @ ', 
      /formresult/config/title
    )"/>
  </xsl:template>
  
  <!--
   ! Template for content
   !
   ! @see      ../layout.xsl
   ! @purpose  Define main content
   !-->
  <xsl:template name="content">
    <h3>
      <a href="{func:linkPage(0)}">Home</a> &#xbb; 
      
      <xsl:if test="/formresult/imagestrip/@page &gt; 0">
        <a href="{func:linkPage(/formresult/imagestrip/@page)}">
          Page #<xsl:value-of select="/formresult/imagestrip/@page"/>
        </a>
        &#xbb;
      </xsl:if>
     
      <a href="{func:linkImageStrip(/formresult/imagestrip/@name)}">
        <xsl:value-of select="/formresult/imagestrip/@title"/>
      </a>
    </h3>
    <br clear="all"/>

    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/imagestrip/created/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/imagestrip/created/value), 'M Y')"/>
    </div>
    <h2>
      <xsl:value-of select="/formresult/imagestrip/@title"/>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="/formresult/imagestrip/description"/>
      <br clear="all"/>
    </p>
    
    <!-- Images -->
    <br clear="all"/>
    <table border="0" width="800">
      <xsl:for-each select="/formresult/imagestrip/images/image">
        <tr>
          <td class="image" align="center">
            <a name="{position() - 1}">
              <img border="0" src="/albums/{/formresult/imagestrip/@name}/{name}"/>
            </a>
          </td>
        </tr>
        <tr>
          <td class="exif">
            <p>
              Originally taken on <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(exifData/dateTime/value), 'D, d M H:i')"/>
              with <xsl:value-of select="exifData/make"/>'s
              <xsl:value-of select="exifData/model"/>.

              (<small>
              <xsl:if test="exifData/apertureFNumber != ''">
                <xsl:value-of select="exifData/apertureFNumber"/>
              </xsl:if>
              <xsl:if test="exifData/exposureTime != ''">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="exifData/exposureTime"/> sec.
              </xsl:if>  
              <xsl:if test="exifData/isoSpeedRatings != ''">
                <xsl:text>, ISO </xsl:text>
                <xsl:value-of select="exifData/isoSpeedRatings"/>
              </xsl:if>  
              <xsl:if test="exifData/focalLength != '0'">
                <xsl:text>, focal length: </xsl:text>
                <xsl:value-of select="exifData/focalLength"/>
                <xsl:text> mm</xsl:text>
              </xsl:if>
              <xsl:if test="(exifData/flash mod 8) = 1">
                <xsl:text>, flash fired</xsl:text>
              </xsl:if>
              </small>)
            </p>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
</xsl:stylesheet>
