-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.


SELECT npi, SUM(total_claim_count) as sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi
ORDER BY sum_total_claim_count DESC
LIMIT 1;

ANSWER: 1881634483, 99707


SELECT nppes_provider_last_org_name, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY nppes_provider_last_org_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
--ANSWER: SMITH, 355104

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT npi, nppes_provider_last_org_name, nppes_provider_first_name, specialty_description, SUM(total_claim_count) as sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_last_org_name, nppes_provider_first_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 10;
--ANSWER: BRUCE PENDLEY, FAMILY PRACTICE 99707 claims
-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT DISTINCT(specialty_description), SUM(total_claim_count) as claim_count
FROM prescriber p1
INNER JOIN prescription p2
ON p1.npi = p2.npi
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY claim_count DESC
--ANSWER: Family practice

--     b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber p1
LEFT JOIN prescription p2
USING(npi)
LEFT JOIN drug as d
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
--NURSE PRACT

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost) as total_cost
FROM drug
FULL JOIN prescription
USING(drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1
--INSULIN GLARGINE,HUM.REC.ANLOG

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, CAST(ROUND((SUM(total_drug_cost) / SUM(total_day_supply)),2)AS MONEY) as cost_per_day
FROM drug
FULL JOIN prescription
USING(drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost_per_day DESC
--ANSWER: C1 ESTERASE INHIBITOR $3,495.22
-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT 
    drug_name,
    CASE
        WHEN opioid_drug_flag = 'Y' THEN 'opioid'
        WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
        ELSE 'neither'
    END AS drug_type
FROM 
    drug;


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type,

CAST(SUM(p.total_drug_cost) AS money) AS total_spent
FROM drug AS d
LEFT JOIN prescription AS p
USING(drug_name)
GROUP BY drug_type
ORDER BY total_spent DESC;

--ANSWER: More was spent on opioids than antibiotics




-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT(COUNT(cbsa)),f.state,cbsaname
	FROM cbsa c
	LEFT JOIN fips_county f
	ON c.fipscounty=f.fipscounty
	WHERE state LIKE '%TN%'
	GROUP BY f.state, cbsaname
	ORDER BY count(cbsa);
--ANSWER: 10



--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population..

-- SELECT population.population, cbsa, cbsaname
-- FROM population
-- INNER JOIN cbsa
-- USING(fipscounty)
-- ORDER BY population.population DESC

SELECT
c.cbsaname,
SUM(p.population) AS total_population
FROM cbsa AS c
INNER JOIN population AS p
USING(fipscounty)
GROUP BY c.cbsaname
ORDER BY total_population DESC;
--ANSWER: LARGEST - Nashville-Davidson--Murfreesboro--Franklin, TN, SMALLEST: Morristown, TN




--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population...

SELECT county, population.population, cbsa, state
FROM fips_county
LEFT JOIN population
USING (fipscounty)
LEFT JOIN cbsa
USING(fipscounty)
WHERE cbsaname IS NULL AND POPULATION IS NOT NULL
ORDER BY population.population DESC
LIMIT 1;
--SEVIER, 95523


-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT total_claim_count, drug_name
FROM prescription
WHERE total_claim_count >= 3000
--ANSWER: OXYCODONE HCL 3655, LEVOTHYROXINE SODIUM 3023,LEVOTHYROXINE SODIUM 3101,GABAPENTIN 3531,LISINOPRIL 3655,HYDROCODONE-ACETAMINOPHEN 3376,LEVOTHYROXINE SODIUM 3138, MIRTAZAPINE 3085, FUROSEMIDE 3083

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name,
	CASE
		WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
		END AS drug_type, p.total_claim_count
FROM prescription p
LEFT JOIN drug as d
USING(drug_name)
WHERE total_claim_count >= 3000
--ANSWER



--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT p.drug_name,
	CASE
		WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
		END AS drug_type, p.total_claim_count, nppes_provider_last_org_name, nppes_provider_first_name
FROM prescription p
LEFT JOIN drug as d
USING(drug_name)
LEFT JOIN prescriber
USING(npi)
WHERE total_claim_count >= 3000


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.


--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT p.npi, d.drug_name, specialty_description, nppes_provider_city,
    CASE
    WHEN d.opioid_drug_flag = 'Y' THEN 'Opioid'
    ELSE 'Non Opioid'
    END AS drug_type
FROM prescription
FULL JOIN drug AS d ON prescription.drug_name = d.drug_name
FULL JOIN prescriber AS p ON prescription.npi = p.npi
WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city ILIKE '%Nashville%'
	AND opioid_drug_flag = 'Y' 
--ANSWER 35
--or
SELECT 
	prescriber.nppes_provider_last_org_name, 
	prescriber.nppes_provider_first_name,
	npi,
	drug_name
FROM prescriber
LEFT JOIN prescription
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE specialty_description iLIKE '%Pain Management%'
AND nppes_provider_city iLIKE '%Nashville%'
AND opioid_drug_flag = 'Y'
--ANSWER 44


--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi, d.drug_name, specialty_description, nppes_provider_city, total_claim_count, nppes_provider_last_org_name, nppes_provider_first_name, COALESCE(SUM(prescription.total_claim_count), 0) as total_claims
FROM prescription
FULL JOIN drug AS d ON prescription.drug_name = d.drug_name
FULL JOIN prescriber AS p ON prescription.npi = p.npi
WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city ILIKE '%Nashville%'
	AND opioid_drug_flag = 'Y'
GROUP BY p.npi, d.drug_name, specialty_description, nppes_provider_city, total_claim_count, nppes_provider_last_org_name, nppes_provider_first_name

--or maybe this could do something
SELECT 
    prescriber.npi,
    drug.drug_name as drug_name,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description,
	nppes_provider_city,
    COALESCE(SUM(prescription.total_claim_count), 0) as total_claims
FROM 
    prescriber
LEFT JOIN 
    prescription
    USING (npi)
LEFT JOIN 
    drug
    USING (drug_name)
WHERE 
    prescriber.specialty_description iLIKE '%Pain Management%'
    AND prescriber.nppes_provider_city iLIKE '%Nashville%'
GROUP BY 
    prescriber.npi,
    drug.drug_name,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description,
	nppes_provider_city
ORDER BY 
    prescriber.npi,
	nppes_provider_last_org_name,
    drug.drug_name;

    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.