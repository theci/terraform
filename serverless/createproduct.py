# import the json utility package since we will be working with a JSON object
import json
# import the AWS SDK (for Python the package name is boto3)
import boto3
# import two packages to help us with dates and date formatting
from time import gmtime, strftime
import uuid


PARTITION_KEY = 'user_id'

def lambda_handler(event, context):
    # AWS SDK의 DynamoDB 클라이언트를 생성합니다.
    user_id=uuid.uuid4()
    now = strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
    dynamodb = boto3.client('dynamodb')
#    user_id = event['user_id']
    name = event['Name']
    phone = event['phoneNumber']
    try:
        # PutItem 작업에 필요한 매개변수를 구성합니다.
        params = {
            'TableName': 'UserTable',  # 테이블 이름을 적절히 변경하세요.
            'Item': {
                'user_id': {'S': str(user_id)},  # 테이블의 키 필드와 값을 적절히 변경하세요.
                'Name': {'S': name},
                'Phone': {'S': phone},
                'Time': {'S': now},
                # 추가적인 속성 및 값을 필요에 따라 정의할 수 있습니다.
            }
        }

        # PutItem 작업을 수행합니다.
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
