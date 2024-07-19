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

/// Manipulate patient name (example of customization 2)
/// 
/// Because NAMEs have sub-nodes and the main method returns the full tag, in this example, the parent method will not be called, 
/// therefore the custom method is expected to return the full tag
Method XIDnameFull(child As %Boolean, value As %String, tagname As %String) As %String
{
    set content = ""
    try {
        if (tagname="Name") {
            set content = "<Name><FamilyName>"
                _$System.Encryption.Base64Encode($System.Encryption.GenCryptRand(6))
                _"</FamilyName><GivenName>"
                _$System.Encryption.Base64Encode($System.Encryption.GenCryptRand(6))
                _"</GivenName></Name>"
        }
    } catch (err) {
        set content = "<ERR><![CDATA["_$System.Status.GetErrorText(err.AsStatus())_"]]></ERR>"
    }
    return content
}

/// Manipulate MRN
/// By default, MRN keeps track on ^HS.XID.MRN to link future that for the same MRN.
/// In this example we will remove the traking of MRNs
Method XIDmrnRemoveTrack(child As %Boolean, value As %String, Facility As %String, AssigningAuthority As %String, MRN As %String, MRNType As %String, Output tXIDFullMRN) As %String
{
    set content = ..XIDmrn(child,value,Facility,AssigningAuthority,MRN,MRNType,.tXIDFullMRN)
    
    set fullMRN = Facility_"^"_AssigningAuthority_"^"_MRN
	set anonMRN = $get(^HS.XID.MRN("In"," "_MRNType,fullMRN))

    kill ^HS.XID.MRN("Out"," "_MRNType,anonMRN)
    kill ^HS.XID.MRN("In"," "_MRNType,fullMRN)

	return content
}

}
