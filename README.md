##โปรแกรมนี้ถูกสร้างขึ้นโดย Chat GPT เพื่อประโยชน์สาธารณะ##

รายงานการทำงานของโปรแกรมติดตั้ง LAMP และ phpMyAdmin


โปรแกรมนี้เป็นสคริปต์ bash ที่ทำงานเพื่อการติดตั้ง LAMP stack (Linux, Apache, MySQL, PHP) และ phpMyAdmin บนระบบปฏิบัติการ Ubuntu โดยป้องกันข้อมูลที่อ่อนไหวด้วยอักขระ '*'

ขั้นตอนการทำงานของโปรแกรม
อัปเดตแคชของตัวจัดการแพ็คเกจและติดตั้ง Apache

bash
คัดลอกโค้ด
sudo apt update
sudo apt install -y apache2
ปรับการตั้งค่าไฟร์วอลล์เพื่ออนุญาตให้มีการเชื่อมต่อ HTTP

bash
คัดลอกโค้ด
sudo ufw allow in "Apache"
ติดตั้ง MySQL และ Expect

bash
คัดลอกโค้ด
sudo apt install -y mysql-server expect
สร้างสคริปต์ expect สำหรับ mysql_secure_installation

bash
คัดลอกโค้ด
tee mysql_secure_installation.expect > /dev/null <<EOF
#!/usr/bin/expect -f

set timeout 10
spawn sudo mysql_secure_installation

expect "Enter password for user root:"
send "*********\r"

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
รันสคริปต์ expect สำหรับ mysql_secure_installation

bash
คัดลอกโค้ด
sudo expect mysql_secure_installation.expect
ลบสคริปต์ expect หลังการใช้งาน

bash
คัดลอกโค้ด
rm mysql_secure_installation.expect
เปลี่ยนการตั้งค่าการรับรองความถูกต้องของ root เป็น mysql_native_password

bash
คัดลอกโค้ด
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '*********'; FLUSH PRIVILEGES;"
ติดตั้ง PHP และโมดูลที่จำเป็น

bash
คัดลอกโค้ด
sudo apt install -y php libapache2-mod-php php-mysql
แก้ไขไฟล์ dir.conf เพื่อให้ Apache ให้ความสำคัญกับไฟล์ index.php ก่อน

bash
คัดลอกโค้ด
sudo tee /etc/apache2/mods-enabled/dir.conf > /dev/null <<EOF
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF
รีโหลด Apache เพื่อให้การเปลี่ยนแปลงมีผล

bash
คัดลอกโค้ด
sudo systemctl reload apache2
สร้างไฟล์ทดสอบ PHP ในไดเร็กทอรีเริ่มต้น

bash
คัดลอกโค้ด
tee /var/www/html/info.php > /dev/null <<EOF
<?php
phpinfo();
?>
EOF
ทดสอบการติดตั้ง PHP โดยเข้าถึง URL http://localhost/info.php

bash
คัดลอกโค้ด
echo "กรุณาทดสอบการติดตั้ง PHP โดยเข้าถึง URL: http://localhost/info.php"
ลบไฟล์ทดสอบ PHP เพื่อความปลอดภัย

bash
คัดลอกโค้ด
sudo rm /var/www/html/info.php
ติดตั้ง phpMyAdmin

bash
คัดลอกโค้ด
sudo apt install -y phpmyadmin
กำหนดให้ phpMyAdmin ใช้งานร่วมกับ Apache

bash
คัดลอกโค้ด
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
รีสตาร์ท Apache เพื่อให้การเปลี่ยนแปลงมีผล

bash
คัดลอกโค้ด
sudo systemctl restart apache2
แจ้งเตือนผู้ใช้ให้ตรวจสอบการติดตั้ง phpMyAdmin

bash
คัดลอกโค้ด
echo "กรุณาทดสอบการติดตั้ง phpMyAdmin โดยเข้าถึง URL: http://localhost/phpmyadmin"
ข้อควรระวัง
ควรเปลี่ยนรหัสผ่านที่ใช้ในสคริปต์ให้เป็นรหัสผ่านที่ปลอดภัยและซับซ้อน และเก็บไว้ในที่ปลอดภัย
หลังการทดสอบการติดตั้ง PHP และ phpMyAdmin ควรตรวจสอบให้แน่ใจว่าลบไฟล์ทดสอบแล้วเพื่อลดความเสี่ยงด้านความปลอดภัย
