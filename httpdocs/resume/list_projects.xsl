<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
sub getProject
{
return (
      <xsl:for-each select="RESUME/PROJECT">
	[
          "<xsl:value-of select="EMPLOYER"/>",
          <xsl:value-of select="SIGNIFICANT"/>
          "<xsl:value-of select="TEXT"/>"
	],
      </xsl:for-each>
);
}
1;
</xsl:template>
</xsl:stylesheet>
