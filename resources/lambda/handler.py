def main (event, context):
	print ("Hola! Somos el grupo 6")

	resp = {
		"statusCode": 200,
		"headers": {
			"Access-Control-Allow-Origin": "*",
		},
		"body": "Esta es la lambda en acción"
	}

	return resp