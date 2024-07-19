<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" 
				exclude-result-prefixes="xsi isc"
				version="1.0">
<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>

<xsl:template match="@* | node()">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
</xsl:template>

<!-- Sending Facility transformation is there for testing purposes-->
<!--<xsl:template match="SendingFacility">
<xsl:variable name="SendingFacility" select="/SendingFacility/text()"/>
<SendingFacility>-->
<!--xsl:value-of select="isc:evaluate('piece',/SendingFacility/text(),'A',1)"/-->
<!--<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of select="isc:evaluate('XIDtest',/SendingFacility/text())"/>
</SendingFacility>
</xsl:template>-->

<!--
DDG Rules:
Patient
	identifier:			Replace:		Pseudo-ID
	name:				Delete:			Or replace with pseudo-ID if necessary 
	gender:				Take over:		
	birthDate:			Generalize:		Age
	deceased:			Take over (Boolean) / Generalize  (DateTime):	Month Year
	address:			Generalize:		remove Street (+  house no.), Transform zip code into the country
	maritialStatus:		Take over:	
	multipleBirth:		Delete:	
	Health insurance:	Replace:		GKV or PKV
	contact:			Delete:	
	generalPractioner:	Replace:		Pseudo-ID

Rare diseases, such as LADA, MODY, type 3 diabetes and neonatal diabetes, which appear in the database under 100, should be replaced with "Other forms of diabetes".

-->

<!--
Patient
	identifier:			Replace:		Pseudo-ID
-->

<xsl:template match="MPIID">
<MPIID>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of select="isc:evaluate('XIDmpiid',$child,text())"/>
</MPIID>
</xsl:template>

<xsl:template match="PatientNumber">
<xsl:variable name="MRN" select="Number"/>
<xsl:variable name="AA" select="Organization/Code"/>
<xsl:variable name="MRNType" select="NumberType"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDmrn',$child,text(),$SendingFacility,$AA,$MRN,$MRNType)"/>
</xsl:template>

<!--
Patient
	name:				Delete:			Or replace with pseudo-ID if necessary 
-->

<xsl:template match="Patient/*[name() = 'Name' or name()='MothersMaidenName' or name()='MothersFullName' or name()='Aliases' or name()='SupportContacts']">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDname',$child,text(),name())"/>
</xsl:template>

<xsl:template match="Guarantors/Guarantor/*[name() = 'Name' or name()='EmployerName']">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDname',$child,text(),name())"/>
</xsl:template>

<xsl:template match="SupportContact/Name">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDname',$child,text(),name())"/>
</xsl:template>

<xsl:template match="InsuredName">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDname',$child,text(),name())"/>
</xsl:template>

<!--
Patient
	gender:				Take over:		
-->

<!--
<xsl:template match="Patient/Gender">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDgender',$child,text(),name())"/>
</xsl:template>

<xsl:template match="Patient/BirthGender">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDgender',$child,text(),name())"/>
</xsl:template>
-->

<!--
Patient	
	birthDate:			Generalize:		Age
	deceased:			Take over (Boolean) / Generalize  (DateTime):	Month Year

Note: apply switch to all dates to preserve event age
-->

<xsl:variable name="DOB" select="/Patient/BirthTime"/>
<xsl:template match="Patient/BirthTime">
<BirthTime>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of select="isc:evaluate('XIDbirthtime',$child,text())"/>
</BirthTime>
</xsl:template>

			<!-- HS.SDA3.Patient.cls-->
<xsl:template match="Patient/*[name() = 'ProtectedEffectiveDate' or name()='DeathTime' or name()='PublicityEffectiveDate' or name()='ImmunizationRegistryStatusEffectiveDate']">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="EnteredOn">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="CreatedOn">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="UpdatedOn">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="FromTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ToTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Encounter.cls-->
<xsl:template match="EndTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ExpectedAdmitTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ExpectedDischargeTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ExpectedLOAReturnTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="EmergencyAdmitDateTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.AbstractBilling.cls-->
<xsl:template match="ClaimProcessedDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="PaymentDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.AbstractClaim.cls-->
<xsl:template match="SubmissionDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ReceivedDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.AbstractExplanationOfBenefit.cls-->
<xsl:template match="ClaimReceivedDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.AbstractMedication.cls-->
<xsl:template match="SpecimenCollectedTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="SpecimenReceivedTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.AbstractOrder.cls-->
<xsl:template match="ReassessmentTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="AuthorizationTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Administration.cls-->
<xsl:template match="ExpiryDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Allergy.cls-->
<xsl:template match="DiscoveryTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ConfirmedTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="InactiveTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="VerifiedTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.CarePlan.cls-->
<xsl:template match="CreatedTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.ClinicalRelationship.cls-->
<xsl:template match="ExpirationDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="StartDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Device.cls-->
<xsl:template match="ManufactureDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Diagnosis.cls-->
<xsl:template match="IdentificationTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="OnsetTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Document.cls-->
<xsl:template match="DocumentTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="TranscriptionTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ActionTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.EOBSupportingInfo.cls-->
<xsl:template match="TimingDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="TimingPeriodStart">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="TimingPeriodEnd">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Guarantor.cls-->
<xsl:template match="Guarantor/BirthTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="Guarantor/HireEffectiveDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="Guarantor/EmploymentStopDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.LabResultItem.cls-->
<xsl:template match="AnalysisTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="ObservationTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.MedicalClaim.cls-->
<xsl:template match="AdmissionDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="DischargeDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.MedicalClaimLine.cls-->
<xsl:template match="ActualPaidDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Observation.cls-->
<xsl:template match="ObservationValueTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.PhysicalExam.cls-->
<xsl:template match="PhysExamTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Procedure.cls-->
<xsl:template match="ProcedureTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.Result.cls-->
<xsl:template match="ResultTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<xsl:template match="GUIDExpDate">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

			<!-- HS.SDA3.SupportContact.cls-->
<xsl:template match="SupportContact/BirthTime">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDdate',$child,text(),name(),$DOB)"/>
</xsl:template>

<!--
Patient
	address:			Generalize:		remove Street (+  house no.), Transform zip code into the country
-->

<xsl:template match="Patient/Addresses">
<Addresses>
<xsl:for-each select="/Patient/Addresses/Address">
<xsl:variable name="zipCode" select="Zip/Code"/>
<xsl:copy>
<xsl:copy-of select="FromTime"/>
<xsl:copy-of select="ToTime"/>
<xsl:copy-of select="State"/>
<xsl:copy-of select="Country"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDaddress',$child,text(),$zipCode)"/>
</xsl:copy>
</xsl:for-each>
</Addresses>
</xsl:template>

<xsl:template match="Guarantors/Guarantor/*[name() = 'Address' or name()='EmployerAddress']">
<xsl:variable name="zipCode" select="Zip/Code"/>
<xsl:copy>
<xsl:copy-of select="FromTime"/>
<xsl:copy-of select="ToTime"/>
<xsl:copy-of select="State"/>
<xsl:copy-of select="Country"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDaddress',$child,text(),$zipCode)"/>
</xsl:copy>
</xsl:template>

<xsl:template match="SupportContact/Address">
<xsl:variable name="zipCode" select="Zip/Code"/>
<xsl:copy>
<xsl:copy-of select="FromTime"/>
<xsl:copy-of select="ToTime"/>
<xsl:copy-of select="State"/>
<xsl:copy-of select="Country"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDaddress',$child,text(),$zipCode)"/>
</xsl:copy>
</xsl:template>

<xsl:template match="InsuredAddress">
<xsl:variable name="zipCode" select="Zip/Code"/>
<xsl:copy>
<xsl:copy-of select="FromTime"/>
<xsl:copy-of select="ToTime"/>
<xsl:copy-of select="State"/>
<xsl:copy-of select="Country"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDaddress',$child,text(),$zipCode)"/>
</xsl:copy>
</xsl:template>

<!--
Patient
	maritialStatus:		Take over:	
-->

<!--
<xsl:template match="Patient/MaritalStatus">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDmaritalstatus',$child,text())"/>
</xsl:template>
-->

<!--
Patient
	multipleBirth:		Delete:			
-->

<xsl:template match="Patient/BirthOrder">
</xsl:template>

<!--
Patient
	Health insurance:	Replace:		GKV or PKV
-->

<!--
<xsl:template match="HealthFund">
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDhealthfund',$child,text())"/>
</xsl:template>
-->

<!--
Patient
	contact:			Delete:	
-->

<xsl:template match="Patient/ContactInfo | SupportContact/ContactInfo | Guarantor/ContactInfo | InsuredContact/ContactInfo">
</xsl:template>

<xsl:template match="CallbackNumber">
</xsl:template>

<xsl:template match="EmployerPhoneNumber">
</xsl:template>

<!--
Patient
	generalPractioner:	Replace:		Pseudo-ID
-->

<xsl:template match="FamilyDoctor">
<xsl:variable name="FamilyDoctorSDACodingStandard" select="SDACodingStandard"/>
<xsl:variable name="FamilyDoctorCode" select="Code"/>
<xsl:variable name="FamilyDoctorDescription" select="Description"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDfamilydoctor',$child,text(),$FamilyDoctorSDACodingStandard,$FamilyDoctorCode,$FamilyDoctorDescription)"/>
</xsl:template>

<!--
Rare diseases, such as LADA, MODY, type 3 diabetes and neonatal diabetes, which appear in the database under 100, should be replaced with "Other forms of diabetes".

SNOMED-CT-Codierung fuer die seltenen Erkrankungen:
LADA: 426875007
MODY: 609561005
Neonatal diabetes: 49817004
Pankreopriver Diabetes mellitus: 105401000119101 
Secondary diabetes: 8801005

-->

<xsl:template match="Diagnoses/Diagnosis/Diagnosis[Code='426875007' or Code='609561005' or Code='49817004' or Code='105401000119101' or Code='8801005']">
<xsl:variable name="DiagnosisSDACodingStandard" select="SDACodingStandard"/>
<xsl:variable name="DiagnosisCode" select="Code"/>
<xsl:variable name="DiagnosisDescription" select="Description"/>
<xsl:variable name="child" select="name(./*[1]) != ''"/>
<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDrarediagnosis',$child,text(),$DiagnosisSDACodingStandard,$DiagnosisCode,$DiagnosisDescription)"/>
</xsl:template>

</xsl:stylesheet>