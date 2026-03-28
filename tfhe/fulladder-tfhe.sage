load("dghv_tfhe.sage")

def sumLimitedBits(a, b, n):
    mask =  (1 << n) - 1
    res = (a + b) & mask
    return res

def fulladder(dghv, n=3):
    m0 = ZZ.random_element(0, 2^n)
    m1 = ZZ.random_element(0, 2^n)

    bitsm0 = m0.digits(base=2, padto=n)
    bitsm1 = m1.digits(base=2, padto=n)

    c0_s = [dghv.enc_scalar(bi) for bi in bitsm0]
    c0_v = [dghv.enc_vector(bi) for bi in bitsm0]
    c1_s = [dghv.enc_scalar(bi) for bi in bitsm1]
    c1_v = [dghv.enc_vector(bi) for bi in bitsm1]

    c = []
    cin = dghv.enc_scalar(0)
    for i in range(n):
        xor_ab = dghv.add_scalar(c0_s[i], c1_s[i])      # scalar
        soma = dghv.add_scalar(xor_ab, cin)             # scalar

        and_ab = dghv.mult(c0_s[i], c1_v[i])            # scalar
        and_acin = dghv.mult(cin, c0_v[i])              # scalar
        and_bcin = dghv.mult(cin, c1_v[i])              # scalar

        cout = dghv.add_scalar(and_ab, dghv.add_scalar(and_acin, and_bcin)) # scalar

        c.append(soma)
        cin = cout 
    
    mbits = [dghv.dec_scalar(ci) for ci in c]

    m = sum((mbits[i] * 2^i) for i in range(n))

    esperado = sumLimitedBits(m0, m1, n)
    if m != esperado:
        print(f"[ERRO] Esperado: {esperado} | Resultado: {m}")
        exit()
    print(f"{m0} + {m1} = {m}")


dghv = DGHV(448, 64, 8)
fulladder(dghv)