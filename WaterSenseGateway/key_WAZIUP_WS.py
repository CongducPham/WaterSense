####################################################
#server: CAUTION must exist
waziup_server="http://broker.waziup.io/v2"

#project name
project_name="watersense"

#your organization: CHANGE HERE
organization_name="FARM1"

#service tree: CHANGE HERE at your convenience
#should start with /
service_tree='/TESTS'

#sensor name: CHANGE HERE but maybe better to leave it as Sensor
#the final name will contain the sensor address
sensor_name="WS_"+organization_name+"_Sensor"

#service path: DO NOT CHANGE HERE
service_path='/'+organization_name+service_tree

#SUMMARY
#the entity name will then be sensor_name+scr_addr, e.g. "WS_FARM1_Sensor2"
#the Fiware-ServicePath will be service_path which is based on both organization_name and service_tree, e.g. "/FARM1/TESTS"
#the Fiware-Service will be project_name, e.g. "watersense"

source_list=[]
####################################################