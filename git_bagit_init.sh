#!/bin/bash
#
# Script to create and initialize a git repository following the bagit
# layout (http://tools.ietf.org/html/draft-kunze-bagit-09). Bagit is a
# useful structure for archiving data.
#
# Created: Adil Hasan, 12/Sept/13 DataTailor Ltd
# 
# Copyright (c) 2013, DataTailor Ltd
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions 
# are met:
#
# * Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright 
#   notice, this list of conditions and the following disclaimer in the 
#   documentation and/or other materials provided with the distribution.
# * Neither the name of the DataTailor Ltd nor the names of its 
#   contributors may be used to endorse or promote products derived from 
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

function usage() {
    echo "Script to create a git repository following the bagit structure.";
    echo "The script creates the git repository and copies a pre-commit hook";
    echo "script which populates bagit manifest files."
    echo " ";
    echo "See http://tools.ietf.org/html/draft-kunze-bagit-09 for more";
    echo "information about bagit";
    echo " ";
    echo "Usage: $0 [-hf] <directory>";
    echo " ";
    echo "Options:";
    echo "-h               Prints this help";
    echo "-f               Forces the creation of a git repository in <directory>";
    echo "                 even if the directory exists";
    echo " ";
    exit 0;
}

function collect_bag_input() {
   echo "Do you wish to enter information for bag-info.txt?";
   echo "(see http://tools.ietf.org/html/draft-kunze-bagit-09 for more";
   echo "information about bagit)";
   echo "No will cause an empty bag-info.txt file to be created";
   select yn in "Yes" "No"; do
       case $yn in
           Yes )
               supply_info=1 
               break
               ;;
           No ) 
               supply_info=0
               break
               ;;
       esac
   done

   if [ ${supply_info} -eq 0 ]; then
       bag_info=("Source-Organization:" "Organization-Address:" 
       "Contact-Name:" "Contact-Phone:" "Contact-Email:" 
       "External-Description:" "Bagging-Date:" "External-Identifier:"
       "Bag-Size:" "Payload-Oxum:" "Bag-Group-Identifier:" "Bag-Count:"
       "Internal-Sender-Identifier:" "Internal-Sender-Description:");
   fi

   if [ ${supply_info} -eq 1 ]; then
       echo -n "Organisation transferring/owning the content: ";
       read source_org;
       bag_info=(${bag_info[@]} $"Source-Organization: ${source_org}");
       echo -n "Mailing address of organization: ";
       read organization_address;
       bag_info=(${bag_info[@]} "Organization-Address: ${organization_address}");
       echo -n "Person responsible for content: ";
       read contact_name;
       bag_info=(${bag_info[@]} "Contact-Name: ${contact_name}");
       echo -n "Phone number of person responsible for content: ";
       read contact_phone;
       bag_info=(${bag_info[@]} "Contact-Phone: ${contact_phone}");
       echo -n "Email address of person responsible for content: ";
       read contact_email;
       bag_info=(${bag_info[@]} "Contact-Email: ${contact_email}");
       echo -n "Brief description of contents and provenance: ";
       read external_description;
       bag_info=(${bag_info[@]} "External-Description: ${external_description}");
       echo -n "Date (YYYY-MM-DD) contents prepared for packaging: ";
       read bagging_date;
       bag_info=(${bag_info[@]} "Bagging-Date: ${bagging_date}");
       echo -n "Identifier for the bag: ";
       read external_identifier;
       bag_info=(${bag_info[@]} "External-Identifier: ${external_identifier}");
       echo -n "Approx size of the bag: ";
       read bag_size;
       bag_info=(${bag_info[@]} "Bag-Size: ${bag_size}");
       echo -n "Octet stream of payload: ";
       read payload_oxum;
       bag_info=(${bag_info[@]} "Payload-Oxum: ${payload_oxum}");
       echo -n "Identifier for the group or data: ";
       read bag_group_identifier;
       bag_info=(${bag_info[@]} "Bag-Group-Identifier: ${bag_group_identifier}");
       echo -n "Bag number in series (e.g. 2 of 5): ";
       read bag_count;
       bag_info=(${bag_info[@]} "Bag-Count: ${bag_count}");
       echo -n "Alternate identifier for content: ";
       read internal_sender_identifier;
       bag_info=(${bag_info[@]} "Internal-Sender-Identifier: ${internal_sender_identifier}");
       echo -n "Internal description of the contents of the bag ";
       read internal_sender_description;
       bag_info=(${bag_info[@]} "Internal-Sender-Description: ${internal_sender_description}");
   fi
   return 0;
}

if [ -z ${GITBAGIT} ]; then
    GITBAGIT=${PWD};
fi

bagit_data="/data";
bagit_tags="/tags";
pre_commit_file="${GITBAGIT}/pre-commit";
directory="";
forceFlag=0;

while getopts "hf" OPTION
do
    case $OPTION in
        h) usage
            ;;
        f) forceFlag=1
    esac
done

shift $((OPTIND-1));

directory=$1;
bag_info_file="$directory/bag-info.txt";
git_hook_dir="${directory}/.git/hooks";

if [ ! -f "${pre_commit_file}" ]; then
    echo "ERROR: File ${pre_commit_file} does not exist or cannot be read";
    echo "Please set the permissions on the file and/or set the GITBAGIT environment";
    echo "variable";
    exit 1;
fi

if [ -z "${directory}" ]; then
    echo "You must specify a target directory for the repository";
    echo "Use the '-h' option for help";
    exit 1;
fi

if [ -d "$directory" ] && [ $forceFlag -eq 0 ]; then
    echo "Warning: Directory exists. Use '-f' option to force override";
    echo "Use the '-h' option for help";
    exit 0;
fi

if [ -f ${bag_info_file} ]; then
    echo "WARNING: ${bag_info_file} already exists! The contents will be overwritten";
    echo "Use the '-h' option for help";
    echo "Do you wish to continue?";
    select yn in "Yes" "No"; do
       case $yn in
           Yes ) break;;
           No ) exit 0;;
       esac
   done
fi

if [ $forceFlag -eq 0 ]; then
    mkdir "$directory";
fi
if [ ! -d "${directory}${bagit_tags}" ]; then  
    mkdir "${directory}${bagit_tags}";
fi

if [ ! -d "${directory}${bagit_data}" ]; then
    mkdir "${directory}${bagit_data}";
fi

bag_info=();

OIFS="${IFS}";
IFS=$'\n';

collect_bag_input;

if [ -f ${bag_info_file} ]; then
    /bin/rm ${bag_info_file};
fi

for line in ${bag_info[@]}; do
    echo ${line} >> ${bag_info_file};
done

IFS=${OIFS};

printf "BagIt-Version: 0.97\nTag-File-Character-Encoding: UTF-8" > "$directory/bagit.txt";

git init "$directory";

cp ${pre_commit_file} ${git_hook_dir} 
echo "";
echo "-------------------------------------------------------------------";
echo "Finished setting up the repository. You will need to run 'git add'";
echo "and 'git commit' to commit files to the repository. Please see the";
echo "git manual for more information";
echo "-------------------------------------------------------------------";
echo "";
exit 0;
