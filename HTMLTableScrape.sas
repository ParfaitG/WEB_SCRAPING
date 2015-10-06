* SET DIRECTORY;
%let cd = C:\Path\To\Working\Directory;

*DOWNLOAD HTML DATA;
filename fn url 'http://www.bartleby.com/titles/';

data htmldata;
	infile fn length=len;
	input record $varying8192. len;	
run;

* PARSE HTML TABLE;
data Tabledata (KEEP = record);
	set Htmldata;
	
	*LIMIT DATA SET TO RECORDS WITH RELEVANT INFO;
	KEEPDATA = 0;

	IF record = '<TABLE ALIGN="CENTER" CELLPADDING="2" CELLSPACING="2">' THEN			
        CALL SYMPUTX('STARTROW', _N_);

	IF record = '<!-- BOTTOM CHAPTER/SECTION NAV CODE -->' THEN			
        CALL SYMPUTX('ENDROW', _N_);	

	IF _N_ >= SYMGET('STARTROW') AND _N_ <= SYMGET('ENDROW') THEN
	    KEEPDATA = 1;

	IF KEEPDATA = 1;

	* CLEANUP;
	record = TRANWRD(record, '&', '&amp;');
	IF substr(record, 1, 4) = '<DIV' THEN delete;
	IF record = "" THEN delete;
	
    IF substr(record, 1, 45) = '<TR><TD><A HREF="/400/">A Library of American' THEN 
       record = TRANWRD(record, 'E.C. Stedman</A>', 'E.C. Stedman');
run;

** OUTPUT TABLE TO XML;
data _null_;
	file "&cd\temp_SASin.xml";
	set Tabledata;
	put record;
run;

** XML TRANSFORM;
** STYLE RAW OUTPUT XML FILE WITH XSLT;
filename xslfile temp;

data _null_;
  infile cards;
  input;
  file xslfile;
  put _infile_;
cards4;
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:strip-space elements="*" />
 <xsl:output method="xml" indent="yes"/>   
 <xsl:template match="TABLE">    
   <xsl:element name="BartleByData">    
      <xsl:for-each select="TR">       
       <xsl:element name="LiteratureWork">        
         <xsl:element name="Title">
          <xsl:value-of select="TD/A[1]"/>
        </xsl:element>       
        <xsl:element name="Author">
          <xsl:value-of select="TD/A[2]"/>
        </xsl:element>       
       </xsl:element>       
      </xsl:for-each>    
     </xsl:element>   
   </xsl:template>   
</xsl:stylesheet>
;;;;

proc xsl 
	in="&cd\temp_SASin.xml"
	out="&cd\temp_SASout.xml"
	xsl=xslfile;
run;

** STORING XML CONTENT;
libname temp xml "&cd\temp_SASout.xml"; 

** APPEND CONTENT TO SAS DATASET;
data Work.LiteratureWork (encoding=any);	
	retain title author;
   	set temp.LiteratureWork;	
	if author = "" AND title = "" then delete;
	title = htmldecode(title);	
	author = htmldecode(author);	
	title = TRANWRD(TRANWRD(title, "&#146;", "'"), "&#150;", "-");
	author = TRANWRD(TRANWRD(author, "&#146;", "'"), "&#150;", "-");
run;

** EXPORT DATASET TO CSV FILE;
proc export 
	data = Work.LiteratureWork
	outfile = "&cd\HTMLDATA_sas.csv"
	dbms = csv replace;
run;

** REMOVE TEMP FILES;
data _null_;
	fname="tempfile";
    rc=filename(fname,"&cd\temp_SASin.xml");
	if rc = 0 and fexist(fname) then
       rc=fdelete(fname);	
    rc=filename(fname,"&cd\temp_SASout.xml");
	if rc = 0 and fexist(fname) then
       rc=fdelete(fname);	
run;
