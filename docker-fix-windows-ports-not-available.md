# Port mapping issue in windows

Sometimes the docker fails to map ports from host to container, complaining that ports are not available, but they are actually available.

Like this

```bash
D:\code\junkbox\service-compose\minio>docker compose -f .\minio-with-client.yml up
time="2024-08-20T10:02:14+08:00" level=warning msg="Found orphan containers ([minio-minio-client-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up."
[+] Running 2/0
 ✔ Network minio_default           Created                                                                                                                                                     0.0s 
 ✔ Container minio-minio-server-1  Created                                                                                                                                                     0.0s 
Attaching to minio-server-1
Gracefully stopping... (press Ctrl+C again to force)
[+] Stopping 1/0
 ✔ Container minio-minio-server-1  Stopped                                                                                                                                                     0.0s 
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:9000 -> 0.0.0.0:0: listen tcp 0.0.0.0:9000: bind: An attempt was made to access a socket in a way forbidden by its access permissions.
```

To fix that, do the followings:

```bash
# do this in admin cmd
net stop winnat
net start winnat
```
