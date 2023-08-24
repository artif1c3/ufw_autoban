# UFW Autoban

The script scans your access log in your nginx folder and autobans IP addresses that search for sensitive files on your webserver.  

Uses <a href="https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29">ufw</a> to ban IP addresses that search for typical files/directories like your .env/ or .git/ directory.  

Make sure to enter your IPv4 address in EXCLUDEDIP or you may risk IP banning yourself.  

Set it up with crontab to perform automation:  

    sudo crontab -e
    0 0 * * * /path/to/autoban.sh