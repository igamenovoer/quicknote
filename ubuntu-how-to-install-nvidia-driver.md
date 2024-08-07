# what is the proper way to install nvidia driver?

Use apt to install nvidia drivers, here is the [guide](https://ubuntu.com/server/docs/nvidia-drivers-installation)

First, make sure you have `ubuntu-drivers` installed,

```bash
sudo apt install ubuntu-drivers-common
```

Then list available drivers

```bash
sudo ubuntu-drivers list
```

You will see the followings

```bash
nvidia-driver-470
nvidia-driver-470-server
nvidia-driver-535
nvidia-driver-535-open
nvidia-driver-535-server
nvidia-driver-535-server-open
nvidia-driver-550
nvidia-driver-550-open
nvidia-driver-550-server
nvidia-driver-550-server-open
```

Select one of the drivers to install ([how these drivers differ from each other?](https://askubuntu.com/questions/1262401/what-is-the-nvidia-server-driver))

```bash
sudo ubuntu-drivers install nvidia:535
```

or

```bash
sudo ubuntu-drivers install --gpgpu nvidia:535-server
```
