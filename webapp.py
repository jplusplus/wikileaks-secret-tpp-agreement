#!/usr/bin/env python
# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Popcorn
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU General Public License
# -----------------------------------------------------------------------------
# Creation : 15-Nov-2013
# Last mod : 15-Nov-2013
# -----------------------------------------------------------------------------
# This file is part of Popcorn.
# 
#     Popcorn is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     Popcorn is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with Popcorn.  If not, see <http://www.gnu.org/licenses/>.

from flask import Flask, render_template, request, send_file, \
	send_from_directory, Response, abort, session, redirect, url_for, make_response
from flask.ext.assets import Environment
import os

app = Flask(__name__)
assets = Environment(app)
app.config.from_pyfile('settings.py', silent=True)

# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------
@app.route('/')
def index():
	response = make_response(render_template('home.html'))
	return response

# -----------------------------------------------------------------------------
#
# Main
#
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	import sys
	if len(sys.argv) > 1:
		if sys.argv[1] == "build":
			from flask_frozen import Freezer
			freezer = Freezer(app).freeze()
			import shutil
			shutil.rmtree(os.path.join(os.path.dirname(__file__), "build", "static", ".webassets-cache"))
			print "frozen!"
			sys.exit()
	app.run(
		extra_files=[os.path.join(os.path.dirname(__file__), "settings.py")]
	)

# EOF
