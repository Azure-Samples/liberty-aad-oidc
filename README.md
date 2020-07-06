---
page_type: sample
languages:
- java
products:
- azure
description: "Securing Open Liberty/WebSphere Liberty Application with Azure Active Directory via OpenID Connect"
urlFragment: "liberty-aad-oidc"
---

# Securing Open Liberty/WebSphere Liberty Application with Azure Active Directory via OpenID Connect

This project demonstrates how to secure your Java EE application on Open Liberty/WebSphere Liberty using Azure Active Directory and OpenID Connect. The following is how you run the demo.

## Prerequisites

* Install Java SE 8 (we used [AdoptOpenJDK OpenJDK 8 LTS/OpenJ9](https://adoptopenjdk.net)).
* Install [Maven](https://maven.apache.org/download.cgi) 3.5.0 or higher.
* Install [Docker](https://docs.docker.com/get-docker/) for your OS.
* You will need an Azure subscription. If you don't have one, you can get one for free for one year [here](https://azure.microsoft.com/free).
* Download this repository somewhere in your file system (easiest way might be to download as a zip and extract).

## Setup Azure Active Directory

1. You will first need to [get an Azure Active Directory tenant](https://docs.microsoft.com/azure/active-directory/develop/quickstart-create-new-tenant). It is very likely your Azure account already has a tenant. Please note down your tenant/directory ID.
2. Although this isn't absolutely necessary, you can [create a few Azure Active Directory users](https://docs.microsoft.com/azure/active-directory/fundamentals/add-users-azure-active-directory). You can use these accounts or your own to test the application. Do note down email addresses and passwords for login.
3. You will need to create an admin group to enable JWT RBAC (role-based-access-control) functionality. Follow [create a basic group and add members using Azure Active Directory](https://docs.microsoft.com/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) to create a group with type as **Security** and add one or more members. Note down the group ID.
4. You will need to [create a new application registration](https://docs.microsoft.com/azure/active-directory/develop/quickstart-register-app) in Azure Active Directory. Please specify the redirect URI to be: https://localhost:9443/oidcclient/redirect/liberty-aad-oidc-javaeecafe. Please note down the application (client) ID.
5. You will need to create a new client secret. In the newly created application registration, find 'Certificates & secrets'. Select 'New client secret'. Provide a description and hit 'Add'. Note down the generated client secret value.
6. You will need to add a **groups claim** into the ID token. In the newly created application registration, find 'Token configuration'. Click 'Add groups claim'. Select 'Security groups' as group types to include in the ID token. Expand 'ID' and select 'Group ID' in the 'Customize token properties by type' section.

## Start the Database instance

The first step to getting the application running is getting the database up. Please follow the instructions below to get the database running.

1. Ensure that all running Docker containers are shut down. You may want to do this by restarting Docker. The demo depends on containers started in a specific order.
2. Make sure Docker is running. Open a console.
3. Enter the following command and wait for the database to come up fully.

   ```bash
   docker run -it --rm --name javaee-cafe-db -v pgdata:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres
   ```

4. The database is now ready (to stop it, simply press Control-C after the Java EE application is shutdown).

Now we can get the application up and running.  The following steps show two different ways to do so: Docker and maven.

## Start the Application with Docker

1. Download [postgresql-42.2.4.jar](https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.4/postgresql-42.2.4.jar) and put it into directory where you have this repository downloaded on your local machine.
2. Open a console. Navigate to where you have this repository downloaded on your local machine.
3. Run `mvn clean package --file javaee-cafe/pom.xml`. This will generate a war deployment under `./javaee-cafe/target`.
4. Build a Docker image tagged `javaee-cafe` by running one of the following commands.

   ```bash
   # build from open liberty base image
   docker build -t javaee-cafe --pull .
   # build from websphere liberty base image
   docker build -t javaee-cafe --pull --file=Dockerfile-wlp .
   ```

5. To run the newly built image, execute the following command. These are the parameters required:

   * `POSTGRESQL_SERVER_NAME`: For Mac and Windows users, 'host.docker.internal' may be used. For other operating systems, use the IP 172.17.0.2 (note, this depends on the fact that the database is the first container to start).
   * `POSTGRESQL_USER`: Use `postgres`.
   * `POSTGRESQL_PASSWORD`: Keep it empty.
   * `CLIENT_ID`: The application/client ID you noted down.
   * `CLIENT_SECRET`: The client secret value you noted down.
   * `TENANT_ID`: The tenant/directory ID you noted down.
   * `ADMIN_GROUP_ID`: The admin group ID you noted down.

   ```bash
   docker run -it --rm -p 9080:9080 -p 9443:9443 -e POSTGRESQL_SERVER_NAME=<...> -e POSTGRESQL_USER=postgres -e POSTGRESQL_PASSWORD= -e CLIENT_ID=<...> -e CLIENT_SECRET=<...> -e TENANT_ID=<...> -e ADMIN_GROUP_ID=<...> javaee-cafe
   ```

6. Wait for Liberty to start and the application to deploy successfully (to stop the application and Liberty, simply press Control-C).

## Start the Application with Maven

You can also get the application up and running using the `mvn` command.

1. Open a console. Navigate to where you have this repository downloaded on your local machine.
2. Run `mvn clean package --file javaee-cafe/pom.xml`.
3. Execute the following command with required parameters (Windows PowerShell uses a slight variant):
   * `postgresql.server.name`: Use `localhost`.
   * `postgresql.user`: Use `postgres`.
   * `postgresql.password`: Keep it empty.
   * `client.id`: The application/client ID you noted down.
   * `client.secret`: The client secret value you noted down.
   * `tenant.id`: The tenant/directory ID you noted down.
   * `admin.group.id`: The admin group ID you noted down.

   ```bash
   mvn -Dpostgresql.server.name=localhost -Dpostgresql.user=postgres -Dpostgresql.password= -Dclient.id=<...> -Dclient.secret=<...> -Dtenant.id=<...> -Dadmin.group.id=<...> liberty:run --file javaee-cafe/pom.xml
   ```

4. Note: if you want to run from Windows PowerShell, please use the following command:

   ```bash
   mvn --file javaee-cafe/pom.xml liberty:run "-Dpostgresql.server.name=localhost" "-Dpostgresql.user=postgres" "-Dpostgresql.password=" "-Dclient.id=<...>" "-Dclient.secret=<...>" "-Dtenant.id=<...>" "-Dadmin.group.id=<...>"
   ```

5. Wait for Liberty to start and the application to deploy successfully (to stop the application and Liberty, simply press Control-C).

## Visit the Application

1. Once the application starts, you can visit the JSF client at

   * [https://localhost:9443/javaee-cafe](https://localhost:9443/javaee-cafe)
   * [http://localhost:9080/javaee-cafe](http://localhost:9080/javaee-cafe)
2. Logging in as a user who doesn't belong to the admin group, you won't be allowed to remove coffee entries as the **Delete** button will be disabled.
3. Logging in as a user who does belong to the admin group, you will be allowed to remove coffee entries as the **Delete** coffee button will be enabled.

## References

* [Configuring an OpenID Connect Client in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_config_oidc_rp.html)
* [Enabling SSL communication in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_sec_ssl.html)
* [Configuring authorization for applications in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_sec_rolebased.html)
* [SSL configuration values in Open Liberty](https://openliberty.io/docs/ref/config/#ssl.html)
* [Building and consuming JSON Web Token (JWT) tokens in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_sec_config_jwt.html)
* [Configuring the MicroProfile JSON Web Token](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_sec_json.html)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
