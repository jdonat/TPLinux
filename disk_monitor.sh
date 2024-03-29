#!/bin/bash
percentage=$(df --output=ipcent -t ext4 | tail -n 1)
percentage=${percentage::-1}
if [ "$percentage" -gt 5 ]; then
	#echo "Disk space almost full : $percentage% used." >> disk_monitor.txt;
	str=$(echo "Jonathan DM : Disk space almost full : $percentage% used.")
	url=$(echo "https://hooks.slack.com/services/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")
	echo $str
	echo $url
	curl -X POST -H "Content-Type: application/json" --data '{"text":"$str"}' --location $url
fi


