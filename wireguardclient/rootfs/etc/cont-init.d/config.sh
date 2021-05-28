#!/usr/bin/with-contenv bashio

declare allowed_ips
declare config
declare dns
declare endpoint
declare interface
declare keep_alive
declare client_private_key
declare client_ip_address
declare server_public_key
declare post_up
declare post_down

interface="wg0"
config="/etc/wireguard/${interface}.conf"
keep_alive=20
post_up="iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
post_down="iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"
dns=$(bashio::dns.host)

if bashio::config.has_value 'client_private_key'; then
    client_private_key=$(bashio::config 'client_private_key')
else
	bashio::exit.nok "Client private key not found"
fi

if bashio::config.has_value 'client_ip_address'; then
    client_ip_address=$(bashio::config 'client_ip_address')
else
	bashio::exit.nok "Client IP address not found"
fi

if bashio::config.has_value 'server_public_key'; then
    server_public_key=$(bashio::config 'server_public_key')
else
	bashio::exit.nok "Server pubic key not found"
fi

if bashio::config.has_value 'allowed_ips'; then
    allowed_ips=$(bashio::config 'allowed_ips')
else
	allowed_ips="0.0.0.0/0"
fi

if bashio::config.has_value 'endpoint'; then
    endpoint=$(bashio::config 'endpoint')
else
	bashio::exit.nok "Endpoint not found"
fi

# Start creation of configuration
echo "[Interface]" >> "${config}"
echo "PrivateKey = ${client_private_key}" >> "${config}"
echo "Address = ${client_ip_address}" >> "${config}"
echo "PostUp = ${post_up} " >> "${config}"
echo "PostDown = ${post_down}" >> "${config}"
echo "DNS = ${dns}" >> "${config}"

echo "[Peer]" >> "${config}"
echo "PublicKey = ${server_public_key}" >> "${config}"
echo "AllowedIPs = ${allowed_ips}" >> "${config}"
echo "Endpoint = ${endpoint}" >> "${config}"
echo "PersistentKeepalive = ${keep_alive}" >> "${config}"
