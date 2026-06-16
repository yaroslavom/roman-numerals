#! /bin/bash
yum update -y
yum install python3-pip -y
pip3 install Flask
cd /home/ec2-user
wget -P templates https://raw.githubusercontent.com/guile-clarusway/roman-numerals-converter/refs/heads/main/templates/index.html
wget -P templates https://raw.githubusercontent.com/guile-clarusway/roman-numerals-converter/refs/heads/main/templates/result.html
wget https://raw.githubusercontent.com/guile-clarusway/roman-numerals-converter/refs/heads/main/app.py
python3 app.py