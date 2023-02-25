#!/bin/sh -l

#set -e at the top of your script will make the script exit with an error whenever an error occurs (and is not explicitly handled)
set -eu


TEMP_SSH_PRIVATE_KEY_FILE='../private_key'
TEMP_SFTP_FILE='../sftp'
TEMP_KNOWN_HOST_FILE='../hosts'

# keep string format
printf "%s" $4 >$TEMP_SSH_PRIVATE_KEY_FILE
# host to hosts file
printf "%s" $2 >$TEMP_KNOWN_HOST_FILE
# avoid Permissions too open
chmod 600 $TEMP_SSH_PRIVATE_KEY_FILE

echo '-----debug start-----'

cat $TEMP_SSH_PRIVATE_KEY_FILE | while read line
do
    echo $line
done

echo '----------------------'

cat $TEMP_KNOWN_HOST_FILE | while read line
do
    echo $line
done

echo '-----debug end-------'

echo 'ssh start'

# ssh -o StrictHostKeyChecking=no -p $3 -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2 mkdir -p $6
ssh -tt -o StrictHostKeyChecking=no -o UserKnownHostsFile=$TEMP_KNOWN_HOST_FILE -p $3 -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2

echo 'sftp start'
# create a temporary file containing sftp commands
printf "%s" "put -r $5 $6" >$TEMP_SFTP_FILE
#-o StrictHostKeyChecking=no avoid Host key verification failed.
sftp -b $TEMP_SFTP_FILE -o StrictHostKeyChecking=no -P $3 $7 -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE $1@$2

echo 'deploy success'
exit 0
