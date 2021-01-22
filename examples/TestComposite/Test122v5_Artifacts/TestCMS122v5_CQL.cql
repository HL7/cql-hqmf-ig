library TestCMS122v5 version '0.0.001'

using QDM version '5.0.2'

valueset "Face-to-Face Interaction": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1048' 

valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025' 

valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "Diabetes": 'urn:oid:2.16.840.1.113883.3.464.1003.103.12.1001' 

valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001' 

valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016' 

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.526.3.1240' 

valueset "HbA1c Laboratory Test": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1013' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

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
    )
  ) E
    where E.relevantPeriod during "Measurement Period"

define "Initial Population": exists ("Diabetes Diagnosis")
    and AgeInYearsAt(start of "Measurement Period") in Interval[18, 75)
    and exists ("Valid Encounter")

define "Denominator": "Initial Population"

define "HbA1c Tests": ["Laboratory Test, Performed": "HbA1c Laboratory Test"] L
    where L.relevantPeriod during "Measurement Period"

define "Most Recent HbA1c Test": Last(
    "HbA1c Tests" T
      sort by start of relevantPeriod
  )

define "Numerator": "Most Recent HbA1c Test".result > 9.0
    or "Most Recent HbA1c Test".result is null
    or not exists ("HbA1c Tests")

