<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 ! Links
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

  <func:function name="func:linkPage">
    <xsl:param name="no"/>
    
    <func:result>
      <xsl:choose>
        <xsl:when test="$no = 0">/</xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('/page/', $no)"/></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="func:linkAlbum">
    <xsl:param name="name"/>
    
    <func:result>
      <xsl:value-of select="concat('/album/', $name)"/>
    </func:result>
  </func:function>
  
  <func:function name="func:linkCollection">
    <xsl:param name="name"/>
    
    <func:result>
      <xsl:value-of select="concat('/collection/', $name)"/>
    </func:result>
  </func:function>

  <func:function name="func:linkImageStrip">
    <xsl:param name="name"/>
    
    <func:result>
      <xsl:value-of select="concat('/imagestrip/', $name)"/>
    </func:result>
  </func:function>
  
  <func:function name="func:linkChapter">
    <xsl:param name="album"/>
    <xsl:param name="no"/>
    
    <func:result>
      <xsl:value-of select="concat('/album/', $album, '/', $no)"/>
    </func:result>
  </func:function>
  
  <func:function name="func:linkImage">
    <xsl:param name="album"/>
    <xsl:param name="chapter"/>
    <xsl:param name="type"/>
    <xsl:param name="id"/>
    
    <func:result>
      <xsl:value-of select="concat('/album/', $album, '/', $chapter, '/', $type, ',', $id)"/>
    </func:result>
  </func:function>

  <func:function name="func:linkShot">
    <xsl:param name="shot"/>
    <xsl:param name="no"/>
    
    <func:result>
      <xsl:value-of select="concat('/shot/', $shot, '/', $no)"/>
    </func:result>
  </func:function>

  <func:function name="func:linkTopic">
    <xsl:param name="name"/>
    
    <func:result>
      <xsl:value-of select="concat('/topic/', $name)"/>
    </func:result>
  </func:function>

  <func:function name="func:linkByTopic">
    <xsl:param name="page" select="false()"/>
    
    <func:result>
      <xsl:choose>
        <xsl:when test="$page = false()">/by/topic</xsl:when>
        <xsl:otherwise>/by/topic/page/<xsl:value-of select="$page"/></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="func:linkByDate">
    <xsl:param name="year" select="false()"/>
    
    <func:result>
      <xsl:choose>
        <xsl:when test="$year = false()">/by/date</xsl:when>
        <xsl:otherwise>/by/date/<xsl:value-of select="$year"/></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
</xsl:stylesheet>
