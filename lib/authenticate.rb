def authenticate_me(com)
  com.key = 'WCQY-7J1Q-GKVV-7DNM-SQ5M-9Q5H-JX3H-CMJK'
  com.identity_v1.authenticate :username => 'api-user-2082', :password => 'f1e0'
end

def authenticate_me_test(com)
  com.key = 'WCQY-7J1Q-GKVV-7DNM-SQ5M-9Q5H-JX3H-CMJK'
  com.identity_v1.authenticate :username => @current_user.fs_username, :password => @current_user.fs_password
end