#!/bin/bash

# login to an ec2 instance sitting behind an elb

if [ -z $1 ]
then
    echo "Usage: ec2_ssh.sh elb-tag-name"
    exit 1
fi

if [ -z $JAVA_HOME ]
then
    export JAVA_HOME=`which java|awk '{sub(/bin\/java/, "", $1); print'}`
fi

if [ -z $AWS_ELB_HOME ]
then
   if [ ! -f /tmp/aws-elb-tools.zip ]
   then
      wget http://ec2-downloads.s3.amazonaws.com/ElasticLoadBalancing.zip -O /tmp/aws-elb-tools.zip
      unzip /tmp/aws-elb-tools.zip -d /tmp
   fi
   export AWS_ELB_HOME="/tmp/ElasticLoadBalancing-1.0.10.0"
fi

if !(which ec2-describe-instances > /dev/null)
then
    sudo apt-get install ec2-api-tools
fi

host=`$AWS_ELB_HOME/bin/elb-describe-lbs $1 --show-xml|awk '/<InstanceId>/ {print substr($1, 13, 10)}' | xargs ec2-describe-instances |grep -m 1 INSTANCE|awk '{print "root@"$4}'`

echo "ssh $host ..."

ssh $host