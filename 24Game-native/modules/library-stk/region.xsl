<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    region.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"    
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">

    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>

    <xsl:variable name="stk:region.active-regions" as="element()*">
        <xsl:copy-of select="/result/context/page/regions/region[count(windows/window) gt 0]"/>
    </xsl:variable>

    <!-- Regions template -->
    <!-- Renders region(s), either specified by region-name or all available regions -->
    <xsl:template name="stk:region.create">
        <xsl:param name="region-name" as="xs:string?"/>
        <xsl:param name="layout" as="xs:string" select="'default'"/>
        <xsl:param name="content-prepend" as="document-node()*"/>
        <xsl:param name="content-append" as="document-node()*"/>
        
        <xsl:for-each select="$stk:theme-device-class/layout[tokenize(@name, ',') = $layout]//region[if ($region-name) then @name = $region-name else *]">
            <!-- Creates region if it contains portlets -->
            <xsl:if
                test="count($stk:rendered-page/regions/region[name = concat($stk:theme-region-prefix, current()/@name)]/windows/window) gt 0">
                
                <xsl:variable name="active-siblings" as="element()*" select="../region[index-of($stk:region.active-regions/name, concat($stk:theme-region-prefix, @name)) castable as xs:integer]"/>
                
                <xsl:variable name="width" as="xs:integer">
                    <xsl:choose>
                        <xsl:when test="scalable = 'true'">
                            
                            <xsl:variable name="width-of-siblings" as="xs:integer">
                                <xsl:value-of select="sum($active-siblings[not(scalable = 'true')]/width) + sum($active-siblings[not(scalable = 'true')]/margin/node()[name() = 'left' or name() = 'right']) + sum($active-siblings[not(scalable = 'true')]/padding/node()[name() = 'left' or name() = 'right'])"/>
                           </xsl:variable>
                            <xsl:variable name="padding-width" as="xs:integer">
                                <xsl:value-of select="if (padding/node()) then sum(padding/node()[name() = 'left' or name() = 'right']) else 0"/>
                            </xsl:variable>
                            <xsl:value-of select="xs:integer(../@width) - $width-of-siblings - $padding-width"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="width"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:element name="{if (current()/@element) then current()/@element else 'div'}">
                    <xsl:attribute name="id" select="concat($stk:theme-region-prefix, current()/@name)"/>
                    <xsl:attribute name="class">
                        <xsl:text>region</xsl:text>
                        <xsl:if test="normalize-space(current()/@class)">
                            <xsl:value-of select="concat(' ', current()/@class)"/>
                        </xsl:if>
                    </xsl:attribute>
                    
                    <xsl:if test="normalize-space(current()/@role)">
                        <xsl:attribute name="role" select="current()/@role"/>
                    </xsl:if>
                    
                    <xsl:if test="$content-prepend/node()">
                        <xsl:copy-of select="$content-prepend"/>
                    </xsl:if>
                    
                        
                        <!-- Create portlet placeholder for region -->
                        <xsl:for-each select="$stk:rendered-page/regions/region[name = concat($stk:theme-region-prefix, current()/@name)]/windows/window">
                            <xsl:variable name="parameters" as="xs:anyAtomicType*">
                                <xsl:sequence select="'_config-region-width', $width"/>
                            </xsl:variable>
                            <xsl:value-of select="portal:createWindowPlaceholder(@key, $parameters)"/>
                        </xsl:for-each>
                    
                    <xsl:if test="$content-append/node()">
                        <xsl:copy-of select="$content-append"/>
                    </xsl:if>
                </xsl:element>
                
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="stk:region.create-css">
        <xsl:param name="layout" as="xs:string" select="'default'"/>
        <style type="text/css">
            <xsl:apply-templates select="$stk:theme-device-class/layout[tokenize(@name, ',') = $layout]//region[index-of($stk:region.active-regions/name, concat($stk:theme-region-prefix, @name)) castable as xs:integer]" mode="css"/>    
        </style>
    </xsl:template>

    <!-- region size css (width, margin, padding) for active regions -->
    <!-- insert region size css for active regions -->
    <xsl:template match="region" mode="css">
        <xsl:variable name="width" as="xs:integer">
            <xsl:choose>
                <xsl:when test="scalable = 'true'">
                    <xsl:variable name="active-siblings" as="element()*"
                        select="../region[not(scalable = 'true')][index-of($stk:region.active-regions/name, concat($stk:theme-region-prefix, @name)) castable as xs:integer]"/>
                    <xsl:variable name="active-siblings-margin-width" select="sum($active-siblings[margin/left]/margin/left) + sum($active-siblings[margin/right]/margin/right)"/>
                    <xsl:variable name="active-siblings-padding-width" select="sum($active-siblings[padding/left]/padding/left) + sum($active-siblings[padding/right]/padding/right)"/>
                    
                    <xsl:variable name="width-of-siblings" as="xs:integer"> 
                        <xsl:value-of select="sum($active-siblings/width) + $active-siblings-margin-width + $active-siblings-padding-width"/>                       
                    </xsl:variable>
                    <xsl:variable name="padding-width" as="xs:integer">                        
                        <xsl:value-of select="sum(padding/left) + sum(padding/right)"/>
                    </xsl:variable>
                    <xsl:variable name="margin-width" as="xs:integer">
                        <xsl:value-of select="sum(margin/left) + sum(margin/right)"/>
                    </xsl:variable>
                    <xsl:value-of select="xs:integer(../@width) - $width-of-siblings - $padding-width - $margin-width"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="width"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="margin" as="xs:string"
            select="if (margin/node()) then concat(if (margin/top) then margin/top else 0, 'px ', if (margin/right) then margin/right else 0, 'px ', if (margin/bottom) then margin/bottom else 0, 'px ', if (margin/left) then margin/left else 0, 'px') else '0'"/>
        <xsl:variable name="padding" as="xs:string"
            select="if (padding/node()) then concat(if (padding/top) then padding/top else 0, 'px ', if (padding/right) then padding/right else 0, 'px ', if (padding/bottom) then padding/bottom else 0, 'px ', if (padding/left) then padding/left else 0, 'px') else '0'"/>

        <xsl:value-of select="concat('#', @name, '{')"/>
        <xsl:value-of select="concat('width: ', $width, 'px;')"/>
        <xsl:value-of select="concat('margin: ', $margin, ';')"/>
        <xsl:value-of select="concat('padding: ', $padding, ';')"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

</xsl:stylesheet>
