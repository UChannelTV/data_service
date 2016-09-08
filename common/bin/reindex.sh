#!/bin/bash
# Update solr index

ssh -i ~/.ssh/us-west.pem ec2-user@54.193.89.199 'cd ~/uchannel/data_service/api; source ~/.bash_profile; bundle exec rake sunspot:reindex RAILS_ENV=production 1>/tmp/result.out; tail /tmp/result.out'
ssh -i ~/.ssh/us-west.pem ec2-user@54.67.60.195 'cd ~/uchannel/data_service/api; source ~/.bash_profile; bundle exec rake sunspot:reindex RAILS_ENV=production 1>/tmp/result.out; tail /tmp/result.out'
