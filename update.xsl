<xsl:stylesheet xmlns:cs="http://purl.org/net/xbiblio/csl" xmlns="http://purl.org/net/xbiblio/csl"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="cs">

  <xsl:output indent="yes" method="xml" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/cs:style">
    <style version="1.0" class="{@class}">
      <xsl:if test="@xml:lang and not(@xml:lang='en' or @xml:lang='en-US' or @xml:lang='en-us')">
        <xsl:attribute name="default-locale">
          <xsl:value-of select="@xml:lang"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </style>
  </xsl:template>

  <!-- Elements that themselves can be copied verbatim but may have child nodes -->
  <xsl:template
    match="cs:choose|cs:if|cs:else-if|cs:else|cs:info|cs:date|cs:names|cs:substitute|cs:macro|cs:group|cs:layout">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='class')]"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Elements that can be copied verbatim together with their child nodes -->
  <xsl:template match="cs:locale|cs:sort|cs:name">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- Child elements of cs:info that can be copied verbatim -->
  <xsl:template
    match="cs:author|cs:contributor|cs:id|cs:issn|cs:published|cs:rights|cs:source|cs:summary|cs:title|cs:updated">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="cs:link">
    <xsl:choose>
      <xsl:when test="@rel='documentation' or @rel='homepage'">
        <xsl:copy>
          <xsl:attribute name="href">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="rel">documentation</xsl:attribute>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="@rel='template'">
        <xsl:copy>
          <xsl:attribute name="href">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="rel">template</xsl:attribute>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="@rel='source'">
        <xsl:copy>
          <xsl:attribute name="href">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="rel">independent-parent</xsl:attribute>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:attribute name="href">
            <xsl:value-of select="@href"/>
          </xsl:attribute>
          <xsl:attribute name="rel">self</xsl:attribute>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cs:category[@term='in-text']">
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="/cs:style/cs:citation//cs:text[@variable='citation-number']">
          <xsl:value-of select="'number'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'author-date'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <category citation-format="{$value}"/>
  </xsl:template>

  <xsl:template
    match="cs:category[@term='author-date' or @term='numeric' or @term='label' or @term='note']">
    <category citation-format="{@term}"/>
  </xsl:template>

  <xsl:template match="cs:category">
    <category field="{@term}"/>
  </xsl:template>
  
  <xsl:template match="cs:citation">
    <xsl:copy>
      <xsl:for-each select="cs:option">
        <xsl:attribute name="{@name}">
          <xsl:value-of select="@value"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="cs:layout|cs:sort"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cs:bibliography">
    <xsl:copy>
      <xsl:for-each select="cs:option">
        <xsl:choose>
          <xsl:when test="@name='second-field-align' and @value='true'">
            <xsl:attribute name="second-field-align">flush</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="{@name}">
              <xsl:value-of select="@value"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:apply-templates select="cs:layout|cs:sort"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cs:date-part|cs:label">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='include-period')]"/>
      <xsl:choose>
        <xsl:when test="(@form='short' or @form='verb-short') and not(@include-period='true')">
          <xsl:attribute name="strip-periods">true</xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cs:text">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='include-period')]"/>
      <xsl:choose>
        <xsl:when
          test="(@form='short' or @form='verb-short') and not(@include-period='true') and @term">
          <xsl:attribute name="strip-periods">true</xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
