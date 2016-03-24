#!/bin/bash


# generic AGOSP shell functions
# Automated SMF authorisation property script
# Uses Root access to configure pre-existing FMRIs!
check_for_root() {
    ROOT_UID=0	# Only users with $UID 0 have root privileges.
    E_NOTROOT=101	# Non-root exit error.

# Confirm that Root Access has been obtained
    if [ "$UID" -ne "$ROOT_UID" ]
    then
	echo "Must be root to run this script."
	exit $E_NOTROOT
    fi
}


#
# identify_machine sets the MACHINE variable to be the type of machine
# we are creating users for. As new machines are added, they should
# be updated in the case according to the role they are too play.
#
identify_machine()
{
  # redacted: classified
}

#
# generic check_and_create_user() function:
# Takes 4 arguments - User Name, User Id, Group Name and User Comment
#
# If User Name and User Id exist, then Group will be added to Groups for that user.
# Otherwise it will create a new user based on parameters supplied.
# Home directory is /export/home/username. Shell is set to be BASH 
#
# User is added to the application groups as appropriate for the
# machine. These groups are assumed to exist already.
#
# User is granted agosp.smf.action privilege, which will allow them to
# temporarily disable/enable SMF services for AGOSP FMRIs
#
check_and_create_user()
{
	grep ^${1}:x:${2}: /etc/passwd &> /dev/null

	if [ $? -eq 0 ]
	then
		echo User ${1} wtih user id ${2} already exists. Group ${3} membership will be added.
		usermod -G ${3} ${1}
	else
		grep ^${1}:x: /etc/passwd &> /dev/null
		if [ $? -eq 0 ]
		then
			echo WARNING: User ${1} already exists with different user id.
			return
		fi

		grep ^.*:x:${2}: /etc/passwd  &> /dev/null
		if [ $? -eq 0 ]
		then
			echo WARNING: User Id ${2} is assigned to a different user than ${1}.
			return
		fi

		echo The user ${1} does not exist with user id ${2}, and will be created. Login as user ${1} to set password at first login.
		useradd -u${2} -s /usr/bin/bash -g ${3} -m -d /export/home/${1} -c"${4}" ${1}
		passwd -d -f ${1}

		if [ -e ${1}_bash_profile ]
		then
			echo Copying Bash Profile to user directory
			cp ${1}_bash_profile /export/home/${1}/.bash_profile
			chown ${1}:${3} /export/home/${1}/.bash_profile
		fi
	fi
}


#
# check_and_create_group() function:
# Takes 2 arguments - Group Name and Group Id
#
# Will create a new group with specified group id if neither are in use.
#
check_and_create_group()
{
	grep ^${1}::${2}: /etc/group &> /dev/null

	if [ $? -eq 1 ]
	then
		grep ^${1}:: /etc/group &> /dev/null
		if [ $? -eq 0 ]
		then
			echo WARNING: Group ${1} already exists with different group id.
			return
		fi

		grep ::${2}: /etc/group &> /dev/null
		if [ $? -eq 0 ]
		then
			echo WARNING: Group Id ${2} is assigned to a different group than ${1}.
			return
		fi
		
		echo The group ${1} does not exist with group id ${2}, and will be created.
		groupadd -g${2} ${1}
	else
		echo Group ${1} wtih group id ${2} already exists and no actions need be done.
	fi
}


add_admin_users_groups() {
# set additional groups for specified user, and make sure the group exists

    # redacted: classified
}
