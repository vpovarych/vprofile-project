#!/bin/bash

yum install java-21-openjdk.x86_64 wget -y   
mkdir -p /opt/nexus/   
mkdir -p /tmp/nexus/                                           
cd /tmp/nexus/
NEXUSURL="https://download.sonatype.com/nexus/3/nexus-3.98.1-01-linux-x86_64.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10
tar -xzvf nexus.tar.gz
NEXUSDIR=$(ls -d nexus-3*)
cp -r /tmp/nexus/* /opt/nexus/
rm -rf /tmp/nexus/$NEXUSDIR/jdk

cp -r /tmp/nexus/* /opt/nexus/
sleep 5

# ДОБАВЛЯЕМ ПРАВА НА ИСПОЛНЕНИЕ ЗДЕСЬ:
chmod +x /opt/nexus/$NEXUSDIR/bin/nexus

useradd nexus || true
chown -R nexus:nexus /opt/nexus 

cat <<EOT > /etc/systemd/system/nexus.service
[Unit]                                                 
Description=nexus service                                                     
After=network.target                                                          

[Service]                                                                     
Type=forking                                                                  
LimitNOFILE=65536 
WorkingDirectory=/opt/nexus
Environment=HOME=/opt/nexus                                                            
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start                                  
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop   
Environment="INSTALL4J_JAVA_HOME=/usr/lib/jvm/java-21-openjdk"                                 
User=nexus                                                                    
Restart=on-abort                                                              

[Install]                                                                     
WantedBy=multi-user.target                                                    
EOT

echo "run_as_user=\"nexus\"" > /opt/nexus/$NEXUSDIR/bin/nexus.rc
chown nexus:nexus /opt/nexus/$NEXUSDIR/bin/nexus.rc

systemctl daemon-reload
systemctl start nexus
systemctl enable nexus
