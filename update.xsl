<xsl:stylesheet xmlns:cs="http://purl.org/net/xbiblio/csl" xmlns="http://purl.org/net/xbiblio/csl"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="cs">

  <xsl:output indent="yes" method="xml" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="generic-base">
    <xsl:choose>
      <xsl:when test="/cs:style/cs:info/cs:category/@term='generic-base'">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template match="/cs:style">
    <style version="1.0" class="{@class}">
      <xsl:apply-templates/>
    </style>
  </xsl:template>

  <xsl:template match="cs:locale|cs:sort|cs:names|cs:text|cs:et-al">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="cs:citation">
    <citation>
      <xsl:for-each select="cs:option">
        <xsl:attribute name="{@name}">
          <xsl:value-of select="@value"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="cs:layout|cs:sort"/>
    </citation>
  </xsl:template>

  <xsl:template match="cs:bibliography">
    <bibliography>
      <xsl:for-each select="cs:option">
        <xsl:attribute name="{@name}">
          <xsl:value-of select="@value"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="cs:layout|cs:sort"/>
    </bibliography>
  </xsl:template>

  <xsl:template match="cs:layout">
    <layout>
      <xsl:choose>
        <xsl:when test="@delimiter">
          <xsl:attribute name="delimiter">
            <xsl:value-of select="@delimiter"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </layout>
  </xsl:template>

  <xsl:template match="cs:group">
    <group>
      <xsl:apply-templates/>
    </group>
  </xsl:template>

  <xsl:template match="cs:macro">
    <macro name="{@name}">
      <xsl:apply-templates/>
    </macro>
  </xsl:template>

  <xsl:template match="cs:choose">
    <choose>
      <xsl:apply-templates/>
    </choose>
  </xsl:template>

  <xsl:template match="cs:date">
    <xsl:choose>
      <xsl:when test="$generic-base='true'">
        <xsl:variable name="form">
          <xsl:choose>
            <xsl:when
              test="cs:date-part[@day] and cs:date-part[@month] and not(cs:date-part[@year])"
              >month-day</xsl:when>
            <xsl:when
              test="cs:date-part[@year] and not(cs:date-part[@day] and cs:date-part[@month])"
              >year</xsl:when>
            <xsl:otherwise>year-month-day</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="modifier">
          <xsl:choose>
            <xsl:when test="cs:date-part[@month]/@form='short'">-short</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <date form="{$form}{$modifier}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cs:info">
    <info>
      <xsl:apply-templates/>
    </info>
  </xsl:template>

  <xsl:template match="cs:author|cs:contributor|cs:id|cs:issn|cs:published|cs:rights|cs:source|cs:summary|cs:title|cs:updated">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="cs:link">
      <xsl:choose>
        <xsl:when test="@rel='documentation' or @rel='homepage'">
          <link href="{@href}" rel="documentation"/>
        </xsl:when>
        <xsl:when test="@rel='template'">
          <link href="{@href}" rel="template"/>
        </xsl:when>
        <xsl:when test="@rel='source'">
          <link href="{@href}" rel="independent-parent"/>
        </xsl:when>
        <xsl:otherwise>
          <link href="{@href}" rel="self"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template match="cs:category">
    <xsl:choose>
      <xsl:when test="@term='author-date' or @term='numeric' or @term='label' or @term='note' or @term='in-text'">
        <category citation-format="{@term}"/>
      </xsl:when>
      <xsl:otherwise>
        <category field="{@term}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cs:if|cs:else-if|cs:else">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
