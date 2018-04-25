ind = list(map(int, input().split()))

st = [1] * 48

for i in ind:
    st[i] = 0

print(*st[::-1], sep = '')
