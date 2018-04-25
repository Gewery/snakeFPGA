import sys

f = open('input.txt')
sys.stdout = open('output.txt', 'w')

spaces = 0

for st in f.readlines():
    st = st.strip()

    l = list(map(str, st.split()))

    if len(l) > 0:        
        beg = l[0]
        
        if beg == 'end':
            spaces -= 4
            
        print(' ' * spaces + st)
        
        if beg == 'begin':
            spaces += 4
    else:
        print()

sys.stdout.close()
