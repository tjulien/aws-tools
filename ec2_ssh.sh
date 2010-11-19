#!/bin/bash

# login to an ec2 instance sitting behind an elb
# Usage: ec2_ssh.sh [elb-tagname]
# without the elb-tagname, a list of elb-tagnames will be returned.
# with an elb-tagname, this script will ssh into an ec2 instance behind that elb.

# PREREQS:
# * add the ssh key you used to bring up the instance to your ssh keys using ssh-add
# * set EC2_PRIVATE_KEY to the location of the .pem file that is the general private key of your aws account
# * set EC2_CERT to the location of the .pem file that is the general certificate of your aws account

if [ -z $EC2_CERT ]
then
    echo 'please set EC2_CERT to the env to the location of the .pem file that is the general certificate of your aws account'
    exit 1
fi

if [ -z $EC2_PRIVATE_KEY ]
then
    echo 'please set  EC2_PRIVATE_KEY to the location of the .pem file that is the general private key of your aws account'
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
       echo 'Installing aws elb tools...'
      wget http://ec2-downloads.s3.amazonaws.com/ElasticLoadBalancing.zip -O /tmp/aws-elb-tools.zip
      unzip /tmp/aws-elb-tools.zip -d /tmp
   fi
   export AWS_ELB_HOME="/tmp/ElasticLoadBalancing-1.0.10.0"
fi

if !(which ec2-describe-instances > /dev/null)
then
    echo 'Installing aws api tools...'
    sudo apt-get install ec2-api-tools
fi


if [ -z $1 ]
then
    echo 'fetching elb tag names...'
    $AWS_ELB_HOME/bin/elb-describe-lbs | awk '{print $2}'
    echo ''
    echo 'Usage: ec2_ssh.sh elb-tag-name'
exit 1
fi

echo 'looking up ip address...'
host=`$AWS_ELB_HOME/bin/elb-describe-lbs $1 --show-xml|awk '/<InstanceId>/ {print substr($1, 13, 10)}' | xargs ec2-describe-instances |grep -m 1 INSTANCE|awk '{print "root@"$4}'`

echo $host

echo "ssh $host ..."

ssh $host
