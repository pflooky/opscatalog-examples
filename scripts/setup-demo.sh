cwd=$(dirname "$0")
cp $cwd/demo/*.yaml $cwd/../datasets/my-account/

kubectl get sts cassandra >/dev/null 2>&1
if [[ $? -eq 0 ]];
then 
  echo creating a new schema "FAQ"
  kubectl exec -it cassandra-0 -- cqlsh -e "create keyspace if not exists faq with replication={'class':'SimpleStrategy', 'replication_factor':1};"
fi;

kubectl get sts postgres >/dev/null 2>&1
if [[ $? -eq 0 ]];
then 
  echo creating a new schema in postgres
  kubectl exec -it postgres-0 -- psql -Upostgres -dservicing -c 'CREATE SCHEMA IF NOT EXISTS refdata;' 
fi;

kubectl get sts kafka >/dev/null 2>&1
if [[ $? -eq 0 ]];
then 
  echo creating new topic
  kubectl exec -it kafka-0 -- kafka-topics.sh --create --if-not-exists --topic jobs.dlq --bootstrap-server kafka:9092 --replication-factor 1
fi;
