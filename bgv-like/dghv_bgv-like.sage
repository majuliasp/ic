load("utils.sage")
load("distributions_acd.sage")

class DGHV:
    def __init__(self, gamma, eta, rho, t = 2, p = 1, b = 2):
        # __init__ é o contrutor de um objeto da classe
        # self: referência ao próprio objeto (obrigatório em métodos de classe)
        # gamma, eta, rho: parâmetros de segurança do esquema
        # t: espaço da mensagem (padrão = 2, para bits 0, 1)
        # p: chave secreta (primo)
        assert(gamma > eta)
        assert(eta > rho)
            # Garantem que essas condições são verdadeiras
            # Caso sejam falsas, o programa para gerando AssertionError
        if 1 == p:
            p = random_prime(2^eta, lbound=2^(eta - 1))
                # lbound: lower bound, valor mínimo de retorno
        else:
            # se p é dado, precisa ter eta bits
            assert(eta - 1 <= p.nbits() <= eta)
        
        self.gamma = gamma
        self.eta = eta
        self.rho = rho
        self.t = t
        self.p = p
            # Armazena os atributos do objeto
            # self.xxxx cria variáveis que pertencem ao objeto
        qq = sample_q(gamma, eta)
        while (qq == 0):
            qq = sample_q(gamma, eta)
        self.x0 = p * qq # + self.sample_r()
            # Gera chave pública x0; limitará o tamanho do texto cifrado
        self.Zp = ZZ.quotient(p)
        self.Zx0 = ZZ.quotient(self.x0)
            # Cria anéis queociente para aritmética modular
            # ZZ.quotient(p) -> Anel dos inteiros módulo p
            # ZZ.quotient(self.x0) -> Anel dos inteiros módulo x0
        self.b = b 
        self.l = floor(log(2^self.gamma, b)) + 1
        
        # Método enc - crifação (encryption):
    def enc(self, m): # self - acesso aos atributos do objeto; m - mensagem a ser cifrada
        q = sample_q(self.gamma, self.eta)
        r = sample_r(self.rho)
        x = self.p * q + r
        c = x + m
        return c

    def dec(self, c):
        noisy_msg = sym_mod(c, self.p)
        m = noisy_msg % self.t
        return m
    
    # Operações homomórficas:    
    def add(self, c0, c1): # soma com criptogramas escalares
        return (c0 + c1) % self.x0
    
    def not_gate(self, c): # porta lógica not
        return (1 - c) % self.x0

    def mult(self, c0, c1): # multiplicação
        temp_c = (c0 * c1) 
        
        # Creating modulus-switching key
        P = random_prime(self.p, lbound=2^(self.eta - 1)) # tirando p' t.q. seja < p
        Q = [(sample_q(self.gamma, self.eta)) for i in range(self.l)] 
        R = [sample_r(self.rho) for i in range(self.l)]
        G = [(self.b)^i for i in range(self.l)] 
        k = [(P * Q[i] + R[i] + round((P/(self.t * self.p)) * G[i])) for i in range(self.l)] # modulus-switching key

        # Decomposing c
        y = []
        c_abs = abs(temp_c)
        for i in range(self.l):
            digit = c_abs % self.b
            if temp_c < 0:
                digit = -digit  # Preservar sinal
            y.append(digit)
            c_abs //= self.b

        # Computing the product
        c = self.t * sum(y[i] * k[i] for i in range(self.l)) + (temp_c % self.t)
        
        # Saving the new secret key (se isso tiver certo mesmo)
        self.p = P
        return c