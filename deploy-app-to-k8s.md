
# Push image to ACR

```sh
SUB_ENV=Dev
DEFAULT_SUB=$(az account list --query "[?ends_with(name,'-$SUB_ENV')].name" -o tsv)
az account set --subscription $DEFAULT_SUB
REGISTRY_NAME=$(az acr list -o table --query [].name -o tsv)

# az acr login --name $REGISTRY_NAME --expose-token     | jq -r '.accessToken'     | podman login $REGISTRY_NAME.azurecr.io       --username 00000000-0000-0000-0000-000000000000       --password-stdin   

``````

# Deploy Nexus

## Create the namespce

```sh
NAME_SPACE=dso-mvp
kubectl create namespace $NAME_SPACE --dry-run=client -o yaml | kubectl apply -f -
```

## Deploy app-nodejs 

```sh
cat deployment.yaml | sed "s/{{ACR_INSTANCE}}/$REGISTRY_NAME/g" | kubectl apply --namespace $NAME_SPACE -f -
```
## Expose service 

```sh
kubectl apply --namespace $NAME_SPACE -f service.yaml
```

## Get the default password

```sh
POD=$(kubectl get pods -o name -n $NAME_SPACE --no-headers=true)
kubectl exec nexus-$POD -n $NAME_SPACE cat /
```