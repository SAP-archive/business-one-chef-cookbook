![](https://img.shields.io/badge/STATUS-NOT%20CURRENTLY%20MAINTAINED-red.svg?longCache=true&style=flat)

# Important Notice
This public repository is read-only and no longer maintained.

# Description
This Chef cookbook installs SAP Business One.
It contains the following recipes:
* b1::server
Recipe installs the SAP Business One server (SBO-Common, Server Tools, etc.).
* b1::client
Recipe installs the SAP Business One client.
* b1::register_to_sld
Register an existing Business One server to an existing SLD.

SAP Business One Partners can find tutorials on how to use these cookbooks and setup Business One test environments with Chef on the [SAP PartnerEdge](https://partneredge.sap.com/en/products/business-one/support.html).
# Limitations


**_The SAP Business One Cookbooks do not follow the Business One installation process as described in the Business One Admin Guide.
It is recommended to use these Chef Cookbooks to only create SAP Business One Test and Demo environments. 
The SAP Business One Support Organization will not support Productive environment created with these Chef Cookbooks._**


* This cookbook supports SAP Business One from version 9.2 Patch 2.
* The tool registering to the SLD only support username/password SQL connection



# Requirements
For the Microsoft Windows platform only.
Microsoft SQL server must be installed first.


# Download and Installation

## Download
This Cookbook is meant to be used in conjonction with a Chef server.
You can use Knife or Berkshelf for example to add this Cookbook to a Chef Repository.

For example, you can add this line to the Berksfile of your wrapper cookbook:

	source 'https://supermarket.chef.io'
	metadata
	cookbook 'b1', git: 'https://github.com/SAP/business-one-chef-cookbook.git'



## Usage 

This will install the B1 Server components (including the B1 Server, SLD, License Server, etc.) and the B1 Client. You need to define the archive location, the version and the passwords.

`recipe[b1::server],recipe[b1::client]`

Attributes: 

	{
		"b1": {
		 	"archiverepo": "http://myfileserver/b1-software/ms-sql",
			"archive": "B192_PL05.zip",
			"sqlservertype": "8",
			"setupissdbservertype": "8",
			"systempassword": "MyPassword1",
			"siteuserpassword": "MyPassword1"
		},
		"b1server": {
		 	"targetdbversion": "920150",
			"targetpatch": "5"
		},
		"b1client": {
		 	"dbversion": "920150",
			"patch": "5"
		}
	}
	


## Usage - with pre-existing SLD

This will install the B1 Server components and the B1 Client and register the MS-SQL instance to a separate SLD. You need to define the archive location, the version and the passwords.

`recipe[b1::server],recipe[b1::client],recipe[b1::register_to_sld]`

Attributes: 

	{
		"b1": {
		 	"archiverepo": "http://myfileserver/b1-software/ms-sql",
			"archive": "B192_PL05.zip",
			"sqlservertype": "8",
			"setupissdbservertype": "8",
			"systempassword": "MyPassword1",
			"siteuserpassword": "MyPassword1"
		},
		"b1server": {
		 	"targetdbversion": "920150",
			"targetpatch": "5"
		},
		"b1client": {
		 	"dbversion": "920150",
			"patch": "5"
		},
	 	"register_to_sld": {
		 	"sldserver": "mysld.mydomain",
		 	"sldusername": "B1SiteUser",
		 	"sldpassword": "MyPassword1",
		 	"instancename": "myinstance.mydomain",
		 	"sqlversion": "SQL2014",
		 	"dbusername": "sa",
		 	"dbpassword": "MyPassword1"
		 	}
	}


# Configuration

## List of cookbook attributes
| Key 									| Type 			| Description | Default |
| ------------------------------------ 	| ---- 			| ----------- | ------- |
| ['b1']['archiverepo'] 				| String 		| **[Required]** Location of the compressed B1 installation archive | nil |
| ['b1']['installerfolder']				| String		| The temp folder to be used by the cookbook | "E:\\temp\\b1" |
| ['b1']['archive'] 					| String 		| Name of the B1 installation archive file | nil |
| ['b1']['is_multispan_archive'] 		| Boolean 		| Specify if the compressed archive is a multispan archive | false |
| ['b1']['multispan_archives'] 			| String array 	| Names of all the files in the B1 installation multispan archive e.g. [ "B19200_2-80000561_P1.EXE", "B19200_2-80000561_P2.RAR", "B19200_2-80000561_P3.RAR", ... ] | nil |
| ['b1']['sqlservertype'] 				| String 		| A number representing the MSSQL Server Type. Microsoft SQL 2008 = 4; Microsoft SQL 2008 R2 = 5; Microsoft SQL 2012 = 6; Microsoft SQL 2014 = 8; Microsoft SQL 2016 | "8" |
| ['b1']['setupissdbservertype']	 	| String 		| A number representing the MSSQL Server Type for use in .iss files. Microsoft SQL 2008 = 6; Microsoft SQL 2008 R2 = 6; Microsoft SQL 2012 = 7; Microsoft SQL 2014 = 8; Microsoft SQL 2016 = 10| "8" |
| ['b1']['sapassword'] 					| String 		| **[Required]** sa password for the SQL server | nil |
| ['b1']['siteuserpassword'] 			| String 		| **[Required]** B1SiteUser password for the SLD | nil |
| ['b1']['programfiles']				| String 		| The installation path of SAP Business One 32 bits | "C:\\Program Files (x86)"
| ['b1']['programfiles64'] 				| String 		| The installation path of SAP Business One 64 bits | "C:\\Program Files"
| ['b1']['licenseserver'] 				| String 		| The SLD server hostname | "localhost"
| ['b1']['licenseserverip'] 			| String 		| The SLD server IP address | "127.0.0.1"
| ['b1server']['targetdbversion'] 		| String 		| **[Required]** For B1 Server. B1 Database Version. e.g. "920120"  | nil |
| ['b1server']['targetpatch'] 			| String 		| **[Required]** For B1 Server. B1 Patch Number. e.g. "2"  | nil |
| ['b1client']['dbversion']		 		| String 		| **[Required]** For B1 Client. B1 Database Version. e.g. "920120"  | nil |
| ['b1client']['patch'] 				| String 		| **[Required]** For B1 Client. B1 Patch Number. e.g. "2"  | nil |
| ['b1client']['platform'] 				| String		| Specifies if the 32 or 64 bits version of the client will be installed |  "x86" |
| ['b1client']['licenseserver'] 		| String 		| The SLD server hostname | ""
| ['b1client']['licenseserverip'] 		| String 		| The SLD server IP address | ""
| ['register_to_sld']['dontregister']  	| String 		| To be used in wrapper cookbook - bypass the registration | "yes"
| ['register_to_sld']['sldserver']		| String 		| Hostname part of the SLD url; localhost if SLD is https://localhost:40000/ControlCenter  | ""
| ['register_to_sld']['sldusername']	| String 		| Username to connect to the SLD | ""
| ['register_to_sld']['sldpassword']	| String 		| Password to connect the SLD | ""
| ['register_to_sld']['instancename']	| String 		| The SQL instance to add to the SLD  | ""
| ['register_to_sld']['sqlversion']		| String 		| SQL version to register in the SLD: SQL2008, SQL2008R2, SQL2012, SQL2014, SQL2016 | ""
| ['register_to_sld']['dbusername']		| String 		| The Username to connect to the client SQL Server | ""
| ['register_to_sld']['dbpassword']		| String 		| The Password to connect to the client SQL Server | ""

	
# Known Issues
The Powershell script checking the version in the SINF table in SBO-Common does not report an error if it fails to connect to the SQL server.


# How to obtain support
This project allows and expects users to post questions or bug reports in the [GitHub bug tracking system](../../issues).

# Contributing
If you would like to contribute, please fork this project and post pull requests.

# License
Copyright (c) 2017 SAP SE or an SAP affiliate company. All rights reserved.
This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the [LICENSE](LICENSE.txt) file.

