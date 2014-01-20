# user作成
users_ids = data_bag('users')

users_ids.each do |id|
  u = data_bag_item('users', id)
  
  # user作成
  user u['user_name'] do
    uid u['uid'] if u['uid']
    gid u['groups'] if u['groups']
    shell u['shell'] if u['shell']
    if u['home']
      home u['home']
      supports manage_home: true
    end
    password u['password'] if u['password']
    comment u['comment'] if u['comment']
  end
  
  if u['ssh_keys'] and u['home']
    # SSHディレクトリ作成
    ssh_dir = File.join(u['home'], '.ssh')
    directory ssh_dir do
      owner u['user_name']
      mode 0700
    end
    
    # SSH公開鍵の設置
    file File.join(ssh_dir, "authorized_keys") do
      owner u['user_name']
      mode 0600
      content u['ssh_keys'].join("\n")
    end
  end
end

# group作成
groups_ids = data_bag('groups')

groups_ids.each do |id|
  g = data_bag_item('groups', id)
  group g['group_name'] do
    gid g['gid'] if g['gid']
    members g['members'] if g['members']
  end
end

