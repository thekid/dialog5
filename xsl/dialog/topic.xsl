<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Stylesheet for home page
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
  <xsl:import href="layout.xsl"/>
  
  <!--
   ! Template for page title
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-title">
    <xsl:text>By Topic</xsl:text>       
    <xsl:text> @ </xsl:text>
    <xsl:value-of select="/formresult/config/title"/>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.Album']">
    <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{str:encode-uri(@name, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.EntryCollection']">
    <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{str:encode-uri(@name, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.SingleShot']">
    <a href="{func:linkShot(@origin-name, @origin-id)}">
      <img width="150" height="113" border="0" src="/shots/thumb.color.{str:encode-uri(@name, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.ImageStrip']">
    <a href="{func:linkImageStrip(@origin-name)}#{@origin-id}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{str:encode-uri(@name, false())}"/>
    </a>
  </xsl:template>

  <!--
   ! Template for albums
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.Album']">
    <h3>
      <a href="{func:linkAlbum(@name)}">
        <xsl:value-of select="@title"/>
      </a>
      (<xsl:value-of select="@num_images"/> images in <xsl:value-of select="@num_chapters"/> chapters)
    </h3>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
  </xsl:template>
  
  <!--
   ! Template for updates
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.Update']">
    <h3>
      <a href="{func:linkAlbum(@album)}">
        <xsl:value-of select="@title"/>
      </a>
      (Update)
    </h3>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
  </xsl:template>

  <!--
   ! Template for updates
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.SingleShot']">
    <h3>
      <a href="{func:linkShot(@name, 0)}">
        <xsl:value-of select="@title"/>
      </a>
      (Featured image)
    </h3>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
  </xsl:template>

  <!--
   ! Template for image strips
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.ImageStrip']">
    <h3>
      <a href="{func:linkImageStrip(@name)}">
        <xsl:value-of select="@title"/>
      </a>
      (Image strip with <xsl:value-of select="@num_images"/> images)
    </h3>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
  </xsl:template>

  <!--
   ! Template for collections 
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.EntryCollection']">
    <h3>
      <a href="{func:linkCollection(@name)}">
        <xsl:value-of select="@title"/>
      </a>
      (Collection of <xsl:value-of select="@num_entries"/>)
    </h3>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
  </xsl:template>

  <!--
   ! Template for content
   !
   ! @see      ../layout.xsl
   ! @purpose  Define main content
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
    </h3>
    <br clear="all"/>

    <xsl:for-each select="/formresult/topic/year">
      <h2>
        <xsl:value-of select="@num"/> - 
        <xsl:variable name="total" select="count(image)"/>
        <xsl:choose>
          <xsl:when test="$total = 1">1 image</xsl:when>
          <xsl:otherwise><xsl:value-of select="$total"/> images</xsl:otherwise>
        </xsl:choose>
      </h2>
      <div class="highlights">
        <xsl:for-each select="image">
          <div style="float: left">
            <xsl:apply-templates select="."/>
          </div>
        </xsl:for-each>
        <br clear="all"/>
      </div>
      <table class="bydate_list" border="0" width="770">
        <xsl:for-each select="entry">
          <tr>
            <td id="day" valign="top">
              <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'M')"/></h2>
            </td>
            <td id="content" valign="top">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>
      <br clear="all"/><hr/>
    </xsl:for-each>
    
  </xsl:template>
  
</xsl:stylesheet>
