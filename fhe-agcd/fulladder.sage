load("dghv.sage")

def sumLimitedBits(a, b, n):
    mask =  (1 << n) - 1
    res = (a + b) & mask
    return res

def fulladder(dghv, n=3):    # n => quantidade de bits
    m1 = ZZ.random_element(0, 2^n)
    m2 = ZZ.random_element(0, 2^n)   # Escolhe dois números inteiros aleatórios
    print("m1: ", m1)
    print("m2: ", m2)
    bits1 = m1.digits(base=2, padto=n)
    bits2 = m2.digits(base=2, padto=n)    # Listas com os bits de cada número
    print("bits 1: ", bits1)
    print("bits 2: ", bits2)

    c1 = [dghv.enc(bi) for bi in bits1]
    c2 = [dghv.enc(bi) for bi in bits2]     # Listas com os bits criptografados de cada número

    # full adder
    c = [None] * n
    cin = dghv.enc(0)
    for i in range(n):
        idx = i

        # Soma do bit atual
        xor_ab = dghv.add(c1[idx], c2[idx])    
        sum = dghv.add(xor_ab, cin)         # Resultado

        # Cálculo do carry out
        and_ab = dghv.mult(c1[idx], c2[idx])
        and_xor_ab_cin = dghv.mult(xor_ab, cin)
        cout = dghv.or_gate(and_ab, and_xor_ab_cin)

        c[idx] = sum                      # mensagem criptografada
        cin = cout
    
    
    mbits = [dghv.dec(ci) for ci in c]
    print("mbits: ", mbits)    # Debuggando

    m = 0
    for i in range(n):
        m += mbits[i] * (2^i)
    # m deve ser a mensagem descriptografada (soma dos valores m1 e m2 iniciais)

    esperado = sumLimitedBits(m1, m2, n)
    print("Resultado: ", m, " | Esperado: ", esperado)
    return m == esperado

dghv = DGHV(512, 256, 16)
fulladder(dghv)
