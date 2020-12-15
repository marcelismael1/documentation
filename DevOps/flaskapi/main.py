from flask import Flask, request, make_response, jsonify
import time, os, sys

from orm_engine import *



app = Flask(__name__)

@app.route('/insert_metrics', methods=['POST', 'GET'])
def sys_config_table():
	try:
		req 	= request.get_json()
		print(req)
		data = {
		"rev_pld_var" : req.get("rev_pld_var"), 
		"src_port" : req.get("src_port"), 
		"pld_distinct" : req.get("pld_distinct") , 
		"rev_hdr_ccnt": req.get("rev_hdr_ccnt"), 
		"bytes_out": req.get("bytes_out"), 
		"hdr_mean": req.get("hdr_mean")
		}
		metric = Android(rev_pld_var = req.get("rev_pld_var"), src_port= req.get("src_port"), pld_distinct = req.get("pld_distinct") , rev_hdr_ccnt= req.get("rev_hdr_ccnt"), bytes_out= req.get("bytes_out"), hdr_mean= req.get("hdr_mean")).save()
		message  = {'success': True}
		return make_response(jsonify(message), 200)
	except  Exception as e:
		print(e)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port = 4444)