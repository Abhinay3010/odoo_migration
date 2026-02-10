#!/bin/bash
set -e

BACKUP=$(ls -t /opt/odoo/backups/odoo15_*.sql.gz | head -1)
dropdb -U odoo odoo15 || true
createdb -U odoo odoo15
gunzip -c $BACKUP | psql -U odoo odoo15
echo "Rollback done. Start Odoo 15 UI on port 8015"
