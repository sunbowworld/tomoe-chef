#
# Cookbook Name:: ruby
# Recipe:: passenger
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

rbenv_root = "/usr/local/rbenv"

bash "rbenv rehash" do
  code "#{rbenv_root}/bin/rbenv rehash"
end

# 必要なパッケージのインストール
(%w{gcc pcre pcre-devel zlib zlib-devel openssl} +
%w{openssl-devel curl-devel}).each do |pkg|
  package pkg do
    action :install
  end
end

# passengerをインストール
gem_package "passenger" do
  version node['ruby']['passenger']['version']
  notifies :run, "bash[rbenv rehash]", :immediately
end

# nginx moduleをインストール
bash "passenger_module" do
  code "#{rbenv_root}/shims/passenger-install-nginx-module" +
       " --auto --auto-download --prefix=/usr/local/nginx" +
       " --extra-configure-flags='--user=#{node['ruby']['nginx']['user']}" +
       " --group=#{node['ruby']['nginx']['group']}'"
  creates "/usr/local/nginx/sbin/nginx"
end

# /etc/nginxから/usr/local/nginx/confにリンクを貼る
bash "nginx directory" do
  code "ln -s /usr/local/nginx/conf /etc/nginx"
  creates "/etc/nginx/nginx.conf"
end

# /etc/nginx/conf.dディレクトリを作成
directory "/etc/nginx/conf.d" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# /var/log/nginx ディレクトリを作成
directory "/var/log/nginx" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# ログファイルの作成
%w{access error}.each do |log|
  file "/var/log/nginx/#{log}.log" do
    owner node['ruby']['nginx']['user']
    group "adm"
    mode 00640
    action :touch
  end
end

# nginxの起動スクリプトを作成
template "/etc/init.d/nginx" do
  source "nginx.erb"
  owner "root"
  group "root"
  mode 00755
end

# nginx を登録
bash "chkconfig add nginx" do
  code "chkconfig --add nginx"
end

# nginx.conf を作成
template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 00644
end

# passengerの設定ファイルを作成
bash "passenger conf" do
  code <<-EOC
    echo "passenger_root `passenger-config --root`;" > /etc/nginx/conf.d/passenger.conf
    echo "passenger_ruby `#{rbenv_root}/bin/rbenv which ruby`;" >> /etc/nginx/conf.d/passenger.conf
  EOC
  # creates "/etc/nginx/conf.d/passenger.conf"
end

template "/etc/nginx/conf.d/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode 00644
end

service "nginx" do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end
