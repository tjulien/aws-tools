ec2_ssh.sh:
login to an ec2 instance sitting behind an elb
      Usage: ec2_ssh.sh [elb-tagname]
      without the elb-tagname, a list of elb-tagnames will be returned.
      with an elb-tagname, this script will ssh into an ec2 instance behind that elb.

      PREREQS:
      * add the ssh key you used to bring up the instance to your ssh keys using ssh-add
      * set EC2_PRIVATE_KEY to the location of the .pem file that is the general private key of your aws account
      * set EC2_CERT to the location of the .pem file that is the general certificate of your aws account
