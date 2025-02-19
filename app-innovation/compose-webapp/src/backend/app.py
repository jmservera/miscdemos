from flask import Flask, request, jsonify
import redis
import os

redishost = os.getenv("REDISHOST", "localhost")

app = Flask(__name__)
r = redis.Redis(host=redishost, port=6379, db=0)

@app.route('/health', methods=['GET'])
def health():
    # check if the redis server is healthy
    try:
        r.ping()
    except redis.ConnectionError:
        return jsonify({"message": "Unhealthy"}), 500

    return jsonify({"message": "Healthy"}), 200

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
    app.run(host='0.0.0.0', port=8080)