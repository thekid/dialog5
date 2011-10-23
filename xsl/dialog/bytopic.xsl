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

  <!--
   ! Template for pager
   !
   ! @purpose  Links to previous and next
   !-->
  <xsl:template name="pager">
    <center>
      <a title="Newer entries" class="pager{/formresult/pager/@offset &gt; 0}" id="previous">
        <xsl:if test="/formresult/pager/@offset &gt; 0">
          <xsl:attribute name="href"><xsl:value-of select="func:linkByTopic(/formresult/pager/@offset - 1)"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Older entries" class="pager{(/formresult/pager/@offset + 1) * /formresult/pager/@perpage &lt; /formresult/pager/@total}" id="next">
        <xsl:if test="(/formresult/pager/@offset + 1) * /formresult/pager/@perpage &lt; /formresult/pager/@total">
          <xsl:attribute name="href"><xsl:value-of select="func:linkByTopic(/formresult/pager/@offset + 1)"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xbb;</xsl:text>
      </a>
    </center>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.Album']">
    <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{@name}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.EntryCollection']">
    <a href="{func:linkImage(@origin-name, @origin-chapter, @origin-type, @origin-id)}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{@name}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.SingleShot']">
    <a href="{func:linkShot(@origin-name, @origin-id)}">
      <img width="150" height="113" border="0" src="/shots/thumb.color.{@name}"/>
    </a>
  </xsl:template>

  <xsl:template match="image[@origin-class = 'de.thekid.dialog.ImageStrip']">
    <a href="{func:linkImageStrip(@origin-name)}#{@origin-id}">
      <img width="150" height="113" border="0" src="/albums/{@origin-name}/thumb.{@name}"/>
    </a>
  </xsl:template>

  <!--
   ! Function that draws the highlights
   !
   ! @see      ../layout.xsl
   ! @purpose  Define main content
   !-->
  <func:function name="func:highlights">
    <xsl:param name="entries"/>
    <xsl:param name="i" select="1"/>
    <xsl:param name="max" select="5"/>
    
    <func:result>
      <tr>
        <xsl:for-each select="exsl:node-set($entries)[position() &gt;= $i and position() &lt; $i + $max]">
          <td>
            <xsl:apply-templates select="."/>
          </td>
        </xsl:for-each>
      </tr>
      <xsl:if test="$i &lt; count(exsl:node-set($entries))">
        <xsl:copy-of select="func:highlights(exsl:node-set($entries), $i + $max)"/>
      </xsl:if>
    </func:result>  
  </func:function>

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
      <xsl:if test="/formresult/pager/@offset &gt; 0">
        &#xbb;
        <a href="{func:linkByTopic(/formresult/pager/@offset)}">
          Page #<xsl:value-of select="/formresult/pager/@offset"/>
        </a>
      </xsl:if>
    </h3>
    <br clear="all"/>

    <xsl:call-template name="pager"/>
    
    <xsl:for-each select="/formresult/topics/topic">
      <h2><a href="{func:linkTopic(@name)}"><xsl:value-of select="@title"/></a></h2>
      <table class="highlights" border="0">
        <tr>
          <xsl:copy-of select="func:highlights(exsl:node-set(featured/image))"/>
        </tr>
      </table>
      <p>
        This topic contains a total of <xsl:value-of select="featured/@total"/> images -
        <a href="{func:linkTopic(@name)}">See more</a>
      </p>
      <br clear="all"/><hr/>
    </xsl:for-each>

    <xsl:call-template name="pager"/>
    <br clear="all"/>
  </xsl:template>
  
</xsl:stylesheet>
