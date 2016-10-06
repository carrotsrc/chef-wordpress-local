template 'home/'<< node[:netnode][:user]<< '/www/public_html/system/config.php' do
    source 'config.php.erb'
    only_if { node[:netnode][:autoconfig] == 1}
end

directory '/home/'<< node[:netnode][:user]<< '/www/gsnstore' do
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
    only_if { node[:netnode][:autoconfig] == 1}
end

directory '/home/'<< node[:netnode][:user]<< '/www/gsnstore/live' do
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
    only_if { node[:netnode][:autoconfig] == 1}
end

directory '/home/'<< node[:netnode][:user]<< '/www/gsnstore/test' do
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
    only_if { node[:netnode][:autoconfig] == 1}
end

directory '/home/'<< node[:netnode][:user]<< '/www/gsnstore/cache' do
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
    only_if { node[:netnode][:autoconfig] == 1}
end
