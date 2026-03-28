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
    def enc_scalar(self, m): # self - acesso aos atributos do objeto; m - mensagem a ser cifrada
        q = sample_q(self.gamma, self.eta)
        r = sample_r(self.rho)
        x = self.p * q + r
        
        delta = round(self.p / self.t)

        c = x + delta * m
        return c

    def enc_vector(self, m):
        g = [(self.b)^i for i in range(self.l)] #gadget vector
        s = [(self.p * sample_q(self.gamma, self.eta) + sample_r(self.rho)) for i in range(self.l)]

        c = [(s[i] + m * g[i]) for i in range(self.l)]
        return c

    def dec_scalar(self, c):
        y = c % self.p
        m = round((self.t * y) / self.p)

        return m % self.t
    
    # Operações homomórficas:    
    def add_scalar(self, c0, c1): # soma com criptogramas escalares
        return (c0 + c1) % self.x0

    def add_vector(self, c0, c1): #soma com criptogramas vetoriais
        c = [((c0[i] + c1[i]) % self.x0) for i in range(self.l)]
        return c

    def mult(self, c_scalar, c_vector): # multiplicação
        y = c_scalar.digits(base=self.b, padto=self.l)
        c = sum(((y[i] * c_vector[i])) for i in range(self.l))
        return c % self.x0