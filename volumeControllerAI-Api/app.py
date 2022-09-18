from random import random

from flask import Flask, jsonify
import numpy as np

app = Flask(__name__)

test = np.load("./data.npy")
volume = 0
index = 0

@app.route('/getVolume')
def get_volume():
    global volume
    global index
    if index < len(test):
        volume = int(test[index])
    else:
        volume = 0
    index += 1
    data = {
        'volume': volume,
        'status': "success"
    }
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='192.168.1.152', port=5000, debug=True)

