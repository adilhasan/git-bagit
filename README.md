git-bagit
=========

Repository of scripts to create a git repository that follows the bagit 
structure (see http://tools.ietf.org/html/draft-kunze-bagit-09). 

Bagit is a proposed standard hierarchical file packaging format for storing 
digital content.

Usage
-----
* To create a repository "test-repo" run the script:
    ./git_bagit_init.sh test-repo

This will create a git repository with a "data" and "tags" subdirectory as well as the files "bag-info.txt" and "bagit.txt". The script will also copy the pre-commit hook script "pre-commit" which ensures the manifest files are populated upon commit.

