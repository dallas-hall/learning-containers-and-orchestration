from flask import Flask, request
from flask_restx import Resource, Api

app = Flask(__name__)
app.config.SWAGGER_UI_DOC_EXPANSION = "list"
app.config.SWAGGER_UI_OPERATION_ID = True
app.config.SWAGGER_UI_REQUEST_DURATION = True

api = Api(app,
        version="1.0",
        title="Simple API",
        description="My Simple API, returning XML or JSON.",
        prefix="/v1",
        contact_email="root@localhost",
        contact="root@localhost",
        contact_url="http://localhost"
        )

ns = api.namespace("hello", description="hello namespace")

@ns.route("/")
class HelloWorld(Resource):
	@ns.produces(["application/json", "application/xml"])
	def get(self):
		if request.headers.get("Accept", None) == "application/xml":
			return {"hello": "xml"}
		else:
			return {"hello": "json"}

if __name__ == "__main__":
	app.run(debug=False)
