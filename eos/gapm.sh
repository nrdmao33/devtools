#!/usr/bin/bash
# Git Archive and Patch Manager
#

function find_archive {
    # get the name of the file that is serving as the archive for the
    # specified PACKAGE and REPO. Assumed file name is ether ${REPO}-*.tar.gz or
    # v*.tar.gz in that order.
    #
    PACKAGE=$1
    REPO=$2
    ARCHIVE=$(ls ${PACKAGE}/${REPO}-*.tar.gz 2> /dev/null)
    if [ -n "${ARCHIVE}" ]
    then
        echo $ARCHIVE
        return
    fi
    ARCHIVE=$(ls ${PACKAGE}/v*.tar.gz 2> /dev/null)
    echo $ARCHIVE
    return
}

function find_url {
    # Get the name of the URL for this repo. This is gotten from the .spec
    # file and if the package and the repo are of the same name it is assumed
    # to be the URL associated with the URL: tag. Else it is assumed to be
    # the defined by a variable of the form <repo>_git_url.
    #
    PACKAGE=$1
    REPO=$2
    PACKAGE_BASENAME=$3
    SPEC_FILE=${PACKAGE}/${PACKAGE_BASENAME}.spec
    if [ ! -f $SPEC_FILE ]
    then
        return
    fi
    if [ $REPO = $PACKAGE_BASENAME ]
    then
        awk '$1 == "URL:" {print $2}' $SPEC_FILE
    else
        # In this case we assume a variable named {REPO}_git_url defined in the
        # .spec file
        awk '$1 == "%define" && $2 == "'${REPO}'_git_url" { print $3 }' $SPEC_FILE
    fi
    return
}

function branch_exists {
    # Determine is the branch specified in $1 exists in the current repo
    #
    BRANCH_NAME=$1
    test ! -z "$(git branch | grep ' '$BRANCH_NAME'$')"
    return $?
}

function branch_current {
    # determine if we are currently on the specified branch
    #
    BRANCH_NAME=$1
    test ! -z "$(git branch | grep '\* '$BRANCH_NAME'$')"
    return $?
}

function branch_contains {
    # Determin if the specified branch contains the specified commit_id
    #
    BRANCH_NAME=$1
    COMMIT_ID=$2
    test ! -z "$(git branch -a --contains $COMMIT_ID 2>/dev/null | grep ' '$BRANCH_NAME'$')"
    return $?
}

IAM=$(basename $0)
HELP="$IAM --help : for more information" 
USAGE="
$IAM [options] -m|--make [archive|repo]

Git archive and patch manager.

 -m|--make [archive|repo]      Make either the archive or the repo.
 -p|--package <package>        The name of the Arista package or the directory
                               containing the package files. If the package name is
                               specified, the directory is assumed to be
                               /src/<package>. If not specified, the current
                               directory is assumed.
 -r|--repo <repo>              The name of the repo. If not specified the basename
                               of the package directory is assumed.
 -c|--commit-id <commit_id>    With --make archive, the commit id from which the
                               archive and patches should be generated.
                               With --make repo, the commit id to which the existing
                               patches should be applied. The default commit_id is
                               gotten from the existing archive file if it exists.
                               Note that a commit ID can be a git commit hash or 
                               a tag.
 -f|--force                    Force the deletion of arista branch if needed.
 -h|--help                     Generate this help message and exit.

This program helps to manage the following:
- The creation of git repos from git archives and a collection of patches.
- The creation of git archives and patches from a git repo.

Discussion:
This program is built around the assumption that an Arista rpmsource package
is constructed from a git archive and a set of patches applied to that
archive. The archive is expanded and patches applied by the <package>.spec file.

Git tools are used to manage the git archives and patches. git archive is used
to build the archive from a particlar commit id. git format-patch is used to
generate a set of patched from the specified commit id to the head of the repo.
The assumption here is that a public git repo is cloned and branched to a
specified commit id. This commit id usually represents a stable version of the
repo. Local commits are then made to the repo. From these commits a set of patches
can then be generated.

The archive and the patches are added to the perforce repo along with the
.spec file used to build them. Subsequently, when another developer comes along
and needs to fix a bug in the package, they can generate a local repo from the
added git archive, the set of patches and the public git repo URL. Specifically
the git archive is used  to find the commit ID. The URL for the public git repo
is found from either the URL: tag in the .spec file (if the spec file name
matches the repo name) or from a defined variable of the form <repo>_git_url
in the .spec file (used when there is more than one repo per .spec file).

File Naming Conventions:
The following file naming conventions are based on what is typically done
in the open source community for git archives. The git archive should be named:

v<commit-id>.tar.gz when the repo name matches the package name.
<repo>-<commit-id>.tar.gz for all other cases.

The <commit-id> is either the 7 character git hash or a tag on the repository
which is typically specified as X.Y.Z .

Workflows:
Add a new package:
1. a4 project newpackage --rpmsource <pkg>; cd /src/<pkg>
2. copy the git archive from the public git-hub to the new package directory.
2a. or clone the git repository and checkout the version if interest.
2b. build the git archive using this program: gapm --make archive
3. Update the .spec file to include the Version: and Source0: and
    URL: information. URL: should be the the URL that can be passed to git
    clone to pull down the git repo.
4. a4 add the .spec file and the archive.

Apply local mods to a package built as defined above:
1. cd /src/<pkg>; gamp --make repo
2. Change files to the local repo, git commit, gamp --make archive
3. a4 add new patch files generated, a4 edit .spec file to include new patches.

Update a package to a new version of the public repo:
1. cd /src/<pkg>; gamp --make repo
2. cd <repo>; git checkout <new-commit-id>
3. if there were any patches, git merge local changes to new commit ID, the local
   changes should be at a tag called arista.
4. a4 edit all existing patch files.
5. gamp --make archive --commit-id <new-commit-id>
6. a4 add <new-archive-file>; a4 delete <old-archive-file>
7. a4 edit <pkg>.spec with new Version: and SourceN: information.

"

MAKE=
PACKAGE=
REPO=
COMMIT_ID=
COMMIT_ID_SPECIFIED=0
FORCE=0

TEMP=$(getopt -l 'make:,package:,repo:,commit-id:,force,help' -o 'm:p:r:c:fh' -- "$@")
if [ $? != 0 ]
then
    echo "$HELP"
    exit 1
fi

set -- $TEMP
while true
do
    case $1 in
        -m|--make)
            case $2 in
                \'archive\') MAKE=archive ; shift 2 ;;
                \'repo\') MAKE=repo ; shift 2 ;;
                *)
                    echo "Make type must be archive or repo, you specified: $2"
                    echo "$HELP"
                    exit 1
                    ;;
            esac ;;
        -p|--package)
            PACKAGE="${2//\'/}" ; shift 2 ;;
        -r|--repo)
            REPO="${2//\'/}" ; shift 2 ;;
        -c|--commit-id)
            COMMIT_ID="${2//\'/}" ; shift 2
            COMMIT_ID_SPECIFIED=1 ;;
	-f|--force)
	    FORCE=1 ; shift ;;
        -h|--help)
            echo "$USAGE" | more
            exit 0
            ;;
        --) shift ; break ;;
    esac
done

if [ -z "$PACKAGE" ]
then
    PACKAGE="$(pwd)"
elif [ "$PACKAGE" = "${PACKAGE//\/}" ]
then
    PACKAGE=/src/$PACKAGE
fi

if [ ! -d "$PACKAGE" ]
then
    echo "No such package: $PACKAGE"
    echo "$HELP"
    exit 1
fi

PACKAGE_BASENAME=$(basename "${PACKAGE}")
if [ -z "$REPO" ]
then
    REPO=$PACKAGE_BASENAME
fi

echo PACKAGE="$PACKAGE" MAKE="$MAKE" REPO="$REPO" COMMIT_ID="$COMMIT_ID"

cd "$PACKAGE"
if [ -z "$COMMIT_ID" ]
then
    ARCHIVE=$(find_archive $PACKAGE $REPO)
    if [ -z "$ARCHIVE" ]
    then
        echo "Commit ID not specified and cannot find archive file."
	echo "$HELP"
        exit 2
    fi
    COMMIT_ID=$(zcat $ARCHIVE 2> /dev/null | git get-tar-commit-id)
    if [ $? != 0 ]
    then
        echo "Cannot get commit id from archive: $ARCHIVE"
	echo "$HELP"
        exit 2
    fi
fi

if [ $MAKE = repo ]
then
    # Make the repo from the archive
    #
    URL=$(find_url $PACKAGE $REPO $PACKAGE_BASENAME)
    if [ -z "$URL" ]
    then
        echo "Cannot get URL from .spec file"
	echo "$HELP"
        exit 2
    fi
    
    PATCH_LIST=$(ls ${REPO}-*.patch 2> /dev/null)
    
    git clone "$URL" $REPO
    RET=$?
    if [ $RET != 0 ]
    then
        echo "Cannot clone repo $REPO. Clone URL=${CLONE_URL[$REPO]}"
	echo "$HELP"
        exit 1
    fi
    
    cd $REPO
    git branch arista $COMMIT_ID
    git checkout arista
    # Apply all the patches
    for PATCH in $PATCH_LIST
    do
        git am ../$PATCH
    done
else
    # Make the patches and optionally a new archive from the repo
    #
    if [ ! -d $REPO ]
    then
        echo "Git repo: $REPO not found in $PACKAGE"
	echo "$HELP"
        exit 2
    fi
    ARCHIVE=$(find_archive $PACKAGE $REPO)
    cd $REPO
    if [ $COMMIT_ID_SPECIFIED = 1 ]
    then
	# IF a commit ID is specified we assume that the archive must be created
	#
	if ! branch_exists arista
	then
	    echo "No arista branch in repo. Creating arista branch at "\
		 "commit-id ${COMMIT_ID}"
	    git branch arista ${COMMIT_ID}
	    git checkout arista
	elif ! branch_contains arista $COMMIT_ID
	then
	    echo "WARNING: arista branch does not contain commit-id ${COMMIT_ID}"
	    echo "deleting existing arista branch and moving it to ${COMMIT_ID}"
	    if branch_current arista
	    then
		git checkout master
	    fi
	    if [ $FORCE == 1 ]
	    then
		DELETE_OPTION='-D'
	    else
		DELETE_OPTION='-d'
	    fi
	    if ! git branch $DELETE_OPTION arista
	    then
		echo "$HELP"
		echo "Cannot remove existing branch. Use --force to override."
		exit 2
	    fi
	    git branch arista ${COMMIT_ID}
	    git checkout arista
	elif ! branch_current arista
	then
	    echo "Using the existing arista branch as it contains the commit-id"
	    git checkout arista
	fi
        # Note, by convention, most repos tag versions as vM.N.O. However,
        # archives are typically named ${REPO}-M.N.O and archives are prefixed
        # similarly. Therefore any leading 'v' is eliminated from ${COMMIT_ID}.
        # If ${COMMIT_ID} is actually a hash, this trimming has no effect since
        # 'v' is not a hex character.
        ARCHIVE=${REPO}-${COMMIT_ID##v}.tar.gz
	echo "Creating archive: $ARCHIVE"
        git archive --output ../${ARCHIVE} --prefix ${REPO}-${COMMIT_ID##v}/ \
	    ${COMMIT_ID}
        RET=$?
        if [ $RET != 0 ]
        then
	    echo "$HELP"
            echo "Cannot generate archive file. git archive returned: $RET"
            exit 2
        fi
    else
	# The archive is not being generated. In this case we are just creating
	# the patches. The patches are created from the arista branch at the
	# commit ID.
	if ! branch_exists arista
	then
	    # Note, by creating the arista branch at the commit ID, we will not
	    # generate any patches.
	    echo "Warning: no existing arista branch, a branch is being created"
	    echo "but no patches will be generated since there are no commits"
	    echo "on the newly created branch"
	    git branch arista ${COMMIT_ID}
	fi
	if ! branch_current arista
	then
	    git checkout arista
	fi
    fi
    # Generate the patches
    git format-patch $COMMIT_ID
    for i in $(ls *.patch 2> /dev/null)
    do
	TARGET="../${REPO}-$i"
	if [ -f $TARGET -a ! -w $TARGET ]
        then
            echo "WARNING: Patch file: ${TARGET} "
	    echo "could not be created in the package dir."
            echo "Perhaps the existing patch file has not been checked out?"
            echo "This may be OK if you have no need to update the existing patch."
	    echo ""
	    rm $i
	else
            mv $i $TARGET
        fi
    done
fi
exit 0
