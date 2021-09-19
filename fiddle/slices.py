numbers = list(range(1, 11))
print(f"Original list: {numbers}")

this_slice = slice(0, 2)
first_two_numbers = numbers[this_slice]
print(f"Slice first two: {first_two_numbers}")

this_slice = slice(0, 3)
first_three_numbers = numbers[this_slice]
print (f"First two: {first_two_numbers} and reslice to first three: {first_three_numbers}")

this_slice = slice(-3, None)   # None gets you to the end, not 0
last_three_numbers = numbers[this_slice]
print (f"Last three using None: {last_three_numbers}")
