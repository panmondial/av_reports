Rails.application.config.middleware.use OmniAuth::Builder do

  if Rails.env.production?
    provider :familysearch, ENV['FAMILYSEARCH_DEVELOPER_KEY'], '',
      :client_options => { :site => 'https://sandbox.familysearch.org' }
    #provider :familysearch, ENV['FAMILYSEARCH_DEVELOPER_KEY'], '',
  else
    provider :familysearch, ENV['FAMILYSEARCH_DEVELOPER_KEY'], '',
      :client_options => { :site => 'https://sandbox.familysearch.org' }
  end

end
