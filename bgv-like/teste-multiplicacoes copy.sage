load("dghv_bgv-like-2.sage")

dghv = DGHV(448, 64, 8, 4)

c0 = dghv.enc(0)
c1 = dghv.enc(1)

# print(f"Ruído c0: {sym_mod(c0['criptograma'], dghv.cadeiaP[0])}")


and_00 = dghv.mult(c0, c0) 
and_01 = dghv.mult(c0, c1)
and_11 = dghv.mult(c1, c1)

if 0 != dghv.dec(and_00):
    print(f"ERROR: 0 and 0 | Esperado: 0 | Resultado: {dghv.dec(and_00)}")
    exit(1)

if 0 != dghv.dec(and_01):
    print(f"ERROR: 0 and 1 | Esperado: 0 | Resultado: {dghv.dec(and_01)}")
    exit(1)

if 1 != dghv.dec(and_11):
    print(f"ERROR: 1 and 1 | Esperado: 1 | Resultado: {dghv.dec(and_11)}")
    exit(1)

print("Multiplicações nível 0 ................... OK")

and_00_0 = dghv.mult(c0, and_00)
and_01_1 = dghv.mult(c1, and_01)
and_11_1 = dghv.mult(c1, and_11)

if 0 != dghv.dec(and_00_0):
    print(f"ERROR: (0 and 0) and 0 | Esperado: 0 | Resultado: {dghv.dec(and_00_0)}")
    exit(1)

if 0 != dghv.dec(and_01_1):
    print(f"ERROR: (0 and 1) and 1 | Esperado: 0 | Resultado: {dghv.dec(and_01_1)}")
    exit(1)

if 1 != dghv.dec(and_11_1):
    print(f"ERROR: (1 and 1) and 1 | Esperado: 1 | Resultado: {dghv.dec(and_11_1)}")
    exit(1)

print("Multiplicações nível 0 com nível 1 ....... OK")

and_00_01 = dghv.mult(and_00, and_01)
and_11_11 = dghv.mult(and_11, and_11)

if 0 != dghv.dec(and_00_01):
    print(f"ERROR: and_00 and and_01 | Esperado: 0 | Resultado: {dghv.dec(and_00_01)}")
    exit(1)

if 1 != dghv.dec(and_11_11):
    print(f"ERROR: and_11 and and_11 | Esperado: 1 | Resultado: {dghv.dec(and_11_11)}")
    exit(1)


print("Multiplicações nível 1 ................... OK")

and_nivel2 = dghv.mult(and_00_01, and_11_11)

if 0 != dghv.dec(and_nivel2):
    print(f"ERROR: and_00_01 and and_11_11 | Esperado: 0 | Resultado {dghv.dec(and_nivel2)}")

print("Multiplicações nível 2 ................... OK")