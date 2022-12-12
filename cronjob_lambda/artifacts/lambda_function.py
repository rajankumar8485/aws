import urllib3
import os
apigw_hostname = os.environ['hostname']
url="https://"+apigw_hostname+"/api/b2b/batch/trigger"
def lambda_handler(event, context):
    http = urllib3.PoolManager()
    r = http.request('GET', url)
    r.status