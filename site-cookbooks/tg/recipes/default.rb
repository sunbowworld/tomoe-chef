#
# Cookbook Name:: tg
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "/var/www/teamgenerator-tomoe" do
  owner "tg"
  group "tg"
  mode 0775
end
