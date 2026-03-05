load("dghv_tfhe.sage")

def compIguais_tfhe(dghv, n=3):
    m0 = ZZ.random_element(0, 2^n)
    m1 = ZZ.random_element(0, 2^n)

    print(f"m0 = {m0}")
    print(f"m1 = {m1}")

    bits0 = m0.digits(base=2, padto=n)
    bits1 = m1.digits(base=2, padto=n)

    c0 = [dghv.enc_vector(bi) for bi in bits0]
    c1 = [dghv.enc_vector(bi) for bi in bits1]
        # Codifica os bits na forma vetorial

    c = dghv.enc_scalar(1)
        # Codifica c de forma escalar
    const1 = dghv.enc_vector(1)
        # Codifica constante 1 para realizar a porta not (c XOR 1)
    for i in range(n):
        cmp_i = dghv.add_vector(c0[i], c1[i])   # c0[i] XOR c1[i]
        cmp_i = dghv.add_vector(cmp_i, const1)  # not cmp_i
        c = dghv.mult(c, cmp_i)             # c AND cmp_i

    res = dghv.dec_scalar(c)
    print(f"Esperado: {1 if m0==m1 else 0} | Res: {res}")
    
dghv = DGHV(448, 64, 8)
compIguais_tfhe(dghv)
