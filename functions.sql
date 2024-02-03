

CREATE OR REPLACE FUNCTION borrow_book(m_id INT, b_id INT)
RETURNS VOID AS $$
DECLARE
    violations_count INT;
	loan_num INT;
	member_num INT;
BEGIN
    -- Check the number of violations for the member
    SELECT Violations INTO violations_count
    FROM Memberships
    WHERE Member_ID = m_id;

    -- Check if the number of violations is greater than 5
    IF violations_count >= 5 THEN
        -- Raise an exception if violations are too high
        RAISE EXCEPTION 'Member cannot borrow a book due to excessive violations.';
    ELSE
        -- Allow the member to borrow the book
        INSERT INTO Loans (member_id,book_id,Loan_Date, Due_Date)
        VALUES ( m_id,b_id,CURRENT_DATE, CURRENT_DATE + 14); 
		--RAISE NOTICE 'Book successfully borrowed by member %.', member_id;
    END IF;
END;
$$ LANGUAGE plpgsql;
--*********************************************************


CREATE OR REPLACE FUNCTION get_overdue_loans()
RETURNS TABLE (
    loan_id INT,
    first_name VARCHAR(50),
	last_name VARCHAR(50),
    book_title VARCHAR(255),
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(10, 2)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT Loans.Loan_ID, Memberships.first_name,Memberships.last_name, Books.Title, Loans.Due_Date, Loans.Return_Date, Loans.Fine_Amount
    FROM Loans
    JOIN Memberships ON Loans.Member_ID = Memberships.Member_ID
    JOIN Books ON Loans.Book_ID = Books.Book_ID
    WHERE Loans.Due_Date < Loans.Return_Date;
END;
$$ LANGUAGE plpgsql;

--***************************************************************

CREATE OR REPLACE FUNCTION popular_books(limit_count INT)
RETURNS TABLE (Book_ID INT, Title VARCHAR(255), Borrow_Count BIGINT) AS
$$
BEGIN
    RETURN QUERY
    SELECT l.Book_ID, b.Title, COUNT(*) AS Borrow_Count
    FROM Loans l
    JOIN Books b ON l.Book_ID = b.Book_ID
    GROUP BY l.Book_ID, b.Title
    ORDER BY Borrow_Count DESC
    LIMIT limit_count;
END;
$$
LANGUAGE plpgsql;

--***************************************************************

CREATE OR REPLACE FUNCTION get_member_info(member_id_param INT)
RETURNS TABLE (
    m_id INT,
    fname VARCHAR(50),
    lname VARCHAR(50),
    mt VARCHAR(50),
    bl INT,
    md INT,
    v INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        Member_ID,
        First_name,
        Last_name,
        Membership_Type,
        Borrowing_Limit,
        Membership_Duration,
        Violations
    FROM Memberships
    WHERE Member_ID = member_id_param;
END;
$$ LANGUAGE plpgsql;

--*************************************************

CREATE OR REPLACE FUNCTION generate_member_analysis_report()
RETURNS TABLE (
    m_id INT,
    m_full_name VARCHAR(100),
    total_loans INT,
    total_reservations INT,
    analysis_result VARCHAR(255)
)
AS $$
DECLARE
    full_name VARCHAR(100);
    member_record RECORD;
BEGIN
    FOR member_record IN (SELECT Member_ID, First_name || ' ' || Last_name AS full_name FROM Memberships)
    LOOP
        SELECT COUNT(*) INTO total_loans
        FROM Loans
        WHERE Member_ID = member_record.Member_ID;

        SELECT COUNT(*) INTO total_reservations
        FROM Reservations
        WHERE Member_ID = member_record.Member_ID;

        IF total_loans > 5 AND total_reservations > 2 THEN
            analysis_result := 'Member has a high level of activity.';
        ELSE
            analysis_result := 'Member has a moderate level of activity.';
        END IF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


--**********************************************

CREATE OR REPLACE FUNCTION most_active_by_month()
RETURNS TABLE (Borrow_Date timestamp with time zone, Borrow_Count bigint) AS $$
BEGIN
  RETURN QUERY
    SELECT DATE_TRUNC('month', Loan_Date) AS Borrow_Date, COUNT(*) AS Borrow_Count
    FROM Loans
    GROUP BY Borrow_Date
    ORDER BY Borrow_Date;
END;
$$ LANGUAGE plpgsql;

--*********************************************

CREATE OR REPLACE FUNCTION most_active_by_year()
RETURNS TABLE (Borrow_Date timestamp with time zone, Borrow_Count bigint) AS $$
BEGIN
  RETURN QUERY
    SELECT DATE_TRUNC('year', Loan_Date) AS Borrow_Date, COUNT(*) AS Borrow_Count
    FROM Loans
    GROUP BY Borrow_Date
    ORDER BY Borrow_Date;
END;
$$ LANGUAGE plpgsql;