# 🚀 SLAMIT - System Enumeration and File Exfiltration Tool

<div align="center">

![SLAMIT Logo](https://img.shields.io/badge/SLAMIT-Pentest%20Tool-blue?style=for-the-badge&logo=terminal)
![Version](https://img.shields.io/badge/Version-3.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-Educational%20Use%20Only-red?style=for-the-badge)

**Professional System Enumeration and File Exfiltration Suite**

*Comprehensive tools for authorized penetration testing and security assessments*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Project Structure](#-project-structure)
- [Core Scripts](#-core-scripts)
- [Upload Scripts](#-upload-scripts)
- [Server Component](#-server-component)
- [Installation](#-installation)
- [Usage Guide](#-usage-guide)
- [Configuration](#-configuration)
- [Security Features](#-security-features)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

SLAMIT is a comprehensive suite of tools designed for system enumeration and file exfiltration during authorized penetration testing engagements. The project provides both Linux/Unix and Windows versions, ensuring cross-platform compatibility for security professionals.

### 🎯 Key Features

- **🔍 Comprehensive Enumeration**: Automatic and manual system reconnaissance
- **📁 Intelligent File Discovery**: Smart detection of interesting file types
- **🚀 Efficient File Upload**: Organized file collection and exfiltration
- **🛡️ Security Focused**: Built-in safety measures and path validation
- **🎨 Professional UI**: Beautiful, centered headers and progress tracking
- **📊 Detailed Reporting**: Comprehensive upload summaries and statistics

---

## 📁 Project Structure

```
slamit/
├── 🐧 Linux/Unix Scripts
│   ├── slamit.sh              # Main enumeration script
│   └── custom_upload.sh       # Standalone upload tool
├── 🪟 Windows Scripts  
│   ├── slamit.ps1             # Main enumeration script
│   └── custom_upload.ps1      # Standalone upload tool
├── 🐍 Server Component
│   └── http_upload_srv.py     # HTTP upload server
├── 📚 Documentation
│   └── README.md              # This file
└── 🔧 Configuration Files
    └── (User-defined settings)
```

---

## 🐧 Core Scripts

### `slamit.sh` - Linux/Unix Main Script

**Purpose**: Comprehensive system enumeration and file exfiltration for Linux/Unix systems.

**Features**:
- 🚀 **Automatic Enumeration**: Runs linpeas and unix-privesc-check
- 📝 **Manual Enumeration**: Executes predefined reconnaissance commands
- 🔍 **File Discovery**: Searches for interesting files across the system
- 📤 **File Upload**: Uploads discovered files to the HTTP server
- 🎯 **Progress Tracking**: Real-time progress indicators and file counts
- 🛡️ **Security**: Path validation and safe file handling

**Usage**:
```bash
./slamit.sh
```

**Output Files**:
- `slamit-sh-out.txt` - Manual enumeration results
- `linpeas-out.txt` - LinPEAS enumeration output
- `unix-privesc-check-out.txt` - Privilege escalation check results

---

### `slamit.ps1` - Windows Main Script

**Purpose**: Comprehensive system enumeration and file exfiltration for Windows systems.

**Features**:
- 🛠️ **Tool Downloads**: Automatically downloads essential pentest tools
- 🏢 **Active Directory**: SharpHound enumeration for AD environments
- 🔍 **System Enumeration**: WinPEAS for Windows privilege escalation
- 📁 **File Discovery**: Intelligent file collection from user directories
- 📤 **File Upload**: Organized upload to HTTP server
- 🎨 **Professional UI**: Color-coded output and centered headers

**Usage**:
```powershell
.\slamit.ps1
```

**Downloaded Tools**:
- Mimikatz, SharpHound, WinPEAS, PowerView, PowerUp
- PsExec, Rubeus, Chisel, and more

---

## 📤 Upload Scripts

### `custom_upload.sh` - Linux/Unix Standalone Upload

**Purpose**: Lightweight file upload tool for Linux/Unix systems without full enumeration.

**Features**:
- 📁 **Current Directory Focus**: Uploads files from current working directory
- 🔒 **Security**: Built-in curl/wget detection and validation
- 📊 **Progress Tracking**: File counting and upload progress
- 🎯 **Standalone**: Can be run independently of main scripts

**Usage**:
```bash
./custom_upload.sh
```

---

### `custom_upload.ps1` - Windows Standalone Upload

**Purpose**: Lightweight file upload tool for Windows systems without full enumeration.

**Features**:
- 📁 **Current Directory Focus**: Uploads files from current working directory
- 🎨 **Professional UI**: Color-coded output and centered headers
- 📊 **Progress Tracking**: File counting and upload progress
- 🎯 **Standalone**: Can be run independently of main scripts

**Usage**:
```powershell
.\custom_upload.ps1
```

---

## 🐍 Server Component

### `http_upload_srv.py` - HTTP Upload Server

**Purpose**: Centralized file collection server that receives and organizes uploaded files.

**Features**:
- 🌐 **HTTP Server**: Accepts file uploads via POST requests
- 📁 **Directory Management**: Automatically creates organized folder structures
- 🛡️ **Security**: Path traversal protection and content validation
- 📊 **File Serving**: Serves static files via GET requests
- ⚙️ **Configurable**: Customizable port and base directory

**Usage**:
```bash
# Basic usage (port 7979, current directory)
python3 http_upload_srv.py

# Custom port and directory
python3 http_upload_srv.py -p 80 -d /var/www

# Help
python3 http_upload_srv.py --help
```

**Security Features**:
- Base directory restriction (`/home/kali/projects`)
- Content-Type validation
- Path traversal protection
- Safe file handling

---

## 🚀 Installation

### Prerequisites

- **Linux/Unix**: bash, curl/wget, find, nc (netcat)
- **Windows**: PowerShell 5.0+, .NET Framework
- **Server**: Python 3.6+

### Quick Start

1. **Clone/Download** the SLAMIT project
2. **Make scripts executable** (Linux/Unix):
   ```bash
   chmod +x *.sh
   ```
3. **Start the upload server**:
   ```bash
   python3 http_upload_srv.py
   ```
4. **Run enumeration scripts** on target systems

---

## 📖 Usage Guide

### 🎯 Workflow Overview

1. **Start Server**: Launch `http_upload_srv.py` on your attack machine
2. **Deploy Scripts**: Copy appropriate scripts to target systems
3. **Run Enumeration**: Execute main scripts for comprehensive assessment
4. **Collect Results**: Files are automatically uploaded and organized

### 🔧 Configuration

Edit the configuration variables at the top of each script:

```bash
# Server Configuration
URI="192.168.45.216"
PORT=80
URL="http://$URI:$PORT"

# Directory Structure
BASE_DIRECTORY="/home/kali/projects"
MAIN_DIRECTORY="challenges"
PROJECT_DIRECTORY="oscp_b"
HOSTNAME="Berlin"
```

### 📁 File Organization

Files are automatically organized into a structured hierarchy:
```
/home/kali/projects/
└── challenges/
    └── oscp_b/
        └── Berlin/
            ├── proof.txt
            ├── local.txt
            ├── linpeas-out.txt
            └── [other discovered files]
```

---

## 🛡️ Security Features

### Built-in Protections

- **Path Validation**: Prevents directory traversal attacks
- **Content Validation**: Ensures proper file upload formats
- **Base Directory Restriction**: Limits upload locations
- **Safe File Handling**: Proper encoding and error handling

### Best Practices

- **Authorization**: Only use on systems you own or have permission to test
- **Network Isolation**: Run in controlled environments
- **File Validation**: Review uploaded files before analysis
- **Access Control**: Restrict server access to authorized personnel

---

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Duplicate Files** | Ensure only one script runs at a time |
| **Permission Errors** | Run with appropriate privileges |
| **Network Issues** | Verify server configuration and connectivity |
| **Missing Tools** | Install required dependencies (curl, PowerShell) |

### Debug Mode

Enable verbose logging by modifying script variables:
```bash
# Add debug output
DEBUG=1
```

### Log Files

Check script output for detailed progress and error information:
- Upload progress indicators
- File count summaries
- Error messages and status codes

---

## 🤝 Contributing

### Development Guidelines

1. **Code Style**: Follow existing formatting and commenting standards
2. **Testing**: Test changes on multiple platforms
3. **Documentation**: Update README and inline comments
4. **Security**: Maintain security features and add new protections

### Feature Requests

- **Enumeration Tools**: Suggest new reconnaissance commands
- **File Types**: Propose additional interesting file extensions
- **UI Improvements**: Ideas for better user experience
- **Security Enhancements**: Additional safety measures

---

## 📄 License

**⚠️ IMPORTANT**: This tool is provided for **educational and authorized testing purposes only**.

### Usage Restrictions

- ✅ **Authorized**: Penetration testing with explicit permission
- ✅ **Educational**: Learning and research purposes
- ✅ **Research**: Security assessment and improvement
- ❌ **Unauthorized**: Testing systems without permission
- ❌ **Malicious**: Any harmful or illegal activities

### Disclaimer

The authors are not responsible for any misuse of these tools. Users must ensure they have proper authorization before testing any systems.

---

## 🏆 Acknowledgments

- **Security Community**: For inspiration and feedback
- **Tool Developers**: LinPEAS, WinPEAS, SharpHound, and others
- **Testing Teams**: For real-world validation and improvements

---

<div align="center">

**🚀 SLAMIT - Professional Pentest Tools for Security Professionals**

*Built with ❤️ for the security community*

</div>
