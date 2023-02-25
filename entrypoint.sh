#!/bin/sh -l

#set -e at the top of your script will make the script exit with an error whenever an error occurs (and is not explicitly handled)
set -eu

TEMP_SSH_PRIVATE_KEY_FILE='../private_key.pem'
TEMP_SFTP_FILE='../sftp'

# make sure remote path is not empty
if [ -z "$6" ]; then
   echo 'remote_path is empty'
   exit 1
fi

# keep string format
printf "%s" "$4" >$TEMP_SSH_PRIVATE_KEY_FILE
# avoid Permissions too open
chmod 600 $TEMP_SSH_PRIVATE_KEY_FILE

# delete remote files if needed
if test $9 == "true";then
  echo 'Start delete remote files'
  ssh -o StrictHostKeyChecking=no -p $3 -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2 rm -rf $6
fi

if test $7 = "true"; then
  echo "Connection via sftp protocol only, skip the command to create a directory"
else
  echo 'Create directory if needed'
  ssh -o StrictHostKeyChecking=no -p $3 -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2 mkdir -p $6
fi

if test $10 = "true"; then
  echo 'SCP Start'
  #-o StrictHostKeyChecking=no avoid Host key verification failed.
  scp -P $3 -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2:$5 $6
else
  echo 'SFTP Start'
  # create a temporary file containing sftp commands
  printf "%s" "put -r $5 $6" >$TEMP_SFTP_FILE
  #-o StrictHostKeyChecking=no avoid Host key verification failed.
  sftp -b $TEMP_SFTP_FILE -P $3 $8 -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2
fi

echo 'Deploy Success'
exit 0
