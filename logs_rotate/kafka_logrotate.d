/var/log/kafka/kafka*.log.* {
  daily
  missingok
  rotate 5
  compress
  delaycompress
  copytruncate
  notifempty
}
