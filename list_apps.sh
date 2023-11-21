#!/bin/bash
SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "sudo ./$SCRIPT"
    exit 1
fi

service_list='bitcoin\|electrs\|esplora\|electrumx\|electrum\|wasabi\|nbxplorer\|btcpayserver\|btc\|selfhost\|lnd\|lncli\|lndconnect\|eclair\|ln-system\|ridetheln\|thunderhub\|btc-rpc-explorer\|lighter\|multiuser-ln\|liblightning\|ln-contacts\|ln-dialog\|qpay-rpc-service\|qpay-client\|ln-mime\|remote-service-bridge\|samourai-dojo\|joinmarket\|lnpbp-testkit\|remir\|translations'

echo "Active:"
systemctl --type=service --state=active | sed -e 's/ *loaded.*//g' | sed -e 's/\.service//g' | grep "$service_list"

echo "Others:"
systemctl --type=service | grep -v " active " | sed -e 's/ *loaded.*//g' | sed -e 's/\.service//g' | grep "$service_list"

