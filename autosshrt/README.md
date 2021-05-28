
# AutoSSH Remote Tunnel
Home Assistant addon. Connects to the remote SSH server using autossh. Creates an SSH tunnel to expose the Home Assistant web interface in the public Internet.

## How it works

```
------------------                   ------------------------------------------
| Home Assistant |  --- autossh ---> |  Remote server with SSH with public IP |
------------------                   ------------------------------------------
 XXX.XXX.XXX.XXX:8123 ----- Tunnel -----> 127.0.0.1:8123
                      WWW (proxy): AAA.BBB.CCC.DDD -> 127.0.0.1:8123
```
1. AutoSSH connects to remote SSH server with public IP address (e.g. AAA.BBB.CCC.DDD)
2. AutoSSH forwards HAS web interface port (e.g. 8123) to the remote server
3. After connect HAS web interface is available on remote server http://127.0.0.1:8123
4. At remote server you can install webserver (Nginx, Apache, etc.) with a proxy module
5. At remote server you can create vhost configuration with proxy configuration (remember about SSL):
```
location / {
    proxy_pass http://127.0.0.1:8123;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
}
```
7. Connect to server https://AAA.BBB.CCC.DDD

## Options
```
  "options": {
    "hostname": "",
    "ssh_port": "22",
    "username": "username",
    "remote_forwarding": ["127.0.0.1:8123:172.17.0.1:8123"],
    "other_ssh_options": "-v",
    "monitor_port": "8124",
    "monitor_port_enable": true,
    "regenerate_key": false
  },
```

 - **hostname** - remote SSH server hostname or IP address
 - **ssh_port** - remote SSH server port
 - **username** - remote server username
 - **remote_forwarding** - ports to forward
 - **other_ssh_options** - additional ssh options
 - **monitor_port** - port to monitor (autossh)
 - **monitor_port_enable** - port monitoring enabled/disabled (autossh)
 - **regenerate_key** - force regenerate SSH keys

