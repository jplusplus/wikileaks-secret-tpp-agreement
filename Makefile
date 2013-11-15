# Makefile -- Popcorn
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


WEBAPP     = $(wildcard webapp.py)

run:
	. `pwd`/.env ; python $(WEBAPP)

install:
	virtualenv venv --no-site-packages --distribute --prompt=popcorn
	. `pwd`/.env ; pip install -r requirements.txt

export:
	. `pwd`/.env ; python $(WEBAPP) build

archive: export
	tar cvzf popcorn.tar.gz build
# EOF
