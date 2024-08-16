# Commonly used configuration for git

## set user name and email

These commands set the username and email globally for all repositories. If you want to set them for a specific repository, omit the --global flag and run the commands inside the repository directory.

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# get current setting
git config --global --get user.name
git config --global --get user.email
```

## set global proxy

```bash
# set proxies
git config --global http.proxy http://proxyuser:proxypassword@proxy.server.com:port
git config --global https.proxy https://proxyuser:proxypassword@proxy.server.com:port

# unset proxies
git config --global --unset http.proxy
git config --global --unset https.proxy

# get currently set proxies
git config --global --get http.proxy
git config --global --get https.proxy
```
