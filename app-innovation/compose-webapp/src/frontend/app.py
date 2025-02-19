from flask import Flask, request, jsonify, render_template_string
import requests
import os

backend = os.getenv("BACKEND", "http://localhost:8080")

app = Flask(__name__)

@app.route('/')
def index():
    # HTML template with form and table
    html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Simple Web App</title>
    </head>
    <body>
        <h1>Simple Web App</h1>
        <h2>Set Value</h2>
        <form id="valueForm">
            <label for="key">Key:</label>
            <input type="text" id="key" name="key" required>
            <label for="value">Value:</label>
            <input type="text" id="value" name="value" required>
            <button type="submit">Submit</button>
        </form>
        <h2>Get Value</h2>
        <form id="getValueForm">
            <label for="getKey">Key:</label>
            <input type="text" id="getKey" name="getKey" required>
            <button type="submit">Submit</button>
        </form>
        <div id="showValue"></div>
        <h2>Values</h2>
        <table id="valuesTable" border="1">
            <thead>
                <tr>
                    <th>Key</th>
                    <th>Value</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
        <script>
            document.getElementById('valueForm').onsubmit = function(event) {
                event.preventDefault();
                const key = document.getElementById('key').value;
                const value = document.getElementById('value').value;
                fetch('/set', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ key: key, value: value })
                }).then(response => response.json()).then(data => {
                    if (data.message === 'Value set successfully') {
                        const table = document.getElementById('valuesTable').getElementsByTagName('tbody')[0];
                        const newRow = table.insertRow();
                        const cellKey = newRow.insertCell(0);
                        const cellValue = newRow.insertCell(1);
                        cellKey.textContent = key;
                        cellValue.textContent = value;
                    }
                });
            };
            document.getElementById('getValueForm').onsubmit = function(event) {
                event.preventDefault();
                const key = document.getElementById('getKey').value;
                fetch(`/get/${key}`).then(response => response.json()).then(data => {
                    document.getElementById('showValue').textContent = `Key: ${data.key}, Value: ${data.value}`;
                });
            };
        </script>
    </body>
    </html>
    '''
    return render_template_string(html)

@app.route('/set', methods=['POST'])
def set_value():
    # send a rest post request to the backend
    requests.post(backend + '/set', json=request.json)
    return jsonify({"message": "Value set successfully"}), 200

@app.route('/get/<key>', methods=['GET'])
def get_value(key):
    value = requests.get(backend + '/get/' + key)
    if value:
        return value.json(), 200
    else:
        return jsonify({"message": "Key not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)