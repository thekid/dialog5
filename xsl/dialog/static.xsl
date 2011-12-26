<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Home and browse page
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
  <xsl:import href="layout.xsl"/>
  
  <!--
   ! Template for page title
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-title">
    <xsl:choose>
      <xsl:when test="/formresult/pager/@offset &gt; 0">
        <xsl:value-of select="concat('Page #', /formresult/pager/@offset)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Home</xsl:text>       
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> @ </xsl:text>
    <xsl:value-of select="/formresult/config/title"/>
  </xsl:template>

  <!--
   ! Template for page header
   !
   ! @see       ../layout.xsl
   !-->
  <xsl:template name="page-head">
    <meta property="og:type" content="album" />
    <xsl:apply-templates select="/formresult/entries/entry[1]" mode="og"/>
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
          <xsl:attribute name="href"><xsl:value-of select="func:linkPage(/formresult/pager/@offset - 1)"/></xsl:attribute>
        </xsl:if>
        <xsl:text>&#xab;</xsl:text>
      </a>
      <a title="Older entries" class="pager{(/formresult/pager/@offset + 1) * /formresult/pager/@perpage &lt; /formresult/pager/@total}" id="next">
        <xsl:if test="(/formresult/pager/@offset + 1) * /formresult/pager/@perpage &lt; /formresult/pager/@total">
          <xsl:attribute name="href"><xsl:value-of select="func:linkPage(/formresult/pager/@offset + 1)"/></xsl:attribute>
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
    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'M Y')"/>
    </div>
    <h2>
      <a href="{func:linkAlbum(@name)}">
        <xsl:value-of select="@title"/>
      </a>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>

    <h4>Highlights</h4>
    <div class="highlights">
      <xsl:for-each select="highlights/highlight">
        <div style="float: left">
          <a href="{func:linkImage(../../@name, 0, 'h', position()- 1)}">
            <img width="150" height="113" border="0" src="/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
          </a>
        </div>
      </xsl:for-each>
      <br clear="all"/>
    </div>
    <p>
      This album contains <xsl:value-of select="@num_images"/> images in <xsl:value-of select="@num_chapters"/> chapters -
      <a href="{func:linkAlbum(@name)}">See more</a>
    </p>
    <br clear="all"/><hr/>
  </xsl:template>

  <!--
   ! Template for updates
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.Update']">
    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'M Y')"/>
    </div>
    <h2>
      Updated: <xsl:value-of select="@title"/>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      - <a href="{func:linkAlbum(@album)}">Go to album</a>
      <br clear="all"/>
    </p>
    <br clear="all"/><hr/>
  </xsl:template>

  <!--
   ! Template for single shots
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.SingleShot']">
    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'M Y')"/>
    </div>
    <h2>
      Featured image: <xsl:value-of select="@title"/>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>
    <table border="0">
      <tr>
        <td class="image" rowspan="3">
          <div class="display" style="background-image: url(/shots/detail.{str:encode-uri(@filename, false())}); width: 619px; height: 347px">
            <div class="opaqueborder"/>
          </div>
        </td>
        <td valign="top">
          <a href="{func:linkShot(@name, 0)}">
            <img class="singleshot_thumb" border="0" src="/shots/thumb.color.{str:encode-uri(@filename, false())}" width="150" height="113"/>
          </a>
        </td>
      </tr>
      <tr>
        <td valign="top">
          <a href="{func:linkShot(@name, 1)}">
            <img class="singleshot_thumb" border="0" src="/shots/thumb.gray.{str:encode-uri(@filename, false())}" width="150" height="113"/>
          </a>
        </td>
      </tr>
      <tr>
        <td valign="bottom">
          <img src="/image/blank.gif" width="150" height="113"/>
        </td>
      </tr>
    </table>
    <br clear="all"/><hr/>
  </xsl:template>

  <!--
   ! Template for image strips
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.ImageStrip']">
    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(date/value), 'M Y')"/>
    </div>
    <h2>
      <a href="{func:linkImageStrip(@name)}">
        <xsl:value-of select="@title"/>
      </a>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>

    <h4>Images</h4>
    <div class="highlights">
      <xsl:for-each select="images/image">
        <div style="float: left"> 
          <a href="{func:linkImageStrip(../../@name)}#{position() - 1}">
            <img width="150" height="113" border="0" src="/albums/{../../@name}/thumb.{str:encode-uri(name, false())}"/>
          </a>
        </div>
      </xsl:for-each>
      <br clear="all"/>
    </div>
    <p>
      This image strip contains <xsl:value-of select="@num_images"/> images -
      <a href="{func:linkImageStrip(@name)}">See more</a>
    </p>
    <br clear="all"/><hr/>
  </xsl:template>

  <!--
   ! Template for collections 
   !
   ! @purpose  Specialized entry template
   !-->
  <xsl:template match="entry[@type = 'de.thekid.dialog.EntryCollection']">
    <div class="datebox">
      <h2><xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'd')"/></h2> 
      <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'M Y')"/>
    </div>
    <h2>
      <a href="{func:linkCollection(@name)}">
        Collection: <xsl:value-of select="@title"/>
      </a>
    </h2>
    <p align="justify">
      <xsl:apply-templates select="description"/>
      <br clear="all"/>
    </p>

    <h4>Albums</h4>
    <table class="collection_list" border="0">
      <xsl:for-each select="entry[@type='de.thekid.dialog.Album']">
        <tr>
          <td width="160" valign="top">
            <a href="{func:linkAlbum(@name)}">
              <img width="150" height="113" border="0" src="/albums/{@name}/thumb.{str:encode-uri(./highlights/highlight[1]/name, false())}"/>
            </a>
          </td>
          <td width="600" valign="top">
            <h3>
              <xsl:value-of select="php:function('XSLCallback::invoke', 'xp.date', 'format', string(created/value), 'd M')"/>:
              <a href="{func:linkAlbum(@name)}">
                <xsl:value-of select="@title"/>
              </a>
              (<xsl:value-of select="@num_images"/> images in <xsl:value-of select="@num_chapters"/> chapters)
            </h3>
            <p align="justify">
              <xsl:apply-templates select="description"/>
              <br clear="all"/>
            </p>
          </td>
        </tr>
      </xsl:for-each>
    </table>
    <br clear="all"/><hr/>
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
      <xsl:if test="/formresult/pager/@offset &gt; 0">
        &#xbb;
        <a href="{func:linkPage(/formresult/pager/@offset)}">
          Page #<xsl:value-of select="/formresult/pager/@offset"/>
        </a>
      </xsl:if>
    </h3>
    <br clear="all"/>
    <xsl:call-template name="pager"/>

    <xsl:for-each select="/formresult/entries/entry">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    
    <br clear="all"/>
    <xsl:call-template name="pager"/>
  </xsl:template>
  
</xsl:stylesheet>
