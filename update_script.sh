#!/bin/sh
environment=$1

if [ $# == 0 ]; then
    echo "No environment details provided"
    exit 1
fi

### clean up of the dynamic files before running the script##

[ -f finalfile.txt ] && rm finalfile.txt
[ -f targent_agent_list.txt ] && rm targent_agent_list.txt
[ -f targent_agent.txt ] && rm targent_agent.txt


#echo "Getting the commit id"
commit_id=`git rev-parse HEAD`
echo "Below are the list of changed files with the commit id : $commit_id"
`git show --pretty="" --name-only $commit_id > commit_id_files_list.txt`
cat commit_id_files_list.txt
`cat mapping_files/$environment | cut -d ":" -f1 > searchagent_list.txt`
commit_file='commit_id_files_list.txt'
searchagent_list='searchagent_list.txt'

i=1
while read file_name; do
echo "$i file : $file_name"
	while read sourceline; do
	cat $file_name | grep $sourceline
	if [ $? == 0 ]
	then
	   echo "[INFO: YES, $sourceline in $file_name exists]"
	   echo $sourceline >> targent_agent_list.txt
	else
	   echo "[INFO: No $sourceline in $file_name]"
	fi
	done < $searchagent_list
i=$((i+1))
done < $commit_file

sort targent_agent_list.txt | uniq > targent_agent.txt

while read sources_agent_name; do

	target_agent=`cat mapping_files/$environment | grep $sources_agent_name | cut -d ":" -f2`
	echo "source : $sources_agent_name --> Target :$target_agent"
    sed -e 's/Source_SecureAgent_Name/'$sources_agent_name'/' -e 's/Target_SecureAgent_Name/'$target_agent'/' -e "s/comma/\,/" base_template >> finalfile.txt
done < targent_agent.txt

truncate -s -2 finalfile.txt
sed '/#updatehere/r finalfile.txt' exisitingscript.txt > replacable_script.txt
