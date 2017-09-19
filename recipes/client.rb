#
# Cookbook Name:: b1
# Recipe:: client
#

Chef::Log.info "include seven_zip"
include_recipe "seven_zip"

####################################################################################################
#  --- VARIABLES ---
#
v_archiverepo                   = node['b1']['archiverepo']
v_is_multispan_archive          = node['b1']['is_multispan_archive']
v_archive                       = node['b1']['archive']
v_multispan_archives            = node['b1']['multispan_archives']
v_installerfolderbase           = node['b1']['installerfolder']
v_dbversion                     = node['b1client']['dbversion']
v_branch                        = node['b1client']['branch']
v_patch                         = node['b1client']['patch']
v_platform                      = node['b1client']['platform']
v_platformName                  = v_platform == "x86" ? 32 : 64
v_changelog                     = node['b1client']['changelog']
v_plnumber                      = v_patch.sub(/_HF[[:digit:]]/, '').sub(/_CL_[[:digit:]]{7}/, '') # Get patch number without HF
v_mv                            = v_dbversion.to_s[0..1]
v_dbversion_part1               = v_dbversion.to_s[0..2]
v_dbversion_part2               = v_dbversion.to_s[3..5]

# Leading zero
if v_plnumber.to_i < 10
  v_patch_leadingzero           = "0#{v_patch}"
  v_plnumber_leadingzero        = "0#{v_plnumber}"
else
  v_patch_leadingzero           = v_patch
  v_plnumber_leadingzero        = v_plnumber
end

if !v_is_multispan_archive
  if v_archive == nil
    if v_branch.downcase == "smp"
      v_archivename  = "B1#{v_mv}_PL#{v_patch_leadingzero}"
      v_archiveextension = "zip"
    elsif v_branch.downcase == "rel"
      v_archivename = "Product_#{v_dbversion_part1}.#{v_dbversion_part2}.#{v_plnumber_leadingzero}_CD_#{v_changelog}_MSSQL" # Archive name does not include any HF# 
      v_archiveextension = "rar"
    else
      raise "Unsupported B1 Branch."
    end
  else
      v_archivename = v_archive.rpartition(".").first 
      v_archiveextension = v_archive.rpartition(".").last
  end
end
  
# If E-drive does not exist, use C-drive
v_installerfolderbase           = node['b1']['installerfolder']
if (v_installerfolderbase.include? "E:\\") && (Dir["E:\\"].empty?)
  v_installerfolderbase = "C:\\temp\\b1"
end

if !v_is_multispan_archive
  v_installerfolderextracted = "#{v_installerfolderbase}\\#{v_archivename}"
else
  v_multispan_first_archive = v_multispan_archives[0]
  v_multispan_first_archivename = v_multispan_first_archive.split(".").first
  v_installerfolderextracted = "#{v_installerfolderbase}\\#{v_multispan_first_archivename}"
end

v_programfiles                  = v_platform == "x86" ? node['b1']['programfiles'] : node['b1']['programfiles64']

if v_platform == "x86"
  v_setupExePath = "#{v_installerfolderextracted}\\Packages\\Client\\setup.exe"
  v_setupIssPath = "#{v_installerfolderextracted}\\Packages\\Client\\setup.iss"
else
  v_setupExePath = "#{v_installerfolderextracted}\\Packages.x64\\Client\\setup.exe"
  v_setupIssPath = "#{v_installerfolderextracted}\\Packages.x64\\Client\\setup.iss"
end

if v_dbversion.to_i >= 920170
  v_licenseserverport = "40000"
  v_b1localmachinexmlsource = "b1-local-machine.xml9.2pl7.erb"
elsif v_dbversion.to_i >= 920003
  v_licenseserverport = "30000"
  v_b1localmachinexmlsource = "b1-local-machine.xml.erb"
end

v_licenseserver = node['b1client']['licenseserver']
if v_licenseserver == ""
 v_licenseserver = node['b1']['licenseserver']
end

if v_licenseserver == "localhost"
 v_licenseserver = node['fqdn']
end

v_licenseserverip = node['b1client']['licenseserverip']
if v_licenseserverip == ""
 v_licenseserverip = node['b1']['licenseserverip']
end

if v_licenseserverip == "127.0.0.1"
 v_licenseserverip = node['ipaddress']
end

v_sapassword                    = node['b1']['sapassword']
v_sitepassword                  = node['b1']['siteuserpassword']
#
#  --- END VARIABLES ---
####################################################################################################


Chef::Log.info "Variable v_licenseserver: #{ v_licenseserver }"
Chef::Log.info "Variable v_licenseserverip: #{ v_licenseserverip }"
Chef::Log.info "Variable v_licenseserverport: #{ v_licenseserverport }"
Chef::Log.info "Variable v_sapassword: #{ v_sapassword }"
Chef::Log.info "Variable v_sitepassword: #{ v_sitepassword }"
Chef::Log.info "Variable v_dbversion: #{ v_dbversion }"
Chef::Log.info "Variable v_branch: #{ v_branch }"
Chef::Log.info "Variable v_patch: #{ v_patch }"
Chef::Log.info "Variable v_plnumber: #{ v_plnumber }"
Chef::Log.info "Variable v_platform: #{ v_platform }"
Chef::Log.info "Variable v_archiverepo: #{ v_archiverepo }"
Chef::Log.info "Variable v_installerfolderbase: #{ v_installerfolderbase }"
Chef::Log.info "Variable v_is_multispan_archive: #{ v_is_multispan_archive }"
Chef::Log.info "Variable v_multispan_first_archive: #{ v_multispan_first_archive }"
Chef::Log.info "Variable v_multispan_first_archivename: #{ v_multispan_first_archivename }"
Chef::Log.info "Variable v_archivename: #{ v_archivename }"
Chef::Log.info "Variable v_archiveextension: #{v_archiveextension}"
Chef::Log.info "Variable v_multispan_archives: #{ v_multispan_archives }"
Chef::Log.info "Variable v_installerfolderextracted: #{ v_installerfolderextracted }"
Chef::Log.info "Variable v_b1localmachinexmlsource: #{ v_b1localmachinexmlsource }"
Chef::Log.info "Variable v_programfiles: #{v_programfiles}"
Chef::Log.info "Variable v_setupExePath: #{v_setupExePath}"
Chef::Log.info "Variable v_setupIssPath: #{v_setupIssPath}"


# 
#  --- VERIFY THAT REQUESTED VERSION IS SUPPORTED ---
# 

if v_dbversion.to_i < 920003
  block do
    raise "Unsupported B1 version. Versions below 920003 are not supported."
  end
end

directory v_installerfolderbase do
  action :create
  recursive true
end


# 
#  --- COPY INSTALLATION MEDIA ---
# 

if !v_is_multispan_archive
  remote_file 'Copy Patch Archive' do
    path "#{v_installerfolderbase}\\#{v_archivename}.#{v_archiveextension}"
    source "#{v_archiverepo}/#{v_archivename}.#{v_archiveextension}"
    action :create_if_missing
    not_if { ::File.exists?("#{v_installerfolderextracted}\\UNZIP_COMPLETE")}
  end
else
  v_multispan_archives.each do |file|
    remote_file 'Copy Patch Archive' do
      path "#{v_installerfolderbase}\\#{file}"
      source "#{v_archiverepo}/#{file}"
      action :create_if_missing
      not_if { ::File.exists?("#{v_installerfolderextracted}\\UNZIP_COMPLETE")}
    end
  end
end

if !v_is_multispan_archive
  batch 'unzip_installer' do
    code <<-EOH
    7z.exe x #{v_installerfolderbase}\\#{v_archivename}.#{v_archiveextension}  -o#{v_installerfolderextracted} -r -y
    EOH
    not_if { ::File.exists?("#{v_installerfolderextracted}\\UNZIP_COMPLETE")}
  end
else
  batch 'unzip_installer' do
    code <<-EOH
    7z.exe x #{v_installerfolderbase}\\#{v_multispan_first_archive}  -o#{v_installerfolderextracted} -r -y
    EOH
    not_if { ::File.exists?("#{v_installerfolderextracted}\\UNZIP_COMPLETE")}
  end
end

batch 'record unzip complete' do
  code <<-EOH
  echo > #{v_installerfolderextracted}\\UNZIP_COMPLETE
  EOH
end

if !v_is_multispan_archive
  batch 'delete installer zip' do
    code <<-EOH
    del "#{v_installerfolderbase}\\#{v_archivename}.#{v_archiveextension}"
    EOH
    only_if { ::File.exists?("#{v_installerfolderbase}\\#{v_archivename}.#{v_archiveextension}")}
  end
else
  v_multispan_archives.each do |file|
    batch 'delete installer zip' do
      code <<-EOH
      del "#{v_installerfolderbase}\\#{file}"
      EOH
      only_if { ::File.exists?("#{v_installerfolderbase}\\#{file}")}
    end
  end
end


# 
#  --- CREATE INSTALLATION CONFIG FILE ---
#

template 'setup.iss' do
  path v_setupIssPath
  source "client.setup.iss.erb"
  action :create
end


#
#  --- INSTALL CLIENT ---
#

# %W[...] is rudy for making an array. Try this method of passing options so that #{v_licenseserver} gets evaluated correctly
windows_package 'B1 Client' do
  package_name "SAP Business One Client (#{v_platformName}-bit)"
  source v_setupExePath
  #options '/s /z"C:\Program Files (x86)\SAP\SAP Business One*#{v_licenseserver}:40000"'
  options %W[
            /s
            /z"#{v_programfiles}\\SAP\\SAP Business One*#{v_licenseserver}:#{v_licenseserverport}"
            ].join(' ')
  timeout 1800
  action :install
end

#Replace "C:\Program Files (x86)\SAP\SAP Business One\Conf\b1-local-machine.xml"
template 'b1-local-machine.xml' do
  path "#{v_programfiles}\\SAP\\SAP Business One\\Conf\\b1-local-machine.xml"
  source "#{v_b1localmachinexmlsource}"
  variables(
    :v_licenseserver => v_licenseserver,
    :v_licenseserverip => v_licenseserverip
  )
  action :create
end

#Replace "C:\Program Files (x86)\SAP\SAP Business One DI API\Conf\b1-local-machine.xml"
template 'b1-local-machine.xml' do
  path "#{v_programfiles}\\SAP\\SAP Business One DI API\\Conf\\b1-local-machine.xml"
  source "#{v_b1localmachinexmlsource}"
    variables(
    :v_licenseserver => v_licenseserver,
    :v_licenseserverip => v_licenseserverip
  )
  action :create
end
