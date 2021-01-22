library TestRiskAdj version '0.0.001'

using QDM version '5.0.2'

valueset "Bilirubin": 'urn:oid:2.16.840.1.113883.3.666.5.2400' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Serum Albumin": 'urn:oid:2.16.840.1.113762.1.4.1029.60' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Cirrhosis or other liver disease": 'urn:oid:2.16.840.1.113762.1.4.1029.63' 

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

valueset "CABG_Open and Endoscopic": 'urn:oid:2.16.840.1.113762.1.4.1029.39' 

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Encounter Inpatient 365": ["Encounter, Performed": "Encounter Inpatient"] E
    where E.lengthOfStay <= 365 days
      and E.relevantPeriod ends during "Measurement Period"

define "CABG_Open and Endoscopic During Encounter": ["Procedure, Performed": "CABG_Open and Endoscopic"] P
    with "Encounter Inpatient 365" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Hepatic Failure":
    exists ("Cirrhosis Dx")
    and exists ("Bilirubin Test")
    and exists ("Serum Albumin Test")

define "Cirrhosis Dx": ["Diagnosis": "Cirrhosis or other liver disease"] D
    with "CABG_Open and Endoscopic During Encounter" C
      such that D.prevalencePeriod starts before start of C.relevantPeriod

define "Bilirubin Test": ["Laboratory Test, Performed": "Bilirubin"] L
    with "CABG_Open and Endoscopic During Encounter" C
      such that L.relevantPeriod starts before start of C.relevantPeriod
    with "Encounter Inpatient 365" E
      such that L.relevantPeriod starts during E.relevantPeriod
    where L.result as Quantity > 2 'mg/dL'

define "Serum Albumin Test": ["Laboratory Test, Performed": "Serum Albumin"] L
    with "CABG_Open and Endoscopic During Encounter" C
      such that L.relevantPeriod starts before start of C.relevantPeriod
    with "Encounter Inpatient 365" E
      such that L.relevantPeriod starts during E.relevantPeriod
    where L.result as Quantity < 3.5 'g/dL'

define "Initial Population": "Encounter Inpatient 365"

define "Denominator": "Initial Population"

define "Numerator": "CABG_Open and Endoscopic During Encounter"

