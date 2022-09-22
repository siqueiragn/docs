## Setup AWS Account 
##### Author: [Gabriel Siqueira](https://github.com/siqueiragn)
---

There are two ways to set up your AWS CLI credentials, using files and setting enviroment variables.  

## Linux
#### Using files:

First of all, you should run ```$ aws configure get [--profile]``` on your CLI. If there are any credentials stored, the return will be something like this: 
```
[default]
AWS Access Key ID [None]: XXXXXXXXXX
AWS Secret Access Key [None]: XxxxXXXXXXXX/xXXxxXXXG/xXXXXxxXXxXX
Default region name [None]: us-west-2
Default output format [None]: json
```
At this point, if your credentials are incorret, you must go ahead with these steps:
```
$ nano ~/.aws/credentials
```

The ```credentials``` file store profiles. You can create multiples profiles with different accounts setting the profile name inside of brackets (ex: [terraform-account]). If there are incorret credentials, fix them and save the file.
```
[default]
aws_access_key_id=xxxxxXXXXXXXXX
aws_secret_access_key=XXxxXxxXXxx/XXXXXXXX/xxxXXxxXxxXXx
```
To keep a understandable configuration and organizated settings, you can create other file named ```config``` to declare some important variables, like region and the output for requests on AWS.
```
$ nano ~/.aws/config
```
```
[default]
region=us-west-2
output=json
```

More config layouts on [Oficial AWS CLI Setup Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
