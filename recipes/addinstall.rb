
directory '/srv/www/vhosts/' << node[:wp][:sub] <<'.zni.lan' do 
    action :create
    mode '0775'
    owner 'nginx'
    group 'ops'
end

directory '/srv/www/vhosts/' << node[:wp][:sub] <<'.zni.lan/www' do 
    action :create
    mode '0775'
    owner 'nginx'
    group 'ops'
end

template '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.zni.lan.conf' do
    source 'nginx.conf.erb'
end

ruby_block 'add_host' do
    block do
	    line = '127.0.0.1 ' << node[:wp][:sub] << '.zni.lan'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end


link '/etc/nginx/sites-enabled/'<< node[:wp][:sub] << '.zni.lan.conf' do
    to '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.zni.lan.conf' 
end



execute 'unpack-wordpress' do
    cwd '/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan/www/'
    command 'tar -xf /home/cfg/Software/wordpress-4.6.1.tar.gz'
end

ruby_block 'rename-wordpress' do
    block do
	::File.rename('/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan/www/wordpress','/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan/www/public_html')
    end
end

execute 'set-selinux-context' do
    cwd '/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan'
    command 'chcon -Rv --type=httpd_sys_rw_content_t www'
    #command 'chcon -Rv --type=httpd_sys_content_t www'
end

execute 'set-public_permissions' do
    cwd '/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan/www/'
    command 'chmod -R 775 *'
end

execute 'set-owner' do
    cwd '/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan'
    command 'chown -R nginx *'
end

execute 'set-group' do
    cwd '/srv/www/vhosts/' << node[:wp][:sub] << '.zni.lan'
    command 'chgrp -R ops *'
end

service 'nginx' do
    action :restart
end

execute 'database-create' do
	command "echo \"CREATE DATABASE IF NOT EXISTS " << node[:wp][:sub] << "_wpinst DEFAULT CHARACTER SET utf8; GRANT ALL PRIVILEGES ON  " << node[:wp][:sub] << "_wpinst . * TO dbagent_foo@localhost;\" | mysql --host=localhost --user=dbagent_foo";
end

ruby_block 'add_subdomain_listing' do
    block do
	    line = node[:wp][:sub] << '.zni.lan,/srv/www/vhosts/'<< node[:wp][:sub] << '.zni.lan/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end

execute 'wordpress-database-config' do
	command 'curl "http://' << node[:wp][:sub] << '.zni.lan/wp-admin/setup-config.php?step=2" --data "dbname='<< node[:wp][:sub] <<'_wpinst&uname=dbagent_foo&pwd&dbhost=localhost&prefix=wp_&language&submit=Submit"'
end

execute 'wordpress-install-config' do
command 'curl "http://' << node[:wp][:sub] << '.zni.lan/wp-admin/install.php?step=2" --data "weblog_title=' << node[:wp][:sub] << ' Instance&user_name=admin&admin_password=passw0rd&pass1-text=passw0rd&admin_password2=passw0rd&admin_email=admin@foo.bar&Submit=Install+WordPress&language=en_US"'
end
