# CADR Tools
Tools and tricks for the cryptoanarchy deb repo builder

DO NOT USE IN PRODUCTION!

This is a set of tools (scripts) for making installation of the [CADR](https://github.com/debian-cryptoanarchy/cryptoanarchy-deb-repo-builder) easier and quicker when testing something. It lacks e.g. verifying signatures (for now) and some of the scripts are built in a relatively naive way so there may be scenarios where it just simply doesn't work.

It is required to run the scripts as super user which is probably not needed in all cases but it is the way it is for now.

Use it only for testing purposes, research, and looking around.

# How it works:

Set the repositories for Microsoft and deb.ln-ask.me

`sudo ./set_repositories.sh`

Install the apps

`sudo ./install_apps.sh`

To check what domain it uses (default is tor), visit the http://xxxxxxxxxxx.onion/dashboard

`sudo ./get_domain.sh`

Setup as clearnet if you want. Prepare the open ports 80 and 443, DNS, etc. before running this command

`sudo ./clearnet.sh`

Upgrade packages with a single command if there are new releases

`sudo ./upgrade.sh`

See currently installed apps

`sudo ./list_apps.sh`

See status, start, stop, or restart each app individually (use the name from the list_apps.sh)

`sudo ./status.sh bitcoin-mainnet`

`sudo ./start.sh bitcoin-mainnet`

`sudo ./stop.sh bitcoin-mainnet`

`sudo ./restart.sh bitcoin-mainnet`

Check logs for each app separately (use the name from the list_apps.sh)

`sudo ./logs.sh bitcoin-mainnet`

Reconfigure the app settings if needed for some reason

`sudo ./reconfigure.sh bitcoin-mainnet`

Upgrade from Debian 10 to Debian 11 including changing the sources list, upgrading the Postgres clusters
`sudo ./upgrade_debian.sh`






