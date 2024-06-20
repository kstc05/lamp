#!/bin/bash

# อัปเดตแคชของตัวจัดการแพ็คเกจและติดตั้ง Apache
sudo apt update
sudo apt install -y apache2

# ปรับการตั้งค่าไฟร์วอลล์เพื่ออนุญาตให้มีการเชื่อมต่อ HTTP
sudo ufw allow in "Apache"

# ติดตั้ง MySQL และ Expect
sudo apt install -y mysql-server expect

# สร้างสคริปต์ expect สำหรับ mysql_secure_installation
tee mysql_secure_installation.expect > /dev/null <<EOF
#!/usr/bin/expect -f

set timeout 10
spawn sudo mysql_secure_installation

expect "Enter password for user root:"
send "Sbkcrona\r"

expect "VALIDATE PASSWORD COMPONENT can be used to test passwords and improve security. It checks the strength of password and allows the users to set only those passwords which are secure enough. Would you like to setup VALIDATE PASSWORD component?"
send "n\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :)"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :)"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :)"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :)"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :)"
send "y\r"

expect eof
EOF

# รันสคริปต์ expect สำหรับ mysql_secure_installation
sudo expect mysql_secure_installation.expect

# ลบสคริปต์ expect หลังการใช้งาน
rm mysql_secure_installation.expect

# ติดตั้ง PHP และโมดูลที่จำเป็น
sudo apt install -y php libapache2-mod-php php-mysql

# แก้ไขไฟล์ dir.conf เพื่อให้ Apache ให้ความสำคัญกับไฟล์ index.php ก่อน
sudo tee /etc/apache2/mods-enabled/dir.conf > /dev/null <<EOF
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF

# รีโหลด Apache เพื่อให้การเปลี่ยนแปลงมีผล
sudo systemctl reload apache2

# สร้างไฟล์ทดสอบ PHP ในไดเร็กทอรีเริ่มต้น
tee /var/www/html/info.php > /dev/null <<EOF
<?php
phpinfo();
?>
EOF

# ทดสอบการติดตั้ง PHP โดยเข้าถึง URL http://192.168.56.103/info.php
echo "กรุณาทดสอบการติดตั้ง PHP โดยเข้าถึง URL: http://192.168.56.103/info.php"

# ลบไฟล์ทดสอบ PHP เพื่อความปลอดภัย
#sudo rm /var/www/html/info.php

# ติดตั้ง phpMyAdmin
sudo apt install -y phpmyadmin

# กำหนดให้ phpMyAdmin ใช้งานร่วมกับ Apache
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# รีสตาร์ท Apache เพื่อให้การเปลี่ยนแปลงมีผล
sudo systemctl restart apache2

# แจ้งเตือนผู้ใช้ให้ตรวจสอบการติดตั้ง phpMyAdmin
echo "กรุณาทดสอบการติดตั้ง phpMyAdmin โดยเข้าถึง URL: http://192.168.56.103/phpmyadmin"
