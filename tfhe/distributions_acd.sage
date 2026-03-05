def sample_r(rho):
    return ZZ.random_element(-2^rho, 2^rho)

def sample_q(gamma, eta):
    return ZZ.random_element(0, 2^(gamma - eta))

def sample_error():
    return ZZ.random_element(-(1/2), 1/2)

def distribuicao_ACD(gamma, eta, rho, p):
    q = sample_q(gamma, eta)
    r = sample_r(rho)
    return p * q + r

def remove_fatores_pequenos (a, num_fact =1000):
    q = 2
    for _ in range(num_fact ):
        while q.divides(a):
            a /= q
        q = next_prime (q)
    return ZZ(a)

def ataque_por_mdc (gamma , eta , rho , list_samples ):
    x0 = list_samples [0]
    mult_p = prod([x0 - r for r in range(-2^rho , 2^ rho )])
    mult_p = remove_fatores_pequenos(mult_p) # mult. de p
    for i in range(1, len( list_samples )):
        xi = list_samples [i]
        mi = prod ([xi - r for r in range(-2^rho , 2^ rho )])
        mult_p = gcd(mult_p , mi) # máximo divisor comum
        print("bitlen mult_p = %d" % mult_p.nbits ())
        if eta >= log(mult_p , 2) >= eta-1:
            break
    return mult_p