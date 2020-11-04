# Approaching Zero:  Minimizing Downtime During Deployments

This repository provides the supporting code for my presentation entitled [Approaching Zero:  Minimizing Downtime During Deployments](https://www.catallaxyservices.com/presentations/approaching-zero/).

## Running the Code

There are **two** ways that you can get the demos working.  We will take each in turn.

### Run Docker Image

If you have Docker installed on your machine, you can grab the image from [Docker Hub](https://hub.docker.com/repository/docker/feaselkl/presentations).  Run the following commands to pull the Docker image and then start up a container running SQL Server with the `ZDT` database pre-created.

```
docker pull docker.io/feaselkl/presentations:approaching-zero-db
docker run --name approaching-zero-db -p 51433:1433 docker.io/feaselkl/presentations:approaching-zero-db
```

From there, connect to `localhost,51433` from SQL Server Management Studio or Azure Data Studio using the username `sa` and the password `SomeBadP@ssword3` and start running the Scripts in the `Scripts` directory from `10 - New Stored Procedure.sql`.

At the end, you will not need to run script `99 - Cleanup.sql` because you can stop and delete the container:

```
docker stop approaching-zero-db
docker rm approaching-zero-db
```

### Run Locally on SQL Server

If you would like to run the scripts but do not have Docker installed, run the script named `01 - Prep Script.sql` and that will create a database called `ZDT`.

The script `99 - Cleanup.sql` allows you to re-run the scripts later, which is handy when presenting this session multiple times!