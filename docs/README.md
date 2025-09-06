# Documentation

This directory contains comprehensive documentation and diagram resources for the Boomi Runtime Template.

## 📊 Professional Diagrams

We provide multiple diagram formats to suit different tools and preferences:

### **🎨 Interactive HTML Diagram** (`interactive-diagram.html`)
**Best for**: Presentations, documentation websites, interactive exploration

**Features**:
- Interactive hover effects
- Professional styling with D3.js
- Animated flow arrows
- Environment-specific color coding
- Mobile responsive design
- No dependencies required

**How to use**: 
1. Download the HTML file
2. Open in any modern web browser
3. Use for presentations or embed in websites

---

### **📋 Draw.io Configuration** (`diagram-configurations.json`)
**Best for**: Collaborative editing, customization, enterprise documentation

**Features**:
- Complete component specifications
- Professional color palette
- Detailed positioning and sizing
- Icon and styling definitions
- Connection flow mapping

**How to use**:
1. Go to [app.diagrams.net](https://app.diagrams.net/)
2. File → Import → Select the JSON file
3. Customize and export as needed
4. Save as PNG/SVG/PDF for documentation

---

### **🔧 PlantUML Diagram** (`plantuml-diagram.puml`)
**Best for**: Version control, automation, developer documentation

**Features**:
- Text-based diagram definition
- Professional AWS orange theme
- Detailed component specifications
- Environment-specific styling
- Version controllable source

**How to use**:
1. Copy the `.puml` code
2. Paste into [plantuml.com](http://www.plantuml.com/plantuml/uml/)
3. Or use VS Code PlantUML extension
4. Generate PNG/SVG output

---

### **🎨 SVG Vector Graphic** (`diagram-svg.svg`) 
**Best for**: High-quality printing, presentations, direct embedding

**Features**:
- Scalable vector format
- Professional styling
- Embedded emojis and icons
- Print-ready quality
- Direct HTML embedding

**How to use**:
1. Open SVG file in browser or image editor
2. Embed directly in HTML: `<img src="diagram-svg.svg">`
3. Use in presentations or documentation
4. Convert to PNG/PDF if needed

## 🚀 Quick Start Guide

### Option 1: Interactive Browser Diagram
```bash
# Download and open
curl -O https://raw.githubusercontent.com/your-org/boomi-runtime-template/main/docs/interactive-diagram.html
open interactive-diagram.html
```

### Option 2: Draw.io Import
1. Visit [app.diagrams.net](https://app.diagrams.net/)
2. File → Import from URL
3. Enter: `https://raw.githubusercontent.com/your-org/boomi-runtime-template/main/docs/diagram-configurations.json`
4. Edit and customize as needed

### Option 3: PlantUML Online
1. Visit [plantuml.com](http://www.plantuml.com/plantuml/uml/)
2. Copy content from `plantuml-diagram.puml`
3. Paste and generate diagram

### Option 4: Direct SVG Embedding
```html
<img src="docs/diagram-svg.svg" alt="Boomi Runtime Architecture" style="width: 100%; max-width: 1400px;">
```

## 📋 File Overview

| File | Format | Best For | Features |
|------|--------|----------|----------|
| `interactive-diagram.html` | HTML/D3.js | Presentations, Interactive | Hover effects, animations, responsive |
| `diagram-configurations.json` | JSON | Draw.io, Customization | Complete specs, collaborative editing |
| `plantuml-diagram.puml` | PlantUML | Automation, Version Control | Text-based, CI/CD friendly |
| `diagram-svg.svg` | SVG | High-quality output | Scalable, print-ready |
| `deployment-guide.md` | Markdown | Step-by-step instructions | Detailed deployment guide |

## 🎨 Customization

All diagrams follow a consistent color scheme:

| Environment | Background | Border | Usage |
|-------------|------------|--------|-------|
| Development | `#e8f5e8` | `#4caf50` | Dev environment resources |
| Staging | `#fff3e0` | `#ff9800` | Staging environment resources |
| Production | `#ffebee` | `#f44336` | Production environment resources |
| CI/CD | `#f3e5f5` | `#9c27b0` | Pipeline and automation |
| External | `#fffde7` | `#ffc107` | External integrations |
| Configuration | `#e0f2f1` | `#009688` | Config management |

## 🛠️ Tools and Compatibility

### Supported Diagram Tools
- ✅ **Draw.io/Diagrams.net** - Direct JSON import
- ✅ **PlantUML** - Text-based source
- ✅ **Lucidchart** - SVG import or manual recreation
- ✅ **Visio** - SVG import or manual recreation
- ✅ **Miro/Mural** - SVG/PNG import
- ✅ **Confluence** - Draw.io macro or SVG embedding
- ✅ **Notion** - SVG/PNG embedding
- ✅ **Web browsers** - Direct HTML viewing

### Export Formats Available
- **Interactive**: HTML (self-contained)
- **Vector**: SVG, PDF (via draw.io/PlantUML)
- **Raster**: PNG, JPG (via draw.io/PlantUML)
- **Print**: High-resolution PDF/PNG

## 🤝 Contributing

To update or improve the diagrams:

1. **Interactive HTML**: Edit `interactive-diagram.html` D3.js code
2. **Draw.io**: Import JSON, modify, export updated JSON
3. **PlantUML**: Edit `.puml` text file
4. **SVG**: Edit with vector graphics editor

Keep all formats synchronized when making changes to ensure consistency across documentation.

---

*For additional questions or support with the diagrams, please refer to the main README.md or create an issue in the repository.*
