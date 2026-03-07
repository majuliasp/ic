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
        print(f"[ERRO] Esperado: {int(m0 == m1)} | Resultado: {res}")
        exit(1)
    print(f"{m0} é {"igual a" if res else "diferente de"} {m1}.")
    
n = 5 #Número de bits
L = n + 1
lamba = 8 # parâmetro de segurança
dghv = DGHV(448, 2^(n+1) * 8, 8, L)
compIguais(dghv, n)

# rho -> tamanho do ruído
# eta -> tamanho do primeiro primo
#   o tamanho do primo depende do tamanho do circuito
# gamma -> tamanho do criptograma 
# lamba -> parâmetro de segurança (qntd de operações que um attacker precisa pra dar ruim)



# fresco: sk = p e log(ruído) ~= rho
# depois de multiplicar: sk = p' e log(ruído) ~= rho
# os criptogramas podem estar criptografados com ps diferentes
# p0 > p1 > ... > pL
# modulo switching pro nivel certo
# rho = lambda, eta = maior que lambda, gamma = lambda * (eta - rho)^2 / log(lambda) (pensando em segurança)
# lamda -> 2^lambda operações -> lambda é o parâmetro de segurança
# escolha de eta -> baseado no tamanho do primo que depende do circuito
# pra brincar -> lambda pequeno
