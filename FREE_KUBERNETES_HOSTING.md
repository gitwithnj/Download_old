# Free Kubernetes Hosting Platforms

## Free Kubernetes Platforms

### 1. **Oracle Cloud Infrastructure (OCI) - Always Free Tier** ⭐ BEST OPTION

**Free Tier Includes:**
- 2 Always-Free Autonomous Databases
- 2 AMD-based Compute VMs (1/8 OCPU, 1GB RAM each)
- 4 Arm-based Ampere A1 Compute VMs (3,000 OCPU hours and 18,000 GB hours per month)
- 10 TB data transfer per month
- 2 Block Volumes (100 GB total)
- 10 GB Object Storage

**Kubernetes:**
- OKE (Oracle Kubernetes Engine) - Free tier available
- Can run Kubernetes clusters on free VMs

**Sign up:** https://www.oracle.com/cloud/free/

**Setup:**
```bash
# Install k3s (lightweight Kubernetes) on free VM
curl -sfL https://get.k3s.io | sh -

# Or use OKE (Oracle Kubernetes Engine)
```

---

### 2. **Google Cloud Platform (GCP) - Free Tier**

**Free Tier Includes:**
- $300 free credit for 90 days
- Always Free: 1 e2-micro VM per month
- GKE Autopilot: Free control plane (pay only for nodes)

**Kubernetes:**
- Google Kubernetes Engine (GKE) - Free control plane
- Can use free tier VMs as nodes

**Sign up:** https://cloud.google.com/free

**Setup:**
```bash
# Create GKE cluster (uses free tier)
gcloud container clusters create resume-cluster \
  --num-nodes=1 \
  --machine-type=e2-micro \
  --zone=us-central1-a
```

---

### 3. **AWS - Free Tier**

**Free Tier Includes:**
- 750 hours/month of t2.micro or t3.micro instances
- EKS: Free control plane (pay for nodes only)
- Can run small EKS cluster on free tier

**Kubernetes:**
- Amazon EKS - Free control plane
- Use free tier EC2 instances as nodes

**Sign up:** https://aws.amazon.com/free/

**Setup:**
```bash
# Create EKS cluster (control plane free, pay for nodes)
eksctl create cluster --name resume-cluster \
  --nodegroup-name standard-workers \
  --node-type t3.micro \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 1
```

---

### 4. **DigitalOcean - Free Trial**

**Free Trial:**
- $200 credit for 60 days
- Managed Kubernetes available

**Kubernetes:**
- DigitalOcean Kubernetes (DOKS)
- $12/month for smallest cluster after trial

**Sign up:** https://www.digitalocean.com/

---

### 5. **Linode (Akamai) - Free Trial**

**Free Trial:**
- $100 credit for 60 days
- LKE (Linode Kubernetes Engine) available

**Sign up:** https://www.linode.com/

---

## Lightweight Kubernetes (Free on Any VM)

### **k3s** - Lightweight Kubernetes

Works on any Linux VM (including free tier VMs):

```bash
# Install k3s (single command)
curl -sfL https://get.k3s.io | sh -

# Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml

# Use kubectl
kubectl get nodes
```

**Best for:** Running on free tier VMs from OCI, AWS, GCP

---

### **MicroK8s** - Another Lightweight Option

```bash
# Install on Ubuntu
snap install microk8s --classic

# Enable addons
microk8s enable dns ingress

# Use kubectl
microk8s kubectl get nodes
```

---

## Container-Only Platforms (No Kubernetes, but Easier)

### 1. **Railway** ⭐ EASIEST

**Free Tier:**
- $5 free credit monthly
- Deploy containers directly
- Automatic HTTPS
- Custom domains

**Deploy:**
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy
railway init
railway up
```

**Website:** https://railway.app/

---

### 2. **Render**

**Free Tier:**
- Free static sites
- Free web services (with limitations)
- Automatic HTTPS

**Deploy:**
- Connect GitHub repo
- Select Docker
- Auto-deploys

**Website:** https://render.com/

---

### 3. **Fly.io**

**Free Tier:**
- 3 shared-cpu VMs free
- Global edge deployment
- Automatic HTTPS

**Deploy:**
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Deploy
fly launch
fly deploy
```

**Website:** https://fly.io/

---

### 4. **Heroku** (Limited Free Tier)

**Free Tier:**
- Discontinued but still works for existing users
- $5/month minimum now

---

### 5. **Cloud Run (GCP)** ⭐ VERY EASY

**Free Tier:**
- 2 million requests/month free
- 400,000 GB-seconds compute free
- Serverless containers
- Automatic scaling

**Deploy:**
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/resume-app
gcloud run deploy resume-app \
  --image gcr.io/PROJECT_ID/resume-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

**Website:** https://cloud.google.com/run

---

### 6. **AWS App Runner**

**Free Tier:**
- Part of AWS free tier
- Pay only for usage

**Deploy:**
- Connect to ECR
- Configure service
- Auto-deploys

---

## Recommended Solutions (Ranked)

### For Kubernetes (Free):

1. **Oracle Cloud (OCI)** - Best free tier, can run k3s
2. **GCP with GKE** - $300 credit, then free tier
3. **AWS EKS** - Free control plane, use free tier EC2

### For Easy Deployment (No Kubernetes):

1. **Railway** - Easiest, $5/month free credit
2. **Cloud Run (GCP)** - Serverless, generous free tier
3. **Render** - Free tier available
4. **Fly.io** - 3 free VMs

---

## Quick Setup Guides

### Option 1: Railway (Easiest - Recommended)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Deploy
railway up

# Your app will be live at: https://your-app.railway.app
```

### Option 2: Cloud Run (GCP)

```bash
# Set project
gcloud config set project YOUR_PROJECT_ID

# Build and deploy
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/resume-app
gcloud run deploy resume-app \
  --image gcr.io/YOUR_PROJECT_ID/resume-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80

# Get URL
gcloud run services describe resume-app --region us-central1
```

### Option 3: Oracle Cloud + k3s

```bash
# 1. Create free VM on OCI
# 2. SSH into VM
# 3. Install k3s
curl -sfL https://get.k3s.io | sh -

# 4. Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml

# 5. Deploy your app
kubectl apply -f deployment.yaml
```

### Option 4: Render

1. Push code to GitHub
2. Go to https://render.com
3. New → Web Service
4. Connect GitHub repo
5. Select Docker
6. Deploy

---

## Comparison Table

| Platform | Free Tier | Kubernetes | Ease of Use | Best For |
|----------|-----------|------------|-------------|----------|
| **Railway** | $5/month credit | No | ⭐⭐⭐⭐⭐ | Quick deployment |
| **Cloud Run** | 2M requests/month | No | ⭐⭐⭐⭐⭐ | Serverless |
| **Render** | Limited free | No | ⭐⭐⭐⭐ | Simple deployments |
| **Fly.io** | 3 free VMs | No | ⭐⭐⭐⭐ | Global edge |
| **OCI** | Always free VMs | Yes (k3s) | ⭐⭐⭐ | Full control |
| **GCP** | $300 credit | Yes (GKE) | ⭐⭐⭐ | Production |
| **AWS** | Free tier EC2 | Yes (EKS) | ⭐⭐⭐ | Enterprise |

---

## My Recommendation

**For Quick Deployment:**
1. **Railway** - Easiest, $5/month free, automatic HTTPS
2. **Cloud Run** - Generous free tier, serverless

**For Learning Kubernetes:**
1. **Oracle Cloud** - Free VMs, install k3s
2. **GCP** - $300 credit, use GKE

**For Production:**
1. **AWS EKS** - Industry standard
2. **GCP GKE** - Great tooling

---

## Quick Start: Railway (Recommended)

```bash
# 1. Install Railway CLI
npm i -g @railway/cli

# 2. Login
railway login

# 3. Create project
railway init

# 4. Deploy
railway up

# 5. Get URL
railway domain
```

Your app will be live in minutes!

---

## Quick Start: Cloud Run (GCP)

```bash
# 1. Enable APIs
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# 2. Build and deploy
gcloud builds submit --tag gcr.io/YOUR_PROJECT/resume-app
gcloud run deploy resume-app \
  --image gcr.io/YOUR_PROJECT/resume-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# 3. Get URL (shown after deployment)
```

---

## Notes

- **Railway** and **Cloud Run** are the easiest options
- **Oracle Cloud** is best for truly free Kubernetes
- All platforms support Docker images
- Most provide automatic HTTPS
- Custom domains available on most platforms

Choose based on your needs:
- **Quick demo**: Railway or Cloud Run
- **Learning K8s**: Oracle Cloud + k3s
- **Production**: AWS EKS or GCP GKE

