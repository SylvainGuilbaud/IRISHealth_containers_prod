# InterSystems HealthShare Health Data De-Identifier

## Overview

**InterSystems HealthShare Health Data De-Identifier** (also referred as Health Data De-ID or The Tool) is a customizable _SDA_ to _SDA_ de-identification application with out-of-the-box support for [HIPAA Safe Harbor §164.514(b)(2)](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html), date shifting and re-identification.

_SDA_ (Summary Document Architecture) is the central piece of patient data representation across InterSystems IRIS for Health and several HealthShare products. As transformations across standards can be extremely hard and time consuming due to the number of actual standards and versions out there, _SDA_ helps bridge this many-to-many relationship.
In addition to helping the interoperability aspect, having the _SDA_ as common factor makes it special when handling de-identification. Instead of having to worry how to apply de-identification rules on top of several standards, data can be received in its original format, de-identified during the transformation process and then sent to its target. For more, [Summary Document Architecture (SDA) documentation](https://docs.intersystems.com/irisforhealth20222/csp/docbook/DocBook.UI.Page.cls?KEY=HXSDA_ch_about).

_SDA_ can be represented and transported as XML, with that, The Tool leverages the performance and reliability of XSLT transformations to do the de-identification process. Helper methods allow for complex and granular manipulation of the _SDA_ XML structure. Customization or extensions to the existing HIPAA Safe Harbor support can be done by changing the XSLT template or customizing the helper methods. To know more about general XSLT transformation, [Performing XSLT Transformations documentation](https://docs.intersystems.com/irisforhealth20222/csp/docbook/Doc.View.cls?KEY=GXML_xslt).

The evaluation of **InterSystems HealthShare Health Data De-Identifier** is available for _24 hours_ from when the service started.

## The Tool

**Health Data De-ID** leverages InterSystems IRIS interoperability capabilities to allow ingestion of health data in virtually any format one needs. After the proper transformation (when applicable) from the outbound format into SDA, The Tool can be plugged into the pipeline to apply de-identification and again leverage InterSystems IRIS interoperability to send the information to any downstream systems.

Also for special cases, The Tool can leverage the same set of XSLT transformations and helper methods to process native HealthShare Health Insight Persistent Request messages.

![architecture](misc/architecture.png)

### The Environment

This evaluation has available a sample production with built-in components for HL7, _SDA_ and _PR_ processing.

![production](misc/production.png)

For better reliability when evaluating The Tool, using _SDA_ or _PR_ XML files as input is highly recommended (more details about how to input files below). In case you want to process HL7, The Tool has two HL7 services that applies standard HealthShare HL7 to _SDA_ transformation. These services are available as _file_ and _TCP_ inbound.

The Tool provides an UI to help upload _SDA_, HL7 and _PR_ files and check the differences between the input and output.

_Note: HL7 services were provided for convenience, any special transformations from HL7 to SDA or any other format to SDA have to be created by the evaluator._

### Starting

Access InterSystems Health Data DeID using the System Management Portal (SMP) through [http://hsdid.hscloud.local/csp/sys/%25CSP.Portal.Home.zen](http://hsdid.hscloud.local/csp/sys/%25CSP.Portal.Home.zen).

    The default credentials are:
    - **Username:** evaluation
    - **Password:** SYS
  
    You will be asked to enter a new set of credentials, go ahead and choose any credentials you wish.

Welcome to **Health Data De-ID**.

### Using

After you gain access to the SMP, you should notice a few things:

1) There is a dedicate menu on the left side to access the **Health Data De-ID** UI.
2) The pre-configured production is already up and running.
3) The main namespace The Tool is running is XID.

![smp](misc/smp.png)

#### Basic: De-identifying SDA (or HL7) through the UI

On the SMP, click on **Health Data De-ID** (1).

In here you have four buttons:

1) **Load SDA**: Helper to upload SDA files in XML format. _(NOTE: the file must have **xml** as extension)_
2) **Load PR**: Helper to upload Health Insight Persistent Request files. _(NOTE: the file must have **xml** as extension)_
3) **Load HL7**: Helper to upload HL7 files. _(NOTE: the file must have **hl7** as extension)_
4) **Production**: Shortcut to InterSystems IRIS Interoperability production.

![main](misc/main.png)

Click on either **Load SDA**, **Load PR** or **Load HL7**. On the first window you can either drag & drop you file or select it using the **Select file** button.
Once you have loaded the file, a _Done!_ message will appear. You can click **Close**.

Step 1 | Step 2
-|-
![load-1](misc/load-1.png)|![load-2](misc/load-2.png)

Now that the file is loaded you can see it on the main UI. _(NOTE: this list will show the last 10 messages that when through the de-identification process, regardless of the input method)_

![main-loaded](misc/main-loaded.png)

On the list you have 5 columns:

1) **TRACE**: Shows the file name (where applicable) and link to Message Trace.
   ![trace](misc/trace.png)
2) **ORIGINAL**: Shows the raw input SDA. _(NOTE: If the initial input is anything other than SDA this will still show the SDA that triggered the de-identification process)_
   ![SDA](misc/SDA.png)
3) **DE-IDENTIFIED**: Shows the raw output SDA. (similar output to above)
4) **DIFF**: In-screen diff against **ORIGINAL** and **DE-IDENTIFIED** files. (this can take a few seconds to run)
   ![diff](misc/diff.png)
5) **SDA STATS**: Runs an extract of simple stats on the differences between the **ORIGINAL** and **DE-IDENTIFIED** files and output to CSV (not available for PR).

The comparison CSV file is another way to see the differences between the **ORIGINAL** and **DE-IDENTIFIED** files.

1) Flattened SDA path;
2) **Old** value;
3) **New** value;
4) If the value is removed, **\[dropped]** will be set as **New** value;
5) If the value is unchanged, **\[same]** will be set as **New** value;
6) Any other changed values.

Totals of **changed**, **dropped** and **same** values are summarized the the bottom of the file.

![csv-main](misc/csv-main.png)

![csv-summary](misc/csv-summary.png)

#### Advanced

There are several ways to harness the power of **Health Data De-ID**, this document will outline a couple of options.

##### Customizing XSLT transformations (and helper methods)

XSLT transformation is a vast topic on its own, details of it will not be covered in this section. To know more about general XSLT transformation, [Performing XSLT Transformations documentation](https://docs.intersystems.com/irisforhealth20222/csp/docbook/Doc.View.cls?KEY=GXML_xslt).

The actual XSLT file used by The Tool will be created into **\[project-root-directory]/src/csp/xslt/SDA3/XID/DeIDTransform.xsl**, and it should be similar to the below:

```xml
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="xsi isc" version="1.0">
<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>

<xsl:template match="@* | node()">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
</xsl:template>

<!-- Sending Facility transformation is there for testing purposes-->
<xsl:template match="SendingFacility">
<xsl:variable name="SendingFacility" select="/SendingFacility/text()"/>
<SendingFacility>
<!--xsl:value-of select="isc:evaluate('piece',/SendingFacility/text(),'A',1)"/-->
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of select="isc:evaluate('XIDtest',text())"/>
</SendingFacility>
</xsl:template>
...
```

This file can be modified to accommodate any custom needs beyond [HIPAA Safe Harbor §164.514(b)(2)](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html).

Say you want to encrypt the diagnosis code. There are two steps required:

1) Modify the XSLT.
   Add to the end of **\[project-root-directory]/src/csp/xslt/SDA3/XID/DeIDTransform.xsl**. The code is in between the NoteId match and the closing stylesheet. After saving the file, right click on the file name (left pane: Explorer) and click on _Import and Compile_. 

   ```xml
   ...
   <xsl:template match="NoteId">
    <xsl:variable name="child" select="name(./*[1]) != ''"/>
    <xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
   </xsl:template>

   <!--
        This is my custom entry where I am sending the diagnosis code of the SDA to my custom method XIDcustomdiagnosis (method will be created below). 
   -->
   <xsl:template match="Diagnosis/Code">
    <xsl:variable name="child" select="name(./*[1]) != ''"/>
    <xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDcustomdiagnosis',$child,text(),name())"/>
   </xsl:template>
   <!-- end custom -->

    <!--
    (K) Certificate/license numbers
    -->

    </xsl:stylesheet>
   ```
2) Create **XIDcustomdiagnosis** method.
   Using your preferred IDE, go to **XID** namespace and open **HS.Local.XID.XSLTHelper** class.

   ```C
   /// XSLT helper class for de-identification transformations HIPAA Safe Harbor.
    /// This class is used on conjunction with the XSLT transformation provided.
    /// For customizations overwrite extended method from XID.Production.Transformation.XSLTHelper.
    Class HS.Local.XID.XSLTHelper Extends XID.Production.Transformation.XSLTHelper
    {

    ///  Example of removing gender customization
    /// 
    /// This would have to be added to the XSLT
    ///     <xsl:template match="Gender">
    ///     <xsl:variable name="child" select="name(./*[1]) != ''"/>
    ///     <xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDgender',$child,text(),name())"/>
    ///     </xsl:template>
    Method XIDgender(child As %Boolean, value As %String, tagname As %String) As %String
    {
        return ""
    }

    /// Manipulate patient name (example of customization 1)
    /// 
    /// Because NAMEs have sub-nodes and the main method returns the full tag, in this example, the parent method is executed and 
    /// further manipulation is done by replacing the content within tag (as the parent method already returned the full tag)
    Method XIDname(child As %Boolean, value As %String, tagname As %String) As %String
    {
        set ret = ##super(child,value,tagname)
        set name = $piece($piece(ret,"<GivenName>",2),"</GivenName>",1)
        set ret = $replace(ret,name,"DEID:"_name)
        return ret
    }
    ...
   ```

   Add the method below and compile:

   ```C
   /// This is my custom diagnosis method. It just creates a Code tab with the original value encrypted and prefix it with MyCustom:
   Method XIDcustomdiagnosis(child As %Boolean, value As %String, tagname As %String) As %String
   {
	  return "<Code>MyCustom:"_$System.Encryption.Base64Encode($System.Encryption.GenCryptRand(6)_"</Code>"
   }
   ```
  
   You can now load data using your preferred mechanism (or use unit-test.* file provided). You can confirm that the change is in full effect.

   ![confirmation](misc/conf.png)

Customizations can be done also by extending the existing methods in **HS.Local.XID.XSLTHelper**. A sample of how it can be done is already implemented in the class on the method **XIDname**.

## Reference

- [HIPAA Safe Harbor §164.514(b)(2)](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
- [InterSystems IRIS Community Edition Limitations](https://docs.intersystems.com/irisforhealth20222/csp/docbook/DocBook.UI.Page.cls?KEY=ACLOUD#ACLOUD_limits)
- [Performing XSLT Transformations documentation](https://docs.intersystems.com/irisforhealth20222/csp/docbook/Doc.View.cls?KEY=GXML_xslt)
- [Summary Document Architecture (SDA) documentation](https://docs.intersystems.com/irisforhealth20222/csp/docbook/DocBook.UI.Page.cls?KEY=HXSDA_ch_about)

_**Health Data De-ID** is not a final product. InterSystems reserves the right to change any aspect of it including but not limited to its UI, production design, transformations and rules._
