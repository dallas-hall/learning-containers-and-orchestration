# SELinux Troubleshooting

## Security-enhanced Linux for mere mortals

Really good resources on understanding SELinux.
* https://www.youtube.com/watch?v=cNoVgDqqJmM
* https://www.redhat.com/files/summit/session-assets/2017/S105084-cameron.pdf

## Necessary Packages

Provide human readable information in `/var/log/messages` and `journalctl -xe`
* `policycoreutils-python-utils-2.9-3.el8.noarch`
* `setroubleshoot.x86_64`
* `setroubleshoot-server.x86_64`

## Fixing SELinux Issues
After installing the above packages:
* Try doing your process that triggers SELinux
* Check `# journalctl -xe` or `# /var/log/messages` for the SELinux deny message.
    * Run the commands suggested there.
* If the above steps don't work, turn on permissive mode `# setenforce 0` and run the process again.
    * Do everything that you would noramlly do in the process. In my case, starting up gunicorn.service and using nginx.service to write to the gunicorn.socket. I exercised this path by starting the service and accessing my website.
    * Fix all the SELinux issues in `# journalctl -xe` and then `# setnforce 1` and your problems will be gone.

# Ansible Up & Running Project

## Create Services
`/usr/lib/systemd/system/gunicorn.*`

## Install packages
`sudo dnf install policycoreutils-python-utils-2.9-3.el8.noarch setroubleshoot.x86_64 setroubleshoot-server.x86_64`

## Try to start the service
`sudo systemctl start gunicorn`

## Fix First Error
```bash
sudo journalctl -xe # This yields the commands below
sudo ausearch -c 'gunicorn' --raw | audit2allow -M my-gunicorn # Search audit log and create an allow policy
sudo semodule -X 300 -i my-gunicorn.pp # Install the policy with a custom priority
sudo systemctl start gunicorn
```

## Fix rest of the errors
```bash
sudo setenforce 0
sudo systemctl start gunicorn
sudo journalctl -xe
sudo ausearch -c 'nginx' --raw | audit2allow -M my-nginx
sudo semodule -X 300 -i my-nginx.pp
sudo setenforce 1
sudo systemctl start gunicorn
```

## Use Application

Without actually visiting a website while SELinux was set to permissive mode, I didn't see the following error which was nginx and gunicorn.socket related. I had to load the website in a browser to trigger that error. Once that policy was created it worked fine.

