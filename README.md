<!-- # Graduation Project - Cloud DevOps Pipeline Overview
<br>

## Project Description

This project implements a fully automated DevOps pipeline for deploying a cloud-native application on AWS using industry-standard tools like Terraform, Docker, Kubernetes, Jenkins, Ansible, and ArgoCD. It demonstrates real-world DevOps workflows including Infrastructure as Code (IaC), containerization, CI/CD, configuration management, and GitOps.
<br>

## High-Level Architecture

 <!-- ![[Project Architecture]](screenshots/Architecture.jpg) -->
<br>

## Project Structure

```bash
.
├── terraform/               # Terraform Infrastructure
│   ├── main.tf
│   ├── bootstrap_backend.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── eks/
│       ├── network/
│       └── server/
├── ansible/                 # Playbooks and Roles for Jenkins and EC2
│   ├── playbook.yml
│   ├── agent-playbook.yml
│   ├── aws_ec2.yaml         # Dynamic Inventory
│   └── roles/
│       ├── common/
│       └── jenkins/
│
├── CI-CD/
│   ├── Jenkinsfile          # CI Pipeline
│   └── vars/                # Shared Library
│   └── K8s/                 # K8s manifests (Deployment, Service)
│
├── Dockerfile               # Dockerfile للتطبيق
├── app.py                   # كود التطبيق (Flask)
├── requirements.txt
│
└──argocd/
    └── app-argocd.yaml      # ArgoCD Application config
```
<br>

## What's Included?

* **Source Code**:  
  [FinalProject](https://github.com/Shahdhussien/CloudDevOpsProject)
<br>

## 1. Containerization with Docker

### Task:
Build a Docker image for a Python Flask web application using a Dockerfile.

### Tools Used:
* Docker  
* Python Flask  

### Implementation:
> Dockerfile: [./Dockerfile](./Dockerfile)  
> Application Files: [app.py](./app.py), [requirements.txt](./requirements.txt)

The [Dockerfile](./Dockerfile) installs the required Python packages listed in `requirements.txt` and launches the Flask application automatically.

##### To build the image locally, run:

```bash
docker build -t flask-final-app:latest .
```

```bash
flask-final-app                           latest         51e7f2006825   43 hours ago    464MB
```

### Outcome:
A lightweight and reproducible Docker image that can be pushed to Docker Hub and deployed into Kubernetes.


<br>

## 2. Container Orchestration with Kubernetes

### Task:
Deploy the containerized application into a Kubernetes cluster.

### Steps:

> * Create a namespace named `iVolve`  
> * Define a `Deployment` resource to manage application pods  
> * Create a `NodePort` `Service` to expose the application

### 📄 Kubernetes Manifests:
* [Namespace YAML](./CI-CD/K8s/namespace.yaml)  
* [Deployment YAML](./CI-CD/K8s/deployment.yaml)  
* [Service YAML](./CI-CD/K8s/service.yaml)

To apply the manifests:

```bash
kubectl apply -f CI-CD/K8s/
```
To Verify

```bash
kubectl get all -n ivolve
```
Output:
```bash
NAME                                           READY   STATUS             RESTARTS        AGE
pod/finalproject-deployment-68c45b459f-rpn5j   1/1     Running            0               4m18s

NAME                           TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/finalproject-service   NodePort   10.110.103.248   <none>        80:30007/TCP   43h

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/finalproject-deployment   1/1     1            1           43h
```

![k8s](screanshots/k8s.jpg)

### Outcome:
Declarative YAML manifests ready for automated deployment via ArgoCD.

<br>


## 3. Infrastructure Provisioning with Terraform

### Task:
Provision the entire cloud infrastructure on AWS using Terraform modules.

### Modules:
* `network`: VPC, public subnet, Internet Gateway, NACL  
* `server`: EC2 instances for Jenkins, security groups, CloudWatch  
* `eks`: Amazon EKS cluster (optional but supported)

### Backend:
Remote state configured with S3 and DynamoDB for stability, state locking, and team collaboration.

### Files:
* [Main Terraform Config](./terraform/main.tf)  
* [Variables](./terraform/variables.tf)  
* [Backend Setup](./terraform/bootstrap_backend.tf)  
* [Modules](./terraform/modules/)

### Apply Infrastructure:
From the `terraform/` directory:

```bash
terraform init
terraform apply
```
![Terraform Apply Screenshot](screanshots/terraform.jpg)

### Outcome:
Reusable, modular infrastructure code for consistent environment creation. no imogies

<br>


## 4. Configuration Management with Ansible

### Task:
- Automatically configure EC2 instances to be Jenkins-ready upon launch using Ansible.
- Automatically configure Jenkins Agent using Ansible.

### Roles:
* `common`: Installs Git, Docker, and Java  
* `jenkins`: Installs and configures Jenkins  

### Dynamic Inventory:
EC2 instances are discovered automatically using AWS EC2 tags via `aws_ec2.yaml`.

### Files:
* [Playbook - Jenkins Master](./ansible/playbook.yml)  
* [Playbook - Jenkins Agent](./ansible/agent-playbook.yml)  
* [Dynamic Inventory Config](./ansible/aws_ec2.yaml)  
* [Roles](./ansible/roles/)

### Run Playbooks:

```bash
ansible-playbook -i aws_ec2.yaml playbook.yml         # Configures Jenkins Master
ansible-playbook -i aws_ec2.yaml agent-playbook.yml   # Configures Jenkins Agent
```
![Ansible Agent Screenshot](screanshots/ansible-agent.jpg)
![Ansible Master Screenshot](screanshots/ansible-master.jpg)



<br>


## 5. Continuous Integration with Jenkins

### Task:
Implement a CI pipeline using Jenkins to automate the build, image management, and manifest update process.  
The pipeline uses a custom Shared Library and is executed using a Jenkins Master–Agent setup.

### Pipeline Stages:
1. Build Docker image  
2. Scan image (optional security stage)  
3. Push to Docker Hub  
4. Delete local image  
5. Update Kubernetes manifests  
6. Push updated manifests to Git (triggers ArgoCD)

### Architecture:
The Jenkins environment consists of:
- One EC2 instance running the Jenkins **Master**
- One EC2 instance as a **Build Agent**, connected via SSH

### Files:
* [Jenkinsfile](https://github.com/Shahdhussien/shared-library-repo-/blob/main/Jenkinsfile)  
* [Shared Library Functions](https://github.com/Shahdhussien/shared-library-repo-/tree/main/vars)

### Execution:
The pipeline runs automatically on code push, or manually from Jenkins.

### Screenshots:
- Jenkins Pipeline Execution  
  ![Jenkins Pipeline](screanshots/jenkins-pipeline1.jpg)

- [pipeline File](Terraformpipeline.txt)    


### Outcome:
A fully automated and scalable CI pipeline built on Jenkins.  
The shared library approach promotes reusability and consistency across different services or environments.

<br>


## 6. Continuous Deployment with ArgoCD (GitOps)

### Task:
Configure ArgoCD to automatically monitor the Git repository for manifest changes and synchronize them with the Kubernetes cluster.

### How It Works:
* ArgoCD continuously watches the Git repository for changes.
* Any updates to Kubernetes manifests (e.g., via Jenkins pipeline) are automatically detected.
* ArgoCD syncs those changes into the cluster in real-time.

### File:
* [ArgoCD Application Config](https://github.com/Shahdhussien/shared-library-repo-/blob/main/app-argocd.yaml)

### Apply the Application:
```bash
kubectl apply -f argocd/app-argocd.yaml
```
![ArcoCD Application](screanshots/arcocd.jpg)

### Outcome:
Truly GitOps-enabled deployment — every change in Git reflects in production.

<br>

## Technologies Used

- Infrastructure: Terraform (modular setup, remote backend using S3 & DynamoDB)
- Provisioning: Ansible (with roles & dynamic inventory for EC2 auto-discovery)
- CI/CD: Jenkins (Master–Agent architecture) with Groovy Shared Library
- Containerization: Docker (Flask app image)
- Orchestration: Kubernetes (local or on EKS)
- Deployment: ArgoCD (GitOps-based continuous deployment)
- Cloud Platform: AWS (EC2, S3, IAM, CloudWatch)


<br>

# 👩‍💻 Author

### Shahd Hussein

### DevOps Engineer  

### • [LinkedIn](https://www.linkedin.com/)



 -->

# 🎓 Graduation Project - Cloud DevOps Pipeline Overview

## 📌 Project Description

This project implements a fully automated DevOps pipeline for deploying a cloud-native application on AWS using industry-standard tools like **Terraform**, **Docker**, **Kubernetes**, **Jenkins**, **Ansible**, and **ArgoCD**. It demonstrates real-world DevOps workflows including **Infrastructure as Code (IaC)**, **containerization**, **CI/CD**, **configuration management**, and **GitOps**.

---

## 🗺️ High-Level Architecture

<!-- ![[Project Architecture]](screenshots/Architecture.jpg) -->

---

## 📁 Project Structure

```bash
.
├── terraform/               # Terraform Infrastructure
│   ├── main.tf
│   ├── bootstrap_backend.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── eks/
│       ├── network/
│       └── server/
├── ansible/                 # Playbooks and Roles for Jenkins and EC2
│   ├── playbook.yml
│   ├── agent-playbook.yml
│   ├── aws_ec2.yaml         # Dynamic Inventory
│   └── roles/
│       ├── common/
│       └── jenkins/
├── CI-CD/
│   ├── Jenkinsfile          # CI Pipeline
│   └── vars/                # Shared Library
│   └── K8s/                 # K8s manifests (Deployment, Service)
├── Dockerfile               # Dockerfile for the Flask app
├── app.py                   # Flask application code
├── requirements.txt
└── argocd/
    └── app-argocd.yaml      # ArgoCD Application config
```

## ✅ What's Included?

* **Source Code:**
  [FinalProject](https://github.com/Shahdhussien/CloudDevOpsProject)

---

## 🐳 1. Containerization with Docker

### 🔧 Task:

Build a Docker image for a Python Flask web application using a Dockerfile.

### 🔨 Tools Used:

* Docker
* Python Flask

### 📁 Implementation:

> Dockerfile: [./Dockerfile](./Dockerfile)
> Application Files: [app.py](./app.py), [requirements.txt](./requirements.txt)

To build the image locally:

```bash
docker build -t flask-final-app:latest .
```

```bash
flask-final-app   latest   51e7f2006825   43 hours ago   464MB
```

### 🎯 Outcome:

A lightweight and reproducible Docker image ready to be deployed in Kubernetes.

---

## ☸️ 2. Container Orchestration with Kubernetes

### 🔧 Task:

Deploy the containerized application into a Kubernetes cluster.

### 📋 Steps:

* Create a namespace `iVolve`
* Define a `Deployment` for managing pods
* Create a `NodePort Service` to expose the app

### 📄 Kubernetes Manifests:

* [Namespace YAML](./CI-CD/K8s/namespace.yaml)
* [Deployment YAML](./CI-CD/K8s/deployment.yaml)
* [Service YAML](./CI-CD/K8s/service.yaml)

To apply:

```bash
kubectl apply -f CI-CD/K8s/
```

To verify:

```bash
kubectl get all -n ivolve
```

**Output:**

```bash
NAME                                           READY   STATUS    RESTARTS   AGE
pod/finalproject-deployment-68c45b459f-rpn5j   1/1     Running   0          4m

NAME                           TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/finalproject-service   NodePort   10.110.103.248   <none>        80:30007/TCP   43h

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/finalproject-deployment   1/1     1            1           43h
```

![k8s](screenshots/k8s.jpg)

### 🎯 Outcome:

Declarative manifests ready for automated deployment via ArgoCD.

---

## 🏗️ 3. Infrastructure Provisioning with Terraform

### 🔧 Task:

Provision the entire AWS infrastructure using Terraform modules.

### 🧱 Modules:

* `network`: VPC, Subnets, IGW, NACL
* `server`: EC2 for Jenkins, Security Groups, CloudWatch
* `eks`: EKS cluster (optional)

### ☁️ Backend:

Remote backend using **S3** and **DynamoDB** for state management and team collaboration.

### 📁 Files:

* [main.tf](./terraform/main.tf)
* [variables.tf](./terraform/variables.tf)
* [bootstrap\_backend.tf](./terraform/bootstrap_backend.tf)
* [Modules](./terraform/modules/)

To deploy infrastructure:

```bash
terraform init
terraform apply
```

![Terraform](screenshots/terraform.jpg)

### 🎯 Outcome:

Modular and reusable code for consistent and automated environment setup.

---

## 🛠️ 4. Configuration Management with Ansible

### 🔧 Task:

Configure EC2 instances automatically for Jenkins Master and Agent using Ansible.

### 📂 Roles:

* `common`: Git, Docker, Java
* `jenkins`: Jenkins setup (on Master)

### 🧠 Dynamic Inventory:

Auto-discovery of EC2 instances via tags using `aws_ec2.yaml`.

### 📁 Files:

* [Jenkins Master Playbook](./ansible/playbook.yml)
* [Jenkins Agent Playbook](./ansible/agent-playbook.yml)
* [Inventory Config](./ansible/aws_ec2.yaml)

### ▶️ Run:

```bash
ansible-playbook -i aws_ec2.yaml playbook.yml
ansible-playbook -i aws_ec2.yaml agent-playbook.yml
```

![Agent](screenshots/ansible-agent.jpg)
![Master](screenshots/ansible-master.jpg)

### 🎯 Outcome:

Fully configured Jenkins Master and Agent environments without manual setup.

---

## 🔁 5. Continuous Integration with Jenkins

### 🔧 Task:

Create a Jenkins pipeline to automate Docker image builds and K8s manifest updates.

### 🧱 Stages:

1. Build Docker image
2. Scan image (optional)
3. Push to Docker Hub
4. Delete local image
5. Update Kubernetes YAMLs
6. Push updates to Git (ArgoCD sync)

### ⚙️ Architecture:

* Jenkins Master EC2 instance
* Agent EC2 instance (SSH-connected)

### 📁 Files:

* [Jenkinsfile](https://github.com/Shahdhussien/shared-library-repo-/blob/main/Jenkinsfile)
* [Shared Library](https://github.com/Shahdhussien/shared-library-repo-/tree/main/vars)

### 🖥️ Screenshots:

![Pipeline](screenshots/jenkins-pipeline1.jpg)

### 🎯 Outcome:

A modular and scalable CI pipeline integrated with Git and Kubernetes.

---

## 🚀 6. Continuous Deployment with ArgoCD (GitOps)

### 🔧 Task:

Enable GitOps by using ArgoCD to automatically deploy changes pushed to Git.

### ⚙️ How it Works:

* Monitors Git repo for manifest changes
* Syncs changes into the Kubernetes cluster in real-time

### 📁 File:

* [ArgoCD Config](https://github.com/Shahdhussien/shared-library-repo-/blob/main/app-argocd.yaml)

### ▶️ Apply:

```bash
kubectl apply -f argocd/app-argocd.yaml
```

![ArgoCD](screenshots/arcocd.jpg)

### 🎯 Outcome:

Git-driven automated deployment with zero manual syncing.

---

## 🧰 Technologies Used

* **Terraform** – Infrastructure provisioning
* **Ansible** – Configuration management with dynamic inventory
* **Jenkins** – CI (Master/Agent) with Groovy Shared Libraries
* **Docker** – Containerization
* **Kubernetes** – Orchestration (via EKS or local)
* **ArgoCD** – GitOps-based CD
* **AWS** – EC2, S3, IAM, CloudWatch, DynamoDB

---

## 👩‍💻 Author

### Shahd Hussein

**DevOps Engineer**
🔗 [LinkedIn](https://www.linkedin.com/)
