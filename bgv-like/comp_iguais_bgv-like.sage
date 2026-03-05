load("dghv_bgv-like-2.sage")

def compIguais(dghv, n):
    m0 = ZZ.random_element(0, 2^n)
    m1 = ZZ.random_element(0, 2^n)

    bits0 = m0.digits(base=2, padto=n)
    bits1 = m1.digits(base=2, padto=n)

    c0 = [dghv.enc(bi) for bi in bits0]
    c1 = [dghv.enc(bi) for bi in bits1]
        # Codifica os bits na forma vetorial

    c = dghv.enc(1)
        # Codifica c 
    for i in range(n):
        cmp_i = dghv.add(c0[i], c1[i])       # c0[i] XOR c1[i]
        cmp_i = dghv.not_gate(cmp_i)
        c = dghv.mult(c, cmp_i)              # c = c AND cmp_i

    res = dghv.dec(c)
    if (m0 == m1) != res:
        print(f"m0 = {m0} e m1 = {m1}")
        print(f"[ERRO] Esperado: {m0 == m1} | Resultado: {res}")
        exit(1)
    print(f"{m0} é {"igual a" if res else "diferente de"} {m1}.")
    
n = 3 #Número de bits
dghv = DGHV(448, 64, 8, n+1)
compIguais(dghv, n)

# fresco: sk = p e log(ruído) ~= rho
# depois de multiplicar: sk = p' e log(ruído) ~= rho
# os criptogramas podem estar criptografados com ps diferentes
# p0 > p1 > ... > pL
# modulo switching pro nivel certo
# rho = lambda, eta = maior que lambda, gamma = lambda * (eta - rho)^2 / log(lambda) (pensando em segurança)
# lamda -> 2^lambda operações -> lambda é o parâmetro de segurança
# escolha de eta -> baseado no tamanho do primo que depende do circuito
# pra brincar -> lambda pequeno
