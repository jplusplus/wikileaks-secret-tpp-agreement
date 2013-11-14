COUNTRIES = {
	NZ : {
		name : "NEW ZEALAND"
		geo : [174.885971, -40.900557]
	}
	CL : {
		name : "CHILE"
		geo : [-71.542969, -35.675147]
	}
	PE : {
		name : "PERU"
		geo : [-75.015152, -9.189967]
	}
	VN : {
		name : "VIET NAM"
		geo : [108.277199, 14.058324]
	}
	BN : {
		name : "BRUNEI DARUSSALAM"
		geo : [114.727669, 4.535277]
	}
	MY : {
		name : "MALAYSIA"
		geo : [101.975766, 4.210484]
	}
	SG : {
		name : "SINGAPORE"
		geo : [103.819836, 1.352083]
	}
	CA : {
		name : "CANADA"
		geo : [-106.346771, 56.130366]
	}
	MX : {
		name : "MEXICO"
		geo : [-102.552784, 23.634501]
	}
	US : {
		name : "UNITED STATES"
		geo : [-95.712891, 37.090240]
	}
	JP : {
		name : "JAPAN"
		geo : [138.252924, 36.204824]
	}
	AU : {
		name : "AUSTRALIA"
		geo : [133.775136, -25.274398]
	}
}

map = L.mapbox.map("map", "vied12.g97iffb2").setView([40, -74.50], 2)
svg = d3.select(map.getPanes().overlayPane).append("svg")
g   = svg.append("g").attr("class", "leaflet-zoom-hide")

# add marker
for country, obj of COUNTRIES
	L.mapbox.markerLayer(
		type: "Feature"
		geometry:
			type: "Point"
			coordinates: obj.geo
		properties:
			title: obj.name
			description: obj.name
			"marker-size": "small"
			"marker-color": "#246CA6"
	).addTo map

d3.json "static/data/data.json", (countries) ->
	x = (d) -> return d.x
	y = (d) -> return d.y
	line = d3.svg.line().x(x).y(y).interpolate("cardinal");
	lines = []
	for country, relations of countries
		for other_country, occ of relations
			a = map.latLngToLayerPoint(new L.LatLng(COUNTRIES[country].geo[1], COUNTRIES[country].geo[0]))
			b = map.latLngToLayerPoint(new L.LatLng(COUNTRIES[other_country].geo[1], COUNTRIES[other_country].geo[0]))
			m = new L.Point(a.x+(b.x-a.x)/2, a.y+(b.y-a.y)/2-50)
			lines.push
				points: [a,m,b]
				occ   : occ
	
	curves = g.selectAll("path.curve").data(lines).enter()
		.append("path")
		.attr("class", "curve")
		.attr('stroke', 'green')
		.attr('stroke-width', 1)
		.attr('fill', 'none')
		.attr('d', (d) -> line(d.points))

	topLeft     = [0,0]
	bottomRight = [1500,800]
	svg.attr("width", bottomRight[0] - topLeft[0])
		.attr("height", bottomRight[1] - topLeft[1])
		.style("left", topLeft[0] + "px")
		.style("top", topLeft[1] + "px")
	g.attr("transform", "translate(" + -topLeft[0] + "," + -topLeft[1] + ")");
	# lines   = []
	# MAX_OCC = 0
	# for country, relations of countries
	# 	for other_country, occ of relations
	# 		if occ > MAX_OCC
	# 			MAX_OCC = occ
	# 		lines.push
	# 			country1_geo : COUNTRIES[country].geo
	# 			country1     : country
	# 			country2     : other_country
	# 			country2_geo : COUNTRIES[other_country].geo
	# 			occ          : occ
	# for country, relations of countries
	# 	for other_country, occ of relations
	# 		pointA = map.latLngToLayerPoint(new L.LatLng(COUNTRIES[country].geo[1],       COUNTRIES[country].geo[0]))
	# 		pointB = map.latLngToLayerPoint(new L.LatLng(COUNTRIES[other_country].geo[1], COUNTRIES[other_country].geo[0]))
	# 		pointM = new L.Point(pointA.x+(pointB.x-pointA.x)/2, pointA.y+(pointB.y-pointA.y)/2-50)
	# 		pointA = map.layerPointToLatLng(pointA)
	# 		pointB = map.layerPointToLatLng(pointB)
	# 		pointM = map.layerPointToLatLng(pointM)
	# 		polyline = L.polyline([pointA, pointM, pointB], {smoothFactor:10, color: '#008506', opacity:occ/MAX_OCC*.6,weight:occ*0.05}).addTo(map)
	# 		# break
		# break


