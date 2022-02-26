#!/bin/sh

echo "getting the commit id"
commit_id=`git rev-parse HEAD`
echo "listing the files with the commit id : $commit_id"
`git show --pretty="" --name-only $commit_id > commit_id_files_list.txt`
#cat commit_id_files_list.txt
`cat mapping_files/dev | cut -d ":" -f1 > searchagent_list.txt`
file='commit_id_files_list.txt'
i=1
while read line; do
#Reading each line.
echo "$i file : $line"
cat $line | grep SecureAgent1
i=$((i+1))
done < $file
