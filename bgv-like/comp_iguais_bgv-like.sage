load("dghv_bgv-like.sage")

def compIguais(dghv, n=1):
    m0 = ZZ.random_element(0, 2^n)
    m1 = ZZ.random_element(0, 2^n)

    print(f"m0 = {m0}")
    print(f"m1 = {m1}")

    bits0 = m0.digits(base=2, padto=n)
    bits1 = m1.digits(base=2, padto=n)

    c0 = [dghv.enc(bi) for bi in bits0]
    c1 = [dghv.enc(bi) for bi in bits1]
        # Codifica os bits na forma vetorial

    c = dghv.enc(1)
        # Codifica c 
    const1 = dghv.enc(1)
        # Codifica constante 1 para realizar a porta not (c XOR 1)
    for i in range(n):
        cmp_i = dghv.add(c0[i], c1[i])       # c0[i] XOR c1[i]
        cmp_i = dghv.not_gate(cmp_i)
        c = dghv.mult(c, cmp_i)              # c = c AND cmp_i

    res = dghv.dec(c)
    print(f"Esperado: {1 if m0==m1 else 0} | Res: {res}")
    
dghv = DGHV(448, 64, 8, )
compIguais(dghv)

# fresco: sk = p e log(ruído) ~= rho
# depois de multiplicar: sk = p' e log(ruído) ~= rho
# os criptogramas podem estar criptografados com ps diferentes
# p0 > p1 > ... > pL
# modulo switching pro nivel certo
# rho = lambda, eta = maior que lambda, gamma = lambda * (eta - rho)^2 / log(lambda) (pensando em segurança)
# lamda -> 2^lambda operações -> lambda é o parâmetro de segurança
# escolha de eta -> baseado no tamanho do primo que depende do circuito
# pra brincar -> lambda pequeno
