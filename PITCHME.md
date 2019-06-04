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
6. Constraint Changes
7. Identity Changes
8. A Case Study

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
6. Constraint Changes
7. Identity Changes
8. A Case Study

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

TODO:  all-blue image

We have "old" code running on all servers.

---

### Servers Down

TODO:  blue-grey

We still have "old" code running on servers but some have gone down, leading to a potentially degraded experience.

---

### New Code

TODO:  blue-green

During this phase, we have old and new application code.  We need to support **both** at the same time.

---

### More Servers Down

TODO:  grey-green

We have only new code but a potentially degraded experience.

---

### All Servers Up

TODO:  all-green image

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
6. Constraint Changes
7. Identity Changes
8. A Case Study

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
6. Constraint Changes
7. Identity Changes
8. A Case Study

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

@snap[west span-25]

New Procedure

@snapend

@snap[east span-75]

|Phase|Process|
|-----|-------|
|Database pre-release| |
|Database release|Deploy new procedure|
|Code release|Deploy calling code|
|Database post-release| |

@snapend

---

@title[Table Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. **Table Changes**
6. Constraint Changes
7. Identity Changes
8. A Case Study

---

@title[Constraint Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. **Constraint Changes**
7. Identity Changes
8. A Case Study

---

@title[Identity Changes]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Constraint Changes
7. **Identity Changes**
8. A Case Study

---

@title[A Case Study]

## Agenda

1. Our Enemy the Downtime
2. The Flow
3. Making Life Simpler
4. Stored Procedure Changes
5. Table Changes
6. Constraint Changes
7. Identity Changes
8. **A Case Study**

---

@title[Wrapping Up]

### Wrapping Up

Functional programming has its own mindset which can take time getting used to, especially if your background is as an object-oriented developer.  There are significant benefits to building up your FP skills, especially if you are interested in the Data Engineering space, where languages like Scala dominate.

---

### Wrapping Up

To learn more, go here:  <a href="https://csmore.info/on/fp">https://CSmore.info/on/fp</a>

And for help, contact me:  <a href="mailto:feasel@catallaxyservices.com">feasel@catallaxyservices.com</a> | <a href="https://www.twitter.com/feaselkl">@feaselkl</a>
