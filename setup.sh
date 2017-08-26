oc login -u system:admin
oc create -n openshift -f \
https://raw.githubusercontent.com/jboss-openshift/application-templates/ose-v1.3.7/jboss-image-streams.json
oc replace -n openshift -f \
https://raw.githubusercontent.com/jboss-openshift/application-templates/ose-v1.3.7/jboss-image-streams.json
for template in sso71-https.json \
  sso71-mysql-persistent.json \
  sso71-mysql.json \
  sso71-postgresql-persistent.json \
  sso71-postgresql.json
do
  oc create -n openshift -f \
  https://raw.githubusercontent.com/jboss-openshift/application-templates/ose-v1.3.7/sso/${template}
done
oc -n openshift import-image redhat-sso71-openshift


