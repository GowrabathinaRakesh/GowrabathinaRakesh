

create database if not exists library_project;
use library_project;

create table tbl_publisher(
publisher_PublisherName varchar(255) primary key,
publisher_PublisherAddress varchar(255),
publisher_PublisherPhone bigint);
describe tbl_publisher;
select * from tbl_publisher;
alter table tbl_publisher
modify publisher_PublisherPhone varchar(255);
desc tbl_publisher;
select * from tbl_publisher;

create table tbl_book(
book_BookID int primary key,
book_Title varchar(255),
book_PublisherName varchar(255),
foreign key(book_PublisherName)
 references tbl_publisher(Publisher_PublisherName)on delete cascade)auto_increment = 100;
 
 select * from tbl_book;
 
 create table tbl_library_branch(
library_branch_BranchID int primary key auto_increment,
library_branch_BranchName varchar(255),
library_branch_BranchAddress varchar(255));

alter table tbl_library_branch
modify column library_branch_BranchID int  auto_increment;
select * from tbl_library_branch;
 
 select * from tbl_book_authors;
 
 use library_project;
 create table tbl_book_copies(
book_copies_CopiesID int primary key auto_increment,
book_copies_BookID int,
book_copies_BranchID int,
book_copies_No_Of_Copies int,
foreign key(book_copies_BookID)
references tbl_book(book_BookID)on delete cascade,
foreign key(book_copies_BranchID)
references tbl_library_branch(library_branch_BranchID)on delete cascade);


create table tbl_book_authors(
book_author_AuthorID int  primary key auto_increment,
book_authors_BookID int ,
book_authors_AuthorName varchar(255),
foreign key(book_authors_BookID)
references tbl_book(book_BookID) on delete cascade);


create table tbl_borrower(
borrower_CardNo int primary key,
borrower_BorrowerName varchar(255),
borrower_BorrowerAddress varchar(255),
borrower_BorrowerPhone varchar(255));

select * from tbl_borrower;

create table tbl_book_loans(
book_loans_LoansID int primary key auto_increment,
book_loans_BookID int,
book_loans_BranchID int,
book_loans_CardNo int,
book_loans_DateOut datetime,
book_loans_DueDate datetime,
foreign key (book_loans_BookID)
references tbl_book(book_BookID),
foreign key (book_loans_BranchID)
references tbl_library_branch(library_branch_BranchID),
foreign key (book_loans_CardNo)
references tbl_borrower(borrower_CardNo));


/*
-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
-- Retrieve the names of all borrowers who do not have any books checked out.
-- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central"
*/
select * from tbl_book;
select * from tbl_library_branch;
select * from tbl_book_copies;
select *
from tbl_book_copies
where book_copies_BookID = 20;

-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select abs.book_BookID,abs.book_Title,abs.book_copies_No_Of_Copies,abs.library_branch_BranchName
from
	 (select * from tbl_book as tb
	 join tbl_book_copies as tc
	 on tb.book_BookId = tc.book_copies_BookID
	 join tbl_library_branch as lb
	 on tc.book_copies_BranchID = lb.library_branch_BranchID) as abs
     where abs.library_branch_BranchName = 'Sharpstown' and abs.book_Title = 'The Lost Tribe';

-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select distinct (lb.library_branch_BranchName) ,tb.book_BookID,tb.book_Title,tc.book_copies_No_Of_Copies
from tbl_book as tb
join tbl_book_copies as tc
on tb.book_BookID = tc.book_copies_BookID
join tbl_library_branch as lb
on tc.book_copies_BranchID = lb.library_branch_BranchID
group by tb.book_BookID,tb.book_Title,tc.book_copies_CopiesID
having tb.book_Title like 'The lost Tribe';

-- Retrieve the names of all borrowers who do not have any books checked 
/* the below code is to find the person who hasnt taken a single book from the library*/ 
select * from tbl_borrower
 where borrower_CardNo not in (
								 select tb.borrower_CardNo from tbl_borrower as tb
								 join tbl_book_loans as tl
								 on tl.book_loans_CardNo = tb.borrower_CardNo);
 
 select * from tbl_book_loans;
 
 -- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
 
 select av.library_branch_BranchName,av.book_title,av.borrower_BorrowerName,av.borrower_BorrowerAddress,av.book_loans_DueDate
 from
	(select * from 
	 tbl_borrower as tb
	 join tbl_book_loans as tl
	 on tb.borrower_CardNo = tl.book_loans_CardNo
	 join tbl_library_branch ll
	 on tl.book_loans_BranchID = ll.library_branch_BranchID
	 join tbl_book as t
	 on tl.book_loans_BookID = t.book_BookID
	 where library_branch_BranchName = 'Sharpstown'
	 and book_loans_DueDate = '2018-03-02 00:00:00') as av;
 
 -- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
 select  lb.library_branch_BranchName,ll.book_loans_BranchID,count(*) as no_books_loaned
 from tbl_library_branch as lb
 join tbl_book_loans as ll
 on ll.book_loans_BranchID= lb.library_branch_BranchID
 group by lb.library_branch_BranchName,ll.book_loans_BranchID
 order by no_books_loaned desc;
 
 
/* 
-- total no of books from each branch
select count(*) as n , ld.library_branch_BranchName from 
 tbl_book_copies as tc
 join tbl_library_branch as ld
 on tc.book_copies_BranchID = ld.library_branch_BranchID
 group by ld.library_branch_BranchName;
 */
 
-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central"
select tb.book_Title,count(tc.book_copies_BookID) as number,ta.book_authors_AuthorName,lg.library_branch_BranchName
from tbl_book_authors as ta
join tbl_book as tb
on ta.book_authors_BookID = tb.book_BookID
join tbl_book_copies as tc
on tb.book_BookID=tc.book_copies_BookID
join tbl_library_branch as lg
on  tc.book_copies_BranchID = lg.library_branch_BranchID
group by lg.library_branch_BranchName,ta.book_authors_AuthorName,tb.book_Title
having ta.book_authors_AuthorName = 'Stephen King' and lg.library_branch_BranchName='Central' ;
 
 
 -- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
 
 select tb.borrower_BorrowerName,tb.borrower_BorrowerAddress,count(*) as number_books from tbl_borrower as tb
 join tbl_book_loans as tl
 on tb.borrower_CardNo = tl.book_loans_CardNo
 group by tb.borrower_BorrowerName,tb.borrower_BorrowerAddress
 having number_books > 5
 order by number_books desc;
 
 select * from tbl_borrower;
 
