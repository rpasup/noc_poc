#!/bin/sh
echo "getting the commit id"
commit_id=`git rev-parse HEAD`
echo "listing the files with the commit id : $commit_id"
`git show --pretty="" --name-only $commit_id > commit_id_files_list.txt`
#cat commit_id_files_list.txt
`cat mapping_files/dev | cut -d ":" -f1 > searchagent_list.txt`
commit_file='commit_id_files_list.txt'
searchagent_list='searchagent_list.txt'
i=1
while read line; do
#Reading each line.
echo "$i file : $line"
while read targetline; do 
cat $line | grep $targetline
if [ $? == 0 ]
then
   echo "we found the agent"
   echo $targetline >> targent_agent_list.txt
else
   echo "we didnt find the $targetline in $line"
fi
done < $searchagent_list
echo $?
i=$((i+1))
done < $commit_file
