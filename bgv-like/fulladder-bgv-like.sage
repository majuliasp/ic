load("dghv_bgv-like-2.sage")

def sumLimitedBits(a, b, n):
    mask =  (1 << n) - 1
    res = (a + b) & mask
    return res

def fulladder(dghv, n): # n = quantidade de bits dos números
    m0 = ZZ.random_element(0, 2^n)
    m1 = ZZ.random_element(0, 2^n)

    bits0 = m0.digits(base=2, padto=n)
    bits1 = m1.digits(base=2, padto=n)

    c0 = [dghv.enc(bi) for bi in bits0]
    c1 = [dghv.enc(bi) for bi in bits1]

    c = []              # bits res
    cin = dghv.enc(0)   # primeiro cin
    for i in range(n):
        # Soma do bit atual
        print(f"[Par {i}]: {dghv.dec(c0[i])} e {dghv.dec(c1[i])}")
        xor_ab = dghv.add(c0[i], c1[i])
        soma = dghv.add(xor_ab, cin)    # Resultado da soma dos bits
        print(f"\tSoma: {dghv.dec(soma)}")

        # Cálculo do carry out (cout)
        and_ab = dghv.mult(c0[i], c1[i])
        and_xor_ab_cin = dghv.mult(xor_ab, cin)
        cout = dghv.or_gate(and_ab, and_xor_ab_cin)
        print(f"\tCout: {dghv.dec(cout)}")
        c.append(soma)                  # bit da soma criptografado
        cin = cout

    mbits = [dghv.dec(ci) for ci in c]

    m = 0
    for i in range(n):
        m += mbits[i] * (2^i)
    # m deve ser a mensagem descriptografada (soma dos valores m0 e m1 iniciais)

    esperado = sumLimitedBits(m0, m1, n)
    if m != esperado:
        print(f"[ERRO] Esperado: {esperado} | Resultado: {m}")
        exit(1)
    print(f"{m0} + {m1} = {m}")

dghv = DGHV(512, 256, 16, 7)
fulladder(dghv, 3)