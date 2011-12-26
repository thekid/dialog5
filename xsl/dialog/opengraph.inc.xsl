<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Opengraph XSL
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

  <!--
   ! Template for albums
   !-->
  <xsl:template match="album|entry[@type = 'de.thekid.dialog.Album']" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkAlbum(@name)}"/>
    <xsl:for-each select="highlights/highlight">
      <meta property="og:image" content="{/formresult/config/base}/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
    </xsl:for-each>
    <meta property="og:title" content="{@title}"/>
    <meta property="og:description" content="{description}"/>
  </xsl:template>

  <!--
   ! Template for album chapters
   !-->
  <xsl:template match="chapter" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkChapter(/formresult/album/@name, @id - 1)}"/>
    <xsl:for-each select="images/image[position() &lt; 5]">
      <meta property="og:image" content="{/formresult/config/base}/albums/{/formresult/album/@name}/thumb.{str:encode-uri(name, false())}"/>
    </xsl:for-each>
    <meta property="og:title" content="{/formresult/album/@title} - Chapter {@id}"/>
    <meta property="og:description" content=""/>
  </xsl:template>

  <!--
   ! Template for album images
   !-->
  <xsl:template match="selected[not(@mode)]" mode="og">
    <xsl:variable name="id">      <!-- FIXME: This should be attached to the formresult information -->
      <xsl:choose>
        <xsl:when test="not(/formresult/selected/prev)">0</xsl:when>
        <xsl:when test="/formresult/selected/prev/chapter != @chapter">0</xsl:when>
        <xsl:when test="/formresult/selected/prev/type != @type">0</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/formresult/selected/prev/number + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <meta property="og:url" content="{/formresult/config/base}{func:linkImage(/formresult/album/@name, @chapter, @type, $id)}"/>
    <meta property="og:image" content="{/formresult/config/base}/albums/{/formresult/album/@name}/thumb.{str:encode-uri(name, false())}"/>
      <xsl:choose>
        <xsl:when test="/formresult/selected/iptcData/title  != ''">
          <meta property="og:title" content="{/formresult/album/@title} - {/formresult/selected/iptcData/title} "/>
        </xsl:when>
        <xsl:otherwise>
          <meta property="og:title" content="{/formresult/album/@title} - {/formresult/selected/name}"/>
        </xsl:otherwise>
      </xsl:choose>
    <meta property="og:description" content=""/>
  </xsl:template>
  
  <!--
   ! Template for updates
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.Update']" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkAlbum(@album)}"/>
    <meta property="og:image" content="/image/blank.gif"/>
    <meta property="og:title" content="{@title}"/>
    <meta property="og:description" content="{description}"/>
  </xsl:template>

  <!--
   ! Template for single shots
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.SingleShot']" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkShot(@name, 1)}"/>
    <meta property="og:image" content="{/formresult/config/base}/shots/thumb.color.{str:encode-uri(@filename, false())}"/>
    <meta property="og:image" content="{/formresult/config/base}/shots/thumb.gray.{str:encode-uri(@filename, false())}"/>
    <meta property="og:title" content="{@title}"/>
    <meta property="og:description" content="{description}"/>
  </xsl:template>

  <!--
   ! Template for single shots
   !-->
  <xsl:template match="selected[@mode]" mode="og">
    <xsl:variable name="id">      <!-- FIXME: This should be in the formresult -->
      <xsl:choose>
        <xsl:when test="@mode = 'color'">0</xsl:when>
        <xsl:when test="@mode = 'gray'">1</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <meta property="og:url" content="{/formresult/config/base}{func:linkShot(name, $id)}"/>
    <meta property="og:image" content="{/formresult/config/base}/shots/thumb.color.{str:encode-uri(fileName, false())}"/>
    <meta property="og:image" content="{/formresult/config/base}/shots/thumb.gray.{str:encode-uri(fileName, false())}"/>
    <meta property="og:title" content="{title}"/>
    <meta property="og:description" content=""/>
  </xsl:template>

  <!--
   ! Template for image strips
   !-->
  <xsl:template match="imagestrip|entry[@type = 'de.thekid.dialog.ImageStrip']" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkImageStrip(@name)}"/>
    <xsl:for-each select="images/image">
      <meta property="og:image" content="{/formresult/config/base}/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
    </xsl:for-each>
    <meta property="og:title" content="{@title}"/>
    <meta property="og:description" content="{description}"/>
  </xsl:template>

  <!--
   ! OpenGraph Template for collections 
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.EntryCollection']" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkCollection(@name)}"/>
    <meta property="og:description" content="{description}"/>
    <meta property="og:title" content="{@title}"/>
    <xsl:for-each select="entry[@type='de.thekid.dialog.Album']/highlights/highlight">
      <meta property="og:image" content="{/formresult/config/base}/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
    </xsl:for-each>
  </xsl:template>

  <!--
   ! OpenGraph Template for collections
   !-->
  <xsl:template match="collection" mode="og">
    <meta property="og:url" content="{/formresult/config/base}{func:linkCollection(@name)}"/>
    <meta property="og:description" content="{description}"/>
    <meta property="og:title" content="{@title}"/>
    <xsl:for-each select="/formresult/entries/entry[@type='de.thekid.dialog.Album']/highlights/highlight">  <!-- FIXME: Layout as in static state.. -->
      <meta property="og:image" content="{/formresult/config/base}/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
