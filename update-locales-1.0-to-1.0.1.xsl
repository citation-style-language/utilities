<xsl:stylesheet xmlns:cs="http://purl.org/net/xbiblio/csl" xmlns="http://purl.org/net/xbiblio/csl"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="cs">

  <xsl:output indent="yes" method="xml" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/cs:locale">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="document('locales-nl-NL.xml')/cs:locale/@xml:lang"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="cs:info">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="cs:date[@form='numeric']">
    <xsl:copy-of select="document('locales-nl-NL.xml')/cs:locale/cs:date[@form='numeric']"/>
  </xsl:template>
  
  <xsl:template match="cs:date[@form='text']">
    <xsl:copy-of select="document('locales-nl-NL.xml')/cs:locale/cs:date[@form='text']"/>
  </xsl:template>

  <xsl:template match="cs:style-options">
    <xsl:copy-of select="document('locales-nl-NL.xml')/cs:locale/cs:style-options"/>
  </xsl:template>
  
  <xsl:template match="cs:terms">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cs:term">
    <xsl:variable name="name" select="@name" />
    <xsl:variable name="form" select="@form" />
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="cs:single and cs:multiple">
          <xsl:choose>
            <xsl:when test="@form">
              <xsl:choose>
                <xsl:when test="document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]/cs:single and document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]/cs:multiple">
                  <xsl:element name="single">
                    <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]/cs:single"/>
                  </xsl:element>
                  <xsl:element name="multiple">
                    <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]/cs:multiple"/>
                  </xsl:element>
                </xsl:when>
                <xsl:when test="//cs:term[@name=$name and @form=$form]/cs:single and //cs:term[@name=$name and @form=$form]/cs:multiple">
                  <xsl:element name="single">
                    <xsl:value-of select="//cs:term[@name=$name and @form=$form]/cs:single"/>
                  </xsl:element>
                  <xsl:element name="multiple">
                    <xsl:value-of select="//cs:term[@name=$name and @form=$form]/cs:multiple"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]/cs:single and document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]/cs:multiple">
                  <xsl:element name="single">
                    <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]/cs:single"/>
                  </xsl:element>
                  <xsl:element name="multiple">
                    <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]/cs:multiple"/>
                  </xsl:element>
                </xsl:when>
                <xsl:when test="//cs:term[@name=$name and not(@form)]/cs:single and //cs:term[@name=$name and not(@form)]/cs:multiple">
                  <xsl:element name="single">
                    <xsl:value-of select="//cs:term[@name=$name and not(@form)]/cs:single"/>
                  </xsl:element>
                  <xsl:element name="multiple">
                    <xsl:value-of select="//cs:term[@name=$name and not(@form)]/cs:multiple"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@form">
              <xsl:choose>
                <xsl:when test="document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]">
                  <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and @form=$form]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="//cs:term[@name=$name and @form=$form]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]">
                  <xsl:value-of select="document('locales-nl-NL.xml')//cs:term[@name=$name and not(@form)]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="//cs:term[@name=$name and not(@form)]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
