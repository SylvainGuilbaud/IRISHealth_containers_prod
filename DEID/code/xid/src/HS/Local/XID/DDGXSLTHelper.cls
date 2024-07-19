/// XSLT helper class for de-identification transformations DDG Pseudonymisizierung.
/// This class is used on conjunction with the XSLT transformation provided.
/// For customizations overwrite extended method from XID.Production.Transformation.DDGXSLTHelper.
Class HS.Local.XID.DDGXSLTHelper Extends XID.Production.Transformation.DDGXSLTHelper
{

/// Manipulate patient name (example of customization)
Method XIDname(child As %Boolean, value As %String, tagname As %String) As %String
{
	set ret = ##super(child,value,tagname)
	set name = $piece($piece(ret,"<GivenName>",2),"</GivenName>",1)
	set ret = $replace(ret,name,"DEID:"_name)
	return ret
}

}
