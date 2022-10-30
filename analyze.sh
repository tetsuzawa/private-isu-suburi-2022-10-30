#!/usr/bin/env bash

set -eux
cd `dirname $0`

################################################################################
echo "# Analyze"
################################################################################

# read env
# 計測用自作env
. /tmp/prepared_env

# isucon serviceで使うenv
. ./env.sh

result_dir=$HOME/result
mkdir -p ${result_dir}

units="-u mysql -u nginx -u isu-go"
sudo journalctl -x ${units} --since="${prepared_time}"  > "${result_dir}/journal.log"
#sudo journalctl -x ${units} --since="${prepared_time}" | gzip -9c > "${result_dir}/journal.log.gz"

# alp
ALPM="/posts/\d+$,/image/\d+.(jpg|png|gif),/@[a-zA-Z]+,/posts?[a-zA-Z0-9=%]+"
OUTFORMT=count,1xx,2xx,3xx,4xx,5xx,method,uri,min,max,sum,avg,p95,min_body,max_body,avg_body
alp ltsv --file=${nginx_access_log} \
  --nosave-pos \
  --sort sum \
  --reverse \
  --output ${OUTFORMT} \
  --format markdown \
  --matching-groups ${ALPM}  \
  --query-string \
  > ${result_dir}/alp.md

# mysqlowquery
#sudo mysqldumpslow -s t ${mysql_slow_log} > ${result_dir}/mysqld-slow.txt

pt-query-digest --explain "h=${DB_HOST},u=${DB_USER},p=${DB_PASS},D=${DB_DATABASE}" ${mysql_slow_log} \
  > ${result_dir}/pt-query-digest.txt
#pt-query-digest ${mysql_slow_log} > ${result_dir}/pt-query-digest.txt
