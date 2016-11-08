
directory '/var/www/' << node[:wp][:sub] <<'.wp' do 
    action :create
    mode '0775'
    owner 'www-data'
    group 'ops'
end

directory '/var/www/' << node[:wp][:sub] <<'.wp/www' do 
    action :create
    mode '0775'
    owner 'www-data'
    group 'ops'
end

template '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.wp.conf' do
    source 'nginx.conf.erb'
end

ruby_block 'add_host' do
    block do
	    line = '127.0.0.1 ' << node[:wp][:sub] << '.wp'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end


link '/etc/nginx/sites-enabled/'<< node[:wp][:sub] << '.wp.conf' do
    to '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.wp.conf' 
end



execute 'unpack-wordpress' do
    cwd '/var/www/' << node[:wp][:sub] << '.wp/www/'
    command 'tar -xf /home/cfg/Software/wordpress-4.6.1.tar.gz'
end

ruby_block 'rename-wordpress' do
    block do
	::File.rename('/var/www/' << node[:wp][:sub] << '.wp/www/wordpress','/var/www/' << node[:wp][:sub] << '.wp/www/public_html')
    end
end

#execute 'set-selinux-context' do
#    cwd '/var/www/' << node[:wp][:sub] << '.wp'
#    command 'chcon -Rv --type=httpd_sys_rw_content_t www'
    #command 'chcon -Rv --type=httpd_sys_content_t www'
#end

execute 'set-public_permissions' do
    cwd '/var/www/' << node[:wp][:sub] << '.wp/www/'
    command 'chmod -R 775 *'
end

execute 'set-owner' do
    cwd '/var/www/' << node[:wp][:sub] << '.wp'
    command 'chown -R www-data *'
end

execute 'set-group' do
    cwd '/var/www/' << node[:wp][:sub] << '.wp'
    command 'chgrp -R ops *'
end

service 'nginx' do
    action :restart
end

execute 'database-create' do
	command "echo \"CREATE DATABASE IF NOT EXISTS " << node[:wp][:sub].gsub("-","_") << "_wpinst DEFAULT CHARACTER SET utf8; GRANT ALL PRIVILEGES ON  " << node[:wp][:sub].gsub("-","_") << "_wpinst . * TO dbagent_foo@localhost;\" | mysql --host=localhost --user=dbagent_foo";
end

ruby_block 'add_subdomain_listing' do
    block do
	    line = node[:wp][:sub] << '.wp,/var/www/'<< node[:wp][:sub] << '.wp/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end

execute 'wordpress-database-config' do
	command 'curl "http://' << node[:wp][:sub] << '.wp/wp-admin/setup-config.php?step=2" --data "dbname='<< node[:wp][:sub].gsub("-","_") <<'_wpinst&uname=dbagent_foo&pwd&dbhost=localhost&prefix=wp_&language&submit=Submit"'
end

execute 'wordpress-install-config' do
command 'curl "http://' << node[:wp][:sub] << '.wp/wp-admin/install.php?step=2" --data "weblog_title=' << node[:wp][:sub] << ' Instance&user_name=admin&admin_password=passw0rd&pass1-text=passw0rd&admin_password2=passw0rd&admin_email=admin@foo.bar&Submit=Install+WordPress&language=en_US"'
end
