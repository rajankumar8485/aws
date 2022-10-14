import urllib3
def lambda_handler(event, context):
    http = urllib3.PoolManager()
    r = http.request('GET', 'https://11v3yvpa10.execute-api.us-east-1.amazonaws.com/api/b2b/batch/trigger')
    r.status
    # 200