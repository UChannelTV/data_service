require 'koala'

# access_token and other values aren't required if you set the defaults as described above
graph = Koala::Facebook::API.new('139108223457638|7H91kcHzoSlIH0PEt7Q6v0DxLNI')
graph.put_wall_post("Test post with API")

