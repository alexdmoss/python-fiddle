# enumerate, basically

with open("Makefile") as f:
    lines = [line.strip() for line in f.readlines()]

for index, line in enumerate(lines):
    if line.startswith('@echo'):
        print(line)
