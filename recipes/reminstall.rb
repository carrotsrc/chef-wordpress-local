
link '/etc/nginx/sites-enabled/'<< node[:wp][:sub] << '.wp.conf' do
    action :delete
end

file '/etc/nginx/sites-available/'<< node[:wp][:sub] << '.wp.conf' do
    action :delete
end



directory '/var/www/' << node[:wp][:sub] << ".wp" do
    action :delete
    recursive true
    only_if{node[:wp][:sub] != ""}
end


ruby_block 'rem_host' do
    block do
	    line = '127.0.0.1 ' << node[:wp][:sub] << '.wp'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

ruby_block 'rem_subdomain_listing' do
    block do
	    line = node[:wp][:sub] << '.wp,/var/www/'<< node[:wp][:sub] << '.wp/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

execute 'database-drop' do
command "echo \"DROP DATABASE IF EXISTS " << node[:wp][:sub].gsub("-","_") << "_wpinst;\" | mysql --host=localhost --user=dbagent_foo";
end

service 'nginx' do
    action :restart
end
