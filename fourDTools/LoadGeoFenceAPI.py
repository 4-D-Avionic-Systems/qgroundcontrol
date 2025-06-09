from flask import Flask, jsonify
import time

app = Flask(__name__)

@app.route('/GeoFence/Load', methods=['GET'])
def get_geo_fence():
    data = {
        "circles": [
            {
                "circle": {
                    "center": [39.203088474235386, -96.54889591934848],
                    "radius": 2.7432000000000003
                },
                "inclusion": False,
                "version": 1
            },
            {
                "circle": {
                    "center": [39.20243722226064, -96.54895553955235],
                    "radius": 73.19944453555631
                },
                "inclusion": False,
                "version": 1
            }
        ]
    }
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=7263)