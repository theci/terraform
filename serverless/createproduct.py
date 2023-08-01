import json
import boto3
from time import gmtime, strftime
import uuid


PARTITION_KEY = 'user_id'

def lambda_handler(event, context):
    user_id=uuid.uuid4()
    now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
    dynamodb = boto3.client('dynamodb')
    name = event['Name']
    phone = event['phoneNumber']
    try:
        params = {
            'TableName': 'UserTable',  # 테이블 이름
            'Item': {
                'user_id': {'S': str(user_id)},  # 테이블의 키 필드와 값
                'Name': {'S': name},
                'Phone': {'S': phone},
                'Time': {'S': now},
            
            }
        }

        response = dynamodb.put_item(**params)
        print('PutItem 성공:', response)

        return {
            'statusCode': 200,
            'body': 'PutItem 작업이 성공적으로 완료되었습니다.'
        }
    except Exception as e:
        print('PutItem 실패:', e)
        return {
            'statusCode': 500,
            'body': 'PutItem 작업이 실패했습니다.'
        }

