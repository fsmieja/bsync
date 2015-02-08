module AuthsHelper
  
  def authenticate_api(domain, token)
    Basecamp.establish_connection!(domain, token, 'X', true)
  end

#  'schoolscloud.basecamphq.com'
#  '1697eb4b12d8cd2e37cf14129839ac6e4e035d3c'
#  'dc84564d1f0a05376b00186d62a751ae75d722bb'

end
