#!/bin/bash -x

set -e

# set odoo database host, port, user and password
HOST='db'
PORT='5432'
USER='odoo'
PASSWORD='odoo'

DB_ARGS=("--db_user" $USER "--db_password" $PASSWORD "--db_host" $HOST "--db_port" $PORT)

# generate password if it is not set
: ${ODOO_MASTER_PASS:=`< /dev/urandom tr -dc A-Za-z0-9 | head -c16;echo;`}

# update password in config file
sed -i -e "s/^admin_passwd.*/admin_passwd = $ODOO_MASTER_PASS/" $OPENERP_SERVER

if [[ "$RESET_ADMIN_PASSWORDS_ON_STARTUP" == "yes" ]]
then
    NEW_ADMIN_PASSWORD=$ODOO_MASTER_PASS \
    PGHOST=$HOST \
    PGPORT=$PORT \
    PGUSER=$USER \
    PGPASSWORD=$PASSWORD \
    python /reset-admin-passwords.py
fi

case "$1" in
	  -- | openerp-server | /mnt/odoo-source/odoo-bin)
		    shift
		    exec /mnt/odoo-source/odoo-bin "${DB_ARGS[@]}" "$@"
		    ;;
	  -*)
		    exec /mnt/odoo-source/odoo-bin "${DB_ARGS[@]}" "$@"
		    ;;
	  *)
		    exec "$@"
esac

exit 1
