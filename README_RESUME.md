# Resume - Nagadev Vishwanath Janganure

Professional resume deployed on Render with Docker containerization.

## 🚀 Live Demo

**Live URL:** [Your Render URL here]

## 📋 About

This is a professional timeline-style resume showcasing 15+ years of IT experience with expertise in:
- AWS Cloud Operations
- Kubernetes & Container Orchestration
- Infrastructure as Code (Terraform, CloudFormation)
- CI/CD Pipelines
- SRE & DevOps Practices

## 🛠️ Technologies

- **Frontend:** HTML5, CSS3, JavaScript
- **Web Server:** Nginx
- **Containerization:** Docker/Podman
- **Hosting:** Render (Free Tier)
- **CI/CD:** GitHub → Render Auto-Deploy

## 📁 Project Structure

```
.
├── index.html              # Main resume HTML file
├── Dockerfile.alternative  # Docker configuration (Ubuntu base)
├── nginx.conf              # Nginx web server configuration
├── render.yaml             # Render deployment configuration
├── deploy-render.sh        # Deployment script
└── README_RESUME.md        # This file
```

## 🚀 Deployment

### Deployed on Render

- **Platform:** Render (Free Tier)
- **Container:** Docker
- **Auto-Deploy:** Enabled (GitHub integration)
- **HTTPS:** Automatic SSL certificate
- **URL:** https://your-app.onrender.com

### Local Development

```bash
# Build image
podman build -f Dockerfile.alternative -t resume-app .

# Run locally
podman run -d -p 8080:80 --name resume-app resume-app:latest

# Open in browser
open http://localhost:8080
```

## 📦 Features

- ✅ Timeline-style resume layout
- ✅ Responsive design (mobile-friendly)
- ✅ Print-friendly (light green background, black borders)
- ✅ Professional styling
- ✅ Fast loading (optimized)
- ✅ HTTPS enabled
- ✅ Auto-deployment from GitHub

## 🔧 Setup Instructions

1. **Clone repository:**
   ```bash
   git clone YOUR_REPO_URL
   cd Testingrandom
   ```

2. **Deploy to Render:**
   - Push to GitHub
   - Connect GitHub repo to Render
   - Render auto-detects Dockerfile
   - Automatic deployment

3. **Or use deployment script:**
   ```bash
   ./deploy-render.sh
   ```

## 📝 Customization

- Edit `index.html` to update resume content
- Modify `styles.css` (embedded in HTML) for styling
- Update `nginx.conf` for server configuration
- Adjust `Dockerfile.alternative` for container setup

## 🔗 Links

- **Live Resume:** [Render URL]
- **GitHub Repository:** [Your GitHub URL]
- **LinkedIn:** https://www.linkedin.com/in/nj9986890806

## 📊 Performance

- **Load Time:** < 2 seconds
- **Lighthouse Score:** 90+ (target)
- **Mobile Friendly:** Yes
- **Print Optimized:** Yes

## 🎯 Future Enhancements

- [ ] Add analytics (Google Analytics)
- [ ] Custom domain
- [ ] SEO optimization
- [ ] Contact form integration
- [ ] Multi-language support

## 📄 License

Personal project - All rights reserved

## 👤 Author

**Nagadev Vishwanath Janganure**
- Email: pnj9986@gmail.com
- Phone: +91 9986890806
- LinkedIn: https://www.linkedin.com/in/nj9986890806

---

**Last Updated:** December 2024
**Deployment Status:** ✅ Live on Render

