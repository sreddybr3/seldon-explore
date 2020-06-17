# seldon-explore
explore seldon

## local prep:

### setup

docker run -it --rm --entrypoint=/bin/bash tensorflow/serving:1.15.0

docker build -t sreddybr3/tfs-prebaked:0.0.3 .

docker push sreddybr3/tfs-prebaked:0.0.3

docker run -it --rm --entrypoint=/bin/bash sreddybr3/tfs-prebaked:0.0.3

docker run -p 8501:8501 -it --rm sreddybr3/tfs-prebaked:0.0.3

### Test:

curl -d '{"instances": [1.0, 2.0, 5.0]}' \
    -X POST http://localhost:8501/v1/models/half-plus-two:predict

curl -d '{"instances": [1.0, 2.0, 5.0]}' \
    -X POST http://localhost:8501/v1/models/half-plus-three:predict


## seldon: 

kubectl delete -f seldon/seldon-tfs-multimodel.yaml

kubectl apply -f seldon/seldon-tfs-multimodel.yaml

kubectl rollout status deploy/$(kubectl get deploy -l seldon-deployment-id=rest-tfserving \
                                 -o jsonpath='{.items[0].metadata.name}')

kubectl get sdep rest-tfserving -o yaml


kubectl port-forward $(kubectl get pods -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].metadata.name}') -n istio-system 8003:80

kubectl logs -f rest-tfserving-model-0-half-plus-two-558bb54b7b-rfsv2 -c half-plus-two

curl -v -d '{"instances": [1.0, 2.0, 5.0]}' \\n   -X POST http://localhost:8003/seldon/default/rest-tfserving/v1/models/half-plus-two/:predict \\n   -H "Content-Type: application/json"

curl -v -d '{"instances": [1.0, 2.0, 5.0]}' \\n   -X POST http://localhost:8003/seldon/default/rest-tfserving-scale/v1/models/half-plus-two/:predict \\n   -H "Content-Type: application/json"


seldon domain model reference:
https://docs.seldon.io/projects/seldon-core/en/v1.1.0/reference/seldon-deployment.html

## obesrvations

### TCO and perf considerations-

Seldon runs one model in one container. this is the biggest drawback to integrate with ml-serving; also their flask based microservice is not preferable

### useful coponents a'la carte option

- autoscaling - works with minRepliacs and maxRepliaces and cpu memory based (created K8S HPA resource)
- AB testing
- shadow
- explainer
- drift

I think above can be easily covered as part of basic knative-serving or KFServing
