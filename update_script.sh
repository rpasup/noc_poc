#!/bin/sh
### clean up of the dynamic files ##
rm finalfile.txt

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
   #echo "we found the agent"
   echo $targetline >> targent_agent_list.txt
   target_agent=`cat mapping_files/preprod | grep $targetline | cut -d ":" -f2`
   echo "target :$target_agent, source : $targetline"
   sed -e 's/Source_SecureAgent_Name/'$targetline'/' -e 's/Target_SecureAgent_Name/'$target_agent'/' -e "s/comma/\,/" base_template >> finalfile.txt
else
   echo "we didnt find the $targetline in $line"
fi
done < $searchagent_list
echo $?
i=$((i+1))
done < $commit_file

sort targent_agent_list.txt | uniq > targent_agent.txt
truncate -s -2 finalfile.txt
sed '/#updatehere/r finalfile.txt' exisitingscript.txt > replacable_script.txt
