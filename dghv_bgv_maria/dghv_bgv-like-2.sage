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
        self.l = floor(log(2^(4 * self.gamma), b)) + 1

        # Cadeia de primos p usados em cada nível multiplicativo
        self.cadeiaP = [p]
        for i in range(1, L):
            # Cada módulo deve ser congruente a p0 mod t e menor que o anterior
            pi = random_prime(self.cadeiaP[-1], lbound=2^(eta - 1))
            while pi % t != p % t: # Pra t=2 isso é irrelevante
                pi = random_prime(self.cadeiaP[-1], lbound=2^(eta - 1))
            self.cadeiaP.append(pi)
        
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
        assert c0_obj['level'] == c1_obj['level']

        level = c0_obj['level'] # nível que estamos trabalhando
        c = (c0_obj['criptograma'] + c1_obj['criptograma'] ) % self.x0

        return {
            'criptograma' : c,
            'level' : level
        }

    def keySwitchOneLevel(self, ctxt):
        level = ctxt['level']
        # Decompondo temp_c
        y = []
        c_aux = ctxt['criptograma']

        # Pegando a chave de key switching, k, do nível level para level+1
        ksKey = self.cadeiaKeySwitch[level]['key']

        for i in range(self.l):
            digit = c_aux % self.b
            y.append(digit)
            c_aux = (c_aux - digit) // self.b

        # Computando o produto
        c = self.t * sum(y[i] * ksKey[i] for i in range(self.l)) + (sym_mod(ctxt['criptograma'], self.t))

        return {
            'criptograma' : c,
            'level' : level + 1
        }



    def mult(self, c0_obj, c1_obj):
        level_0 = c0_obj['level']
        level_1 = c1_obj['level']
        if level_0 == level_1:
            return self.mult_same_level(c0_obj, c1_obj)
        
        # se criptograma c0 está num nível inferior, sobe c0 em um nível
        if level_0 < level_1:
            c0_obj = self.keySwitchOneLevel(c0_obj)

        # se criptograma c1 está num nível inferior, sobe c1 em um nível
        if level_1 < level_0:
            c1_obj = self.keySwitchOneLevel(c1_obj)

        # tenta multiplicar novamente (se ainda houver diferença de níveis,as chamadas recursivas eventualmente igualarão os níveis)
        return self.mult(c0_obj, c1_obj)



    # assume que ambos os criptogramas estão no mesmo nível
    def mult_same_level(self, c0_obj, c1_obj):
        assert(c0_obj['level'] == c1_obj['level'])

        level = c0_obj['level']

        # Valor temporário c
        tmp_c = c0_obj['criptograma'] * c1_obj['criptograma']
        # criptograma temporário com nível
        tmp_ctxt = {'criptograma' : tmp_c, 'level' : level}

        # Aplicando o key switching para aumentar nível em 1
        ctxt = self.keySwitchOneLevel(tmp_ctxt)

        return ctxt
