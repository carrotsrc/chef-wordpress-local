
link '/etc/nginx/sites-enabled/'<< node[:wp][:sub] << '.zni.lan.conf' do
    action :delete
end

file '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.zni.lan.conf' do
    action :delete
end



directory '/srv/www/vhosts/' << node[:wp][:sub] << ".zni.lan" do
    action :delete
    recursive true
    only_if{node[:wp][:sub] != ""}
end


ruby_block 'rem_host' do
    block do
	    line = '127.0.0.1 ' << node[:wp][:sub] << '.zni.lan'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

ruby_block 'rem_subdomain_listing' do
    block do
	    line = node[:wp][:sub] << '.zni.lan,/srv/www/vhosts/'<< node[:wp][:sub] << '.zni.lan/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

execute 'database-drop' do
command "echo \"DROP DATABASE IF EXISTS " << node[:wp][:sub] << "_wpinst;\" | mysql --host=localhost --user=dbagent_foo";
end

service 'nginx' do
    action :restart
end
