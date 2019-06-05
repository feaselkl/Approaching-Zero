<style>
.reveal section img { background:none; border:none; box-shadow:none; }
</style>

## Approaching Zero
### Minimizing Downtime During Deployments

<a href="https://www.catallaxyservices.com">Kevin Feasel</a> (<a href="https://twitter.com/feaselkl">@feaselkl</a>)<br />
<a href="https://csmore.info/on/zdt">https://CSmore.info/on/zdt</a>

---

@title[Who Am I?]

@snap[west splitscreen]
<table>
	<tr>
		<td><a href="https://csmore.info"><img src="https://www.catallaxyservices.com/media/Logo.png" height="133" width="119" /></a></td>
		<td><a href="https://csmore.info">Catallaxy Services</a></td>
	</tr>
	<tr>
		<td><a href="https://curatedsql.com"><img src="https://www.catallaxyservices.com/media/CuratedSQLLogo.png" height="133" width="119" /></a></td>
		<td><a href="https://curatedsql.com">Curated SQL</a></td>
	</tr>
	<tr>
		<td><a href="https://wespeaklinux.com"><img src="https://www.catallaxyservices.com/media/WeSpeakLinux.jpg" height="133" width="119" /></a></td>
		<td><a href="https://wespeaklinux.com">We Speak Linux</a></td>
	</tr>
</table>
@snapend

@snap[east splitscreen]
<div>
	<a href="https://www.twitter.com/feaselkl"><img src="https://www.catallaxyservices.com/media/HeadShot.jpg" height="358" width="315" /></a>
	<br />
	<a href="https://www.twitter.com/feaselkl">@feaselkl</a>
</div>
@snapend

---

### Motivation

The goal of this talk is to minimize downtime due to application deployments.  Ideally, we would want to get this down to zero:  users experience zero downtime when the app upgrades.

In reality, that is impossible.  We instead settle for **approaching** zero.

---

@title[Our Enemy the Downtime]

## Agenda

1. **Our Enemy the Downtime**
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### Know Your Enemy:  Downtime

If your website has office hours, downtime is no problem:  you deploy during off hours occasionally.

Most websites aren't like that anymore.  Instead, users expect 24/7 uptime.  For deployments, users can accept occasional degraded experiences (especially around performance) but otherwise want to get on with their lives.  We need an approach to keep them happy while pushing out code changes at a reasonable time.

---

### Know Your Enemy:  Downtime

**Downtime** is any time users are unable to access the resources they need in your product.  Reasons for downtime:
* Hardware failures
* Application down due to deployment
* Network / routing issues
* Locks on resources
* Persistent timeouts due to performance issues

---

### Why I Don't Believe in Zero Downtime

Table locks are downtime.  Thought experiment:  drop and rebuild the clustered columnstore index on a fact table and see if anyone complains.

Many operations take locks for short amounts of time.  With luck, nobody will notice these locks, but there are small batches of potential downtime here.  Users tend to be forgiving regarding these--it's easy enough to say "the network must be slow today"!

---

### The Benefits of Minimizing Downtime

**Users** can get their work done with fewer interruptions.

**Developers** can deploy smaller changes faster, giving end users fixes and improvements sooner.

**Administrators** can deploy when people are in the office and available.

---

@title[The Flow]

## Agenda

1. Our Enemy the Downtime
2. **The Flow**
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### The Flow

Our flow will be a modified **blue-green deployment** method.  We will have the following phases:

1. Database Pre-Release
2. Database Release
3. Application Release
4. Database Post-Release

---

### Database Pre-Release

Pre-release starts whenever you are ready for it.  Good things to do during pre-release are:

* Scheduling things that will take a long time.
* Making changes which need to happen before the rest of the process.
* Phase 1 of a multi-step process.

Users should not notice that you are in database pre-release.

---

### Database Release

Database release often starts on a fixed schedule but can run several times a day.  We **might** see a degradation of services here.

During this phase, we push the majority of database changes.  Our database changes need to support the application release model.

---

### Application Release Model

We will use the blue-green deployment model today.  We will show without loss of generality the variant in which the number of application servers is fixed.

---

### Before the Release

![Phase 1:  all old code.](presentation/assets/image/code_phase1_blue.png)

We have "old" code running on all servers.

---

### Servers Down

![Phase 2:  old code and some servers down.](presentation/assets/image/code_phase2_bluegrey.png)

We still have "old" code running on servers but some have gone down, leading to a potentially degraded experience.

---

### New Code

![Phase 3:  some old code and some new code running concurrently.](presentation/assets/image/code_phase3_bluegreen.png)

During this phase, we have old and new application code.  We need to support **both** at the same time.

---

### More Servers Down

![Phase 4:  some servers down and some new code.](presentation/assets/image/code_phase4_greygreen.png)

We have only new code but a potentially degraded experience.

---

### All Servers Up

![Phase 5:  all new code.](presentation/assets/image/code_phase5_green.png)

Servers are back to normal, running new code.

---

### Database Post-Release

During this phase, we get to destroy stuff, removing unused columns, dropping obsolete procedures or tables, deleting old data, etc.

Database post-release can go on as long as needed and customers should not notice a thing.

---

@title[Making Life Simpler]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. **Making Life Simpler**
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### Key Assumptions

I will make three key assumptions.  These make deployment much easier and help reduce the risk of extended downtime due to a process failure.

1. You have code in source control
2. You have an automated release process
3. You have a continuous integration pipeline

---

### Source Control

Source control is not mandatory but it is **really** helpful.  Source control is a safety net and allows you to revert code quickly in event of failure.

Git is the most popular source control system, but use whatever you want.

---

### Automated Release Process

**That** you have something is more important than the tool itself.  Use Azure DevOps, Octopus Deploy, Jenkins, a hand-built solution, or whatever works.

Automated release processes ensure all scripts go and that each release is consistent.  Humans make a lot of replication mistakes; let computers do that work.

---

### Continuous Integration Pipeline

With an automated release process, keep deploying to lower environments--you want as many tests of your deployment scripts as possible.  That way you won't have any nasty downtime-related surprises going to production, or errors if you need to re-run scripts.

---

### Simplification Measures

In addition to the key assumptions, we have a few tools for making life easier.

1. Use Enterprise Edition
2. Use Read Committed Snapshot Isolation
3. Use Stored Procedures
4. Use Database Tests

---

### Use Enterprise Edition

Enterprise Edition allows you to do things you cannot do in Standard Edition, such as rebuilding indexes online and partitioning tables.  These can make deployments easier.

---

### Use RCSI

Read Committed Snapshot Isolation limits the amount of blocking on tables.  If you can turn it on, do so.  This will let you write to tables without blocking readers.  Note that writers can still block writers with RCSI.

RCSI does increase tempdb usage, sometimes considerably.  Keep that in mind if you haven't turned it on yet.

---

### Use Stored Procedures

Stored procedures act as an interface between your application code and your database objects.  Stored procedures let us provide a consistent interface, letting us refactor database code and objects without the application knowing or caring.

Stored procedures also let you explicitly see backward compatibility:  you can (usually) know which of ProcedureV4 and ProcedureV3 is newer.

---

### Use Database Tests

Database tests give you an extra dose of confidence that your refactoring will not break existing code.  This lets you experiment more without additional risk.

tSQLt is the most popular database test library out there, but it could be as simple as a series of NUnit tests which make stored procedure calls.

---

@title[Stored Procedure Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. **Stored Procedure Changes**
5. Table Changes
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### Stored Procedure Changes

Scenarios covered:

1. New stored procedure
2. Add new column to procedure
3. Remove column from procedure
4. Change input parameter
5. Change input parameter -- table type
6. Refactoring a procedure

---?image=presentation/assets/background/demo.jpg&size=cover&opacity=20

### Demo Time

---

### Stored Procedure Recap

What follows are the phase and process for each scenario we have covered.  These are here for your reference.

---

New Stored Procedure

@table[table-header table-tsv text-07](presentation/assets/tsv/11_NewStoredProcedure.txt)

---

Add New Column to Procedure

@table[table-header table-tsv text-07](presentation/assets/tsv/12_NewColumn.txt)

---

Remove Column from Procedure

@table[table-header table-tsv text-07](presentation/assets/tsv/13_RemoveColumn.txt)

---

Change Input Parameter

@table[table-header table-tsv text-07](presentation/assets/tsv/14_ChangeInputParameter.txt)

---

Change Input Paramter -- Table Type

@table[table-header table-tsv text-07](presentation/assets/tsv/15_ChangeInputParameter_TableType.txt)

---

Refactoring a Procedure

@table[table-header table-tsv text-07](presentation/assets/tsv/16_RefactorProcedure.txt)

---

@title[Table Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. **Table Changes**
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### Table Changes

Scenarios covered:

1. Add a nullable column
2. Add a non-nullable column with a default constraint
3. Backfill a new column
4. Remove a column
5. Remove a column with a constraint
6. Extend VARCHAR column
7. Shrink VARCHAR column
8. Rename a table

---?image=presentation/assets/background/demo.jpg&size=cover&opacity=20

### Demo Time

---

### Table Recap

What follows are the phase and process for each scenario we have covered.  These are here for your reference.

---

Add a Nullable Column

@table[table-header table-tsv text-07](presentation/assets/tsv/21_AddNullableColumn.txt)

---

Add a Non-Nullable Column with a Default Constraint

@table[table-header table-tsv text-07](presentation/assets/tsv/22_AddColumnWithConstraint.txt)

---

Backfill a New Column

@table[table-header table-tsv text-05](presentation/assets/tsv/23_BackfillColumn.txt)

---

Remove a Column

@table[table-header table-tsv text-07](presentation/assets/tsv/24_RemoveColumn.txt)

---

Remove a Column with a Constraint

@table[table-header table-tsv text-07](presentation/assets/tsv/25_RemoveColumnWithConstraint.txt)

---

Extend a VARCHAR Column

@table[table-header table-tsv text-07](presentation/assets/tsv/26_ExtendVarcharColumn.txt)

---

Shrink a VARCHAR Column

@table[table-header table-tsv text-05](presentation/assets/tsv/27_ShrinkVarcharColumn.txt)

---

Rename a Table

@table[table-header table-tsv text-07](presentation/assets/tsv/28_RenameTable.txt)

---

@title[Index Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. **Index Changes**
7. Constraint Changes
8. Identity Changes
9. A Case Study

---

### Index Changes

Scenarios covered:

1. Add a non-clustered index
2. Drop a non-clustered index
3. Create a clustered index
4. Change a clustered index which is not the primary key
5. Separate out a combination primary key and clustered index

---?image=presentation/assets/background/demo.jpg&size=cover&opacity=20

### Demo Time

---

### Index Recap

What follows are the phase and process for each scenario we have covered.  These are here for your reference.

---

Add a Non-Clustered Index

@table[table-header table-tsv text-07](presentation/assets/tsv/30_CreateIndex.txt)

---

Drop a Non-Clustered Index

@table[table-header table-tsv text-07](presentation/assets/tsv/31_DropIndex.txt)

---

Add a Clustered Index

@table[table-header table-tsv text-07](presentation/assets/tsv/32_CreateClusteredIndex.txt)

---

Change a Non-Primary Key Clustered Index 

@table[table-header table-tsv text-07](presentation/assets/tsv/33_ChangeNonPKClusteredIndex.txt)

---

Separate Out a Primary Key + Clustered Index

@table[table-header table-tsv text-07](presentation/assets/tsv/34_SeparatePKAndCI.txt)

---

@title[Constraint Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. **Constraint Changes**
8. Identity Changes
9. A Case Study

---

### Constraint Changes

Scenarios covered:

1. Add a default constraint
2. Change a default constraint
3. Add a unique key constraint
4. Add other constraints

---?image=presentation/assets/background/demo.jpg&size=cover&opacity=20

### Demo Time

---

### Constraints Recap

What follows are the phase and process for each scenario we have covered.  These are here for your reference.

---

Add a Default Constraint

@table[table-header table-tsv text-07](presentation/assets/tsv/41_AddDefaultConstraint.txt)

---

Change a Default Constraint

@table[table-header table-tsv text-07](presentation/assets/tsv/42_ChangeDefaultConstraint.txt)

---

Add a Unique Key Constraint

@table[table-header table-tsv text-07](presentation/assets/tsv/43_AddUniqueKeyConstraint.txt)

---

Add Other Constraints

@table[table-header table-tsv text-05](presentation/assets/tsv/44_AddOtherConstraints.txt)

---

@title[Identity Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. Constraint Changes
8. **Identity Changes**
9. A Case Study

---

### Identity Changes

Scenarios covered:

1. Add an identity column to an existing table
2. Reseed an identity column
3. Change the data type of an identity column

---?image=presentation/assets/background/demo.jpg&size=cover&opacity=20

### Demo Time

---

### Identity Recap

What follows are the phase and process for each scenario we have covered.  These are here for your reference.

---

Add an Identity Column to an Existing Table

@table[table-header table-tsv text-07](presentation/assets/tsv/51_AddIdentityColumn.txt)

---

Reseed an Identity Column

@table[table-header table-tsv text-07](presentation/assets/tsv/52_ReseedIdentityColumn.txt)

---

Change the Data Type of an Identity Column

@table[table-header table-tsv text-05](presentation/assets/tsv/53_ChangeIdentityColumnType.txt)

---

@title[A Case Study]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Index Changes
7. Constraint Changes
8. Identity Changes
9. **A Case Study**

---

### A Case Study

As a Database Engineer, I was responsible for approximately 200 tables and 800 stored procedures.

Most of these tables had a column called `ClientID` as part of the primary key.  The only problem?  It needs to be called `ProfileID`.  Which means updating 150+ tables and 700+ stored procedures.  Without extended downtime.

---

### The Scope

* Rename `ClientID` to `ProfileID` on 150 tables, including constraint and index names.
* Drop 150 unused procedures and 20 unused tables.
* Rename `ClientID` to `ProfileID` on 550+ procedures.  And refactor while we're in there.
* Update SSIS packages to use `ProfileID` instead of `ClientID`.
* Convert ad hoc queries in code to stored procedures and make them use `ProfileID`.

---

![Phase 1:  all ClientID references.](presentation/assets/image/phase-1-starting.png)

---

### Pre-Pre-Release (Phase 1)

* Begin reformatting and refactoring procedures.
* Look for unused procedures.  Search in plan and procedure cache, code base, SQL Agent jobs, SSIS packages, metadata tables, etc.  Eliminate broken objects.
* Create lots and lots of database tests.

---

### Pre-Release Phase

* Add `ProfileID` as nullable INT on each table with `ClientID`.

---

### Database Release (Phase 2a)

* Release temporary procedures which take `@ClientID` and `@ProfileID` as parameters.  
* Scoop out logic from app-level procedures and put into temp procedures.  Run `ISNULL(@ProfileID, @ClientID)` checks on these.
* Turn app-level procedures into shells which call temp procedures.

---

![Phase 2a:  ProfileID added as a column.](presentation/assets/image/phase-2a-add-profileid.png)

---

### Database Release (Phase 2b)

Change references in views and functions to return `ISNULL(ProfileID, ClientID)` instead of `ClientID`.

---

![Phase 2b:  have views include ProfileID references.](presentation/assets/image/phase-2b-modify-views.png)

---

### Database Release (Phase 2c)

Update non-application SQL code to run `ISNULL(ProfileID, ClientID)` checks.  This includes:

* SQL Agent jobs
* Triggers
* Non-application stored procedures
* SSIS packages
* Other processes

---

![Phase 2c:  update non-application code to include ProfileID references.](presentation/assets/image/phase-2c-update-non-code.png)

---

### Database Release (Phase 3)

Swap `ProfileID` and `ClientID`:

* Rename `ProfileID` to `ProfileID2`
* Rename `ClientID` to `ProfileID`
* Add new `ClientID` nullable integer
* Drop `ProfileID2`

Then rename all constraints and indexes using `sp_rename`.

---

![Phase 3:  swap ProfileID and ClientID.](presentation/assets/image/phase-3-swap-profileid.png)

---

### Database Post-Release (Phase 4)

Deploy final versions of "temp" application code procedures:  replace `@ClientID` with `@ProfileID` in app procedures and change `ISNULL(ProfileID, ClientID)` to `ProfileID`.

Return `ProfileID` column on procedures as well as `ProfileID AS ClientID`.

---

![Phase 4:  add final versions of new procedures.](presentation/assets/image/phase-4-new-procedures.png)

---

### Database Post-Release (Phase 5)

Update non-application SQL code to change `ISNULL(ProfileID, ClientID)` to `ProfileID`.

---

![Phase 5:  remove ClientID references from non-app code.](presentation/assets/image/phase-5-update-code.png)

---

### Database Post-Release (Phase 6)

Update views and functions to change `ISNULL(ProfileID, ClientID)` checks to `ProfileID`.

Include `ProfileID` and `ProfileID AS ClientID` columns in result sets.

---

![Phase 6:  remove ClientID references from views and functions.](presentation/assets/image/phase-6-updated-views-and-functions.png)

---

### Post- Database Post-Release (Phase 7)

* Drop the empty ClientID column on each table.
* Deprecate obsolete objects.

---

![Phase 7:  drop ClientID columns.](presentation/assets/image/phase-7-drop-clientid.png)

---

### Post- Database Post-Release (Phase 8)

Update application code over time to call new procedures instead of old code-facing procedures and change `ClientID` code references to `ProfileID`.  Deprecate old procedures over time.

---

![Phase 8:  clean up the database over time.  Lots of time.](presentation/assets/image/phase-8-cleanup.png)

---

@title[Wrapping Up]

### Wrapping Up

"Zero" downtime database deployments aren't for every company.  If you have the ability to take downtime windows, your deployments are significantly easier.

Still, if you do need these tools, it is good to know what you can safely do without blocking your customers.

---

### Wrapping Up

To learn more, go here:  <a href="https://csmore.info/on/zdt">https://CSmore.info/on/zdt</a>

And for help, contact me:  <a href="mailto:feasel@catallaxyservices.com">feasel@catallaxyservices.com</a> | <a href="https://www.twitter.com/feaselkl">@feaselkl</a>
