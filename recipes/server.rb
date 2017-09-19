#
# Cookbook Name:: b1
# Recipe:: server
#

Chef::Log.info "include seven_zip"
include_recipe "seven_zip"


####################################################################################################
#  --- VARIABLES ---
#
v_licenseserver             = node['fqdn']
v_licenseserverip           = node['ipaddress']
v_sapassword                = node['b1']['sapassword']
v_sitepassword              = node['b1']['siteuserpassword']
v_installerfolderbase       = node['b1']['installerfolder']
v_archiverepo               = node['b1']['archiverepo']
v_is_multispan_archive      = node['b1']['is_multispan_archive']
v_archive                   = node['b1']['archive']
v_multispan_archives        = node['b1']['multispan_archives']
v_dbversion                 = node['b1server']['targetdbversion']
v_branch                    = node['b1server']['targetbranch']
v_patch                     = node['b1server']['targetpatch']
v_changelog                 = node['b1server']['targetchangelog']
v_plnumber                  = v_patch.sub(/_HF[[:digit:]]/, '').sub(/_CL_[[:digit:]]{7}/, '') # Get patch number without HF
v_mv                        = v_dbversion.to_s[0..1]
v_dbversion_part1           = v_dbversion.to_s[0..2]
v_dbversion_part2           = v_dbversion.to_s[3..5]

if v_plnumber.to_i < 10
  # Leading zero
  v_patch_leadingzero = "0#{v_patch}"
  v_plnumber_leadingzero = "0#{v_plnumber}"
else
  v_patch_leadingzero = v_patch
  v_plnumber_leadingzero = v_plnumber
end

# If E-drive does not exist, use C-drive
v_installerfolderbase           = node['b1']['installerfolder']

if (v_installerfolderbase.include? "E:\\") && (Dir["E:\\"].empty?)
  v_installerfolderbase = "C:\\temp\\b1"
end

if !v_is_multispan_archive
  if v_archive == nil
    if v_branch.downcase == "smp"
      v_archivename = "B1#{v_mv}_PL#{v_patch_leadingzero}"
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
  
if !v_is_multispan_archive
  v_installerfolderextracted = "#{v_installerfolderbase}\\#{v_archivename}"
else
  v_multispan_first_archive = v_multispan_archives[0]
  v_multispan_first_archivename = v_multispan_first_archive.split(".").first
  v_installerfolderextracted = "#{v_installerfolderbase}\\#{v_multispan_first_archivename}"
end
#
#  --- END VARIABLES ---
####################################################################################################


Chef::Log.info "Variable v_licenseserver: #{ v_licenseserver }"
Chef::Log.info "Variable v_licenseserverip: #{ v_licenseserverip }"
Chef::Log.info "Variable v_is_multispan_archive: #{ v_is_multispan_archive }"
Chef::Log.info "Variable v_archivename: #{ v_archivename }"
Chef::Log.info "Variable v_archiveextension: #{ v_archiveextension }"
Chef::Log.info "Variable v_multispan_archives: #{ v_multispan_archives }"
Chef::Log.info "Variable v_dbversion: #{ v_dbversion }"
Chef::Log.info "Variable v_branch: #{ v_branch }"
Chef::Log.info "Variable v_patch: #{ v_patch }"
Chef::Log.info "Variable v_installerfolderbase: #{ v_installerfolderbase }"
Chef::Log.info "Variable v_sapassword: #{ v_sapassword }"
Chef::Log.info "Variable v_sitepassword: #{ v_sitepassword }"
Chef::Log.info "Variable v_installerfolderextracted: #{ v_installerfolderextracted }"
Chef::Log.info "Variable v_archiverepo: #{ v_archiverepo }"
Chef::Log.info "Variable v_changelog: #{v_changelog}"
Chef::Log.info "Variable v_plnumber: #{v_plnumber}"
Chef::Log.info "Variable v_mv: #{v_mv}"
Chef::Log.info "Variable v_dbversion_part1: #{v_dbversion_part1}"
Chef::Log.info "Variable v_dbversion_part2: #{v_dbversion_part2}"
Chef::Log.info "Variable v_multispan_first_archive: #{v_multispan_first_archive}"
Chef::Log.info "Variable v_multispan_first_archivename: #{v_multispan_first_archivename}"


#  --- VERIFY THAT REQUESTED VERSION IS SUPPORTED ---
if v_dbversion.to_i < 920003
  block do
    raise "Unsupported B1 version. Versions below 920003 are not supported."
  end
end


#
#  --- COPY INSTALLATION MEDIA ---
#

directory v_installerfolderbase do
  action :create
  recursive true
end

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

if
v_dbversion.to_i >= 920170
  template 'config.xml' do
    path "#{v_installerfolderextracted}\\config.xml"
    source "server9.2pl7.config.xml.erb"
	action :create
  end
elsif
v_dbversion.to_i >= 920130
  template 'config.xml' do
    path "#{v_installerfolderextracted}\\config.xml"
    source "server9.2pl3.config.xml.erb"
	action :create
  end
else 
  template 'config.xml' do
    path "#{v_installerfolderextracted}\\config.xml"
    source "server9.2pl0.config.xml.erb"
	action :create
  end
end


#
#  --- CHECK FOR EXISTING INSTALLATION ---
#

template 'get_sbocommmon_version.ps1' do
  path "#{v_installerfolderbase}\\get_sbocommmon_version.ps1"
  source "get_sbocommmon_version.ps1.erb"

  action :create
end

# Check version
powershell_script "run get_sbocommmon_version.ps1" do
  cwd v_installerfolderbase
  code <<-EOH
     ./get_sbocommmon_version.ps1
  EOH
  not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end


#
#  --- INSTALL SERVER ---
#

# Chef windows_package resource is not compatible with B1 9.2 installer. Batch call is used instead
batch 'Install B1 Server' do
  cwd v_installerfolderextracted
  code <<-EOH
    Setup.exe config.xml -DbPassword #{v_sapassword} -SitePassword #{v_sitepassword} -SLDCertPassword #{v_sitepassword} -SLDDomainPassword #{v_sitepassword} -B1iDBPassword #{v_sapassword} -B1iAdminPassword #{v_sitepassword} -B1iDIPassword #{v_sitepassword}
  EOH
  returns [0, 3010]
  not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end

# Check version
powershell_script "run get_sbocommmon_version.ps1" do
  cwd v_installerfolderbase
  code <<-EOH
     ./get_sbocommmon_version.ps1
  EOH
  not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end

#
# workaround for '3010' error on B1 version >= 9.2 PL3 in the cases where Windows desktop logon has never occurred
# >>>>>>>>>>
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce' do
  values [{
    :name => "BusinessOne Prerequisites",
    :type => :string,
    :data => ''
    }]
  action :delete
end

batch 'Install B1 Server' do
 cwd v_installerfolderextracted
 code <<-EOH
 Setup.exe config.xml -DbPassword #{v_sapassword} -SitePassword #{v_sitepassword} -SLDCertPassword #{v_sitepassword} -SLDDomainPassword #{v_sitepassword} -B1iDBPassword #{v_sapassword} -B1iAdminPassword #{v_sitepassword} -B1iDIPassword #{v_sitepassword}
 EOH
 returns [0]
 not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end
# <<<<<<<<<<
#


#
#  --- VALIDATE VERSION ---
#

powershell_script "run get_sbocommmon_version.ps1" do
  cwd v_installerfolderbase
  code <<-EOH
     ./get_sbocommmon_version.ps1
  EOH
  not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end

ruby_block "verify sbocommon version" do
  block do
    raise "SBO-COMMON version is not on the expected target version"
  end
  not_if { ::File.exists?("#{v_installerfolderbase}\\UPGRADE_RAN_#{v_dbversion}")}
end
