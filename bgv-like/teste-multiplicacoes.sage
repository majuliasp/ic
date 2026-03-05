load("dghv_bgv-like-2.sage")

dghv = DGHV(448, 64, 8, 3)

c0 = dghv.enc(0)
c1 = dghv.enc(1)

print(f"Ruído c0: {dghv.ruido(c0)}")

print("Multiplicações nível 0")

and_00 = dghv.mult(c0, c0) 
and_01 = dghv.mult(c0, c1)
and_11 = dghv.mult(c1, c1)

print(f"Ruído and_00: {dghv.ruido(and_00)}")

print(f"0 and 0 | Esperado: 0 | Resultado: {dghv.dec(and_00)}")
print(f"0 and 1 | Esperado: 0 | Resultado: {dghv.dec(and_01)}")
print(f"1 and 1 | Esperado: 1 | Resultado: {dghv.dec(and_11)}")

print("Multiplicações nível 0 com nível 1")

and_00_0 = dghv.mult(c0, and_00)
and_01_1 = dghv.mult(c1, and_01)
and_11_1 = dghv.mult(c1, and_11)

print(f"(0 and 0) and 0 | Esperado: 0 | Resultado: {dghv.dec(and_00_0)}")
print(f"(0 and 1) and 1 | Esperado: 0 | Resultado: {dghv.dec(and_01_1)}")
print(f"(1 and 1) and 1 | Esperado: 1 | Resultado: {dghv.dec(and_11_1)}")

print("Multiplicações nível 1")

and_00_01 = dghv.mult(and_00, and_01)
and_11_11 = dghv.mult(and_11, and_11)

print(f"Ruído and_00_01: {dghv.ruido(and_00_01)}")

print(f"and_00 and and_01 | Esperado: 0 | Resultado: {dghv.dec(and_00_01)}")
print(f"and_11 and and_11 | Esperado: 1 | Resultado: {dghv.dec(and_11_11)}")