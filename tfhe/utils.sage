# Definindo o anel de polinômios
Zx.<x> = ZZ[] # Polinômios na variável x com coeficientes inteiros

def sym_mod(a, n): # symetric modulo
    a = ZZ(a) % n
        # ZZ(a) transforma a em um inteiro
        # ZZ(a) % n retorna o resto da divisão de a por n
    if 2 * a > n:
        # a > n/2
        return a - n
            # a - n > n/2 - n => a - n > -n/2
    return a
        # a < n/2
    # a sempre fica no intervalo [-n/2, n/2]

def sym_mod_poly(poly, q):
    # Aplica sym_mod a todos os coef. de um polinômio
    return Zx([sym_mod(ZZ(ai), q) for ai in poly.list()])
        # poly.list: transforma o polinômio em uma lista de coeficientes
        # for ai in poly.list(): itera cada coeficiente do polinômio
        # sym_mod(ZZ(ai), q): aplica o módulo simétrico a cada coeficiente
        # Zx(...): constroi um polinômio com os novos coeficientes

def sym_mod_vec(vec, q):
    # Função que processa um vetor (lista) de polinômios
    return [sym_mod_poly(vi, q) for vi in vec]
        # for vi in vec: itera cada elemento do vetor
        # sym_mod_poly(vi, q): aplica a função a cada polinômio do vetor 
        # Retorna uma noca lista com os polinômios processados