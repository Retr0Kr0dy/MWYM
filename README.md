### MWYM
#### <i>Me When Your Mom...</i>
![Alt text](https://media.tenor.com/nU4nLSz7lQIAAAAd/idkwhyhelp.gif)
### Whats this ???

Backdoor generator. I mean, `MWYM` is here to check which backdoor should be the best on the config machine and set them up.

- First check if config is handled :

  Such as kernel version, distro, bin (apache2,php,ssh,...) 

- Then check capabalities :

  to be `root` or not to be `root`, check if potential easy privesc if not check caps.

- Check current service started :

  Check if web server or ssh or ftp or any potential backdoor entry.

- Check network possiblites :

  Check accesibility, which currently used, check wich port can reach outside (not stealth).

#### BACKDOOR THE THING

<b>backdoor list:</b>
|Name|OS|PRIV|PROTO|SERVICE|DESC|STEALTH(0to5)|Implemented|
|-|-|-|-|-|-|-|-|
|MAGMAR|Linux|?|SSH|SSH|Adding id_pub.rsa to current `~/.ssh/authorized_keys`.|`2` if file doesn't exist, else `4|✅|
|ARBOK|Linux|?|PHP|APACHE2,PHP|Create PHP backdoor file for each php files and name it `.bk.<filename>`|`2` if file doesn't exist, else `4`|✅|
|VOLTORB|Linux|?|PHP|APACHE2,PHP|Pretty much a defacer, creating a subdomain for command execution|`2` if file doesn't exist, else `4`|❌|
|ASPICOT|Linux|?|SSH|any|Create a listener on preopened port sharing it whith his service.|?|❌|


#### Usage

- ?
- rsapub :
```
The RSA public key you want to use to connect to victim's machine.
```
- Stealth :
```
[0] - instantly spotable.
[1] - creating new conf-file anf new network confs.
[2] - creating new conf-file partially hidden and new network confs.
[3] - relying on pre-existing conf and possibly some conf change.
[4] - relying only on pre-existing conf file and sharing pre-opened port.
[5] - fully invisible
```
- php_shell_exec :
```
Content of PHP function (as one file for the moment) for command execution,
can be modified to any PHP backdoor file you want.
```
