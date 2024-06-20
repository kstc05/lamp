#!/bin/bash

# อัปเดตแคชของตัวจัดการแพ็คเกจและติดตั้ง Apache
sudo apt update
sudo apt install -y apache2

# ปรับการตั้งค่าไฟร์วอลล์เพื่ออนุญาตให้มีการเชื่อมต่อ HTTP
sudo ufw allow in "Apache"

# ติดตั้ง MySQL
sudo apt install -y mysql-server expect

# แก้ปัญหาการตั้งค่าความปลอดภัยของ MySQL และตั้งรหัสผ่าน Root เป็น 'Sbkcrona'
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Sbkcrona';"

# สร้างสคริปต์ expect สำหรับ mysql_secure_installation
tee mysql_secure_installation.expect > /dev/null <<EOF
#!/usr/bin/expect -f

set timeout 10
spawn sudo mysql_secure_installation

expect "Enter password for user root:"
send "Sbkcrona\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
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

# สร้างไดเร็กทอรีสำหรับเว็บไซต์
sudo mkdir /var/www/antfarm.online
sudo chown -R $USER:$USER /var/www/antfarm.online

# สร้างไฟล์คอนฟิก Virtual Host
sudo tee /etc/apache2/sites-available/antfarm.online.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName antfarm.online
    ServerAlias www.antfarm.online
    DocumentRoot /var/www/antfarm.online
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# เปิดใช้งาน Virtual Host
sudo a2ensite antfarm.online
sudo systemctl reload apache2

# สร้างไฟล์ทดสอบ PHP
tee /var/www/antfarm.online/info.php > /dev/null <<EOF
<?php
phpinfo();
?>
EOF

# ทดสอบการติดตั้ง PHP โดยเข้าถึง URL http://antfarm.online/info.php
echo "กรุณาทดสอบการติดตั้ง PHP โดยเข้าถึง URL: http://antfarm.online/info.php"

# ลบไฟล์ทดสอบ PHP เพื่อความปลอดภัย
sudo rm /var/www/antfarm.online/info.php

# สร้างฐานข้อมูลและผู้ใช้ใหม่ใน MySQL
sudo mysql -e "CREATE DATABASE example_database;"
sudo mysql -e "CREATE USER 'example_user'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON example_database.* TO 'example_user'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# สร้างสคริปต์ PHP เพื่อทดสอบการเชื่อมต่อฐานข้อมูล
tee /var/www/antfarm.online/todo_list.php > /dev/null <<EOF
<?php
\$user = "example_user";
\$password = "password";
\$database = "example_database";
\$table = "todo_list";

try {
    \$db = new PDO("mysql:host=localhost;dbname=\$database", \$user, \$password);
    echo "<h2>TODO</h2><ol>";
    foreach(\$db->query("SELECT content FROM \$table") as \$row) {
        echo "<li>" . \$row['content'] . "</li>";
    }
    echo "</ol>";
} catch (PDOException \$e) {
    print "Error!: " . \$e->getMessage() . "<br/>";
    die();
}
?>
EOF

# ทดสอบการเชื่อมต่อฐานข้อมูลโดยเข้าถึง URL http://antfarm.online/todo_list.php
echo "กรุณาทดสอบการเชื่อมต่อฐานข้อมูลโดยเข้าถึง URL: http://antfarm.online/todo_list.php"
