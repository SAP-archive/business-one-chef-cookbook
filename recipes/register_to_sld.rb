#
# Cookbook Name:: b1
# Recipe:: register_to_sld
#

Dir.mkdir('/temp') unless File.exist? '/temp'

v_bypass                    = node['register_to_sld']['dontregister']
Chef::Log.info "Variable v_bypass: #{ v_bypass }"

if v_bypass.downcase == "yes"
   return 0
end

v_sldserver                 = node['register_to_sld']['sldserver']
v_sldusername               = node['register_to_sld']['sldusername']
v_sldpassword               = node['register_to_sld']['sldpassword']
v_instancename              = node['fqdn']
v_sqlversion                = node['register_to_sld']['sqlversion']
v_dbusername                = node['register_to_sld']['dbusername']
v_dbpassword                = node['register_to_sld']['dbpassword']

Chef::Log.info "Variable v_sldserver: #{ v_sldserver }"
Chef::Log.info "Variable v_sldusername: #{ v_sldusername }"
Chef::Log.info "Variable v_sldpassword: #{ v_sldpassword }"
Chef::Log.info "Variable v_instancename: #{ v_instancename }"
Chef::Log.info "Variable v_sqlversion: #{ v_sqlversion }"
Chef::Log.info "Variable v_dbusername: #{ v_dbusername }"
Chef::Log.info "Variable v_dbpassword: #{ v_dbpassword }"

cookbook_file "c:/temp/RegisterDBServerToSLD.exe" do
  source "RegisterDBServerToSLD.exe"
end

#RegisterDBServerToSLD /sldserver [SLDSERVER] /sldusername [SLDUSERNAME] /sldpassword [SLDPASSWORD] /instancename [INSTANCETOADD] /sqlversion [SQLVERSION] /dbusername [INSTANCETOADDUSERNAME] /dbpassword [INSTANCETOADDPASSWORD]
batch "install smo" do
  cwd "C:\\temp\\"
  code "RegisterDBServerToSLD.exe /sldserver #{v_sldserver} /sldusername #{v_sldusername} /sldpassword #{v_sldpassword} /instancename #{v_instancename} /sqlversion #{v_sqlversion} /dbusername #{v_dbusername} /dbpassword #{v_dbpassword}"
  returns [0, -4]
end
