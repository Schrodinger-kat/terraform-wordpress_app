
project_id = "gcp-training-01-303001"
vpc        = "jishnn-wp"
mig_name   = "jishnn-mig"
load_balancer = "jishnn-lb"

#InstanceGroupConfig
targetsize = "2"

#Autoscalerconfig
max = "3"
min = "1"
cpu_targetUtil = "0.7"

#CloudSQL
db_instname = "wpdb-inst"
db_name = "wordpressdb"
usrname = "jishnn"

 