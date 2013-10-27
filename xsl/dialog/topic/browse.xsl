<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Stylesheet for browsing a topic
 !
 ! $Id$
 !-->
<xsl:stylesheet
 version="1.0"
 xmlns:exsl="http://exslt.org/common"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:func="http://exslt.org/functions"
 xmlns:str="http://exslt.org/strings"
 xmlns:php="http://php.net/xsl"
 extension-element-prefixes="func"
 exclude-result-prefixes="exsl func php"
>
  <xsl:import href="../layout.xsl"/>
  
  <!--
   ! Template for page title
   !-->
  <xsl:template name="page-title">
    <xsl:text>Browsing topic "</xsl:text>
    <xsl:value-of select="/formresult/topic/@title"/>
    <xsl:text>" @ </xsl:text>
    <xsl:value-of select="/formresult/config/title"/>
  </xsl:template>

  <!-- Images -->
  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.Album']">
    <div class="display" style="background-image: url(/albums/{@origin-name}/{str:encode-uri(name, false())}); width: {width}px; height: {height}px">
      <div class="opaqueborder"/>
    </div>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.EntryCollection']">
    <div class="display" style="background-image: url(/albums/{@origin-name}/{str:encode-uri(name, false())}); width: {width}px; height: {height}px">
      <div class="opaqueborder"/>
    </div>
  </xsl:template>

  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.ImageStrip']">
    <div class="display" style="background-image: url(/albums/{@origin-name}/{str:encode-uri(name, false())}); width: {width}px; height: {height}px">
      <div class="opaqueborder"/>
    </div>
  </xsl:template>

  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.SingleShot']">
    <div class="display" style="background-image: url(/shots/color.{str:encode-uri(@origin-file, false())}); width: {width}px; height: {height}px">
      <div class="opaqueborder"/>
    </div>
  </xsl:template>

  <!-- Links -->
  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.Album']" mode="link">
    Album: <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <xsl:value-of select="@origin-title"/>
    </a>
  </xsl:template>

  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.EntryCollection']" mode="link">
    Collection: <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <xsl:value-of select="@origin-title"/>
    </a>
  </xsl:template>

  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.SingleShot']" mode="link">
    Featured image: <a href="{func:linkShot(@origin-name, @origin-id)}">
      <xsl:value-of select="@origin-title"/>
    </a>
  </xsl:template>

  <xsl:template match="selected[@origin-class = 'de.thekid.dialog.ImageStrip']" mode="link">
    Image strip: <a href="{func:linkImageStrip(@origin-name)}#{@origin-id}">
      <xsl:value-of select="@origin-title"/>
    </a>
  </xsl:template>

  <!--
   ! Template for content
   !-->
  <xsl:template name="content">
    <h3>
      <a href="/">Home</a>
      &#xbb;
      <a href="{func:linkByTopic()}">
        By Topic
      </a>
      &#xbb;
      <a href="{func:linkTopic(/formresult/topic/@name)}">
        <xsl:value-of select="/formresult/topic/@title"/>
      </a>
      &#xbb;
      <xsl:choose>
        <xsl:when test="/formresult/selected/iptcData/title  != ''">
          <xsl:value-of select="/formresult/selected/iptcData/title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/formresult/selected/name"/>
        </xsl:otherwise>
      </xsl:choose>
    </h3>
    <br clear="all"/>

    <center>
      <a title="Previous image" class="pager{/formresult/selected/@prev != ''}" id="previous">
        <xsl:if test="/formresult/selected/@prev != ''">
          <xsl:attribute name="href"><xsl:value-of select="concat(
            func:linkTopic(/formresult/topic/@name),
            '/',
            /formresult/selected/@prev 
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Next image" class="pager{/formresult/selected/@next != ''}" id="next">
        <xsl:if test="/formresult/selected/@next != ''">
          <xsl:attribute name="href"><xsl:value-of select="concat(
            func:linkTopic(/formresult/topic/@name),
            '/',
            /formresult/selected/@next 
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xbb;</xsl:text>
      </a>
    </center>

    <!-- Show image -->
    <div class="image">
      <a>
        <xsl:if test="/formresult/selected/@next != ''">
          <xsl:attribute name="href"><xsl:value-of select="concat(
            func:linkTopic(/formresult/topic/@name),
            '/',
            /formresult/selected/@next 
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="/formresult/selected"/>
      </a>
    </div>

    <p>
      Originally taken on <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/selected/exifData/dateTime/value), 'D, d M Y, H:i')"/>
      with <xsl:value-of select="/formresult/selected/exifData/make"/>'s
      <xsl:value-of select="/formresult/selected/exifData/model"/>.

      (<small>
      <xsl:if test="/formresult/selected/exifData/apertureFNumber != ''">
        <xsl:value-of select="/formresult/selected/exifData/apertureFNumber"/>
      </xsl:if>
      <xsl:if test="/formresult/selected/exifData/exposureTime != ''">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="/formresult/selected/exifData/exposureTime"/> sec.
      </xsl:if>  
      <xsl:if test="/formresult/selected/exifData/isoSpeedRatings != ''">
        <xsl:text>, ISO </xsl:text>
        <xsl:value-of select="/formresult/selected/exifData/isoSpeedRatings"/>
      </xsl:if>  
      <xsl:if test="/formresult/selected/exifData/focalLength != '0'">
        <xsl:text>, focal length: </xsl:text>
        <xsl:value-of select="/formresult/selected/exifData/focalLength"/>
        <xsl:text> mm</xsl:text>
      </xsl:if>
      <xsl:if test="(/formresult/selected/exifData/flash mod 8) = 1">
        <xsl:text>, flash fired</xsl:text>
      </xsl:if>
      </small>)
    </p>

    <hr/>

    <xsl:apply-templates select="/formresult/selected" mode="link"/>
  </xsl:template>
  
</xsl:stylesheet>
