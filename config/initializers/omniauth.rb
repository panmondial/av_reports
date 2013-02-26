Rails.application.config.middleware.use OmniAuth::Builder do

  if Rails.env.production?
    provider :familysearch, ENV['FAMILYSEARCH_DEVELOPER_KEY'], '',
      :client_options => {
        :site => 'https://sandbox.familysearch.org', # TODO remove this line when we get a production developer key
        :connection_opts => { :ssl => { :ca_file => '/usr/lib/ssl/certs/ca-certificates.crt' } }
      }
  else
    provider :familysearch, ENV['FAMILYSEARCH_DEVELOPER_KEY'], '',
      :client_options => {
        :site => 'https://sandbox.familysearch.org',
        :connection_opts => { :ssl => { :verify => false } }
      }
  end

end
