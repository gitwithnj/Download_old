// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Save editable contact information to localStorage
function saveContactInfo() {
    const editableFields = document.querySelectorAll('.editable');
    const contactData = {};
    
    editableFields.forEach(field => {
        const key = field.getAttribute('data-key');
        contactData[key] = field.textContent.trim();
    });
    
    localStorage.setItem('contactInfo', JSON.stringify(contactData));
    showSaveIndicator();
}

// Load saved contact information from localStorage
function loadContactInfo() {
    const savedData = localStorage.getItem('contactInfo');
    if (savedData) {
        try {
            const contactData = JSON.parse(savedData);
            Object.keys(contactData).forEach(key => {
                const field = document.querySelector(`[data-key="${key}"]`);
                if (field && contactData[key]) {
                    field.textContent = contactData[key];
                }
            });
        } catch (e) {
            console.error('Error loading saved contact info:', e);
        }
    }
}

// Show save indicator
function showSaveIndicator() {
    let indicator = document.querySelector('.save-indicator');
    if (!indicator) {
        indicator = document.createElement('div');
        indicator.className = 'save-indicator';
        indicator.textContent = '✓ Contact information saved!';
        document.body.appendChild(indicator);
    }
    
    indicator.classList.add('show');
    setTimeout(() => {
        indicator.classList.remove('show');
    }, 2000);
}

// Random interior design and wooden furniture images from Unsplash
const interiorImages = [
    // Living rooms
    '1586023492125-27b2c045efd7', '1583847268969-b35d41d2e061', '1560448204-e02f841c09f5',
    '1506439773649-6e0eb8cfb237', '1560184897-ae9c0b3b8c0e', '1556911220-bff31c812dba',
    // Bedrooms
    '1631889993951-12f2a97e2c0a', '1522771739844-6a9f6d5b377b', '1556912172-45b7abe8b7e1',
    '1560448204-e02f841c09f5', '1583847268969-b35d41d2e061', '1506439773649-6e0eb8cfb237',
    // Kitchens - Expanded collection
    '1556912172-45b7abe8b7e1', '1556911220-bff31c812dba', '1556911220-e15b29be8c8f',
    '1556909114-f6e7ad7d3136', '1556912173-6719e5279ce6', '1556912171-4c0c4e0e4b0a',
    '1556912173-2b45e6d44d66', '1560184897-ae9c0b3b8c0e', '1586023492125-27b2c045efd7',
    '1506439773649-6e0eb8cfb237', '1631889993951-12f2a97e2c0a', '1556909114-366b1f3e0e5f',
    // Offices
    '1497366216548-37526070297c', '1506439773649-6e0eb8cfb237', '1560184897-ae9c0b3b8c0e',
    '1586023492125-27b2c045efd7', '1556911220-bff31c812dba', '1631889993951-12f2a97e2c0a',
    // Dining rooms
    '1556911220-bff31c812dba', '1586023492125-27b2c045efd7', '1506439773649-6e0eb8cfb237',
    '1560184897-ae9c0b3b8c0e', '1556912172-45b7abe8b7e1', '1631889993951-12f2a97e2c0a',
    // Study rooms
    '1506439773649-6e0eb8cfb237', '1497366216548-37526070297c', '1560184897-ae9c0b3b8c0e',
    '1586023492125-27b2c045efd7', '1556911220-bff31c812dba', '1631889993951-12f2a97e2c0a'
];

// Kitchen-specific images for kitchen gallery items
const kitchenImages = [
    '1556912172-45b7abe8b7e1', '1556911220-e15b29be8c8f', '1556909114-f6e7ad7d3136',
    '1556912173-6719e5279ce6', '1556912171-4c0c4e0e4b0a', '1556912173-2b45e6d44d66',
    '1556909114-366b1f3e0e5f', '1556911220-bff31c812dba', '1556912172-45b7abe8b7e1',
    '1556911220-e15b29be8c8f', '1556909114-f6e7ad7d3136', '1556912173-6719e5279ce6'
];

// Function to get random image URL
function getRandomImage(size = '800x600', useKitchen = false) {
    const imagePool = useKitchen ? kitchenImages : interiorImages;
    const randomIndex = Math.floor(Math.random() * imagePool.length);
    const photoId = imagePool[randomIndex];
    return `https://images.unsplash.com/photo-${photoId}?w=${size.split('x')[0]}&h=${size.split('x')[1]}&fit=crop&auto=format&sig=${Date.now()}`;
}

// Function to randomize all images on the page
function randomizeImages() {
    // Randomize hero background
    const hero = document.querySelector('.hero');
    if (hero) {
        hero.style.backgroundImage = `url('${getRandomImage('1920x1080')}')`;
    }
    
    // Randomize gallery images (preserve kitchen images for kitchen gallery items)
    const galleryImages = document.querySelectorAll('.gallery-image');
    galleryImages.forEach((img, index) => {
        // Check if this is a kitchen gallery item by checking parent's text content
        const galleryItem = img.closest('.gallery-item');
        if (galleryItem) {
            const overlay = galleryItem.querySelector('.gallery-overlay h3');
            const isKitchen = overlay && overlay.textContent.toLowerCase().includes('kitchen');
            if (isKitchen) {
                img.style.backgroundImage = `url('${getRandomImage('800x600', true)}')`;
            } else {
                img.style.backgroundImage = `url('${getRandomImage('800x600')}')`;
            }
        } else {
            img.style.backgroundImage = `url('${getRandomImage('800x600')}')`;
        }
    });
    
    // Randomize furniture card images
    const furnitureCards = document.querySelectorAll('.furniture-card');
    furnitureCards.forEach(card => {
        card.style.backgroundImage = `url('${getRandomImage('600x400')}')`;
    });
}

// Add event listeners to editable fields
document.addEventListener('DOMContentLoaded', function() {
    // Randomize images on page load
    randomizeImages();
    
    // Load saved contact info on page load
    loadContactInfo();
    
    // Add event listeners to all editable fields
    const editableFields = document.querySelectorAll('.editable');
    editableFields.forEach(field => {
        // Save on blur (when user clicks away)
        field.addEventListener('blur', saveContactInfo);
        
        // Save on Enter key (for single-line fields)
        field.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.blur();
            }
        });
        
        // Visual feedback on focus
        field.addEventListener('focus', function() {
            this.style.borderColor = 'var(--primary-wood)';
            this.style.background = 'rgba(139, 111, 71, 0.05)';
        });
        
        // Remove visual feedback on blur
        field.addEventListener('blur', function() {
            this.style.borderColor = '';
            this.style.background = '';
        });
    });
    
    // Handle contact form submission
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get form data
            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                phone: document.getElementById('phone').value,
                message: document.getElementById('message').value
            };
            
            // Show success message
            alert(`Thank you, ${formData.name}! Your message has been received. We'll get back to you soon at ${formData.email}.`);
            
            // Reset form
            contactForm.reset();
        });
    }
    
    // Add scroll effect to navbar
    let lastScroll = 0;
    const navbar = document.querySelector('.navbar');
    
    window.addEventListener('scroll', function() {
        const currentScroll = window.pageYOffset;
        
        if (currentScroll > 100) {
            navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.15)';
        } else {
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        }
        
        lastScroll = currentScroll;
    });
    
    // Add animation on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    document.querySelectorAll('.gallery-item, .furniture-card, .stat, .contact-item').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});

// Export contact info function (for potential future use)
function exportContactInfo() {
    const editableFields = document.querySelectorAll('.editable');
    const contactData = {};
    
    editableFields.forEach(field => {
        const key = field.getAttribute('data-key');
        contactData[key] = field.textContent.trim();
    });
    
    return contactData;
}

// Import contact info function (for potential future use)
function importContactInfo(data) {
    Object.keys(data).forEach(key => {
        const field = document.querySelector(`[data-key="${key}"]`);
        if (field && data[key]) {
            field.textContent = data[key];
        }
    });
    saveContactInfo();
}

