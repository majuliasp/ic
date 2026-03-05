load("dghv.sage")

def comparacao_homomorfica (dghv , n=3):
    m0 = ZZ. random_element (0, 2^n)
    m1 = ZZ. random_element (0, 2^n)
    print(m0)
    print(m1)
    bits0 = m0.digits(base =2, padto=n) # lista com n bits
    bits1 = m1.digits(base =2, padto=n) # lista com n bits
    c0 = [dghv.enc(bi) for bi in bits0] # cifra cada bit
    c1 = [dghv.enc(bi) for bi in bits1] # cifra cada bit
    # compara homomorficamente
    c, m = 1, 1
    for i in range(n):
        cmp_i = dghv.add(c0[i], c1[i]) # enc(0) <==> c0[i] == c1[i]
        cmp_i = dghv.not_gate(cmp_i) # enc(1) <==> c0[i] == c1[i]
        c = dghv.mult(c, cmp_i) # c *= cmp_i
    # decifra e verifica
    print(c)
    res = dghv.dec(c)
    print(m0 == m1)
    print(res)
    return ((m0 == m1) == res)

dghv = DGHV(25, 20, 5)
print(comparacao_homomorfica(dghv))