from math import asin, atan2, cos, degrees, radians, sin
import sys



#https://stackoverflow.com/questions/7222382/get-lat-long-given-current-point-distance-and-bearing
def get_point_at_distance(lat1, lon1, d, bearing, R=6371):
    """
    lat: initial latitude, in degrees
    lon: initial longitude, in degrees
    d: target distance from initial
    bearing: (true) heading in degrees
    R: optional radius of sphere, defaults to mean radius of earth

    Returns new lat/lon coordinate {d}km from initial, in degrees
    """
    lat1 = radians(lat1)
    lon1 = radians(lon1)
    a = radians(bearing)
    lat2 = asin(sin(lat1) * cos(d/R) + cos(lat1) * sin(d/R) * cos(a))
    lon2 = lon1 + atan2(
        sin(a) * sin(d/R) * cos(lat1),
        cos(d/R) - sin(lat1) * sin(lat2)
    )
    return (degrees(lat2), degrees(lon2),)


center_longitude = float(sys.argv[1])
center_latitude =  float(sys.argv[2])
distance =  float(sys.argv[3])

# the formula doesn't work at exactly the north pole
if center_latitude == 90.0000:
	center_latitude = 89.99999998

bearing = 225.0
bottom_lat, bottom_lon = get_point_at_distance(center_latitude,center_longitude,distance,bearing)

bearing = 45.0
top_lat, top_lon = get_point_at_distance(center_latitude,center_longitude,distance,bearing)

print(f"-R{bottom_lon}/{bottom_lat}/{top_lon}/{top_lat}r")
