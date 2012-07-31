#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_set_mycnf, :server_id => nil, :relay_log => nil do

  log "  Installing my.cnf with server_id = #{params[:server_id]}, relay_log = #{params[:relay_log]}"

  template value_for_platform("default" => "/etc/mysql/conf.d/my.cnf") do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => params[:server_id],
      :relay_log => params[:relay_log]
    )
    cookbook "db_mysql"
  end

  bash "create_config_file" do
    user "root"
    cwd "/etc"
    code <<-EOH
      read -rd '' string << 'EOF'
# * IMPORTANT: Additional settings that can override those from this file!\n
#   The files must end with '.cnf', otherwise they'll be ignored.\n
#\n
!includedir /etc/mysql/conf.d/
EOF
      if [ -e my.cnf ]
      then
        if ! grep -Eq "\s*\!includedir\s*/etc/mysql/conf\.d" my.cnf
        then
          echo -e $string >> my.cnf
        fi
      else
        echo -e $string > my.cnf
      fi
    EOH
  end

end
