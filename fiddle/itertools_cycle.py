import itertools

traffic_lights = 'Red Green Amber'.split()

each = itertools.cycle(traffic_lights)

print (next(each))
print (next(each))
print (next(each))
print (next(each))
