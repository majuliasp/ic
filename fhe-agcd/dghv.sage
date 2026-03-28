load("utils.sage")
load("distributions_acd.sage")

class DGHV:
    def __init__(self, gamma, eta, rho, t = 2, p = 1):
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
        
        # Método enc - crifação (encryption):
    def enc(self, m): # self - acesso aos atributos do objeto; m - mensagem a ser cifrada
        q = sample_q(self.gamma, self.eta)
        r = sample_r(self.rho)
        c = self.p * q + self.t * r + m # Fórmula central do DGHV: c = p*q + t*r + m
        c %= self.x0
            # Reduz o texto cifrado módulo a chave pública x0
            # Mantém c no intervalo [0, x0 - 1]
        return c # Retorna o texto cifrado

    # Método dec - decifração (decryption)
    def dec(self, c): # c - mensagem a ser decifrada
        noisy_msg = sym_mod(c, self.p) # == t * r + m
            # Como c = p * q + t * r + m, então c mod p = t * r + m 
            # O módulo simétrico garante que o resultado está em [-p/2, p/2]
        return noisy_msg % self.t 
            # Como noisy_msg = t * r + m, aplicando mod t temos simplesmente m
        
    # Operações homomórficas:
    def not_gate(self, c): # porta lógica not
        return (1 - c) % self.x0
        
    def add(self, c1, c2): # soma
        return (c1 + c2) % self.x0

    def mult(self, c1, c2): # multiplicação
        return (c1 * c2) % self.x0

    def or_gate(self, c1, c2):  #or
        return ((c1 + c2) + (c1 * c2)) % self.x0