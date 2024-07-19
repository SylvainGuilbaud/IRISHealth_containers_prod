<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com"
				exclude-result-prefixes="xsi isc"
				version="1.0">
<xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>

<xsl:template match="@* | node()">
    <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
</xsl:template>

<!-- Sending Facility transformation is there for testing purposes-->
<!--<xsl:template match="SendingFacility">
	<xsl:variable name="SendingFacility" select="text()"/>
	<SendingFacility>-->
		<!--xsl:value-of select="isc:evaluate('piece',text(),'A',1)"/-->
<!--		<xsl:variable name="child" select="name(./*[1]) != ''"/>
		<xsl:value-of select="isc:evaluate('XIDtest',$child,text())"/>
	</SendingFacility>
</xsl:template>-->

<!--
HIPAA "Safe Harbor" method:

(2)(i) The following identifiers of the individual or of relatives, employers, or household members of the individual, are removed:

(A) Names

(B) All geographic subdivisions smaller than a state, including street address, city, county, precinct, ZIP code, and their equivalent geocodes, except for the initial three digits of the ZIP code if, according to the current publicly available data from the Bureau of the Census:
(1) The geographic unit formed by combining all ZIP codes with the same three initial digits contains more than 20,000 people; and
(2) The initial three digits of a ZIP code for all such geographic units containing 20,000 or fewer people is changed to 000

(C) All elements of dates (except year) for dates that are directly related to an individual, including birth date, admission date, discharge date, death date, and all ages over 89 and all elements of dates (including year) indicative of such age, except that such ages and elements may be aggregated into a single category of age 90 or older

(D) Telephone numbers

(L) Vehicle identifiers and serial numbers, including license plate numbers

(E) Fax numbers

(M) Device identifiers and serial numbers

(F) Email addresses

(N) Web Universal Resource Locators (URLs)

(G) Social security numbers

(O) Internet Protocol (IP) addresses

(H) Medical record numbers

(P) Biometric identifiers, including finger and voice prints

(I) Health plan beneficiary numbers

(Q) Full-face photographs and any comparable images

(J) Account numbers

(R) Any other unique identifying number, characteristic, or code, except as permitted by paragraph (c) of this section [Paragraph (c) is presented below in the section ?Re-identification?]; and

(K) Certificate/license numbers

(ii) The covered entity does not have actual knowledge that the information could be used alone or in combination with other information to identify an individual who is a subject of the information.

Satisfying either method would demonstrate that a covered entity has met the standard in chap 164.514(a) above.  De-identified health information created following these methods is no longer protected by the Privacy Rule because it does not fall within the definition of PHI.  Of course, de-identification leads to information loss which may limit the usefulness of the resulting health information in certain circumstances. As described in the forthcoming sections, covered entities may wish to select de-identification strategies that minimize such loss.
-->

<!--
(A) Names
=> HS.SDA3.Patient.Name
=> HS.SDA3.Patient.MothersMaidenName
=> HS.SDA3.Patient.MothersFullName
=> HS.SDA3.Patient.Aliases
=> HS.SDA3.Patient.SupportContacts
=> HS.SDA3.Guarantor.Name
=> HS.SDA3.Guarantor.EmployerName
=> ...HealthFund.InsuredName
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
(B) All geographic subdivisions smaller than a state, including street address, city, county, precinct, ZIP code, and their equivalent geocodes, except for the initial three digits of the ZIP code if, according to the current publicly available data from the Bureau of the Census:
(1) The geographic unit formed by combining all ZIP codes with the same three initial digits contains more than 20,000 people; and
(2) The initial three digits of a ZIP code for all such geographic units containing 20,000 or fewer people is changed to 000
-->

<xsl:template match="Patient/Addresses">
	<Addresses>
		<xsl:for-each select="Address">
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
(C) All elements of dates (except year) for dates that are directly related to an individual, including birth date, admission date, discharge date, death date, and all ages over 89 and all elements of dates (including year) indicative of such age, except that such ages and elements may be aggregated into a single category of age 90 or older
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
(D) Telephone numbers

(E) Fax numbers

(F) Email addresses
-->

<xsl:template match="Patient/ContactInfo | SupportContact/ContactInfo | Guarantor/ContactInfo | InsuredContact/ContactInfo">
</xsl:template>

<xsl:template match="CallbackNumber">
</xsl:template>

<xsl:template match="EmployerPhoneNumber">
</xsl:template>

<!--
(L) Vehicle identifiers and serial numbers, including license plate numbers
-->

<!--
(M) Device identifiers and serial numbers
-->

<xsl:template match="Procedures/Procedure/Devices/Device">
</xsl:template>

<!--
(N) Web Universal Resource Locators (URLs)
-->

<xsl:template match="DocumentURL">
</xsl:template>

<!--
(G) Social security numbers
-->

<xsl:template match="Guarantor/SSN">
</xsl:template>

<xsl:template match="SubscriberSSNOrProxy">
</xsl:template>

<!--
(O) Internet Protocol (IP) addresses
-->

<!--
(H) Medical record numbers
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
(P) Biometric identifiers, including finger and voice prints

(I) Health plan beneficiary numbers
-->

<xsl:template match="HealthFund/MembershipNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<!--
(Q) Full-face photographs and any comparable images
-->
<!-- notes: we cannot know what is in document streams, so all streams should be cleared-->
<!--        streams replaced by a non-empty value to prevent Viewer errors-->

<xsl:template match="Document/Stream">
	<Stream>W2VtcHR5XQ==</Stream>
</xsl:template>

<xsl:template match="Result/Stream">
	<Stream>W2VtcHR5XQ==</Stream>
</xsl:template>

<xsl:template match="HSBlobStream">
	<HSBlobStream>W2VtcHR5XQ==</HSBlobStream>
</xsl:template>

<!--
(J) Account numbers
-->

<xsl:template match="Encounter/AccountNumber">
</xsl:template>

<!--
(R) Any other unique identifying number, characteristic, or code, except as permitted by paragraph (c) of this section [Paragraph (c) is presented below in the section ?Re-identification?]; and
-->

<xsl:template match="ExternalId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="EncounterNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="EncounterMRN">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDencountermrn',$child,text(),$SendingFacility,$AA,$MRN,$MRNType)"/>
</xsl:template>

<xsl:template match="PreAdmissionNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PriorVisitNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="OtherIdentifiers/OtherIdentifier/Number">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PrescriptionNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<!--<xsl:template match="RefillNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>-->

<xsl:template match="FillerId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PlacerId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="LotNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="ParentFillerId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="ParentPlacerId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="FillerApptId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="FillerOrderId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PlacerApptId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PlacerOrderId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="Document/DocumentNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="Guarantor/EmployerID">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="Guarantor/GuarantorNumber/Number">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="HealthFundPlan">
</xsl:template>

<xsl:template match="PayerId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="TaxId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="FormerClaimNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="MedicalClaimNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="AuthorizationNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="FinancialClaimNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="InsuredGroupOrPolicyNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="InsuredGroup">
</xsl:template>

<xsl:template match="PolicyPlan">
</xsl:template>

<xsl:template match="CarrierSpecificMemberID">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="NationalPlanID">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="PharmacyClaimNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="ClaimNumber">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<xsl:template match="NoteId">
	<xsl:variable name="child" select="name(./*[1]) != ''"/>
	<xsl:value-of disable-output-escaping="yes" select="isc:evaluate('XIDidentifyingnumber',$child,text(),name())"/>
</xsl:template>

<!--
(K) Certificate/license numbers
-->

</xsl:stylesheet>