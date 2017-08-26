# $1 = target subdomain
#yum -y install java-1.8.0-openjdk
#yum -y install pwgen
#export DOMAIN=rsc7.com
export DOMAIN=52.160.91.126.nip.io
export HOSTNAME_HTTPS="login.$DOMAIN"
export HOSTNAME_HTTP="nlogin.$DOMAIN"
rm -r -f ${1}idm
mkdir ${1}idm
cd ${1}idm
oc delete serviceaccount sso-service-account
oc delete secret sso-app-secret
oc delete project ${1}idm
sleep 120
#pwgen --symbols --numerals 8 1 > .password
pwgen -A 5 1 --symbols > .projectid
echo 'my-password' > .password
export idmpassword=$(cat .password)
export projectid=$(cat .projectid)
oc new-project ${1}idm
oc create serviceaccount sso-service-account
oadm policy add-role-to-user admin glennswest
oc policy add-role-to-user view system:serviceaccount:${1}idm:sso-service-account
oc policy add-role-to-user view system:serviceaccount:${1}idm:sso-service-account
echo "Stage 1 - REQ"
openssl req -new  -passout pass:$idmpassword -newkey rsa:4096 -x509 -keyout xpaas.key -out xpaas.crt -days 365 -subj "/CN=xpaas-sso.ca"
echo "Stage 2 - GENKEYPAIR"
keytool  -genkeypair -deststorepass $idmpassword -storepass $idmpassword -keypass $idmpassword -keyalg RSA -keysize 2048 -dname "CN=${HOSTNAME_HTTPS}" -alias sso-https-key -keystore sso-https.jks
echo "Stage 3 - CERTREQ"
keytool  -deststorepass $idmpassword -storepass $idmpassword -keypass $idmpassword -certreq -keyalg rsa -alias sso-https-key -keystore sso-https.jks -file sso.csr
echo "Stage 4 - X509"
openssl x509 -req -passin pass:$idmpassword -CA xpaas.crt -CAkey xpaas.key -in sso.csr -out sso.crt -days 365 -CAcreateserial
echo "Stage 5 - IMPORT CRT"
keytool  -noprompt -deststorepass $idmpassword -import -file xpaas.crt  -storepass $idmpassword -keypass $idmpassword -alias xpaas.ca -keystore sso-https.jks
echo "Stage 6 - IMPORT SSO"
keytool  -noprompt -deststorepass $idmpassword -storepass $idmpassword -keypass $idmpassword  -import -file sso.crt -alias sso-https-key -keystore sso-https.jks
echo "Stage 7 - IMPORT XPAAS"
keytool -noprompt -deststorepass $idmpassword -storepass $idmpassword -keypass $idmpassword   -import -file xpaas.crt -alias xpaas.ca -keystore truststore.jks
echo "Stage 8 - GENSECKEY"
keytool  -deststorepass $idmpassword -storepass $idmpassword -keypass $idmpassword -genseckey -alias jgroups -storetype JCEKS -keystore jgroups.jceks
echo "Stage 9 - OCCREATE SECRET"
oc create secret generic sso-app-secret --from-file=jgroups.jceks --from-file=sso-https.jks --from-file=truststore.jks
echo "Stage 10 - OCCREATE SECRET ADD"
oc secret add sa/sso-service-account secret/sso-app-secret
echo "Stage 11 - Create App"
echo ${1}
echo $idmpassword
echo $projectid
cat << EOF > sso.params
HOSTNAME_HTTPS="login.$DOMAIN"
HOSTNAME_HTTP="nlogin.$DOMAIN"
APPLICATION_NAME="sso"
HTTPS_KEYSTORE="sso-https.jks"
HTTPS_PASSWORD="$idmpassword"
HTTPS_SECRET="sso-app-secret"
JGROUPS_ENCRYPT_KEYSTORE="jgroups.jceks"
JGROUPS_ENCRYPT_PASSWORD="$idmpassword"
JGROUPS_ENCRYPT_SECRET="sso-app-secret"
SERVICE_ACCOUNT_NAME=sso-service-account
SSO_REALM=cloud
SSO_SERVICE_USERNAME=sso-mgmtuser
SSO_SERVICE_PASSWORD=mgmt-password
SSO_ADMIN_USERNAME=admin
SSO_ADMIN_PASSWORD=adm-password
SSO_TRUSTSTORE=truststore.jks
SSO_TRUSTSTORE_PASSWORD=$idmpassword
EOF
oc new-app sso71-postgresql --param-file sso.params -l app=sso71-postgresql -l application=sso -l template=sso71-https 
