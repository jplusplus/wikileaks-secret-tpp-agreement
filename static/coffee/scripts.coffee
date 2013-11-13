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

$.get "static/data/data.json", (data) ->
	MAX_OCC = 0
	for country, relations of data
		for other_country, occ of relations
			if occ > MAX_OCC
				MAX_OCC = occ

	for country, relations of data
		for other_country, occ of relations
			# console.log country, other_country, occ
			pointA = new L.LatLng(COUNTRIES[country].geo[1],       COUNTRIES[country].geo[0])
			pointB = new L.LatLng(COUNTRIES[other_country].geo[1], COUNTRIES[other_country].geo[0])
			polyline = L.polyline([pointA, pointB], {color: '#008506', opacity:occ/MAX_OCC*.6,weight:occ*0.05}).addTo(map)
