<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! View a single shot
 !-->
<xsl:stylesheet
 version="1.0"
 xmlns:exsl="http://exslt.org/common"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:func="http://exslt.org/functions"
 xmlns:str="http://exslt.org/strings"
 xmlns:php="http://php.net/xsl"
 extension-element-prefixes="func str"
 exclude-result-prefixes="exsl func php str"
>
  <xsl:import href="../layout.xsl"/>
  
  <!--
   ! Template for page title
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-title">
    <xsl:value-of select="concat(/formresult/selected/title, ' ', /formresult/selected/@mode, ' @ ', /formresult/config/title)"/>
  </xsl:template>

  <!--
   ! Template for page header
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-head">
    <meta property="og:type" content="album" />
    <xsl:apply-templates select="/formresult/selected" mode="og"/>
  </xsl:template>
  
  <!--
   ! Template for content
   !
   ! @see      ../../layout.xsl
   ! @purpose  Define main content
   !-->
  <xsl:template name="content">
    <h3>
      <a href="{func:linkPage(0)}">Home</a> &#xbb; 

      <xsl:if test="/formresult/selected/@page &gt; 0">
        <a href="{func:linkPage(/formresult/selected/@page)}">
          Page #<xsl:value-of select="/formresult/selected/@page"/>
        </a>
        &#xbb;
      </xsl:if>

      Featured image: <xsl:value-of select="/formresult/selected/title"/>
    </h3>

    <br clear="all"/> 
    <center>
      <a title="Color version" class="pager{/formresult/selected/@mode = 'gray'}" id="previous">
        <xsl:if test="/formresult/selected/@mode = 'gray'">
          <xsl:attribute name="href"><xsl:value-of select="func:linkShot(
            /formresult/selected/name, 
            0
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Black and white version" class="pager{/formresult/selected/@mode = 'color'}" id="next">
        <xsl:if test="/formresult/selected/@mode = 'color'">
          <xsl:attribute name="href"><xsl:value-of select="func:linkShot(
            /formresult/selected/name, 
            1
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xbb;</xsl:text>
      </a>
    </center>
    
    <!-- Selected image -->
    <div class="image">
      <div class="display" style="background-image: url(/shots/{/formresult/selected/@mode}.{str:encode-uri(/formresult/selected/fileName, false())}); width: {/formresult/selected/image/width}px; height: {/formresult/selected/image/height}px">
        <div class="opaqueborder"/>
      </div>
    </div>
    
    <p>
      Originally taken on <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/selected/image/exifData/dateTime/value), 'D, d M Y, H:i')"/>
      with <xsl:value-of select="/formresult/selected/image/exifData/make"/>'s
      <xsl:value-of select="/formresult/selected/image/exifData/model"/>.

      (<small>
      <xsl:if test="/formresult/selected/image/exifData/apertureFNumber != ''">
        <xsl:value-of select="/formresult/selected/image/exifData/apertureFNumber"/>
      </xsl:if>
      <xsl:if test="/formresult/selected/image/exifData/exposureTime != ''">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="/formresult/selected/image/exifData/exposureTime"/> sec.
      </xsl:if>  
      <xsl:if test="/formresult/selected/image/exifData/isoSpeedRatings != ''">
        <xsl:text>, ISO </xsl:text>
        <xsl:value-of select="/formresult/selected/image/exifData/isoSpeedRatings"/>
      </xsl:if>  
      <xsl:if test="/formresult/selected/image/exifData/focalLength != '0'">
        <xsl:text>, focal length: </xsl:text>
        <xsl:value-of select="/formresult/selected/image/exifData/focalLength"/>
        <xsl:text> mm</xsl:text>
      </xsl:if>
      <xsl:if test="(/formresult/selected/image/exifData/flash mod 8) = 1">
        <xsl:text>, flash fired</xsl:text>
      </xsl:if>
      </small>)
    </p>
    <hr/>
    <xsl:if test="count(/formresult/selected/topics/topic) &gt; 0">
      <p>
        <xsl:text>Topics: </xsl:text>
        <xsl:for-each select="/formresult/selected/topics/topic">
          <a href="{func:linkTopic(@name)}"><xsl:value-of select="."/></a>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </p>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
