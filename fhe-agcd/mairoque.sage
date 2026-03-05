load("dghv.sage")

def maior(dghv, n=3):               # n => quantidade de bits
    A = ZZ.random_element(0, 2^n)
    B = ZZ.random_element(0, 2^n)      # Escolhe dois números inteiros aleatórios
    print("A: ", A)
    print("B: ", B)

    bitsA = A.digits(base=2, padto=n)
    bitsB = B.digits(base=2, padto=n)  # Listas com os bits de cada número
    print(f"Bits A: {bitsA}\nBits B: {bitsB}")

    ac = [dghv.enc(bi) for bi in bitsA]
    bc = [dghv.enc(bi) for bi in bitsB] # Listas com os bits criptografados de cada número

    maior = dghv.enc(0)
    igualAntes = dghv.enc(1)
    for i in range(n):
        idx = n - 1 - i
        print("pos = ", idx)
        # Se os números ainda são iguais, verifica bit atual
        a_Maior = dghv.mult(dghv.mult(ac[idx], dghv.not_gate(bc[idx])), igualAntes)
        print(f"\ta_Maior: {dghv.dec(a_Maior)}")

        # Atualiza maior (maior OR a_Maior)
        print(f"\tMaior antes: {dghv.dec(maior)}")
        maior = dghv.or_gate(maior, a_Maior)
        print(f"\tMaior depois: {dghv.dec(maior)}")

        # Verifica se os bits analisados são iguais
        iguais = dghv.add(ac[idx], bc[idx])
        iguais = dghv.not_gate(iguais)

        # Set igualAntes pra próxima iteração
        # Verifica se os números continuam iguais
        igualAntes = dghv.mult(iguais, igualAntes)
    
    # resposta está no maior
    res = dghv.dec(maior)
    print(f"Resposta: {res}")
    print(f"Esperado: {1 if A > B else 0}")


dghv = DGHV(7500, 800, 40)
maior(dghv)