#!/usr/bin/env python3
"""
===============================================================================
                    HTTP UPLOAD SERVER FOR SLAMIT
===============================================================================

This Python script provides a simple HTTP server that can:
1. Accept file uploads via POST requests with multipart/form-data
2. Serve static files via GET requests
3. Organize uploaded files into specified directory structures
4. Provide basic security by restricting upload paths

DESCRIPTION:
    The server is designed to work with the SLAMIT enumeration and exfiltration
    tools. It receives files uploaded by the SLAMIT scripts and organizes them
    into a structured directory hierarchy based on the target system and project.

FEATURES:
    - Multipart form data file upload support
    - Directory structure creation and management
    - Path validation and security restrictions
    - Static file serving capabilities
    - Configurable port and base directory
    - Automatic directory creation for uploads

SECURITY FEATURES:
    - Path traversal protection via BASE_DIR restriction
    - Content-Type validation for uploads
    - Safe file handling with proper encoding

USAGE:
    python3 http_upload_srv.py [-p PORT] [-d DIRECTORY]
    
    Examples:
        python3 http_upload_srv.py                    # Default port 7979, current dir
        python3 http_upload_srv.py -p 80             # Listen on port 80
        python3 http_upload_srv.py -d /var/www       # Serve from /var/www

AUTHOR: SLAMIT Development Team
VERSION: 2.0
LICENSE: Educational and authorized testing purposes only
===============================================================================
"""

import os
import cgi
import argparse
from http.server import SimpleHTTPRequestHandler, HTTPServer

# Security: Restrict file writes to a base directory to prevent path traversal attacks
# This prevents malicious uploads from writing files outside the intended directory structure
BASE_DIR = os.path.abspath("/home/kali/projects")

class UploadAndServeHandler(SimpleHTTPRequestHandler):
    """
    Custom HTTP request handler that extends SimpleHTTPRequestHandler
    to support both file uploads (POST) and static file serving (GET).
    """
    
    def do_POST(self):
        """
        Handle POST requests for file uploads.
        
        Expected format: multipart/form-data with:
        - 'file': The file to upload
        - 'folder': (optional) Target directory path within BASE_DIR
        
        Security checks:
        - Validates Content-Type is multipart/form-data
        - Restricts upload paths to BASE_DIR
        - Creates directories as needed
        """
        # Validate that the request contains multipart form data
        content_type = self.headers.get('Content-Type')
        if not content_type or 'multipart/form-data' not in content_type:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid Content-Type for upload. Expected multipart/form-data.')
            return

        # Parse the multipart form data
        form = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={
                'REQUEST_METHOD': 'POST',
                'CONTENT_TYPE': content_type
            }
        )

        # Check if a file was actually uploaded
        if 'file' in form and form['file'].filename:
            file_item = form['file']
            filename = os.path.basename(file_item.filename)  # Extract just the filename, not the full path

            # Default save directory is the current working directory
            target_dir = os.getcwd()

            # If a folder parameter is provided, use it as the target directory
            if 'folder' in form and form['folder'].value:
                requested_path = os.path.abspath(form['folder'].value)

                # Security check: Ensure the requested path is within the allowed BASE_DIR
                # This prevents path traversal attacks (e.g., "../../../etc/passwd")
                if not requested_path.startswith(BASE_DIR):
                    self.send_response(403)
                    self.end_headers()
                    self.wfile.write(b'Access denied: Invalid folder path. Path must be within the base directory.')
                    return

                target_dir = requested_path

            # Create the target directory if it doesn't exist
            # This allows the SLAMIT scripts to organize files by project/target
            os.makedirs(target_dir, exist_ok=True)
            save_path = os.path.join(target_dir, filename)

            # Write the uploaded file to disk
            with open(save_path, 'wb') as f:
                f.write(file_item.file.read())

            # Send success response
            self.send_response(200)
            self.end_headers()
            response_message = f'File "{filename}" uploaded to "{target_dir}" successfully.\n\n'
            self.wfile.write(response_message.encode('utf-8'))
        else:
            # No file was uploaded
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'No file uploaded. Please provide a file in the request.')

    def do_GET(self):
        """
        Handle GET requests for static file serving.
        Inherits the default behavior from SimpleHTTPRequestHandler.
        """
        return super().do_GET()

def run(port, directory):
    """
    Start the HTTP server on the specified port and directory.
    
    Args:
        port (int): Port number to listen on
        directory (str): Directory to serve files from and change working directory to
    """
    # Change to the specified directory for serving files
    os.chdir(directory)
    
    # Create and start the HTTP server
    server_address = ('', port)  # Empty string means listen on all available interfaces
    httpd = HTTPServer(server_address, UploadAndServeHandler)
    
    print(f"🚀 HTTP Upload Server Started!")
    print(f"📍 Serving files from: {os.getcwd()}")
    print(f"🌐 Listening on port: {port}")
    print(f"🔒 Base directory restriction: {BASE_DIR}")
    print(f"📁 Uploads will be organized within the base directory structure")
    print(f"⏹️  Press Ctrl+C to stop the server")
    print("=" * 70)
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print(f"\n🛑 Server stopped by user")
        httpd.server_close()

if __name__ == '__main__':
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description="HTTP Upload Server for SLAMIT - File upload and static file serving",
        epilog="Example: python3 http_upload_srv.py -p 80 -d /var/www"
    )
    
    parser.add_argument(
        '-p', '--port', 
        type=int, 
        default=7979, 
        help='Port to listen on (default: 7979)'
    )
    
    parser.add_argument(
        '-d', '--directory', 
        type=str, 
        default=os.getcwd(),
        help='Directory to serve files from (default: current directory)'
    )
    
    args = parser.parse_args()
    
    # Start the server with the provided arguments
    run(args.port, os.path.abspath(args.directory))
