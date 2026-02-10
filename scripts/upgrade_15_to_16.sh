#!/bin/bash
set -e

SRC_DB=odoo15
TGT_DB=odoo16
BACKUP=/tmp/${SRC_DB}_$(date +%F).sql.gz

echo "Dumping Odoo 15..."
pg_dump -U odoo $SRC_DB | gzip > $BACKUP

echo "Creating Odoo 16 DB..."
dropdb -U odoo $TGT_DB || true
createdb -U odoo $TGT_DB
gunzip -c $BACKUP | psql -U odoo $TGT_DB

echo "Running OpenUpgrade 15 → 16..."
cd /opt/odoo/openupgrade16
source venv/bin/activate
./venv/bin/python server/odoo-bin \
  -c odoo16.conf \
  -d $TGT_DB \
  --upgrade-path=OpenUpgrade/openupgrade_scripts/scripts \
  --update=all \
  --stop-after-init \
  --load=base,web,openupgrade_framework

echo "Migration completed. Checking version..."
psql -U odoo -d $TGT_DB -Atc "SELECT latest_version FROM ir_module_module WHERE name='base';"
