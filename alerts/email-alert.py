#!/usr/bin/env python3

"""
Email Alert Script for DevSecOps Project
Sends Trivy and Falco alerts via email
"""

import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import socket
from dotenv import load_dotenv
import os

load_dotenv()

# Email Configuration - UPDATE THESE VALUES
SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.gmail.com")  # For Gmail
SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
SENDER_EMAIL = os.getenv("SENDER_EMAIL", "YOUR_GMAIL")  # Your email
SENDER_PASSWORD = os.getenv("SENDER_PASSWORD", "YOUR_APP_PASSWORD")  # Gmail App Password
RECIPIENT_EMAIL = os.getenv("RECIPIENT_EMAIL", "RECIPIENT_EMAIL")  # Alert recipient

def send_email(subject, body_html, priority="normal"):
    """Send email alert"""
    
    msg = MIMEMultipart('alternative')
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECIPIENT_EMAIL
    msg['Subject'] = f"[DevSecOps Alert] {subject}"
    
    # Set priority
    if priority == "critical":
        msg['X-Priority'] = '1'
        msg['Importance'] = 'high'
    
    # Add timestamp and hostname
    hostname = socket.gethostname()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create HTML email
    html_body = f"""
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: #2c3e50; color: white; padding: 20px; text-align: center; }}
            .content {{ background: #ecf0f1; padding: 20px; margin: 20px 0; }}
            .critical {{ border-left: 5px solid #e74c3c; }}
            .warning {{ border-left: 5px solid #f39c12; }}
            .info {{ border-left: 5px solid #3498db; }}
            .footer {{ text-align: center; color: #7f8c8d; font-size: 12px; }}
            .metric {{ background: white; padding: 10px; margin: 10px 0; border-radius: 5px; }}
            .metric-value {{ font-size: 24px; font-weight: bold; color: #2c3e50; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🔒 DevSecOps Security Alert</h1>
            </div>
            <div class="content {priority}">
                {body_html}
            </div>
            <div class="footer">
                <p><strong>Host:</strong> {hostname} | <strong>Time:</strong> {timestamp}</p>
                <p>DevSecOps Container Security - Trivy + Falco Monitoring</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    msg.attach(MIMEText(html_body, 'html'))
    
    try:
        # Connect and send
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.send_message(msg)
        server.quit()
        print("✓ Email alert sent successfully")
        return True
    except Exception as e:
        print(f"✗ Failed to send email: {e}")
        return False

def send_trivy_alert(image_name, critical_count, high_count, medium_count=0):
    """Send Trivy scan results alert"""
    
    priority = "critical" if int(critical_count) > 0 else "warning" if int(high_count) > 5 else "info"
    
    body = f"""
    <h2>🔍 Container Vulnerability Scan Results</h2>
    <p><strong>Image:</strong> <code>{image_name}</code></p>
    
    <div class="metric">
        <div>🔴 Critical Vulnerabilities</div>
        <div class="metric-value">{critical_count}</div>
    </div>
    
    <div class="metric">
        <div>🟠 High Vulnerabilities</div>
        <div class="metric-value">{high_count}</div>
    </div>
    
    <div class="metric">
        <div>🟡 Medium Vulnerabilities</div>
        <div class="metric-value">{medium_count}</div>
    </div>
    """
    
    if int(critical_count) > 0 or int(high_count) > 5:
        body += """
        <div style="background: #e74c3c; color: white; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h3>⚠️ Action Required</h3>
            <p>Critical or high-severity vulnerabilities detected. Immediate remediation recommended.</p>
        </div>
        """
    else:
        body += """
        <div style="background: #27ae60; color: white; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h3>✅ Status</h3>
            <p>Security scan passed with acceptable risk level.</p>
        </div>
        """
    
    send_email(f"Trivy Scan Alert - {image_name}", body, priority)

def send_falco_alert(alert_type, details, container_name, command=""):
    """Send Falco runtime alert"""
    
    body = f"""
    <h2>🚨 Runtime Security Threat Detected</h2>
    
    <div class="metric">
        <div>Alert Type</div>
        <div style="color: #e74c3c; font-weight: bold;">{alert_type}</div>
    </div>
    
    <div class="metric">
        <div>📦 Container</div>
        <div><code>{container_name}</code></div>
    </div>
    
    <div class="metric">
        <div>📋 Details</div>
        <div>{details}</div>
    </div>
    """
    
    if command:
        body += f"""
        <div class="metric">
            <div>💻 Command</div>
            <div><code>{command}</code></div>
        </div>
        """
    
    body += """
    <div style="background: #e74c3c; color: white; padding: 15px; margin: 20px 0; border-radius: 5px;">
        <h3>⚠️ Immediate Action Required</h3>
        <p>A runtime security threat has been detected. Investigate immediately.</p>
        <ul>
            <li>Review container logs</li>
            <li>Check for unauthorized access</li>
            <li>Verify application behavior</li>
            <li>Consider stopping the container if necessary</li>
        </ul>
    </div>
    """
    
    send_email(f"Runtime Alert - {alert_type}", body, "critical")

def send_test_alert():
    """Send test alert"""
    body = """
    <h2>🧪 Test Alert</h2>
    <p>This is a test message from the DevSecOps Security Alerting System.</p>
    <p>If you received this email, your email configuration is working correctly!</p>
    """
    send_email("Test Alert", body, "info")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("DevSecOps Email Alert Script")
        print("")
        print("Usage:")
        print(f"  {sys.argv[0]} trivy <image_name> <critical> <high> [medium]")
        print(f"  {sys.argv[0]} falco <alert_type> <details> <container> [command]")
        print(f"  {sys.argv[0]} test")
        print("")
        print("Examples:")
        print(f"  {sys.argv[0]} trivy vulnerable-app:latest 5 10 3")
        print(f"  {sys.argv[0]} falco 'Shell Execution' 'bash spawned' 'devsecops-demo' '/bin/bash'")
        print(f"  {sys.argv[0]} test")
        sys.exit(1)
    
    alert_type = sys.argv[1]
    
    if alert_type == "trivy" and len(sys.argv) >= 5:
        send_trivy_alert(sys.argv[2], sys.argv[3], sys.argv[4], 
                        sys.argv[5] if len(sys.argv) > 5 else 0)
    
    elif alert_type == "falco" and len(sys.argv) >= 5:
        send_falco_alert(sys.argv[2], sys.argv[3], sys.argv[4],
                        sys.argv[5] if len(sys.argv) > 5 else "")
    
    elif alert_type == "test":
        send_test_alert()
    
    else:
        print("Invalid arguments. Run without arguments to see usage.")
        sys.exit(1)
