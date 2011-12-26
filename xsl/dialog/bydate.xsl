<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Stylesheet for home page
 !
 ! $Id: static.xsl 11090 2007-10-03 17:40:37Z friebe $
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
    <xsl:text>By Date: </xsl:text>       
    <xsl:value-of select="/formresult/years/@current"/>
    <xsl:text> @ </xsl:text>
    <xsl:value-of select="/formresult/config/title"/>
  </xsl:template>

  <!--
   ! Template for pager
   !
   ! @purpose  Links to previous and next
   !-->
  <xsl:template name="pager">
    <center>
      <a title="Year after" class="pager{formresult/years/@next}" id="previous">
        <xsl:if test="/formresult/years/@next">
          <xsl:attribute name="href"><xsl:value-of select="func:linkByDate(/formresult/years/@next)"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Year before" class="pager{/formresult/years/@previous}" id="next">
        <xsl:if test="/formresult/years/@previous">
          <xsl:attribute name="href"><xsl:value-of select="func:linkByDate(/formresult/years/@previous)"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xbb;</xsl:text>
      </a>
    </center>
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
  
  <xsl:template match="entry[@type = 'de.thekid.dialog.Album']" mode="highlights">
    <a href="{func:linkImage(@name, 0, 'h', 0)}">
      <img width="150" height="113" border="0" src="/albums/{@name}/thumb.{str:encode-uri(highlight, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="entry[@type = 'de.thekid.dialog.SingleShot']" mode="highlights">
    <a href="{func:linkShot(@name, 0)}">
      <img width="150" height="113" border="0" src="/shots/thumb.color.{str:encode-uri(highlight, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="entry[@type = 'de.thekid.dialog.ImageStrip']" mode="highlights">
    <a href="{func:linkImageStrip(@name)}#0">
      <img width="150" height="113" border="0" src="/albums/{@name}/thumb.{str:encode-uri(highlight, false())}"/>
    </a>
  </xsl:template>

  <xsl:template match="entry[@type = 'de.thekid.dialog.EntryCollection']" mode="highlights">
    <a href="{func:linkImage(@first, 0, 'h', 0)}">
      <img width="150" height="113" border="0" src="/albums/{@first}/thumb.{str:encode-uri(highlight, false())}"/>
    </a>
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
      <a href="{func:link(concat('bydate?', /formresult/years/@current))}">
        By Date: <xsl:value-of select="/formresult/years/@current"/>
      </a>
    </h3>
    <br clear="all"/>
    <xsl:call-template name="pager"/>

    <xsl:for-each select="/formresult/entries/month">
      <h2><xsl:value-of select="@num"/>/<xsl:value-of select="@year"/></h2>
      <div class="highlights">
        <xsl:for-each select="entry[child::highlight]">
          <div style="float: left">
            <xsl:apply-templates select="." mode="highlights"/>
          </div>
        </xsl:for-each>
        <br clear="all"/>
      </div>
      <table class="bydate_list" border="0" width="770">
        <xsl:for-each select="entry">
          <tr>
            <td id="day" valign="top">
              <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'd')"/></h2>
            </td>
            <td id="content" valign="top">
              <xsl:apply-templates select="."/>
            </td>
          </tr>
        </xsl:for-each>
      </table>

      <br clear="all"/><hr/>
    </xsl:for-each>
    
    <br clear="all"/>
    <xsl:call-template name="pager"/>
  </xsl:template>
  
</xsl:stylesheet>
