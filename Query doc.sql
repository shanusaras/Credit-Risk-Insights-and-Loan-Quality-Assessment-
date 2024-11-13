-- Creating database and table structure:
CREATE DATABASE bank_loan;

CREATE TABLE loan(
id VARCHAR(50) PRIMARY KEY,
address_state VARCHAR(50),
application_type VARCHAR(50),
emp_length varchar(50),
emp_title VARCHAR(50),
grade VARCHAR(10),
home_ownership VARCHAR(50),
issue_date DATE,
last_credit_pull_date DATE,
last_payment_date DATE,
loan_status VARCHAR(50),
next_payment_date DATE,
member_id INT,
purpose VARCHAR(50),
sub_grade VARCHAR(10),
term VARCHAR(50),
verification_status VARCHAR(50),
annual_income INT,
dti DECIMAL(10, 4),
installment DECIMAL(10, 2),
int_rate DECIMAL(10, 4),
loan_amount INT,
total_acc INT,
total_payment INT);

SELECT * FROM loan;
------------------------------------------------------------------------------------
-- A. Dashboard 1: SUMMARY

-- Total loan applications:
SELECT COUNT(id) AS Total_Applications
FROM loan;

-- Month-to-Date Loan applications
SELECT COUNT(id) AS Total_MTD_Applications FROM loan
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)= 2021;

-- Previous Month-to-Date Loan applications
SELECT COUNT(id) AS Total_PMTD_Applications FROM loan
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)= 2021;
------------------------------------------------------------
-- Total funded amount
SELECT FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount FROM loan;

-- MTD Total Funded Amount
SELECT FORMAT(SUM(loan_amount), 0) AS Total_MTD_Funded_Amount FROM loan
WHERE MONTH(issue_date)= 12 AND YEAR(issue_date)= 2021;

-- PMTD Total Funded Amount
SELECT FORMAT(SUM(loan_amount), 0) AS Total_PMTD_Funded_Amount FROM loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)= 2021;

/*
SELECT 
    MONTH(CURDATE() - INTERVAL 1 MONTH) AS Previous_Month,
    YEAR(CURDATE() - INTERVAL 1 MONTH) AS Previous_Month_Year;
*/
---------------------------------------------------------------
-- Total amount received
SELECT FORMAT(SUM(total_payment), 0) AS Total_Amount_Collected FROM loan;

-- MTD Total Amount Received
SELECT FORMAT(SUM(total_payment), 0) AS Total_MTD_Amount_Collected FROM loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)= 2021;

-- PMTD Total Amount Received
SELECT FORMAT(SUM(total_payment), 0) AS Total_PMTD_Amount_Collected FROM loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)= 2021;
--------------------------------------------------------------------
-- Average Interest Rate
SELECT AVG(int_rate)*100 AS Avg_Int_Rate 
FROM loan;

-- MTD Average Interest
SELECT AVG(int_rate)*100 AS MTD_Avg_Int_Rate FROM loan
WHERE MONTH(issue_date) = 12;

-- PMTD Average Interest
SELECT AVG(int_rate)*100 AS PMTD_Avg_Int_Rate FROM loan
WHERE MONTH(issue_date) = 11;

------------------------------------------------------------
-- Avg DTI
SELECT AVG(dti)*100 AS Avg_DTI FROM loan;

-- MTD Avg DTI
SELECT AVG(dti)*100 AS MTD_Avg_DTI FROM loan
WHERE MONTH(issue_date) = 12;

-- PMTD Avg DTI
SELECT AVG(dti)*100 AS PMTD_Avg_DTI FROM loan
WHERE MONTH(issue_date) = 11;

------------------------------------------------------------
-- GOOD LOAN ISSUED
-- Good Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0) / 
	COUNT(id) AS Good_Loan_Percentage
FROM loan;

-- Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Good Loan Funded Amount
SELECT FORMAT(SUM(loan_amount), 0) AS Good_Loan_Funded_amount FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Good Loan Amount Received
SELECT FORMAT(SUM(total_payment), 0) AS Good_Loan_amount_received FROM loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

--------------------------------------------------
-- BAD LOAN ISSUED
-- Bad Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
	COUNT(id) AS Bad_Loan_Percentage
FROM loan;

-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM loan
WHERE loan_status = 'Charged Off';

-- Bad Loan Funded Amount
SELECT FORMAT(SUM(loan_amount), 0) AS Bad_Loan_Funded_amount FROM loan
WHERE loan_status = 'Charged Off';

-- Bad Loan Amount Received
SELECT FORMAT(SUM(total_payment), 0) AS Bad_Loan_amount_received FROM loan
WHERE loan_status = 'Charged Off';

-----------------------------------------------------------------------------

-- LOAN STATUS
	SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        FORMAT(SUM(total_payment), 0) AS Total_Amount_Received,
        FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
    FROM
        loan
    GROUP BY
        loan_status;
        
WITH CTE AS (
SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        FORMAT(SUM(total_payment), 0) AS Total_Amount_Received,
        FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
FROM
        loan
GROUP BY
        loan_status)
SELECT CASE WHEN loan_status= 'Current' OR loan_status= 'Fully Paid' THEN 'Good loan'
		    ELSE 'Bad loan' END AS Loan_type, 
		loan_status, LoanCount, Total_Amount_Received, Total_Funded_Amount, Interest_Rate, DTI
FROM CTE
GROUP BY loan_status;

WITH CTE AS (
SELECT 
	loan_status, 
	FORMAT(SUM(total_payment), 0) AS MTD_Total_Amount_Received, 
	FORMAT(SUM(loan_amount), 0) AS MTD_Total_Funded_Amount 
FROM loan
WHERE MONTH(issue_date) = 12 
GROUP BY loan_status)

SELECT CASE WHEN loan_status= 'Current' OR loan_status= 'Fully Paid' THEN 'Good loan'
		    ELSE 'Bad loan' END AS Loan_type, 
		loan_status, MTD_Total_Amount_Received, MTD_Total_Funded_Amount 
FROM CTE
GROUP BY loan_status;

--------------------------------------------------------------------------------
-- B.	BANK LOAN REPORT | OVERVIEW
-- MONTH
SELECT 
	MONTH(issue_date) AS Month_Number, 
	MONTHNAME(issue_date) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

-- STATE
SELECT 
	address_state AS State, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY address_state
ORDER BY address_state;

-- TERM
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY term
ORDER BY term;

-- EMPLOYEE LENGTH
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY emp_length
ORDER BY emp_length;

-- PURPOSE 
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY purpose
ORDER BY purpose;

-- HOME OWNERSHIP
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	FORMAT(SUM(loan_amount), 0) AS Total_Funded_Amount,
	FORMAT(SUM(total_payment), 0) AS Total_Amount_Received
FROM loan
GROUP BY home_ownership
ORDER BY home_ownership;

