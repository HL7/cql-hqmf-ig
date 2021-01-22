library Test131v5 version '0.0.001'

using QDM version '5.0.2'

valueset "Face-to-Face Interaction": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1048' 

valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025' 

valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023' 

valueset "Negative Finding": 'urn:oid:2.16.840.1.113883.3.464.1003.195.12.1002' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "Diabetes": 'urn:oid:2.16.840.1.113883.3.464.1003.103.12.1001' 

valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001' 

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Retinal or Dilated Eye Exam": 'urn:oid:2.16.840.1.113883.3.464.1003.115.12.1088' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.526.3.1240' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016' 

valueset "Ophthalmological Services": 'urn:oid:2.16.840.1.113883.3.526.3.1285' 

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Diabetes Diagnosis": ["Diagnosis": "Diabetes"] Dx
    where Dx.prevalencePeriod overlaps "Measurement Period"

define "Valid Encounter": (
    distinct (
      ["Encounter, Performed": "Office Visit"]
        union ["Encounter, Performed": "Face-to-Face Interaction"]
        union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
        union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
        union ["Encounter, Performed": "Home Healthcare Services"]
        union ["Encounter, Performed": "Annual Wellness Visit"]
        union ["Encounter, Performed": "Ophthalmological Services"]
    )
  ) E
    where E.relevantPeriod during "Measurement Period"

define "Initial Population": exists ("Diabetes Diagnosis")
    and AgeInYearsAt(start of "Measurement Period") in Interval[18, 75)
    and exists ("Valid Encounter")

define "Denominator": "Initial Population"

define "Numerator": ["Physical Exam, Performed": "Retinal or Dilated Eye Exam"] Ex
    where (
      (Ex.result as Code) in "Negative Finding"
        and Ex.relevantPeriod ends 12 months or less before start of "Measurement Period"
    )
      or Ex.relevantPeriod during "Measurement Period"

