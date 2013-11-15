class Map

	constructor: ->
		@COUNTRIES =
			US :
				name    : "United States"
				geo     : [-77.036567, 38.895101]
				pib_usd : 15700000000000
			JP :
				name    : "Japan"
				geo     : [-221.747076, 36.204824]
				pib_usd : 6000000000000
			CA :
				name    : "Canada"
				geo     : [-75.69529, 45.42231]
				pib_usd : 1800000000000
			AU :
				name    : "Australia"
				geo     : [-210.875611, -35.308294]
				pib_usd : 1500000000000
			MX :
				name    : "Mexico"
				geo     : [-102.552784, 23.634501]
				pib_usd : 1780000000000
			MY :
				name    : "Malaysia"
				geo     : [-258.024234, 4.210484]
				pib_usd : 303000000000
			SG :
				name    : "Singapore"
				geo     : [-256.180164, 1.352083]
				pib_usd : 275000000000
			CL :
				name    : "Chile"
				geo     : [-71.542969, -35.675147]
				pib_usd : 268000000000
			PE :
				name    : "Peru"
				geo     : [-75.015152, -9.189967]
				pib_usd : 197000000000
			VN :
				name    : "Viet-nam"
				geo     : [-251.722801, 14.058324]
				pib_usd : 142000000000
			NZ :
				name    : "New Zealand"
				geo     : [-185.114029, -40.900557]
				pib_usd : 140000000000
			BN :
				name    : "Brunei Darussalam"
				geo     : [-245.272331, 4.535277]
				pib_usd : 17000000000
		@map = undefined
		@svg = undefined
		@g   = undefined
		@markers = []
		@line = d3.svg.line()
			.x((d) -> return d.x)
			.y((d) -> return d.y)
			.interpolate("basis")
		@lines = []
		@current_country = undefined

	getParameterByName : (name) =>
		### from location/hash ###
		name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
		regex = new RegExp("[\\#&]" + name + "=([^&#]*)")
		results = regex.exec(location.hash)
		return if results == null then null else decodeURIComponent(results[1].replace(/\+/g, " "))

	init: =>
		# set map container size
		set_size = -> $("#map").height($(window).height() - $("#map").offset().top)
		set_size(); d3.select(window).on('resize', set_size)
		# load map from leaflet
		zoom = @getParameterByName("zoom") or 2
		@map = L.mapbox.map(
			"map", 
			"vied12.g9ekj0p2",
				zoom            : zoom
				center          : new L.LatLng(5,-150)
				scrollWheelZoom : false
		)
		@map.addEventListener('click', @onMapClick)
		# init d3 with leaflet
		@svg = d3.select(@map.getPanes().overlayPane).append("svg")
		@g   = @svg.append("g").attr("class", "leaflet-zoom-hide")
		#add markers
		@addMarkersToMap()
		@map.on("viewreset", => @loadedDataCallback(null, @matrice))
		# load data
		queue()
			.defer(d3.json, "static/data/matrice.json")
			.await(@loadedDataCallback)
		# init scales
		@color_scale = chroma.scale(["#FDC96D", "#AD0303"]).domain(_.map(@COUNTRIES, (c)-> c.pib_usd)).out('hex')

	addMarkersToMap : =>
		@map.markerLayer.on 'layeradd', (e) =>
			marker = e.layer
			feature = marker.feature
			marker.setIcon(L.icon(feature.properties.icon))
			marker.addEventListener('click', @onMarkerClick)

		@markers = []
		for country, obj of @COUNTRIES
			@markers.push
				"type": "Feature"
				"geometry":
					"type": "Point"
					"coordinates": obj.geo
				"properties":
					"title": obj.name
					"code" : country
					"icon":
						"iconUrl": "static/flags/#{country}.png"
						"iconSize": [20, 32]
						"iconAnchor": [11, 31]
						"popupAnchor": [0, -25]
						"className": "dot"

		@map.markerLayer.setGeoJSON(@markers)

	loadedDataCallback : (a, matrice) =>
		@matrice  = matrice
		@lines    = []
		occs_glob = []
		for country, relations of matrice
			for other_country, data of relations
				occs_glob.push(data.occ)
				a = @map.latLngToLayerPoint(new L.LatLng(@COUNTRIES[country]      .geo[1] , @COUNTRIES[country]     .geo[0]))
				b = @map.latLngToLayerPoint(new L.LatLng(@COUNTRIES[other_country].geo[1], @COUNTRIES[other_country].geo[0]))
				@lines.push
					points : @getCurbPoints(a,b)
					data   : data
					from   : country
					to     : other_country
		domain         = [d3.min(occs_glob), d3.max(occs_glob)]
		@scale1        = d3.scale.linear().domain(domain)
		@scale2        = d3.scale.linear().domain(domain)
		@opacity_scale = @scale1.range([0.15, 0.7])
		@stroke_scale  = @scale2.range([1   , 3])
		@update()

	onMarkerClick : (e) =>
		code = e.target.feature.properties.code
		if @current_country == code
			@current_country = undefined
		else
			@current_country = code
		@showCurves(@current_country)

	onMapClick : (e) =>
		if @current_country?
			@current_country = undefined
			@showCurves(@current_country)

	showCurves: (country=undefined) =>
		@curves
			.attr('display', (d) => if not country? or d.from == country then "inline" else "none")
			.attr 'stroke-width', (d) =>
				@stroke_scale(d.data.occ)
			.attr 'opacity', (d) =>
				@opacity_scale(d.data.occ)
			# animation
			.attr "stroke-dasharray", (d) ->
				total_length = d3.select(this).node().getTotalLength()
				return total_length + " " + total_length
			.attr "stroke-dashoffset", (d) ->
				total_length = d3.select(this).node().getTotalLength()
				return total_length
			.transition()
				.duration(1000)
				.ease("linear")
				.attr("stroke-dashoffset", 0)

	getCurbPoints: (a, b)->
		### Returns a curve ###
		maxY = Math.max(a.y, b.y)
		minY = Math.min(a.y, b.y)
		maxX = Math.max(a.x, b.x)
		minX = Math.min(a.x, b.x)
		ab_x = maxX - minX
		ab_y = maxY - minY 
		a_t = 
			x: a.x
			y: a.y
		b_t =  
			x: b.x
			y: b.y
		factor_x = if a.x < b.x then 1 else -1
		factor_y = if a.y < b.y then 1 else -1
		if ab_x > ab_y
			offsetX = ab_x / 3 
			a_t.x = a_t.x + factor_x * offsetX
			b_t.x = b_t.x + (-factor_x) * offsetX
		else
			offsetY = ab_y / 3
			a_t.y = a_t.y + factor_y * offsetY
			b_t.y = b_t.y + (-factor_y) * offsetY
		return [a, a_t, b_t,b]

	update : =>
		@curves = @g.selectAll("path.curve").data(@lines)
		@curves.enter()
			.append("path")
			# .attr('display', (d) => if not country? or d.from == country then "inline" else "none")
			.attr("class", "curve")
			.attr 'stroke', (d) =>
				c1 = @COUNTRIES[d.from]
				c2 = @COUNTRIES[d.to]
				pib_max = Math.max(c1.pib_usd, c2.pib_usd)
				@color_scale(pib_max)
			.attr 'stroke-width', (d) =>
				@stroke_scale(d.data.occ)
			.attr 'opacity', (d) =>
				@opacity_scale(d.data.occ)
			.attr('fill', 'none')
			# animation
			.attr "stroke-dasharray", (d) ->
				total_length = d3.select(this).node().getTotalLength()
				return total_length + " " + total_length
			.attr "stroke-dashoffset", (d) ->
				total_length = d3.select(this).node().getTotalLength()
				return total_length
			.transition()
				.duration(5000)
				.ease("linear")
				.attr("stroke-dashoffset", 0)
		@reset()

	reset: =>
		@curves.attr('d', (d) => @line(d.points))
		bounds      = @getBoundingBox()
		topLeft     = bounds[0]
		bottomRight = bounds[1]
		@svg
			.attr("width", bottomRight[0] - topLeft[0])
			.attr("height", bottomRight[1] - topLeft[1])
			.style("left", topLeft[0] + "px")
			.style("top", topLeft[1] + "px")
		@g.attr("transform", "translate(" + -topLeft[0] + "," + -topLeft[1] + ")")

	getBoundingBox: =>
		coords  = []
		padding = 30
		for code, country of @COUNTRIES
			coords.push(@map.latLngToLayerPoint(new L.LatLng(country.geo[1], country.geo[0])))
		maxY = d3.max(coords, (e)-> e.y)
		maxX = d3.max(coords, (e)-> e.x)
		minY = d3.min(coords, (e)-> e.y)
		minX = d3.min(coords, (e)-> e.x)
		return [[minX - padding, minY - padding], [maxX + padding, maxY + padding]]

map = new Map
map.init()

# EOF
