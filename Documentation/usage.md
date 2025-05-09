# Usage

## Usage via Terminal
<img src="https://github.com/bindhosts/bindhosts/blob/master/Documentation/screenshots/terminal_usage.png?raw=true" width="100%">

You can access the various options as shown in the image for bindhosts Magisk/KernelSU/APatch
- via Termux (or other various common terminal apps)
    ```shell
    > su
    > bindhosts
    ```

- via SDK Platform Tools (root shell)
    ```shell
    > adb shell
    > su
    > bindhosts
    ```

### Example
```
    bindhosts --action          This will simulate bindhosts action to grab ips or reset the hosts file, depending on which state bindhosts is in
    bindhosts --tcpdump         Will sniff current active ip addresses on your network mode (wifi or data, make sure no DNS services are being used like cloudflare, etc.)
    bindhosts --query <URL>     Check hosts file for pattern
    bindhosts --force-update    force an update
    bindhosts --force-reset     Will force reset bindhosts, which means resets the hosts file to zero ips
    bindhosts --custom-cron     Defines time of day to run a cronjob for bindhosts
    bindhosts --enable-cron     Enables cronjob task for bindhosts to update the ips of the lists you are currently using at 10am (default time)
    bindhosts --disable-cron    Disables & deletes previously set cronjob task for bindhosts
    bindhosts --help            This will show everything as shown above in image and text
```

## Action
 press action to toggle update and reset
 
 <img src="https://github.com/bindhosts/bindhosts/blob/master/Documentation/screenshots/manager_action.gif?raw=true" width="100%">

## WebUI
  add your custom rules, sources, whitelist or blacklist
 
 <img src="https://github.com/bindhosts/bindhosts/blob/master/Documentation/screenshots/manager_webui.gif?raw=true" width="100%">

