# Test-Task
Test task for dna:micro 

1. Infrastructure Provisioning with Terraform
Using Terraform, I orchestrated the creation of an Amazon Web Services (AWS) Kubernetes Cluster (EKS) to manage the infrastructure. The configuration includes:
VPC: Created using Terraform to ensure networking is properly set up for the EKS cluster.
Subnets, Security Groups, and Internet Gateway: To enable proper access and networking capabilities.
- IAM Roles and Policies: Created to manage permissions for the EKS cluster and its nodes.
- EKS Cluster: Provisioned using Terraform and linked to the appropriate VPC and subnets.
- Node Group: Created using Terraform to ensure the Kubernetes cluster has worker nodes to   run applications.

2. Deployment of whoami Docker Image
Successfully deployed at least 3 replicas of the congtaojiang/whoami-nodejs-express Docker image to the EKS cluster using Kubernetes manifests.
These replicas run within the cluster, and Kubernetes manages their lifecycle.

3. Load Balancing Demonstration
Created a Kubernetes Service of type LoadBalancer to expose the application externally.
The service distributes traffic across the 3 replicas of the whoami-nodejs-express application.
When accessed via the LoadBalancer, each request is routed to different instances, demonstrating load balancing functionality.

4. Canary Deployment
Deployed a separate service using the emilevauge/whoami Docker image as a canary deployment to test new features or versions without affecting the main deployment.
The canary deployment uses Kubernetes manifests to create a new set of pods and services that coexist with the main deployment, but serve a subset of traffic for testing purposes.

5. CI/CD Pipeline with GitHub Actions
Integrated a CI/CD pipeline using GitHub Actions to automate the deployment process. The pipeline performs the following:
Checkouts Code: Automatically pulls the latest code from the repository.
Kubernetes Deployment: Applies the Kubernetes manifest files (deployment.yaml, service.yaml, canary-deployment.yaml, and canary-service.yaml) to update the cluster.
Verification Step: The pipeline also verifies that the deployments and services are correctly applied by checking replicas and image versions.