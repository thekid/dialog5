<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! View an album
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
    <xsl:value-of select="concat(
      /formresult/album/@title, ' @ ', 
      /formresult/config/title
    )"/>
  </xsl:template>

  <!--
   ! Template for page header
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-head">
    <meta property="og:type" content="album" />
    <xsl:apply-templates select="/formresult/album" mode="og"/>
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
      
      <xsl:if test="/formresult/album/@page &gt; 0">
        <a href="{func:linkPage(/formresult/album/@page)}">
          Page #<xsl:value-of select="/formresult/album/@page"/>
        </a>
        &#xbb;
      </xsl:if>
     
      <xsl:if test="/formresult/album/collection">
        <a href="{func:linkCollection(/formresult/album/collection/@name)}">
          <xsl:value-of select="/formresult/album/collection/@title"/> Collection
        </a>
         &#xbb;
      </xsl:if>
      
      <a href="{func:linkAlbum(/formresult/album/@name)}">
        <xsl:value-of select="/formresult/album/@title"/>
      </a>
    </h3>
    <br clear="all"/>

    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/album/created/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(/formresult/album/created/value), 'M Y')"/>
    </div>
    <h2>
      <xsl:value-of select="/formresult/album/@title"/>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="/formresult/album/description"/>
      <br clear="all"/>
    </p>
    
    <h4>Highlights</h4>
    <div class="highlights">
      <xsl:for-each select="/formresult/album/highlights/highlight">
        <div style="float: left"> 
          <a href="{func:linkImage(../../@name, 0, 'h', position()- 1)}">
            <img width="150" height="113" border="0" src="/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
          </a>
        </div>
      </xsl:for-each>
      <br clear="all"/>
    </div>
    <p>
      This album contains <xsl:value-of select="/formresult/album/@num_images"/> images in <xsl:value-of select="/formresult/album/@num_chapters"/> chapters.
    </p>
    <br clear="all"/><hr/>

    <xsl:for-each select="/formresult/album/chapters/chapter">
      <xsl:variable name="total" select="count(images/image)"/>
      <xsl:variable name="oldest" select="images/image[1]"/>
      <xsl:variable name="newest" select="images/image[$total]"/>
      <xsl:variable name="chapter" select="position() - 1"/>

      <div class="datebox">
        <h2><xsl:value-of select="position()"/></h2> 
      </div>
      <h2>
        <a href="{func:linkChapter(../../@name, $chapter)}">
          <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(exsl:node-set($oldest)/exifData/dateTime/value), 'D, d M H:00')"/>
        </a>
      </h2>
      <p>
        This chapter contains
        <xsl:choose>
          <xsl:when test="$total = 1">1 image</xsl:when>
          <xsl:otherwise><xsl:value-of select="$total"/> images</xsl:otherwise>
        </xsl:choose>
      </p>

      <div class="chapter">
        <xsl:for-each select="images/image">
          <div style="float: left"> 
            <a href="{func:linkImage(../../../../@name, $chapter, 'i', position()- 1)}">
              <img width="150" height="113" border="0" src="/albums/{../../../../@name}/thumb.{str:encode-uri(name, false())}"/>
            </a>
          </div>
        </xsl:for-each>
        <br clear="all"/>
      </div>
      <hr/>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
