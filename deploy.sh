#!/usr/bin/env bash
set -eux

#sudo systemctl restart redis-server.service
sudo systemctl restart mysql.service

# sudo systemctl stop isu.service
# docker-compose build
# sudo systemctl start isu.service

cd ruby
bundle install --jobs 4
cd ..
sudo systemctl restart isuda.ruby.service
sudo systemctl restart isutar.ruby.service
# sudo systemctl restart isutar.ruby.service

# cd react
# NODE_ENV=production npm run build
# cd ..
# sudo systemctl restart isu.react.service

sudo logrotate -f /etc/logrotate.d/nginx
sudo service nginx restart
sudo chmod 644 /var/log/nginx/access_kataribe.log
sudo tail /var/log/nginx/error.log
