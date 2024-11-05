import sys
import numpy as np
import pandas as pd

filename = sys.argv[1]
interval =  float(sys.argv[2])


col_names = ["x", "y"]

polygon = pd.read_csv (filename, sep='\t', header=None, skiprows=1, names=col_names)

x = polygon['x'].to_numpy()
y = polygon['y'].to_numpy()

number_points = len(x)

last_x = x[number_points-1]
last_y = y[number_points-1]

for index in range(0,number_points):


	distance = np.sqrt((last_x-x[index])**2+(last_y-y[index])**2)
	angle = np.arctan2([y[index]-last_y],[x[index]-last_x])

	number_extra_points = int(distance / interval)

	along_line = 0

	print(last_x,last_y)

	for extra_point in range(1,number_extra_points + 1):

		along_line = extra_point * interval
		next_x = np.cos(angle) * along_line + last_x
		next_y = np.sin(angle) * along_line + last_y
		print(next_x[0],next_y[0])


	last_x = x[index]
	last_y = y[index]


