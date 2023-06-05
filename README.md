# About this repo 

This repo includes following solutions
- Terraform module to create an EKS cluster privately
- Terraform module to create RDS postgres privately
- Python app which create, delete, update users details
- Helm chart to deploy this python app
- Terraform modules for helm to deploy application using helm


## How to provision these resources

1. AWS EKS
```console
    cd terraform/resources/vpc

        terraform init 
        terraform plan -var-file="vpc.test.tfvars"
        terraform apply -var-file="vpc.test.tfvars"
```
```console
    cd terraform/resources/eks-cluster

        terraform init 
        terraform plan -var-file="eks.test.tfvars"
        terraform apply -var-file="eks.test.tfvars"    
```

2. AWS RDS
```console
    cd terraform/resources/rds

        terraform init 
        terraform plan -var-file="rds.test.tfvars"
        terraform apply -var-file="rds.test.tfvars"   
```

3. Deploy service using Helm
    1. Build the docker image
    2. Push the image on AWS ECR
    3. Update the values.yaml file at terrafom/module/helm/helm-values/value.yaml

```console
    cd terraform/resources/helm-release
        terraform init 
        terraform plan -var-file="helm.test.tfvars"
        terraform apply -var-file="helm.test.tfvars"  
```

## API's of python app 

1. Create a user using python app 

```console
    curl -X POST -H "Content-Type: application/json" http://python-app.xyz.com/create -d '{
    "username": "xuz",
    "dob": "03/09/1997",
    "email": "asffc@gmail.com"
    }'
```

    Note: you must deploy this service in your k8s cluster as I deployed this privately.
    You can change the domain and other detials from values.yaml at terrafom/module/helm/helm-values/value.yaml

2. Update a user details using python app 

```console
    curl -X GET -H "Content-Type: application/json" http://python-app.xyz.com/users

    [["2234234234","xuz","asffc@gmail.com","03/09/1997"]]

```
```console
    curl -X PUT -H "Content-Type: application/json" http://python-app.xyz.com/create -d '{
    "id" : "2234234234"
    "username": "xuz",
    "dob": "03/09/1997",
    "email": "asffc@gmail.com"
    }'
```

3. Delete user details using python app 
```console
    curl -X DELETE -H "Content-Type: application/json" http://python-app.xyz.com/delete/2234234234
```