RESULT=`curl --silent --insecure --data "grant_type=password&client_id=admin-cli&username=sso-mgmtuser&password=mgmt-password" https://login.52.160.91.126.nip.io/auth/realms/cloud/protocol/openid-connect/token`
TOKEN=`echo $RESULT | sed 's/.*access_token":"//g' | sed 's/".*//g'`
RESULTX=`curl https://login.52.160.91.126.nip.io/auth/admin/realms/cloud/admin-events -H "Authorization: bearer $TOKEN" --insecure --silent`
echo $RESULTX
RESULTY=`curl https://login.52.160.91.126.nip.io/auth/admin/realms/cloud/clients -H "Authorization: bearer $TOKEN" --insecure --silent`
echo $RESULTY > clients.json

RESULTZ=`curl -X POST -d @ocpclientcreate.json https://login.52.160.91.126.nip.io/auth/admin/realms/cloud/clients-registrations/default -H "[[Authorization: bearer $TOKEN],[Content-Type:application/json]]" --insecure `
echo $RESULTZ
echo $RESULTZ > ocpclient.json



#RESULT=`curl --insecure -H '[["Content-Type","application/json"],["Authorization","Bearer "]]'--data "type=password&client_id=admin-cli&username=sso-mgmtuser&password=mgmt-password" https://login.52.160.91.126.nip.io/auth/realms/cloud/protocol/openid-connect/token`
# "Create Client":
# "method":"POST","url":"<URL>:<PORT>/auth/admin/realms/<REALM>/clients"
# "body":
# "{
# "id":"3",
# "clientId":"testclient-3",
# "name": "testclient-3",
# "description": "TESTCLIENT-3",
# "enabled": true,
# "redirectUris":[ "\\" ],
# "publicClient": true
# }"
# "headers":
# [["Content-Type","application/json"],
# ["Authorization","Bearer <ACCESS_TOKEN>]]
