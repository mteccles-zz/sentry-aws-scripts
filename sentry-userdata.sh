#!/bin/bash
yum update -y
yum install -y docker
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
service docker start

yum install -y git
git clone https://github.com/getsentry/onpremise.git
cd onpremise/
mkdir -p data/{sentry,postgres}

/usr/local/bin/docker-compose run --rm web config generate-secret-key | tail -1 > SECRET_KEY

skey=$(<SECRET_KEY)
sed -i "s/# SENTRY_SECRET_KEY: ''/SENTRY_SECRET_KEY: '${skey//&/\\&}'/" docker-compose.yml
rm SECRET_KEY

/usr/local/bin/docker-compose run --rm web upgrade --noinput

/usr/local/bin/docker-compose run --rm web createuser --email sentry@fakeuser.com --password timmie1 --superuser

/usr/local/bin/docker-compose up -d
