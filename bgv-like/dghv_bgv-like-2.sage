load("utils.sage")
load("distributions_acd.sage")

class DGHV:
    def __init__(self, gamma, eta, rho, L, t = 2, p = 1, b = 2):
        # L = profundidade do circuito, quantidade de níveis
        assert(gamma > eta)
        assert(eta > rho)
        if 1 == p:
            p = random_prime(2^eta, lbound=2^(eta - 1))
        else:
            assert(eta - 1 <= p.nbits() <= eta)

        self.gamma = gamma
        self.eta = eta
        self.rho = rho
        self.t = t

        qq = sample_q(gamma, eta)
        while (qq == 0):
            qq = sample_q(gamma, eta)
        self.x0 = p * qq # + self.sample_r()
            # Gera chave pública x0; limitará o tamanho do texto cifrado
        
        self.Zp = ZZ.quotient(p)
        self.Zx0 = ZZ.quotient(self.x0)
        self.b = b 

        # Preciso aumentar l conforme a quantidades de níveis multiplicativos eu tenho
        # Nesse caso, ele permite multiplicações entre, no máximo, criptogramas de nível 1
        # Aparentemente floor(log(2^(2^(L-1) * self.gamma), b)) + 1 ?
        self.l = floor(log(2^(2^(L-1) * gamma), b)) + 1

        # Cadeia de primos p usados em cada nível multiplicativo
        self.cadeiaP = [p]
        bitsAtual = p.nbits()
        for i in range(1, L):
            # Cada módulo deve ser congruente a p0 mod t e menor que o anterior
            # A razão entre dois p's seguidos deve ser de 2^-rho aproximadamente
            bitsNovo = bitsAtual - rho
            pi = random_prime(self.cadeiaP[-1], lbound=2^(bitsNovo - 1))
            while pi % t != p % t: # Pra t=2 isso é irrelevante
                pi = random_prime(self.cadeiaP[-1], lbound=2^(bitsNovo - 1))
            self.cadeiaP.append(pi)
            bitsAtual = pi.nbits()
        
        # Cadeia de trocas de chave
        # cadeiaKeySwitch[0]['key'] -> chave de troca do nível 0 para o nível 1
        self.cadeiaKeySwitch = [] # Vai ser um vetor de vetor
        for i in range(L - 1): # Existem L-1 mudanças
            pAtual = self.cadeiaP[i]
            pProx = self.cadeiaP[i + 1]
            switchKey = self.keySwitchingGen(pAtual, pProx)
            self.cadeiaKeySwitch.append(switchKey)

    # Geração das chaves de troca de módulo
    def keySwitchingGen(self, pAntigo, pNovo):
        q = [(sample_q(self.gamma, self.eta)) for i in range(self.l)] 
        r = [sample_r(self.rho) for i in range(self.l)]
        g = [(self.b)^i for i in range(self.l)] 
        k = [(pNovo * q[i] + r[i] + round((pNovo/(self.t * pAntigo)) * g[i])) for i in range(self.l)] # modulus-switching key
        return {
            'antigo': pAntigo,
            'novo': pNovo,
            'key': k
        }

    def switchToLevel(self, c_obj, level):
        c = c_obj['criptograma']
        levelAtual = c_obj['level']
        if levelAtual > level:
            raise ValueError("Não é possível subir o nível")
        while levelAtual < level:
            # Valor temporário c
            temp_c = c

            # Pegando a chave k
            keySwitch = self.cadeiaKeySwitch[levelAtual]
            k = keySwitch['key']
    
            # Decompondo temp_c
            y = []
            c_aux = temp_c
            for i in range(self.l):
                digit = c_aux % self.b
                y.append(digit)
                c_aux = (c_aux - digit) // self.b

            # Computando o produto
            c = self.t * sum(y[i] * k[i] for i in range(self.l)) + temp_c % self.t
            levelAtual += 1
        return {
            'criptograma': c, 
            'level': level
        }

    def enc(self, m, level=0):
        p = self.cadeiaP[level]
        q = sample_q(self.gamma, self.eta)
        r = sample_r(self.rho)
        c = p * q + self.t * r + m
        return {
            'criptograma' : c,
            'level' : level
        }

    def dec(self, c_obj):
        c = c_obj['criptograma']
        level = c_obj['level']

        p = self.cadeiaP[level]

        noisy_msg = sym_mod(c, p)
        m = noisy_msg % self.t
        return m

    def add(self, c0_obj, c1_obj):
        # Para funcionar, ambos precisam estar no mesmo nível
        # Colocando ambos os objetos no mesmo nível, caso não estejam
        if c0_obj['level'] > c1_obj['level']:
            c1_obj = self.switchToLevel(c1_obj, c0_obj['level'])
        elif c1_obj['level'] > c0_obj['level']:
            c0_obj = self.switchToLevel(c0_obj, c1_obj['level'])

        level = c0_obj['level'] # nível que estamos trabalhando
        c = (c0_obj['criptograma'] + c1_obj['criptograma'] ) % self.x0

        return {
            'criptograma' : c,
            'level' : level
        }

    def not_gate(self, c):
        um = self.enc(1)
        return {
            'criptograma' : ( um['criptograma'] - c['criptograma']) % self.cadeiax0[c['level']],
            'level': c['level']
        }

    def mult(self, c0_obj, c1_obj):
        # Para funcionar, ambos precisam estar no mesmo nível
        # Colocando ambos os objetos no mesmo nível, caso não estejam
        if c0_obj['level'] > c1_obj['level']:
            c1_obj = self.switchToLevel(c1_obj, c0_obj['level'])
        elif c1_obj['level'] > c0_obj['level']:
            c0_obj = self.switchToLevel(c0_obj, c1_obj['level'])

        # ambos estão no mesmo nível
        level = c0_obj['level']

        prod = (c0_obj['criptograma'] * c1_obj['criptograma'])
        
        temp_c = {'criptograma': prod, 'level': level}

        c = self.switchToLevel(temp_c, level + 1)

        return c

    def or_gate(self, c0_obj, c1_obj):
        # or = (c0 XOR c1) XOR (NOT (c0 AND c1))
        #      (c0  +  c1)  +  ( -  (c0  *  c1))
        soma = self.add(c0_obj, c1_obj)
        prod = self.mult(c0_obj, c1_obj)
        res = self.add(soma, prod)


        return res
    
    def ruido(self, c_obj):
        level = c_obj['level']
        c = c_obj['criptograma']

        # c = p * q + r * t + m 
        m = self.dec(c_obj)
        noisy_msg = sym_mod(c, self.cadeiaP[level])

        noise = noisy_msg - m
        return noise / self.t