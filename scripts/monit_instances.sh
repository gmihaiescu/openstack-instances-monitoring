#!/bin/bash

export COLUMNS=512

IFS='
'

MONITORING_SERVICE_IP="http://10.131.80.28:8000"

instance_ps='qemu-system'

if [ ! -e "${HOME}/.toprc" ]; then
  wget -c ${MONITORING_SERVICE_IP}/scripts/toprc -O ${HOME}/.toprc
fi
  

PSS=$(top -c -b -p $(pgrep ${instance_ps} -d ',') -n 1 |grep ${instance_ps})

hv_mem=$(free -k |sed -n '2p' |awk '{print $2}')
hv_cpu=$(cat /proc/cpuinfo |grep processor |wc -l)


for i in ${PSS}; do
  IFS=' '
  read cpu mem instance <<<$(echo ${i}| awk '{match($0,"instance-[0-9a-zA-Z]{8}",a)}END{print $9, $10, a[0]}')
  instance_cpu=$(virsh vcpucount ${instance} |awk '{if (($1=="current") && ($2=="live")) {print $3}}')
  instance_mem=$(virsh dommemstat ${instance} |awk '{if ($1=="actual") {print $2}}')
  instance_tap=$(virsh domiflist ${instance}  | grep tap| awk '{print $1}')
  instance_rx_bytes=$(virsh domifstat ${instance} ${instance_tap}| grep rx_bytes | awk '{print $3}')
  instance_tx_bytes=$(virsh domifstat ${instance} ${instance_tap}| grep tx_bytes | awk '{print $3}')
  total_mem=$(echo "scale=4;(((${hv_mem}/100)*${mem})/${instance_mem})*100"|bc)
  total_cpu=$(echo "scale=4;(((${hv_cpu}/100)*${cpu})/${instance_cpu})*100"|bc)
  instance_id=$(virsh dominfo ${instance} |awk '{if ($1=="UUID:") {print $2}}')
  curl --silent -d "instance_id=${instance_id}&cpu=${total_cpu}&mem=${total_mem}&rx_bytes=${instance_rx_bytes}&tx_bytes=${instance_tx_bytes}" "${MONITORING_SERVICE_IP}/monitoring/post"
done
