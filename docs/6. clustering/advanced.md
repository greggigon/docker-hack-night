# Complete Application

## Create a user
$ openshift ex policy add-user view anypassword:test-admin

## View Openshift Website

Login as the user you just created, password can be anything

https://10.245.2.2:8444/

(You'll need to accept the self-signed cert)

## Create a project

`openshift ex new-project hack --display-name="Hack Night" --description="The Hack Night Demo Project" --admin=anypassword:test-admin`

## Assign a quota to that project

cat hack-quota.json | osc create -n hack -f -

\-n means we're now creating resources in a specific project

See quota settings at:
https://10.245.2.2:8444/project/hack/settings


## Deploy application

Read through the json, it defines a complete application.

`$ cat application.json  | osc create -n hack -f -

`

View app in GUI

## Remove application

`$ cat application.json | osc delete -n hack -f -

