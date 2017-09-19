#Default attributes for b1 (MS_SQL)

default['b1']['archiverepo']							= nil
default['b1']['patchrepo']       						= nil
default['b1']['relproductcdrepo']						= nil
default['b1']['siteuserpassword']      					= nil
default['b1']['sapassword']       						= nil
default['b1']['programfiles']       					= "C:\\Program Files (x86)"
default['b1']['programfiles64']       					= "C:\\Program Files"
default['b1']['installerfolder']       					= "E:\\temp\\b1"
default['b1']['licenseserver'] 							= "localhost"
default['b1']['licenseserverip'] 						= "127.0.0.1"

# setupiss_dbservertype (setup.iss)
#
# 	Microsoft SQL 2008 = 6
# 	Microsoft SQL 2008 R2 = 6 
# 	Microsoft SQL 2012 = 7
# 	Microsoft SQL 2014 = 8
default['b1']['setupissdbservertype']					= "8"

# sqlservertype (upgrade.config.xml)
#
# 	Microsoft SQL 2008 R2 = 6
# 	Microsoft SQL 2012 = 7
# 	Microsoft SQL 2014 = 8
#   Microsoft SQL 2016 = 10
default['b1']['sqlservertype']							= "8"

default['b1']['is_multispan_archive']					= false
default['b1']['archive']								= nil # e.g. "B192_PL02.zip"
default['b1']['multispan_archives']						= nil # e.g. [ "B19200_2-80000561_P1.EXE", "B19200_2-80000561_P2.RAR", "B19200_2-80000561_P3.RAR", ... ]

# B1 version defaults
default['b1client']['dbversion'] 						= nil # e.g. "920120"
default['b1client']['patch'] 							= nil # e.g. "2"
default['b1client']['branch'] 							= "SMP"
default['b1client']['changelog']						= ""
default['b1client']['platform'] 						= "x86"
default['b1client']['licenseserver'] 					= ""
default['b1client']['licenseserverip'] 					= ""

default['b1server']['targetdbversion']					= nil # e.g. "920120"
default['b1server']['targetpatch']						= nil # e.g. "2"
default['b1server']['targetbranch']						= "SMP"
default['b1server']['targetchangelog']					= ""

default['register_to_sld']['dontregister']    			= "yes"
default['register_to_sld']['sldserver']       			= ""
default['register_to_sld']['sldusername']     			= ""
default['register_to_sld']['sldpassword']     			= ""
default['register_to_sld']['instancename']    			= ""
default['register_to_sld']['sqlversion']      			= ""
default['register_to_sld']['dbusername']      			= ""
default['register_to_sld']['dbpassword']      			= ""
