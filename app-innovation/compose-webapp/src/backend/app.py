from flask import Flask, request, jsonify
import redis

app = Flask(__name__)
r = redis.Redis(host='redis', port=6379, db=0)

@app.route('/set', methods=['POST'])
def set_value():
    key = request.json.get('key')
    value = request.json.get('value')
    r.set(key, value)
    return jsonify({"message": "Value set successfully"}), 200

@app.route('/get/<key>', methods=['GET'])
def get_value(key):
    value = r.get(key)
    if value:
        return jsonify({"key": key, "value": value.decode('utf-8')}), 200
    else:
        return jsonify({"message": "Key not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)