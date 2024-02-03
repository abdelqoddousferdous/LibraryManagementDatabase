
CREATE TABLE IF NOT EXISTS Memberships (
    Member_ID UUID  PRIMARY KEY,
	First_name VARCHAR(50),
	Last_name VARCHAR(50),
    Membership_Type VARCHAR(50) NOT NULL
	CHECK (Membership_Type IN ('Individual Membership', 'Family Membership', 'Student Membership')),
    Borrowing_Limit INT,
    Membership_Duration INT,
	Violations INT
	--Account_status VARCHAR(20) CHECK (Account_status IN ('Active', 'Suspended', 'Inactive'))
);

CREATE TABLE IF NOT EXISTS  Books (
    Book_ID UUID  PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    Publication_Date DATE,
    Stock VARCHAR(20) DEFAULT 'In Stock',
	BookType VARCHAR(50)
    CHECK (BookType IN ('MAGAZIN' , 'NOVEL', 'JOURNAL', 'BOOK'))
);

CREATE TABLE IF NOT EXISTS Reservations (
    Reservation_ID UUID PRIMARY KEY,
    Member_ID UUID REFERENCES Memberships(Member_ID),
    Book_ID UUID REFERENCES Books(Book_ID),
    Reservation_Date DATE,
    Status VARCHAR(20) DEFAULT 'Reserved'
);

CREATE TABLE IF NOT EXISTS Loans (
    Loan_ID UUID  PRIMARY KEY,
    Member_ID UUID REFERENCES Memberships(Member_ID),
    Book_ID UUID REFERENCES Books(Book_ID),
    Loan_Date DATE,
    Due_Date DATE,
    Return_Date DATE,
    Fine_Amount DECIMAL(10, 2),
    CHECK (Fine_Amount >= 0)
);

CREATE TABLE IF NOT EXISTS  Suppliers (
    Supplier_ID UUID  PRIMARY KEY,
    Supplier_Name VARCHAR(255) NOT NULL,
    Contact_Info VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS  Purchases (
    Purchase_ID UUID PRIMARY KEY,
    Supplier_ID UUID REFERENCES Suppliers(Supplier_ID),
    Book_ID UUID REFERENCES Books(Book_ID),
    Purchase_Date DATE,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    CHECK (Quantity > 0 AND UnitPrice >= 0)
);

CREATE TABLE IF NOT EXISTS  StaffUsers (
    Staff_ID UUID  PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Pd VARCHAR(255) NOT NULL,
    Full_Name VARCHAR(255),
	Staff_role VARCHAR(50) CHECK (Staff_role IN ('MANAGER', 'HR', 'Director'))
);

/*CREATE TABLE IF NOT EXISTS  Staffroles(
 	Role_id SERIAL PRIMARY KEY,
	Staff_ID INT REFERENCES StaffUsers(Staff_ID),
	Role_name VARCHAR(50)
);*/



