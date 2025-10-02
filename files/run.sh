#!/bin/bash
set -euo pipefail

DBCONF="/gitbucket/database.conf"
JAVA17="/usr/lib/jvm/java-17-openjdk-amd64/bin/java"

# Check if config file exists
if [[ -f "$DBCONF" ]]; then
    echo "[INFO] Found $DBCONF"

    # Check if url line contains MVCC=true (case-insensitive)
    if grep -iEq '^[[:space:]]*url[[:space:]]*=.*MVCC=true' "$DBCONF"; then
        echo "[INFO] Detected MVCC=true in config. Starting migration process..."
	

        # Step 1: Export DB using old H2 (1.4.199)
        echo "[INFO] Exporting database with H2 1.4.199..."
        $JAVA17 -cp /migration/h2-1.4.199.jar org.h2.tools.Script \
            -url "jdbc:h2:/gitbucket/data" -user sa -password sa \
            -script /migration/dump.sql
        echo "[INFO] Export completed. Dump saved at /migration/dump.sql"

        # Step 2: Import DB into a NEW file with H2 2.3.232
        echo "[INFO] Importing dump into new H2 2.3.232 database..."
        $JAVA17 -cp /migration/h2-2.3.232.jar org.h2.tools.RunScript \
            -url "jdbc:h2:/gitbucket/data_new" -user sa -password sa \
            -script /migration/dump.sql
        echo "[INFO] Import completed. New DB created at /gitbucket/data_new.mv.db"

        # Step 3: Swap databases
        echo "[INFO] Replacing old database with migrated one..."
        rm -f /gitbucket/data.mv.db /gitbucket/data.trace.db || true
        mv /gitbucket/data_new.mv.db /gitbucket/data.mv.db
        if [[ -f /gitbucket/data_new.trace.db ]]; then
            mv /gitbucket/data_new.trace.db /gitbucket/data.trace.db
        fi
        echo "[INFO] Database successfully migrated."

        # Step 4: Clean config (remove MVCC=true)
        echo "[INFO] Cleaning MVCC=true from $DBCONF..."
        sed -i -E 's/;[[:space:]]*MVCC=true//Ig; s/MVCC=true//Ig' "$DBCONF"
        echo "[INFO] Config cleaned."

    else
        echo "[INFO] No MVCC=true found in config. Migration not required."
    fi
else
    echo "[INFO] No database.conf found. Skipping migration."
fi

echo "[INFO] Starting GitBucket..."
exec $JAVA17 -jar /opt/gitbucket/gitbucket.war


