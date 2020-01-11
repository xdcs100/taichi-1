#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread

TAICHI_LOG=/data/local/tmp/taichi.log
logcat > ${TAICHI_LOG} &
LOGCAT_PID=$!

log() {
  echo "[$(date +"%H:%M:%S:%3N %d-%m-%Y")] $1" | tee -a ${TAICHI_LOG}
}

timeout=10
WATCH_FILE=/data/misc/taichi
while ((timeout > 0)) && [[ ! -f ${WATCH_FILE} ]];
do
   sleep 1
   ((timeout -= 1))
done

if [[ ! -f ${WATCH_FILE} ]]; then
  setprop ctl.restart zygote_secondary
else
  rm ${WATCH_FILE}
fi

max_wait=300
interval=1
BOOT_COMPLETED=false
while [[ "$max_wait" -gt 0 ]]; do
  if [[ "$(getprop sys.boot_completed)" = "1" ]];then
    BOOT_COMPLETED=true
    log "BOOT_COMPLETED"
    break
  fi
  sleep ${interval}
  log "WAIT FOR BOOT_COMPLETE"
  max_wait=$((max_wait-1))
done

ENFORCE_FILE=/data/misc/taichi_enforce
if [[ -f ${ENFORCE_FILE} ]] && [[ "${BOOT_COMPLETED}" = "true" ]];then
  log "RESTORE SELinux"
  rm ${ENFORCE_FILE}
  setenforce 1
fi

kill ${LOGCAT_PID}
