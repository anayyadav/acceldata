from flask import Flask, request, Response, jsonify, flash
import lib.handler as handler
import logging.config
from config.logs import logging_config
logging.config.dictConfig(logging_config)

app = Flask(__name__)

@app.route('/create', methods=['POST'])
def createUser():
    log = logging.getLogger(__name__)
    # Handle webhook request here
    payload = request
    #print(request)
    respone = handler.createuser(payload)
    return respone

@app.route('/update', methods=['PUT'])
def updateUserDetails():
    log = logging.getLogger(__name__)
    # Handle webhook request here
    payload = request.json
    handler.updateUserInfo(payload)
    return Response(status=200)


@app.route('/delete/<id>', methods=['DELETE'])
def deleteUserDetails(id):
    log = logging.getLogger(__name__)
    respone = handler.deleteUser(id)
    return respone

@app.route('/user', methods=['GET'])
def getAllUserDetails():
    log = logging.getLogger(__name__)
    respone = handler.getAllUserDetails()
    return respone

@app.route('/user/<id>', methods=['GET'])
def getUserDetails(id):
    log = logging.getLogger(__name__)
    respone = handler.getUserDetails(id)
    return respone

@app.errorhandler(404)
def showMessage(error=None):
    message = {
        'status': 404,
        'message': 'Record not found: ' + request.url,
    }
    respone = jsonify(message)
    respone.status_code = 404
    return respone

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
