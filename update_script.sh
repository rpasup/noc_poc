#!/bin/sh
environment=$1
### clean up of the dynamic files ##
rm finalfile.txt

#echo "getting the commit id"
commit_id=`git rev-parse HEAD`
echo "listing the files with the commit id : $commit_id"
`git show --pretty="" --name-only $commit_id > commit_id_files_list.txt`
echo "file changes on this commit are : "
cat commit_id_files_list.txt
`cat mapping_files/$environment | cut -d ":" -f1 > searchagent_list.txt`
commit_file='commit_id_files_list.txt'
searchagent_list='searchagent_list.txt'
i=1
while read comment_file_name; do
#Reading each comment_file_name.
echo "$i file : $comment_file_name"
while read sourceagentcomment_file_name; do
cat $comment_file_name | grep $sourceagentcomment_file_name
if [ $? == 0 ]
then
   #echo "we found the agent"
   echo $sourceagentcomment_file_name >> targent_agent_list.txt
   target_agent=`cat mapping_files/$environment | grep $sourceagentcomment_file_name | cut -d ":" -f2`
   echo "target :$target_agent, source : $sourceagentcomment_file_name"
   sed -e 's/Source_SecureAgent_Name/'$sourceagentcomment_file_name'/' -e 's/Target_SecureAgent_Name/'$target_agent'/' -e "s/comma/\,/" base_template >> finalfile.txt
else
   echo "we didnt find the $sourceagentcomment_file_name in $comment_file_name"
fi
done < $searchagent_list
echo $?
i=$((i+1))
done < $commit_file

sort targent_agent_list.txt | uniq > targent_agent.txt
truncate -s -2 finalfile.txt
sed '/#updatehere/r finalfile.txt' exisitingscript.txt > replacable_script.txt

