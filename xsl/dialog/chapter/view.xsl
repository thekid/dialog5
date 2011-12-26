<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! View a chapter
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
      'Chapter #', /formresult/chapter/@id, ' of ',
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
    <xsl:apply-templates select="/formresult/chapter" mode="og"/>
  </xsl:template>
  
  <!--
   ! Pager: Previous and next chapter
   !
   !-->
  <xsl:template name="pager">
    <center>
      <a title="Previous chapter" class="pager{/formresult/chapter/@previous != ''}" id="previous">
        <xsl:if test="/formresult/chapter/@previous != ''">
          <xsl:attribute name="href"><xsl:value-of select="func:linkChapter(
            /formresult/album/@name, 
            /formresult/chapter/@previous
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Next chapter" class="pager{/formresult/chapter/@next != ''}" id="next">
        <xsl:if test="/formresult/chapter/@next != ''">
          <xsl:attribute name="href"><xsl:value-of select="func:linkChapter(
            /formresult/album/@name,
            /formresult/chapter/@next
          )"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xbb;</xsl:text>
      </a>
    </center>
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
      &#xbb; 
      <a href="{func:linkChapter(/formresult/album/@name, /formresult/chapter/@id - 1)}">
        Chapter #<xsl:value-of select="/formresult/chapter/@id"/>
      </a>
    </h3>
    <br clear="all"/>

    <xsl:variable name="total" select="count(/formresult/chapter/images/image)"/>
    <xsl:variable name="oldest" select="/formresult/chapter/images/image[1]"/>

    <div class="datebox">
      <h2><xsl:value-of select="/formresult/chapter/@id"/></h2> 
    </div>
    <h2>
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(exsl:node-set($oldest)/exifData/dateTime/value), 'D, d M H:00')"/>
    </h2>
    <p>
      This chapter contains
      <xsl:choose>
        <xsl:when test="$total = 1">1 image</xsl:when>
        <xsl:otherwise><xsl:value-of select="$total"/> images</xsl:otherwise>
      </xsl:choose>
    </p>
    
    <xsl:call-template name="pager"/>

    <div class="chapter">
      <xsl:choose>
        <xsl:when test="count(/formresult/chapter/images/image) &lt; 3">
          <xsl:for-each select="/formresult/chapter/images/image">
            <div style="float: left">
              <a href="{func:linkImage(/formresult/album/@name, /formresult/chapter/@id - 1, 'i', position()- 1)}">
                <img width="150" height="113" border="0" src="/albums/{/formresult/album/@name}/thumb.{str:encode-uri(name, false())}"/>
              </a>
            </div>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <div style="float: left; margin-top: 1px; margin-right: 1px">
            <a href="{func:linkImage(/formresult/album/@name, /formresult/chapter/@id - 1, 'i', '0')}">
              <div class="viewport" style="background-image: url(/albums/{/formresult/album/@name}/{str:encode-uri(/formresult/chapter/images/image[1]/name, false())});">
                <div class="opaqueborder"/>
              </div>
            </a>
          </div>
          <xsl:for-each select="/formresult/chapter/images/image[position() &gt; 1]">
            <div style="float: left">
              <a href="{func:linkImage(/formresult/album/@name, /formresult/chapter/@id - 1, 'i', position())}">
                <img width="150" height="113" border="0" src="/albums/{/formresult/album/@name}/thumb.{str:encode-uri(name, false())}"/>
              </a>
            </div>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      <br clear="all"/>
    </div>

    <xsl:call-template name="pager"/>
    
    <hr/>
  </xsl:template>
  
</xsl:stylesheet>
